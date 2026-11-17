import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/alphabet/data/datasources/hebrew_numbers_seed_data.dart';
import 'package:nexus_hebrew_app/features/alphabet/domain/entities/hebrew_number.dart';

void main() {
  group('Hebrew Numbers & Time Domain Tests', () {
    test('calculateTimePhrase formats on the hour', () {
      final t1 = HebrewNumbersSeedData.calculateTimePhrase(1, 0);
      expect(t1.hebrewPhrase, contains('אַחַת'));
      expect(t1.russianTranslation, contains('1:00'));

      final t12 = HebrewNumbersSeedData.calculateTimePhrase(12, 0);
      expect(t12.hebrewPhrase, contains('שְׁתֵּים עֶשְׂרֵה'));
    });

    test('calculateTimePhrase formats quarter past (:15)', () {
      final t215 = HebrewNumbersSeedData.calculateTimePhrase(2, 15);
      expect(t215.hebrewPhrase, equals('שְׁתַּיִם וָרֶבַע'));
      expect(t215.transliteration, contains('Shtayim va-reva'));
    });

    test('calculateTimePhrase formats half past (:30)', () {
      final t330 = HebrewNumbersSeedData.calculateTimePhrase(3, 30);
      expect(t330.hebrewPhrase, equals('שָׁלוֹשׁ וָחֵצִי'));
      expect(t330.transliteration, contains('Shalosh va-chetzi'));
    });

    test('calculateTimePhrase formats quarter to (:45)', () {
      final t345 = HebrewNumbersSeedData.calculateTimePhrase(3, 45);
      expect(t345.hebrewPhrase, equals('רֶבַע לְאַרְבַּע'));
    });

    test('NumberQuizQuestion verifies correct choice', () {
      const q = NumberQuizQuestion(
        id: 'test_q',
        questionPrompt: 'Prompt',
        correctAnswer: 'A',
        options: ['A', 'B'],
        explanation: 'Exp',
        audioPrompt: 'A',
      );
      expect(q.isCorrect('A'), isTrue);
      expect(q.isCorrect('B'), isFalse);
    });

    test('cardinalNumbers contains 1 to 10 with gender paradox values', () {
      final numbers = HebrewNumbersSeedData.cardinalNumbers;
      expect(numbers.length, equals(10));

      final three = numbers.firstWhere((n) => n.value == 3);
      expect(three.masculine, equals('שְׁלוֹשָׁה')); // -a ending for masculine!
      expect(three.feminine, equals('שָׁלוֹשׁ')); // no -a for feminine!
    });
  });
}
