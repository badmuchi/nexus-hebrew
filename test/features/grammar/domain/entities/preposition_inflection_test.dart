import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/grammar/data/datasources/hebrew_prepositions_seed_data.dart';
import 'package:nexus_hebrew_app/features/grammar/domain/entities/preposition_inflection.dart';

void main() {
  group('HebrewPrepositionsSeedData', () {
    test('contains 10 essential Hebrew prepositions with complete paradigms', () {
      expect(HebrewPrepositionsSeedData.prepositions.length, 10);

      final ids =
          HebrewPrepositionsSeedData.prepositions.map((p) => p.id).toSet();
      expect(
        ids,
        containsAll([
          'shel',
          'le',
          'be',
          'et',
          'im',
          'al',
          'el',
          'min',
          'bishvil',
          'kmo',
        ]),
      );
    });

    test('distinguishes singular-type and plural-type inflection patterns', () {
      final shel = HebrewPrepositionsSeedData.prepositions
          .firstWhere((p) => p.id == 'shel');
      expect(shel.pattern, PrepositionPattern.singularType);

      final al = HebrewPrepositionsSeedData.prepositions
          .firstWhere((p) => p.id == 'al');
      expect(al.pattern, PrepositionPattern.pluralType);

      final el = HebrewPrepositionsSeedData.prepositions
          .firstWhere((p) => p.id == 'el');
      expect(el.pattern, PrepositionPattern.pluralType);
    });

    test('contains valid pronoun forms with Hebrew vocalization and transliteration', () {
      final le = HebrewPrepositionsSeedData.prepositions
          .firstWhere((p) => p.id == 'le');
      expect(le.forms.length, 8);

      final firstPerson = le.forms.firstWhere(
        (f) => f.person == GrammaticalPerson.firstSingular,
      );
      expect(firstPerson.hebrewVocalized, 'לִי');
      expect(firstPerson.transliteration, 'Ли');
      expect(firstPerson.russianTranslation, 'Мне / у меня');
      expect(firstPerson.exampleSentenceHebrew, contains('יֵשׁ לִי'));

      final im = HebrewPrepositionsSeedData.prepositions
          .firstWhere((p) => p.id == 'im');
      final withMe = im.forms.firstWhere(
        (f) => f.person == GrammaticalPerson.firstSingular,
      );
      expect(withMe.hebrewVocalized, 'אִתִּי');
    });
  });
}
