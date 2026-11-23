import '../../domain/entities/easy_hebrew_article.dart';

/// Seed data containing adapted easy Hebrew news articles based on Israel Kan Reka format.
final class EasyHebrewNewsSeedData {
  const EasyHebrewNewsSeedData._();

  static const List<EasyHebrewArticle> articles = [
    // -------------------------------------------------------------------------
    // Article 1: Solar Energy in Negev (High-Tech)
    // -------------------------------------------------------------------------
    EasyHebrewArticle(
      id: 'news_1_solar_negev',
      titleHebrewWithNikkud: 'סְטַארְטְאַפּ יִשְׂרְאֵלִי פִּתֵּחַ אֶנֶרְגְּיָה סוֹלָארִית חֲדָשָׁה בְּמִדְבַּר הַנֶּגֶב',
      titleHebrewNormalized: 'סטארטאפ ישראלי פיתח אנרגיה סולארית חדשה במדבר הנגב',
      titleRu: 'Израильский стартап разработал новую солнечную энергию в пустыне Негев',
      category: NewsCategory.hightech,
      readingLevelRu: 'Алеф+',
      dateString: 'הַיּוֹם • 23.11.2026',
      readingMinutes: 3,
      summaryRu: 'Новая экологическая технология позволяет накапливать солнечный свет в песке даже ночью.',
      paragraphs: [
        NewsParagraph(
          index: 0,
          hebrewWithNikkud:
              'חֶבְרַת הַזְּנֵק (סְטַארְטְאַפּ) מִבְּאֵר שֶׁבַע הוֹדִיעָה הַבֹּקֶר עַל פִּתּוּחַ חָדָשׁ שֶׁל פָּנֶלִים סוֹלָארִיִּים יְרֻקִּים.',
          hebrewNormalized:
              'חברת ההזנק (סטארטאפ) מבאר שבע הודיעה הבוקר על פיתוח חדש של פנלים סולאריים ירוקים.',
          translationRu:
              'Стартап из Беэр-Шевы объявил сегодня утром о новой разработке зеленых солнечных панелей.',
        ),
        NewsParagraph(
          index: 1,
          hebrewWithNikkud:
              'הַטֶּכְנוֹלוֹגְיָה שׁוֹמֶרֶת אֶת חֹם הַשֶּׁמֶשׁ בְּתוֹךְ חוֹל הַמִּדְבָּר וּמְיַצֶּרֶת חַשְׁמַל גַּם בַּלַּיְלָה לְלֹא זִהוּם אֲוִיר.',
          hebrewNormalized:
              'הטכנולוגיה שומרת את חום השמש בתוך חול המדבר ומייצרת חשמל גם בלילה ללא זיהום אוויר.',
          translationRu:
              'Технология сохраняет солнечное тепло в пустынном песке и вырабатывает электричество даже ночью без загрязнения воздуха.',
        ),
        NewsParagraph(
          index: 2,
          hebrewWithNikkud:
              'רֹאשׁ עִירִיַּת בְּאֵר שֶׁבַע אָמַר: ״זֶהוּ צַעַד עֲנָק לְמַעַן הַסְּבִיבָה וְעָתִיד הַנֶּגֶב״.',
          hebrewNormalized:
              'ראש עיריית באר שבע אמר: "זהו צעד ענק למען הסביבה ועתיד הנגב".',
          translationRu:
              'Мэр Беэр-Шевы сказал: «Это гигантский шаг ради окружающей среды и будущего Негева».',
        ),
      ],
      vocabulary: [
        NewsWordVocabulary(
          hebrewWithNikkud: 'חֶבְרַת הַזְנֵק',
          hebrewNormalized: 'חברת הזנק',
          translationRu: 'стартап',
          root: 'ז-נ-ק',
        ),
        NewsWordVocabulary(
          hebrewWithNikkud: 'פִּתּוּחַ',
          hebrewNormalized: 'פיתוח',
          translationRu: 'разработка, развитие',
          root: 'פ-ת-ח',
        ),
        NewsWordVocabulary(
          hebrewWithNikkud: 'זִהוּם אֲוִיר',
          hebrewNormalized: 'זיהום אוויר',
          translationRu: 'загрязнение воздуха',
          root: 'ז-ה-ם',
        ),
        NewsWordVocabulary(
          hebrewWithNikkud: 'סְבִיבָה',
          hebrewNormalized: 'סביבה',
          translationRu: 'окружающая среда',
          root: 'ס-ב-ב',
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // Article 2: Dead Sea Scrolls in Jerusalem (Culture)
    // -------------------------------------------------------------------------
    EasyHebrewArticle(
      id: 'news_2_scrolls_museum',
      titleHebrewWithNikkud: 'תַּעֲרוּכָה חֲדָשָׁה בְּמוּזֵיאוֹן יִשְׂרָאֵל: תַּגְלִיּוֹת מְגִלּוֹת יַם הַמֶּלַח',
      titleHebrewNormalized: 'תערוכה חדשה במוזיאון ישראל: תגליות מגילות ים המלח',
      titleRu: 'Новая выставка в Музее Израиля: открытия Свитков Мёртвого моря',
      category: NewsCategory.culture,
      readingLevelRu: 'Бет',
      dateString: 'אֶתְמוֹל • 22.11.2026',
      readingMinutes: 3,
      summaryRu: 'Редкие древние фрагменты свитков выставлены в Храме Книги в Иерусалиме с цифровой микроскопией.',
      paragraphs: [
        NewsParagraph(
          index: 0,
          hebrewWithNikkud:
              'מוּזֵיאוֹן יִשְׂרָאֵל בִּירוּשָׁלַיִם פָּתַח הַשָּׁבוּעַ תַּעֲרוּכָה מְיֻחֶדֶת בְּהֵיכַל הַסֵּפֶר.',
          hebrewNormalized:
              'מוזיאון ישראל בירושלים פתח השבוע תערוכה מיוחדת בהיכל הספר.',
          translationRu:
              'Музей Израиля в Иерусалиме открыл на этой неделе специальную выставку в Храме Книги.',
        ),
        NewsParagraph(
          index: 1,
          hebrewWithNikkud:
              'הַמְּבַקְּרִים יְכוֹלִים לִרְאוֹת טֶקְסְטִים עַתִּיקִים בִּכְתָב עִבְרִי קַדְמוֹן בְּאֶמְצָעוּת מִסָּכִים דִּיגִיטָלִיִּים חֲדָשִׁים.',
          hebrewNormalized:
              'המבקרים יכולים לראות טקסטים עתיקים בכתב עברי קדמון באמצעות מסכים דיגיטליים חדשים.',
          translationRu:
              'Посетители могут увидеть древние тексты на древнем еврейском письме с помощью новых цифровых экранов.',
        ),
      ],
      vocabulary: [
        NewsWordVocabulary(
          hebrewWithNikkud: 'תַּעֲרוּכָה',
          hebrewNormalized: 'תערוכה',
          translationRu: 'выставка',
          root: 'ע-ר-ך',
        ),
        NewsWordVocabulary(
          hebrewWithNikkud: 'מְבַקְּרִים',
          hebrewNormalized: 'מבקרים',
          translationRu: 'посетители, гости',
          root: 'ב-ק-ר',
        ),
        NewsWordVocabulary(
          hebrewWithNikkud: 'עַתִּיק',
          hebrewNormalized: 'עתיק',
          translationRu: 'древний, старинный',
          root: 'ע-ת-ק',
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // Article 3: First Snow on Mount Hermon (Weather)
    // -------------------------------------------------------------------------
    EasyHebrewArticle(
      id: 'news_3_hermon_snow',
      titleHebrewWithNikkud: 'סְעָרָה חָרְפִּית רִאשׁוֹנָה בַּגָּלִיל: הַשֶּׁלֶג חָזַר לַחֶרְמוֹן',
      titleHebrewNormalized: 'סערה חורפית ראשונה בגליל: השלג חזר לחרמון',
      titleRu: 'Первая зимняя буря в Галилее: снег вернулся на Хермон',
      category: NewsCategory.weather,
      readingLevelRu: 'Алеф+',
      dateString: 'לִפְנֵי 2 יָמִים',
      readingMinutes: 2,
      summaryRu: 'Обильные дожди наполнили ручьи севера, а на вершине горы выпало 15 сантиметров свежего снега.',
      paragraphs: [
        NewsParagraph(
          index: 0,
          hebrewWithNikkud:
              'מֶזֶג הָאֲוִיר הַחָרְפִּי הִגִּיעַ לְיִשְׂרָאֵל עִם גְּשָׁמִים חֲזָקִים בַּצָּפוֹן וּבַמֶּרְכָּז.',
          hebrewNormalized:
              'מזג האוויר החורפי הגיע לישראל עם גשמים חזקים בצפון ובמרכז.',
          translationRu:
              'Зимняя погода пришла в Израиль с сильными дождями на севере и в центре.',
        ),
        NewsParagraph(
          index: 1,
          hebrewWithNikkud:
              'בְּהַר הַחֶרְמוֹן יָרַד שֶׁלֶג רִאשׁוֹן לָעוֹנָה, וְהַטֶּמְפֶּרָטוּרוֹת יָרְדוּ מִתַּחַת לָאֶפֶס.',
          hebrewNormalized:
              'בהר החרמון ירד שלג ראשון לעונה, והטמפרטורות ירדו מתחת לאפס.',
          translationRu:
              'На горе Хермон выпал первый снег в сезоне, а температура опустилась ниже нуля.',
        ),
      ],
      vocabulary: [
        NewsWordVocabulary(
          hebrewWithNikkud: 'סְעָרָה',
          hebrewNormalized: 'סערה',
          translationRu: 'буря, шторм',
          root: 'ס-ע-ר',
        ),
        NewsWordVocabulary(
          hebrewWithNikkud: 'גְּשָׁמִים',
          hebrewNormalized: 'גשמים',
          translationRu: 'дожди',
          root: 'ג-ש-ם',
        ),
        NewsWordVocabulary(
          hebrewWithNikkud: 'עוֹנָה',
          hebrewNormalized: 'עונה',
          translationRu: 'сезон, время года',
          root: 'ע-ו-נ',
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // Article 4: Fast Train Jerusalem - Tel Aviv (Society)
    // -------------------------------------------------------------------------
    EasyHebrewArticle(
      id: 'news_4_fast_train',
      titleHebrewWithNikkud: 'רַכֶּבֶת יִשְׂרָאֵל פּוֹתַחַת קַו מָהִיר חָדָשׁ בֵּין יְרוּשָׁלַיִם לְתֵל אָבִיב',
      titleHebrewNormalized: 'רכבת ישראל פותחת קו מהיר חדש בין ירושלים לתל אביב',
      titleRu: 'Поезд Израиля открывает новый экспресс-маршрут между Иерусалимом и Тель-Авивом',
      category: NewsCategory.society,
      readingLevelRu: 'Алеф+',
      dateString: 'הַשָּׁבוּעַ',
      readingMinutes: 2,
      summaryRu: 'Время в пути сокращается до 28 минут благодаря новым двухэтажным электропоездам.',
      paragraphs: [
        NewsParagraph(
          index: 0,
          hebrewWithNikkud:
              'רַכֶּבֶת יִשְׂרָאֵל מְבַשֶּׂרֶת עַל שִׁפְרוּר מַשְׁמָעוּתִי בַּשֵּׁרוּת: זְמַן הַנְּסִיעָה יִתְקַצֵּר לְעֶשְׂרִים וּשְׁמוֹנֶה דַּקּוֹת בִּלְבַד.',
          hebrewNormalized:
              'רכבת ישראל מבשרת על שיפור משמעותי בשירות: זמן הנסיעה יתקצר לעשרים ושמונה דקות בלבד.',
          translationRu:
              '«Ракевет Исраэль» сообщает о значительном улучшении сервиса: время поездки сократится всего до 28 минут.',
        ),
        NewsParagraph(
          index: 1,
          hebrewWithNikkud:
              'הַנּוֹסְעִים יֵהָנוּ מֵאִינְטֶרְנֶט מָהִיר חִנָּם וּמֵעֶמְדּוֹת טְעִינָה לְכָל כִּסֵּא.',
          hebrewNormalized:
              'הנוסעים ייהנו מאינטרנט מהיר חינם ומעמדות טעינה לכל כיסא.',
          translationRu:
              'Пассажиры смогут пользоваться бесплатным быстрым интернетом и зарядными станциями у каждого кресла.',
        ),
      ],
      vocabulary: [
        NewsWordVocabulary(
          hebrewWithNikkud: 'שִׁפְרוּר / שִׁפּוּר',
          hebrewNormalized: 'שיפור',
          translationRu: 'улучшение',
          root: 'ש-פ-ר',
        ),
        NewsWordVocabulary(
          hebrewWithNikkud: 'מַשְׁמָעוּתִי',
          hebrewNormalized: 'משמעותי',
          translationRu: 'значительный, существенный',
          root: 'ש-מ-ע',
        ),
        NewsWordVocabulary(
          hebrewWithNikkud: 'עֶמְדַּת טְעִינָה',
          hebrewNormalized: 'עמדת טעינה',
          translationRu: 'зарядная станция',
          root: 'ט-ע-נ',
        ),
      ],
    ),
  ];
}
