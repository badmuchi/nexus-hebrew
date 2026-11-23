import '../../domain/entities/apartment_listing.dart';
import '../../domain/entities/housing_scenario.dart';
import '../../domain/entities/rental_contract_clause.dart';

/// Seed data for Israeli apartment hunting, Yad2 ad decryptor, rental contracts, and landlord disputes.
final class HousingSeedData {
  const HousingSeedData._();

  /// 10 essential abbreviations used in Israeli rental ads.
  static const List<Yad2Abbreviation> yad2Abbreviations = [
    Yad2Abbreviation(
      id: 'abbr_nis',
      abbreviationHebrew: 'ש״ח',
      fullHebrewWithNikkud: 'שֶׁקֶל חָדָשׁ',
      transcriptionRu: 'shekel chadásh',
      translationRu: 'Новый израильский шекель (₪)',
      significanceRu: 'Все цены аренды в Израиле указываются в шекелях в месяц.',
    ),
    Yad2Abbreviation(
      id: 'abbr_air_directions',
      abbreviationHebrew: 'כ״א',
      fullHebrewWithNikkud: 'כִּוּוּנֵי אֲוִיר',
      transcriptionRu: 'kivunéy avír',
      translationRu: 'Стороны света (направления ветра)',
      significanceRu:
          '«3 כ״א» означает, что окна выходят на 3 стороны света — квартира отлично проветривается и не плесневеет зимой.',
    ),
    Yad2Abbreviation(
      id: 'abbr_sqm',
      abbreviationHebrew: 'מ״ר',
      fullHebrewWithNikkud: 'מֶטֶר רָבוּעַ',
      transcriptionRu: 'méter ravú\'a',
      translationRu: 'Квадратный метр площади',
      significanceRu: 'Полезная или брутто-площадь квартиры, от которой также зависит муниципальный налог Арнона.',
    ),
    Yad2Abbreviation(
      id: 'abbr_dud_shemesh',
      abbreviationHebrew: 'דוד שמש',
      fullHebrewWithNikkud: 'דּוּד שֶׁמֶשׁ',
      transcriptionRu: 'dud shémesh',
      translationRu: 'Солнечный водонагревательный бойлер',
      significanceRu:
          'Критично! Нагревает воду от солнца бесплатно 7-8 месяцев в году, экономя сотни шекелей на счетах за свет.',
    ),
    Yad2Abbreviation(
      id: 'abbr_mamad',
      abbreviationHebrew: 'ממ״ד',
      fullHebrewWithNikkud: 'מֶרְחָב מוּגָן דִּירָתִי',
      transcriptionRu: 'mamád (mercháv mugán diratí)',
      translationRu: 'Защищенная комната безопасности (МАМАД)',
      significanceRu:
          'Укрепленная комната с тяжелой стальной дверью и фильтрацией воздуха. Защищает при ракетных обстрелах, обязательно в домах после 1992 года.',
    ),
    Yad2Abbreviation(
      id: 'abbr_mazgan',
      abbreviationHebrew: 'מזגן',
      fullHebrewWithNikkud: 'מַזְגָן',
      transcriptionRu: 'mazgán',
      translationRu: 'Кондиционер',
      significanceRu:
          'Жизненно необходим из-за влажной 35-градусной летней жары и зимнего обогрева (в Израиле нет центрального отопления!).',
    ),
    Yad2Abbreviation(
      id: 'abbr_elevator',
      abbreviationHebrew: 'מעלית',
      fullHebrewWithNikkud: 'מַעֲלִית',
      transcriptionRu: 'ma\'alít',
      translationRu: 'Лифт',
      significanceRu: 'Особенно важно на 3-4 этажах старых домов без лифта («בניין רכבת»).',
    ),
    Yad2Abbreviation(
      id: 'abbr_parking',
      abbreviationHebrew: 'חניה',
      fullHebrewWithNikkud: 'חֲנָיָה בַּטַּאבּוֹ',
      transcriptionRu: 'chanayá ba-tábo',
      translationRu: 'Парковочное место в собственности дома',
      significanceRu: 'Огромный плюс в центре Тель-Авива или Иерусалима, экономит часы поиска парковки каждый вечер.',
    ),
    Yad2Abbreviation(
      id: 'abbr_no_broker',
      abbreviationHebrew: 'ללא תיווך',
      fullHebrewWithNikkud: 'לְלֹא דְּמֵי תִּוּוּךְ',
      transcriptionRu: 'le-lo dméy tivúch',
      translationRu: 'Без комиссии маклера / риелтора',
      significanceRu: 'Экономит комиссию риелтора, которая в Израиле обычно равна стоимости одного месячного оклада аренды + НДС (מע״מ).',
    ),
    Yad2Abbreviation(
      id: 'abbr_cv_checks',
      abbreviationHebrew: 'ק״ח / תלושים',
      fullHebrewWithNikkud: 'קוֹרוֹת חַיִּים וּתְלוּשֵׁי שָׂכָר',
      transcriptionRu: 'korót chayím u-tlushéy sakhár',
      translationRu: 'Резюме и 3 последних зарплатных листка арендатора',
      significanceRu: 'Хозяева квартир всегда требуют подтверждение стабильного дохода перед показом или подписанием договора.',
    ),
  ];

