import '../../../../core/utils/hebrew_normalizer.dart';
import '../../../conversation/domain/entities/hebrew_text.dart';
import '../entities/dictionary_entry.dart';

/// Filters, ranks, and matches dictionary entries against a bidirectional query.
class SearchDictionaryEntriesUseCase {
  const SearchDictionaryEntriesUseCase();

  /// Executes bidirectional Hebrew/Russian/root filtering and relevance ranking.
  List<DictionarySearchMatch> call({
    required List<DictionaryEntry> entries,
    required DictionaryFilter filter,
    Set<String> srsNormalizedForms = const <String>{},
  }) {
    final trimmed = filter.query.trim();
    final lowerQuery = trimmed.toLowerCase();
    final hebNormalizedExact = HebrewNormalizer.normalizeForComparison(trimmed);
    final hebNormalizedLoose = HebrewNormalizer.normalizeForComparison(
      trimmed,
      normalizeFinalForms: true,
    );
    final queryLetters = HebrewNormalizer.extractHebrewLetters(trimmed);

    final scored = <_ScoredMatch>[];

    for (final entry in entries) {
      final isInSrs = srsNormalizedForms.contains(entry.hebrew.normalized);
      if (filter.onlyInSrs && !isInSrs) {
        continue;
      }
      if (filter.onlyWithRoot && entry.root == null) {
        continue;
      }
      if (filter.category != null && entry.category != filter.category) {
        continue;
      }
      if (filter.binyan != null && entry.binyan != filter.binyan) {
        continue;
      }
      if (filter.rootFilter != null &&
          entry.root?.compact != filter.rootFilter!.compact) {
        continue;
      }

      if (trimmed.isEmpty) {
        scored.add(
          _ScoredMatch(
            match: DictionarySearchMatch(entry: entry, isInSrs: isInSrs),
            score: 0,
          ),
        );
        continue;
      }

      final score = _scoreEntry(
        entry: entry,
        lowerQuery: lowerQuery,
        hebNormalizedExact: hebNormalizedExact,
        hebNormalizedLoose: hebNormalizedLoose,
        queryLetters: queryLetters,
      );
      if (score != null) {
        scored.add(
          _ScoredMatch(
            match: DictionarySearchMatch(entry: entry, isInSrs: isInSrs),
            score: score,
          ),
        );
      }
    }

    scored.sort((_ScoredMatch a, _ScoredMatch b) {
      final scoreCmp = b.score.compareTo(a.score);
      if (scoreCmp != 0) {
        return scoreCmp;
      }
      final rankA = a.match.entry.frequencyRank ?? 999999;
      final rankB = b.match.entry.frequencyRank ?? 999999;
      final rankCmp = rankA.compareTo(rankB);
      if (rankCmp != 0) {
        return rankCmp;
      }
      return a.match.entry.hebrew.normalized.compareTo(
        b.match.entry.hebrew.normalized,
      );
    });

    return List<DictionarySearchMatch>.unmodifiable(
      scored.map((_ScoredMatch item) => item.match),
    );
  }

  /// Returns all dictionary entries sharing the same Hebrew shoresh [root].
  List<DictionaryEntry> findRelatedByRoot({
    required List<DictionaryEntry> entries,
    required Shoresh root,
    String? excludeEntryId,
  }) {
    final target = root.compact;
    final related = entries
        .where(
          (DictionaryEntry e) =>
              e.id != excludeEntryId && e.root?.compact == target,
        )
        .toList(growable: false)
      ..sort((DictionaryEntry a, DictionaryEntry b) {
        final rankA = a.frequencyRank ?? 999999;
        final rankB = b.frequencyRank ?? 999999;
        return rankA.compareTo(rankB);
      });
    return List<DictionaryEntry>.unmodifiable(related);
  }

  int? _scoreEntry({
    required DictionaryEntry entry,
    required String lowerQuery,
    required String hebNormalizedExact,
    required String hebNormalizedLoose,
    required String queryLetters,
  }) {
    var bestScore = -1;

    final entryHebExact = entry.hebrew.normalized;
    final entryHebLoose = HebrewNormalizer.replaceFinalLetters(entryHebExact);
    final ruLower = entry.russianTranslation.toLowerCase();
    final translitLower = (entry.transliteration ?? '').toLowerCase();
    final formsNormalized = entry.formsSummary == null
        ? ''
        : HebrewNormalizer.normalizeForComparison(
            entry.formsSummary!,
            normalizeFinalForms: true,
          );

    if (hebNormalizedExact.isNotEmpty) {
      if (entryHebExact == hebNormalizedExact) {
        bestScore = _maxScore(bestScore, 100);
      } else if (entryHebLoose == hebNormalizedLoose) {
        bestScore = _maxScore(bestScore, 95);
      } else if (entryHebLoose.startsWith(hebNormalizedLoose)) {
        bestScore = _maxScore(bestScore, 80);
      } else if (entryHebLoose.contains(hebNormalizedLoose)) {
        bestScore = _maxScore(bestScore, 60);
      } else if (formsNormalized.isNotEmpty &&
          formsNormalized.contains(hebNormalizedLoose)) {
        bestScore = _maxScore(bestScore, 55);
      }
    }

    if (entry.root != null) {
      final rootCompact = entry.root!.compact;
      final rootHyphenated = entry.root!.hyphenated;
      if (queryLetters.isNotEmpty && rootCompact == queryLetters) {
        bestScore = _maxScore(bestScore, 90);
      } else if (hebNormalizedExact.isNotEmpty &&
          rootHyphenated.contains(hebNormalizedExact)) {
        bestScore = _maxScore(bestScore, 75);
      } else if (queryLetters.length >= 2 && rootCompact.contains(queryLetters)) {
        bestScore = _maxScore(bestScore, 50);
      }
    }

    final ruTokens = ruLower
        .split(RegExp(r'[;,/()\s]+'))
        .where((String part) => part.isNotEmpty);
    if (ruLower == lowerQuery) {
      bestScore = _maxScore(bestScore, 98);
    } else if (ruTokens.any((String tok) => tok == lowerQuery)) {
      bestScore = _maxScore(bestScore, 85);
    } else if (ruLower.startsWith(lowerQuery) ||
        ruTokens.any((String tok) => tok.startsWith(lowerQuery))) {
      bestScore = _maxScore(bestScore, 72);
    } else if (ruLower.contains(lowerQuery)) {
      bestScore = _maxScore(bestScore, 55);
    }

    if (translitLower.isNotEmpty && translitLower.contains(lowerQuery)) {
      bestScore = _maxScore(bestScore, translitLower.startsWith(lowerQuery) ? 58 : 42);
    }

    final exHeb = entry.exampleHebrew?.normalized ?? '';
    final exRu = (entry.exampleRussian ?? '').toLowerCase();
    if (hebNormalizedLoose.length >= 2 &&
        exHeb.isNotEmpty &&
        HebrewNormalizer.replaceFinalLetters(exHeb).contains(hebNormalizedLoose)) {
      bestScore = _maxScore(bestScore, 30);
    } else if (lowerQuery.length >= 3 && exRu.contains(lowerQuery)) {
      bestScore = _maxScore(bestScore, 25);
    }

    return bestScore >= 0 ? bestScore : null;
  }

  static int _maxScore(int current, int candidate) =>
      candidate > current ? candidate : current;
}

final class _ScoredMatch {
  const _ScoredMatch({required this.match, required this.score});

  final DictionarySearchMatch match;
  final int score;
}
