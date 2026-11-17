import '../../../../core/error/failures.dart';
import '../../../../core/network/json_reader.dart';
import '../../../../core/result/result.dart';
import '../../../conversation/domain/entities/binyan.dart';
import '../../../conversation/domain/entities/hebrew_text.dart';
import '../../domain/entities/story.dart';

final class StoryWordTokenDto {
  final String wordVocalized;
  final String wordNormalized;
  final String russianTranslation;
  final String? transliteration;
  final String? root;
  final String? binyan;
  final String? category;

  const StoryWordTokenDto({
    required this.wordVocalized,
    required this.wordNormalized,
    required this.russianTranslation,
    this.transliteration,
    this.root,
    this.binyan,
    this.category,
  });

  static Result<StoryWordTokenDto, ParsingFailure> fromReader(
      JsonReader reader) {
    final vocalizedRes = reader.requireNonEmptyString('word_vocalized');
    if (vocalizedRes case Error(:final failure)) return Error(failure);

    final normalizedRes = reader.requireNonEmptyString('word_normalized');
    if (normalizedRes case Error(:final failure)) return Error(failure);

    final russianRes = reader.requireNonEmptyString('russian_translation');
    if (russianRes case Error(:final failure)) return Error(failure);

    final transliterationRes = reader.optionalNonEmptyString('transliteration');
    if (transliterationRes case Error(:final failure)) return Error(failure);

    final rootRes = reader.optionalNonEmptyString('root');
    if (rootRes case Error(:final failure)) return Error(failure);

    final binyanRes = reader.optionalNonEmptyString('binyan');
    if (binyanRes case Error(:final failure)) return Error(failure);

    final categoryRes = reader.optionalNonEmptyString('category');
    if (categoryRes case Error(:final failure)) return Error(failure);

    return Success(
      StoryWordTokenDto(
        wordVocalized: vocalizedRes.getOrNull()!,
        wordNormalized: normalizedRes.getOrNull()!,
        russianTranslation: russianRes.getOrNull()!,
        transliteration: transliterationRes.getOrNull(),
        root: rootRes.getOrNull(),
        binyan: binyanRes.getOrNull(),
        category: categoryRes.getOrNull(),
      ),
    );
  }

  Result<StoryWordToken, Failure> toDomain() {
    Shoresh? shoresh;
    if (root != null) {
      final shoreshRes = Shoresh.create(root!);
      if (shoreshRes case Success(:final data)) {
        shoresh = data;
      }
    }

    Binyan? binyanVal;
    if (binyan != null) {
      final binyanRes = Binyan.parseStrict(binyan!);
      if (binyanRes case Success(:final data)) {
        binyanVal = data;
      }
    }

    return Success(
      StoryWordToken(
        wordVocalized: wordVocalized,
        wordNormalized: wordNormalized,
        russianTranslation: russianTranslation,
        transliteration: transliteration,
        root: shoresh,
        binyan: binyanVal,
        category: category,
      ),
    );
  }
}

final class StorySentenceDto {
  final String id;
  final String hebrewVocalized;
  final String russianTranslation;
  final String? audioUrl;
  final List<StoryWordTokenDto> tokens;

  const StorySentenceDto({
    required this.id,
    required this.hebrewVocalized,
    required this.russianTranslation,
    this.audioUrl,
    required this.tokens,
  });

  static Result<StorySentenceDto, ParsingFailure> fromReader(
      JsonReader reader) {
    final idRes = reader.requireNonEmptyString('id');
    if (idRes case Error(:final failure)) return Error(failure);

    final hebrewRes = reader.requireNonEmptyString('hebrew_vocalized');
    if (hebrewRes case Error(:final failure)) return Error(failure);

    final russianRes = reader.requireNonEmptyString('russian_translation');
    if (russianRes case Error(:final failure)) return Error(failure);

    final audioRes = reader.optionalNonEmptyString('audio_url');
    if (audioRes case Error(:final failure)) return Error(failure);

    final tokensRes = reader.requireObjectList('tokens');
    if (tokensRes case Error(:final failure)) return Error(failure);

    final tokens = <StoryWordTokenDto>[];
    for (final tokenReader in tokensRes.getOrNull()!) {
      final itemRes = StoryWordTokenDto.fromReader(tokenReader);
      switch (itemRes) {
        case Success(:final data):
          tokens.add(data);
        case Error(:final failure):
          return Error(failure);
      }
    }

    return Success(
      StorySentenceDto(
        id: idRes.getOrNull()!,
        hebrewVocalized: hebrewRes.getOrNull()!,
        russianTranslation: russianRes.getOrNull()!,
        audioUrl: audioRes.getOrNull(),
        tokens: List<StoryWordTokenDto>.unmodifiable(tokens),
      ),
    );
  }

  Result<StorySentence, Failure> toDomain() {
    final hebrewRes = HebrewText.create(hebrewVocalized);
    if (hebrewRes case Error(:final failure)) return Error(failure);
    final hebrew = hebrewRes.getOrNull()!;

    final domainTokens = <StoryWordToken>[];
    for (final tokenDto in tokens) {
      final res = tokenDto.toDomain();
      if (res case Error(:final failure)) return Error(failure);
      domainTokens.add(res.getOrNull()!);
    }

    return Success(
      StorySentence(
        id: id,
        hebrewVocalized: hebrew.vocalized,
        hebrewNormalized: hebrew.normalized,
        russianTranslation: russianTranslation,
        audioUrl: audioUrl,
        tokens: List<StoryWordToken>.unmodifiable(domainTokens),
      ),
    );
  }
}

