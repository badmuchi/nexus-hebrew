import 'dart:convert';

import '../../../conversation/domain/entities/binyan.dart';
import '../../../dictionary/domain/entities/dictionary_entry.dart';
import '../entities/srs_card.dart';

/// Supported Anki export formats.
enum AnkiExportFormat {
  tsv(
    id: 'tsv',
    displayName: 'Anki TSV (рекомендуется)',
    fileExtension: 'tsv',
    mimeType: 'text/tab-separated-values',
  ),
  csv(
    id: 'csv',
    displayName: 'Стандартный CSV',
    fileExtension: 'csv',
    mimeType: 'text/csv',
  ),
  json(
    id: 'json',
    displayName: 'JSON массив',
    fileExtension: 'json',
    mimeType: 'application/json',
  );

  const AnkiExportFormat({
    required this.id,
    required this.displayName,
    required this.fileExtension,
    required this.mimeType,
  });

  final String id;
  final String displayName;
  final String fileExtension;
  final String mimeType;
}

/// Generic intermediate item for generating Anki decks from various app sources.
final class AnkiExportRow {
  const AnkiExportRow({
    required this.hebrewVocalized,
    required this.hebrewNormalized,
    required this.russianTranslation,
    this.transliteration,
    this.root,
    this.binyanOrPart = '',
    this.audioUrl,
    this.tags = const <String>['nexus_hebrew'],
  });

  final String hebrewVocalized;
  final String hebrewNormalized;
  final String russianTranslation;
  final String? transliteration;
  final String? root;
  final String binyanOrPart;
  final String? audioUrl;
  final List<String> tags;

  factory AnkiExportRow.fromSrsCard(SrsCard card) {
    final binyanLabel = card.binyan != Binyan.none
        ? '${card.binyan.hebrewLabel} (${card.binyan.transliteration})'
        : card.category.labelRu;
    final rootLabel = card.root?.hyphenated ?? '';
    final tags = <String>['nexus_hebrew', 'srs', 'fsrs'];
    if (card.binyan != Binyan.none) {
      tags.add(card.binyan.name);
    }

    return AnkiExportRow(
      hebrewVocalized: card.hebrew.vocalized,
      hebrewNormalized: card.hebrew.normalized,
      russianTranslation: card.russianTranslation,
      transliteration: null,
      root: rootLabel.isNotEmpty ? rootLabel : null,
      binyanOrPart: binyanLabel,
      audioUrl: card.audioUrl,
      tags: tags,
    );
  }

  factory AnkiExportRow.fromDictionaryEntry(DictionaryEntry entry) {
    final binyanLabel = entry.binyan != Binyan.none
        ? '${entry.binyan.hebrewLabel} (${entry.binyan.transliteration})'
        : entry.category.labelRu;
    final rootLabel = entry.root?.hyphenated ?? '';
    final tags = <String>[
      'nexus_hebrew',
      'dictionary',
      entry.category.id,
    ];

    return AnkiExportRow(
      hebrewVocalized: entry.hebrew.vocalized,
      hebrewNormalized: entry.hebrew.normalized,
      russianTranslation: entry.russianTranslation,
      transliteration: entry.transliteration,
      root: rootLabel.isNotEmpty ? rootLabel : null,
      binyanOrPart: binyanLabel,
      audioUrl: entry.audioUrl,
      tags: tags,
    );
  }
}

/// Service that serializes flashcards and dictionary entries into Anki-ready formats.
final class AnkiDeckExportService {
  const AnkiDeckExportService();

  /// Exports a list of [SrsCard]s into the chosen [AnkiExportFormat].
  String exportSrsCards(
    List<SrsCard> cards, {
    AnkiExportFormat format = AnkiExportFormat.tsv,
    bool includeNikkud = true,
  }) {
    final rows = cards.map(AnkiExportRow.fromSrsCard).toList(growable: false);
    return exportRows(rows, format: format, includeNikkud: includeNikkud);
  }

  /// Exports a list of [DictionaryEntry]s into the chosen [AnkiExportFormat].
  String exportDictionaryEntries(
    List<DictionaryEntry> entries, {
    AnkiExportFormat format = AnkiExportFormat.tsv,
    bool includeNikkud = true,
  }) {
    final rows = entries
        .map(AnkiExportRow.fromDictionaryEntry)
        .toList(growable: false);
    return exportRows(rows, format: format, includeNikkud: includeNikkud);
  }

