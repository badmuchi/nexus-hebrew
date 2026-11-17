import '../../domain/entities/hebrew_number.dart';

/// Seed data and algorithmic helpers for Hebrew numbers, gender counting,
/// telling time (?מַה הַשָּׁעָה), and interactive drills.
abstract final class HebrewNumbersSeedData {
  static final List<HebrewNumber> cardinalNumbers = [
    HebrewNumber.create(
      value: 1,
      masculine: 'אֶחָד',
      masculineTranslit: 'Echad',
      feminine: 'אַחַת',
      feminineTranslit: 'Achat',
      exampleMasculine: 'שֶׁקֶל אֶחָד (один шекель)',
      exampleFeminine: 'עוּגָה אַחַת (один пирог)',
      note: 'Числительное «1» ВСЕГДА ставится ПОСЛЕ существительного: שֶׁקֶל אֶחָד, עוּגָה אַחַת.',
    ),
    HebrewNumber.create(
      value: 2,
      masculine: 'שְׁנַיִם',
      masculineTranslit: 'Shnayim',
      feminine: 'שְׁתַּיִם',
      feminineTranslit: 'Shtayim',
      masculineConstruct: 'שְׁנֵי',
      feminineConstruct: 'שְׁתֵּי',
      exampleMasculine: 'שְׁנֵי שְׁקָלִים (два шекеля)',
      exampleFeminine: 'שְׁתֵּי עוּגוֹת (два пирога)',
      note: 'Перед существительным всегда используется сопряженная форма (смихут): שְׁנֵי (м.р.) / שְׁתֵּי (ж.р.).',
    ),
    HebrewNumber.create(
      value: 3,
      masculine: 'שְׁלוֹשָׁה',
      masculineTranslit: 'Shlosha',
      feminine: 'שָׁלוֹשׁ',
      feminineTranslit: 'Shalosh',
      masculineConstruct: 'שְׁלוֹשֶׁת',
      feminineConstruct: 'שְׁלוֹשׁ',
      exampleMasculine: 'שְׁלוֹשָׁה סְפָרִים (три книги)',
      exampleFeminine: 'שָׁלוֹשׁ בָּנוֹת (три девочки)',
      note: 'ПАРАДОКС: Мужской род имеет окончание -а (שְׁלוֹשָׁה), а женский — без окончания (שָׁלוֹשׁ)!',
    ),
    HebrewNumber.create(
      value: 4,
      masculine: 'אַרְבָּעָה',
      masculineTranslit: 'Arba\'a',
      feminine: 'אַרְבַּע',
      feminineTranslit: 'Arba',
      masculineConstruct: 'אַרְבַּעַת',
      feminineConstruct: 'אַרְבַּע',
      exampleMasculine: 'אַרְבָּעָה יְלָדִים (четыре мальчика)',
      exampleFeminine: 'אַרְבַּע יְלָדוֹת (четыре девочки)',
      note: 'Мужской род с окончанием ה (אַרְבָּעָה), женский род — без ה (אַרְבַּע).',
    ),
    HebrewNumber.create(
      value: 5,
      masculine: 'חֲמִשָּׁה',
      masculineTranslit: 'Chamisha',
      feminine: 'חָמֵשׁ',
      feminineTranslit: 'Chamesh',
      masculineConstruct: 'חֲמֵשֶׁת',
      feminineConstruct: 'חֲמֵשׁ',
      exampleMasculine: 'חֲמִשָּׁה שְׁקָלִים (пять шекелей)',
      exampleFeminine: 'חָמֵשׁ שָׂפוֹת (пять языков)',
      note: 'В мужском роде חֲמִשָּׁה, в женском — חָמֵשׁ. Абстрактный счет всегда женского рода (חָמֵשׁ).',
    ),
    HebrewNumber.create(
      value: 6,
      masculine: 'שִׁשָּׁה',
      masculineTranslit: 'Shisha',
      feminine: 'שֵׁשׁ',
      feminineTranslit: 'Shesh',
      masculineConstruct: 'שֵׁשֶׁת',
      feminineConstruct: 'שֵׁשׁ',
      exampleMasculine: 'שִׁשָּׁה יָמִים (шесть дней)',
      exampleFeminine: 'שֵׁשׁ שָׁנִים (шесть лет)',
      note: 'Слово שָׁנָה (год) — женского рода, поэтому שֵׁשׁ שָׁנִים, несмотря на окончание -им!',
    ),
    HebrewNumber.create(
      value: 7,
      masculine: 'שִׁבְעָה',
      masculineTranslit: 'Shiv\'a',
      feminine: 'שֶׁבַע',
      feminineTranslit: 'Sheva',
      masculineConstruct: 'שִׁבְעַת',
      feminineConstruct: 'שְׁבַע',
      exampleMasculine: 'שִׁבְעָה תַּלְמִידִים (семь учеников)',
      exampleFeminine: 'שֶׁבַע תַּלְמִידוֹת (семь учениц)',
      note: 'Смихут мужского рода: שִׁבְעַת יְמֵי הַשָּׁבוּעַ (семь дней недели).',
    ),
    HebrewNumber.create(
      value: 8,
      masculine: 'שְׁמוֹנָה',
      masculineTranslit: 'Shmona',
      feminine: 'שְׁמוֹנֶה',
      feminineTranslit: 'Shmone',
      masculineConstruct: 'שְׁמוֹנַת',
      feminineConstruct: 'שְׁמוֹנֶה',
      exampleMasculine: 'שְׁמוֹנָה חֳדָשִׁים (восемь месяцев)',
      exampleFeminine: 'שְׁמוֹנֶה שָׁעוֹת (восемь часов)',
      note: 'Оба слова звучат с финальным гласным, но пишутся с разным никудом: שְׁמוֹנָה (м.р.) vs שְׁמוֹנֶה (ж.р.).',
    ),
    HebrewNumber.create(
      value: 9,
      masculine: 'תִּשְׁעָה',
      masculineTranslit: 'Tish\'a',
      feminine: 'תֵּשַׁע',
      feminineTranslit: 'Tesha',
      masculineConstruct: 'תִּשְׁעַת',
      feminineConstruct: 'תְּשַׁע',
      exampleMasculine: 'תִּשְׁעָה שִׁעוּרִים (девять уроков)',
      exampleFeminine: 'תֵּשַׁע תְּמוּנוֹת (девять картинок)',
      note: 'Мужской род תִּשְׁעָה, женский תֵּשַׁע.',
    ),
    HebrewNumber.create(
      value: 10,
      masculine: 'עֲשָׂרָה',
      masculineTranslit: 'Asara',
      feminine: 'עֶשֶׂר',
      feminineTranslit: 'Eser',
      masculineConstruct: 'עֲשֶׂרֶת',
      feminineConstruct: 'עֲשֶׂרֶת',
      exampleMasculine: 'עֲשָׂרָה שְׁקָלִים (десять шекелей)',
      exampleFeminine: 'עֶשֶׂר שָׁנִים (десять лет)',
      note: 'Смихут: עֲשֶׂרֶת הַדִּבְּרוֹת (Десять заповедей).',
    ),
  ];

