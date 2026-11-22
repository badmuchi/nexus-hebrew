import '../../../../core/utils/hebrew_normalizer.dart';

/// Analyzes user input in Hebrew for common learner grammar and pragmatic mistakes.
final class GrammarCorrectionEngine {
  const GrammarCorrectionEngine();

  String? analyzeUserInput(String rawInput) {
    final trimmed = rawInput.trim();
    if (trimmed.isEmpty) return null;

    final normalized = HebrewNormalizer.normalizeForComparison(trimmed);

    // 1. Gender mismatch: קפה (masculine) with feminine adjectives
    if (normalized.contains('קפה')) {
      final feminineCoffeeRegex = RegExp(
        r'קפה\s+(קרה|גדולה|קטנה|טובה|חמה|מתוקה|אחת|שתיים)',
      );
      if (feminineCoffeeRegex.hasMatch(normalized)) {
        return '💡 Род существительного: Слово «קָפֶה» в иврите мужского рода (זָכָר). '
            'Прилагательное тоже должно быть мужского рода: «קָפֶה קַר» / «קָפֶה גָּדוֹל» / «קָפֶה אֶחָד».';
      }
    }

    // 2. Plural/gender mismatch: מים (masculine plural) with singular or feminine
    if (normalized.contains('מים')) {
      final wrongWaterRegex = RegExp(
        r'מים\s+(קר|קרה|חם|חמה|טובה|גדולה|אחד|אחת)',
      );
      if (wrongWaterRegex.hasMatch(normalized)) {
        return '💡 Число и род: Слово «מַיִם» — всегда мужского рода во множественном числе (זָכָר רַבִּים). '
            'Правильно говорить: «מַיִם קָרִים» / «מַיִם חַמִּים».';
      }
    }

    // 3. Plural exceptions ending in -ot: שולחנות / מקומות / חלונות / רחובות
    if (RegExp(r'(שולחנות|מקומות|חלונות|רחובות)\s+(גדולות|קטנות|טובות|פנויות|יפות)').hasMatch(normalized)) {
      return '💡 Исключение во множественном числе: Слова «שֻׁלְחָנוֹת», «מְקוֹמוֹת», «רְחוֹבוֹת» — мужского рода (несмотря на окончание ־וֹת). '
          'Правильно: «מְקוֹמוֹת פְּנוּיִים» / «שֻׁלְחָנוֹת גְּדוֹלִים».';
    }

    // 4. Missing direct object marker 'את' before definite noun
    final missingEtRegex = RegExp(
      r'(רוצה|אוהב|מזמין|לוקח|קונה|צריך|מחפש|רואה)\s+(ה[\u05D0-\u05EA]{2,})',
    );
    final etMatch = missingEtRegex.firstMatch(normalized);
    if (etMatch != null) {
      final verb = etMatch.group(1);
      final noun = etMatch.group(2);
      return '💡 Прямое дополнение (אֶת): Перед конкретным существительным с артиклем «ה» ставится частица «אֶת»: '
          '«$verb אֶת $noun».';
    }

    // 5. Preposition mismatch with להתקשר (requires ל־, not עם or את)
    if (RegExp(r'(^|\s)(מתקשר|להתקשר|אתקשר)\s+(עם|את|ב)($|\s)').hasMatch(normalized)) {
      return '💡 Управление глагола: Глагол «לְהִתְקַשֵּׁר» (звонить) в иврите управляет предлогом «לְ־»: '
          'например, «מִתְקַשֵּׁר לַמַּשְׂכִּיר» (звоню арендодателю).';
    }

    // 6. Pragmatic / etiquette advice for polite ordering (avoid abrupt תן לי)
    if (RegExp(r'^(תן לי|תביא לי|תני לי|תביאי לי)($|\s)').hasMatch(normalized)) {
      return '💡 Разговорный этикет: Фраза «תֵּן לִי» может звучать излишне требовательно. '
          'Израильтяне обычно говорят: «אֶפְשָׁר בְּבַקָּשָׁה...» (Можно, пожалуйста...) или «אֲנִי אֶשְׂמַח לְ...» (Я с удовольствием возьму...).';
    }

    return null;
  }
}