  /// 3 authentic Yad2 apartment rental listings with decryptor info.
  static const List<ApartmentListing> apartmentListings = [
    ApartmentListing(
      id: 'yad2_florentin_tlv',
      cityRu: 'Тель-Авив',
      neighborhoodRu: 'Флорентин',
      neighborhoodHebrewWithNikkud: 'פְּלוֹרֶנְטִין, תֵּל אָבִיב',
      roomsCount: 2.5,
      squareMeters: 65,
      priceMonthlyShekels: 6800,
      floor: 2,
      hasElevator: false,
      hasMamad: false,
      hasBalcony: true,
      hasDudShemesh: true,
      hasParking: false,
      rawAdTextHebrew:
          'לְהַשְׂכָּרָה בִּפְלוֹרֶנְטִין! דִּירַת 2.5 חֲדָרִים 65 מ״ר מְשֻׁפֶּצֶת וּמואֶרֶת. מַזְגָן בְּכָל חֶדֶר, דּוּד שֶׁמֶשׁ, מִרְפֶּסֶת שֶׁמֶשׁ מְפַנֶּקֶת. לְלֹא מַעֲלִית (קוֹמָה 2), לְלֹא מַמָּ״ד (יֵשׁ מִקְלָט מְשֻׁתָּף). 6,800 ש״ח לְחֹדֶשׁ, כְּנִיסָה מִיָּדִית, לְלֹא תִּוּוּךְ!',
      abbreviationsUsed: [
        Yad2Abbreviation(
          id: 'ad1_nis',
          abbreviationHebrew: 'ש״ח',
          fullHebrewWithNikkud: 'שֶׁקֶל חָדָשׁ',
          transcriptionRu: 'shekel chadásh',
          translationRu: '₪6,800 в месяц',
          significanceRu: 'Стандартная цена для Флорентина.',
        ),
        Yad2Abbreviation(
          id: 'ad1_sqm',
          abbreviationHebrew: 'מ״ר',
          fullHebrewWithNikkud: 'מֶטֶר רָבוּעַ',
          transcriptionRu: 'méter ravú\'a',
          translationRu: '65 кв.м',
          significanceRu: 'Просторная площадь для 2.5 комнат.',
        ),
        Yad2Abbreviation(
          id: 'ad1_mamad',
          abbreviationHebrew: 'ללא ממ״ד',
          fullHebrewWithNikkud: 'לְלֹא מֶרְחָב מוּגָן דִּירָתִי',
          transcriptionRu: 'le-lo mamád',
          translationRu: 'Без МАМАДа в квартире',
          significanceRu: 'В доме есть только общее убежище в подвале (מקלט).',
        ),
      ],
      hiddenTrapWarningRu:
          'Внимание: 2 этаж без лифта (неудобно с коляской или велосипедом), нет МАМАДа в квартире — при сирене придется бежать в подвальный миклат за 90 секунд.',
    ),
    ApartmentListing(
      id: 'yad2_rehavia_jlm',
      cityRu: 'Иерусалим',
      neighborhoodRu: 'Рехавия',
      neighborhoodHebrewWithNikkud: 'רְחַבְיָה, יְרוּשָׁלַיִם',
      roomsCount: 3.0,
      squareMeters: 82,
      priceMonthlyShekels: 7500,
      floor: 3,
      hasElevator: true,
      hasMamad: true,
      hasBalcony: true,
      hasDudShemesh: true,
      hasParking: true,
      rawAdTextHebrew:
          'בִּרְחַבְיָה הַמְּבֻקֶּשֶׁת! 3 חֲדָרִים 82 מ״ר, 3 כ״א, מַעֲלִית, חֲנָיָה פְּרָטִית בַּטַּאבּוֹ וּמַמָּ״ד! דּוּד שֶׁמֶשׁ וְחִמּוּם גַּז (יוֹנְקֶרְס). 7,500 ש״ח לְחֹדֶשׁ, דְּרוּשִׁים עֲרֵבִים יִשְׂרְאֵלִיִּים וְצֶ׳ק בִּטָּחוֹן. לְלֹא תִּוּוּךְ.',
      abbreviationsUsed: [
        Yad2Abbreviation(
          id: 'ad2_air',
          abbreviationHebrew: '3 כ״א',
          fullHebrewWithNikkud: 'שְׁלוֹשָׁה כִּוּוּנֵי אֲוִיר',
          transcriptionRu: 'shloshá kivunéy avír',
          translationRu: '3 стороны света',
          significanceRu: 'Много естественного света и свежего иерусалимского воздуха.',
        ),
        Yad2Abbreviation(
          id: 'ad2_mamad',
          abbreviationHebrew: 'ממ״ד',
          fullHebrewWithNikkud: 'מֶרְחָב מוּגָן דִּירָתִי',
          transcriptionRu: 'mamád',
          translationRu: 'Есть защитная комната',
          significanceRu: 'Максимальная безопасность прямо в квартире.',
        ),
        Yad2Abbreviation(
          id: 'ad2_arevim',
          abbreviationHebrew: 'ערבים',
          fullHebrewWithNikkud: 'עֲרֵבִים יִשְׂרְאֵלִיִּים',
          transcriptionRu: 'arevím yisre\'elíyim',
          translationRu: 'Требуются поручители',
          significanceRu: 'Два работающих гражданина Израиля должны подписать гарантию договора.',
        ),
      ],
      hiddenTrapWarningRu:
          'Хозяин строго требует двух работающих поручителей-израильтян с зарплатными листками (תלושי שכר). Новым репатриантам без местных родственников стоит заранее обсудить замену на гарантийный депозит.',
    ),
    ApartmentListing(
      id: 'yad2_carmel_haifa',
      cityRu: 'Хайфа',
      neighborhoodRu: 'Мерказ Кармель',
      neighborhoodHebrewWithNikkud: 'מֶרְכַּז הַכַּרְמֶל, חֵיפָה',
      roomsCount: 4.0,
      squareMeters: 105,
      priceMonthlyShekels: 5200,
      floor: 4,
      hasElevator: true,
      hasMamad: true,
      hasBalcony: true,
      hasDudShemesh: true,
      hasParking: true,
      rawAdTextHebrew:
          'בְּמֶרְכַּז הַכַּרְמֶל בְּבִנְיָן מְטֻפָּח! 4 חֲדָרִים מְרֻוַּחַת 105 מ״ר, נוֹף מַרְהִיב לַמִּפְרָץ, מַעֲלִית, חֲנָיָה מְקֹרָה, דּוּד שֶׁמֶשׁ, מַזְגָן מֶרְכָּזִי. אַרְנוֹנָה נְמוּכָה. 5,200 ש״ח לְחֹדֶשׁ, לְלֹא דְּמֵי תִּוּוּךְ.',
      abbreviationsUsed: [
        Yad2Abbreviation(
          id: 'ad3_sqm',
          abbreviationHebrew: '105 מ״ר',
          fullHebrewWithNikkud: 'מֵאָה וְחָמֵשׁ מֶטֶר רָבוּעַ',
          transcriptionRu: 'me\'áh ve-chamésh méter ravú\'a',
          translationRu: '105 кв.м',
          significanceRu: 'Очень просторная 4-комнатная квартира для большой семьи.',
        ),
        Yad2Abbreviation(
          id: 'ad3_arnona',
          abbreviationHebrew: 'ארנונה',
          fullHebrewWithNikkud: 'אַרְנוֹנָה עִירוֹנִית',
          transcriptionRu: 'arnóna ironít',
          translationRu: 'Муниципальный налог',
          significanceRu: 'В Хайфе арнона оплачивается раз в 2 месяца в мэрию.',
        ),
      ],
      hiddenTrapWarningRu:
          '«מזגן מרכזי» (центральный кондиционер на всю квартиру) потребляет намного больше электричества, чем раздельные инверторы в каждой комнате. Счета за свет летом могут превысить ₪1,000 в месяц.',
    ),
  ];

