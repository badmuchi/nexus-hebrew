import '../../../../core/utils/hebrew_normalizer.dart';

/// A model representing a Hebrew cardinal number with gender forms,
/// construct (smikhut) forms, and contextual examples.
class HebrewNumber {
  final int value;
  final String masculine;
  final String masculineUnpointed;
  final String masculineTranslit;
  final String feminine;
  final String feminineUnpointed;
  final String feminineTranslit;
  final String? masculineConstruct;
  final String? feminineConstruct;
  final String exampleMasculine;
  final String exampleFeminine;
  final String? note;

  const HebrewNumber({
    required this.value,
    required this.masculine,
    required this.masculineUnpointed,
    required this.masculineTranslit,
    required this.feminine,
    required this.feminineUnpointed,
    required this.feminineTranslit,
    this.masculineConstruct,
    this.feminineConstruct,
    required this.exampleMasculine,
    required this.exampleFeminine,
    this.note,
  });

  factory HebrewNumber.create({
    required int value,
    required String masculine,
    String? masculineUnpointed,
    required String masculineTranslit,
    required String feminine,
    String? feminineUnpointed,
    required String feminineTranslit,
    String? masculineConstruct,
    String? feminineConstruct,
    required String exampleMasculine,
    required String exampleFeminine,
    String? note,
  }) {
    return HebrewNumber(
      value: value,
      masculine: masculine,
      masculineUnpointed:
          masculineUnpointed ?? HebrewNormalizer.stripNikkud(masculine),
      masculineTranslit: masculineTranslit,
      feminine: feminine,
      feminineUnpointed:
          feminineUnpointed ?? HebrewNormalizer.stripNikkud(feminine),
      feminineTranslit: feminineTranslit,
      masculineConstruct: masculineConstruct,
      feminineConstruct: feminineConstruct,
      exampleMasculine: exampleMasculine,
      exampleFeminine: exampleFeminine,
      note: note,
    );
  }
}

/// A countable noun used in gender simulation drills.
class CountableNoun {
  final String id;
  final String singularHebrew;
  final String pluralHebrew;
  final String singularTranslation;
  final String pluralTranslation;
  final bool isMasculine;

  const CountableNoun({
    required this.id,
    required this.singularHebrew,
    required this.pluralHebrew,
    required this.singularTranslation,
    required this.pluralTranslation,
    required this.isMasculine,
  });
}

/// A representation of time expressed in natural Hebrew speech.
class TimePhrase {
  final int hour;
  final int minute;
  final String hebrewPhrase;
  final String transliteration;
  final String russianTranslation;
  final String explanation;

  const TimePhrase({
    required this.hour,
    required this.minute,
    required this.hebrewPhrase,
    required this.transliteration,
    required this.russianTranslation,
    required this.explanation,
  });
}

/// A quiz question testing number gender agreements or time expressions.
class NumberQuizQuestion {
  final String id;
  final String questionPrompt;
  final String correctAnswer;
  final List<String> options;
  final String explanation;
  final String audioPrompt;

  const NumberQuizQuestion({
    required this.id,
    required this.questionPrompt,
    required this.correctAnswer,
    required this.options,
    required this.explanation,
    required this.audioPrompt,
  });

  bool isCorrect(String answer) => answer.trim() == correctAnswer.trim();
}