  static final List<CountableNoun> sampleNouns = [
    const CountableNoun(
      id: 'noun_shekel',
      singularHebrew: 'שֶׁקֶל',
      pluralHebrew: 'שְׁקָלִים',
      singularTranslation: 'шекель',
      pluralTranslation: 'шекелей',
      isMasculine: true,
    ),
    const CountableNoun(
      id: 'noun_sefer',
      singularHebrew: 'סֵפֶר',
      pluralHebrew: 'סְפָרִים',
      singularTranslation: 'книга',
      pluralTranslation: 'книг',
      isMasculine: true,
    ),
    const CountableNoun(
      id: 'noun_yeled',
      singularHebrew: 'יֶלֶד',
      pluralHebrew: 'יְלָדִים',
      singularTranslation: 'мальчик',
      pluralTranslation: 'мальчиков',
      isMasculine: true,
    ),
    const CountableNoun(
      id: 'noun_uga',
      singularHebrew: 'עוּגָה',
      pluralHebrew: 'עוּגוֹת',
      singularTranslation: 'пирог',
      pluralTranslation: 'пирогов',
      isMasculine: false,
    ),
    const CountableNoun(
      id: 'noun_yalda',
      singularHebrew: 'יַלְדָּה',
      pluralHebrew: 'יְלָדוֹת',
      singularTranslation: 'девочка',
      pluralTranslation: 'девочек',
      isMasculine: false,
    ),
    const CountableNoun(
      id: 'noun_shana',
      singularHebrew: 'שָׁנָה',
      pluralHebrew: 'שָׁנִים',
      singularTranslation: 'год',
      pluralTranslation: 'лет',
      isMasculine: false,
    ),
  ];

  static const Map<int, (String hebrew, String translit)> hourWordsFeminine = {
    1: ('אַחַת', 'Achat'),
    2: ('שְׁתַּיִם', 'Shtayim'),
    3: ('שָׁלוֹשׁ', 'Shalosh'),
    4: ('אַרְבַּע', 'Arba'),
    5: ('חָמֵשׁ', 'Chamesh'),
    6: ('שֵׁשׁ', 'Shesh'),
    7: ('שֶׁבַע', 'Sheva'),
    8: ('שְׁמוֹנֶה', 'Shmone'),
    9: ('תֵּשַׁע', 'Tesha'),
    10: ('עֶשֶׂר', 'Eser'),
    11: ('אַחַת עֶשְׂרֵה', 'Achat-esre'),
    12: ('שְׁתֵּים עֶשְׂרֵה', 'Shteim-esre'),
  };

