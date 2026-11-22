import '../../domain/entities/job_interview_case.dart';
import '../../domain/entities/payslip_item.dart';

/// Seed data for Israeli job interview preparation, payslip analysis, and high-tech career vocabulary.
final class CareerSeedData {
  const CareerSeedData._();

  /// 10 interactive interview cases across 4 key Israeli workplace categories.
  static const List<InterviewQuestion> interviewQuestions = [
    InterviewQuestion(
      id: 'hr_1_tell_about_yourself',
      category: InterviewCategory.hrScreening,
      interviewerRoleRu: 'HR-менеджер (רַכֶּזֶת גִּיּוּס)',
      interviewerHebrewWithNikkud: 'סַפֵּר לִי קְצָת עַל עַצְמְךָ וְעַל הַנִּסָּיוֹן הַמִּקְצוֹעִי שֶׁלְּךָ.',
      interviewerHebrewPlain: 'ספר לי קצת על עצמך ועל הניסיון המקצועי שלך.',
      transcriptionRu: 'Sapér li ktzat al atzm\'khá ve-ál ha-nisayón ha-miktzoí shelkhá.',
      translationRu: 'Расскажи мне немного о себе и о своем профессиональном опыте.',
      mentorCareerTipRu:
          'Сабры ценят «дюклесс» (без лишней воды). Не начинай с детского сада: 2-3 минуты о стеке технологий, ключевом проекте и пользе, которую принес бизнесу.',
      responseOptions: [
        'אֲנִי מְפַתֵּחַ עִם 5 שְׁנוֹת נִסָּיוֹן בִּ-Flutter וְ-Dart. בַּתַּפְקִיד הָאַחֲרוֹן הוֹבַלְתִּי אֶת אַפְּלִיקַצְיַת הַפִּינְטֶק מֵאֶפֶס וְהִגַּעְנוּ לְמֵאָה אֶלֶף מִשְׁתַּמְּשִׁים.',
        'נוֹלַדְתִּי בְּמוֹסְקְבָה, לָמַדְתִּי בְּבֵית סֵפֶר וְתָמִיד אָהַבְתִּי מַחְשְׁבִים מִגִּיל עֶשֶׂר.',
        'הַכֹּל כָּתוּב בַּקּוֹרוֹת חַיִּים שֶׁלִּי, לֹא קָרָאת אוֹתָם?',
      ],
      bestResponseIndex: 0,
      explanationRu:
          'Первый ответ идеален: четко назван стек, стаж и измеримый результат (100k пользователей). Второй ответ слишком биографичный, третий — грубый «хамса» саботаж интервью.',
    ),
    InterviewQuestion(
      id: 'hr_2_why_leave_previous',
      category: InterviewCategory.hrScreening,
      interviewerRoleRu: 'Team Lead / ראש צוות',
      interviewerHebrewWithNikkud: 'לָמָּה הֶחְלַטְתָּ לַעֲזֹב אֶת הַחֶבְרָה הַקּוֹדֶמֶת?',
      interviewerHebrewPlain: 'למה החלטת לעזוב את החברה הקודמת?',
      transcriptionRu: 'Láma hechlát-ta la\'azóv et ha-chevrá ha-kodémet?',
      translationRu: 'Почему ты решил уйти из предыдущей компании?',
      mentorCareerTipRu:
          'Никогда не ругай бывшего босса («босс был дураком»). Фокусируйся на стремлении к профессиональному росту и новым челленджам («אתגרים»).',
      responseOptions: [
        'הַבּוֹס שֶׁלִּי הָיָה נוֹרָאִי וְכָל הַזְּמַן צָעַק עַל כֻּלָּם בַּמִּשְׂרָד.',
        'הִרְגַּשְׁתִּי שֶׁמִּצִּיתִי אֶת עַצְמִי בַּתַּפְקִיד וְחִפַּשְׂתִּי אֶתְגָּר חָדָשׁ שֶׁבּוֹ אוּכַל לְהַשְׁפִּיעַ יוֹתֵר עַל הָאַרְכִיטֶקְטוּרָה.',
        'הַחֶבְרָה הָיְתָה מְשַׁעֲמֶמֶת וְהַקּוֹד הָיָה פָּשׁוּט סְפָגֶטִי גָּרוּעַ.',
      ],
      bestResponseIndex: 1,
      explanationRu:
          'Фраза «מיציתי את עצמי» (митце́ти эт ацми — я исчерпал себя/вырос из роли) — классическая уважительная формула в израильском хайтеке.',
    ),
    InterviewQuestion(
      id: 'hr_3_hebrew_confidence',
      category: InterviewCategory.hrScreening,
      interviewerRoleRu: 'HR-директор (מְנַהֶלֶת מַשְׁאַבֵּי אֱנוֹשׁ)',
      interviewerHebrewWithNikkud: 'אֵיךְ הָעִבְרִית שֶׁלְּךָ? אַתָּה מַרְגִּישׁ בָּטוּחַ לְדַבֵּר בַּצֶּוֶת?',
      interviewerHebrewPlain: 'איך העברית שלך? אתה מרגיש בטוח לדבר בצוות?',
      transcriptionRu: 'Eikh ha-ivrít shelkhá? Atá margísh batúach le-dabér ba-tzévet?',
      translationRu: 'Как твой иврит? Ты чувствуешь уверенность общаться в команде?',
      mentorCareerTipRu:
          'Не стесняйся акцента! В Израиле важен «тахлес» (смысл) и желание пробовать. Честно скажи, что учишься и готов говорить, а сложные тех-термины переключать на английский.',
      responseOptions: [
        'אֲנִי מֵבִין הַכֹּל וּמְדַבֵּר, אֲבָל לִפְעָמִים חָסֵר לִי אֶוֹצַר מִלִּים. אֲנִי לֹא מִתְבַּיֵּשׁ לִשְׁאוֹל וּמִשְׁתַּפֵּר כָּל יוֹם!',
        'אֲנִי יוֹדֵעַ רַק שָׁלוֹם וְתוֹדָה, עָדִיף שֶׁנְּדַבֵּר רַק בְּרוּסִית.',
        'הָעִבְרִית שֶׁלִּי מֻשְׁלֶמֶת מֵאָה אָחוּז, אַף פַּעַם לֹא טוֹעֶה.',
      ],
      bestResponseIndex: 0,
      explanationRu:
          '«אני לא מתבייש לשאול» (Я не стесняюсь спрашивать) показывает здоровую инициативность и смелость, которую израильские работодатели ставят выше идеальной грамматики.',
    ),
    InterviewQuestion(
      id: 'sal_1_gross_expectations',
      category: InterviewCategory.salaryAndContract,
      interviewerRoleRu: 'VP R&D / סמנכ״ל פיתוח',
      interviewerHebrewWithNikkud: 'מָה צִפִּיּוֹת הַשָּׂכָר שֶׁלְּךָ בְּרָמַת בְּרוּטוֹ לְחֹדֶשׁ?',
      interviewerHebrewPlain: 'מה ציפיות השכר שלך ברמת ברוטו לחודש?',
      transcriptionRu: 'Mah tzipiyót ha-sakhár shelkhá be-ramát brúto le-chódesh?',
      translationRu: 'Каковы твои ожидания по зарплате брутто в месяц?',
      mentorCareerTipRu:
          'В Израиле зарплаты всегда обсуждаются в БРУТТО за месяц в шекелях (₪). Называй реалистичную вилку с запасом на торг (~10%).',
      responseOptions: [
        'לְפִי רָמַת הַנִּסָּיוֹן שֶׁלִּי וּטְבָלָאוֹת הַשָּׂכָר בַּשּׁוּק, אֲנִי מְכַוֵּן לִסְבִיבַת 28 עַד 32 אֶלֶף שֶׁקֶל בְּרוּטוֹ.',
        'אֲנִי רוֹצֶה עֲשָׂרָה אֲלָפִים שֶׁקֶל נֶטּוֹ לַיָּד וְשֶׁהַמִּסִּים לֹא יְעַנְיְנוּ אוֹתִי.',
        'תְּנוּ לִי כַּמָּה שֶׁאַתֶּם רוֹצִים, הָעִקָּר שֶׁתִּהְיֶה עֲבוֹדָה.',
      ],
      bestResponseIndex: 0,
      explanationRu:
          'В Израиле работодатели не мыслят «нетто на руки», так как налоги зависят от личных баллов (נקודות זיכוי). Вилка 28k-32k брутто с опорой на таблицы зарплат — профессиональный стандарт.',
    ),
    InterviewQuestion(
      id: 'sal_2_keren_hishtalmut',
      category: InterviewCategory.salaryAndContract,
      interviewerRoleRu: 'HR-менеджер (רַכֶּזֶת גִּיּוּס)',
      interviewerHebrewWithNikkud: 'בְּנוֹגֵעַ לַתְּנָאִים הַסּוֹצְיָאלִיִּים, יֵשׁ לְךָ שְׁאֵלוֹת עַל הַחֲבִילָה?',
      interviewerHebrewPlain: 'בנוגע לתנאים הסוציאליים, יש לך שאלות על החבילה?',
      transcriptionRu: 'Be-nogé\'a la-tna\'ím ha-sotzyáliyim, yesh lekhá she\'elót al ha-chavilá?',
      translationRu: 'Касательно соцпакета, есть ли у тебя вопросы по компенсации?',
      mentorCareerTipRu:
          '«Керен Иштальмут» (фонд повышения квалификации) — главный безналоговый инвестиционный бонус в Израиле (работодатель вкладывает 7.5%, работник 2.5%). Обязательно уточняй с первого месяца!',
      responseOptions: [
        'כֵּן, הַאִם הַחֶבְרָה מַפְרִישָׁה לְקֶרֶן הִשְׁתַּלְּמוּת מֵהַיּוֹם הָרִאשׁוֹן וְעַד הַתִּקְרָה הַחֲקִיקָתִית?',
        'לֹא אִכְפַּת לִי מִפֶּנְסְיָה וְקֶרֶן, תְּבִיאוּ לִי רַק כֶּסֶף מְזֻמָּן.',
        'מָה זֶה בִּכְלָל תְּנָאִים סוֹצְיָאלִיִּים? זֶה חוֹבָה בְּיִשְׂרָאֵל?',
      ],
      bestResponseIndex: 0,
      explanationRu:
          '«קרן השתלמות מהיום הראשון עד התקרה» — ключевой вопрос каждого профессионала в израильском хайтеке. Освобожден от налога на прибыль через 6 лет.',
    ),
    InterviewQuestion(
      id: 'work_1_daily_standup',
      category: InterviewCategory.dailyWorkplace,
      interviewerRoleRu: 'Scrum Master / ראש צוות',
      interviewerHebrewWithNikkud: 'בּוֹקֶר טוֹב לְכֻלָּם! נַתְחִיל אֶת הַדֵּיילִי. מָה הַסְּטָטוּס שֶׁלְּךָ הַיּוֹם?',
      interviewerHebrewPlain: 'בוקר טוב לכולם! נתחיל את הדיילי. מה הסטטוס שלך היום?',
      transcriptionRu: 'Boker tov le-chulám! Natchíl et ha-déyli. Mah ha-státus shelkhá hayóm?',
      translationRu: 'Доброе утро всем! Начинаем дейли. Какой у тебя статус сегодня?',
      mentorCareerTipRu:
          'Формат дейли в Израиле: что сделал вчера, что делаю сегодня, и есть ли «блокеры» («חוסמים»). Кратко и четко.',
      responseOptions: [
        'אֶתְמוֹל סִיַּמְתִּי אֶת הַפִּיצֶ׳ר שֶׁל הַסְּלִיקָה, הַיּוֹם אֲנִי כּוֹתֵב טֶסְטִים וְאֵין לִי חוֹסְמִים.',
        'הָיִיתִי עָיֵף מְאוֹד אֶתְמוֹל כִּי הָיָה פְּקָק עֲנָק בְּאַיָּלוֹן, אָז שָׁתִיתִי קָפֶה שְׁעָתַיִם.',
        'לֹא עָשִׂיתִי כְּלוּם, אַף אֶחָד לֹא אָמַר לִי מָה לַעֲשׂוֹת.',
      ],
      bestResponseIndex: 0,
      explanationRu:
          '«סיימתי את הפיצ׳ר, כותב טסטים, אין חוסמים» — эталонный стендап-рапорт. Показывает темп и самостоятельность.',
    ),
    InterviewQuestion(
      id: 'work_2_code_review',
      category: InterviewCategory.dailyWorkplace,
      interviewerRoleRu: 'Senior Developer (מְפַתֵּחַ בָּכִיר)',
      interviewerHebrewWithNikkud: 'הַי, פָּתַחְתָּ כְּבָר אֶת הַ-Pull Request? צָרִיךְ עֶזְרָה בְּקוֹד רִיוְיוּ?',
      interviewerHebrewPlain: 'הי, פתחת כבר את ה-Pull Request? צריך עזרה בקוד ריוויו?',
      transcriptionRu: 'Hay, patáchta kvár et ha-Pull Request? Tzaríkh ezrá be-kod rívyu?',
      translationRu: 'Привет, ты уже открыл Pull Request? Нужна помощь с код-ревью?',
      mentorCareerTipRu:
          'Израильская культура разработчиков неформальная («היי, אחי / גבר»). Предложи коллеге посмотреть вместе или скинь ссылку в Slack.',
      responseOptions: [
        'כֵּן, שָׁלַחְתִּי לְךָ לִינְק בִּ-Slack. תִּסְתַּכֵּל כְּשֶׁיֵּשׁ לְךָ רֶגַע, אֶשְׂמַח לְהֶעָרוֹת.',
        'הַקּוֹד שֶׁלִּי מֻשְׁלָם, אֵין שׁוּם צֹרֶךְ לִבְדֹּק אוֹתוֹ.',
        'לֹא פָּתַחְתִּי כִּי לֹא בָּא לִי שֶׁאַנָּשִׁים יִרְאוּ אֶת הַטָּעֻיּוֹת שֶׁלִּי.',
      ],
      bestResponseIndex: 0,
      explanationRu:
          '«אשמח להערות» (Буду рад замечаниям) демонстрирует открытость к фидбеку и здоровую культуру код-ревью.',
    ),
    InterviewQuestion(
      id: 'work_3_tiktuk_production',
      category: InterviewCategory.dailyWorkplace,
      interviewerRoleRu: 'DevOps / Team Lead',
      interviewerHebrewWithNikkud: 'יֵשׁ לָנוּ תַּקָּלָה קְרִיטִית בִּפְרוֹדַקְשֶׁן, מִי יָכוֹל לְתַקְתֵּק אֶת זֶה?',
      interviewerHebrewPlain: 'יש לנו תקלה קריטית בפרודקשן, מי יכול לתקתק את זה?',
      transcriptionRu: 'Yesh lánu takalá kritít bi-prodákshen, mi yakhól letakték et ze?',
      translationRu: 'У нас критический инцидент на проде, кто может быстро разрулить это?',
      mentorCareerTipRu:
          'Глагол «לְתַקְתֵּק» (летактек) — культовый сленг из армии и хайтека: сделать быстро, четко и без тормозов, как ход часов («תִּק-תַּק»).',
      responseOptions: [
        'אֲנִי עַל זֶה! פּוֹתֵחַ אֶת הַלּוֹגִים בְּעוֹד דַּקָּה וּמַעֲלֶה הוֹטְפִיקְס.',
        'זֶה לֹא בַּמַּשְׂכֹּרֶת שֶׁלִּי לְתַקֵּן בָּאגִים בִּפְרוֹד.',
        'תְּחַכּוּ לְיוֹם רִאשׁוֹן, עַכְשָׁו סוֹף שָׁבוּעַ וַאֲנִי בַּיָּם.',
      ],
      bestResponseIndex: 0,
      explanationRu:
          '«אני על זה!» (Ани аль зэ! — Я уже занимаюсь этим!) — золотой ответ любого сотрудника в израильском стартапе.',
    ),
    InterviewQuestion(
      id: 'pay_1_nekudot_zikuy',
      category: InterviewCategory.payslipDecoding,
      interviewerRoleRu: 'Бухгалтер (חַשֶּׁבֶת שָׂכָר)',
      interviewerHebrewWithNikkud: 'שַׂמְתָּ לֵב לִנְקֻדּוֹת הַזִּכּוּי שֶׁל עוֹלֶה חָדָשׁ בַּתְּלוּשׁ?',
      interviewerHebrewPlain: 'שמת לב לנקודות הזיכוי של עולה חדש בתלוש?',
      transcriptionRu: 'Samta lev li-nekudót ha-zikúy shel olé chadásh ba-tlush?',
      translationRu: 'Ты обратил внимание на налоговые баллы нового репатрианта в расчетном листке?',
      mentorCareerTipRu:
          'Каждая «некудат зикуй» экономит ₪242 в месяц налога. Новый репатриант имеет право на +3 пункта в первые 18 месяцев — это почти ₪726 чистой экономии ежемесячно!',
      responseOptions: [
        'כֵּן, וִדֵּאתִי שֶׁמְּעֻדְכָּנוֹת לִי 5.25 נְקֻדּוֹת זִכּוּי בְּטֹפֶס 101 כְּדֵי לֹא לְשַׁלֵּם מַס מְיֻתָּר.',
        'לֹא מְעַנְיֵן אוֹתִי מַה כָּתוּב שָׁם, הָעִקָּר שֶׁהַבַּנְק לֹא שׁוֹלֵחַ מִכְתָּבִים.',
        'נְקֻדּוֹת זִכּוּי זֶה קְנָס שֶׁל מַס הַכְנָסָה, נָכוֹן?',
      ],
      bestResponseIndex: 0,
      explanationRu:
          'Каждый работник в Израиле заполняет форму 101 (טופס 101) каждый год в январе, чтобы подтвердить статус репатрианта, детей и положенные налоговые скидки.',
    ),
    InterviewQuestion(
      id: 'pay_2_chafifa_handover',
      category: InterviewCategory.payslipDecoding,
      interviewerRoleRu: 'Руководитель группы / מנהל צוות',
      interviewerHebrewWithNikkud: 'לִפְנֵי שֶׁהַמְּפַתֵּחַ הַקּוֹדֵם עוֹזֵב, צָרִיךְ לַעֲשׂוֹת אִתּוֹ חָפִיפָה מַקִּיפָה.',
      interviewerHebrewPlain: 'לפני שהמפתח הקודם עוזב, צריך לעשות איתו חפיפה מקיפה.',
      transcriptionRu: 'Lifnéi she-ha-mefatéch ha-kodém ozév, tzaríkh la\'asót itó chafifá makifá.',
      translationRu: 'Перед тем как предыдущий разработчик уйдет, нужно провести с ним глубокую передачу дел (хафифа).',
      mentorCareerTipRu:
          'Слово «חֲפִיפָה» (хафифа) буквально означает мытье головы шампунем, но в израильской армии и на работе это официальный термин для онбординга и передачи дел.',
      responseOptions: [
        'מְעֻלֶּה, אֶקְבַּע אִתּוֹ שְׁלוֹשָׁה סֶשֶׁנִים שֶׁל הַעֲבָרַת יֶדַע וְאֶכְתֹּב תִּעוּד מְסֻדָּר בִּ-Confluence.',
        'לָמָּה שֶׁאֶחְפֹּף אִתּוֹ? אֲנִי מִתְקַלֵּחַ לְבַד בַּבַּיִת.',
        'לֹא צָרִיךְ חָפִיפָה, אֲנִי אֶמְחַק אֶת כָּל הַקּוֹד הַיָּשָׁן וְאֶכְתֹּב מֵחָדָשׁ.',
      ],
      bestResponseIndex: 0,
      explanationRu:
          '«חפיפה» (хафифа) — важнейший процесс: фиксирование паролей, архитектуры и подводных камней проекта перед уходом сотрудника.',
    ),
  ];

