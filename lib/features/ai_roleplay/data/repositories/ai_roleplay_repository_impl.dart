import 'dart:math';

import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../../../core/utils/hebrew_normalizer.dart';
import '../../domain/entities/ai_chat_message.dart';
import '../../domain/entities/ai_roleplay_scenario.dart';
import '../../domain/repositories/ai_roleplay_repository.dart';
import '../datasources/ai_roleplay_seed_data.dart';
import '../datasources/grammar_correction_engine.dart';

final class AiRoleplayRepositoryImpl implements AiRoleplayRepository {
  final GrammarCorrectionEngine _grammarEngine;
  final List<AiRoleplayScenario> _scenarios;

  AiRoleplayRepositoryImpl({
    GrammarCorrectionEngine grammarEngine = const GrammarCorrectionEngine(),
    List<AiRoleplayScenario>? scenarios,
  })  : _grammarEngine = grammarEngine,
        _scenarios = scenarios ?? AiRoleplaySeedData.scenarios;

  @override
  Future<Result<List<AiRoleplayScenario>, Failure>> getScenarios() async {
    return Success(_scenarios);
  }

  @override
  Future<Result<AiRoleplayScenario, Failure>> getScenarioById(
    String scenarioId,
  ) async {
    for (final s in _scenarios) {
      if (s.id == scenarioId) {
        return Success(s);
      }
    }
    return Error(ValidationFailure('Сценарий "$scenarioId" не найден'));
  }

  @override
  Future<Result<AiChatMessage, Failure>> sendMessage({
    required AiRoleplayScenario scenario,
    required List<AiChatMessage> conversationHistory,
    required String userHebrewInput,
  }) async {
    final trimmedInput = userHebrewInput.trim();
    if (trimmedInput.isEmpty) {
      return const Error(
        ValidationFailure('Сообщение пользователя не может быть пустым'),
      );
    }

    // 1. Analyze grammar for learning feedback
    final correction = _grammarEngine.analyzeUserInput(trimmedInput);

    // 2. Determine contextual response based on scenario and user intent
    final generated = _generateContextualReply(
      scenarioId: scenario.id,
      input: trimmedInput,
      messageCount: conversationHistory.length,
    );

    final aiMessage = AiChatMessage(
      id: 'ai_${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(1000)}',
      isUser: false,
      hebrewText: generated.hebrew,
      russianTranslation: generated.russian,
      transliteration: generated.translit,
      grammarCorrection: correction,
      timestamp: DateTime.now(),
    );

    return Success(aiMessage);
  }

  ({String hebrew, String russian, String translit}) _generateContextualReply({
    required String scenarioId,
    required String input,
    required int messageCount,
  }) {
    final norm = HebrewNormalizer.normalizeForComparison(input);

    switch (scenarioId) {
      case 'scene_cafe':
        return _replyCafe(norm);
      case 'scene_supermarket':
        return _replySupermarket(norm);
      case 'scene_transport':
        return _replyTransport(norm);
      case 'scene_clinic':
        return _replyClinic(norm);
      case 'scene_rent':
        return _replyRent(norm);
      default:
        return _replyFreeChat(norm);
    }
  }