  /// Generates a natural Hebrew time phrase given an hour (1-12) and minute (0, 15, 30, 45, etc.).
  static TimePhrase calculateTimePhrase(int hour, int minute) {
    final normHour = ((hour - 1) % 12) + 1;
    final nextHour = (normHour % 12) + 1;

    final currHourHeb = hourWordsFeminine[normHour]!.$1;
    final currHourTr = hourWordsFeminine[normHour]!.$2;
    final nextHourHeb = hourWordsFeminine[nextHour]!.$1;
    final nextHourTr = hourWordsFeminine[nextHour]!.$2;

    switch (minute) {
      case 0:
        return TimePhrase(
          hour: normHour,
          minute: 0,
          hebrewPhrase: 'הַשָּׁעָה $currHourHeb בְּדִיּוּק',
          transliteration: 'Ha-sha\'a $currHourTr be-diyuk',
          russianTranslation: 'Ровно $normHour:00',
          explanation:
              'Час в иврите — женского рода (שָׁעָה), поэтому числительные всегда женского рода (אַחַת, שְׁתַּיִם, שָׁלוֹשׁ). בְּדִיּוּק означает «ровно / точно».',
        );
      case 15:
        return TimePhrase(
          hour: normHour,
          minute: 15,
          hebrewPhrase: '$currHourHeb וָרֶבַע',
          transliteration: '$currHourTr va-reva',
          russianTranslation: '$normHour с четвертью ($normHour:15)',
          explanation:
              '«И четверть» на иврите передается союзом וָרֶבַע (ва-рева). Буква вав огласуется камацем перед словом רֶבַע.',
        );
      case 30:
        return TimePhrase(
          hour: normHour,
          minute: 30,
          hebrewPhrase: '$currHourHeb וָחֵצִי',
          transliteration: '$currHourTr va-chetzi',
          russianTranslation: 'Половина следующего / $normHour:30',
          explanation:
              '«И половина» — וָחֵצִי (ва-хеци). В отличие от русского языка («полчетвертого»), в иврите называют ТЕКУЩИЙ час плюс половина: שָׁלוֹשׁ וָחֵצִי = 3:30.',
        );
      case 45:
        return TimePhrase(
          hour: normHour,
          minute: 45,
          hebrewPhrase: 'רֶבַע לְ$nextHourHeb',
          transliteration: 'Reva le-$nextHourTr',
          russianTranslation: 'Без четверти $nextHour ($normHour:45)',
          explanation:
              'Формула «без четверти»: сначала слово רֶבַע (четверть) + предлог направления לְ... + СЛЕДУЮЩИЙ час: רֶבַע לְאַרְבַּע (без четверти четыре).',
        );
      case 10:
        return TimePhrase(
          hour: normHour,
          minute: 10,
          hebrewPhrase: '$currHourHeb וַעֲשָׂרָה',
          transliteration: '$currHourTr va-asara',
          russianTranslation: 'Десять минут следующего ($normHour:10)',
          explanation:
              'Минуты мужского рода (דַּקָּה в разговорной речи сокращается до числительного мужского рода: עֲשָׂרָה).',
        );
      case 20:
        return TimePhrase(
          hour: normHour,
          minute: 20,
          hebrewPhrase: '$currHourHeb וְעֶשְׂרִים',
          transliteration: '$currHourTr ve-esrim',
          russianTranslation: 'Двадцать минут следующего ($normHour:20)',
          explanation: 'Число 20 на иврите עֶשְׂרִים.',
        );
      case 40:
        return TimePhrase(
          hour: normHour,
          minute: 40,
          hebrewPhrase: 'עֶשְׂרִים לְ$nextHourHeb',
          transliteration: 'Esrim le-$nextHourTr',
          russianTranslation: 'Без двадцати $nextHour ($normHour:40)',
          explanation: 'Двадцать минут ДО следующего часа.',
        );
      case 50:
        return TimePhrase(
          hour: normHour,
          minute: 50,
          hebrewPhrase: 'עֲשָׂרָה לְ$nextHourHeb',
          transliteration: 'Asara le-$nextHourTr',
          russianTranslation: 'Без десяти $nextHour ($normHour:50)',
          explanation: 'Десять минут ДО следующего часа.',
        );
      default:
        return TimePhrase(
          hour: normHour,
          minute: minute,
          hebrewPhrase: '$currHourHeb וְ$minute',
          transliteration: '$currHourTr ve-$minute',
          russianTranslation: '$normHour:$minute',
          explanation: 'Стандартный формат времени.',
        );
    }
  }