  /// Realistic high-tech Israeli payslip (₪25,000 monthly gross).
  static const IsraeliPayslip sampleHighTechPayslip = IsraeliPayslip(
    employeeNameRu: 'Даниэль Левин (דָּנִיאֵל לֵוִין)',
    employerNameRu: 'סייבר-טק מעבדות בע״מ (CyberTech Labs Herzliya)',
    roleTitleRu: 'Senior Flutter & Mobile Engineer',
    monthYearHebrew: 'נוֹבֶמְבֶּר 2026',
    grossSalaryShekels: 25000.0,
    nekudotZikuy: 5.25,
    nekudotZikuyValueMonthly: 1270.50,
    items: [
      // Incomes
      PayslipItem(
        id: 'inc_base_salary',
        titleRu: 'Базовый оклад',
        hebrewWithNikkud: 'שְׂכַר יְסוֹד',
        hebrewPlain: 'שכר יסוד',
        transcriptionRu: 'S\'khar Yesód',
        amountShekels: 20000.0,
        category: PayslipCategory.income,
        explanationRu: 'Основная фиксированная ставка за 182 рабочих часа в месяц.',
        lawOrTipRu: 'Именно от этой суммы рассчитываются пенсионные и выходные пособия.',
      ),
      PayslipItem(
        id: 'inc_global_overtime',
        titleRu: 'Глобальные сверхурочные',
        hebrewWithNikkud: 'שְׁעוֹת נוֹסָפוֹת גְּלוֹבָּלִיּוֹת',
        hebrewPlain: 'שעות נוספות גלובליות',
        transcriptionRu: 'She\'ót Nosafót Globáliyot',
        amountShekels: 5000.0,
        category: PayslipCategory.income,
        explanationRu: 'Стандартная надбавка в хайтеке вместо поштучного учета ночных часов.',
        lawOrTipRu: 'Обязательно должна быть отдельной строкой в договоре.',
      ),

      // Mandatory taxes
      PayslipItem(
        id: 'ded_income_tax',
        titleRu: 'Подоходный налог (Мас Ахнаса)',
        hebrewWithNikkud: 'מַס הַכְנָסָה',
        hebrewPlain: 'מס הכנסה',
        transcriptionRu: 'Mas Hakhnasá',
        amountShekels: 2430.0,
        percentage: 9.72,
        category: PayslipCategory.mandatoryDeduction,
        explanationRu: 'Прогрессивный налог государства с вычетом твоих 5.25 льготных баллов.',
        lawOrTipRu: 'Благодаря статусу Оле Хадаш налог снижен почти на ₪726 в месяц!',
      ),
      PayslipItem(
        id: 'ded_bituach_leumi',
        titleRu: 'Служба нацстрахования (Битуах Леуми)',
        hebrewWithNikkud: 'בִּיטּוּחַ לְאֻמִּי',
        hebrewPlain: 'ביטוח לאומי',
        transcriptionRu: 'Bitúach Le\'umí',
        amountShekels: 1310.0,
        percentage: 5.24,
        category: PayslipCategory.mandatoryDeduction,
        explanationRu: 'Оплата пособий по безработице, декретных и резервистских выплат (милуим).',
        lawOrTipRu: 'Рассчитывается по двум ступеням: до ₪7,522 пониженная ставка, выше — полная.',
      ),
      PayslipItem(
        id: 'ded_health_tax',
        titleRu: 'Налог на здравоохранение (Мас Бриут)',
        hebrewWithNikkud: 'מַס בְּרִיאוּת',
        hebrewPlain: 'מס בריאות',
        transcriptionRu: 'Mas Bri\'út',
        amountShekels: 975.0,
        percentage: 3.9,
        category: PayslipCategory.mandatoryDeduction,
        explanationRu: 'Обеспечивает государственную медицинскую страховку в больничных кассах (Клалит, Маккаби).',
        lawOrTipRu: 'Взимается автоматически Институтом национального страхования.',
      ),

      // Social deductions
      PayslipItem(
        id: 'ded_pension_employee',
        titleRu: 'Пенсионные отчисления работника (6%)',
        hebrewWithNikkud: 'תַּגְמוּלֵי עֹבֶד לְפֶנְסְיָה',
        hebrewPlain: 'תגמולי עובד לפנסיה',
        transcriptionRu: 'Tagmuléy Ovéd le-Pénsya',
        amountShekels: 1500.0,
        percentage: 6.0,
        category: PayslipCategory.socialDeduction,
        explanationRu: 'Твоя доля инвестиций в пенсионный фонд (Мейтав, Харэль, Менора и др.).',
        lawOrTipRu: 'Обязательно по закону о пенсионном страховании в Израиле с 2008 года.',
      ),
      PayslipItem(
        id: 'ded_keren_hishtalmut_employee',
        titleRu: 'Керен Иштальмут работника (2.5%)',
        hebrewWithNikkud: 'קֶרֶן הִשְׁתַּלְּמוּת עֹבֶד',
        hebrewPlain: 'קרן השתלמות עובד',
        transcriptionRu: 'Kéren Hishtalmút Ovéd',
        amountShekels: 393.75,
        percentage: 2.5,
        category: PayslipCategory.socialDeduction,
        explanationRu: 'Твой взнос до налогового потолка (до ₪15,712 базы).',
        lawOrTipRu: 'Через 6 лет все накопления с процентами снимаются абсолютно БЕЗ налога на прибыль!',
      ),
      PayslipItem(
        id: 'ded_cibus_10bis',
        titleRu: 'Участие в корпоративном питании (10bis)',
        hebrewWithNikkud: 'הִשְׁתַּתְּפוּת בְּאָרוּחוֹת (תֵּן בִּיס)',
        hebrewPlain: 'השתתפות בארוחות (תן ביס)',
        transcriptionRu: 'Hishtatfút be-Aruchót (Ten Bis)',
        amountShekels: 200.0,
        category: PayslipCategory.voluntaryDeduction,
        explanationRu: 'Личное софинансирование карты на обеды в ресторанах и супермаркетах.',
        lawOrTipRu: 'Остальную сумму обедов оплачивает компания как бенефит.',
      ),

      // Employer additions
      PayslipItem(
        id: 'emp_pension_employer',
        titleRu: 'Взнос работодателя в пенсию (6.5%)',
        hebrewWithNikkud: 'תַּגְמוּלֵי מַעֲסִיק לְפֶנְסְיָה',
        hebrewPlain: 'תגמולי מעסיק לפנסיה',
        transcriptionRu: 'Tagmuléy Ma\'asík le-Pénsya',
        amountShekels: 1625.0,
        percentage: 6.5,
        category: PayslipCategory.employerContribution,
        explanationRu: 'Прямой вклад компании в твой пенсионный фонд сверх оклада.',
        lawOrTipRu: 'Не уменьшает твое нетто, а капитализируется на твоем личном счете.',
      ),
      PayslipItem(
        id: 'emp_severance_pitzuim',
        titleRu: 'Фонд компенсации при увольнении (Пицуим 8.33%)',
        hebrewWithNikkud: 'פִּצּוּיֵי פִּטּוּרִין (סְעִיף 14)',
        hebrewPlain: 'פיצויי פיטורין (סעיף 14)',
        transcriptionRu: 'Pitzuyéy Piturín (Se\'if 14)',
        amountShekels: 2082.50,
        percentage: 8.33,
        category: PayslipCategory.employerContribution,
        explanationRu: 'Покрытие 1 месячного оклада за каждый отработанный год по «Параграфу 14».',
        lawOrTipRu: 'Деньги принадлежат тебе, даже если ты уволишься по собственному желанию!',
      ),
      PayslipItem(
        id: 'emp_keren_hishtalmut_employer',
        titleRu: 'Взнос работодателя в Керен Иштальмут (7.5%)',
        hebrewWithNikkud: 'קֶרֶן הִשְׁתַּלְּמוּת מַעֲסִיק',
        hebrewPlain: 'קרן השתלמות מעסיק',
        transcriptionRu: 'Kéren Hishtalmút Ma\'asík',
        amountShekels: 1178.40,
        percentage: 7.5,
        category: PayslipCategory.employerContribution,
        explanationRu: 'Компания вкладывает в 3 раза больше, чем работник! Самый ценный хайтек-бенефит.',
        lawOrTipRu: 'Полное освобождение от 25% налога на прирост капитала.',
      ),
    ],
  );

