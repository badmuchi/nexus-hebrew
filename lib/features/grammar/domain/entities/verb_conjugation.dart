import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../../conversation/domain/entities/binyan.dart';
import '../../../conversation/domain/entities/hebrew_text.dart';
import '../../../srs/domain/entities/srs_card.dart';

/// Hebrew verb tense used in paradigm tables and conjugation drills.
enum VerbTense {
  present(
    id: 'present',
    hebrewLabel: 'הוֹוֶה',
    russianLabel: 'Настоящее',
  ),
  past(
    id: 'past',
    hebrewLabel: 'עָבָר',
    russianLabel: 'Прошедшее',
  ),
  future(
    id: 'future',
    hebrewLabel: 'עָתִיד',
    russianLabel: 'Будущее',
  );

  const VerbTense({
    required this.id,
    required this.hebrewLabel,
    required this.russianLabel,
  });

  final String id;
  final String hebrewLabel;
  final String russianLabel;

  /// Parses an external tense string into [VerbTense] or returns [ParsingFailure].
  static Result<VerbTense, ParsingFailure> parseStrict(String rawValue) {
    final String normalized = rawValue.trim().toLowerCase();
    for (final VerbTense tense in VerbTense.values) {
      if (tense.id == normalized) {
        return Success<VerbTense, ParsingFailure>(tense);
      }
    }
    return Error<VerbTense, ParsingFailure>(
      ParsingFailure('Unknown Hebrew verb tense: "$rawValue"'),
    );
  }
}

/// Grammatical person/gender/number slot in a Hebrew conjugation paradigm.
enum GrammaticalPerson {
  masculineSingular(
    id: 'ms',
    hebrewPronoun: 'הוּא / אַתָּה / אֲנִי (ז׳)',
    russianLabel: 'м.р. ед.ч.',
  ),
  feminineSingular(
    id: 'fs',
    hebrewPronoun: 'הִיא / אַתְּ / אֲנִי (נ׳)',
    russianLabel: 'ж.р. ед.ч.',
  ),
  masculinePlural(
    id: 'mp',
    hebrewPronoun: 'הֵם / אַתֶּם / אֲנַחְנוּ (ז׳)',
    russianLabel: 'м.р. мн.ч.',
  ),
  femininePlural(
    id: 'fp',
    hebrewPronoun: 'הֵן / אַתֶּן / אֲנַחְנוּ (נ׳)',
    russianLabel: 'ж.р. мн.ч.',
  ),
  firstSingular(
    id: '1s',
    hebrewPronoun: 'אֲנִי',
    russianLabel: 'я (1 л. ед.)',
  ),
  secondMasculineSingular(
    id: '2ms',
    hebrewPronoun: 'אַתָּה',
    russianLabel: 'ты м.р.',
  ),
  secondFeminineSingular(
    id: '2fs',
    hebrewPronoun: 'אַתְּ',
    russianLabel: 'ты ж.р.',
  ),
  thirdMasculineSingular(
    id: '3ms',
    hebrewPronoun: 'הוּא',
    russianLabel: 'он',
  ),
  thirdFeminineSingular(
    id: '3fs',
    hebrewPronoun: 'הִיא',
    russianLabel: 'она',
  ),
  firstPlural(
    id: '1p',
    hebrewPronoun: 'אֲנַחְנוּ',
    russianLabel: 'мы',
  ),
  thirdPlural(
    id: '3p',
    hebrewPronoun: 'הֵם / הֵן',
    russianLabel: 'они',
  );

  const GrammaticalPerson({
    required this.id,
    required this.hebrewPronoun,
    required this.russianLabel,
  });

  final String id;
  final String hebrewPronoun;
  final String russianLabel;

  /// Parses an external person code into [GrammaticalPerson] or returns [ParsingFailure].
  static Result<GrammaticalPerson, ParsingFailure> parseStrict(
    String rawValue,
  ) {
    final String normalized = rawValue.trim().toLowerCase();
    for (final GrammaticalPerson person in GrammaticalPerson.values) {
      if (person.id == normalized) {
        return Success<GrammaticalPerson, ParsingFailure>(person);
      }
    }
    return Error<GrammaticalPerson, ParsingFailure>(
      ParsingFailure('Unknown grammatical person: "$rawValue"'),
    );
  }
}

/// Immutable conjugated verb form for a specific tense and grammatical person.
final class ConjugatedForm extends Equatable {
  const ConjugatedForm({
    required this.tense,
    required this.person,
    required this.form,
    required this.transliteration,
  });

  final VerbTense tense;
  final GrammaticalPerson person;
  final HebrewText form;
  final String transliteration;

  @override
  List<Object?> get props => [tense, person, form, transliteration];
}

/// Immutable Hebrew verb lexeme with its shoresh, binyan, and full conjugation table.
final class VerbLexeme extends Equatable {
  VerbLexeme({
    required this.id,
    required this.lemma,
    required this.infinitive,
    required this.root,
    required this.binyan,
    required this.russianMeaning,
    required this.grammarNotesRu,
    required List<ConjugatedForm> conjugations,
    required this.attribution,
  }) : conjugations = List<ConjugatedForm>.unmodifiable(conjugations);

  final String id;
  final HebrewText lemma;

  /// Nullable because passive binyanim ([Binyan.pual], [Binyan.hufal]) lack active infinitives.
  final HebrewText? infinitive;
  final Shoresh root;
  final Binyan binyan;
  final String russianMeaning;
  final String grammarNotesRu;
  final List<ConjugatedForm> conjugations;
  final ContentAttribution attribution;

  /// Returns all forms belonging to [tense] preserving canonical paradigm order.
  List<ConjugatedForm> formsForTense(VerbTense tense) {
    return conjugations
        .where((ConjugatedForm item) => item.tense == tense)
        .toList(growable: false);
  }

  /// Looks up a single conjugated form by [tense] and [person], or null if absent.
  ConjugatedForm? findForm(VerbTense tense, GrammaticalPerson person) {
    for (final ConjugatedForm item in conjugations) {
      if (item.tense == tense && item.person == person) {
        return item;
      }
    }
    return null;
  }

  @override
  List<Object?> get props => [
        id,
        lemma,
        infinitive,
        root,
        binyan,
        russianMeaning,
        grammarNotesRu,
        conjugations,
        attribution,
      ];
}

/// Evaluation result of a user's typed conjugation drill attempt.
final class ConjugationCheckResult extends Equatable {
  const ConjugationCheckResult({
    required this.isCorrect,
    required this.normalizedUserInput,
    required this.normalizedExpected,
    required this.expectedForm,
    required this.transliteration,
    required this.tense,
    required this.person,
  });

  final bool isCorrect;
  final String normalizedUserInput;
  final String normalizedExpected;
  final HebrewText expectedForm;
  final String transliteration;
  final VerbTense tense;
  final GrammaticalPerson person;

  @override
  List<Object?> get props => [
        isCorrect,
        normalizedUserInput,
        normalizedExpected,
        expectedForm,
        transliteration,
        tense,
        person,
      ];
}
