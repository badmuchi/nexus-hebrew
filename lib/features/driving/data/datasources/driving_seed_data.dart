import '../../domain/entities/driving_scenario.dart';
import '../../domain/entities/parking_curb_rule.dart';
import '../../domain/entities/waze_navigation_prompt.dart';

/// Seed data for Israeli parking curb regulations, Waze audio navigation, and driving situations.
final class DrivingSeedData {
  const DrivingSeedData._();

  /// 4 realistic Israeli parking curb scenarios.
  static const List<ParkingCurbCase> parkingCurbCases = [
    ParkingCurbCase(
      id: 'curb_1_blue_white_tel_aviv',
      curbType: CurbColorType.blueWhite,
      titleRu: 'Сине-белый в центре Тель-Авива в 20:30',
      streetNameRu: 'Улица Дизенгоф, Тель-Авив',
      streetNameHebrewWithNikkud: 'רְחוֹב דִּיזֶנְגּוֹף, תֵּל אָבִיב',
      signTextHebrew:
          'הַחֲנָיָה בְּתַשְׁלוּם א׳-ה׳ 09:00-17:00.\nמ-17:00 עַד 09:00 הַחֲנָיָה מֻתֶּרֶת לְבַעֲלֵי תָּו אֵזוֹר 1 בִּלְבַד.',
      signTextRu:
          'Парковка платная вс-чт 09:00-17:00.\nС 17:00 до 09:00 парковка разрешена ТОЛЬКО для жителей с наклейкой Зоны 1.',
      questionRu:
          'Ты приехал поужинать в 20:30, у тебя нет наклейки жителя Зоны 1. Можно ли припарковаться и оплатить через Pango?',
      isParkingAllowed: false,
      fineAmountTextRu: 'Штраф ₪250',
      explanationRu:
          'НЕТ! Хотя днем здесь можно платить через Pango, после 17:00 сине-белый бордюр становится эксклюзивным для местных жителей (תו אזורי). Pango даже не даст активировать парковку, а муниципальный инспектор выпишет штраф ₪250 за считанные минуты!',
      sabraDriverTipRu:
          'Всегда читай начало и конец знака на въезде на улицу. Если видишь «לבעלי תו בלבד» с определенного часа — ищи подземный паркинг (חניון).',
    ),
    ParkingCurbCase(
      id: 'curb_2_red_white_kiosk',
      curbType: CurbColorType.redWhite,
      titleRu: 'Красно-белый бордюр у киоска',
      streetNameRu: 'Улица Яффо, Иерусалим',
      streetNameHebrewWithNikkud: 'רְחוֹב יָפוֹ, יְרוּשָׁלַיִם',
      signTextHebrew: 'אָסוּר לַעֲצֹר וְאָסוּר לַחֲנוֹת לְאֹרֶךְ כָּל הָרְחוֹב.',
      signTextRu: 'Остановка и стоянка запрещены на всем протяжении улицы.',
      questionRu:
          '«Я только на 2 минутки за питой с фалафелем, включил аварийку». Разрешено ли остановиться?',
      isParkingAllowed: false,
      fineAmountTextRu: 'Штраф ₪250–500 + эвакуатор (גרר)',
      explanationRu:
          'СТРОГО ЗАПРЕЩЕНО! Мигающая аварийка («איתות חירום») в Израиле не дает никакого права парковаться на красно-белом бордюре. Камеры муниципалитета фиксируют нарушение автоматически, а эвакуатор увезет машину на штрафстоянку за ₪500+.',
      sabraDriverTipRu:
          'В Израиле говорят: «אדום-לבן זה טאבו» (красно-белый — это табу). Никаких исключений нет.',
    ),
    ParkingCurbCase(
      id: 'curb_3_red_yellow_bus_stop',
      curbType: CurbColorType.redYellow,
      titleRu: 'Красно-желтый бордюр на остановке',
      streetNameRu: 'Улица Ибн Гвироль, Тель-Авив',
      streetNameHebrewWithNikkud: 'רְחוֹב אִבְּן גַּבִּירוֹל, תֵּל אָבִיב',
      signTextHebrew: 'תַּחֲנַת אוֹטוֹבּוּס. פְּרִיקָה וּטְעִינָה מֻתֶּרֶת עַד 10:00.',
      signTextRu: 'Автобусная остановка. Разгрузка и погрузка разрешена до 10:00.',
      questionRu: 'Сейчас 15:00. Можно ли высадить пассажира или подождать 3 минуты?',
      isParkingAllowed: false,
      fineAmountTextRu: 'Штраф ₪500–1000',
      explanationRu:
          'ЗАПРЕЩЕНО! Красно-желтый бордюр предназначен исключительно для автобусов, маршруток и такси. Остановка легкового автомобиля мешает общественному транспорту и наказывается максимальным штрафом.',
      sabraDriverTipRu:
          'Даже кратковременная посадка/высадка на автобусной полосе (נת״צ) карается штрафом ₪500 по видеокамерам.',
    ),
    ParkingCurbCase(
      id: 'curb_4_gray_curb',
      curbType: CurbColorType.gray,
      titleRu: 'Обычный серый бордюр без окраски',
      streetNameRu: 'Улица Герцль, Нетания',
      streetNameHebrewWithNikkud: 'רְחוֹב הֶרְצְל, נְתַנְיָה',
      signTextHebrew: 'אֵין תַּמְרוּרֵי אִסּוּר.',
      signTextRu: 'Запрещающие знаки отсутствуют.',
      questionRu: 'Бордюр серый, без синей или красной краски. Нужно ли платить через Pango?',
      isParkingAllowed: true,
      explanationRu:
          'ДА, МОЖНО ПАРКОВАТЬСЯ БЕСПЛАТНО! Серый бордюр (מדרכה אפורה) при отсутствии запрещающих знаков означает полностью свободную и бесплатную парковку для всех автомобилей без ограничений.',
      sabraDriverTipRu:
          'Серый бордюр — мечта любого израильского водителя. Главное убедиться, что колеса не стоят на тротуаре («חניה על מדרכה» карается штрафом ₪500 даже на сером бордюре!).',
    ),
  ];

