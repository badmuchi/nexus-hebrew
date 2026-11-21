import 'package:nexus_hebrew_app/core/utils/hebrew_normalizer.dart';
import 'package:nexus_hebrew_app/features/alphabet/data/datasources/hebrew_alphabet_seed_data.dart';
import 'package:nexus_hebrew_app/features/alphabet/domain/entities/hebrew_letter.dart';
import 'package:nexus_hebrew_app/features/alphabet/domain/entities/nikkud_mark.dart';
import 'package:nexus_hebrew_app/features/dictionary/domain/entities/dictionary_entry.dart';
import 'package:nexus_hebrew_app/features/grammar/data/datasources/hebrew_prepositions_seed_data.dart';
import 'package:nexus_hebrew_app/features/grammar/domain/entities/preposition_inflection.dart';
import 'package:nexus_hebrew_app/features/scenes/data/datasources/israeli_scenes_seed_data.dart';
import 'package:nexus_hebrew_app/features/scenes/domain/entities/israeli_life_scene.dart';
import 'package:nexus_hebrew_app/features/slang/domain/entities/slang_expression.dart';
import '../entities/omni_search_result.dart';

/// High-performance in-memory search engine across all app domains.
class OmniSearchEngine {
  final List<OmniSearchResult> _items = [];

  OmniSearchEngine({List<OmniSearchResult>? initialItems}) {
    if (initialItems != null) {
      _items.addAll(initialItems);
    }
  }

  /// Factory creating an engine pre-populated with alphabet letters, nikkud, and core prepositions.
  factory OmniSearchEngine.withStaticDefaults() {
    final engine = OmniSearchEngine();
    engine.addAlphabetLetters(HebrewAlphabetSeedData.letters);
    engine.addNikkudMarks(HebrewAlphabetSeedData.nikkudMarks);
    engine.addPrepositions(HebrewPrepositionsSeedData.prepositions);
    engine.addSceneContent(IsraeliScenesSeedData.scenes);
    return engine;
  }

  /// Total indexed items count.
  int get count => _items.length;

  /// Clear all indexed items.
  void clear() => _items.clear();

  /// Adds a custom list of search items.
  void addResults(Iterable<OmniSearchResult> items) {
    _items.addAll(items);
  }

  /// Indexes Hebrew Alphabet letters.
  void addAlphabetLetters(Iterable<HebrewLetter> letters) {
    for (final l in letters) {
      _items.add(
        OmniSearchResult(
          id: 'letter_${l.id}',
          category: OmniResultCategory.alphabet,
          hebrewWithNikkud: '${l.printed} (${l.nameHebrew})',
          hebrewWithoutNikkud: l.printed,
          translationRu: '${l.nameRussian}: ${l.soundDescription}',
          transliteration: l.transliteration,
          details: 'Буква ${l.printed} • Пример: ${l.exampleWordHebrew} (${l.exampleWordRussian}) • Гематрия: ${l.gematria}',
          audioText: l.exampleWordHebrew,
          originalObject: l,
        ),
      );
    }
  }

  /// Indexes Hebrew Nikkud marks.
  void addNikkudMarks(Iterable<NikkudMark> marks) {
    for (final m in marks) {
      _items.add(
        OmniSearchResult(
          id: 'nikkud_${m.id}',
          category: OmniResultCategory.alphabet,
          hebrewWithNikkud: '${m.symbol} ${m.nameHebrew}',
          hebrewWithoutNikkud: HebrewNormalizer.stripNikkud(m.nameHebrew),
          translationRu: '${m.nameRussian} (${m.sound})',
          transliteration: m.exampleWordTranscription,
          details: '${m.symbol} • Пример: ${m.exampleWordHebrew} (${m.exampleWordRussian}) • ${m.description}',
          audioText: m.exampleWordHebrew,
          originalObject: m,
        ),
      );
    }
  }

  /// Indexes dictionary entries.
  void addDictionaryEntries(Iterable<DictionaryEntry> entries) {
    for (final e in entries) {
      _items.add(
        OmniSearchResult(
          id: 'dict_${e.id}',
          category: OmniResultCategory.dictionary,
          hebrewWithNikkud: e.hebrew.vocalized,
          hebrewWithoutNikkud: e.hebrew.normalized,
          translationRu: e.russianTranslation,
          transliteration: e.transliteration,
          root: e.root?.hyphenated,
          details: e.category.labelRu,
          audioText: e.hebrew.vocalized,
          originalObject: e,
        ),
      );
    }
  }

  /// Indexes Israeli slang expressions.
  void addSlangExpressions(Iterable<SlangExpression> slangList) {
    for (final s in slangList) {
      _items.add(
        OmniSearchResult(
          id: 'slang_${s.id}',
          category: OmniResultCategory.slang,
          hebrewWithNikkud: s.hebrew.vocalized,
          hebrewWithoutNikkud: s.hebrew.normalized,
          translationRu: s.translationRu,
          transliteration: s.transliteration,
          details: '${s.category.titleRu} • Дословно: ${s.literalTranslationRu}',
          audioText: s.hebrew.vocalized,
          originalObject: s,
        ),
      );
    }
  }

