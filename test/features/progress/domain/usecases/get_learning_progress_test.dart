import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/error/failures.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/binyan.dart';
import 'package:nexus_hebrew_app/features/progress/domain/entities/learning_progress_summary.dart';
import 'package:nexus_hebrew_app/features/progress/domain/repositories/progress_repository.dart';
import 'package:nexus_hebrew_app/features/progress/domain/usecases/get_learning_progress.dart';

class _MockProgressRepository extends Mock implements ProgressRepository {}

void main() {
  late _MockProgressRepository repository;
  late GetLearningProgressUseCase useCase;
  final fixedNow = DateTime.utc(2026, 11, 12, 10, 0);

  final sampleSummary = LearningProgressSummary(
    totalSrsCards: 20,
    dueSrsCards: 5,
    newCards: 10,
    learningCards: 4,
    reviewCards: 5,
    relearningCards: 1,
    totalSrsReviews: 42,
    currentStreakDays: 4,
    activeTodayCount: 6,
    grammarAttempts: 10,
    grammarCorrect: 8,
    binyanStats: const <BinyanAccuracyStat>[
      BinyanAccuracyStat(
        binyan: Binyan.paal,
        totalAttempts: 10,
        correctAttempts: 8,
      ),
    ],
    listeningAttempts: 5,
    listeningExactMatches: 3,
    averageListeningAccuracy: 0.88,
  );

  setUp(() {
    repository = _MockProgressRepository();
    useCase = GetLearningProgressUseCase(repository);
  });

  group('GetLearningProgressUseCase', () {
    test('returns LearningProgressSummary from repository', () async {
      when(() => repository.getProgressSummary(asOf: fixedNow)).thenAnswer(
        (_) async => Success<LearningProgressSummary, Failure>(sampleSummary),
      );

      final result = await useCase(GetLearningProgressParams(asOf: fixedNow));

      expect(result.isSuccess, isTrue);
      expect(result.getOrNull(), sampleSummary);
      expect(sampleSummary.grammarAccuracy, closeTo(0.8, 0.0001));
    });

    test('propagates CacheFailure when summary query fails', () async {
      const failure = CacheFailure('DB read failed');
      when(() => repository.getProgressSummary(asOf: fixedNow)).thenAnswer(
        (_) async => const Error<LearningProgressSummary, Failure>(failure),
      );

      final result = await useCase(GetLearningProgressParams(asOf: fixedNow));

      expect(result.isError, isTrue);
      expect(result.failureOrNull(), failure);
    });
  });

  group('StreakCalculator', () {
    test('counts consecutive UTC days ending today', () {
      final stamps = <DateTime>[
        DateTime.utc(2026, 11, 10, 9, 0),
        DateTime.utc(2026, 11, 11, 14, 0),
        DateTime.utc(2026, 11, 11, 21, 0),
        DateTime.utc(2026, 11, 12, 8, 15),
      ];

      expect(
        StreakCalculator.calculateCurrentStreakDays(
          activityTimestamps: stamps,
          nowUtc: fixedNow,
        ),
        3,
      );
      expect(
        StreakCalculator.countActivitiesToday(
          activityTimestamps: stamps,
          nowUtc: fixedNow,
        ),
        1,
      );
    });

    test('preserves streak when last activity was yesterday', () {
      final stamps = <DateTime>[
        DateTime.utc(2026, 11, 10, 12, 0),
        DateTime.utc(2026, 11, 11, 18, 0),
      ];

      expect(
        StreakCalculator.calculateCurrentStreakDays(
          activityTimestamps: stamps,
          nowUtc: fixedNow,
        ),
        2,
      );
      expect(
        StreakCalculator.countActivitiesToday(
          activityTimestamps: stamps,
          nowUtc: fixedNow,
        ),
        0,
      );
    });

    test('resets streak to 0 when gap exceeds 1 day or timestamps are empty',
        () {
      expect(
        StreakCalculator.calculateCurrentStreakDays(
          activityTimestamps: <DateTime>[DateTime.utc(2026, 11, 9, 12, 0)],
          nowUtc: fixedNow,
        ),
        0,
      );
      expect(
        StreakCalculator.calculateCurrentStreakDays(
          activityTimestamps: const <DateTime>[],
          nowUtc: fixedNow,
        ),
        0,
      );
    });
  });
}