  /// Serializes generic [AnkiExportRow] items into formatted text string.
  String exportRows(
    List<AnkiExportRow> rows, {
    AnkiExportFormat format = AnkiExportFormat.tsv,
    bool includeNikkud = true,
  }) {
    final buffer = StringBuffer();

    if (format == AnkiExportFormat.json) {
      final list = rows.map((r) {
        return <String, dynamic>{
          'hebrew': includeNikkud ? r.hebrewVocalized : r.hebrewNormalized,
          'hebrewNormalized': r.hebrewNormalized,
          'russianTranslation': r.russianTranslation,
          if (r.transliteration != null && r.transliteration!.isNotEmpty)
            'transliteration': r.transliteration,
          if (r.root != null && r.root!.isNotEmpty) 'root': r.root,
          if (r.binyanOrPart.isNotEmpty) 'binyanOrCategory': r.binyanOrPart,
          if (r.audioUrl != null && r.audioUrl!.isNotEmpty) 'audio': r.audioUrl,
          'tags': r.tags,
        };
      }).toList(growable: false);
      return const JsonEncoder.withIndent('  ').convert(list);
    }

    if (format == AnkiExportFormat.tsv) {
      // Anki TSV metadata headers for auto-configuration on import
      buffer.writeln('#separator:tab');
      buffer.writeln('#html:true');
      buffer.writeln('#tags column:7');
      buffer.writeln(
        'Front\tBack\tTransliteration\tRoot\tBinyanOrCategory\tAudio\tTags',
      );

      for (final row in rows) {
        final front = includeNikkud
            ? row.hebrewVocalized
            : row.hebrewNormalized;
        final back = _sanitizeForTsv(row.russianTranslation);
        final translit = _sanitizeForTsv(row.transliteration ?? '');
        final root = _sanitizeForTsv(row.root ?? '');
        final binyan = _sanitizeForTsv(row.binyanOrPart);
        final audio = _formatAnkiAudio(row.audioUrl);
        final tags = row.tags.join(' ');

        buffer.writeln(
          '$front\t$back\t$translit\t$root\t$binyan\t$audio\t$tags',
        );
      }
    } else {
      // Standard RFC 4180 CSV
      buffer.writeln(
        'Front,Back,Transliteration,Root,BinyanOrCategory,Audio,Tags',
      );

      for (final row in rows) {
        final front = includeNikkud
            ? row.hebrewVocalized
            : row.hebrewNormalized;
        final back = row.russianTranslation;
        final translit = row.transliteration ?? '';
        final root = row.root ?? '';
        final binyan = row.binyanOrPart;
        final audio = _formatAnkiAudio(row.audioUrl);
        final tags = row.tags.join(' ');

        final line = [
          _escapeCsv(front),
          _escapeCsv(back),
          _escapeCsv(translit),
          _escapeCsv(root),
          _escapeCsv(binyan),
          _escapeCsv(audio),
          _escapeCsv(tags),
        ].join(',');

        buffer.writeln(line);
      }
    }

    return buffer.toString();
  }

  String _sanitizeForTsv(String input) {
    return input
        .replaceAll('\t', ' ')
        .replaceAll('\r\n', ' ')
        .replaceAll('\n', ' ')
        .trim();
  }

  String _formatAnkiAudio(String? audioUrl) {
    if (audioUrl == null || audioUrl.trim().isEmpty) return '';
    final trimmed = audioUrl.trim();
    final fileName = trimmed.split('/').last;
    if (fileName.endsWith('.mp3') || fileName.endsWith('.m4a') || fileName.endsWith('.wav')) {
      return '[sound:$fileName]';
    }
    return trimmed;
  }

  String _escapeCsv(String field) {
    final sanitized = field.replaceAll('\r\n', ' ').replaceAll('\n', ' ');
    if (sanitized.contains(',') ||
        sanitized.contains('"') ||
        sanitized.contains(';') ||
        sanitized.contains('\n')) {
      return '"${sanitized.replaceAll('"', '""')}"';
    }
    return sanitized;
  }
}
