import 'package:equatable/equatable.dart';

import '../../../conversation/domain/entities/hebrew_text.dart';

/// Curated inspirational Hebrew word of the day with root, translation, and example.
final class WordOfTheDay extends Equatable {
  final String id;
  final HebrewText word;
  final String transliteration;
  final String russianMeaning;
  final Shoresh root;
  final String exampleSentenceHebrew;
  final String exampleSentenceRussian;
  final String sabraCulturalNote;

  const WordOfTheDay({
    required this.id,
    required this.word,
    required this.transliteration,
    required this.russianMeaning,
    required this.root,
    required this.exampleSentenceHebrew,
    required this.exampleSentenceRussian,
    required this.sabraCulturalNote,
  });

  @override
  List<Object?> get props => [
        id,
        word,
        transliteration,
        russianMeaning,
        root,
        exampleSentenceHebrew,
        exampleSentenceRussian,
        sabraCulturalNote,
      ];

  /// Returns today's curated word of the day based on the calendar date.
  static WordOfTheDay getForDate([DateTime? date]) {
    final now = date?.toUtc() ?? DateTime.now().toUtc();
    final dayIndex = DateTime.utc(now.year, now.month, now.day)
            .difference(DateTime.utc(2026, 1, 1))
            .inDays %
        catalog.length;
    final positiveIndex = (dayIndex < 0 ? dayIndex + catalog.length : dayIndex);
    return catalog[positiveIndex];
  }

  static const List<WordOfTheDay> catalog = [
    WordOfTheDay(
      id: 'wotd_tikva',
      word: HebrewText.fixture(vocalized: 'תִּקְוָה', normalized: 'תקוה'),
      transliteration: 'tikva',
      russianMeaning: 'надежда',
      root: Shoresh.fixture(['ק', 'ו', 'ה']),
      exampleSentenceHebrew: 'הַתִּקְוָה לֹא אָבְדָה.',
      exampleSentenceRussian: 'Надежда не потеряна.',
      sabraCulturalNote:
          '«Ха-Тиква» (הַתִּקְוָה) — название государственного гимна Израиля, основанного на стихотворении Нафтали Герца Имбера.',
    ),
    WordOfTheDay(
      id: 'wotd_savlanut',
      word: HebrewText.fixture(vocalized: 'סַבְלָנוּת', normalized: 'סבלנות'),
      transliteration: 'savlanut',
      russianMeaning: 'терпение',
      root: Shoresh.fixture(['ס', 'ב', 'ל']),
      exampleSentenceHebrew: 'קְצָת סַבְלָנוּת, הַכֹּל יִהְיֶה בְּסֵדֶר.',
      exampleSentenceRussian: 'Немного терпения, всё будет в порядке.',
      sabraCulturalNote:
          'В Израиле очень популярна поговорка «סַבְלָנוּת, לֹא קָנִיתָ בַּמַּכּוֹלֶת» (Терпение в продуктовом магазине не купишь).',
    ),
    WordOfTheDay(
      id: 'wotd_haverut',
      word: HebrewText.fixture(vocalized: 'חֲבֵרוּת', normalized: 'חברות'),
      transliteration: 'haverut',
      russianMeaning: 'дружба',
      root: Shoresh.fixture(['ח', 'ב', 'ר']),
      exampleSentenceHebrew: 'חֲבֵרוּת אֲמִתִּית נִמְדֶּדֶת בְּרְגָעִים קָשִׁים.',
      exampleSentenceRussian: 'Настоящая дружба измеряется в трудные моменты.',
      sabraCulturalNote:
          'Слово «хавер» (חָבֵר) означает не только друга, но и товарища, члена сообщества или бойфренда в зависимости от контекста.',
    ),
    WordOfTheDay(
      id: 'wotd_shalom',
      word: HebrewText.fixture(vocalized: 'שָׁלוֹם', normalized: 'שלום'),
      transliteration: 'shalom',
      russianMeaning: 'мир, приветствие, благополучие',
      root: Shoresh.fixture(['ש', 'ל', 'ם']),
      exampleSentenceHebrew: 'שָׁלוֹם עֲלֵיכֶם וּבְרוּכִים הַבָּאִים!',
      exampleSentenceRussian: 'Мир вам и добро пожаловать!',
      sabraCulturalNote:
          'Корень ש-ל-ם связан с целостностью, полнотой и гармонией (שְׁלֵמוּת). Мир — это не просто отсутствие войны, а состояние внутренней завершённости.',
    ),
    WordOfTheDay(
      id: 'wotd_hatzlaha',
      word: HebrewText.fixture(vocalized: 'הַצְלָחָה', normalized: 'הצלחה'),
      transliteration: 'hatzlaha',
      russianMeaning: 'успех, удача',
      root: Shoresh.fixture(['צ', 'ל', 'ח']),
      exampleSentenceHebrew: 'בְּהַצְלָחָה רַבָּה בַּלִּמּוּדִים!',
      exampleSentenceRussian: 'Больших успехов в учёбе!',
      sabraCulturalNote:
          '«Бе-ацлаха!» (בְּהַצְלָחָה) — самое частое ободряющее пожелание в Израиле перед тестом, собеседованием или новым начинанием.',
    ),
    WordOfTheDay(
      id: 'wotd_hiyukh',
      word: HebrewText.fixture(vocalized: 'חִיּוּךְ', normalized: 'חיוך'),
      transliteration: 'hiyukh',
      russianMeaning: 'улыбка',
      root: Shoresh.fixture(['ח', 'י', 'ך']),
      exampleSentenceHebrew: 'חִיּוּךְ אֶחָד שׁוֹוֶה אֶלֶף מִלִּים.',
      exampleSentenceRussian: 'Одна улыбка стоит тысячи слов.',
      sabraCulturalNote:
          'Израильтяне ценят открытость: улыбка и доброжелательный тон открывают любые двери быстрее формальностей.',
    ),
    WordOfTheDay(
      id: 'wotd_sakranut',
      word: HebrewText.fixture(vocalized: 'סַקְרָנוּת', normalized: 'סקרנות'),
      transliteration: 'sakranut',
      russianMeaning: 'любознательность, интерес',
      root: Shoresh.fixture(['ס', 'ק', 'ר']),
      exampleSentenceHebrew: 'הַסַּקְרָנוּת הִיא הַמַּנְוֵעַ שֶׁל הַלְּמִידָה.',
      exampleSentenceRussian: 'Любознательность — двигатель обучения.',
      sabraCulturalNote:
          'Культура вопросов и споров (в хорошем смысле) лежит в основе израильской инновационной традиции и стартап-экосистемы.',
    ),
    WordOfTheDay(
      id: 'wotd_simha',
      word: HebrewText.fixture(vocalized: 'שִׂמְחָה', normalized: 'שמחה'),
      transliteration: 'simha',
      russianMeaning: 'радость, веселье, торжество',
      root: Shoresh.fixture(['ש', 'מ', 'ח']),
      exampleSentenceHebrew: 'אֵין שִׂמְחָה כְּשִׂמְחַת הַלֵּב.',
      exampleSentenceRussian: 'Нет радости превыше радости сердца.',
      sabraCulturalNote:
          'Словом «симха» также называют любое семейное торжество: свадьбу, бар-мицву или рождение ребёнка («рак бе-смахот» — только по радостным поводам!).',
    ),
  ];
}