  /// 5 key legal clauses from an Israeli standard rental contract.
  static const List<RentalContractClause> contractClauses = [
    RentalContractClause(
      id: 'clause_1_security_deposit',
      category: ContractClauseCategory.guaranteesAndSecurity,
      clauseTitleRu: 'Размер чека безопасности (צֶ׳ק בִּטָּחוֹן)',
      clauseHebrewWithNikkud:
          'הַשׂוֹכֵר יַפְקִיד בְּיָדֵי הַמַּשְׂכִּיר שְׁטַר חוֹב אוֹ צֶ׳ק בִּטָּחוֹן עַל סַךְ לֹא יוֹתֵר מִשְּׁלוֹשָׁה חָדְשֵׁי שְׂכִירוּת.',
      clauseHebrewPlain:
          'השוכר יפקיד בידי המשכיר שטר חוב או צ׳ק ביטחון על סך לא יותר משלושה חודשי שכירות.',
      transcriptionRu:
          'Ha-sochér yafkíd bi-yedéy ha-maskír shtar chov o tzek bitachón al sach lo yotér mi-shloshá chodshéy skhirút.',
      plainLanguageExplanationRu:
          'Хозяин квартиры может потребовать чек безопасности, но по Закону о справедливой аренде 2017 года его сумма не может превышать 3 месяцев аренды.',
      tenantProtectionLawRu:
          'Чек безопасности передается без даты и с надписью «לביטחון בלבד» (только для залога) между двумя косыми линиями (קרוס).',
      isFairClause: true,
    ),
    RentalContractClause(
      id: 'clause_2_repairs_responsibility',
      category: ContractClauseCategory.repairsAndDefects,
      clauseTitleRu: 'Ремонт поломок и естественный износ (בְּלַאי סָבִיר)',
      clauseHebrewWithNikkud:
          'קִלְקוּלִים הַנּוֹבְעִים מִבְּלַאי סָבִיר (דּוּד שֶׁמֶשׁ, צַנֶּרֶת, מַזְגָן) יְתֻקְּנוּ עַל יְדֵי הַמַּשְׂכִּיר תּוֹךְ 24 עַד 48 שָׁעוֹת מֵהַהוֹדָעָה.',
      clauseHebrewPlain:
          'קלקולים הנובעים מבלאי סביר (דוד שמש, צנרת, מזגן) יתוקנו על ידי המשכיר תוך 24 עד 48 שעות מההודעה.',
      transcriptionRu:
          'Kikulím ha-nov\'ím mi-bláy savír (dud shémesh, tzanéret, mazgán) yetuknú al yedéy ha-maskír toch 24 ad 48 sha\'ót me-ha-hoda\'á.',
      plainLanguageExplanationRu:
          'Если сгорел бойлер, сломался кондиционер или потекла труба от старости — платит ТОЛЬКО хозяин квартиры! Арендатор платит только за то, что сломал сам по неосторожности.',
      tenantProtectionLawRu:
          'Если хозяин не чинит срочную поломку (бойлер, течь) в течение 24 часов, арендатор имеет законное право вызвать мастера сам и вычесть чек из аренды.',
      isFairClause: true,
    ),
    RentalContractClause(
      id: 'clause_3_early_exit_tenant',
      category: ContractClauseCategory.earlyTermination,
      clauseTitleRu: 'Досрочный выезд арендатора (שׂוֹכֵר חֲלִיפִי)',
      clauseHebrewWithNikkud:
          'הַשׂוֹכֵר רַשַּׁאי לְסַיֵּם אֶת הַחוֹזֶה בְּהוֹדָעָה מֵרֹאשׁ שֶׁל 60 יוֹם אוֹ בִּמְצִיאַת שׂוֹכֵר חֲלִיפִי בְּאוֹתָם תְּנָאִים.',
      clauseHebrewPlain:
          'השוכר רשאי לסיים את החוזה בהודעה מראש של 60 יום או במציאת שוכר חליפי באותם תנאים.',
      transcriptionRu:
          'Ha-sochér rasháy le-sayém et ha-chozéh be-hoda\'á me-rosh shel shishím yom o bi-mtzi\'át sochér chalifí be-otám tna\'ím.',
      plainLanguageExplanationRu:
          'Золотое правило для арендатора: если ты решил сменить квартиру или город раньше срока, хозяин обязан отпустить тебя, если ты найдешь вместо себя платежеспособного жильца («שוכר חליפי»).',
      tenantProtectionLawRu:
          'Хозяин не имеет права безосновательно отклонить адекватного заменяющего жильца.',
      isFairClause: true,
    ),
    RentalContractClause(
      id: 'clause_4_arnona_bills_transfer',
      category: ContractClauseCategory.billsAndTaxes,
      clauseTitleRu: 'Перевод Арноны и счетов за электричество (הַעֲבָרַת חֶשְׁבּוֹנוֹת)',
      clauseHebrewWithNikkud:
          'הַשׂוֹכֵר יַעֲבִיר עַל שְׁמוֹ אֶת חֶשְׁבּוֹנוֹת הַחַשְׁמַל, הַמַּיִם, הַגַּז וְהָאַרְנוֹנָה הָעִירוֹנִית.',
      clauseHebrewPlain:
          'השוכר יעביר על שמו את חשבונות החשמל, המים, הגז והארנונה העירונית.',
      transcriptionRu:
          'Ha-sochér ya\'avír al shmo et cheshbonót ha-chashmál, ha-máyim, ha-gaz ve-ha-arnóna ha-ironít.',
      plainLanguageExplanationRu:
          'Все коммунальные счета переводятся на имя жильца на сайте мэрии и Хеврат Хашмаль. Это выгодно: оле хадаш получает огромную скидку на арнону!',
      tenantProtectionLawRu:
          'Новые репатрианты имеют государственное право на скидку до 70–90% на арнону в течение первого года аренды (до 100 м²).',
      isFairClause: true,
    ),
    RentalContractClause(
      id: 'clause_5_unfair_repair_clause',
      category: ContractClauseCategory.repairsAndDefects,
      clauseTitleRu: 'Хитрая несправедливая статья хозяев (נֶזֶק עַל חֶשְׁבּוֹן שׂוֹכֵר)',
      clauseHebrewWithNikkud:
          'כָּל קִלְקוּל בַּמַּזְגָן וּבַדּוּד עַד סַךְ 1,000 ש״ח יְתֻקַּן בִּלְעָדִית עַל חֶשְׁבּוֹן הַשׂוֹכֵר.',
      clauseHebrewPlain:
          'כל קלקול במזגן ובדוד עד סך 1,000 ש״ח יתוקן בלעדית על חשבון השוכר.',
      transcriptionRu:
          'Kol kilkúl ba-mazgán u-va-dud ad sach élef shkhalím yetukán bil\'adít al cheshbón ha-sochér.',
      plainLanguageExplanationRu:
          'ОСТОРОЖНО! Некоторые хозяева пытаются переложить мелкий ремонт старой техники на жильца. Никогда не подписывай этот пункт!',
      tenantProtectionLawRu:
          'По закону 2017 года эта статья незаконна: арендодатель обязан чинить любой естественный износ оборудования.',
      isFairClause: false,
    ),
  ];

