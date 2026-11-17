import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/error/failures.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/listening/domain/repositories/listening_repository.dart';
import 'package:nexus_hebrew_app/features/listening/domain/usecases/record_listening_attempt.dart';

class _MockListeningRepository extends Mock implements ListeningRepository {}

void main() {
  late _MockListeningRepository repository;
  late RecordListeningAttemptUseCase useCase;
  final fixedTime = DateTime.utc(2026, 11, 11, 22, 0);

  setUp(() {
    repository = _MockListeningRepository();
    useCase = RecordListeningAttemptUseCase(repository);
  });

  group('RecordListeningAttemptUseCase', () {
    test('records valid dictation attempt with trimmed exerciseId', () async {
      when(
        () => repository.recordAttempt(
          exerciseId: 'listen_beg_1',
          wordAccuracy: 0.75,
          isExactMatch: false,
          attemptedAt: fixedTime,
        ),
      ).thenAnswer((_) async => const Success<void, Failure>(null));

      final result = await useCase(
        RecordListeningAttemptParams(
          exerciseId: ' listen_beg_1 ',
          wordAccuracy: 0.75,
          isExactMatch: false,
          attemptedAt: fixedTime,
        ),
      );

      expect(result.isSuccess, isTrue);
      verify(
        () => repository.recordAttempt(
          exerciseId: 'listen_beg_1',
          wordAccuracy: 0.75,
          isExactMatch: false,
          attemptedAt: fixedTime,
        ),
      ).called(1);
    });

    test('returns ValidationFailure on empty exerciseId or invalid accuracy',
        () async {
      final badIdRes = await useCase(
        RecordListeningAttemptParams(
          exerciseId: ' ',
          wordAccuracy: 1.0,
          isExactMatch: true,
          attemptedAt: fixedTime,
        ),
      );
      final badAccuracyRes = await useCase(
        RecordListeningAttemptParams(
          exerciseId: 'listen_beg_1',
          wordAccuracy: 1.2,
          isExactMatch: false,
          attemptedAt: fixedTime,
        ),
      );

      expect(badIdRes.failureOrNull(), isA<ValidationFailure>());
      expect(badAccuracyRes.failureOrNull(), isA<ValidationFailure>());
      verifyZeroInteractions(repository);
    });

    test('propagates CacheFailure from repository', () async {
      const failure = CacheFailure('SQLite insert failed');
      when(
        () => repository.recordAttempt(
          exerciseId: 'listen_beg_1',
          wordAccuracy: 1.0,
          isExactMatch: true,
          attemptedAt: fixedTime,
        ),
      ).thenAnswer((_) async => const Error<void, Failure>(failure));

      final result = await useCase(
        RecordListeningAttemptParams(
          exerciseId: 'listen_beg_1',
          wordAccuracy: 1.0,
          isExactMatch: true,
          attemptedAt: fixedTime,
        ),
      );

      expect(result.isError, isTrue);
      expect(result.failureOrNull(), failure);
    });
  });
}