final class StoryParagraphDto {
  final String id;
  final List<StorySentenceDto> sentences;

  const StoryParagraphDto({
    required this.id,
    required this.sentences,
  });

  static Result<StoryParagraphDto, ParsingFailure> fromReader(
      JsonReader reader) {
    final idRes = reader.requireNonEmptyString('id');
    if (idRes case Error(:final failure)) return Error(failure);

    final sentencesRes = reader.requireObjectList('sentences');
    if (sentencesRes case Error(:final failure)) return Error(failure);

    final sentences = <StorySentenceDto>[];
    for (final sentenceReader in sentencesRes.getOrNull()!) {
      final itemRes = StorySentenceDto.fromReader(sentenceReader);
      switch (itemRes) {
        case Success(:final data):
          sentences.add(data);
        case Error(:final failure):
          return Error(failure);
      }
    }

    return Success(
      StoryParagraphDto(
        id: idRes.getOrNull()!,
        sentences: List<StorySentenceDto>.unmodifiable(sentences),
      ),
    );
  }

  Result<StoryParagraph, Failure> toDomain() {
    final domainSentences = <StorySentence>[];
    for (final sentenceDto in sentences) {
      final res = sentenceDto.toDomain();
      if (res case Error(:final failure)) return Error(failure);
      domainSentences.add(res.getOrNull()!);
    }

    return Success(
      StoryParagraph(
        id: id,
        sentences: List<StorySentence>.unmodifiable(domainSentences),
      ),
    );
  }
}

final class StoryDto {
  final String id;
  final String titleHebrew;
  final String titleRussian;
  final String level;
  final int readingTimeMinutes;
  final String coverEmoji;
  final String summaryRussian;
  final List<StoryParagraphDto> paragraphs;

  const StoryDto({
    required this.id,
    required this.titleHebrew,
    required this.titleRussian,
    required this.level,
    required this.readingTimeMinutes,
    required this.coverEmoji,
    required this.summaryRussian,
    required this.paragraphs,
  });

  static Result<StoryDto, ParsingFailure> fromReader(JsonReader reader) {
    final idRes = reader.requireNonEmptyString('id');
    if (idRes case Error(:final failure)) return Error(failure);

    final titleHebrewRes = reader.requireNonEmptyString('title_hebrew');
    if (titleHebrewRes case Error(:final failure)) return Error(failure);

    final titleRussianRes = reader.requireNonEmptyString('title_russian');
    if (titleRussianRes case Error(:final failure)) return Error(failure);

    final levelRes = reader.requireNonEmptyString('level');
    if (levelRes case Error(:final failure)) return Error(failure);

    final timeRes = reader.requireInt('reading_time_minutes');
    if (timeRes case Error(:final failure)) return Error(failure);

    final emojiRes = reader.requireNonEmptyString('cover_emoji');
    if (emojiRes case Error(:final failure)) return Error(failure);

    final summaryRes = reader.requireNonEmptyString('summary_russian');
    if (summaryRes case Error(:final failure)) return Error(failure);

    final paragraphsRes = reader.requireObjectList('paragraphs');
    if (paragraphsRes case Error(:final failure)) return Error(failure);

    final paragraphs = <StoryParagraphDto>[];
    for (final paragraphReader in paragraphsRes.getOrNull()!) {
      final itemRes = StoryParagraphDto.fromReader(paragraphReader);
      switch (itemRes) {
        case Success(:final data):
          paragraphs.add(data);
        case Error(:final failure):
          return Error(failure);
      }
    }

    return Success(
      StoryDto(
        id: idRes.getOrNull()!,
        titleHebrew: titleHebrewRes.getOrNull()!,
        titleRussian: titleRussianRes.getOrNull()!,
        level: levelRes.getOrNull()!,
        readingTimeMinutes: timeRes.getOrNull()!,
        coverEmoji: emojiRes.getOrNull()!,
        summaryRussian: summaryRes.getOrNull()!,
        paragraphs: List<StoryParagraphDto>.unmodifiable(paragraphs),
      ),
    );
  }

  Result<Story, Failure> toDomain() {
    final titleRes = HebrewText.create(titleHebrew);
    if (titleRes case Error(:final failure)) return Error(failure);

    final domainParagraphs = <StoryParagraph>[];
    for (final pDto in paragraphs) {
      final pRes = pDto.toDomain();
      if (pRes case Error(:final failure)) return Error(failure);
      domainParagraphs.add(pRes.getOrNull()!);
    }

    return Success(
      Story(
        id: id,
        titleHebrew: titleRes.getOrNull()!,
        titleRussian: titleRussianResFormatted(titleRussian),
        level: level,
        readingTimeMinutes: readingTimeMinutes,
        coverEmoji: coverEmoji,
        summaryRussian: summaryRussian,
        paragraphs: List<StoryParagraph>.unmodifiable(domainParagraphs),
      ),
    );
  }

  static String titleRussianResFormatted(String title) => title.trim();
}
