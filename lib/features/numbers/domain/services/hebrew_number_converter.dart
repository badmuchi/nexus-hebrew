import '../entities/hebrew_number.dart';

/// Pure domain service converting integers to authentic Hebrew text with nikkud
/// according to strict Hebrew gender and counting rules.
final class HebrewNumberConverter {
  const HebrewNumberConverter();

  static const Map<int, String> _mascUnitsWithNikkud = {
    0: 'אֶפֶס',
    1: 'אֶחָד',
    2: 'שְׁנַיִם',
    3: 'שְׁלוֹשָׁה',
    4: 'אַרְבָּעָה',
    5: 'חֲמִשָּׁה',
    6: 'שִׁשָּׁה',
    7: 'שִׁבְעָה',
    8: 'שְׁמוֹנָה',
    9: 'תִּשְׁעָה',
    10: 'עֲשָׂרָה',
  };

  static const Map<int, String> _femUnitsWithNikkud = {
    0: 'אֶפֶס',
    1: 'אַחַת',
    2: 'שְׁתַּיִם',
    3: 'שָׁלוֹשׁ',
    4: 'אַרְבַּע',
    5: 'חָמֵשׁ',
    6: 'שֵׁשׁ',
    7: 'שֶׁבַע',
    8: 'שְׁמוֹנֶה',
    9: 'תֵּשַׁע',
    10: 'עֶשֶׂר',
  };

  static const Map<int, String> _mascTeensWithNikkud = {
    11: 'אַחַד עָשָׂר',
    12: 'שְׁנֵים עָשָׂר',
    13: 'שְׁלוֹשָׁה עָשָׂר',
    14: 'אַרְבָּעָה עָשָׂר',
    15: 'חֲמִשָּׁה עָשָׂר',
    16: 'שִׁשָּׁה עָשָׂר',
    17: 'שִׁבְעָה עָשָׂר',
    18: 'שְׁמוֹנָה עָשָׂר',
    19: 'תִּשְׁעָה עָשָׂר',
  };

  static const Map<int, String> _femTeensWithNikkud = {
    11: 'אַחַת עֶשְׂרֵה',
    12: 'שְׁתֵּים עֶשְׂרֵה',
    13: 'שְׁלוֹשׁ עֶשְׂרֵה',
    14: 'אַרְבַּע עֶשְׂרֵה',
    15: 'חֲמֵשׁ עֶשְׂרֵה',
    16: 'שֵׁשׁ עֶשְׂרֵה',
    17: 'שְׁבַע עֶשְׂרֵה',
    18: 'שְׁמוֹנֶה עֶשְׂרֵה',
    19: 'תְּשַׁע עֶשְׂרֵה',
  };

  static const Map<int, String> _tensWithNikkud = {
    20: 'עֶשְׂרִים',
    30: 'שְׁלוֹשִׁים',
    40: 'אַרְבָּעִים',
    50: 'חֲמִשִּׁים',
    60: 'שִׁשִּׁים',
    70: 'שִׁבְעִים',
    80: 'שְׁמוֹנִים',
    90: 'תִּשְׁעִים',
  };

  static const Map<int, String> _hundredsWithNikkud = {
    100: 'מֵאָה',
    200: 'מָאתַיִם',
    300: 'שְׁלוֹשׁ מֵאוֹת',
    400: 'אַרְבַּע מֵאוֹת',
    500: 'חֲמֵשׁ מֵאוֹת',
    600: 'שֵׁשׁ מֵאוֹת',
    700: 'שְׁבַע מֵאוֹת',
    800: 'שְׁמוֹנֶה מֵאוֹת',
    900: 'תְּשַׁע מֵאוֹת',
  };

  /// Converts an integer [0..999] into spoken Hebrew text with nikkud.
  static String numberToHebrew(int n, {required HebrewNumberGender gender}) {
    if (n < 0 || n > 999) {
      return n.toString();
    }
    if (n <= 10) {
      return gender == HebrewNumberGender.masculine
          ? _mascUnitsWithNikkud[n]!
          : _femUnitsWithNikkud[n]!;
    }
    if (n <= 19) {
      return gender == HebrewNumberGender.masculine
          ? _mascTeensWithNikkud[n]!
          : _femTeensWithNikkud[n]!;
    }
    if (n < 100) {
      final tens = (n ~/ 10) * 10;
      final rem = n % 10;
      final tensStr = _tensWithNikkud[tens]!;
      if (rem == 0) return tensStr;
      final unitStr = gender == HebrewNumberGender.masculine
          ? _mascUnitsWithNikkud[rem]!
          : _femUnitsWithNikkud[rem]!;
      return '$tensStr וְ$unitStr';
    }

    // 100 - 999
    final hundreds = (n ~/ 100) * 100;
    final remainder = n % 100;
    final hundredStr = _hundredsWithNikkud[hundreds]!;
    if (remainder == 0) return hundredStr;
    final remStr = numberToHebrew(remainder, gender: gender);
    return '$hundredStr וְ$remStr';
  }

  /// Formats prices in Shekels (שֶׁקֶל / שְׁקָלִים).
  ///
  /// CRITICAL NOTE: 'Shekel' is masculine, so it takes masculine numbers!
  /// 1 שקל = שֶׁקֶל אֶחָד
  /// 2 שקלים = שְׁנֵי שְׁקָלִים
  /// 3-10 שקלים = X שְׁקָלִים (שְׁלוֹשָׁה, אַרְבָּעָה...)
  /// 11+ שקל = X שֶׁקֶל (עֶשְׂרִים שֶׁקֶל, מֵאָה שֶׁקֶל...)
  static String formatShekels(int amount) {
    if (amount <= 0) return 'אֶפֶס שְׁקָלִים';
    if (amount == 1) return 'שֶׁקֶל אֶחָד';
    if (amount == 2) return 'שְׁנֵי שְׁקָלִים';
    if (amount >= 3 && amount <= 10) {
      final numStr = _mascUnitsWithNikkud[amount]!;
      return '$numStr שְׁקָלִים';
    }
    // 11+ takes singular שֶׁקֶל in modern everyday Israeli speech
    final numStr = numberToHebrew(amount, gender: HebrewNumberGender.masculine);
    return '$numStr שֶׁקֶל';
  }

  /// Formats spoken colloquial time in Hebrew.
  ///
  /// Note: Hours in Hebrew are always feminine (שָׁעָה שְׁתַּיִם, not שְׁנַיִם).
  static String formatTime(int hour24, int minute) {
    var h = hour24 % 12;
    if (h == 0) h = 12;
    final nextH = (h % 12) + 1;

    final hourStr = _femUnitsWithNikkud[h] ?? '$h';
    final nextHourStr = _femUnitsWithNikkud[nextH] ?? '$nextH';

    if (minute == 0) {
      return 'הַשָּׁעָה $hourStr';
    }
    if (minute == 15) {
      return '$hourStr וָרֶבַע';
    }
    if (minute == 30) {
      return '$hourStr וָחֵצִי';
    }
    if (minute == 45) {
      return 'רֶבַע לְ$nextHourStr';
    }
    if (minute < 30) {
      final minStr = _femUnitsWithNikkud[minute] ?? '$minute';
      return '$hourStr וְ$minStr דַּקּוֹת';
    } else {
      final diff = 60 - minute;
      final diffStr = _femUnitsWithNikkud[diff] ?? '$diff';
      return '$diffStr דַּקּוֹת לְ$nextHourStr';
    }
  }
}
