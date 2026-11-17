import 'package:equatable/equatable.dart';

/// Grammatical person and number in Hebrew morphology.
enum GrammaticalPerson {
  firstSingular('1 л. ед.ч. (я)'),
  secondMasculineSingular('2 л. м.р. ед.ч. (ты м.)'),
  secondFeminineSingular('2 л. ж.р. ед.ч. (ты ж.)'),
  thirdMasculineSingular('3 л. м.р. ед.ч. (он)'),
  thirdFeminineSingular('3 л. ж.р. ед.ч. (она)'),
  firstPlural('1 л. мн.ч. (мы)'),
  secondMasculinePlural('2 л. м.р. мн.ч. (вы м.)'),
  secondFemininePlural('2 л. ж.р. мн.ч. (вы ж.)'),
  thirdMasculinePlural('3 л. м.р. мн.ч. (они м.)'),
  thirdFemininePlural('3 л. ж.р. мн.ч. (они ж.)');

  final String labelRu;
  const GrammaticalPerson(this.labelRu);
}

/// Inflexion paradigm pattern (Тип 1: основы ед. числа, Тип 2: основы мн. числа с дифтонгом /ay/).
enum PrepositionPattern {
  singularType(
    'Тип 1 (основа ед. числа)',
    'Присоединяет суффиксы как к существительным в единственном числе (לִי, שֶׁלִּי, בִּי, אוֹתִי)',
  ),
  pluralType(
    'Тип 2 (основа мн. числа)',
    'Присоединяет суффиксы как к существительным во множественном числе через /ay/ (עָלַי, אֵלַי, בִּלְעָדַי)',
  );

  final String title;
  final String description;

  const PrepositionPattern(this.title, this.description);
}

/// A single inflected preposition form for a specific grammatical person.
class PrepositionForm extends Equatable {
  final GrammaticalPerson person;
  final String hebrewVocalized;
  final String hebrewNormalized;
  final String transliteration;
  final String russianTranslation;
  final String exampleSentenceHebrew;
  final String exampleSentenceRussian;

  const PrepositionForm({
    required this.person,
    required this.hebrewVocalized,
    required this.hebrewNormalized,
    required this.transliteration,
    required this.russianTranslation,
    required this.exampleSentenceHebrew,
    required this.exampleSentenceRussian,
  });

  @override
  List<Object?> get props => [
        person,
        hebrewVocalized,
        hebrewNormalized,
        transliteration,
        russianTranslation,
        exampleSentenceHebrew,
        exampleSentenceRussian,
      ];
}

/// A Hebrew preposition with full paradigm of pronoun suffix inflections.
class PrepositionEntity extends Equatable {
  final String id;
  final String baseHebrew;
  final String baseRussian;
  final String transliteration;
  final PrepositionPattern pattern;
  final String grammaticalRule;
  final String? usageNote;
  final List<PrepositionForm> forms;

  const PrepositionEntity({
    required this.id,
    required this.baseHebrew,
    required this.baseRussian,
    required this.transliteration,
    required this.pattern,
    required this.grammaticalRule,
    this.usageNote,
    required this.forms,
  });

  @override
  List<Object?> get props => [
        id,
        baseHebrew,
        baseRussian,
        transliteration,
        pattern,
        grammaticalRule,
        usageNote,
        forms,
      ];
}
