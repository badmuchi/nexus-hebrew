import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/assessment/domain/entities/level_quiz_question.dart';
import 'package:nexus_hebrew_app/features/assessment/domain/entities/level_quiz_result.dart';

void main() {
  group('LevelQuizQuestion', () {
    const question = LevelQuizQuestion(
      id: 'q1',
      promptRussian: 'Выберите правильный ответ',
      promptHebrew: 'שָׁלוֹם',
      options: ['Да', 'Нет', 'Привет', 'Пока'],
      correctOptionIndex: 2,
      explanationRu: 'Шалом означает мир или привет.',
      level: CefrLevel.a1,
      skillFocus: SkillFocus.vocabulary,
    );

    test('isCorrect accurately compares selected index', () {
      expect(question.isCorrect(2), isTrue);
      expect(question.isCorrect(0), isFalse);
      expect(question.correctOption, 'Привет');
    });
  });

  group('LevelQuizResult.evaluate', () {
    final questions = [
      const LevelQuizQuestion(
        id: 'q1',
        promptRussian: 'Q1',
        options: ['A', 'B'],
        correctOptionIndex: 0,
        explanationRu: 'Exp 1',
        level: CefrLevel.a1,
        skillFocus: SkillFocus.vocabulary,
      ),
      const LevelQuizQuestion(
        id: 'q2',
        promptRussian: 'Q2',
        options: ['A', 'B'],
        correctOptionIndex: 1,
        explanationRu: 'Exp 2',
        level: CefrLevel.a2,
        skillFocus: SkillFocus.grammar,
      ),
      const LevelQuizQuestion(
        id: 'q3',
        promptRussian: 'Q3',
        options: ['A', 'B'],
        correctOptionIndex: 0,
        explanationRu: 'Exp 3',
        level: CefrLevel.b1,
        skillFocus: SkillFocus.syntax,
      ),
      const LevelQuizQuestion(
        id: 'q4',
        promptRussian: 'Q4',
        options: ['A', 'B'],
        correctOptionIndex: 1,
        explanationRu: 'Exp 4',
        level: CefrLevel.b1,
        skillFocus: SkillFocus.listening,
      ),
    ];

    test('evaluates perfect score as B1.2 level', () {
      final userAnswers = {'q1': 0, 'q2': 1, 'q3': 0, 'q4': 1};
      final result = LevelQuizResult.evaluate(
        questions: questions,
        userAnswers: userAnswers,
      );

      expect(result.correctAnswers, 4);
      expect(result.totalQuestions, 4);
      expect(result.scorePercentage, 1.0);
      expect(result.determinedLevel, 'B1.2');
      expect(result.mistakes, isEmpty);
      expect(result.skillScores[SkillFocus.vocabulary], 1.0);
      expect(result.skillScores[SkillFocus.grammar], 1.0);
    });

    test('evaluates 50% score as A2.1 with mistakes tracking', () {
      final userAnswers = {'q1': 0, 'q2': 1, 'q3': 1, 'q4': 0}; // q3 and q4 wrong
      final result = LevelQuizResult.evaluate(
        questions: questions,
        userAnswers: userAnswers,
      );

      expect(result.correctAnswers, 2);
      expect(result.scorePercentage, 0.5);
      expect(result.determinedLevel, 'A2.1');
      expect(result.mistakes.length, 2);
      expect(result.mistakes.map((m) => m.id), containsAll(['q3', 'q4']));
      expect(result.recommendations, isNotEmpty);
    });

    test('evaluates 0% score as A1.1 level', () {
      final userAnswers = {'q1': 1, 'q2': 0, 'q3': 1, 'q4': 0};
      final result = LevelQuizResult.evaluate(
        questions: questions,
        userAnswers: userAnswers,
      );

      expect(result.correctAnswers, 0);
      expect(result.determinedLevel, 'A1.1');
      expect(result.mistakes.length, 4);
    });
  });
}
