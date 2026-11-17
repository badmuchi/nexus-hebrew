import 'package:unorm_dart/unorm_dart.dart' as unorm;

final class HebrewNormalizer {
  HebrewNormalizer._();

  /// Unicode range U+0591 to U+05C7 covers Hebrew cantillation marks, points (nikkud),
  /// shin/sin dots, dagesh, rafe, and meteg.
  static final RegExp _nikkudRegex = RegExp(r'[\u0591-\u05C7]');
  static final RegExp _multiWhitespaceRegex = RegExp(r'\s+');
  static final RegExp _hebrewLetterRegex = RegExp(r'[\u05D0-\u05EA]');

  static const Map<String, String> _finalLettersMap = <String, String>{
    'ך': 'כ',
    'ם': 'מ',
    'ן': 'נ',
    'ף': 'פ',
    'ץ': 'צ',
  };

  /// Normalizes Unicode representation to composed NFC form while keeping nikkud intact.
  static String toNfc(String input) => unorm.nfc(input);

  /// Normalizes Unicode representation to decomposed NFD form.
  static String toNfd(String input) => unorm.nfd(input);

  /// Decomposes compatibility presentation forms (U+FB1D..U+FB4F) and combining sequences,
  /// removes Hebrew nikkud/cantillation marks, and recomposes to NFC.
  static String stripNikkud(String input) {
    final decomposed = unorm.nfkd(input);
    final stripped = decomposed.replaceAll(_nikkudRegex, '');
    return unorm.nfc(stripped);
  }

  /// Produces a canonical form suitable for search indexing and answer validation.
  static String normalizeForComparison(
    String input, {
    bool normalizeFinalForms = false,
  }) {
    var result = stripNikkud(
      input.replaceAll('\u05BE', ' '), // Hebrew maqaf -> space before stripping \u0591-\u05C7
    )
        .replaceAll('\u05F3', "'") // Hebrew geresh -> ASCII apostrophe
        .replaceAll('\u2019', "'")
        .replaceAll('\u05F4', '"') // Hebrew gershayim -> ASCII quote
        .replaceAll('\u201D', '"')
        .replaceAll(_multiWhitespaceRegex, ' ')
        .trim();

    if (normalizeFinalForms) {
      result = replaceFinalLetters(result);
    }

    return unorm.nfc(result);
  }

  static String replaceFinalLetters(String input) {
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      final char = String.fromCharCode(rune);
      buffer.write(_finalLettersMap[char] ?? char);
    }
    return buffer.toString();
  }

  /// Extracts pure Hebrew base letters (U+05D0..U+05EA), useful for shoresh validation.
  static String extractHebrewLetters(String input) {
    final stripped = stripNikkud(input);
    final buffer = StringBuffer();
    for (final match in _hebrewLetterRegex.allMatches(stripped)) {
      buffer.write(match.group(0));
    }
    return buffer.toString();
  }

  static bool isMatchWithoutNikkud(
    String rawInput,
    String targetWithNikkud, {
    bool normalizeFinalForms = false,
  }) {
    final normalizedInput = normalizeForComparison(
      rawInput,
      normalizeFinalForms: normalizeFinalForms,
    );
    final normalizedTarget = normalizeForComparison(
      targetWithNikkud,
      normalizeFinalForms: normalizeFinalForms,
    );
    return normalizedInput == normalizedTarget;
  }
}
