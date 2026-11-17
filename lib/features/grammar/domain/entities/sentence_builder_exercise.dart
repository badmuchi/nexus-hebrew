import '../../../../core/utils/hebrew_normalizer.dart';

/// Categories of Hebrew syntactic and word-order rules.
enum SyntaxCategory {
  directObjectEt(
    title: 'Прямое дополнение с אֶת',
    hebrewTitle: 'מוּשָׂא יָשִׁיר (אֶת)',
    description: 'Определенный артикль הַ требует предлога אֶת перед объектом',
  ),
  adjectiveAgreement(
    title: 'Согласование прилагательных',
    hebrewTitle: 'הַתְאָמַת שֵׁם תֹּאַר',
    description: 'Прилагательное идет ПОСЛЕ существительного и копирует его артикль и род',
  ),
  existentialYeshEin(
    title: 'Наличие и владение (יֵשׁ / אֵין)',
    hebrewTitle: 'קִיּוּם וּבַעֲלוּת (יֵשׁ / אֵין)',
    description: 'Конструкции «У меня есть / нет» строятся через יֵשׁ / אֵין + לְ...',
  ),
  nominalSentence(
    title: 'Именные предложения',
    hebrewTitle: 'מִשְׁפָּט שְׁמִי',
    description: 'В настоящем времени нет глагола «быть» (подлежащее + сказуемое напрямую)',
  ),
  smijutConstruct(
    title: 'Сопряжение (Смихут)',
    hebrewTitle: 'סְמִיכוּת',
    description: 'Два существительных вместе; определенный артикль הַ ставится только ко второму',
  ),
  questionOrder(
    title: 'Вопросительные фразы',
    hebrewTitle: 'מִשְׁפְּטֵי שְׁאֵלָה',
    description: 'Вопросительное слово в начале, логический акцент и интонация',
  ),
  pastFutureAgreement(
    title: 'Глагол в прошедшем и будущем',
    hebrewTitle: 'הַתְאָמַת פֹּעַל בְּעָבָר וְעָתִיד',
    description: 'Согласование глагола по лицу, роду и числу с подлежащим',
  );

  const SyntaxCategory({
    required this.title,
    required this.hebrewTitle,
    required this.description,
  });

  final String title;
  final String hebrewTitle;
  final String description;
}

/// A single token (word / particle) used in constructing sentences.
class SentenceToken {
  final String id;
  final String vocalized;
  final String unpointed;
  final String translation;
  final String syntacticRole;
  final bool isDistractor;

  const SentenceToken({
    required this.id,
    required this.vocalized,
    required this.unpointed,
    required this.translation,
    required this.syntacticRole,
    this.isDistractor = false,
  });

  /// Factory helper for creating a token where unpointed is auto-normalized if not provided.
  factory SentenceToken.create({
    required String id,
    required String vocalized,
    String? unpointed,
    required String translation,
    required String syntacticRole,
    bool isDistractor = false,
  }) {
    return SentenceToken(
      id: id,
      vocalized: vocalized,
      unpointed: unpointed ?? HebrewNormalizer.stripNikkud(vocalized),
      translation: translation,
      syntacticRole: syntacticRole,
      isDistractor: isDistractor,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SentenceToken &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// An exercise model for assembling Hebrew sentences with syntax rules.
class SentenceExercise {
  final String id;
  final String targetHebrew;
  final String targetHebrewUnpointed;
  final String russianTranslation;
  final String transliteration;
  final SyntaxCategory category;
  final String level;
  final String ruleTitle;
  final String ruleExplanation;
  final List<SentenceToken> tokens;
  final List<SentenceToken> distractorTokens;
  final String hint;

  const SentenceExercise({
    required this.id,
    required this.targetHebrew,
    required this.targetHebrewUnpointed,
    required this.russianTranslation,
    required this.transliteration,
    required this.category,
    required this.level,
    required this.ruleTitle,
    required this.ruleExplanation,
    required this.tokens,
    required this.distractorTokens,
    required this.hint,
  });

  /// Returns true if the provided tokens match the target sequence.
  bool isCorrect(List<SentenceToken> submitted) {
    if (submitted.length != tokens.length) return false;
    for (int i = 0; i < tokens.length; i++) {
      if (submitted[i].unpointed != tokens[i].unpointed) {
        return false;
      }
    }
    return true;
  }

  /// Returns a merged list containing all correct tokens and distractors.
  List<SentenceToken> get allTokensPool => [...tokens, ...distractorTokens];
}
