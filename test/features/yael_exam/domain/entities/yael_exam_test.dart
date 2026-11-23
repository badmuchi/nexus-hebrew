import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/yael_exam/data/datasources/yael_exam_seed_data.dart';
import 'package:nexus_hebrew_app/features/yael_exam/domain/entities/yael_exam_result.dart';
import 'package:nexus_hebrew_app/features/yael_exam/domain/entities/yael_question.dart';

void main() {
  group('YAEL Exam Entities & Seed Data', () {
    test('Seed data contains 12 diagnostic questions across 3 sections', () {
      const questions = YaelExamSeedData.examQuestions;
      expect(questions.length, 12);

      final rcQuestions =
          questions.where((q) => q.section == YaelSection.readingComprehension).toList();
      final scQuestions =
          questions.where((q) => q.section == YaelSection.sentenceCompletion).toList();
      final rsQuestions =
          questions.where((q) => q.section == YaelSection.restatement).toList();

      expect(rcQuestions.length, 4);
      expect(scQuestions.length, 4);
      expect(rsQuestions.length, 4);

      for (final q in questions) {
        expect(q.promptRussian, isNotEmpty);
        expect(q.promptHebrewWithNikkud, isNotEmpty);
        expect(q.options.length, 4);
        expect(q.correctOptionIndex, inInclusiveRange(0, 3));
        expect(q.explanationRu, isNotEmpty);
        expect(q.keyGrammarRuleRu, isNotEmpty);
      }
    });

    test('Score evaluation calculates correct scaled score and band', () {
      const questions = YaelExamSeedData.examQuestions;

      // Perfect score: 12/12 -> 150 points -> ptorAcademic
      final perfectAnswers = {
        for (final q in questions) q.id: q.correctOptionIndex,
      };
      final perfectResult = YaelExamResult.evaluate(
        questions: questions,
        userAnswers: perfectAnswers,
      );
      expect(perfectResult.correctCount, 12);
      expect(perfectResult.scaledScore, 150);
      expect(perfectResult.band, YaelProficiencyBand.ptorAcademic);
      expect(perfectResult.accuracyPercent, 100.0);

      // Half score: 6/12 -> 50% -> 100 points -> ramaAlef
      final halfAnswers = <String, int>{};
      for (int i = 0; i < questions.length; i++) {
        final q = questions[i];
        halfAnswers[q.id] = i < 6 ? q.correctOptionIndex : (q.correctOptionIndex + 1) % 4;
      }
      final halfResult = YaelExamResult.evaluate(
        questions: questions,
        userAnswers: halfAnswers,
      );
      expect(halfResult.correctCount, 6);
      expect(halfResult.scaledScore, 100);
      expect(halfResult.band, YaelProficiencyBand.ramaAlef);

      // Zero score: 0/12 -> 50 points -> preUlpan
      final zeroAnswers = {
        for (final q in questions) q.id: (q.correctOptionIndex + 1) % 4,
      };
      final zeroResult = YaelExamResult.evaluate(
        questions: questions,
        userAnswers: zeroAnswers,
      );
      expect(zeroResult.correctCount, 0);
      expect(zeroResult.scaledScore, 50);
      expect(zeroResult.band, YaelProficiencyBand.preUlpan);
    });
  });
}
