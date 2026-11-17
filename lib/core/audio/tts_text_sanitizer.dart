import '../utils/hebrew_normalizer.dart';

/// Sanitizes vocalized Hebrew strings so system TTS engines read natural speech.
abstract final class TtsTextSanitizer {
  static final RegExp _cantillationAndRareMarksPattern =
      RegExp(r'[\u0591-\u05AF\u05BD\u05BF\u05C0\u05C3\u200E\u200F\u202A-\u202E\u2066-\u2069]');
  static final RegExp _whitespacePattern = RegExp(r'\s+');

  /// Keeps standard nikkud for accurate pronunciation while stripping cantillation,
  /// meteg/rafe, directional markers, brackets, and separators that confuse TTS.
  static String sanitizeForHebrewTts(String raw) {
    var text = HebrewNormalizer.toNfc(raw);
    text = text.replaceAll(_cantillationAndRareMarksPattern, '');
    text = text
        .replaceAll('\u05BE', ' ')
        .replaceAll('—', ', ')
        .replaceAll('–', ', ')
        .replaceAll('·', ', ')
        .replaceAll(';', ', ')
        .replaceAll('/', ', ')
        .replaceAll('(', ' ')
        .replaceAll(')', ' ')
        .replaceAll('[', ' ')
        .replaceAll(']', ' ');
    return text.replaceAll(_whitespacePattern, ' ').trim();
  }
}
