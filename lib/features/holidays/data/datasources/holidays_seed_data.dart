import '../../domain/entities/holiday_scenario.dart';
import '../../domain/entities/jewish_holiday.dart';
import '../../domain/entities/shabbat_survival_rule.dart';

/// Seed data for Israeli Shabbat lifestyle, holiday calendar, greeting etiquette, and cultural customs.
final class HolidaysSeedData {
  const HolidaysSeedData._();

  /// 4 stages of Shabbat rhythm in Israel.
  static const List<ShabbatRule> shabbatStages = [
    ShabbatRule(
      id: 'shabbat_1_friday_prep',
      titleRu: 'Пятница: Суета и Подготовка',
      hebrewTitleWithNikkud: 'יוֹם שִׁישִׁי וְהַכָּנוֹת לְשַׁבָּת',
      transcriptionRu: 'Yom Shishí ve-Hachanót le-Shabát',
      timeWindowRu: 'Пятница с утра до 14:00–15:00',
      descriptionRu:
          'Улицы и рынки бурлят: все покупают свежие плетеные халы (חַלּוֹת), цветы к шаббату (פְּרָחִים) и продукты. В воздухе запах свежей выпечки и кофе.',
      transportAndShopsRu:
          'Супермаркеты и рынки закрываются рано (к 14:00–15:00). Общественный транспорт (автобусы и поезда) прекращает работу за 2–3 часа до заката.',
      etiquetteTipRu:
          'Всем встречным, продавцам и коллегам уже с утра пятницы говорят: «שַׁבָּת שָׁלוֹם!» (Шабба́т Шало́м!) или «סוֹפַ״שׁ נָעִים!» (Хороших выходных!).',
      iconEmoji: '🥖',
    ),
    ShabbatRule(
      id: 'shabbat_2_knisat_shabbat',
      titleRu: 'Заход субботы (Книсат Шаббат)',
      hebrewTitleWithNikkud: 'כְּנִיסַת שַׁבָּת',
      transcriptionRu: 'Knisát Shabát',
      timeWindowRu: 'За 20 минут до заката солнца',
      descriptionRu:
          'В городах воцаряется тишина. В религиозных районах звучит сирена захода субботы. Зажигают шаббатние свечи, семьи собираются за праздничным столом с кидушем.',
      transportAndShopsRu:
          'Государственный транспорт полностью остановлен. Работают только службы такси (Gett), дежурные аптеки, а в Тель-Авиве и Гуш-Дане — бесплатные городские автобусы «נעים בסופ״ש».',
      etiquetteTipRu:
          'Не въезжайте на автомобиле в ультраортодоксальные районы (Бней-Брак, Меа Шеарим) — улицы перекрыты шлагбаумами.',
      iconEmoji: '🕯️',
    ),
    ShabbatRule(
      id: 'shabbat_3_saturday_day',
      titleRu: 'День субботы: Отдых и Хамин',
      hebrewTitleWithNikkud: 'יוֹם הַשַּׁבָּת',
      transcriptionRu: 'Yom ha-Shabát',
      timeWindowRu: 'Суббота с утра до заката',
      descriptionRu:
          'День абсолютного отдыха (מְנוּחָה). Светские израильтяне гуляют в национальных парках, едут на море и пляжи. Традиционное субботнее блюдо — чолнт / хамин (חַמִּין), томившийся всю ночь.',
      transportAndShopsRu:
          'Большинство торговых центров закрыты. В светских районах (набережные, порты Тель-Авива и Герцлии) работают кафе, рестораны и круглосуточные киоски (פיצוציות).',
      etiquetteTipRu:
          'Прекрасное время для неспешных прогулок и встреч с друзьями («לָשֶׁבֶת עִם חֲבֵרִים»).',
      iconEmoji: '☀️',
    ),
    ShabbatRule(
      id: 'shabbat_4_motzash_havdalah',
      titleRu: 'Исход субботы (Моцей Шаббат — Моца״ш)',
      hebrewTitleWithNikkud: 'מוֹצָאֵי שַׁבָּת (מוֹצָ״שׁ)',
      transcriptionRu: 'Motza\'éy Shabát (Motzásh)',
      timeWindowRu: 'Суббота через ~40 минут после захода солнца',
      descriptionRu:
          'С появлением трех первых звезд суббота завершается церемонией Авдалы (הַבְדָּלָה — разделение между святым днем и буднями) с бокалом вина, свечой и ароматными пряностями.',
      transportAndShopsRu:
          'Вновь начинают ходить поезда и рейсовые автобусы. Торговые центры (каньоны) и супермаркеты открываются на вечерний шоппинг до 23:00.',
      etiquetteTipRu:
          'В Моцаш и в течение всего воскресенья люди желают друг другу: «שָׁבוּעַ טוֹב!» (Шаву́а тов! — Доброй недели!).',
      iconEmoji: '✨',
    ),
  ];

