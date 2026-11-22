import 'dart:convert';

import 'package:equatable/equatable.dart';

import '../../../../core/result/result.dart';
import '../../../../core/utils/hebrew_normalizer.dart';
import '../../../conversation/domain/entities/binyan.dart';
import '../../../conversation/domain/entities/hebrew_text.dart';

/// Parsed card payload ready for insertion into the FSRS deck.
final class ImportedCardItem extends Equatable {
  final String hebrewVocalized;
  final String hebrewNormalized;
  final String russianTranslation;
  final String? transliteration;
  final Shoresh? root;
  final Binyan binyan;
  final String? audioUrl;
  final List<String> tags;

  const ImportedCardItem({
    required this.hebrewVocalized,
    required this.hebrewNormalized,
    required this.russianTranslation,
    this.transliteration,
    this.root,
    this.binyan = Binyan.none,
    this.audioUrl,
    this.tags = const <String>['imported'],
  });

  @override
  List<Object?> get props => [
        hebrewVocalized,
        hebrewNormalized,
        russianTranslation,
        transliteration,
        root,
        binyan,
        audioUrl,
        tags,
      ];
}

/// Result of parsing an imported deck string.
final class DeckImportResult extends Equatable {
  final List<ImportedCardItem> validCards;
  final List<String> skippedLines;
  final String formatDetected;

  const DeckImportResult({
    required this.validCards,
    required this.skippedLines,
    required this.formatDetected,
  });

  int get totalValid => validCards.length;
  int get totalSkipped => skippedLines.length;

  @override
  List<Object?> get props => [validCards, skippedLines, formatDetected];
}

/// Service that parses Anki TSV/CSV, JSON, and word lists into [ImportedCardItem]s.
final class DeckImportService {
  const DeckImportService();

  DeckImportResult parse(String rawContent) {
    final trimmed = rawContent.trim();
    if (trimmed.isEmpty) {
      return const DeckImportResult(
        validCards: <ImportedCardItem>[],
        skippedLines: <String>[],
        formatDetected: 'Пустой ввод',
      );
    }

    // 1. Check for JSON array
    if (trimmed.startsWith('[') || trimmed.startsWith('{')) {
      final jsonResult = _parseJson(trimmed);
      if (jsonResult != null && jsonResult.validCards.isNotEmpty) {
        return jsonResult;
      }
    }

    // 2. Check for TSV (Anki TSV contains tabs)
    if (trimmed.contains('\t')) {
      return _parseTsv(trimmed);
    }

    // 3. Fallback to CSV / Delimited lines
    return _parseDelimited(trimmed);
  }

  DeckImportResult? _parseJson(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);
      final List<dynamic> items;
      if (decoded is List) {
        items = decoded;
      } else if (decoded is Map<String, dynamic> && decoded['cards'] is List) {
        items = decoded['cards'] as List<dynamic>;
      } else {
        return null;
      }

      final validCards = <ImportedCardItem>[];
      final skipped = <String>[];

      for (var i = 0; i < items.length; i++) {
        final item = items[i];
        if (item is! Map) {
          skipped.add('Элемент #$i не является объектом');
          continue;
        }

        final hebrewRaw = (item['hebrew'] ??
                item['front'] ??
                item['word'] ??
                item['text'] ??
                item['vocalized'] ??
                '')
            .toString()
            .trim();
        final translationRaw = (item['russianTranslation'] ??
                item['translation'] ??
                item['back'] ??
                item['meaning'] ??
                item['definition'] ??
                item['ru'] ??
                '')
            .toString()
            .trim();

        final parsed = _buildCard(
          rawHebrew: hebrewRaw,
          rawTranslation: translationRaw,
          rawTranslit: item['transliteration']?.toString(),
          rawRoot: item['root']?.toString(),
          rawBinyanOrCategory: (item['binyanOrCategory'] ?? item['binyan'])?.toString(),
          rawAudio: (item['audio'] ?? item['audioUrl'])?.toString(),
          tags: _extractTags(item['tags']),
        );

        if (parsed != null) {
          validCards.add(parsed);
        } else {
          skipped.add('Строка #$i: "$hebrewRaw" / "$translationRaw"');
        }
      }