  /// 8 authentic Hebrew voice prompts from Waze navigation.
  static const List<WazePrompt> wazePrompts = [
    WazePrompt(
      id: 'waze_1_turn_right',
      maneuverType: WazeManeuverType.turnRight,
      hebrewWithNikkud: 'בְּעוֹד מָאתַיִם מֶטֶר, פְּנֵה יְמִינָה.',
      hebrewPlain: 'בעוד מאתיים מטר, פנה ימינה.',
      transcriptionRu: 'Be-ód matáyim méter, pnéh yemína.',
      translationRu: 'Через двести метров поверните направо.',
      correctActionRu: 'Повернуть направо на следующем перекрестке',
      actionOptionsRu: [
        'Повернуть направо через 200 метров',
        'Повернуть налево на светофоре',
        'Развернуться на кругу',
      ],
      correctOptionIndex: 0,
      iconEmoji: '↗️',
    ),
    WazePrompt(
      id: 'waze_2_roundabout_second_exit',
      maneuverType: WazeManeuverType.roundaboutExit,
      hebrewWithNikkud: 'בַּכִּכָּר, צֵא בַּיְּצִיאָה הַשְּׁנִיָּה.',
      hebrewPlain: 'בכיכר, צא ביציאה השנייה.',
      transcriptionRu: 'Ba-kikár, tzé ba-yetzi\'á ha-shniyá.',
      translationRu: 'На кругу съезжайте во второй съезд.',
      correctActionRu: 'На круговом перекрестке выехать во 2-й съезд (прямо)',
      actionOptionsRu: [
        'Выехать в первый съезд направо',
        'Выехать во второй съезд (прямо)',
        'Сделать полный разворот в третий съезд',
      ],
      correctOptionIndex: 1,
      iconEmoji: '🔄',
    ),
    WazePrompt(
      id: 'waze_3_speed_camera',
      maneuverType: WazeManeuverType.speedCamera,
      hebrewWithNikkud: 'שִׁמְרוּ עַל הַמְּהִירוּת, מַצְלֵמַת מְהִירוּת לְפָנֶיךָ.',
      hebrewPlain: 'שמרו על המהירות, מצלמת מהירות לפניך.',
      transcriptionRu: 'Shimrú al ha-mehirút, matzlemát mehirút lefanéikha.',
      translationRu: 'Соблюдайте скорость, камера контроля скорости впереди.',
      correctActionRu: 'Проверить спидометр и не превышать разрешенную скорость',
      actionOptionsRu: [
        'Снизить скорость, впереди фоторадар',
        'Прибавить газ для обгона',
        'Перестроиться на обочину',
      ],
      correctOptionIndex: 0,
      iconEmoji: '📸',
    ),
    WazePrompt(
      id: 'waze_4_u_turn_parsa',
      maneuverType: WazeManeuverType.uTurn,
      hebrewWithNikkud: 'בְּעוֹד חֲצִי קִילוֹמֶטֶר, עֲשֵׂה פַּרְסָה.',
      hebrewPlain: 'בעוד חצי קילומטר, עשה פרסה.',
      transcriptionRu: 'Be-ód chátzi kilómeter, aséh parsá.',
      translationRu: 'Через полкилометра сделайте разворот.',
      correctActionRu: 'Развернуться в обратную сторону («парса»)',
      actionOptionsRu: [
        'Поехать прямо по шоссе',
        'Сделать разворот на 180° (פרסה)',
        'Съехать на заправку',
      ],
      correctOptionIndex: 1,
      iconEmoji: '↩️',
    ),
    WazePrompt(
      id: 'waze_5_highway_merge',
      maneuverType: WazeManeuverType.mergeHighway,
      hebrewWithNikkud: 'הִשָּׁאֵר בַּנָּתִיב הַשְּׂמָאלִי וַעֲלֵה עַל הַמֶּחְלָף.',
      hebrewPlain: 'הישאר בנתיב השמאלי ועלה על המחלף.',
      transcriptionRu: 'Hisha\'ér ba-natív ha-smalí va-aléh al ha-mechláf.',
      translationRu: 'Держитесь левой полосы и въезжайте на развязку.',
      correctActionRu: 'Занять левую полосу для заезда на мост/эстакаду развязки',
      actionOptionsRu: [
        'Держаться левой полосы и заехать на развязку',
        'Съехать вправо в карман',
        'Остановиться перед знаком «Стоп»',
      ],
      correctOptionIndex: 0,
      iconEmoji: '🛣️',
    ),
    WazePrompt(
      id: 'waze_6_road_hazard',
      maneuverType: WazeManeuverType.roadHazard,
      hebrewWithNikkud: 'זְהִירוּת, סַכָּנָה בַּדֶּרֶךְ: רֶכֶב עוֹמֵד בַּשּׁוּלַיִם.',
      hebrewPlain: 'זהירות, סכנה בדרך: רכב עומד בשוליים.',
      transcriptionRu: 'Zehirút, sakaná ba-dérech: réchev oméd ba-shuláyim.',
      translationRu: 'Внимание, опасность на дороге: автомобиль на обочине.',
      correctActionRu: 'Быть внимательным к машине на обочине («шулаим»)',
      actionOptionsRu: [
        'Посигналить пешеходу',
        'Быть осторожным: машина стоит на обочине',
        'Включить дальний свет',
      ],
      correctOptionIndex: 1,
      iconEmoji: '⚠️',
    ),
    WazePrompt(
      id: 'waze_7_speed_bump',
      maneuverType: WazeManeuverType.speedBump,
      hebrewWithNikkud: 'פַּס הַאֲטָה לְפָנֶיךָ, הָאֵט אֶת הַמְּהִירוּת.',
      hebrewPlain: 'פס האטה לפניך, האט את המהירות.',
      transcriptionRu: 'Pas ha\'atá lefanéikha, ha\'ét et ha-mehirút.',
      translationRu: 'Лежачий полицейский впереди, снизьте скорость.',
      correctActionRu: 'Притормозить перед искусственной неровностью («пас хаата»)',
      actionOptionsRu: [
        'Притормозить перед лежачим полицейским',
        'Уступить дорогу справа',
        'Выключить кондиционер',
      ],
      correctOptionIndex: 0,
      iconEmoji: '〰️',
    ),
    WazePrompt(
      id: 'waze_8_destination_reached',
      maneuverType: WazeManeuverType.turnLeft,
      hebrewWithNikkud: 'הִגַּעְתָּ לַיַּעַד, הַיַּעַד מִשְּׂמֹאלְךָ.',
      hebrewPlain: 'הגעת ליעד, היעד משמאלך.',
      transcriptionRu: 'Higá\'ta la-yá\'ad, ha-yá\'ad mi-smolkha.',
      translationRu: 'Вы прибыли в пункт назначения, он слева от вас.',
      correctActionRu: 'Маршрут завершен, точка назначения слева',
      actionOptionsRu: [
        'Повернуть направо',
        'Вы прибыли, пункт назначения слева',
        'Продолжать движение 5 км',
      ],
      correctOptionIndex: 1,
      iconEmoji: '🏁',
    ),
  ];