  static final List<NumberQuizQuestion> quizQuestions = [
    const NumberQuizQuestion(
      id: 'nq_1',
      questionPrompt: 'Как правильно сказать: «Три шекеля» (שֶׁקֶל — м.р.)?',
      correctAnswer: 'שְׁלוֹשָׁה שְׁקָלִים',
      options: [
        'שְׁלוֹשָׁה שְׁקָלִים',
        'שָׁלוֹשׁ שְׁקָלִים',
        'שְׁלוֹשֶׁת שְׁקָלִים',
        'שְׁלוֹשׁ שֶׁקֶל',
      ],
      explanation:
          'ПАРАДОКС РОДА: С существительными мужского рода числительное 3 имеет окончание -а: שְׁלוֹשָׁה שְׁקָלִים!',
      audioPrompt: 'שְׁלוֹשָׁה שְׁקָלִים',
    ),
    const NumberQuizQuestion(
      id: 'nq_2',
      questionPrompt: 'Как сказать: «Четыре девочки» (יַלְדָּה — ж.р.)?',
      correctAnswer: 'אַרְבַּע יְלָדוֹת',
      options: [
        'אַרְבַּע יְלָדוֹת',
        'אַרְבָּעָה יְלָדוֹת',
        'אַרְבַּעַת יְלָדוֹת',
        'אַרְבַּע יַלְדָּה',
      ],
      explanation:
          'С существительными женского рода числительное 4 используется в женском роде БЕЗ окончания ה: אַרְבַּע יְלָדוֹת.',
      audioPrompt: 'אַרְבַּע יְלָדוֹת',
    ),
    const NumberQuizQuestion(
      id: 'nq_3',
      questionPrompt: 'Как сказать на иврите: «3:30» (полчетвертого)?',
      correctAnswer: 'שָׁלוֹשׁ וָחֵצִי',
      options: [
        'שָׁלוֹשׁ וָחֵצִי',
        'אַרְבַּע וָחֵצִי',
        'חֲצִי לְאַרְבַּע',
        'שְׁלוֹשָׁה וָחֵצִי',
      ],
      explanation:
          'В иврите называют текущий час + половину: שָׁלוֹשׁ וָחֵצִי. Часы всегда в женском роде (שָׁלוֹשׁ, а не שְׁלוֹשָׁה).',
      audioPrompt: 'שָׁלוֹשׁ וָחֵצִי',
    ),
    const NumberQuizQuestion(
      id: 'nq_4',
      questionPrompt: 'Как сказать: «2:15» (два с четвертью)?',
      correctAnswer: 'שְׁתַּיִם וָרֶבַע',
      options: [
        'שְׁתַּיִם וָרֶבַע',
        'שְׁנַיִם וָרֶבַע',
        'שְׁתֵּי וָרֶבַע',
        'רֶבַע לִשְׁתַּיִם',
      ],
      explanation:
          'Час «два» в женском роде — שְׁתַּיִם. С четвертью — וָרֶבַע. Итого: שְׁתַּיִם וָרֶבַע.',
      audioPrompt: 'שְׁתַּיִם וָרֶבַע',
    ),
    const NumberQuizQuestion(
      id: 'nq_5',
      questionPrompt: 'Как сказать: «3:45» (без четверти четыре)?',
      correctAnswer: 'רֶבַע לְאַרְבַּע',
      options: [
        'רֶבַע לְאַרְבַּע',
        'שָׁלוֹשׁ וְרֶבַע',
        'רֶבַע לִשְׁלוֹשׁ',
        'אַרְבַּע פָּחוֹת רֶבַע',
      ],
      explanation:
          'Формула «без четверти» строится как «четверть К следующему часу»: רֶבַע לְאַרְבַּע.',
      audioPrompt: 'רֶבַע לְאַרְבַּע',
    ),
    const NumberQuizQuestion(
      id: 'nq_6',
      questionPrompt: 'Слово שָׁנָה (год) женского рода. Как правильно сказать «5 лет»?',
      correctAnswer: 'חָמֵשׁ שָׁנִים',
      options: [
        'חָמֵשׁ שָׁנִים',
        'חֲמִשָּׁה שָׁנִים',
        'חֲמֵשֶׁת שָׁנִים',
        'חָמֵשׁ שָׁנָה',
      ],
      explanation:
          'Хотя множественное число שָׁנִים имеет окончание -им, грамматический род слова שָׁנָה — женский! Поэтому חָמֵשׁ שָׁנִים.',
      audioPrompt: 'חָמֵשׁ שָׁנִים',
    ),
  ];
}