  ({String hebrew, String russian, String translit}) _replyCafe(String norm) {
    if (norm.contains('כמה') || norm.contains('חשבון') || norm.contains('לשלם')) {
      return (
        hebrew: 'בְּסַךְ הַכֹּל זֶה 22 שְׁקָלִים. אֶפְשָׁר בְּאַשְׁרַאי אוֹ בִּמְזֻמָּן. שֶׁיִּהְיֶה לְךָ יוֹם מְעֻלֶּה!',
        russian: 'Всего 22 шекеля. Можно картой или наличными. Отличного дня!',
        translit: 'Besakh hakol ze 22 shkalim. Efshar be-ashray o bi-mzuman. She-yihye lekha yom meule!',
      );
    }
    if (norm.contains('חלב') || norm.contains('שועל') || norm.contains('סויה')) {
      return (
        hebrew: 'אֵין בְּעָיָה! קָפֶה עִם חָלָב מְיֻחָד. תִּרְצֶה עִם סֻכָּר? וְלָשֶׁבֶת פֹּה אוֹ לָקַחַת?',
        russian: 'Без проблем! Кофе со специальным молоком. Добавить сахар? Здесь или с собой?',
        translit: 'Eyn beaya! Kafe im chalav meyuchad. Tirtse im sukar? Ve-lashevet po o lakachat?',
      );
    }
    if (norm.contains('לקחת') || norm.contains('לשבת') || norm.contains('פה')) {
      return (
        hebrew: 'מְעֻלֶּה, רָשַׁמְתִּי. אֶפְשָׁר לְהַצִּיעַ לְךָ גַּם מַאֲפֶה טָרִי לְיַד? יֵשׁ קְרוּאָסוֹן חַם!',
        russian: 'Отлично, записал. Предложить свежую выпечку к кофе? Есть горячий круассан!',
        translit: 'Meule, rashamti. Efshar lehatzia lekha gam maafe tari leyad? Yesh kruason cham!',
      );
    }
    if (norm.contains('הפוך') || norm.contains('קפה') || norm.contains('אספרסו') || norm.contains('מים')) {
      return (
        hebrew: 'מְצֻיָּן! אֵיזֶה גֹּדֶל תִּרְצֶה — קָטָן, בֵּינוֹנִי אוֹ גָּדוֹל? וְאֵיזֶה חָלָב לָשִׂים?',
        russian: 'Замечательно! Какой размер: маленький, средний или большой? И какое молоко налить?',
        translit: 'Metzuyan! Eyze godel tirtse — katan, beynoni o gadol? Ve-eyze chalav lasim?',
      );
    }
    return (
      hebrew: 'בְּכֵיף! הַהַזְמָנָה שֶׁלְּךָ בַּהֲכָנָה. עוֹד מַשֶּׁהוּ קָטָן שֶׁתִּרְצֶה לְהוֹסִיף?',
      russian: 'С удовольствием! Твой заказ готовится. Хочешь добавить что-нибудь еще?',
      translit: 'Be-kheyf! Ha-hazmana shelkha ba-hakhana. Od mashehu katan she-tirtse lehosif?',
    );
  }

  ({String hebrew, String russian, String translit}) _replySupermarket(String norm) {
    if (norm.contains('שקית') || norm.contains('שקיות')) {
      return (
        hebrew: 'מְצֻיָּן, הוֹסַפְתִּי שַׂקִּיּוֹת לַחֶשְׁבּוֹן. יֵשׁ לְךָ כַּרְטִיס מוֹעֲדוֹן לִצְבִירַת נְקֻדּוֹת?',
        russian: 'Отлично, добавила пакеты в чек. Есть карта клуба для начисления баллов?',
        translit: 'Metzuyan, hosafti sakiyot la-cheshbon. Yesh lekha kartis moadon li-tzvirat nekudot?',
      );
    }
    if (norm.contains('אשראי') || norm.contains('מזומן') || norm.contains('לשלם')) {
      return (
        hebrew: 'תַּעֲבִיר אֶת הַכַּרְטִיס עַל הַמַּכְשִׁיר מִצַּד יָמִין. זֶה מְאֻשָּׁר! תִּרְצֶה קַבָּלָה?',
        russian: 'Приложи карту к терминалу справа. Оплата прошла! Нужен чек?',
        translit: 'Taavir et ha-kartis al ha-makhshir mi-tsad yamin. Ze meushar! Tirtse kabala?',
      );
    }
    if (norm.contains('קבלה') || norm.contains('תודה')) {
      return (
        hebrew: 'הִנֵּה הַקַּבָּלָה. תּוֹדָה רַבָּה שֶׁקָּנִיתָ אֶצְלֵנוּ וְשֶׁיִּהְיֶה לְךָ יוֹם נִפְלָא!',
        russian: 'Вот ваш чек. Спасибо за покупки и прекрасного вам дня!',
        translit: 'Hine ha-kabala. Toda raba she-kanita etslenu ve-she-yihye lekha yom nifla!',
      );
    }
    return (
      hebrew: 'בְּסֵדֶר גָּמוּר. הַסַּךְ הַכֹּל הוּא 68 שְׁקָלִים. אֵיךְ נוֹחַ לְךָ לְשַׁלֵּם?',
      russian: 'Хорошо. Общая сумма 68 шекелей. Как вам удобно оплатить?',
      translit: 'Beseder gamur. Ha-sakh hakol hu 68 shkalim. Eikh noach lekha leshalem?',
    );
  }

