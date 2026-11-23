import '../../domain/entities/voice_scenario.dart';

/// Comprehensive conversational scenarios for the Sabra Voice AI companion.
final class VoiceAiSeedData {
  const VoiceAiSeedData._();

  static const List<VoiceScenario> scenarios = [
    // -------------------------------------------------------------------------
    // Scenario 1: Cafe on Dizengoff
    // -------------------------------------------------------------------------
    VoiceScenario(
      id: 'scenario_coffee_shop',
      titleRu: 'Кофе на Дизенгоф',
      titleHebrewWithNikkud: 'קָפֶה בְּדִיזֶנְגּוֹף',
      locationRu: 'Тель-Авив • Уютная кофейня',
      iconEmoji: '☕',
      descriptionRu: 'Заказ кофе с молоком на выбор, выпечка и оплата картой.',
      turns: [
        VoiceTurn(
          turnIndex: 0,
          sabraSpeechHebrewWithNikkud: 'שָׁלוֹם! מָה אֶפְשָׁר לְהָכִין לְךָ הַיּוֹם? לָשֶׁבֶת אוֹ לָקַחַת?',
          sabraSpeechNormalized: 'שלום! מה אפשר להכין לך היום? לשבת או לקחת?',
          sabraSpeechRu: 'Привет! Что приготовить тебе сегодня? Здесь или с собой?',
          culturalTipRu: 'В Израиле "с собой" часто говорят "Take away" или "Лакахат" (לָקַחַת). Если садишься, официант спросит имя для чека.',
          grammarHintRu: 'Глагол לָשֶׁבֶת (инфинитив пааль от корня י-ש-ב) — сидеть.',
          bestAnswerIndex: 0,
          suggestedAnswers: [
            SuggestedVoiceAnswer(
              id: 'ans_1_1',
              hebrewWithNikkud: 'שָׁלוֹם, אֲנִי רוֹצֶה הָפוּךְ קָטָן עִם חֲלֵב שִׁבּוֹלֶת שׁוּעָל, לָשֶׁבֶת בְּבַקָּשָׁה.',
              hebrewNormalized: 'שלום, אני רוצה הפוך קטן עם חלב שיבולת שועל, לשבת בבקשה.',
              transcriptionRu: 'Шалом, ани роцэ афух катан им халав шиболет шуаль, лашевет бевакаша.',
              translationRu: 'Привет, я хочу маленький капучино с овсяным молоком, здесь, пожалуйста.',
              expectedKeywords: ['הפוך', 'קטן', 'חלב', 'לשבת'],
            ),
            SuggestedVoiceAnswer(
              id: 'ans_1_2',
              hebrewWithNikkud: 'אֶסְפְּרֶסוֹ קָצָר וְכוֹס מַיִם קָרִים, לָקַחַת.',
              hebrewNormalized: 'אספרסו קצר וכוס מים קרים, לקחת.',
              transcriptionRu: 'Эспрессо кацар ве-хос маим карим, лакахат.',
              translationRu: 'Короткий эспрессо и стакан холодной воды, с собой.',
              expectedKeywords: ['אספרסו', 'מים', 'לקחת'],
            ),
          ],
        ),
        VoiceTurn(
          turnIndex: 1,
          sabraSpeechHebrewWithNikkud: 'מְעֻלֶּה! תִּרְצֶה גַּם מַשֶּׁהוּ מָתוֹק לְיַד? יֵשׁ מַאֲפֶה שׁוֹקוֹלָד חַם מֵהַתַּנּוּר.',
          sabraSpeechNormalized: 'מעולה! תרצה גם משהו מתוק ליד? יש מאפה שוקולד חם מהתנור.',
          sabraSpeechRu: 'Отлично! Захочешь что-нибудь сладенькое к кофе? Есть шоколадная выпечка горячая из печи.',
          culturalTipRu: '"Машеху ле-яд" (מַשֶּׁהוּ לְיַד) буквально "что-то рядом" — израильский термин для десерта к кофе.',
          grammarHintRu: 'תִּרְצֶה — будущее время 2 лицо мужского рода (ты захочешь).',
          bestAnswerIndex: 0,
          suggestedAnswers: [
            SuggestedVoiceAnswer(
              id: 'ans_2_1',
              hebrewWithNikkud: 'כֵּן, מַאֲפֶה שׁוֹקוֹלָד נִשְׁמָע מְצֻיָּן, תּוֹדָה רַבָּה!',
              hebrewNormalized: 'כן, מאפה שוקולד נשמע מצוין, תודה רבה!',
              transcriptionRu: 'Кен, маафэ шоколад нишма мецуян, тода раба!',
              translationRu: 'Да, шоколадная выпечка звучит отлично, спасибо большое!',
              expectedKeywords: ['כן', 'מאפה', 'שוקולד', 'תודה'],
            ),
            SuggestedVoiceAnswer(
              id: 'ans_2_2',
              hebrewWithNikkud: 'לֹא תּוֹדָה, רַק הַקָּפֶה. אֶפְשָׁר לְשַׁלֵּם בְּאַשְׁרַאי?',
              hebrewNormalized: 'לא תודה, רק הקפה. אפשר לשלם באשראי?',
              transcriptionRu: 'Ло тода, рак а-кафэ. Эфшар лешалем бе-ашрай?',
              translationRu: 'Нет спасибо, только кофе. Можно оплатить картой?',
              expectedKeywords: ['לא', 'רק', 'אשראי'],
            ),
          ],
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // Scenario 2: Shuk HaCarmel
    // -------------------------------------------------------------------------
    VoiceScenario(
      id: 'scenario_shuk_carmel',
      titleRu: 'Рынок Кармель',
      titleHebrewWithNikkud: 'שׁוּק הַכַּרְמֶל',
      locationRu: 'Тель-Авив • Торговые ряды',
      iconEmoji: '🍉',
      descriptionRu: 'Выбор сочных манго, взвешивание, дегустация и торг по-израильски.',
      turns: [
        VoiceTurn(
          turnIndex: 0,
          sabraSpeechHebrewWithNikkud: 'בֹּא, אָחִי! הַכֹּל דְּבַשׁ הַיּוֹם! תִּטְעַם אֶת הַמַּנְגּוֹ הַזֶּה, מַמָּשׁ סֻכָּרִיָּה!',
          sabraSpeechNormalized: 'בוא, אחי! הכל דבש היום! תטעם את המנגו הזה, ממש סוכרייה!',
          sabraSpeechRu: 'Подходи, брат! Всё как мёд сегодня! Попробуй это манго, настоящая конфета!',
          culturalTipRu: 'На израильском шуке продавцы часто называют покупателей "ахи" (брат) или "мотек" (сладкий) и охотно дают пробовать.',
          grammarHintRu: 'תִּטְעַם — форма повелительного наклонения/будущего времени от корня ט-ע-ם (пробовать на вкус).',
          bestAnswerIndex: 0,
          suggestedAnswers: [
            SuggestedVoiceAnswer(
              id: 'ans_shuk_1',
              hebrewWithNikkud: 'וָואלָה, מַמָּשׁ מָתוֹק! כַּמָּה זֶה עוֹלֶה לְקִילוֹ?',
              hebrewNormalized: 'וואלה, ממש מתוק! כמה זה עולה לקילו?',
              transcriptionRu: 'Валла, мамаш маток! Кама зэ олэ ле-кило?',
              translationRu: 'Ого, действительно сладкий! Сколько стоит за килограмм?',
              expectedKeywords: ['וואלה', 'מתוק', 'כמה', 'קילו'],
            ),
            SuggestedVoiceAnswer(
              id: 'ans_shuk_2',
              hebrewWithNikkud: 'נִרְאֶה טוֹב. אֶפְשָׁר לָקַחַת שְׁנֵי קִילוֹ בַּהֲנָחָה?',
              hebrewNormalized: 'נראה טוב. אפשר לקחת שני קילו בהנחה?',
              transcriptionRu: 'Ниръэ тов. Эфшар лакахат шней кило бе-анаха?',
              translationRu: 'Выглядит хорошо. Можно взять два килограмма со скидкой?',
              expectedKeywords: ['נראה', 'קילו', 'הנחה'],
            ),
          ],
        ),
        VoiceTurn(
          turnIndex: 1,
          sabraSpeechHebrewWithNikkud: 'בִּשְׁבִילְךָ עֶשְׂרִים שֶׁקֶל לִשְׁנֵי קִילוֹ! שָׂם לְךָ בַּשַּׂקִּית?',
          sabraSpeechNormalized: 'בשבילך עשרים שקל לשני קילו! שם לך בשקית?',
          sabraSpeechRu: 'Для тебя 20 шекелей за два килограмма! Кладу тебе в пакет?',
          culturalTipRu: '"Сам леха" (שָׂם לְךָ) — стандартная быстрая фраза продавца перед упаковкой.',
          grammarHintRu: 'בִּשְׁבִילְךָ — предлог בשביל с местоименным суффиксом 2 лица мужского рода.',
          bestAnswerIndex: 0,
          suggestedAnswers: [
            SuggestedVoiceAnswer(
              id: 'ans_shuk_3',
              hebrewWithNikkud: 'כֵּן, שִׂים בַּשַּׂקִּית. הִנֵּה הַכֶּסֶף בִּמְזֻמָּן, שַׁבָּת שָׁלוֹם!',
              hebrewNormalized: 'כן, שים בשקית. הנה הכסף במזומן, שבת שלום!',
              transcriptionRu: 'Кен, сим ба-сакит. Инэ а-кэсэф би-мзуман, шабат шалом!',
              translationRu: 'Да, положи в пакет. Вот наличные, хорошей субботы!',
              expectedKeywords: ['כן', 'שקית', 'כסף', 'מזומן'],
            ),
          ],
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // Scenario 3: Bus Driver & Rav-Kav
    // -------------------------------------------------------------------------
    VoiceScenario(
      id: 'scenario_bus_driver',
      titleRu: 'Автобус и Рав-Кав',
      titleHebrewWithNikkud: 'אוֹטוֹבּוּס וְרַב-קַו',
      locationRu: 'Городской маршрут • Остановка',
      iconEmoji: '🚌',
      descriptionRu: 'Уточнение маршрута, оплата приложением и остановка по требованию.',
      turns: [
        VoiceTurn(
          turnIndex: 0,
          sabraSpeechHebrewWithNikkud: 'עֲלֵה מַהֵר, חֲבֵר! אַתָּה מְתַקֵּף בָּאַפְּלִיקַצְיָה אוֹ בְּרַב-קַו?',
          sabraSpeechNormalized: 'עלה מהר, חבר! אתה מתקף באפליקציה או ברב-קו?',
          sabraSpeechRu: 'Заходи быстрее, друг! Ты валидируешь в приложении или Рав-Кавом?',
          culturalTipRu: 'Глагол לתקף (летакэф) означает приложить проездной к валидатору при входе.',
          grammarHintRu: 'עֲלֵה — повелительное наклонение глагола לַעֲלוֹת (подниматься, входить в транспорт).',
          bestAnswerIndex: 0,
          suggestedAnswers: [
            SuggestedVoiceAnswer(
              id: 'ans_bus_1',
              hebrewWithNikkud: 'שָׁלוֹם, תִּקַּפְתִּי בָּאַפְּלִיקַצְיָה. הָאוֹטוֹבּוּס מַגִּיעַ לָרַכֶּבֶת?',
              hebrewNormalized: 'שלום, תקפתי באפליקציה. האוטובוס מגיע לרכבת?',
              transcriptionRu: 'Шалом, тикафти ба-апликацья. А-отобус магиа ла-ракэвет?',
              translationRu: 'Здравствуйте, я провалидировал в приложении. Этот автобус едет к поезду?',
              expectedKeywords: ['שלום', 'אפליקציה', 'אוטובוס', 'רכבת'],
            ),
          ],
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // Scenario 4: Doctor Appointment
    // -------------------------------------------------------------------------
    VoiceScenario(
      id: 'scenario_doctor_appointment',
      titleRu: 'Визит к врачу',
      titleHebrewWithNikkud: 'תּוֹר לָרוֹפֵא',
      locationRu: 'Купат Холим • Регистратура',
      iconEmoji: '🩺',
      descriptionRu: 'Объяснение симптомов, запись к терапевту и получение рецепта.',
      turns: [
        VoiceTurn(
          turnIndex: 0,
          sabraSpeechHebrewWithNikkud: 'שָׁלוֹם, יֵשׁ לְךָ כַּרְטִיס מַגְנֶטִי שֶׁל הַקֻּפָּה? מָה הַבְּעָיָה הַיּוֹם?',
          sabraSpeechNormalized: 'שלום, יש לך כרטיס מגנטי של הקופה? מה הבעיה היום?',
          sabraSpeechRu: 'Здравствуйте, у вас есть магнитная карточка кассы? На что жалуетесь сегодня?',
          culturalTipRu: 'В Израиле карточка купат холим (כַּרְטִיס מַגְנֶטִי) нужна на каждом шагу у врача и в аптеке.',
          grammarHintRu: 'שֶׁל הַקֻּפָּה — сокращение от קופת חולים (больничная касса).',
          bestAnswerIndex: 0,
          suggestedAnswers: [
            SuggestedVoiceAnswer(
              id: 'ans_doc_1',
              hebrewWithNikkud: 'כֵּן, הִנֵּה הַכַּרְטִיס. כּוֹאֵב לִי הַגָּרוֹן וְיֵשׁ לִי חֹם מֵאֶתְמוֹל.',
              hebrewNormalized: 'כן, הנה הכרטיס. כואב לי הגרון ויש לי חום מאתמול.',
              transcriptionRu: 'Кен, инэ а-картис. Коэв ли а-гарон ве-йеш ли хом ме-этмоль.',
              translationRu: 'Да, вот карточка. У меня болит горло и со вчерашнего дня температура.',
              expectedKeywords: ['כרטיס', 'כואב', 'גרון', 'חום'],
            ),
          ],
        ),
      ],
    ),
  ];
}