  /// 5 realistic driving dialogues across gas stations, police stops, and car tests.
  static const List<DrivingScenarioQuestion> drivingScenarios = [
    DrivingScenarioQuestion(
      id: 'scen_1_gas_station_self_service',
      category: DrivingScenarioCategory.gasStation,
      interlocutorRoleRu: 'Заправщик на АЗС (מְתַדְלֵק)',
      speechHebrewWithNikkud: 'שָׁלוֹם, 95 אוֹ סוֹלָר? שֵׁרוּת עַצְמִי אוֹ מָלֵא?',
      speechHebrewPlain: 'שלום, 95 או סולר? שירות עצמי או מלא?',
      transcriptionRu: 'Shalom, tish\'ím ve-chamesh o sólar? Sherút atzmí o maléh?',
      translationRu: 'Здравствуйте, 95-й бензин или солярка (дизель)? Самообслуживание или полный сервис?',
      driverTipRu:
          '«Шерут ацми» (самообслуживание) в Израиле дешевле примерно на 22 агоры за литр. Большинство заправляются сами картой на колонке.',
      responseOptions: [
        'תֵּן לִי 95, שֵׁרוּת עַצְמִי בְּבַקָּשָׁה. אֲנִי מְשַׁלֵּם בְּאַשְׁרַאי בַּמַּשְׁאֵבָה.',
        'תִּשְׁפֹּךְ לִי מַיִם מֵהַבֶּרֶז לְתוֹךְ מְכַל הַדֶּלֶק.',
        'לֹא יוֹדֵעַ מָה זֶה מְכוֹנִית, בָּאתִי בְּקוֹרְקִינֶט.',
      ],
      bestResponseIndex: 0,
      explanationRu:
          '«95, שירות עצמי, אשראי במשאבה» — самая частая формула на израильской заправке.',
    ),
    DrivingScenarioQuestion(
      id: 'scen_2_tire_pressure',
      category: DrivingScenarioCategory.gasStation,
      interlocutorRoleRu: 'Работник АЗС (עוֹבֵד תַּחֲנַת דֶּלֶק)',
      speechHebrewWithNikkud: 'אַתָּה רוֹצֶה לִבְדֹּק שֶׁמֶן וּמַיִם וּלְמַלֵּאת לַחַץ אֲוִיר בַּצְּמִיגִים?',
      speechHebrewPlain: 'אתה רוצה לבדוק שמן ומים ולמלאת לחץ אוויר בצמיגים?',
      transcriptionRu: 'Atá rotzéh livdók shémen u-máyim u-lemalét láchatz avír ba-tzmigím?',
      translationRu: 'Хотите проверить масло и воду и подкачать давление воздуха в шинах?',
      driverTipRu:
          'Компрессор для подкачки шин («מַשְׁאֵבַת אֲוִיר») на израильских заправках бесплатный. Давление в PSI указано на наклейке на водительской стойке двери.',
      responseOptions: [
        'כֵּן, תּוֹדָה. מַדְחֵס הָאֲוִיר נִמְצָא שָׁם לְיַד הַשְּׁטִיפָה, נָכוֹן?',
        'לֹא צָרִיךְ אֲוִיר, הַצְּמִיגִים שֶׁלִּי עֲשׂוּיִים מֵעֵץ מָלֵא.',
        'אֲנִי אֶמְזֹג שֶׁמֶן לְתוֹךְ הַוִינְקֶר שֶׁל הָאוֹטוֹ.',
      ],
      bestResponseIndex: 0,
      explanationRu:
          'Автоматические насосы воздуха («מדחס אוויר») стоят на каждой АЗС рядом с автомойкой (שטיפה).',
    ),
    DrivingScenarioQuestion(
      id: 'scen_3_police_stop',
      category: DrivingScenarioCategory.policeStop,
      interlocutorRoleRu: 'Офицер дорожной полиции (שׁוֹטֵר תְּנוּעָה)',
      speechHebrewWithNikkud: 'בֹּקֶר טוֹב. עֲצֹר בַּצַּד, כַּבֵּה מָנוֹעַ. תַּרְאֶה לִי רִשְׁיוֹן נְהִיגָה וּבִטּוּחַ חוֹבָה.',
      speechHebrewPlain: 'בוקר טוב. עצור בצד, כבה מנוע. תראה לי רישיון נהיגה וביטוח חובה.',
      transcriptionRu: 'Boker tov. Atzór ba-tzad, kabéh manó\'a. Tar\'éh li rishyón nehigá u-vitúach chová.',
      translationRu: 'Доброе утро. Остановитесь у обочины, заглушите двигатель. Покажите водительские права и обязательную страховку.',
      driverTipRu:
          'В Израиле полиция вежливая, но строгая. Руки держи на руле, не выходи из машины без просьбы офицера. Права можно показать в цифровом виде в телефоне.',
      responseOptions: [
        'בֹּקֶר טוֹב, הִנֵּה הָרִשְׁיוֹן הַדִּיגִיטָלִי בָּאַפְּלִיקַצְיָה וּפָּלִיסַת הַבִּטּוּחַ.',
        'לָמָּה שֶׁאַרְאֶה לְךָ? אֲנִי בְּמַהֲלַךְ נְסִיעָה וּמְמַהֵר לַיָּם.',
        'אֵין לִי רִשְׁיוֹן, שָׁאַלְתִּי אֶת הָרֶכֶב מֵחָבֵר בְּלִי לִשְׁאוֹל.',
      ],
      bestResponseIndex: 0,
      explanationRu:
          'Спокойно и вежливо передать права и страховку — лучший способ разрешить проверку без штрафа.',
    ),
    DrivingScenarioQuestion(
      id: 'scen_4_annual_test',
      category: DrivingScenarioCategory.carInspection,
      interlocutorRoleRu: 'Инспектор станции техосмотра (בּוֹחֵן רֶכֶב בַּטֶּסְט)',
      speechHebrewWithNikkud: 'הַבְּלָמִים תַּקִינִים, אֲבָל יֵשׁ לְךָ נוּרַת פַּנָּס שְׂרוּפָה וְלוֹחִית רִשּׁוּי דְּהוּיָה.',
      speechHebrewPlain: 'הבלמים תקינים, אבל יש לך נורת פנס שרופה ולוחית רישוי דהויה.',
      transcriptionRu: 'Ha-blamím tkiním, avál yesh lekhá nurát panás srufá ve-luchít rishúy dehuyá.',
      translationRu: 'Тормоза исправны, но перегорела лампочка фары и выцвел номерной знак.',
      driverTipRu:
          '«Тест» (טסט לרכב) проходят каждый год. Прямо на станции техосмотра почти всегда есть мастерская, где за ₪30-50 меняют лампочку или штампуют новый желтый номер.',
      responseOptions: [
        'הֵבַנְתִּי. אֶכָּנֵס עַכְשָׁו לַמּוּסָךְ שֶׁל הַמָּכוֹן, אַחֲלִיף נוּרָה וְאַחֲזֹר לַחֲתִימָה.',
        'לֹא אִכְפַּת לִי מֵהַפַּנָּסִים, אֲנִי נוֹסֵעַ רַק בַּיּוֹם בַּשֶּׁמֶשׁ.',
        'תַּחְתֹּם לִי מִיָּד, אֲנִי לֹא מְתַקֵּן שׁוּם דָּבָר.',
      ],
      bestResponseIndex: 0,
      explanationRu:
          'Исправление мелких недочетов на месте позволяет завершить тест в тот же день без повторной оплаты.',
    ),
    DrivingScenarioQuestion(
      id: 'scen_5_bumper_scratch',
      category: DrivingScenarioCategory.accidentExchange,
      interlocutorRoleRu: 'Водитель второго автомобиля (נַהָג שֶׁשִּׁפְשֵׁף פָּגוֹשׁ)',
      speechHebrewWithNikkud: 'סְלִיחָה, שִׁפְשַׁפְתִּי קְצָת אֶת הַפָּגוֹשׁ שֶׁלְּךָ בַּחֲנָיָה. בּוֹא נַחֲלִיף פְּרָטִים.',
      speechHebrewPlain: 'סליחה, שפשפתי קצת את הפגוש שלך בחניה. בוא נחליף פרטים.',
      transcriptionRu: 'Slichá, shifsháfti ktzat et ha-pagósh shelkhá ba-chanayá. Bo nachlíf pratím.',
      translationRu: 'Извини, я немного притер твой бампер на парковке. Давай обменяемся данными.',
      driverTipRu:
          '«החלפת פרטים» (обмен данными) — стандартная процедура в Израиле. Фотографируют права водителя, полис страховки, техпаспорт машины (ришайон рехев) и повреждения с номерами.',
      responseOptions: [
        'בְּסֵדֶר גָּמוּר, הַכֹּל טוֹב. נְצַלֵּם אֶת הַנְּזָקִים, הַבִּטּוּחִים וְרִשְׁיוֹנוֹת הַנְּהִיגָה.',
        'אֲנִי הוֹלֵךְ לִצְעֹק עָלֶיךָ שְׁעָתַיִם בְּאֶמְצַע הָרְחוֹב.',
        'אֵין צֹרֶךְ בִּפְרָטִים, שַׁלֵּם לִי עַכְשָׁו מִילְיוֹן שֶׁקֶל בִּמְזֻמָּן.',
      ],
      bestResponseIndex: 0,
      explanationRu:
          'Спокойное фотографирование документов и повреждений («נצלם את הנזקים והביטוחים») решает вопрос через страховую компанию без лишнего стресса.',
    ),
  ];

