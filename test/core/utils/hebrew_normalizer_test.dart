import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/core/error/failures.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/core/utils/hebrew_normalizer.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/hebrew_text.dart';

void main() {
  group('HebrewNormalizer', () {
    test('stripNikkud удаляет все огласовки и знаки кантилляции', () {
      const textWithNikkud = 'שָׁלוֹם עֲלֵיכֶם';

      final stripped = HebrewNormalizer.stripNikkud(textWithNikkud);

      expect(stripped, equals('שלום עליכם'));
    });

    test('нормализует составные presentation forms и NFD-последовательности', () {
      // U+FB2A (שׁ precomposed) + qamats vs decomposed ש + shin dot + qamats
      const precomposed = '\uFB2A\u05B8לוֹם';
      const decomposedNfd = 'ש\u05C1\u05B8לו\u05B9ם';
      const plainInput = 'שלום';

      expect(
        HebrewNormalizer.isMatchWithoutNikkud(plainInput, precomposed),
        isTrue,
      );
      expect(
        HebrewNormalizer.isMatchWithoutNikkud(plainInput, decomposedNfd),
        isTrue,
      );
      expect(
        HebrewNormalizer.toNfc('ש\u05B8\u05C1לוֹם'),
        equals(HebrewNormalizer.toNfc('ש\u05C1\u05B8לוֹם')),
      );
    });

    test('normalizeForComparison схлопывает пробелы и обрабатывает макаф и софит', () {
      const withMaqaf = 'בֵּית־קָפֶה   גָּדוֹל';

      final normalized = HebrewNormalizer.normalizeForComparison(withMaqaf);
      final normalizedSofit = HebrewNormalizer.normalizeForComparison(
        'מֶלֶךְ',
        normalizeFinalForms: true,
      );

      expect(normalized, equals('בית קפה גדול'));
      expect(normalizedSofit, equals('מלכ'));
    });
  });

  group('HebrewText & Shoresh Value Objects', () {
    test('HebrewText.create разделяет текст с огласовками и без', () {
      final result = HebrewText.create('  אֲנִי רוֹצֶה קָפֶה  ');

      expect(result, isA<Success<HebrewText, ValidationFailure>>());
      result.fold(
        (failure) => fail('Ожидался Success, получен Failure: ${failure.message}'),
        (value) {
          expect(value.vocalized, equals('אֲנִי רוֹצֶה קָפֶה'));
          expect(value.normalized, equals('אני רוצה קפה'));
          expect(value.matchesInput('אני רוצה קפה'), isTrue);
          expect(value.matchesInput('אֲנִי   רוֹצֶה קָפֶה'), isTrue);
        },
      );
    });

    test('HebrewText.create возвращает ValidationFailure для пустой строки или одних огласовок', () {
      final emptyResult = HebrewText.create('   ');
      final nikkudOnlyResult = HebrewText.create('\u05B8\u05B7');

      expect(emptyResult, isA<Error<HebrewText, ValidationFailure>>());
      expect(nikkudOnlyResult, isA<Error<HebrewText, ValidationFailure>>());
    });

    test('Shoresh.create принимает 3- и 4-буквенные корни', () {
      final threeLetters = Shoresh.create('ר-צ-ה');
      final fourLetters = Shoresh.create('פִּ-רְ-נֵ-ס');

      expect(threeLetters, isA<Success<Shoresh, ValidationFailure>>());
      expect(threeLetters.getOrNull()?.hyphenated, equals('ר-צ-ה'));
      expect(threeLetters.getOrNull()?.compact, equals('רצה'));

      expect(fourLetters, isA<Success<Shoresh, ValidationFailure>>());
      expect(fourLetters.getOrNull()?.hyphenated, equals('פ-ר-נ-ס'));
    });

    test('Shoresh.create отклоняет невалидные корни с ValidationFailure', () {
      final tooShort = Shoresh.create('ר-צ');
      final tooLong = Shoresh.create('א-ב-ג-ד-ה');
      final nonHebrew = Shoresh.create('k-t-v');

      expect(tooShort, isA<Error<Shoresh, ValidationFailure>>());
      expect(tooLong, isA<Error<Shoresh, ValidationFailure>>());
      expect(nonHebrew, isA<Error<Shoresh, ValidationFailure>>());
    });
  });
}