  ({String hebrew, String russian, String translit}) _replyTransport(String norm) {
    if (norm.contains('תחנה') || norm.contains('ירושלים') || norm.contains('תל אביב') || norm.contains('ים')) {
      return (
        hebrew: 'הָאוֹטוֹבּוּס מַגִּיעַ לְשָׁם עוֹד עֶשֶׂר דַּקּוֹת. אֲנִי אֶכְרֹז אֶת הַתַּחֲנָה לִפְנֵי שֶׁנַּגִּיעַ.',
        russian: 'Автобус прибудет туда минут через десять. Я объявлю остановку перед прибытием.',
        translit: 'Ha-otobus magia le-sham od eser dakot. Ani ekhroz et ha-tachana lifney she-nagia.',
      );
    }
    if (norm.contains('תיקוף') || norm.contains('רב קו') || norm.contains('כרטיס')) {
      return (
        hebrew: 'מְצֻיָּן, הַתִּקּוּף עָבַר. יֵשׁ מְקוֹמוֹת יְשִׁיבָה פְּנוּיִים מֵאָחוֹר. נְסִיעָה טוֹבָה!',
        russian: 'Отлично, валидация прошла. Сзади есть свободные места. Хорошей поездки!',
        translit: 'Metzuyan, ha-tikuf avar. Yesh mekomot yeshiva pnuyim me-achor. Nesia tova!',
      );
    }
    return (
      hebrew: 'אֵין בְּעָיָה, פָּשׁוּט תִּלְחַץ עַל הַכַּפְתּוֹר הָאָדֹם כְּשֶׁתִּרְצֶה לָרֶדֶת.',
      russian: 'Без проблем, просто нажми красную кнопку стоп, когда соберешься выходить.',
      translit: 'Eyn beaya, pashut tilchatats al ha-kaftor ha-adom keshe-tirtse laredet.',
    );
  }

  ({String hebrew, String russian, String translit}) _replyClinic(String norm) {
    if (norm.contains('תור') || norm.contains('רופא') || norm.contains('משפחה')) {
      return (
        hebrew: 'בָּדַקְתִּי אֶת הַתּוֹר שֶׁלְּךָ. גַּשׁ לְחֶדֶר 14, הָרוֹפֵא יִקְרָא לְךָ לְפִי הַמִּסְפָּר בַּצָּג.',
        russian: 'Проверила вашу запись. Пройдите в кабинет 14, врач вызовет по номеру на табло.',
        translit: 'Badakti et ha-tor shelkha. Gash le-cheder 14, ha-rofe yikra lekha lefi ha-mispar ba-tsag.',
      );
    }
    if (norm.contains('מרשם') || norm.contains('תרופה') || norm.contains('כדורים')) {
      return (
        hebrew: 'הַמִּרְשָׁם הָאֶלֶקְטְרוֹנִי כְּבָר מְעֻדְכָּן בַּכַּרְטִיס. בֵּית הַמִּרְקַחַת נִמְצָא בַּקּוֹמָה הָרִאשׁוֹנָה.',
        russian: 'Электронный рецепт уже прикреплен к карте. Аптека находится на первом этаже.',
        translit: 'Ha-mirsham ha-elektroni kvar meudkan ba-kartis. Beyt ha-mirkachat nimtsa ba-koma ha-rishona.',
      );
    }
    return (
      hebrew: 'רָשַׁמְתִּי אֶת הַפְּנִיָּה שֶׁלְּךָ. יֵשׁ עוֹד שְׁאֵלָה בְּנוֹגֵעַ לַבְּדִיקוֹת?',
      russian: 'Я отметила ваше обращение. Есть еще вопросы по поводу анализов?',
      translit: 'Rashamti et ha-pniya shelkha. Yesh od sheela be-nogea la-bdikot?',
    );
  }

