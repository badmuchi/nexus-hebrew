import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/features/shoresh/data/datasources/shoresh_seed_data.dart';
import 'package:nexus_hebrew_app/features/shoresh/presentation/bloc/shoresh_bloc.dart';
import 'package:nexus_hebrew_app/features/shoresh/presentation/bloc/shoresh_event.dart';
import 'package:nexus_hebrew_app/features/shoresh/presentation/bloc/shoresh_state.dart';
import 'package:nexus_hebrew_app/features/shoresh/presentation/screens/shoresh_detective_game_screen.dart';

class _MockShoreshBloc extends Mock implements ShoreshBloc {}

void main() {
  late _MockShoreshBloc bloc;
  const questions = ShoreshSeedData.detectiveQuizChallenges;

  setUp(() {
    bloc = _MockShoreshBloc();
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: ShoreshDetectiveGameScreen(bloc: bloc),
    );
  }

  group('ShoreshDetectiveGameScreen', () {
    testWidgets('triggers StartShoreshQuizEvent on init and displays question', (tester) async {
      when(() => bloc.state).thenReturn(
        ShoreshCatalogLoaded(
          allRoots: ShoreshSeedData.roots,
          filteredRoots: ShoreshSeedData.roots,
          categories: const ['Культура'],
          masteredRootIds: const {},
          activeQuiz: ShoreshQuizSessionState(questions: questions.take(2).toList()),
        ),
      );
      when(() => bloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      verify(() => bloc.add(const StartShoreshQuizEvent(questionCount: 8))).called(1);

      expect(find.text('Шореш-Детектив 🔍'), findsOneWidget);
      expect(find.text('Раскройте корень слова'), findsOneWidget);
      expect(find.text('מַחְשֵׁב'), findsOneWidget);
      expect(find.text('ח-ש-ב'), findsOneWidget);
    });

    testWidgets('displays celebration view when quiz is completed', (tester) async {
      when(() => bloc.state).thenReturn(
        ShoreshCatalogLoaded(
          allRoots: ShoreshSeedData.roots,
          filteredRoots: ShoreshSeedData.roots,
          categories: const ['Культура'],
          masteredRootIds: const {},
          activeQuiz: ShoreshQuizSessionState(
            questions: questions.take(2).toList(),
            score: 2,
            isCompleted: true,
          ),
        ),
      );
      when(() => bloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Шериф Морфологии!'), findsOneWidget);
      expect(find.text('Ваш результат: 2 из 2 правильных корней'), findsOneWidget);
      expect(find.text('Пройти новое расследование'), findsOneWidget);
      expect(find.text('Вернуться в каталог корней'), findsOneWidget);
    });
  });
}
