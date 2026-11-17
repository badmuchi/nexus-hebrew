import '../../../../core/database/app_database.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/result/result.dart';
import '../../../../core/utils/hebrew_normalizer.dart';
import '../../../conversation/domain/entities/binyan.dart';
import '../../../conversation/domain/entities/hebrew_text.dart';
import '../../../srs/domain/entities/fsrs_models.dart';
import '../../domain/entities/learning_progress_summary.dart';

/// Contract for local progress aggregation and cross-table Hebrew search.
abstract interface class ProgressLocalDataSource {
  /// Aggregates mastery, streak, and accuracy stats from local SQLite tables.
  Future<Result<LearningProgressSummary, Failure>> loadSummary({
    required DateTime asOf,
  });

  /// Searches across FSRS cards, grammar verbs, dialogues, and listening items.
  Future<Result<List<GlobalHebrewSearchResult>, Failure>> searchLibrary(
    String query,
  );
}

/// Drift-backed implementation of [ProgressLocalDataSource].
final class DriftProgressLocalDataSource implements ProgressLocalDataSource {
  static const String _tag = 'DriftProgressLocalDataSource';

  const DriftProgressLocalDataSource({
    required AppDatabase database,
    required AppLogger logger,
  })  : _database = database,
        _logger = logger;

  final AppDatabase _database;
  final AppLogger _logger;

  @override
  Future<Result<LearningProgressSummary, Failure>> loadSummary({
    required DateTime asOf,
  }) async {
    try {
      final cards = await _database.getAllSrsCards();
      final srsLogs = await _database.getAllSrsReviewLogs();
      final grammarLogs = await _database.getAllGrammarPracticeLogs();
      final grammarVerbs = await _database.getGrammarVerbs();
      final listeningLogs = await _database.getAllListeningAttemptLogs();

      var dueCount = 0;
      var newCount = 0;
      var learningCount = 0;
      var reviewCount = 0;
      var relearningCount = 0;

      for (final card in cards) {
        if (!card.dueAt.isAfter(asOf)) {
          dueCount += 1;
        }
        final stateRes = FsrsCardState.parseStrict(card.fsrsState);
        switch (stateRes.getOrNull()) {
          case FsrsCardState.newCard:
          case null:
            newCount += 1;
          case FsrsCardState.learning:
            learningCount += 1;
          case FsrsCardState.review:
            reviewCount += 1;
          case FsrsCardState.relearning:
            relearningCount += 1;
        }
      }

      final verbBinyanById = <String, Binyan>{};
      for (final verb in grammarVerbs) {
        final binyan = Binyan.parseStrict(verb.binyan).getOrNull();
        if (binyan != null && binyan != Binyan.none) {
          verbBinyanById[verb.id] = binyan;
        }
      }

      var grammarCorrect = 0;
      final totalByBinyan = <Binyan, int>{};
      final correctByBinyan = <Binyan, int>{};

      for (final log in grammarLogs) {
        if (log.isCorrect) {
          grammarCorrect += 1;
        }
        final binyan = verbBinyanById[log.verbId];
        if (binyan != null) {
          totalByBinyan[binyan] = (totalByBinyan[binyan] ?? 0) + 1;
          if (log.isCorrect) {
            correctByBinyan[binyan] = (correctByBinyan[binyan] ?? 0) + 1;
          }
        }
      }

      final binyanStats = totalByBinyan.entries
          .map(
            (MapEntry<Binyan, int> entry) => BinyanAccuracyStat(
              binyan: entry.key,
              totalAttempts: entry.value,
              correctAttempts: correctByBinyan[entry.key] ?? 0,
            ),
          )
          .toList(growable: false)
        ..sort(
          (BinyanAccuracyStat a, BinyanAccuracyStat b) =>
              a.binyan.index.compareTo(b.binyan.index),
        );

      var listeningExact = 0;
      var accuracySum = 0.0;
      for (final log in listeningLogs) {
        accuracySum += log.wordAccuracy;
        if (log.isExactMatch) {
          listeningExact += 1;
        }
      }
      final averageListeningAccuracy = listeningLogs.isEmpty
          ? 0.0
          : accuracySum / listeningLogs.length;

      final allTimestamps = <DateTime>[
        ...srsLogs.map((SrsReviewLogRow r) => r.reviewedAt),
        ...grammarLogs.map((GrammarPracticeLogRow g) => g.practicedAt),
        ...listeningLogs.map((ListeningAttemptLogRow l) => l.attemptedAt),
      ];

      final streak = StreakCalculator.calculateCurrentStreakDays(
        activityTimestamps: allTimestamps,
        nowUtc: asOf.toUtc(),
      );
      final todayCount = StreakCalculator.countActivitiesToday(
        activityTimestamps: allTimestamps,
        nowUtc: asOf.toUtc(),
      );

      final activityByDate = <String, int>{};
      for (final ts in allTimestamps) {
        final utc = ts.toUtc();
        final key =
            '${utc.year}-${utc.month.toString().padLeft(2, '0')}-${utc.day.toString().padLeft(2, '0')}';
        activityByDate[key] = (activityByDate[key] ?? 0) + 1;
      }

      return Success<LearningProgressSummary, Failure>(
        LearningProgressSummary(
          totalSrsCards: cards.length,
          dueSrsCards: dueCount,
          newCards: newCount,
          learningCards: learningCount,
          reviewCards: reviewCount,
          relearningCards: relearningCount,
          totalSrsReviews: srsLogs.length,
          currentStreakDays: streak,
          activeTodayCount: todayCount,
          grammarAttempts: grammarLogs.length,
          grammarCorrect: grammarCorrect,
          binyanStats: binyanStats,
          listeningAttempts: listeningLogs.length,
          listeningExactMatches: listeningExact,
          averageListeningAccuracy: averageListeningAccuracy,
          activityByDate: activityByDate,
        ),
      );
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Failed to aggregate learning progress summary',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
      return const Error<LearningProgressSummary, Failure>(
        CacheFailure('Не удалось собрать статистику прогресса из локальной БД'),
      );
    }
  }