  /// 16 essential Israeli driving and road vocabulary terms.
  static const List<Map<String, String>> drivingGlossary = [
    {
      'hebrew': 'רִשְׁיוֹן נְהִיגָה',
      'plain': 'רישיון נהיגה',
      'transcription': 'rishyón nehigá',
      'translation': 'Водительское удостоверение (права)',
      'tip': 'Новые репатрианты могут конвертировать иностранные права (המרת רישיון) при стаже от 5 лет без сдачи экзаменов.',
    },
    {
      'hebrew': 'בִּטּוּחַ חוֹבָה',
      'plain': 'ביטוח חובה',
      'transcription': 'bitúach chová',
      'translation': 'Обязательное страхование автогражданской ответственности',
      'tip': 'Покрывает ущерб здоровью водителя, пассажиров и пешеходов в Израиле по закону.',
    },
    {
      'hebrew': 'פַּנְגּוֹ / סֵלוֹ',
      'plain': 'פנגו / סלו',
      'transcription': 'Pango / Cello',
      'translation': 'Приложения оплаты муниципальной парковки',
      'tip': 'Главные приложения для оплаты сине-белой зоны по всей стране. Автоматически определяют город и тариф.',
    },
    {
      'hebrew': 'תָּו חֲנָיָה אֲזוֹרִי',
      'plain': 'תו חניה אזורי',
      'transcription': 'tav chanayá azorí',
      'translation': 'Зональное парковочное разрешение жителя',
      'tip': 'Электронное разрешение от мэрии по прописке в договоре аренды, позволяющее бесплатно парковаться в своем районе.',
    },
    {
      'hebrew': 'כְּבִישׁ אַגְרָה (כְּבִישׁ 6)',
      'plain': 'כביש אגרה',
      'transcription': 'kvish agrá (kvish shesh)',
      'translation': 'Платная автострада (Трасса 6)',
      'tip': 'Скоростная трасса без шлагбаумов — считывание номера машины происходит автоматически камерами порталов.',
    },
    {
      'hebrew': 'נָתִיב מָהִיר',
      'plain': 'נתיב מהיר',
      'transcription': 'natív mahír',
      'translation': 'Скоростная платная полоса (Fast Lane)',
      'tip': 'Полоса въезда в Тель-Авив по шоссе 1 с динамическим тарифом; бесплатна для автобусов и карпула (3+ человека).',
    },
    {
      'hebrew': 'פַּס הַאֲטָה',
      'plain': 'פס האטה',
      'transcription': 'pas ha\'atá',
      'translation': 'Лежачий полицейский',
      'tip': 'Искусственная дорожная неровность для снижения скорости в жилых кварталах.',
    },
    {
      'hebrew': 'מַצְלֵמַת מְהִירוּת',
      'plain': 'מצלמת מהירות',
      'transcription': 'matzlemát mehirút',
      'translation': 'Камера контроля скорости (радар)',
      'tip': 'Автоматические стационарные оранжево-серые камеры («מצלמות גאטסו») на главных магистралях Израиля.',
    },
    {
      'hebrew': 'כִּכָּר תְּנוּעָה',
      'plain': 'כיכר תנועה',
      'transcription': 'kikár tnu\'á',
      'translation': 'Круговой перекресток',
      'tip': 'В Израиле огромное количество кругов! Приоритет ВСЕГДА у того, кто уже въехал на кольцо.',
    },
    {
      'hebrew': 'פַּרְסָה',
      'plain': 'פרסה',
      'transcription': 'parsá',
      'translation': 'Разворот на 180 градусов',
      'tip': '«עֲשֵׂה פַּרְסָה» — команда Waze и инструктора. Дословно «подкова».',
    },
    {
      'hebrew': 'פְּקָק תְּנוּעָה',
      'plain': 'פקק תנועה',
      'transcription': 'pkak tnu\'á',
      'translation': 'Дорожный затор (пробка)',
      'tip': '«אני תקוע בפקק באיילון» (Я застрял в пробке на Аялоне) — вечное оправдание опозданий.',
    },
    {
      'hebrew': 'גְּרָר',
      'plain': 'גרר',
      'transcription': 'grar',
      'translation': 'Эвакуатор',
      'tip': 'Служба эвакуации за неправильную парковку на красно-белом или инвалидном месте.',
    },
    {
      'hebrew': 'דּוּ״חַ חֲנָיָה',
      'plain': 'דוח חניה',
      'transcription': 'dú\'ach chanayá',
      'translation': 'Штрафная квитанция за парковку',
      'tip': 'Муниципальный штраф (от ₪100 до ₪1000), оплачивается на сайте мэрии (ирия).',
    },
    {
      'hebrew': 'טֶסְט שְׁנָתִי',
      'plain': 'טסט שנתי',
      'transcription': 'test shnatí',
      'translation': 'Ежегодный государственный техосмотр',
      'tip': 'Обязательная проверка безопасности автомобиля на аккредитованной станции (махон ришуй).',
    },
    {
      'hebrew': 'שֵׁרוּת עַצְמִי',
      'plain': 'שירות עצמי',
      'transcription': 'sherút atzmí',
      'translation': 'Самообслуживание на АЗС',
      'tip': 'Самостоятельная вставка пистолета и оплата картой в терминале колонки со скидкой к тарифу.',
    },
    {
      'hebrew': 'הַחְלָפַת פְּרָטִים',
      'plain': 'החלפת פרטים',
      'transcription': 'hachlafát pratím',
      'translation': 'Обмен контактами и страховками при аварии',
      'tip': 'Взаимное фотографирование прав, техпаспорта и полиса без признания вины на месте.',
    },
  ];
}
