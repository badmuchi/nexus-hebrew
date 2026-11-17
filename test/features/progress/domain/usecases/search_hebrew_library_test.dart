import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/error/failures.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/binyan.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/hebrew_text.dart';
import 'package:nexus_hebrew_app/features/progress/domain/entities/learning_progress_summary.dart';
import 'package:nexus_hebrew_app/features/progress/domain/repositories/progress_repository.dart';
import 'package:nexus_hebrew_app/features/progress/domain/usecases/search_hebrew_library.dart';

class _MockProgressRepository extends Mock implements ProgressRepository {}

void main() {
  late _MockProgressRepository repository;
  late SearchHebrewLibraryUseCase useCase;

  const sampleHit = GlobalHebrewSearchResult(
    id: 'verb_paal_katav',
    kind: SearchSourceKind.grammar,
    hebrew: HebrewText.fixture(vocalized: 'לִכְתֹּב', normalized: 'לכתוב'),
    russianMeaning: 'писать',
    root: Shoresh.fixture(<String>['כ', 'ת', 'ב']),
    binyan: Binyan.paal,
  );

  setUp(() {
    repository = _MockProgressRepository();
    useCase = SearchHebrewLibraryUseCase(repository);
  });

  group('SearchHebrewLibraryUseCase', () {
    test('trims query and returns unified hits from repository', () async {
      when(() => repository.searchAcrossLibrary('כ-ת-ב')).thenAnswer(
        (_) async => const Success<List<GlobalHebrewSearchResult>, Failure>(
          <GlobalHebrewSearchResult>[sampleHit],
        ),
      );

      final result = await useCase(
        const SearchHebrewLibraryParams(query: '  כ-ת-ב  '),
      );

      expect(result.isSuccess, isTrue);
      expect(result.getOrNull(), <GlobalHebrewSearchResult>[sampleHit]);
      verify(() => repository.searchAcrossLibrary('כ-ת-ב')).called(1);
    });

    test('returns ValidationFailure for blank search query', () async {
      final result = await useCase(
        const SearchHebrewLibraryParams(query: '   '),
      );

      expect(result.isError, isTrue);
      expect(result.failureOrNull(), isA<ValidationFailure>());
      verifyZeroInteractions(repository);
    });

    test('propagates CacheFailure when cross-table search fails', () async {
      const failure = CacheFailure('SQLite error');
      when(() => repository.searchAcrossLibrary('קפה')).thenAnswer(
        (_) async =>
            const Error<List<GlobalHebrewSearchResult>, Failure>(failure),
      );

      final result = await useCase(
        const SearchHebrewLibraryParams(query: 'קפה'),
      );

      expect(result.isError, isTrue);
      expect(result.failureOrNull(), failure);
    });
  });
}
