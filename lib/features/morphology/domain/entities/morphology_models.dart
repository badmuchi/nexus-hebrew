import 'package:equatable/equatable.dart';

import '../../../conversation/domain/entities/binyan.dart';
import '../../../conversation/domain/entities/hebrew_text.dart';

enum MorphemeType {
  conjunction, // Союз "и/а" (ו)
  preposition, // Предлог "в/на", "к/для", "из/от", "как" (ב, ל, מ, כ)
  relative, // Относительный союз "что/который" (ש)
  definiteArticle, // Определенный артикль "тот самый" (ה)
  baseLemma, // Словарная основа / лемма
  genderNumberSuffix, // Окончание рода/числа (-ים, -ות, -ת, -ה)
  pronominalSuffix, // Местоименное окончание принадлежности (-י, -נו, -ך, -ו, -ה)
  pastTenseSuffix, // Окончание прошедшего времени (-תי, -ת, -נו, -ו)
  futurePrefix, // Приставка будущего времени (א, ת, י, נ)
  unknown,
}

final class PrefixToken extends Equatable {
  final String raw;
  final String normalized;
  final String meaning;
  final MorphemeType type;

  const PrefixToken({
    required this.raw,
    required this.normalized,
    required this.meaning,
    required this.type,
  });

  @override
  List<Object?> get props => [raw, normalized, meaning, type];
}

final class SuffixToken extends Equatable {
  final String raw;
  final String normalized;
  final String meaning;
  final MorphemeType type;

  const SuffixToken({
    required this.raw,
    required this.normalized,
    required this.meaning,
    required this.type,
  });

  @override
  List<Object?> get props => [raw, normalized, meaning, type];
}

final class WordMorphology extends Equatable {
  final String rawToken;
  final String cleanVocalized;
  final String cleanNormalized;
  final List<PrefixToken> prefixes;
  final String lemma;
  final String lemmaNormalized;
  final String translation;
  final String? partOfSpeech;
  final Shoresh? root;
  final Binyan? binyan;
  final SuffixToken? suffix;
  final String explanation;

  const WordMorphology({
    required this.rawToken,
    required this.cleanVocalized,
    required this.cleanNormalized,
    this.prefixes = const <PrefixToken>[],
    required this.lemma,
    required this.lemmaNormalized,
    required this.translation,
    this.partOfSpeech,
    this.root,
    this.binyan,
    this.suffix,
    required this.explanation,
  });

  bool get hasPrefixes => prefixes.isNotEmpty;
  bool get hasSuffix => suffix != null;
  bool get hasRoot => root != null;

  @override
  List<Object?> get props => [
        rawToken,
        cleanVocalized,
        cleanNormalized,
        prefixes,
        lemma,
        lemmaNormalized,
        translation,
        partOfSpeech,
        root,
        binyan,
        suffix,
        explanation,
      ];
}

final class SentenceMorphology extends Equatable {
  final String originalSentence;
  final String? russianTranslation;
  final List<WordMorphology> words;

  const SentenceMorphology({
    required this.originalSentence,
    this.russianTranslation,
    required this.words,
  });

  @override
  List<Object?> get props => [originalSentence, russianTranslation, words];
}
