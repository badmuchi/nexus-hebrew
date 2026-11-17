import '../../../../core/utils/hebrew_normalizer.dart';
import '../../../conversation/domain/entities/hebrew_text.dart';
import '../entities/story.dart';

/// Parses arbitrary Hebrew text into a structured [Story] entity suitable for
/// [StoryReaderScreen] with live audio playback, word lookup, and SRS saving.
final class CustomTextStoryParser {
  const CustomTextStoryParser._();

  static Story parse({
    required String rawText,
    String? title,
    String? titleRussian,
    Map<String, String> dictionaryLookup = const {},
  }) {
    final cleanInput = rawText.trim();
    if (cleanInput.isEmpty) {
      throw const FormatException('Hebrew text cannot be empty');
    }

    final effectiveTitleRu = (titleRussian != null && titleRussian.trim().isNotEmpty)
        ? titleRussian.trim()
        : 'Пользовательский текст';

    final effectiveTitleHe = (title != null && title.trim().isNotEmpty)
        ? title.trim()
        : 'טֶקְסְט אִישִׁי';

    final hebrewTitleObj = HebrewText.create(effectiveTitleHe).getOrNull() ??
        const HebrewText.fixture(
          vocalized: 'טֶקְסְט אִישִׁי',
          normalized: 'טקסט אישי',
        );

    // Split by double newlines or single newlines into paragraphs
    final rawParagraphs = cleanInput
        .split(RegExp(r'\n{2,}'))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList(growable: false);

    final paragraphs = <StoryParagraph>[];
    var sentenceCounter = 1;
    var totalWordCount = 0;

    for (var pIdx = 0; pIdx < rawParagraphs.length; pIdx++) {
      final pText = rawParagraphs[pIdx];
      final rawSentences = _splitIntoSentences(pText);
      final sentences = <StorySentence>[];

      for (final sText in rawSentences) {
        if (sText.trim().isEmpty) continue;

        final sentenceId = 'custom_s_$sentenceCounter';
        sentenceCounter++;

        final rawTokens = sText.trim().split(RegExp(r'\s+'));
        final wordTokens = <StoryWordToken>[];

        for (final tokenStr in rawTokens) {
          final trimmedToken = tokenStr.trim();
          if (trimmedToken.isEmpty) continue;

          totalWordCount++;
          final cleanWord = trimmedToken.replaceAll(
            RegExp(r'[^\u0590-\u05FFa-zA-Zа-яА-Я0-9]'),
            '',
          );
          final normalizedWord = HebrewNormalizer.stripNikkud(
            cleanWord.isNotEmpty ? cleanWord : trimmedToken,
          );

          final translation = dictionaryLookup[normalizedWord] ?? '';

          wordTokens.add(
            StoryWordToken(
              wordVocalized: trimmedToken,
              wordNormalized: normalizedWord,
              russianTranslation: translation,
            ),
          );
        }

        sentences.add(
          StorySentence(
            id: sentenceId,
            hebrewVocalized: sText.trim(),
            hebrewNormalized: HebrewNormalizer.stripNikkud(sText.trim()),
            russianTranslation: '',
            audioUrl: null, // Forces TTS playback
            tokens: wordTokens,
          ),
        );
      }

      if (sentences.isNotEmpty) {
        paragraphs.add(
          StoryParagraph(
            id: 'custom_p_${pIdx + 1}',
            sentences: sentences,
          ),
        );
      }
    }

    final readingMinutes = (totalWordCount / 20.0).ceil().clamp(1, 60);

    return Story(
      id: 'custom_story_${DateTime.now().millisecondsSinceEpoch}',
      titleHebrew: hebrewTitleObj,
      titleRussian: effectiveTitleRu,
      level: 'Свой текст',
      readingTimeMinutes: readingMinutes,
      coverEmoji: '📰',
      summaryRussian: 'Импортированный текст для свободного чтения и разбора корней',
      paragraphs: paragraphs,
    );
  }

  static List<String> _splitIntoSentences(String text) {
    final result = <String>[];
    final buffer = StringBuffer();

    for (var i = 0; i < text.length; i++) {
      final char = text[i];
      buffer.write(char);

      if (char == '.' || char == '!' || char == '?' || char == '\n') {
        final sentence = buffer.toString().trim();
        if (sentence.isNotEmpty) {
          result.add(sentence);
        }
        buffer.clear();
      }
    }

    final remaining = buffer.toString().trim();
    if (remaining.isNotEmpty) {
      result.add(remaining);
    }

    return result.isEmpty ? [text.trim()] : result;
  }
}
