import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/shoresh/data/datasources/shoresh_seed_data.dart';
import 'package:nexus_hebrew_app/features/shoresh/domain/usecases/get_mastered_shoresh_roots_use_case.dart';
import 'package:nexus_hebrew_app/features/shoresh/domain/usecases/get_shoresh_family_use_case.dart';
import 'package:nexus_hebrew_app/features/shoresh/domain/usecases/get_shoresh_quiz_use_case.dart';
import 'package:nexus_hebrew_app/features/shoresh/domain/usecases/get_shoresh_roots_use_case.dart';
import 'package:nexus_hebrew_app/features/shoresh/domain/usecases/save_shoresh_mastery_use_case.dart';
import 'package:nexus_hebrew_app/features/shoresh/presentation/bloc/shoresh_bloc.dart';
import 'package:nexus_hebrew_app/features/shoresh/presentation/bloc/shoresh_event.dart';
import 'package:nexus_hebrew_app/features/shoresh/presentation/bloc/shoresh_state.dart';

class _MockGetShoreshRootsUseCase extends Mock implements GetShoreshRootsUseCase {}
class _MockGetShoreshFamilyUseCase extends Mock implements GetShoreshFamilyUseCase {}
class _MockGetMasteredShoreshRootsUseCase extends Mock implements GetMasteredShoreshRootsUseCase {}
class _MockGetShoreshQuizUseCase extends Mock implements GetShoreshQuizUseCase {}
class _MockSaveShoreshMasteryUseCase extends Mock implements SaveShoreshMasteryUseCase {}

void main() {
  late _MockGetShoreshRootsUseCase getShoreshRootsUseCase;
  late _MockGetShoreshFamilyUseCase getShoreshFamilyUseCase;
  late _MockGetMasteredShoreshRootsUseCase getMasteredShoreshRootsUseCase;
  late _MockGetShoreshQuizUseCase getShoreshQuizUseCase;
  late _MockSaveShoreshMasteryUseCase saveShoreshMasteryUseCase;

  const sampleRoots = ShoreshSeedData.roots;
  const sampleChallenges = ShoreshSeedData.detectiveQuizChallenges;

  setUpAll(() {
    registerFallbackValue(
      const SaveShoreshMasteryParams(
        rootId: 'fallback',
        isMastered: true,
        quizCorrectIncrement: 1,
      ),
    );
  });

  setUp(() {
    getShoreshRootsUseCase = _MockGetShoreshRootsUseCase();
    getShoreshFamilyUseCase = _MockGetShoreshFamilyUseCase();
    getMasteredShoreshRootsUseCase = _MockGetMasteredShoreshRootsUseCase();
    getShoreshQuizUseCase = _MockGetShoreshQuizUseCase();
    saveShoreshMasteryUseCase = _MockSaveShoreshMasteryUseCase();
  });

  ShoreshBloc buildBloc() {
    return ShoreshBloc(
      getShoreshRootsUseCase: getShoreshRootsUseCase,
      getShoreshFamilyUseCase: getShoreshFamilyUseCase,
      getMasteredShoreshRootsUseCase: getMasteredShoreshRootsUseCase,
      getShoreshQuizUseCase: getShoreshQuizUseCase,
      saveShoreshMasteryUseCase: saveShoreshMasteryUseCase,
    );
  }

  group('ShoreshBloc', () {
    test('initial state is ShoreshInitial', () {
      final bloc = buildBloc();
      expect(bloc.state, equals(const ShoreshInitial()));
      bloc.close();
    });

    blocTest<ShoreshBloc, ShoreshState>(
      'emits [ShoreshLoading, ShoreshCatalogLoaded] on LoadShoreshCatalogEvent',
      setUp: () {
        when(() => getShoreshRootsUseCase(category: any(named: 'category'), query: any(named: 'query')))
            .thenReturn(sampleRoots);
        when(() => getMasteredShoreshRootsUseCase())
            .thenAnswer((_) async => const Success({'root_ktv': true}));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadShoreshCatalogEvent()),
      expect: () => [
        const ShoreshLoading(),
        isA<ShoreshCatalogLoaded>()
            .having((s) => s.allRoots.length, 'allRoots length', sampleRoots.length)
            .having((s) => s.masteredRootIds['root_ktv'], 'mastered root_ktv', isTrue),
      ],
    );

    blocTest<ShoreshBloc, ShoreshState>(
      'toggles nikkud visibility on ToggleShoreshNikkudEvent',
      setUp: () {
        when(() => getShoreshRootsUseCase(category: any(named: 'category'), query: any(named: 'query')))
            .thenReturn(sampleRoots);
        when(() => getMasteredShoreshRootsUseCase())
            .thenAnswer((_) async => const Success({}));
      },
      build: buildBloc,
      seed: () => const ShoreshCatalogLoaded(
        allRoots: sampleRoots,
        filteredRoots: sampleRoots,
        categories: ['Образование'],
        masteredRootIds: {},
        showNikkud: true,
      ),
      act: (bloc) => bloc.add(const ToggleShoreshNikkudEvent()),
      expect: () => [
        isA<ShoreshCatalogLoaded>().having((s) => s.showNikkud, 'showNikkud', isFalse),
      ],
    );

    blocTest<ShoreshBloc, ShoreshState>(
      'selects root family on SelectShoreshRootEvent',
      setUp: () {
        when(() => getShoreshFamilyUseCase('root_ktv'))
            .thenReturn(sampleRoots.first);
      },
      build: buildBloc,
      seed: () => const ShoreshCatalogLoaded(
        allRoots: sampleRoots,
        filteredRoots: sampleRoots,
        categories: ['Культура'],
        masteredRootIds: {},
      ),
      act: (bloc) => bloc.add(const SelectShoreshRootEvent('root_ktv')),
      expect: () => [
        isA<ShoreshCatalogLoaded>()
            .having((s) => s.selectedRoot?.id, 'selectedRoot id', 'root_ktv'),
      ],
    );

    blocTest<ShoreshBloc, ShoreshState>(
      'starts quiz and responds to user answer correctly',
      setUp: () {
        when(() => getShoreshQuizUseCase(count: any(named: 'count')))
            .thenReturn(sampleChallenges.take(2).toList());
      },
      build: buildBloc,
      seed: () => const ShoreshCatalogLoaded(
        allRoots: sampleRoots,
        filteredRoots: sampleRoots,
        categories: ['Культура'],
        masteredRootIds: {},
      ),
      act: (bloc) {
        bloc.add(const StartShoreshQuizEvent(questionCount: 2));
        bloc.add(const AnswerShoreshQuizEvent(0)); // quiz_1 correctIndex is 0
      },
      expect: () => [
        isA<ShoreshCatalogLoaded>()
            .having((s) => s.activeQuiz?.questions.length, 'questions length', 2),
        isA<ShoreshCatalogLoaded>()
            .having((s) => s.activeQuiz?.score, 'score', 1)
            .having((s) => s.activeQuiz?.isCorrect, 'isCorrect', isTrue),
      ],
    );
  });
}
