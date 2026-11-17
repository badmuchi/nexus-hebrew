import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/error/failures.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/hebrew_text.dart';
import 'package:nexus_hebrew_app/features/listening/domain/entities/listening_exercise.dart';
import 'package:nexus_hebrew_app/features/listening/domain/repositories/listening_repository.dart';
import 'package:nexus_hebrew_app/features/listening/domain/usecases/import_tatoeba_listening.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/srs_card.dart';

class _MockListeningRepository extends Mock implements ListeningRepository {}

void main() {
  late _MockListeningRepository repository;
  late ImportTatoebaListeningUseCase useCase;

  final importedExercise = ListeningExercise(
    id: 'listen_tatoeba_99',
    transcript: const HebrewText.fixture(
      vocalized: 'תּוֹדָה רַבָּה עַל הָעֶזְרָה',
      normalized: 'תודה רבה על העזרה',
    ),
    russianTranslation: 'Большое спасибо за помощь',
    audioUrl: 'https://audio.tatoeba.org/sentences/heb/99.mp3',
    difficulty: ListeningDifficulty.beginner,
    focusWords: const <String>['תּוֹדָה', 'רַבָּה'],
    attribution: const ContentAttribution(
      sourceName: 'Tatoeba',
      licenseName: 'CC0 1.0',
    ),
  );

  setUp(() {
    repository = _MockListeningRepository();
    useCase = ImportTatoebaListeningUseCase(repository);
  });

  group('ImportTatoebaListeningUseCase', () {
    test('trims query and forwards valid import request to repository',
        () async {
      when(
        () => repository.importFromTatoeba(query: 'עזרה', limit: 6),
      ).thenAnswer(
        (_) async => Success<List<ListeningExercise>, Failure>(
          <ListeningExercise>[importedExercise],
        ),
      );

      final result = await useCase(
        const ImportTatoebaListeningParams(query: '  עזרה  ', limit: 6),
      );

      expect(result.isSuccess, isTrue);
      expect(result.getOrNull(), <ListeningExercise>[importedExercise]);
      verify(
        () => repository.importFromTatoeba(query: 'עזרה', limit: 6),
      ).called(1);
    });

    test('returns ValidationFailure when query is empty', () async {
      final result = await useCase(
        const ImportTatoebaListeningParams(query: '   '),
      );

      expect(result.isError, isTrue);
      expect(result.failureOrNull(), isA<ValidationFailure>());
      verifyZeroInteractions(repository);
    });

    test('returns ValidationFailure when limit is out of bounds', () async {
      final zeroRes = await useCase(
        const ImportTatoebaListeningParams(query: 'שלום', limit: 0),
      );
      final tooHighRes = await useCase(
        const ImportTatoebaListeningParams(query: 'שלום', limit: 50),
      );

      expect(zeroRes.failureOrNull(), isA<ValidationFailure>());
      expect(tooHighRes.failureOrNull(), isA<ValidationFailure>());
      verifyZeroInteractions(repository);
    });

    test('propagates NetworkFailure when Tatoeba endpoint is unreachable',
        () async {
      const failure = NetworkFailure('No internet connection');
      when(
        () => repository.importFromTatoeba(query: 'קפה', limit: 8),
      ).thenAnswer(
        (_) async => const Error<List<ListeningExercise>, Failure>(failure),
      );

      final result = await useCase(
        const ImportTatoebaListeningParams(query: 'קפה'),
      );

      expect(result.isError, isTrue);
      expect(result.failureOrNull(), failure);
    });
  });
}