  @override
  Future<Result<List<GlobalHebrewSearchResult>, Failure>> searchLibrary(
    String query,
  ) async {
    try {
      final trimmed = query.trim();
      final normalizedHeb = HebrewNormalizer.normalizeForComparison(trimmed);
      final compactLetters = HebrewNormalizer.extractHebrewLetters(trimmed);
      final lowerRu = trimmed.toLowerCase();

      final srsRows = await _database.getAllSrsCards();
      final verbRows = await _database.getGrammarVerbs();
      final dialogueRows = await _database.getAllDialogueNodes();
      final listeningRows = await _database.getListeningExercises();

      final hits = <GlobalHebrewSearchResult>[];

      bool matchesFields({
        required String normalizedTarget,
        required String russianTarget,
        Shoresh? root,
      }) {
        if (russianTarget.toLowerCase().contains(lowerRu)) {
          return true;
        }
        if (normalizedHeb.isNotEmpty &&
            normalizedTarget.contains(normalizedHeb)) {
          return true;
        }
        if (root != null) {
          if (normalizedHeb.isNotEmpty &&
              root.hyphenated.contains(normalizedHeb)) {
            return true;
          }
          if (compactLetters.isNotEmpty &&
              root.compact.contains(compactLetters)) {
            return true;
          }
        }
        return false;
      }

      for (final row in srsRows) {
        final hebrew = HebrewText.create(row.hebrewVocalized).getOrNull();
        if (hebrew == null) continue;
        final root = row.root != null && row.root!.trim().isNotEmpty
            ? Shoresh.create(row.root!).getOrNull()
            : null;
        if (!matchesFields(
          normalizedTarget: row.hebrewNormalized,
          russianTarget: row.russianTranslation,
          root: root,
        )) {
          continue;
        }
        hits.add(
          GlobalHebrewSearchResult(
            id: row.id,
            kind: SearchSourceKind.srs,
            hebrew: hebrew,
            russianMeaning: row.russianTranslation,
            root: root,
            binyan: Binyan.parseStrict(row.binyan).getOrNull() ?? Binyan.none,
            audioUrl: row.audioUrl,
            contextNote: row.exampleRussian,
          ),
        );
      }

      for (final row in verbRows) {
        final displayHebrew = HebrewText.create(
          row.infinitiveVocalized ?? row.lemmaVocalized,
        ).getOrNull();
        if (displayHebrew == null) continue;
        final root = Shoresh.create(row.root).getOrNull();
        final combinedNormalized =
            '${row.lemmaNormalized} ${displayHebrew.normalized}';
        if (!matchesFields(
          normalizedTarget: combinedNormalized,
          russianTarget: row.russianMeaning,
          root: root,
        )) {
          continue;
        }
        hits.add(
          GlobalHebrewSearchResult(
            id: row.id,
            kind: SearchSourceKind.grammar,
            hebrew: displayHebrew,
            russianMeaning: row.russianMeaning,
            root: root,
            binyan: Binyan.parseStrict(row.binyan).getOrNull() ?? Binyan.none,
            contextNote: row.grammarNotesRu,
          ),
        );
      }

      for (final row in dialogueRows) {
        final hebrew = HebrewText.create(row.lineHebrewVocalized).getOrNull();
        if (hebrew == null) continue;
        if (!matchesFields(
          normalizedTarget: row.lineHebrewNormalized,
          russianTarget: row.lineRussian,
        )) {
          continue;
        }
        hits.add(
          GlobalHebrewSearchResult(
            id: row.id,
            kind: SearchSourceKind.dialogue,
            hebrew: hebrew,
            russianMeaning: row.lineRussian,
            audioUrl: row.audioPath,
            contextNote: row.characterName,
          ),
        );
      }

      for (final row in listeningRows) {
        final hebrew = HebrewText.create(row.transcriptVocalized).getOrNull();
        if (hebrew == null) continue;
        if (!matchesFields(
          normalizedTarget: row.transcriptNormalized,
          russianTarget: row.russianTranslation,
        )) {
          continue;
        }
        hits.add(
          GlobalHebrewSearchResult(
            id: row.id,
            kind: SearchSourceKind.listening,
            hebrew: hebrew,
            russianMeaning: row.russianTranslation,
            audioUrl: row.audioUrl,
          ),
        );
      }

      return Success<List<GlobalHebrewSearchResult>, Failure>(
        List<GlobalHebrewSearchResult>.unmodifiable(hits),
      );
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Global Hebrew library search failed for query "$query"',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
      return const Error<List<GlobalHebrewSearchResult>, Failure>(
        CacheFailure('Не удалось выполнить поиск по локальной базе'),
      );
    }
  }
}
