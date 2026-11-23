import '../../domain/entities/chat_channel.dart';

/// Authentic Israeli WhatsApp chat threads and abbreviations data.
final class ChatSlangSeedData {
  const ChatSlangSeedData._();

  static const List<ChatThread> threads = [
    // -------------------------------------------------------------------------
    // 🏢 1. VAAD BAYIT (Домовой комитет)
    // -------------------------------------------------------------------------
    ChatThread(
      id: 'thread_vaad_bayit',
      category: ChatChannelCategory.buildingCommittee,
      groupNameRu: 'Ваад Байт — ул. Герцль 42',
      groupNameHebrew: 'וַעַד בַּיִת — הֶרְצְל 42',
      participantsSummaryRu: '18 соседей, включая управдома Шломо и старшую по подъезду Рину',
      messages: [
        ChatMessage(
          id: 'msg_v1',
          senderName: 'שלמה (ועד)',
          senderRoleRu: 'Управдом',
          isMe: false,
          timeString: '10:14',
          textHebrewWithNikkud: 'שְׁכֵנִים יְקָרִים, מִישֶׁהוּ שׁוּב הִשְׁאִיר קוֹרְקִינֶט חַשְׁמַלִּי בְּאֶמְצַע הַלּוֹבִּי. זֶה חוֹסֵם אֶת הַמַּעֲלִית!',
          textPlain: 'שכנים יקרים, מישהו שוב השאיר קורקינט חשמלי באמצע הלובי. זה חוסם את המעלית!',
          transcriptionRu: 'Shchenim yekarim, mishehu shuv hish\'ir korkinet chashmali be-emtza ha-lobi. Ze chosem et ha-maalit!',
          translationRu: 'Дорогие соседи, кто-то снова оставил электросамокат прямо посреди лобби. Это блокирует лифт!',
          slangDictionary: {
            'קוֹרְקִינֶט': 'Электросамокат (национальный транспорт в городах Израиля)',
            'לוֹבִּי': 'Подъезд / холл первого этажа дома',
          },
        ),
        ChatMessage(
          id: 'msg_v2',
          senderName: 'רוני קומה 3',
          senderRoleRu: 'Сосед с 3 этажа',
          isMe: false,
          timeString: '10:16',
          textHebrewWithNikkud: 'חחח כָּל שָׁבוּעַ אוֹתוֹ סִפּוּר. אֶפְשָׁר אָמָלָ״ק? מִי בָּא לְהַזִיז אוֹתוֹ?',
          textPlain: 'חחח כל שבוע אותו סיפור. אפשר אמלק? מי בא להזיז אותו?',
          transcriptionRu: 'Chahaha kol shavua oto sipur. Efshar amlak? Mi ba lehaziz oto?',
          translationRu: 'Ахаха, каждую неделю одна и та же история. Можно кратко (TL;DR)? Кто придет его убрать?',
          slangDictionary: {
            'חחח': 'Ха-ха-ха (стандартное обозначение смеха в чатах)',
            'אָמָלָ״ק': 'АМАЛАК — אָרוֹךְ מִדַּי; לֹא קָרָאתִי (Слишком длинно; не читал / TL;DR)',
          },
        ),
        ChatMessage(
          id: 'msg_v3',
          senderName: 'רינה קומה 2',
          senderRoleRu: 'Соседка со 2 этажа',
          isMe: false,
          timeString: '10:19',
          textHebrewWithNikkud: 'תַּכְלֶס זֶה מְסֻכָּן לַיְּלָדִים. וְגַם תַּזְכֹּרֶת: הַיּוֹם יוֹם הַנִּקָּיוֹן הַחָדְשִׁי, לֹא לְהוֹצִיא זֶבֶל לַחֲדַר מַדְרֵגוֹת.',
          textPlain: 'תכלס זה מסוכן לילדים. וגם תזכורת: היום יום הניקיון החודשי, לא להוציא זבל לחדר מדרגות.',
          transcriptionRu: 'Takhles ze mesukan la-yeladim. Ve-gam tazkoret: hayom yom ha-nikayon ha-chodshi, lo lehotzi zevel la-chadar madregot.',
          translationRu: 'По факту (тахлес) это опасно для детей. И еще напоминание: сегодня генеральная уборка, не выставляйте мусор на лестничную клетку.',
          slangDictionary: {
            'תַּכְלֶס': 'Тахлес — по факту, по сути, если говорить серьезно',
          },
        ),
      ],
      challenge: ChatReplyChallenge(
        id: 'chal_vaad',
        contextRu: 'Самокат действительно твоего гостя. Как ответить вежливо, с извинением и обещанием немедленно убрать?',
        optionsHebrewWithNikkud: [
          'סְלִיחָה עֲנָקִית! זֶה שֶׁל חָבֵר שֶׁלִּי, אֲנִי יוֹרֵד מִיָּד לְהַזִיז אֶת זֶה לַמַּחְסָן. סוֹפַ״שׁ נָעִים!',
          'לָמָּה אַתֶּם תָּמִיד מִתְלוֹנְנִים? יֵשׁ מַסְפִּיק מָקוֹם לְכֻלָּם בַּלּוֹבִּי.',
          'אֲנִי לֹא מֵבִין עִבְרִית, תִּכְתְּבוּ בְּאַנְגְּלִית.',
        ],
        optionsTranslationRu: [
          'Огромные извинения! Это самокат моего друга, спускаюсь прямо сейчас переставить его в кладовку. Хороших выходных!',
          'Почему вы вечно жалуетесь? В лобби полно места для всех.',
          'Я не понимаю иврит, пишите по-английски.',
        ],
        bestOptionIndex: 0,
        feedbackRu:
          '«סליחה ענקית... אני יורד מיד להזיז» — идеальный ответ: снимает напряжение соседей и демонстрирует добрососедство («יחסי שכנות טובים»).',
        culturalEtiquetteRuleRu:
          'В чатах Ваад Байта в Израиле лучше сразу признать неловкость и закончить фразу дружелюбным «סופ״ש נעים» или «שבת שלום», чтобы не провоцировать соседскую перепалку.',
      ),
    ),

    // -------------------------------------------------------------------------
    // 💻 2. HIGH-TECH STARTUP TEAM (Команда в стартапе)
    // -------------------------------------------------------------------------
    ChatThread(
      id: 'thread_tech_team',
      category: ChatChannelCategory.highTechTeam,
      groupNameRu: 'Хайтек Dev Team — Slack/WhatsApp',
      groupNameHebrew: 'צֶוֶת Dev — סְטָארְטְאַפּ',
      participantsSummaryRu: 'Тимлид Томер, фронтендер Даниэль, QA Майя и ты',
      messages: [
        ChatMessage(
          id: 'msg_t1',
          senderName: 'תומר (Team Lead)',
          senderRoleRu: 'Тимлид',
          isMe: false,
          timeString: '11:30',
          textHebrewWithNikkud: 'בֹּקֶר טוֹב צֶוֶת! הַפְּרוֹד קְצָת עוֹשֶׂה בְּעָיוֹת אַחֲרֵי הַדִּפְלוֹי. מִי בַּמִּשְׂרָד הַיּוֹם לְסִינְק מָהִיר?',
          textPlain: 'בוקר טוב צוות! הפרוד קצת עושה בעיות אחרי הדיפלוי. מי במשרד היום לסינק מהיר?',
          transcriptionRu: 'Boker tov tzevet! Ha-prod ktzat ose baayot acharey ha-diploy. Mi ba-misrad hayom le-sink mahir?',
          translationRu: 'Доброе утро, команда! Прод немного сбоит после деплоя. Кто сегодня в офисе на быстрый синкап?',
          slangDictionary: {
            'פְּרוֹד': 'Прод (production environment)',
            'סִינְק': 'Синкап / короткий созвон или летучка',
          },
        ),
        ChatMessage(
          id: 'msg_t2',
          senderName: 'דניאל (Front)',
          senderRoleRu: 'Фронтенд-разработчик',
          isMe: false,
          timeString: '11:32',
          textHebrewWithNikkud: 'אֲנִי פֹּה! יֵשׁ פִּנּוּקִים בַּמִּטְבָּח — קְרוּאָסוֹנִים חַמִּים. חֲבָלָ״ז!',
          textPlain: 'אני פה! יש פינוקים במטבח — קרואסונים חמים. חבל״ז!',
          transcriptionRu: 'Ani po! Yesh pinukim ba-mitbach — kruasonim chamim. Chavalaz!',
          translationRu: 'Я тут! На кухне ништяки/угощения (пинуким) — горячие круассаны. Просто бомба (хавальаз)!',
          slangDictionary: {
            'פִּנּוּקִים': 'Пинуким — приятные вкусняшки, фрукты или выпечка от работодателя в офисе',
            'חֲבָלָ״ז': 'Хавальаз — חֲבָל עַל הַזְּמַן (досл. «жаль времени», сленг: «невероятно круто / восторг»)',
          },
        ),
        ChatMessage(
          id: 'msg_t3',
          senderName: 'מאיה (QA)',
          senderRoleRu: 'Тестировщик',
          isMe: false,
          timeString: '11:35',
          textHebrewWithNikkud: 'פַּחַחַח תָּמִיד אַתָּה חוֹשֵׁב רַק עַל הָאֹכֶל. בָּדַקְתִּי אֶת הַבַּאג, זֶה אֶצְלֵנוּ בַּקְּלַיֶּנְט. אֲנִי שׁוֹלַחַת לוֹגִים.',
          textPlain: 'פחחח תמיד אתה חושב רק על האוכל. בדקתי את הבאג, זה אצלנו בקליינט. אני שולחת לוגים.',
          transcriptionRu: 'Pchahaha tamid ata choshev rak al ha-ochel. Badakti et ha-bag, ze etzlenu ba-klient. Ani sholachat logim.',
          translationRu: 'Пхаха, ты вечно думаешь только о еде. Я проверила баг, это у нас на клиенте. Скидываю логи.',
          slangDictionary: {
            'פַּחַח': 'Пххх — ироничный или саркастический смех',
          },
        ),
      ],
      challenge: ChatReplyChallenge(
        id: 'chal_tech',
        contextRu: 'Тимлид спрашивает статус твоей фичи. Как написать на офисном хайтек-сленге, что ты уже пушишь фикс?',
        optionsHebrewWithNikkud: [
          'אֲנִי כְּבָר עַל זֶה, מַעֲלֶה פִּיקְס עוֹד 5 דַּקּוֹת וְעָפִיתִי לַקָּפֶה בַּמִּרְפֶּסֶת.',
          'אֲנִי לֹא רוֹצֶה לְתַקֵּן אֶת זֶה, שֶׁמָּאיָה תַּעֲשֶׂה אֶת הָעֲבוֹדָה.',
          'שָׁלוֹם אֲדוֹנִי הַמְּנַהֵל, בְּבַקָּשָׁה תַּמְתִּין עַד שָׁבוּעַ הַבָּא.',
        ],
        optionsTranslationRu: [
          'Я уже занимаюсь этим, выкатываю фикс через 5 минут и побежал за кофе на балкон.',
          'Я не хочу это чинить, пусть Майя сделает эту работу.',
          'Здравствуйте, господин начальник, пожалуйста подождите до следующей недели.',
        ],
        bestOptionIndex: 0,
        feedbackRu:
          '«אני כבר על זה... ועפתי לקפה» — эталонный непринужденный стиль израильского стартапа: готовность взять ответственность и дружеский тон.',
        culturalEtiquetteRuleRu:
          'В израильском хайтеке нет субординационной дистанции («адони а-менаэль» звучит дико). Общаются на «ты», прямо, по существу и с юмором.',
      ),
    ),

    // -------------------------------------------------------------------------
    // 🍻 3. WEEKEND FRIENDS (Планы на вечер пятницы)
    // -------------------------------------------------------------------------
    ChatThread(
      id: 'thread_friends',
      category: ChatChannelCategory.weekendFriends,
      groupNameRu: 'Друзья — вечер на Дизенгоф',
      groupNameHebrew: 'חֲבֵרִים בְּדִיזֶנְגּוֹף',
      participantsSummaryRu: 'Юваль, Ноа, Эйтан и ты',
      messages: [
        ChatMessage(
          id: 'msg_f1',
          senderName: 'יובל',
          senderRoleRu: 'Организатор вечера',
          isMe: false,
          timeString: '20:15',
          textHebrewWithNikkud: 'וַאלְלָה הִזְמַנְתִּי מָקוֹם בַּבָּאר בְּדִיזֶנְגּוֹף לְ-21:30. מִי זּוֹרֵם?',
          textPlain: 'וואלה הזמנתי מקום בבאר בדיזנגוף ל-21:30. מי זורם?',
          transcriptionRu: 'Walla hizmanti makom ba-bar be-Dizengoff le-21:30. Mi zorem?',
          translationRu: 'Ого, я забронировал столик в баре на Дизенгоф на 21:30. Кто в деле (кто «течет»/за)?',
          slangDictionary: {
            'וַאלְלָה': 'Валла — ого / вот это да / правда',
            'זוֹרֵם': 'Зорэм (досл. «течет») — лёгок на подъем, в деле, согласен на движуху',
          },
        ),
        ChatMessage(
          id: 'msg_f2',
          senderName: 'נועה',
          senderRoleRu: 'Подруга',
          isMe: false,
          timeString: '20:18',
          textHebrewWithNikkud: 'בָּרוּר שֶׁאֲנִי בָּאָה! אֲבָל קְצָת בִּלְתִּי לִמְצֹא חֲנָיָה בָּאֵזוֹר, עָדִיף לָקַחַת מוֹנִית.',
          textPlain: 'ברור שאני באה! אבל קצת בלתי למצוא חניה באזור, עדיף לקחת מונית.',
          transcriptionRu: 'Barur she-ani baa! Aval ktzat bilti limtzo chanaya ba-ezor, adif lakachat monit.',
          translationRu: 'Конечно я иду! Но найти парковку в этом районе — просто анриал (бильти), лучше взять такси.',
          slangDictionary: {
            'בִּלְתִּי': 'Бильти (от בלתי אפשרי) — анриал, невозможно, невыносимо',
          },
        ),
      ],
      challenge: ChatReplyChallenge(
        id: 'chal_friends',
        contextRu: 'Ты опаздываешь на 10 минут из-за пробок, но точно будешь. Как написать на сленге?',
        optionsHebrewWithNikkud: [
          'עַפְתִּי עַל מוֹנִית! מַגִּיעַ בְּאֵחוּר קַל שֶׁל 10 דַּקּוֹת בְּקַטְנָה, תַּזְמִינוּ לִי בִּירָה.',
          'מִצְטַעֵר מְאֹד, בִּגְלַל כֹּחַ עֶלְיוֹן אֵינֶנִּי יָכוֹל לְהַגִּיעַ בַּזְּמַן הַנָּקוּב.',
          'תְּבַטְּלוּ אֶת הַכֹּל, אֲנִי הוֹלֵךְ לִישׁוֹן.',
        ],
        optionsTranslationRu: [
          'Я уже в такси! Прибуду с легким опозданием на 10 минут, ерунда (бе-ктана), закажите мне пиво.',
          'Крайне сожалею, по причине непреодолимой силы не имею возможности прибыть в назначенное время.',
          'Отменяйте всё, я иду спать.',
        ],
        bestOptionIndex: 0,
        feedbackRu:
          '«עפתי על מונית... בקטנה» — живой, расслабленный израильский сленг в дружеском кругу.',
        culturalEtiquetteRuleRu:
          'Опоздание на 10-15 минут в пятницу вечером в Израиле («בקטנה») воспринимается спокойно, если заранее весело предупредить в чате.',
      ),
    ),
  ];

