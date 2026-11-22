import 'dart:math' as math;

import '../../../../core/database/app_database.dart';
import '../../../../core/utils/hebrew_normalizer.dart';
import '../../../conversation/domain/entities/hebrew_text.dart';
import '../entities/story.dart';

/// Representation of a weak FSRS flashcard requiring contextual reinforcement.
final class WeakWordTarget {
  final String hebrewVocalized;
  final String hebrewNormalized;
  final String russianTranslation;
  final double stability;
  final int lapses;

  const WeakWordTarget({
    required this.hebrewVocalized,
    required this.hebrewNormalized,
    required this.russianTranslation,
    required this.stability,
    required this.lapses,
  });

  factory WeakWordTarget.fromCardRow(SrsCardRow row) {
    return WeakWordTarget(
      hebrewVocalized: row.hebrewVocalized,
      hebrewNormalized: row.hebrewNormalized,
      russianTranslation: row.russianTranslation,
      stability: row.stability,
      lapses: row.lapses,
    );
  }
}

/// Service analyzing user's FSRS deck and generating contextual Hebrew mini-stories
/// targeting weak vocabulary (S < 3.0 days, lapses > 0, or relearning state).
final class WeakWordsStoryGenerator {
  const WeakWordsStoryGenerator();

  static const List<WeakWordTarget> _fallbackDefaultWords = [
    WeakWordTarget(
      hebrewVocalized: 'קָפֶה',
      hebrewNormalized: 'קפה',
      russianTranslation: 'кофе',
      stability: 1.2,
      lapses: 1,
    ),
    WeakWordTarget(
      hebrewVocalized: 'בְּבַקָּשָׁה',
      hebrewNormalized: 'בבקשה',
      russianTranslation: 'пожалуйста',
      stability: 2.0,
      lapses: 0,
    ),
    WeakWordTarget(
      hebrewVocalized: 'תּוֹדָה',
      hebrewNormalized: 'תודה',
      russianTranslation: 'спасибо',
      stability: 1.8,
      lapses: 1,
    ),
    WeakWordTarget(
      hebrewVocalized: 'חָבֵר',
      hebrewNormalized: 'חבר',
      russianTranslation: 'друг',
      stability: 2.4,
      lapses: 0,
    ),
  ];

  /// Filters cards in need of reinforcement based on stability and lapses.
  static List<WeakWordTarget> extractWeakWords(List<SrsCardRow> cards) {
    if (cards.isEmpty) return _fallbackDefaultWords;

    final candidates = <WeakWordTarget>[];
    for (final card in cards) {
      final isWeak = card.stability < 3.0 ||
          card.lapses > 0 ||
          card.fsrsState == 'relearning' ||
          card.fsrsState == 'learning';

      if (isWeak && card.hebrewNormalized.trim().isNotEmpty) {
        candidates.add(WeakWordTarget.fromCardRow(card));
      }
    }

    // Sort by lowest stability and highest lapses
    candidates.sort((a, b) {
      final lapseCompare = b.lapses.compareTo(a.lapses);
      if (lapseCompare != 0) return lapseCompare;
      return a.stability.compareTo(b.stability);
    });

    if (candidates.length >= 3) {
      return candidates.take(5).toList();
    }

    // If fewer than 3 weak words, supplement with any cards from the deck
    final existingNorms = candidates.map((c) => c.hebrewNormalized).toSet();
    for (final card in cards) {
      if (candidates.length >= 4) break;
      if (!existingNorms.contains(card.hebrewNormalized)) {
        candidates.add(WeakWordTarget.fromCardRow(card));
        existingNorms.add(card.hebrewNormalized);
      }
    }

    return candidates.isNotEmpty ? candidates : _fallbackDefaultWords;
  }

  /// Synthesizes a structured [Story] embedding the given [weakWords].
  static Story generateStory({
    required List<WeakWordTarget> weakWords,
    int? seed,
    int? scenarioIndex,
  }) {
    final effectiveWords = weakWords.isNotEmpty ? weakWords : _fallbackDefaultWords;
    final rng = math.Random(seed ?? DateTime.now().millisecondsSinceEpoch);

    final w1 = effectiveWords[0];
    final w2 = effectiveWords.length > 1 ? effectiveWords[1] : w1;
    final w3 = effectiveWords.length > 2 ? effectiveWords[2] : w2;
    final w4 = effectiveWords.length > 3 ? effectiveWords[3] : w1;

    final scenarioChoice = scenarioIndex ?? (seed != null ? seed % 3 : rng.nextInt(3));

    switch (scenarioChoice) {
      case 0:
        return _buildCafeStory(w1, w2, w3, w4);
      case 1:
        return _buildMarketStory(w1, w2, w3, w4);
      default:
        return _buildBeachStory(w1, w2, w3, w4);
    }
  }

