import '../../domain/entities/ai_roleplay_character.dart';
import '../../domain/entities/ai_roleplay_scenario.dart';

abstract final class AiRoleplaySeedData {
  static const List<AiRoleplayScenario> scenarios = [
    AiRoleplayScenario(
      id: 'scene_cafe',
      titleRussian: 'Кофейня в Тель-Авиве',
      category: 'Быт и гастрономия',
      level: 'A1-A2',
      badgeEmoji: '☕',
      descriptionRussian:
          'Закажи любимый кофе, выбери вид молока, сладость и выпечку в шумном кафе на Дизенгоф.',
      character: AiRoleplayCharacter(
        id: 'barista_yoav',
        nameHebrew: 'יוֹאָב הַבָּרִיסְטָה',
        nameRussian: 'Йоав, бариста',
        roleRussian: 'Бариста в спешелти кафе на Дизенгоф',
        avatarEmoji: '☕',
        initialGreetingHebrew:
            'שָׁלוֹם! מָה לְהָכִין לְךָ הַיּוֹם? קָפֶה חַם אוֹ קַר?',
        initialGreetingRussian:
            'Привет! Что приготовить тебе сегодня? Горячий кофе или холодный?',
        initialGreetingTranslit:
            'Shalom! Ma lehakhin lekha hayom? Kafe cham o kar?',
        systemPrompt:
            'Ты — дружелюбный израильский бариста Йоав. Общайся на естественном разговорном иврите, помогай с заказом и мягко поправляй ошибки.',
      ),
      suggestedPrompts: [
        SuggestedPromptItem(
          hebrew: 'אֶפְשָׁר קָפֶה הָפוּךְ קָטָן, בְּבַקָּשָׁה?',
          russian: 'Можно маленький капучино, пожалуйста?',
        ),
        SuggestedPromptItem(
          hebrew: 'יֵשׁ לָכֶם חָלָב שִׁבֹּלֶת שׁוּעָל?',
          russian: 'У вас есть овсяное молоко?',
        ),
        SuggestedPromptItem(
          hebrew: 'כַּמָּה זֶה עוֹלֶה? אֶפְשָׁר בְּאַשְׁרַאי?',
          russian: 'Сколько это стоит? Можно оплатить картой?',
        ),
        SuggestedPromptItem(
          hebrew: 'אֲנִי אֶשְׂמַח גַּם לְקְרוּאָסוֹן שׁוֹקוֹלָד.',
          russian: 'Я также буду рад шоколадному круассану.',
        ),
      ],
    ),
    AiRoleplayScenario(
      id: 'scene_supermarket',
      titleRussian: 'Супермаркет и касса',
      category: 'Быт и покупки',
      level: 'A1',
      badgeEmoji: '🛒',
      descriptionRussian:
          'Оформи покупки на кассе, спроси про скидки, пакеты и оплати картой.',
      character: AiRoleplayCharacter(
        id: 'cashier_rina',
        nameHebrew: 'רִינָה הַקֻּפָּאִית',
        nameRussian: 'Рина, кассир',
        roleRussian: 'Кассир в супермаркете Шуферсаль',
        avatarEmoji: '🛒',
        initialGreetingHebrew:
            'שָׁלוֹם, צָרִיךְ שַׂקִּיּוֹת? יֵשׁ לְךָ כַּרְטִיס מוֹעֲדוֹן?',
        initialGreetingRussian:
            'Здравствуйте! Нужны пакеты? Есть клубная карта?',
        initialGreetingTranslit:
            'Shalom, tsarikh sakiyot? Yesh lekha kartis moadon?',
        systemPrompt:
            'Ты — вежливая кассир Рина в супермаркете. Спрашивай о пакетах, оплате и чеке.',
      ),
      suggestedPrompts: [
        SuggestedPromptItem(
          hebrew: 'כֵּן, שְׁתֵּי שַׂקִּיּוֹת בְּבַקָּשָׁה.',
          russian: 'Да, два пакета пожалуйста.',
        ),
        SuggestedPromptItem(
          hebrew: 'אֵין לִי כַּרְטִיס מוֹעֲדוֹן. אֶפְשָׁר בְּאַשְׁרַאי?',
          russian: 'У меня нет карты клуба. Можно картой?',
        ),
        SuggestedPromptItem(
          hebrew: 'אֶפְשָׁר קַבָּלָה, בְּבַקָּשָׁה?',
          russian: 'Можно чек, пожалуйста?',
        ),
      ],
    ),
    AiRoleplayScenario(
      id: 'scene_transport',
      titleRussian: 'Автобус и Рав-Кав',
      category: 'Транспорт и город',
      level: 'A1-A2',
      badgeEmoji: '🚌',
      descriptionRussian:
          'Поездка на автобусе Дан/Эгед: проверка валидации Рав-Кава, остановки и маршруты.',
      character: AiRoleplayCharacter(
        id: 'driver_moshe',
        nameHebrew: 'מֹשֶׁה הַנֶּהָג',
        nameRussian: 'Моше, водитель',
        roleRussian: 'Водитель автобуса маршрута 18',
        avatarEmoji: '🚌',
        initialGreetingHebrew:
            'בֹּקֶר טוֹב! תְּתַקֵּף בָּרַב־קַו בִּכְנִיסָה. לְאָן אַתָּה נוֹסֵעַ?',
        initialGreetingRussian:
            'Доброе утро! Приложи Рав-Кав на входе. Куда ты едешь?',
        initialGreetingTranslit:
            'Boker tov! Tetakef ba-Rav-Kav bi-khnisa. Lean ata nosea?',
        systemPrompt:
            'Ты — опытный водитель автобуса Моше. Отвечай коротко и по делу о маршрутах и остановках.',
      ),
      suggestedPrompts: [
        SuggestedPromptItem(
          hebrew: 'הָאוֹטוֹבּוּס הַזֶּה מַגִּיעַ לַתַּחֲנָה הַמֶּרְכָּזִית?',
          russian: 'Этот автобус едет на центральную автостанцию?',
        ),
        SuggestedPromptItem(
          hebrew: 'אֵיזֶה קַו מַגִּיעַ לַיָּם?',
          russian: 'Какой маршрут едет к морю?',
        ),
        SuggestedPromptItem(
          hebrew: 'תּוֹדָה, אֲנִי יוֹרֵד בַּתַּחֲנָה הַבָּאָה!',
          russian: 'Спасибо, я выхожу на следующей остановке!',
        ),
      ],
    ),
    AiRoleplayScenario(
      id: 'scene_clinic',
      titleRussian: 'Поликлиника и регистратура',
      category: 'Медицина и здоровье',
      level: 'A2',
      badgeEmoji: '🩺',
      descriptionRussian:
          'Визит в Купат Холим: подтверждение очереди, рецепты и кабинет врача.',
      character: AiRoleplayCharacter(
        id: 'secretary_tali',
        nameHebrew: 'טַלִי מֵהַמַּזְכִּירוּת',
        nameRussian: 'Тали, секретарь',
        roleRussian: 'Секретарь в регистратуре Купат Холим',
        avatarEmoji: '🩺',
        initialGreetingHebrew:
            'שָׁלוֹם! יֵשׁ לְךָ תּוֹר לָרוֹפֵא הַיּוֹם? תַּעֲבִיר כַּרְטִיס מַגְנֶטִי.',
        initialGreetingRussian:
            'Здравствуйте! У вас есть запись к врачу? Проведите карту.',
        initialGreetingTranslit:
            'Shalom! Yesh lekha tor la-rofe hayom? Taavir kartis magneti.',
        systemPrompt:
            'Ты — сотрудник регистратуры поликлиники Тали. Помогай с очередями, направлениями и рецептами.',
      ),
      suggestedPrompts: [
        SuggestedPromptItem(
          hebrew: 'יֵשׁ לִי תּוֹר לְרוֹפֵא מִשְׁפָּחָה בְּעֶשֶׂר.',
          russian: 'У меня запись к терапевту на 10:00.',
        ),
        SuggestedPromptItem(
          hebrew: 'אֵיפֹה הַחֶדֶר שֶׁל ד"ר לֵוִי?',
          russian: 'Где кабинет доктора Леви?',
        ),
        SuggestedPromptItem(
          hebrew: 'אֲנִי צָרִיךְ חִדּוּשׁ מִרְשָׁם לִתְרוּפָה.',
          russian: 'Мне нужно продление рецепта на лекарство.',
        ),
      ],
    ),
    AiRoleplayScenario(
      id: 'scene_rent',
      titleRussian: 'Аренда квартиры во Флорентине',
      category: 'Недвижимость',
      level: 'A2-B1',
      badgeEmoji: '🔑',
      descriptionRussian:
          'Обсуждение условий съема: цена, арнона, коммуналка, ремонт и дата въезда.',
      character: AiRoleplayCharacter(
        id: 'landlord_idan',
        nameHebrew: 'עִדָּן בַּעַל הַדִּירָה',
        nameRussian: 'Идан, арендодатель',
        roleRussian: 'Владелец уютной 2-комнатной квартиры',
        avatarEmoji: '🔑',
        initialGreetingHebrew:
            'הַי! רָצִיתָ לִרְאוֹת אֶת הַדִּירָה בִּפְלוֹרֶנְטִין? 2 חֲדָרִים עִם מַרְפֶּסֶת.',
        initialGreetingRussian:
            'Хай! Ты хотел посмотреть квартиру во Флорентине? 2 комнаты с балконом.',
        initialGreetingTranslit:
            'Hai! Ratsita lirot et ha-dira bi-Florentin? Shney khadarim im mirpeset.',
        systemPrompt:
            'Ты — арендодатель Идан. Рассказывай о квартире, коммунальных платежах и договоре.',
      ),
      suggestedPrompts: [
        SuggestedPromptItem(
          hebrew: 'כַּמָּה שְׂכַר הַדִּירָה לְחֹדֶשׁ?',
          russian: 'Сколько стоит аренда в месяц?',
        ),
        SuggestedPromptItem(
          hebrew: 'הַמְּחִיר כּוֹלֵל אַרְנוֹנָה וָוַעַד בַּיִת?',
          russian: 'Включает ли цена арнону и домовой комитет?',
        ),
        SuggestedPromptItem(
          hebrew: 'מָתַי אֶפְשָׁר לְהִכָּנֵס לַדִּירָה?',
          russian: 'Когда свободна дата въезда?',
        ),
      ],
    ),
    AiRoleplayScenario(
      id: 'scene_free_chat',
      titleRussian: 'Разговор с израильским другом',
      category: 'Свободное общение',
      level: 'Любой уровень',
      badgeEmoji: '💬',
      descriptionRussian:
          'Непринужденный разговор на иврите обо всем: планы, впечатления, жизнь в Израиле.',
      character: AiRoleplayCharacter(
        id: 'friend_noam',
        nameHebrew: 'נֹעַם',
        nameRussian: 'Ноам, друг из Тель-Авива',
        roleRussian: 'Коренной израильтянин, открытый к общению',
        avatarEmoji: '💬',
        initialGreetingHebrew:
            'מָה הוֹלֵךְ, אָחִי? אֵיךְ עוֹבֵר הַיּוֹם? מָה חָדָשׁ אֶצְלְךָ?',
        initialGreetingRussian:
            'Как дела, бро? Как проходит день? Что нового у тебя?',
        initialGreetingTranslit:
            'Ma holekh, akhi? Eikh over hayom? Ma chadash etzlekha?',
        systemPrompt:
            'Ты — теплый израильский друг Ноам. Поддерживай непринужденную беседу, используй разговорный сленг и помогай собеседнику освоить язык.',
      ),
      suggestedPrompts: [
        SuggestedPromptItem(
          hebrew: 'הַכֹּל סַבָּבָה, אֲנִי לוֹמֵד עִבְרִית עַכְשָׁו!',
          russian: 'Все отлично, я сейчас учу иврит!',
        ),
        SuggestedPromptItem(
          hebrew: 'הָיִיתִי בַּיָּם הַיּוֹם, הָיָה מֶזֶג אֲוִיר מְצֻיָּן.',
          russian: 'Я был на море сегодня, погода была отличная.',
        ),
        SuggestedPromptItem(
          hebrew: 'מָה הַתָּכְנִיּוֹת שֶׁלְּךָ לְסוֹף הַשָּׁבוּעַ?',
          russian: 'Какие у тебя планы на выходные?',
        ),
      ],
    ),
  ];
}