  /// 16 essential Israeli WhatsApp chat abbreviations & slang terms.
  static const List<Map<String, String>> chatSlangGlossary = [
    {
      'abbreviation': 'חחח',
      'fullHebrew': 'חָה-חָה-חָה',
      'transcription': 'chahaha',
      'meaningRu': 'Смех в переписке (ха-ха-ха). Чем больше букв «ח», тем смешнее.',
      'category': 'Эмоции',
    },
    {
      'abbreviation': 'אמלק',
      'fullHebrew': 'אָרוֹךְ מִדַּי; לֹא קָרָאתִי',
      'transcription': 'amlak',
      'meaningRu': 'Слишком длинно, не читал (эквивалент англ. TL;DR). Краткая суть текста.',
      'category': 'Аббревиатуры',
    },
    {
      'abbreviation': 'תכלס',
      'fullHebrew': 'תַּכְלֶס',
      'transcription': 'takhles',
      'meaningRu': 'По факту, по сути, если говорить начистоту.',
      'category': 'Сленг',
    },
    {
      'abbreviation': 'חבלז',
      'fullHebrew': 'חֲבָל עַל הַזְּמַן',
      'transcription': 'chaval\'az',
      'meaningRu': 'Невероятно круто / потрясающе (букв. «жаль времени»).',
      'category': 'Аббревиатуры',
    },
    {
      'abbreviation': 'סופ״ש',
      'fullHebrew': 'סוֹף שָׁבוּעַ',
      'transcription': 'sofash',
      'meaningRu': 'Выходные (пятница и суббота). Главное слово недели!',
      'category': 'Аббревиатуры',
    },
    {
      'abbreviation': 'פחח',
      'fullHebrew': 'פַּחַחַח',
      'transcription': 'pchchch',
      'meaningRu': 'Саркастический или скептический смешок («ну-ну, да конечно»).',
      'category': 'Эмоции',
    },
    {
      'abbreviation': 'וואלה',
      'fullHebrew': 'וַאלְלָה',
      'transcription': 'walla',
      'meaningRu': 'Универсальное слово: «ого!», «серьезно?», «вот оно как».',
      'category': 'Сленг',
    },
    {
      'abbreviation': 'עפתי',
      'fullHebrew': 'עַפְתִּי',
      'transcription': 'afti',
      'meaningRu': '«Я полетел» — срочно убегаю, ухожу, погнал.',
      'category': 'Сленг',
    },
    {
      'abbreviation': 'אשכרה',
      'fullHebrew': 'אַשְׁכָּרָה',
      'transcription': 'ashkara',
      'meaningRu': 'Реально, в натуре, в самом деле (из арабского).',
      'category': 'Сленг',
    },
    {
      'abbreviation': 'בקטנה',
      'fullHebrew': 'בְּקַטְנָה',
      'transcription': 'be-ktana',
      'meaningRu': 'Пустяки, мелочи жизни, ерунда, не парься.',
      'category': 'Сленг',
    },
    {
      'abbreviation': 'זורם',
      'fullHebrew': 'זוֹרֵם / זוֹרֶמֶת',
      'transcription': 'zorem / zoremet',
      'meaningRu': 'Лёгок на подъем, согласен на предложение, без претензий.',
      'category': 'Сленг',
    },
    {
      'abbreviation': 'בלתי',
      'fullHebrew': 'בִּלְתִּי אֶפְשָׁרִי',
      'transcription': 'bilti',
      'meaningRu': 'Невыносимый, анриал, невозможно вытерпеть.',
      'category': 'Сленг',
    },
    {
      'abbreviation': 'תותח',
      'fullHebrew': 'תּוֹתָח / תּוֹתָחִית',
      'transcription': 'totach / totachit',
      'meaningRu': 'Красавчик / огонь / профи (букв. «пушка»). Комплимент коллеге.',
      'category': 'Сленг',
    },
    {
      'abbreviation': 'איזה קטע',
      'fullHebrew': 'אֵיזֶה קֶטַע',
      'transcription': 'eize keta',
      'meaningRu': 'Вот это совпадение / прикол / забавный случай.',
      'category': 'Сленг',
    },
    {
      'abbreviation': 'פנוי / פנויה',
      'fullHebrew': 'פָּנוּי לְדַבֵּר?',
      'transcription': 'panuy / pnuyá',
      'meaningRu': 'Свободен говорить? (вежливый прелюд перед звонком).',
      'category': 'Этикет',
    },
    {
      'abbreviation': 'יאללה ביי',
      'fullHebrew': 'יַאלְלָה בַּיי',
      'transcription': 'yalla bye',
      'meaningRu': 'Классическое быстрое завершение разговора или переписки.',
      'category': 'Этикет',
    },
  ];
}