  /// 16 authentic Israeli tech, career, and workplace terms.
  static const List<Map<String, String>> careerGlossary = [
    {
      'hebrew': 'תְּלוּשׁ מַשְׂכֹּרֶת',
      'plain': 'תלוש משכורת',
      'transcription': 'tlush maskóret',
      'translation': 'Расчетный листок по зарплате',
      'tip': 'Официальный финансовый документ, подтверждающий доход для съема квартиры и машканты.',
    },
    {
      'hebrew': 'שָׂכָר בְּרוּטוֹ',
      'plain': 'שכר ברוטו',
      'transcription': 'sakhár brúto',
      'translation': 'Зарплата брутто (до всех налогов)',
      'tip': 'Единственная официальная цифра в израильском трудовом договоре (חוזה עבודה).',
    },
    {
      'hebrew': 'שָׂכָר נֶטּוֹ',
      'plain': 'שכר נטו',
      'transcription': 'sakhár néto',
      'translation': 'Зарплата нетто (сумма на банковский счет)',
      'tip': 'Сумма к переводу (שכר נטו לתשלום בבנק) после всех отчислений и налогов.',
    },
    {
      'hebrew': 'קֶרֶן הִשְׁתַּלְּמוּת',
      'plain': 'קרן השתלמות',
      'transcription': 'kéren hishtalmút',
      'translation': 'Фонд повышения квалификации (безналоговый вклад)',
      'tip': 'Работодатель платит 7.5%, работник 2.5%. Через 6 лет можно забрать деньги на любые цели без налога.',
    },
    {
      'hebrew': 'נְקֻדּוֹת זִכּוּי',
      'plain': 'נקודות זיכוי',
      'transcription': 'nekudót zikúy',
      'translation': 'Налоговые льготные баллы',
      'tip': 'Каждый балл равен ₪242/мес. Репатрианты получают дополнительные баллы в течение 4.5 лет.',
    },
    {
      'hebrew': 'חָפִיפָה',
      'plain': 'חפיפה',
      'transcription': 'chafifá',
      'translation': 'Онбординг, передача дел',
      'tip': 'Период обучения и передачи кодовой базы от уходящего сотрудника новому разработчику.',
    },
    {
      'hebrew': 'לְתַקְתֵּק',
      'plain': 'לתקתק',
      'transcription': 'letakték',
      'translation': 'Сделать быстро, оперативно и четко',
      'tip': '«אני מתקתק את המשימה הזאת» — культовое выражение эффективности в израильском офисе.',
    },
    {
      'hebrew': 'חוֹזֶה עֲבוֹדָה',
      'plain': 'חוזה עבודה',
      'transcription': 'chozéh avodá',
      'translation': 'Трудовой договор',
      'tip': 'Индивидуальный контракт, регулирующий оклад, соцпакет и опционы (אופציות).',
    },
    {
      'hebrew': 'פִּצּוּיֵי פִּטּוּרִין',
      'plain': 'פיצויי פיטורין',
      'transcription': 'pitzuyéy piturín',
      'translation': 'Выходное пособие при увольнении (Пицуим)',
      'tip': 'В хайтеке действует «סעיף 14»: ежемесячно 8.33% от оклада идут в фонд сотрудника независимо от причины ухода.',
    },
    {
      'hebrew': 'דֵּיילִי',
      'plain': 'דיילי',
      'transcription': 'déyli',
      'translation': 'Ежедневный стендап-митинг',
      'tip': 'Пятиминутка команды разработчиков: статус задач и выявление блокеров.',
    },
    {
      'hebrew': 'חוֹסֵם',
      'plain': 'חוסם',
      'transcription': 'chosém',
      'translation': 'Блокер задачи (технический барьер)',
      'tip': '«יש לי חוסם ב-API» — фраза на стендапе, когда ждешь другого разработчика или сервис.',
    },
    {
      'hebrew': 'תֵּן בִּיס / סִיבּוּס',
      'plain': 'תן ביס / סיבוס',
      'transcription': 'Ten Bis / Cibus',
      'translation': 'Корпоративная карта на рестораны и обеды',
      'tip': 'Ежедневный бюджет на ланч от компании, действующий в тысячах заведений Израиля.',
    },
    {
      'hebrew': 'יְמֵי חָפְשָׁה',
      'plain': 'ימי חופשה',
      'transcription': 'yeméy chufshá',
      'translation': 'Оплачиваемые дни отпуска',
      'tip': 'По закону от 12 до 24+ дней в год; их накопление и остаток указаны внизу каждого тлуша.',
    },
    {
      'hebrew': 'יְמֵי מַחֲלָה',
      'plain': 'ימי מחלה',
      'transcription': 'yeméy machalá',
      'translation': 'Больничные дни',
      'tip': '1-й день без оплаты, 2-й и 3-й по 50%, с 4-го дня — 100% (в хайтеке часто платят 100% с 1-го дня).',
    },
    {
      'hebrew': 'דְּמֵי הַבְרָאָה',
      'plain': 'דמי הבראה',
      'transcription': 'dméy havra\'á',
      'translation': 'Оздоровительные выплаты',
      'tip': 'Ежегодный бонус, выплачиваемый летом всем сотрудникам со стажем более года (~₪418 за день стажа).',
    },
    {
      'hebrew': 'טוֹפֶס 101',
      'plain': 'טופס 101',
      'transcription': 'tófes me\'áh ve-echád',
      'translation': 'Налоговая декларация работника (Форма 101)',
      'tip': 'Заполняется при приеме на работу и каждый январь для расчета налоговых скидок и семейного статуса.',
    },
  ];
}