  /// 5 realistic tenant dialogues with landlords and house committees (Va'ad Bayit).
  static const List<HousingScenarioQuestion> housingScenarios = [
    HousingScenarioQuestion(
      id: 'scen_1_water_heater_broken',
      interlocutorRoleRu: 'Хозяин квартиры (בַּעַל הַבַּיִת)',
      speechHebrewWithNikkud: 'שָׁלוֹם, רָאִיתִי אֶת הַהוֹדָעָה שֶׁלְּךָ שֶׁדּוּד הַשֶּׁמֶשׁ מְקַצֵּר וְאֵין מַיִם חַמִּים.',
      speechHebrewPlain: 'שלום, ראיתי את ההודעה שלך שדוד השמש מקצר ואין מים חמים.',
      transcriptionRu: 'Shalom, raíti et ha-hoda\'á shelkhá she-dud ha-shémesh mekatzér ve-en máyim chamím.',
      translationRu: 'Привет, я увидел твое сообщение, что солнечный бойлер коротит и нет горячей воды.',
      tenantTipRu:
          'Срочная поломка бойлера — ответственность арендодателя. Попроси прислать техника в течение суток, так как жить без горячей воды невозможно.',
      responseOptions: [
        'תּוֹדָה, דָּנִי. זֶה מְקַצֵּר אֶת כָּל הַחַשְׁמַל בַּבַּיִת. תּוּכַל לִשְׁלֹחַ טֶכְנַאי דּוּדִים הַיּוֹם?',
        'אֵין בְּעָיָה, אֲנִי אֶתְקַלֵּחַ בְּמַיִם קְפוּאִים כָּל הַחֹרֶף עַד שֶׁתִּהְיֶה לְךָ סַבְלָנוּת.',
        'אֲנִי אֶשְׂרֹף אֶת כָּל הַבִּנְיָן כְּדֵי לְחַמֵּם אֶת הַמַּיִם.',
      ],
      bestResponseIndex: 0,
      explanationRu:
          'Четкое вежливое описание («מקצר את החשמל, תוכל לשלוח טכנאי היום?») обязывает хозяина оперативно направить сертифицированного мастера.',
    ),
    HousingScenarioQuestion(
      id: 'scen_2_roof_leak_winter',
      interlocutorRoleRu: 'Управдом / Ваад Байт (יוֹ״ר וַעַד הַבַּיִת)',
      speechHebrewWithNikkud: 'שָׁמַעְתִּי שֶׁיֵּשׁ נְזִילָה מֵהַגַּג בְּקוֹמָה 4 בִּגְלַל הַגְּשָׁמִים הַחֲזָקִים.',
      speechHebrewPlain: 'שמעתי שיש נזילה מהגג בקומה 4 בגלל הגשמים החזקים.',
      transcriptionRu: 'Shamá\'ti she-yesh nezilá me-ha-gag be-komá árba biglál ha-gshamím ha-chazakím.',
      translationRu: 'Я слышал, что протекает крыша на 4 этаже из-за сильных дождей.',
      tenantTipRu:
          'Гидроизоляция крыши (איטום גג) — зона ответственности общего домового комитета (ועד בית), так как крыша является общим имуществом (רכוש משותף).',
      responseOptions: [
        'כֵּן, הַמַּיִם מְטַפְטְפִים בַּסָּלוֹן. צָרִיךְ לְהַזְמִין אִישׁ אִטּוּם מִקֻּפַּת הַוַּעַד מִיָּד.',
        'לֹא נוֹרָא, פָּתַחְתִּי בְּרֵכַת שְׂחִיָּה בַּסָּלוֹן שֶׁלִּי.',
        'אֲנִי מְסָרֵב לְשַׁלֵּם וַעַד בַּיִת לְעוֹלָם.',
      ],
      bestResponseIndex: 0,
      explanationRu:
          '«איש איטום מקופת הוועד» — именно так решаются проблемы протекающей крыши за счет общего фонда дома.',
    ),
    HousingScenarioQuestion(
      id: 'scen_3_arnona_discount_city',
      interlocutorRoleRu: 'Сотрудник отдела Арноны в мэрии (עִירִיָּה)',
      speechHebrewWithNikkud: 'בֹּקֶר טוֹב. בָּאתָ לְהַעֲבִיר אֶת חֶשְׁבּוֹן הָאַרְנוֹנָה וּלְבַקֵּשׁ הֲנָחָה?',
      speechHebrewPlain: 'בוקר טוב. באת להעביר את חשבון הארנונה ולבקש הנחה?',
      transcriptionRu: 'Boker tov. Báta le-ha\'avír et cheshbón ha-arnóna u-levakésh hanachá?',
      translationRu: 'Доброе утро. Вы пришли перевести счет арноны и запросить льготу?',
      tenantTipRu:
          'Скидка репатрианта (הנחת עולה חדש) в мэрии требует удостоверение нового репатрианта (תעודת עולה) и подписанный договор аренды минимум на 1 год.',
      responseOptions: [
        'כֵּן, הִנֵּה חוֹזֶה הַשְּׂכִירוּת הֶחָתוּם וּתְעוּדַת הָעוֹלֶה שֶׁלִּי לְקַבָּלַת הֲנָחַת עֹלֶה חָדָשׁ.',
        'אֲנִי רוֹצֶה שֶׁהָעִירִיָּה תְּשַׁלֵּם לִי אֶת הַשְּׂכִירוּת עַל הַדִּירָה.',
        'מָה זֶה אַרְנוֹנָה? לָמָּה מְשַׁלְּמִים מִסִּים לָעִירִיָּה?',
      ],
      bestResponseIndex: 0,
      explanationRu:
          'Пакет документов «חוזה חתום + תעודת עולה» позволяет моментально получить экономию тысяч шекелей на городском налоге.',
    ),
    HousingScenarioQuestion(
      id: 'scen_4_contract_extension_option',
      interlocutorRoleRu: 'Хозяин квартиры (בַּעַל הַבַּיִת)',
      speechHebrewWithNikkud: 'הַחוֹזֶה שֶׁלָּנוּ מִסְתַּיֵּם בְּעוֹד חָדְשַׁיִם. מָה הַתָּכְנִיּוֹת שֶׁלְּךָ לַשָּׁנָה הַבָּאָה?',
      speechHebrewPlain: 'החוזה שלנו מסתיים בעוד חודשיים. מה התוכניות שלך לשנה הבאה?',
      transcriptionRu: 'Ha-chozéh shelánu mistayém be-ód chodsháyim. Mah ha-tochniyót shelkhá la-shaná ha-ba\'á?',
      translationRu: 'Наш договор заканчивается через два месяца. Какие у тебя планы на следующий год?',
      tenantTipRu:
          'Если в договоре прописана опция («אופציה להארכה»), сообщи хозяину за 60-90 дней о намерении остаться по зафиксированной в контракте цене.',
      responseOptions: [
        'אֲנִי מְאוֹד מְרֻצֶּה מֵהַדִּירָה וּמְעֻנְיָן לְמַמֵּשׁ אֶת הָאוֹפְּצְיָה לְשָׁנָה נוֹסֶפֶת כְּפִי שֶׁמֻּסְכָּם.',
        'אֲנִי עוֹזֵב מָחָר בַּבֹּקֶר בְּלִי לְהַגִּיד מִלָּה וְלוֹקֵחַ אֶת הַדְּלָתוֹת.',
        'תַּחְתֹּךְ לִי אֶת הַמְּחִיר בַּחֲצִי אוֹ שֶׁאֲנִי שׁוֹבֵר אֶת הַקִּירוֹת.',
      ],
      bestResponseIndex: 0,
      explanationRu:
          '«לממש את האופציה לשנה נוספת» — грамотная формулировка реализации законного права на продление аренды.',
    ),
    HousingScenarioQuestion(
      id: 'scen_5_clogged_shower_drain',
      interlocutorRoleRu: 'Сантехник (אִינְסְטָלָטוֹר)',
      speechHebrewWithNikkud: 'שָׁלוֹם, הִגַּעְתִּי לִבְדֹּק אֶת הַסְּתִימָה בַּמִּקְלַחַת. הַמַּיִם יוֹרְדִים לְאַט?',
      speechHebrewPlain: 'שלום, הגעתי לבדוק את הסתימה במקלחת. המים יורדים לאט?',
      transcriptionRu: 'Shalom, higá\'ti livdók et ha-stimá ba-mikláchat. Ha-máyim yordím le\'át?',
      translationRu: 'Здравствуйте, я пришел проверить засор в душе. Вода уходит медленно?',
      tenantTipRu:
          '«סְתִימָה» (стима́) — засор. «הַמַּיִם לֹא יוֹרְדִים» — вода не уходит. Покажи мастеру сифон и главный сливной трап в полу.',
      responseOptions: [
        'כֵּן, הַמַּיִם מַמָּשׁ עוֹמְדִים וְעוֹלִים עַל גְּדוֹתֵיהֶם. נִרְאֶה שֶׁיֵּשׁ סְתִימָה עֲמֻקָּה בַּצַּנֶּרֶת.',
        'אֵין שׁוּם סְתִימָה, סְתָם קָרָאתִי לְךָ כְּדֵי שֶׁנְּשַׂחֵק שַׁחְמָט.',
        'אֲנִי שׁוֹפֵךְ מֵלַח וְשֶׁמֶן לְתוֹךְ הַכִּיּוֹר כָּל יוֹם.',
      ],
      bestResponseIndex: 0,
      explanationRu:
          '«המים עומדים, סתימה עמוקה בצנרת» точно описывает проблему для оперативной прочистки трубы тросом.',
    ),
  ];