      return DeckImportResult(
        validCards: validCards,
        skippedLines: skipped,
        formatDetected: 'JSON',
      );
    } on Object catch (_) {
      return null;
    }
  }

  DeckImportResult _parseTsv(String content) {
    final lines = content.split(RegExp(r'\r?\n'));
    final validCards = <ImportedCardItem>[];
    final skipped = <String>[];

    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;
      // Skip Anki configuration comments
      if (line.startsWith('#')) continue;

      final columns = line.split('\t').map((c) => c.trim()).toList();
      if (columns.length < 2) {
        skipped.add(line);
        continue;
      }

      // Skip header if present
      if (_isHeaderLine(columns[0], columns[1])) {
        continue;
      }

      final hebrewCol = columns[0];
      final translationCol = columns[1];
      final translitCol = columns.length > 2 ? columns[2] : null;
      final rootCol = columns.length > 3 ? columns[3] : null;
      final binyanCol = columns.length > 4 ? columns[4] : null;
      final audioCol = columns.length > 5 ? columns[5] : null;
      final tagsCol = columns.length > 6 ? columns[6] : null;

      final parsed = _buildCard(
        rawHebrew: hebrewCol,
        rawTranslation: translationCol,
        rawTranslit: translitCol,
        rawRoot: rootCol,
        rawBinyanOrCategory: binyanCol,
        rawAudio: audioCol,
        tags: tagsCol != null && tagsCol.isNotEmpty ? tagsCol.split(RegExp(r'[,;\s]+')) : const ['imported'],
      );

      if (parsed != null) {
        validCards.add(parsed);
      } else {
        skipped.add(line);
      }
    }

    return DeckImportResult(
      validCards: validCards,
      skippedLines: skipped,
      formatDetected: 'Anki TSV',
    );
  }

  DeckImportResult _parseDelimited(String content) {
    final lines = content.split(RegExp(r'\r?\n'));
    final validCards = <ImportedCardItem>[];
    final skipped = <String>[];
    var isCsvFormat = false;

    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;
      if (line.startsWith('#')) continue;

      List<String> tokens;

      if (line.contains(';') || line.contains(',')) {
        tokens = _parseCsvLine(line);
        isCsvFormat = true;
      } else {
        // Check for list separators: ' - ', ' — ', ' – ', ' : '
        final match = RegExp(r'\s+[-—–:]\s+').firstMatch(line);
        if (match != null) {
          final left = line.substring(0, match.start).trim();
          final right = line.substring(match.end).trim();
          tokens = [left, right];
        } else {
          skipped.add(line);
          continue;
        }
      }

      if (tokens.length < 2) {
        skipped.add(line);
        continue;
      }

      if (_isHeaderLine(tokens[0], tokens[1])) {
        continue;
      }

      final parsed = _buildCard(
        rawHebrew: tokens[0],
        rawTranslation: tokens[1],
        rawTranslit: tokens.length > 2 ? tokens[2] : null,
        rawRoot: tokens.length > 3 ? tokens[3] : null,
        rawBinyanOrCategory: tokens.length > 4 ? tokens[4] : null,
        rawAudio: tokens.length > 5 ? tokens[5] : null,
        tags: tokens.length > 6 ? tokens[6].split(RegExp(r'[,;\s]+')) : const ['imported'],
      );

      if (parsed != null) {
        validCards.add(parsed);
      } else {
        skipped.add(line);
      }
    }

    return DeckImportResult(
      validCards: validCards,
      skippedLines: skipped,
      formatDetected: isCsvFormat ? 'CSV' : 'Текстовый список',
    );
  }

  ImportedCardItem? _buildCard({
    required String rawHebrew,
    required String rawTranslation,
    String? rawTranslit,
    String? rawRoot,
    String? rawBinyanOrCategory,
    String? rawAudio,
    List<String> tags = const ['imported'],
  }) {
    var hebrew = _cleanField(rawHebrew);
    var translation = _cleanField(rawTranslation);

    if (hebrew.isEmpty || translation.isEmpty) return null;

    // Detect if user has Hebrew in second column and Russian in first column
    final hebrewInFirst = HebrewNormalizer.extractHebrewLetters(hebrew).isNotEmpty;
    final hebrewInSecond = HebrewNormalizer.extractHebrewLetters(translation).isNotEmpty;

    if (!hebrewInFirst && hebrewInSecond) {
      final temp = hebrew;
      hebrew = translation;
      translation = temp;
    } else if (!hebrewInFirst && !hebrewInSecond) {
      return null;
    }

    final vocalized = HebrewNormalizer.toNfc(hebrew);
    final normalized = HebrewNormalizer.normalizeForComparison(hebrew);

    // Resolve Binyan
    var binyan = Binyan.none;
    if (rawBinyanOrCategory != null && rawBinyanOrCategory.isNotEmpty) {
      final binyanLower = rawBinyanOrCategory.toLowerCase();
      for (final b in Binyan.values) {
        if (b == Binyan.none) continue;
        if (binyanLower.contains(b.name) ||
            binyanLower.contains(b.transliteration.toLowerCase()) ||
            binyanLower.contains(b.hebrewLabel)) {
          binyan = b;
          break;
        }
      }
    }

    // Resolve Shoresh
    Shoresh? root;
    if (rawRoot != null && rawRoot.trim().isNotEmpty) {
      final rootRes = Shoresh.create(rawRoot.trim());
      if (rootRes case Success(:final data)) {
        root = data;
      }
    }

    // Clean Audio (remove [sound:...] Anki wrapper)
    String? cleanAudio = rawAudio?.trim();
    if (cleanAudio != null) {
      final soundMatch = RegExp(r'\[sound:(.*?)\]').firstMatch(cleanAudio);
      if (soundMatch != null) {
        cleanAudio = soundMatch.group(1);
      }
      if (cleanAudio != null && cleanAudio.isEmpty) {
        cleanAudio = null;
      }
    }

    return ImportedCardItem(
      hebrewVocalized: vocalized,
      hebrewNormalized: normalized,
      russianTranslation: translation,
      transliteration: rawTranslit?.trim().isNotEmpty == true ? rawTranslit!.trim() : null,
      root: root,
      binyan: binyan,
      audioUrl: cleanAudio,
      tags: tags.where((t) => t.trim().isNotEmpty).map((t) => t.trim()).toList(),
    );
  }

  List<String> _parseCsvLine(String line) {
    final delimiter = line.contains(';') ? ';' : ',';
    final result = <String>[];
    final buffer = StringBuffer();
    var insideQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        if (insideQuotes && i + 1 < line.length && line[i + 1] == '"') {
          buffer.write('"');
          i++; // Skip escaped quote
        } else {
          insideQuotes = !insideQuotes;
        }
      } else if (char == delimiter && !insideQuotes) {
        result.add(buffer.toString().trim());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }
    result.add(buffer.toString().trim());
    return result;
  }

  String _cleanField(String raw) {
    return raw
        .replaceAll(RegExp(r'<[^>]*>'), ' ') // Remove simple HTML tags
        .replaceAll('&nbsp;', ' ')
        .trim();
  }

  bool _isHeaderLine(String col1, String col2) {
    final lower1 = col1.toLowerCase();
    final lower2 = col2.toLowerCase();
    return (lower1 == 'front' && lower2 == 'back') ||
        (lower1 == 'hebrew' && lower2 == 'russian') ||
        (lower1 == 'слово' && lower2 == 'перевод') ||
        (lower1 == 'иврит' && lower2 == 'русский');
  }

  List<String> _extractTags(dynamic tagsRaw) {
    if (tagsRaw is List) {
      return tagsRaw.map((e) => e.toString().trim()).where((t) => t.isNotEmpty).toList();
    }
    if (tagsRaw is String && tagsRaw.isNotEmpty) {
      return tagsRaw.split(RegExp(r'[,;\s]+')).map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
    }
    return const ['imported'];
  }
}