  /// Indexes Hebrew prepositions and their inflected forms.
  void addPrepositions(Iterable<PrepositionEntity> prepositions) {
    for (final p in prepositions) {
      _items.add(
        OmniSearchResult(
          id: 'prep_${p.id}',
          category: OmniResultCategory.preposition,
          hebrewWithNikkud: p.baseHebrew,
          hebrewWithoutNikkud: HebrewNormalizer.stripNikkud(p.baseHebrew),
          translationRu: p.baseRussian,
          transliteration: p.transliteration,
          details: p.usageNote,
          audioText: p.baseHebrew,
          originalObject: p,
        ),
      );

      for (final f in p.forms) {
        _items.add(
          OmniSearchResult(
            id: 'prep_form_${p.id}_${f.hebrewNormalized}_${f.person.name}',
            category: OmniResultCategory.preposition,
            hebrewWithNikkud: f.hebrewVocalized,
            hebrewWithoutNikkud: f.hebrewNormalized,
            translationRu: f.russianTranslation,
            transliteration: f.transliteration,
            details: 'Форма предлога ${p.baseHebrew} (${f.person.labelRu})',
            audioText: f.exampleSentenceHebrew.isNotEmpty ? f.exampleSentenceHebrew : f.hebrewVocalized,
            originalObject: f,
          ),
        );
      }
    }
  }

  /// Indexes Israeli real-life scene vocabulary and phrases.
  void addSceneContent(Iterable<IsraeliLifeScene> scenes) {
    for (final s in scenes) {
      for (final w in s.words) {
        _items.add(
          OmniSearchResult(
            id: 'scene_word_${w.id}',
            category: OmniResultCategory.dictionary,
            hebrewWithNikkud: w.hebrewVocalized,
            hebrewWithoutNikkud: w.hebrewNormalized,
            translationRu: '${w.russianMeaning} (${s.titleRussian})',
            transliteration: w.transliteration,
            root: w.root,
            details: '${s.emoji} ${s.titleRussian} • ${w.contextNote ?? ""}',
            audioText: w.hebrewVocalized,
            originalObject: w,
          ),
        );
      }
      for (final p in s.phrases) {
        _items.add(
          OmniSearchResult(
            id: 'scene_phrase_${p.id}',
            category: OmniResultCategory.slang,
            hebrewWithNikkud: p.hebrewVocalized,
            hebrewWithoutNikkud: p.hebrewNormalized,
            translationRu: '${p.russianTranslation} (${s.titleRussian})',
            transliteration: p.transliteration,
            details: '${s.emoji} ${p.role.labelRu} • ${p.culturalTip ?? ""}',
            audioText: p.hebrewVocalized,
            originalObject: p,
          ),
        );
      }
    }
  }

  /// Searches indexed items with resilient normalization and relevance ranking.
  List<OmniSearchResult> search(
    String query, {
    OmniResultCategory? categoryFilter,
    int limit = 40,
  }) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];

    final rawLower = trimmed.toLowerCase();
    final normQuery = HebrewNormalizer.normalizeForComparison(rawLower);

    final scoredList = <_ScoredResult>[];

    for (final item in _items) {
      if (categoryFilter != null && item.category != categoryFilter) {
        continue;
      }

      int score = 0;
      final itemHebrewNorm = HebrewNormalizer.normalizeForComparison(item.hebrewWithoutNikkud);
      final itemVocalNorm = HebrewNormalizer.normalizeForComparison(item.hebrewWithNikkud);
      final itemRuLower = item.translationRu.toLowerCase();
      final itemTransLower = item.transliteration?.toLowerCase() ?? '';
      final itemRootNorm = item.root != null
          ? HebrewNormalizer.normalizeForComparison(item.root!.replaceAll('-', ''))
          : '';

      // 1. Hebrew direct match
      if (itemHebrewNorm == normQuery || itemVocalNorm == normQuery) {
        score += 120;
      } else if (itemHebrewNorm.startsWith(normQuery) || itemVocalNorm.startsWith(normQuery)) {
        score += 80;
      } else if (itemHebrewNorm.contains(normQuery) || itemVocalNorm.contains(normQuery)) {
        score += 50;
      }

      // 2. Shoresh / Root match
      if (itemRootNorm.isNotEmpty) {
        if (itemRootNorm == normQuery) {
          score += 100;
        } else if (itemRootNorm.contains(normQuery)) {
          score += 60;
        }
      }

      // 3. Russian translation match
      if (itemRuLower == rawLower) {
        score += 110;
      } else if (itemRuLower.startsWith(rawLower)) {
        score += 70;
      } else if (itemRuLower.contains(rawLower)) {
        score += 40;
      }

      // 4. Transliteration match
      if (itemTransLower.isNotEmpty) {
        if (itemTransLower == rawLower) {
          score += 90;
        } else if (itemTransLower.startsWith(rawLower)) {
          score += 50;
        } else if (itemTransLower.contains(rawLower)) {
          score += 30;
        }
      }

      // 5. Details match
      if (item.details != null && item.details!.toLowerCase().contains(rawLower)) {
        score += 15;
      }

      if (score > 0) {
        scoredList.add(_ScoredResult(result: item, score: score));
      }
    }

    scoredList.sort((a, b) => b.score.compareTo(a.score));

    return scoredList.take(limit).map((e) => e.result).toList(growable: false);
  }
}

final class _ScoredResult {
  const _ScoredResult({required this.result, required this.score});

  final OmniSearchResult result;
  final int score;
}
