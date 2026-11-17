import 'package:equatable/equatable.dart';

/// Categories of Hebrew letters for grammatical and phonetic grouping.
enum LetterCategory {
  consonant,
  guttural, // גרוניות: א, ה, ח, ע
  begedKefet, // בג״ד כפ״ת: ב, כ, פ (меняют звук при наличии дагеша)
  sofit, // סופיות: ך, ם, ן, ף, ץ (конечные формы)
}

/// Domain entity representing a letter in the Hebrew Alef-Bet.
class HebrewLetter extends Equatable {
  final String id;
  final String printed;
  final String? finalFormPrinted;
  final String nameHebrew;
  final String nameRussian;
  final String transliteration;
  final String soundDescription;
  final String? dageshExplanation;
  final int gematria;
  final LetterCategory category;
  final String cursiveDescription;
  final String exampleWordHebrew;
  final String exampleWordRussian;
  final String exampleWordTranscription;

  const HebrewLetter({
    required this.id,
    required this.printed,
    this.finalFormPrinted,
    required this.nameHebrew,
    required this.nameRussian,
    required this.transliteration,
    required this.soundDescription,
    this.dageshExplanation,
    required this.gematria,
    required this.category,
    required this.cursiveDescription,
    required this.exampleWordHebrew,
    required this.exampleWordRussian,
    required this.exampleWordTranscription,
  });

  bool get hasFinalForm => finalFormPrinted != null;
  bool get isBegedKefet => category == LetterCategory.begedKefet;
  bool get isGuttural => category == LetterCategory.guttural;

  @override
  List<Object?> get props => [
        id,
        printed,
        finalFormPrinted,
        nameHebrew,
        nameRussian,
        transliteration,
        soundDescription,
        dageshExplanation,
        gematria,
        category,
        cursiveDescription,
        exampleWordHebrew,
        exampleWordRussian,
        exampleWordTranscription,
      ];
}
