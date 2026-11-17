import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/alphabet/data/datasources/hebrew_alphabet_seed_data.dart';
import 'package:nexus_hebrew_app/features/alphabet/domain/entities/nikkud_mark.dart';

void main() {
  group('HebrewAlphabetSeedData', () {
    test('contains all 22 fundamental letters of the Hebrew alphabet', () {
      expect(HebrewAlphabetSeedData.letters.length, 22);

      final alef = HebrewAlphabetSeedData.letters.first;
      expect(alef.printed, 'א');
      expect(alef.nameRussian, 'Алеф');
      expect(alef.gematria, 1);
      expect(alef.isGuttural, isTrue);

      final tav = HebrewAlphabetSeedData.letters.last;
      expect(tav.printed, 'ת');
      expect(tav.nameRussian, 'Тав');
      expect(tav.gematria, 400);
    });

    test('correctly defines the 5 final forms (sofit letters: ך, ם, ן, ף, ץ)', () {
      final sofitLetters = HebrewAlphabetSeedData.letters
          .where((l) => l.hasFinalForm)
          .toList();

      expect(sofitLetters.length, 5);
      final finalForms = sofitLetters.map((l) => l.finalFormPrinted).toSet();
      expect(finalForms, containsAll(['ך', 'ם', 'ן', 'ף', 'ץ']));
    });

    test('correctly flags BeGeD KeFeT letters (ב, כ, פ) with dagesh rules', () {
      final begedKefet = HebrewAlphabetSeedData.letters
          .where((l) => l.isBegedKefet)
          .toList();

      expect(begedKefet.length, 3);
      final printedLetters = begedKefet.map((l) => l.printed).toSet();
      expect(printedLetters, containsAll(['ב', 'כ', 'פ']));

      for (final letter in begedKefet) {
        expect(letter.dageshExplanation, isNotNull);
        expect(letter.dageshExplanation!.isNotEmpty, isTrue);
      }
    });

    test('correctly calculates Gematria sums and breakdowns', () {
      // חַי = 18 (ח=8 + י=10)
      expect(HebrewAlphabetSeedData.calculateGematria('חי'), 18);

      // אַהֲבָה = 13 (א=1 + ה=5 + ב=2 + ה=5)
      expect(HebrewAlphabetSeedData.calculateGematria('אהבה'), 13);

      // שָׁלוֹם = 376 (ש=300 + ל=30 + ו=6 + ם=40)
      expect(HebrewAlphabetSeedData.calculateGematria('שלום'), 376);

      final breakdown = HebrewAlphabetSeedData.getGematriaBreakdown('שלום');
      expect(breakdown.length, 4);
      expect(breakdown[0].key, 'ש');
      expect(breakdown[0].value, 300);
      expect(breakdown[1].key, 'ל');
      expect(breakdown[1].value, 30);
      expect(breakdown[2].key, 'ו');
      expect(breakdown[2].value, 6);
      expect(breakdown[3].key, 'ם');
      expect(breakdown[3].value, 40);
    });

    test('contains all 14 standard Nikkud marks grouped by vowel sound', () {
      expect(HebrewAlphabetSeedData.nikkudMarks.length, 14);

      final kamatz = HebrewAlphabetSeedData.nikkudMarks
          .firstWhere((m) => m.id == 'kamatz');
      expect(kamatz.nameRussian, 'Камац');
      expect(kamatz.group, NikkudVowelGroup.a);
      expect(kamatz.exampleWithLetter, 'בָּ');

      final cholam = HebrewAlphabetSeedData.nikkudMarks
          .firstWhere((m) => m.id == 'cholam_male');
      expect(cholam.group, NikkudVowelGroup.o);
      expect(cholam.symbol, 'וֹ');

      final dagesh = HebrewAlphabetSeedData.nikkudMarks
          .firstWhere((m) => m.id == 'dagesh');
      expect(dagesh.group, NikkudVowelGroup.dagesh);
    });
  });
}