  static Story _buildCafeStory(
    WeakWordTarget w1,
    WeakWordTarget w2,
    WeakWordTarget w3,
    WeakWordTarget w4,
  ) {
    final targetWordsList = '${w1.hebrewVocalized}, ${w2.hebrewVocalized}, ${w3.hebrewVocalized}';

    final s1 = _createSentence(
      id: 's_cafe_1',
      hebrewVocalized: 'הַבֹּקֶר הָיָה בָּהִיר, וְדָנִיאֵל נִכְנַס לְבֵית הַקָּפֶה עִם מִלָּה אַחַת בַּלֵּב: ${w1.hebrewVocalized}.',
      russianTranslation: 'Утро было ясным, и Даниэль зашел в кофейню с одним словом на сердце: ${w1.russianTranslation}.',
      targetedWords: [w1],
    );

    final s2 = _createSentence(
      id: 's_cafe_2',
      hebrewVocalized: 'הַבָּרִיסְטָה חִיֵּךְ וְאָמַר: "${w2.hebrewVocalized}, הִנֵּה הַהַזְמָנָה שֶׁלְּךָ!"',
      russianTranslation: 'Бариста улыбнулся и сказал: "${w2.russianTranslation}, вот ваш заказ!"',
      targetedWords: [w2],
    );

    final s3 = _createSentence(
      id: 's_cafe_3',
      hebrewVocalized: 'דָּנִיאֵל הֵשִׁיב מִיָּד: "${w3.hebrewVocalized}, זֶה בְּדִיּוּק מָה שֶׁרָצִיתִי".',
      russianTranslation: 'Даниэль сразу ответил: "${w3.russianTranslation}, это в точности то, что я хотел".',
      targetedWords: [w3],
    );

    final s4 = _createSentence(
      id: 's_cafe_4',
      hebrewVocalized: 'לִפְנֵי שֶׁיָּצָא, הוּא נִזְכַּר גַּם בַּבִּטּוּי ${w4.hebrewVocalized} וְהִרְגִּישׁ שֶׁהַשָּׂפָה נַעֲשֵׂית טִבְעִית יוֹתֵר.',
      russianTranslation: 'Прежде чем выйти, он вспомнил также выражение ${w4.russianTranslation} и почувствовал, что язык становится естественнее.',
      targetedWords: [w4],
    );

    return Story(
      id: 'story_weak_${DateTime.now().microsecondsSinceEpoch}',
      titleHebrew: const HebrewText.fixture(
        vocalized: 'בֹּקֶר שֶׁל קָפֶה בְּדִיזֶנְגֹוף',
        normalized: 'בוקר של קפה בדיזנגוף',
      ),
      titleRussian: 'Утро с кофе на Дизенгоф (FSRS)',
      level: 'FSRS Smart',
      readingTimeMinutes: 2,
      coverEmoji: '☕',
      summaryRussian: 'Адаптивный рассказ для закрепления трудных слов: $targetWordsList.',
      paragraphs: [
        StoryParagraph(id: 'p1', sentences: [s1, s2]),
        StoryParagraph(id: 'p2', sentences: [s3, s4]),
      ],
    );
  }

  static Story _buildMarketStory(
    WeakWordTarget w1,
    WeakWordTarget w2,
    WeakWordTarget w3,
    WeakWordTarget w4,
  ) {
    final targetWordsList = '${w1.hebrewVocalized}, ${w2.hebrewVocalized}, ${w3.hebrewVocalized}';

    final s1 = _createSentence(
      id: 's_mkt_1',
      hebrewVocalized: 'בְּיוֹם שִׁשִּׁי שׁוּק הַכַּרְמֶל הוֹמֶה אֲנָשִׁים, וְכֻלָּם מְחַפְּשִׂים ${w1.hebrewVocalized}.',
      russianTranslation: 'В пятницу рынок Кармель шумит людьми, и все ищут ${w1.russianTranslation}.',
      targetedWords: [w1],
    );

    final s2 = _createSentence(
      id: 's_mkt_2',
      hebrewVocalized: 'הַמּוֹכֵר צָעַק בְּקוֹל רָם: "${w2.hebrewVocalized}, הַכֹּל טָרִי וּבְמִבְצָע!"',
      russianTranslation: 'Продавец громко крикнул: "${w2.russianTranslation}, все свежее и по акции!"',
      targetedWords: [w2],
    );

    final s3 = _createSentence(
      id: 's_mkt_3',
      hebrewVocalized: 'הַקּוֹנִים עָנוּ בְּחִיּוּךְ: "${w3.hebrewVocalized}, תֵּן לָנוּ שְׁנַיִם מִזֶּה".',
      russianTranslation: 'Покупатели с улыбкой ответили: "${w3.russianTranslation}, дайте нам два таких".',
      targetedWords: [w3],
    );

    final s4 = _createSentence(
      id: 's_mkt_4',
      hebrewVocalized: 'בַּסּוֹף הַקְּנִיּוֹת נִשְׁאַר רַק לוֹמַר ${w4.hebrewVocalized} וּלְאַחֵל שַׁבָּת שָׁלוֹם.',
      russianTranslation: 'В конце покупок осталось только сказать ${w4.russianTranslation} и пожелать Шаббат Шалом.',
      targetedWords: [w4],
    );

    return Story(
      id: 'story_weak_${DateTime.now().microsecondsSinceEpoch}',
      titleHebrew: const HebrewText.fixture(
        vocalized: 'שִׁשִּׁי עַל שׁוּק הַכַּרְמֶל',
        normalized: 'שישי על שוק הכרמל',
      ),
      titleRussian: 'Пятница на рынке Кармель (FSRS)',
      level: 'FSRS Smart',
      readingTimeMinutes: 2,
      coverEmoji: '🛒',
      summaryRussian: 'Адаптивный рассказ для закрепления трудных слов: $targetWordsList.',
      paragraphs: [
        StoryParagraph(id: 'p1', sentences: [s1, s2]),
        StoryParagraph(id: 'p2', sentences: [s3, s4]),
      ],
    );
  }