  /// 8 major Israeli holidays & national remembrance days.
  static const List<JewishHoliday> jewishHolidays = [
    JewishHoliday(
      id: 'hol_1_rosh_hashanah',
      season: HolidaySeason.autumn,
      hebrewNameWithNikkud: 'רֹאשׁ הַשָּׁנָה',
      hebrewNamePlain: 'ראש השנה',
      transcriptionRu: 'Rosh ha-Shaná',
      russianTitle: 'Еврейский Новый год',
      monthHebrew: 'תִּשְׁרֵי (Тишрей — сентябрь/октябрь)',
      greetingHebrewWithNikkud: 'שָׁנָה טוֹבָה וּמְתוּקָה!',
      greetingTranscriptionRu: 'Shaná Tová u-Metuká!',
      greetingRussian: 'Хорошего и сладкого года!',
      customsAndFoodRu:
          'Яблоки, обмакнутые в мёд (תַּפּוּחַ בִּדְבַשׁ), гранат (רִמּוֹן) с пожеланием множества добрых дел, голова рыбы («чтобы быть во главе, а не в хвосте») и трубление в рог — шофар (שׁוֹפָר).',
      modernIsraeliRealityRu:
          'Два официальных выходных дня. Все дарят друг другу подарочные корзины и сертификаты от работодателей (תָּוֵי שַׁי).',
      iconEmoji: '🍏',
    ),
    JewishHoliday(
      id: 'hol_2_yom_kippur',
      season: HolidaySeason.autumn,
      hebrewNameWithNikkud: 'יוֹם כִּפּוּר',
      hebrewNamePlain: 'יום כיפור',
      transcriptionRu: 'Yom Kipúr',
      russianTitle: 'Судный день',
      monthHebrew: 'תִּשְׁרֵי (10-е Тишрея)',
      greetingHebrewWithNikkud: 'גְּמַר חֲתִימָה טוֹבָה וְצוֹם קַל!',
      greetingTranscriptionRu: 'Gmar Chatimá Tová ve-Tzom Kal!',
      greetingRussian: 'Доброй записи в Книге Жизни и легкого поста!',
      customsAndFoodRu:
          '25-часовой строгий сухой пост (צוֹם), белые одежды, молитвы раскаяния (סְלִיחוֹת).',
      modernIsraeliRealityRu:
          'Уникальный феномен: в стране полностью замирает движение транспорта, не работают аэропорты, ТВ и радио. Все автомагистрали (включая шоссе Аялон) заполняются тысячами детей и взрослых на велосипедах («חַג הָאוֹפַנַּיִם»). Не принято желать «חג שמח»!',
      iconEmoji: '🚲',
    ),
    JewishHoliday(
      id: 'hol_3_sukkot',
      season: HolidaySeason.autumn,
      hebrewNameWithNikkud: 'סֻכּוֹת',
      hebrewNamePlain: 'סוכות',
      transcriptionRu: 'Sukót',
      russianTitle: 'Праздник Кущей (Суккот)',
      monthHebrew: 'תִּשְׁרֵי (15-е Тишрея)',
      greetingHebrewWithNikkud: 'חַג סֻכּוֹת שָׂמֵחַ! / מוֹעֲדִים לְשִׂמְחָה!',
      greetingTranscriptionRu: 'Chag Sukót Samé\'ach! / Mo\'adím le-Simchá!',
      greetingRussian: 'Веселого Суккота! Радостных праздников!',
      customsAndFoodRu:
          'Строительство шалашей (סֻכָּה) во дворах и на балконах под открытым небом с крышей из пальмовых ветвей (סְכָךְ), благословение 4 видов растений (אַרְבַּעַת הַמִּינִים: лулав, этрог, мирт, ива).',
      modernIsraeliRealityRu:
          'Неделя каникул для школ и полувыходных на работе (חֻל הַמּוֹעֵד — холь ха-моэд). Страна наводнена фестивалями, походами и ярмарками.',
      iconEmoji: '🛖',
    ),
    JewishHoliday(
      id: 'hol_4_hanukkah',
      season: HolidaySeason.winter,
      hebrewNameWithNikkud: 'חֲנֻכָּה',
      hebrewNamePlain: 'חנוכה',
      transcriptionRu: 'Chanuká',
      russianTitle: 'Праздник огней (Ханука)',
      monthHebrew: 'כִּסְלֵו (Кислев — декабрь)',
      greetingHebrewWithNikkud: 'חַג אוּרִים שָׂמֵחַ!',
      greetingTranscriptionRu: 'Chag Urím Samé\'ach!',
      greetingRussian: 'Веселого праздника огней!',
      customsAndFoodRu:
          'Зажигание ханукальных свечей 8 дней подряд (חֲנֻכִּיָּה), поедание пончиков с джемом (סֻפְגָּנִיּוֹת), картофельных оладий (לְבִיבוֹת / латкес) и игра в волчок (סְבִיבוֹן).',
      modernIsraeliRealityRu:
          'В витринах всех израильских пекарен появляются сотни видов изысканных суфганиет с фисташками, шоколадом и кремом. Школьные каникулы и детские спектакли (פֶסְטִיגָל).',
      iconEmoji: '🍩',
    ),
    JewishHoliday(
      id: 'hol_5_purim',
      season: HolidaySeason.spring,
      hebrewNameWithNikkud: 'פּוּרִים',
      hebrewNamePlain: 'פורים',
      transcriptionRu: 'Purím',
      russianTitle: 'Праздник радости и спасения (Пурим)',
      monthHebrew: 'אֲדָר (Адар — февраль/март)',
      greetingHebrewWithNikkud: 'חַג פּוּרִים שָׂמֵחַ!',
      greetingTranscriptionRu: 'Chag Purím Samé\'ach!',
      greetingRussian: 'Веселого Пурима!',
      customsAndFoodRu:
          'Чтение свитка Эстер (מְגִלַּת אֶסְתֵּר), карнавальные костюмы (תַּחְפֹּשׂוֹת), угощение «Уши Амана» с маком или шоколадом (אָזְנֵי הָמָן), посылка сладких подарков друзьям (מִשְׁלוֹחַ מָנוֹת) и благотворительность.',
      modernIsraeliRealityRu:
          'Самый безудержно веселый день года: грандиозный уличный карнавал Адлояда (עַדְלָיָדָע), вечеринки в костюмах во всех барах Тель-Авива и Иерусалима.',
      iconEmoji: '🎭',
    ),
    JewishHoliday(
      id: 'hol_6_passover',
      season: HolidaySeason.spring,
      hebrewNameWithNikkud: 'פֶּסַח',
      hebrewNamePlain: 'פסח',
      transcriptionRu: 'Pésach',
      russianTitle: 'Песах (Праздник свободы)',
      monthHebrew: 'נִיסָן (Нисан — март/апрель)',
      greetingHebrewWithNikkud: 'חַג פֶּסַח כָּשֵׁר וְשָׂמֵחַ!',
      greetingTranscriptionRu: 'Chag Pésach Kashér ve-Samé\'ach!',
      greetingRussian: 'Кошерного и веселого Песаха!',
      customsAndFoodRu:
          'Полный запрет на квасное (חָמֵץ: хлеб, пиво, макароны), употребление пресной мацы (מַצָּה), праздничная пасхальная трапеза с чтением Агады (לֵיל הַסֵּדֶר) и поиском спрятанного афикомана (אֲפִיקוֹמָן).',
      modernIsraeliRealityRu:
          'В супермаркетах отделы с хлебом и мучными изделиями запечатываются пленкой. Весенняя генеральная уборка в домах («נִקְיוֹנוֹת פֶּסַח»). Недельные каникулы.',
      iconEmoji: '🍷',
    ),
    JewishHoliday(
      id: 'hol_7_yom_hazikaron',
      season: HolidaySeason.nationalDays,
      hebrewNameWithNikkud: 'יוֹם הַזִּכָּרוֹן',
      hebrewNamePlain: 'יום הזיכרון',
      transcriptionRu: 'Yom ha-Zikarón',
      russianTitle: 'День памяти павших воинов и жертв террора',
      monthHebrew: 'אִיָּר (Ияр — апрель/май)',
      greetingHebrewWithNikkud: 'יְהִי זִכְרָם בָּרוּךְ.',
      greetingTranscriptionRu: 'Yehí zichrám barúch.',
      greetingRussian: 'Да будет благословенна их память.',
      customsAndFoodRu:
          'Всеобщая сирена (צְפִירָה): в 20:00 вечера (1 минута) и в 11:00 утра (2 минуты). Вся страна замирает на месте — машины останавливаются на трассах, водители выходят и стоят по стойке смирно.',
      modernIsraeliRealityRu:
          'Один из самых эмоционально объединяющих дней в израильском обществе. Закрыты все увеселительные заведения и рестораны. На следующий вечер день памяти мгновенно сменяется Днем Независимости.',
      iconEmoji: '🕯️',
    ),
    JewishHoliday(
      id: 'hol_8_yom_haatzmaut',
      season: HolidaySeason.nationalDays,
      hebrewNameWithNikkud: 'יוֹם הָעַצְמָאוּת',
      hebrewNamePlain: 'יום העצמאות',
      transcriptionRu: 'Yom ha-Atzma\'út',
      russianTitle: 'День Независимости Израиля',
      monthHebrew: 'אִיָּר (Ияр — апрель/май)',
      greetingHebrewWithNikkud: 'חַג עַצְמָאוּת שָׂמֵחַ!',
      greetingTranscriptionRu: 'Chag Atzma\'út Samé\'ach!',
      greetingRussian: 'С Днем Независимости!',
      customsAndFoodRu:
          'Всенародный барбекю / шашлыки в парках и на природе (מַנְגָּל), авиапарад ВВС Израиля в небе (מַטָּס חֵיל הָאֲוִיר), салюты и развешивание израильских флагов на всех окнах и машинах.',
      modernIsraeliRealityRu:
          'Официальный выходной день. Парки заполняются семьями с переносными мангалами с раннего утра.',
      iconEmoji: '🇮🇱',
    ),
  ];

