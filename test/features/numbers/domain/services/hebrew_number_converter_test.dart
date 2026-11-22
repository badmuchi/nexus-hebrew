import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/numbers/domain/entities/hebrew_number.dart';
import 'package:nexus_hebrew_app/features/numbers/domain/services/hebrew_number_converter.dart';

void main() {
  group('HebrewNumberConverter', () {
    test('конвертирует базовые числа 1-10 с учетом рода (перевертыш)', () {
      // 3
      expect(
        HebrewNumberConverter.numberToHebrew(3, gender: HebrewNumberGender.masculine),
        equals('שְׁלוֹשָׁה'),
      );
      expect(
        HebrewNumberConverter.numberToHebrew(3, gender: HebrewNumberGender.feminine),
        equals('שָׁלוֹשׁ'),
      );

      // 5
      expect(
        HebrewNumberConverter.numberToHebrew(5, gender: HebrewNumberGender.masculine),
        equals('חֲמִשָּׁה'),
      );
      expect(
        HebrewNumberConverter.numberToHebrew(5, gender: HebrewNumberGender.feminine),
        equals('חָמֵשׁ'),
      );

      // 10
      expect(
        HebrewNumberConverter.numberToHebrew(10, gender: HebrewNumberGender.masculine),
        equals('עֲשָׂרָה'),
      );
      expect(
        HebrewNumberConverter.numberToHebrew(10, gender: HebrewNumberGender.feminine),
        equals('עֶשֶׂר'),
      );
    });

    test('конвертирует составные десятки (21-99)', () {
      expect(
        HebrewNumberConverter.numberToHebrew(21, gender: HebrewNumberGender.masculine),
        equals('עֶשְׂרִים וְאֶחָד'),
      );
      expect(
        HebrewNumberConverter.numberToHebrew(21, gender: HebrewNumberGender.feminine),
        equals('עֶשְׂרִים וְאַחַת'),
      );
      expect(
        HebrewNumberConverter.numberToHebrew(50, gender: HebrewNumberGender.masculine),
        equals('חֲמִשִּׁים'),
      );
    });

    test('корректно склоняет шекели по грамматическим правилам Израиля', () {
      expect(HebrewNumberConverter.formatShekels(1), equals('שֶׁקֶל אֶחָד'));
      expect(HebrewNumberConverter.formatShekels(2), equals('שְׁנֵי שְׁקָלִים'));
      expect(HebrewNumberConverter.formatShekels(3), equals('שְׁלוֹשָׁה שְׁקָלִים'));
      expect(HebrewNumberConverter.formatShekels(5), equals('חֲמִשָּׁה שְׁקָלִים'));
      expect(HebrewNumberConverter.formatShekels(10), equals('עֲשָׂרָה שְׁקָלִים'));
      expect(HebrewNumberConverter.formatShekels(20), equals('עֶשְׂרִים שֶׁקֶל'));
      expect(HebrewNumberConverter.formatShekels(100), equals('מֵאָה שֶׁקֶל'));
    });

    test('корректно форматирует разговорное время на часах', () {
      expect(HebrewNumberConverter.formatTime(3, 0), equals('הַשָּׁעָה שָׁלוֹשׁ'));
      expect(HebrewNumberConverter.formatTime(3, 15), equals('שָׁלוֹשׁ וָרֶבַע'));
      expect(HebrewNumberConverter.formatTime(3, 30), equals('שָׁלוֹשׁ וָחֵצִי'));
      expect(HebrewNumberConverter.formatTime(3, 45), equals('רֶבַע לְאַרְבַּע'));
      expect(HebrewNumberConverter.formatTime(14, 30), equals('שְׁתַּיִם וָחֵצִי'));
    });
  });
}