  /// 16 essential Israeli apartment rental and real estate vocabulary terms.
  static const List<Map<String, String>> housingGlossary = [
    {
      'hebrew': 'שְׂכִירוּת',
      'plain': 'שכירות',
      'transcription': 'skhirút',
      'translation': 'Аренда жилья',
      'tip': '«חוֹזֶה שְׂכִירוּת בִּלְתִּי מֻגֶּנֶת» — стандартный договор свободной аренды жилья в Израиле.',
    },
    {
      'hebrew': 'בַּעַל הַבַּיִת',
      'plain': 'בעל הבית',
      'transcription': 'ba\'al ha-báyit',
      'translation': 'Арендодатель (хозяин квартиры)',
      'tip': 'В женском роде — «בַּעֲלַת הַבַּיִת» (баала́т ха-ба́йит).',
    },
    {
      'hebrew': 'שׂוֹכֵר',
      'plain': 'שוכר',
      'transcription': 'sochér',
      'translation': 'Арендатор (квартиросъемщик)',
      'tip': 'В женском роде — «שׂוֹכֶרֶת» (сохе́рет).',
    },
    {
      'hebrew': 'צֶ׳ק בִּטָּחוֹן',
      'plain': 'צ׳ק ביטחון',
      'transcription': 'tzek bitachón',
      'translation': 'Гарантийный чек безопасности',
      'tip': 'Выписывается хозяину без даты с пометкой «לביטחון בלבד». Не обналичивается без решения суда.',
    },
    {
      'hebrew': 'עַרְבוּת בַּנְקָאִית',
      'plain': 'ערבות בנקאית',
      'transcription': 'arvút banka\'ít',
      'translation': 'Банковская гарантия',
      'tip': 'Замораживание средств на счете в банке в пользу арендодателя (самый надежный для хозяина вид залога).',
    },
    {
      'hebrew': 'עָרֵב',
      'plain': 'ערב',
      'transcription': 'arév',
      'translation': 'Поручитель по договору',
      'tip': 'Лицо, обязующееся оплатить долг арендатора при нарушении контракта (мн.ч. «עֲרֵבִים»).',
    },
    {
      'hebrew': 'אַרְנוֹנָה',
      'plain': 'ארנונה',
      'transcription': 'arnóna',
      'translation': 'Муниципальный налог на недвижимость',
      'tip': 'Оплачивается арендатором раз в 2 месяца в мэрию (ирия). Новые репатрианты получают скидку до 90%!',
    },
    {
      'hebrew': 'וַעַד בַּיִת',
      'plain': 'ועד בית',
      'transcription': 'va\'ad báyit',
      'translation': 'Домовой комитет (взнос на уборку и лифт)',
      'tip': 'Ежемесячный взнос жильцов на освещение подъезда, уборку, полив сада и техобслуживание лифта.',
    },
    {
      'hebrew': 'דּוּד שֶׁמֶשׁ',
      'plain': 'דוד שמש',
      'transcription': 'dud shémesh',
      'translation': 'Солнечный бойлер на крыше',
      'tip': 'Обеспечивает бесплатную горячую воду все солнечное лето; зимой включают электронагрев (דוד חשמל).',
    },
    {
      'hebrew': 'מַמָּ״ד',
      'plain': 'ממ״ד',
      'transcription': 'mamád',
      'translation': 'Защитная комната в квартире (Мерхав Муган)',
      'tip': 'Герметичная комната безопасности со стальными ставнями на окне для защиты при сиренах.',
    },
    {
      'hebrew': 'בְּלַאי סָבִיר',
      'plain': 'בלאי סביר',
      'transcription': 'blay savír',
      'translation': 'Естественный износ квартиры и техники',
      'tip': 'Поломки от старости и износа обязан чинить хозяин квартиры за свой счет по закону.',
    },
    {
      'hebrew': 'אוֹפְּצְיָה',
      'plain': 'אופציה',
      'transcription': 'óptzya',
      'translation': 'Опция продления договора на следующий год',
      'tip': 'Преимущественное право арендатора продлить контракт на тех же или оговоренных условиях.',
    },
    {
      'hebrew': 'שׂוֹכֵר חֲלִיפִי',
      'plain': 'שוכר חליפי',
      'transcription': 'sochér chalifí',
      'translation': 'Заменяющий арендатор при досрочном выезде',
      'tip': 'Новый жилец, которого находит арендатор для закрытия договора без штрафов.',
    },
    {
      'hebrew': 'נְזִילָה',
      'plain': 'נזילה',
      'transcription': 'nezilá',
      'translation': 'Протечка воды / течь',
      'tip': '«יֵשׁ נְזִילָה בַּכִּיּוֹר» — течет под раковиной. «נְזִילָה מֵהַתִּקְרָה» — протечка с потолка от соседей.',
    },
    {
      'hebrew': 'סְתִימָה',
      'plain': 'סתימה',
      'transcription': 'stimá',
      'translation': 'Засор в трубе или раковине',
      'tip': '«יֵשׁ סְתִימָה בַּמִּקְלַחַת» — засор в душе, вода не уходит.',
    },
    {
      'hebrew': 'דְּמֵי תִּוּוּךְ',
      'plain': 'דמי תיווך',
      'transcription': 'dméy tivúch',
      'translation': 'Комиссия агентства недвижимости (маклера)',
      'tip': 'Обычно составляет сумму месячной аренды + НДС. Объявления «לְלֹא תִּוּוּךְ» — без посредников.',
    },
  ];
}