  /// 5 realistic greeting etiquette and cultural situation scenarios.
  static const List<HolidayScenarioQuestion> holidayScenarios = [
    HolidayScenarioQuestion(
      id: 'scen_1_friday_office_leave',
      situationRu: 'Пятница 13:00, ты уходишь из офиса на выходные',
      interlocutorRoleRu: 'Коллега по команде / Босс',
      speechHebrewWithNikkud: 'הַי, סִיַּמְנוּ אֶת הַשָּׁבוּעַ! שַׁבָּת שָׁלוֹם וְסוֹפַ״שׁ מְצֻיָּן.',
      speechHebrewPlain: 'הי, סיימנו את השבוע! שבת שלום וסופ״ש מצוין.',
      transcriptionRu: 'Hay, siyámnu et ha-shavú\'a! Shabát Shalóm ve-sofásh metzuyán.',
      translationRu: 'Привет, мы закончили неделю! Шаббат шалом и отличных выходных.',
      etiquetteTipRu:
          'Ответь тепло и взаимно: «שַׁבָּת שָׁלוֹם, תֵּהָנוּ בַּסּוֹפַ״שׁ!» (Шаббат шалом, наслаждайтесь выходными!).',
      responseOptions: [
        'שַׁבָּת שָׁלוֹם גַּם לְךָ! סוֹפַ״שׁ רָגוּעַ וּמְנוּחָה נְעִימָה.',
        'לָמָּה שַׁבָּת? אֲנִי מַמְשִׁיךְ לַעֲבֹד בַּמִּשְׂרָד עַד יוֹם רִאשׁוֹן בַּבֹּקֶר.',
        'אֲנִי לֹא מֵגִיב לִבְרָכוֹת שֶׁל סוֹף שָׁבוּעַ.',
      ],
      bestOptionIndex: 0,
      explanationRu:
          '«שבת שלום, סופ״ש רגוע ומנוחה נעימה» — классическое дружелюбное пожелание в израильском коллективе.',
    ),
    HolidayScenarioQuestion(
      id: 'scen_2_yom_kippur_greeting',
      situationRu: 'Канун Йом Кипура (Эрев Йом Кипур) в лифте с соседом',
      interlocutorRoleRu: 'Сосед по дому (שָׁכֵן בַּבִּנְיָן)',
      speechHebrewWithNikkud: 'שָׁלוֹם שָׁכֵן! גְּמַר חֲתִימָה טוֹבָה וְצוֹם קַל לְךָ וּלְכָל הַמִּשְׁפָּחָה.',
      speechHebrewPlain: 'שלום שכן! גמר חתימה טובה וצום קל לך ולכל המשפחה.',
      transcriptionRu: 'Shalom shachén! Gmar chatimá tová ve-tzom kal lekhá u-le-chol ha-mishpachá.',
      translationRu: 'Привет, сосед! Доброй записи в Книге Жизни и легкого поста тебе и всей семье.',
      etiquetteTipRu:
          'В Йом Кипур никогда не говорят «חַג שָׂמֵחַ» (веселого праздника), так как это день строгого самоанализа и поста. Отвечают взаимно: «גְּמַר חֲתִימָה טוֹבָה» или «צוֹם מוֹעִיל».',
      responseOptions: [
        'גְּמַר חֲתִימָה טוֹבָה וְצוֹם קַל גַּם לָכֶם!',
        'חַג שָׂמֵחַ, בּוֹא נַעֲשֶׂה מַנְגָּל עִם סְטֵיקִים בַּגַּג הַיּוֹם.',
        'אֲנִי לֹא צוֹם, לָמָּה אַתָּה מְאַחֵל לִי צִוּוּיִים כָּאֵלֶּה?',
      ],
      bestOptionIndex: 0,
      explanationRu:
          'Даже светские израильтяне, которые не постятся, уважительно отвечают «גמר חתימה טובה וצום קל» из вежливости к соблюдающим пост.',
    ),
    HolidayScenarioQuestion(
      id: 'scen_3_siren_on_highway',
      situationRu: '11:00 утра в День Памяти, ты едешь по трассе и звучит сирена',
      interlocutorRoleRu: 'Дорожная этика (צְפִירַת יוֹם הַזִּכָּרוֹן)',
      speechHebrewWithNikkud: 'נִשְׁמַעַת צְפִירַת יוֹם הַזִּכָּרוֹן בְּמֶשֶׁךְ שְׁתֵּי דַּקּוֹת שְׁלֵמוֹת.',
      speechHebrewPlain: 'נשמעת צפירת יום הזיכרון במשך שתי דקות שלמות.',
      transcriptionRu: 'Nishmá\'at tzfirát Yom ha-Zikarón be-méshech shtéy dakót shlemót.',
      translationRu: 'Звучит сирена Дня Памяти на протяжении двух полных минут.',
      etiquetteTipRu:
          'В Израиле во время сирены памяти все машины на дорогах и автострадах останавливаются на обочине, водители выходят из машин и стоят молча по стойке смирно (עוֹמְדִים דּוֹם).',
      responseOptions: [
        'לַעֲצֹר בִּזְהִירוּת בַּשּׁוּלַיִם, לְכַבּוֹת אֶת הָרַדְיוֹ, לָצֵאת מֵהָרֶכֶב וְלַעֲמֹד דּוֹם.',
        'לִלְחֹץ עַל הַגַּז וְלִצְפֹּר בְּחָזְקָה כְּדֵי לַעֲקֹף אֶת כֻּלָּם.',
        'לְהַגְבִּיר אֶת הַמּוּזִיקָה בָּרֶכֶב וּלְהַמְשִׁיךְ כָּרָגִיל.',
      ],
      bestOptionIndex: 0,
      explanationRu:
          'Остановка машины на обочине и стояние по стойке смирно — священный жест уважения к павшим и национальной памяти всего народа Израиля.',
    ),
    HolidayScenarioQuestion(
      id: 'scen_4_holiday_dinner_gift',
      situationRu: 'Тебя пригласили на праздничный ужин Рош ха-Шана или Песах',
      interlocutorRoleRu: 'Хозяйка дома (בַּעֲלַת הַבַּיִת)',
      speechHebrewWithNikkud: 'שָׁלוֹם! כַּמָּה כֵּיף שֶׁבָּאתֶם לְעֶרֶב הֶחָג. תִּכָּנְסוּ בְּבַקָּשָׁה!',
      speechHebrewPlain: 'שלום! כמה כיף שבאתם לערב החג. תכנסו בבקשה!',
      transcriptionRu: 'Shalom! Káma kéyf she-bátem le-érev ha-chag. Tikansú be-vakashá!',
      translationRu: 'Здравствуйте! Как здорово, что вы пришли на праздничный ужин. Входите, пожалуйста!',
      etiquetteTipRu:
          'В Израиле никогда не приходят на праздничную трапезу с пустыми руками. Всегда приносят красивый букет цветов (פְּרָחִים), коробку шоколада или бутылку кошерного вина.',
      responseOptions: [
        'חַג שָׂמֵחַ וְשָׁנָה טוֹבָה! הֵבֵאנוּ יַיִן מְשֻׁבָּח וּפְרָחִים לְכָבוֹד הֶחָג. תּוֹדָה עַל הַהַזְמָנָה!',
        'בָּאתִי רַק כְּדֵי לֶאֱכֹל בְּחִנָּם כִּי לֹא הָיָה לִי כֹּחַ לְבַשֵּׁל בַּבַּיִת.',
        'לָמָּה הַבַּיִת שֶׁלָּכֶם קָטָן כָּל כָּךְ?',
      ],
      bestOptionIndex: 0,
      explanationRu:
          '«חג שמח, הבאנו יין ופרחים, תודה על ההזמנה» — эталон израильского гостевого этикета.',
    ),
    HolidayScenarioQuestion(
      id: 'scen_5_motzash_greeting',
      situationRu: 'Суббота вечер (Моца״ш), ты встречаешь консьержа или соседа в подъезде',
      interlocutorRoleRu: 'Сосед в подъезде (שָׁכֵן)',
      speechHebrewWithNikkud: 'שָׁבוּעַ טוֹב! אֵיךְ עָבְרָה הַשַּׁבָּת שֶׁלְּךָ?',
      speechHebrewPlain: 'שבוע טוב! איך עברה השבת שלך?',
      transcriptionRu: 'Shavú\'a tov! Eikh avrá ha-Shabát shelkhá?',
      translationRu: 'Доброй недели! Как прошла твоя суббота?',
      etiquetteTipRu:
          'На исходе субботы принято отвечать: «שָׁבוּעַ טוֹב וּמְבֹרָךְ!» (Шаву́а тов у-мевора́х! — Доброй и благословенной недели!).',
      responseOptions: [
        'שָׁבוּעַ טוֹב וּמְבֹרָךְ! הָיְתָה שַׁבָּת רְגוּעָה וּנְעִימָה מְאוֹד.',
        'לֹא רוֹצֶה שָׁבוּעַ טוֹב, מָחָר שׁוּב יוֹם רִאשׁוֹן וַעֲבוֹדָה.',
        'תַּעֲזֹב אוֹתִי, אֲנִי מְמַהֵר לִרְאוֹת טֶלֶוִיזְיָה.',
      ],
      bestOptionIndex: 0,
      explanationRu:
          '«שבוע טוב ומבורך» заряжает позитивом на начало израильской рабочей недели (которая начинается в воскресенье — יום ראשון).',
    ),
  ];

