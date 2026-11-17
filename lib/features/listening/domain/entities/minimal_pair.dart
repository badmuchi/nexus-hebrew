import '../../../../core/utils/hebrew_normalizer.dart';

/// Categories of phonetic contrasts and homophones in Hebrew.
enum PhoneticCategory {
  tavVsTet(
    title: 'Звук /t/: ת против ט',
    hebrewTitle: 'תּוֹ וָטֵית',
    description: 'В современном иврите обе буквы звучат как /t/, но определяют разные корни',
  ),
  kafVsQof(
    title: 'Звук /k/: כּ против ק',
    hebrewTitle: 'כַּף דְּגוּשָׁה וְקוֹף',
    description: 'Оба звука произносятся как /k/, исторически ק была эмфатической гортанной',
  ),
  vetVsVav(
    title: 'Звук /v/: בֿ против ו',
    hebrewTitle: 'בֵּית רָפָה וָוָאו',
    description: 'Бет без дагеша (вет) и буква вав звучат одинаково как /v/',
  ),
  chetVsChaf(
    title: 'Звук /x/: ח против כֿ',
    hebrewTitle: 'חֵית וְכַף רָפָה',
    description: 'В современном произношении обе звучат как глухой фрикативный /x/ (русский «х»)',
  ),
  alefVsAyin(
    title: 'Гортанные: א против ע',
    hebrewTitle: 'אָלֶף וְעַיִן',
    description: 'Алеф и аин часто звучат как легкая гортанная пауза или гласный звук',
  ),
  sinVsSamech(
    title: 'Звук /s/: שׂ против ס',
    hebrewTitle: 'שִׂין וְסָמֶךְ',
    description: 'Син с точкой слева и самех звучат абсолютно одинаково как /s/',
  ),
  genderSound(
    title: 'Род на слух: м.р. vs ж.р.',
    hebrewTitle: 'זָכָר וּנְקֵבָה בִּשְׁמִיעָה',
    description: 'Различение окончаний женского рода (-а, -ет) и мужского рода',
  ),
  stressAccent(
    title: 'Ударение: Милель vs Мильра',
    hebrewTitle: 'מִלְּעֵיל וּמִלְּרַע',
    description: 'Ударение на предпоследний слог (милель) меняет значение слова',
  );

  const PhoneticCategory({
    required this.title,
    required this.hebrewTitle,
    required this.description,
  });

  final String title;
  final String hebrewTitle;
  final String description;
}

/// A single Hebrew word in a minimal pair contrast.
class MinimalPairWord {
  final String id;
  final String vocalized;
  final String unpointed;
  final String transliteration;
  final String translation;
  final String? shoresh;
  final String mnemonicNote;
  final String exampleSentenceHebrew;
  final String exampleSentenceRussian;

  const MinimalPairWord({
    required this.id,
    required this.vocalized,
    required this.unpointed,
    required this.transliteration,
    required this.translation,
    this.shoresh,
    required this.mnemonicNote,
    required this.exampleSentenceHebrew,
    required this.exampleSentenceRussian,
  });

  factory MinimalPairWord.create({
    required String id,
    required String vocalized,
    String? unpointed,
    required String transliteration,
    required String translation,
    String? shoresh,
    required String mnemonicNote,
    required String exampleSentenceHebrew,
    required String exampleSentenceRussian,
  }) {
    return MinimalPairWord(
      id: id,
      vocalized: vocalized,
      unpointed: unpointed ?? HebrewNormalizer.stripNikkud(vocalized),
      transliteration: transliteration,
      translation: translation,
      shoresh: shoresh,
      mnemonicNote: mnemonicNote,
      exampleSentenceHebrew: exampleSentenceHebrew,
      exampleSentenceRussian: exampleSentenceRussian,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MinimalPairWord &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// An exercise presenting a minimal pair audio challenge.
class MinimalPairExercise {
  final String id;
  final PhoneticCategory category;
  final String contrastTitle;
  final String pedagogicalExplanation;
  final MinimalPairWord targetWord;
  final MinimalPairWord contrastWord;

  const MinimalPairExercise({
    required this.id,
    required this.category,
    required this.contrastTitle,
    required this.pedagogicalExplanation,
    required this.targetWord,
    required this.contrastWord,
  });

  /// Check whether chosen word matches target word ID.
  bool isCorrectChoice(String chosenWordId) => chosenWordId == targetWord.id;
}
