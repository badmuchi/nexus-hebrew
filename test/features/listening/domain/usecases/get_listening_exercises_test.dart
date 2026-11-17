import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/error/failures.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/hebrew_text.dart';
import 'package:nexus_hebrew_app/features/listening/domain/entities/listening_exercise.dart';
import 'package:nexus_hebrew_app/features/listening/domain/repositories/listening_repository.dart';
import 'package:nexus_hebrew_app/features/listening/domain/usecases/get_listening_exercises.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/srs_card.dart';

class _MockListeningRepository extends Mock implements ListeningRepository {}

void main() {
  late _MockListeningRepository repository;
  late GetListeningExercisesUseCase useCase;

  final sampleExercise = ListeningExercise(
    id: 'listen_int_1',
    transcript: const HebrewText.fixture(
      vocalized: 'אֶפְשָׁר לְדַבֵּר קְצָת יוֹתֵר לְאַט',
      normalized: 'אפשר לדבר קצת יותר לאט',
    ),
    russianTranslation: 'Можно говорить чуть помедленнее?',
    difficulty: ListeningDifficulty.intermediate,
    focusWords: const <String>['לְדַבֵּר', 'לְאַט'],
    attribution: const ContentAttribution(
      sourceName: 'Nexus Curated Ulpan',
      licenseName: 'CC0 1.0',
    ),
  );

  setUp(() {
    repository = _MockListeningRepository();
    useCase = GetListeningExercisesUseCase(repository);
  });

  group('GetListeningExercisesUseCase', () {
    test('forwards difficulty filter to repository and returns exercises',
        () async {
      when(
        () => repository.getExercises(
          difficulty: ListeningDifficulty.intermediate,
        ),
      ).thenAnswer(
        (_) async => Success<List<ListeningExercise>, Failure>(
          <ListeningExercise>[sampleExercise],
        ),
      );

      final result = await useCase(
        const GetListeningExercisesParams(
          difficulty: ListeningDifficulty.intermediate,
        ),
      );

      expect(result.isSuccess, isTrue);
      expect(result.getOrNull(), <ListeningExercise>[sampleExercise]);
      verify(
        () => repository.getExercises(
          difficulty: ListeningDifficulty.intermediate,
        ),
      ).called(1);
    });

    test('propagates CacheFailure when repository fails', () async {
      const failure = CacheFailure('Failed to read listening table');
      when(() => repository.getExercises(difficulty: null)).thenAnswer(
        (_) async => const Error<List<ListeningExercise>, Failure>(failure),
      );

      final result = await useCase(const GetListeningExercisesParams());

      expect(result.isError, isTrue);
      expect(result.failureOrNull(), failure);
    });
  });
}