  /// 16 essential Israeli holiday, Shabbat, and cultural tradition terms.
  static const List<Map<String, String>> holidaysGlossary = [
    {
      'hebrew': 'שַׁבָּת שָׁלוֹם',
      'plain': 'שבת שלום',
      'transcription': 'shabát shalóm',
      'translation': 'Мирной субботы! (главное субботнее приветствие)',
      'tip': 'Говорится с утра пятницы и до вечера субботы всем встречным.',
    },
    {
      'hebrew': 'שָׁבוּעַ טוֹב',
      'plain': 'שבוע טוב',
      'transcription': 'shavú\'a tov',
      'translation': 'Доброй недели! (на исходе субботы и в воскресенье)',
      'tip': 'Традиционное пожелание с вечера субботы (моцаш) до полудня воскресенья.',
    },
    {
      'hebrew': 'כְּנִיסַת שַׁבָּת',
      'plain': 'כניסת שבת',
      'transcription': 'knisát shabát',
      'translation': 'Заход субботы (зажжение свечей и остановка транспорта)',
      'tip': 'Наступает за 20-40 минут до заката солнца в пятницу в зависимости от города.',
    },
    {
      'hebrew': 'מוֹצָאֵי שַׁבָּת (מוֹצָ״שׁ)',
      'plain': 'מוצאי שבת (מוצ״ש)',
      'transcription': 'motza\'éy shabát (motzásh)',
      'translation': 'Исход субботы (вечер субботы после появления трех звезд)',
      'tip': 'Время, когда открываются торговые центры и возобновляется транспорт.',
    },
    {
      'hebrew': 'חַג שָׂמֵחַ',
      'plain': 'חג שמח',
      'transcription': 'chag samé\'ach',
      'translation': 'С праздником! (универсальное поздравление)',
      'tip': 'Используется на Песах, Суккот, Пурим, Хануку, Шавуот.',
    },
    {
      'hebrew': 'שָׁנָה טוֹבָה',
      'plain': 'שנה טובה',
      'transcription': 'shaná tová',
      'translation': 'С Новым Годом! (Рош ха-Шана)',
      'tip': 'Полное пожелание: «שָׁנָה טוֹבָה וּמְתוּקָה» (Хорошего и сладкого года!).',
    },
    {
      'hebrew': 'גְּמַר חֲתִימָה טוֹבָה',
      'plain': 'גמר חתימה טובה',
      'transcription': 'gmar chatimá tová',
      'translation': 'Доброй окончательной записи (на Йом Кипур)',
      'tip': 'Пожелание быть записанным в Книгу Жизни; говорят перед Йом Кипуром и до Ошана Раба.',
    },
    {
      'hebrew': 'צוֹם קַל',
      'plain': 'צום קל',
      'transcription': 'tzom kal',
      'translation': 'Легкого поста! (в Йом Кипур и 9 Ава)',
      'tip': 'Традиционное пожелание постящимся людям перед началом сухого поста.',
    },
    {
      'hebrew': 'חֻל הַמּוֹעֵד',
      'plain': 'חול המועד',
      'transcription': 'chol ha-mo\'éd',
      'translation': 'Полупраздничные дни (внутри Песаха и Суккота)',
      'tip': 'Дни, когда разрешена часть работы, но школы закрыты и все путешествуют по стране.',
    },
    {
      'hebrew': 'חַלָּה',
      'plain': 'חלה',
      'transcription': 'chalá',
      'translation': 'Хала (традиционный субботний плетеный хлеб)',
      'tip': 'Покупается свежей в пекарнях и на рынках в пятницу утром (мн.ч. «חַלּוֹת»).',
    },
    {
      'hebrew': 'קִדּוּשׁ',
      'plain': 'קידוש',
      'transcription': 'kidúsh',
      'translation': 'Кидуш (освящение субботы и праздника над бокалом вина)',
      'tip': 'Произносится главой семьи перед началом пятничной вечерней трапезы.',
    },
    {
      'hebrew': 'הַבְדָּלָה',
      'plain': 'הבדלה',
      'transcription': 'havdalá',
      'translation': 'Авдала (обряд разделения святости субботы и будней)',
      'tip': 'Церемония проводов субботы с вином, витой свечой и пряностями (бесамим).',
    },
    {
      'hebrew': 'צְפִירָה',
      'plain': 'צפירה',
      'transcription': 'tzfirá',
      'translation': 'Траурная сирена (в Йом ха-Зикарон и Йом ха-Шоа)',
      'tip': 'Минута всеобщего молчания; весь транспорт останавливается посреди трасс.',
    },
    {
      'hebrew': 'מַנְגָּל',
      'plain': 'מנגל',
      'transcription': 'mangál',
      'translation': 'Мангал / шашлыки на День Независимости',
      'tip': '«לַעֲשׂוֹת מַנְגָּל» — национальное занятие израильтян на Йом ха-Ацмаут.',
    },
    {
      'hebrew': 'חָמֵץ',
      'plain': 'חמץ',
      'transcription': 'chamétz',
      'translation': 'Квасное (запрещенное к употреблению в Песах)',
      'tip': 'Любые продукты из 5 злаков, подвергшиеся брожению (хлеб, макароны, пиво).',
    },
    {
      'hebrew': 'נָעִים בַּסּוֹפַ״שׁ',
      'plain': 'נעים בסופ״ש',
      'transcription': 'na\'ím ba-sofásh',
      'translation': 'Бесплатные муниципальные субботние автобусы в Гуш-Дане',
      'tip': 'Сеть бесплатных автобусов между Тель-Авивом, Гиватаимом, Рамат-Ганом и Герцлией в шаббат.',
    },
  ];
}