  static Story _buildBeachStory(
    WeakWordTarget w1,
    WeakWordTarget w2,
    WeakWordTarget w3,
    WeakWordTarget w4,
  ) {
    final targetWordsList = '${w1.hebrewVocalized}, ${w2.hebrewVocalized}, ${w3.hebrewVocalized}';

    final s1 = _createSentence(
      id: 's_bch_1',
      hebrewVocalized: 'הַגַּלִּים בְּחוֹף גּוֹרְדוֹן הָיוּ שְׁקֵטִים, וְנִדְמֶה הָיָה שֶׁזֶּה זְמַן מֻשְׁלָם לוֹמַר ${w1.hebrewVocalized}.',
      russianTranslation: 'Волны на пляже Гордон были тихими, и казалось, что это идеальное время сказать ${w1.russianTranslation}.',
      targetedWords: [w1],
    );

    final s2 = _createSentence(
      id: 's_bch_2',
      hebrewVocalized: 'חֲבֵרִים יָשְׁבוּ עַל הַחוֹל וְהִקְשִׁיבוּ: "${w2.hebrewVocalized}, הַשְּׁקִיעָה הַיּוֹם מַדְהִימָה!"',
      russianTranslation: 'Друзья сидели на песке и слушали: "${w2.russianTranslation}, закат сегодня потрясающий!"',
      targetedWords: [w2],
    );

    final s3 = _createSentence(
      id: 's_bch_3',
      hebrewVocalized: 'אֶחָד מֵהֶם הִסְכִּים: "${w3.hebrewVocalized}, זֶה רֶגַע שֶׁל שַׁלְוָה אֲמִתִּית".',
      russianTranslation: 'Один из них согласился: "${w3.russianTranslation}, это момент истинного спокойствия".',
      targetedWords: [w3],
    );

    final s4 = _createSentence(
      id: 's_bch_4',
      hebrewVocalized: 'וּכְשֶׁהַשֶּׁמֶשׁ שָׁקְעָה, הֵם נִפְרְדוּ עִם ${w4.hebrewVocalized} וְתִקְוָה לְהִפָּגֵשׁ שׁוּב.',
      russianTranslation: 'И когда солнце село, они попрощались со словом ${w4.russianTranslation} и надеждой встретиться снова.',
      targetedWords: [w4],
    );

    return Story(
      id: 'story_weak_${DateTime.now().microsecondsSinceEpoch}',
      titleHebrew: const HebrewText.fixture(
        vocalized: 'שְׁקִיעָה בְּחוֹף תֵּל אָבִיב',
        normalized: 'שקיעה בחוף תל אביב',
      ),
      titleRussian: 'Закат на пляже Тель-Авива (FSRS)',
      level: 'FSRS Smart',
      readingTimeMinutes: 2,
      coverEmoji: '🌊',
      summaryRussian: 'Адаптивный рассказ для закрепления трудных слов: $targetWordsList.',
      paragraphs: [
        StoryParagraph(id: 'p1', sentences: [s1, s2]),
        StoryParagraph(id: 'p2', sentences: [s3, s4]),
      ],
    );
  }

  static StorySentence _createSentence({
    required String id,
    required String hebrewVocalized,
    required String russianTranslation,
    required List<WeakWordTarget> targetedWords,
  }) {
    final cleanNormalized = HebrewNormalizer.stripNikkud(hebrewVocalized);
    final rawTokens = hebrewVocalized.trim().split(RegExp(r'\s+'));
    final tokens = <StoryWordToken>[];

    final targetMap = <String, WeakWordTarget>{};
    for (final tw in targetedWords) {
      targetMap[tw.hebrewNormalized] = tw;
    }

    for (final rawTok in rawTokens) {
      final cleanTok = rawTok.replaceAll(RegExp(r'[^\u0590-\u05FFa-zA-Zа-яА-Я0-9]'), '');
      final norm = HebrewNormalizer.stripNikkud(cleanTok.isNotEmpty ? cleanTok : rawTok);

      final isTarget = targetMap.containsKey(norm);
      final translation = isTarget ? targetMap[norm]!.russianTranslation : '';

      tokens.add(
        StoryWordToken(
          wordVocalized: rawTok,
          wordNormalized: norm,
          russianTranslation: translation,
          category: isTarget ? 'weak_word_practice' : null,
        ),
      );
    }

    return StorySentence(
      id: id,
      hebrewVocalized: hebrewVocalized,
      hebrewNormalized: cleanNormalized,
      russianTranslation: russianTranslation,
      tokens: tokens,
    );
  }
}