  ({String hebrew, String russian, String translit}) _replyRent(String norm) {
    if (norm.contains('מחיר') || norm.contains('שכר דירה') || norm.contains('כמה')) {
      return (
        hebrew: 'שְׂכַר הַדִּירָה הוּא 5,400 שְׁקָלִים. זֶה כּוֹלֵל וַעַד בַּיִת, וְהָאַרְנוֹנָה הִיא 350 שְׁקָלִים לְחֹדֶשׁ.',
        russian: 'Аренда 5,400 шекелей. Включает домовой комитет, а арнона около 350 шекелей в месяц.',
        translit: 'Skhar ha-dira hu 5,400 shkalim. Ze kolel vaad bayit, ve-ha-arnona hi 350 shkalim le-chodesh.',
      );
    }
    if (norm.contains('כניסה') || norm.contains('מתי') || norm.contains('חוזה')) {
      return (
        hebrew: 'הַכְּנִיסָה הִיא בָּרִאשׁוֹן לַחֹדֶשׁ הַבָּא. הַחֹזֶה הוּא לְשָׁנָה עִם אָפְצְיָה לְהַאֲרָכָה.',
        russian: 'Въезд с первого числа следующего месяца. Контракт на год с опцией продления.',
        translit: 'Ha-knisa hi ba-rishon la-chodesh ha-ba. Ha-choze hu le-shana im optzia le-haaracha.',
      );
    }
    return (
      hebrew: 'הַדִּירָה שְׁקֵטָה מְאֹד וְיֵשׁ מַזְגָן בְּכָל חֶדֶר. תִּרְצֶה לָבוֹא לִרְאוֹת אוֹתָהּ הָעֶרֶב?',
      russian: 'Квартира очень тихая, в каждой комнате кондиционер. Хочешь прийти посмотреть ее вечером?',
      translit: 'Ha-dira shketa meod ve-yesh mazgan be-khol cheder. Tirtse lavo lirot ota ha-erev?',
    );
  }

  ({String hebrew, String russian, String translit}) _replyFreeChat(String norm) {
    if (norm.contains('עברית') || norm.contains('לומד')) {
      return (
        hebrew: 'כָּל הַכָּבוֹד! הָעִבְרִית שֶׁלְּךָ מִשְׁתַּפֶּרֶת מִיּוֹם לְיוֹם. מָה הַחֵלֶק שֶׁהֲכִי קָשֶׁה לְךָ?',
        russian: 'Молодец! Твой иврит улучшается день ото дня. Что для тебя самое трудное?',
        translit: 'Kol ha-kavod! Ha-ivrit shelkha mishtaperet mi-yom le-yom. Ma ha-chelek she-hachi kashe lekha?',
      );
    }
    if (norm.contains('ים') || norm.contains('מזג אוויר') || norm.contains('שמש')) {
      return (
        hebrew: 'אֵין כְּמוֹ הַיָּם בְּיִשְׂרָאֵל! מֶזֶג הָאֲוִיר מַמָּשׁ מַתְאִים לְהַלִּיכָה עַל הַטַּיֶּלֶת.',
        russian: 'Нет ничего лучше моря в Израиле! Погода как раз для прогулки по набережной.',
        translit: 'Eyn kmo ha-yam be-Yisrael! Mezeg ha-avir mamash matim le-halikha al ha-tayelet.',
      );
    }
    return (
      hebrew: 'אֵיזֶה יֹפִי לִשְׁמֹעַ! תְּסַפֵּר לִי עוֹד, אֲנִי תָּמִיד שָׂמֵחַ לְדַבֵּר עִמְּךָ עִבְרִית.',
      russian: 'Как приятно слышать! Расскажи мне еще, я всегда рад поговорить с тобой на иврите.',
      translit: 'Eyze yofi lishmoa! Tesaper li od, ani tamid sameach ledaber imkha ivrit.',
    );
  }
}
