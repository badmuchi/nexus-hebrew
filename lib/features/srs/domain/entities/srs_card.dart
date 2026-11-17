import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../../conversation/domain/entities/binyan.dart';
import '../../../conversation/domain/entities/hebrew_text.dart';
import 'fsrs_models.dart';

enum LexicalCategory {
  noun('noun', 'Существительное'),
  verb('verb', 'Глагол'),
  adjective('adjective', 'Прилагательное'),
  phrase('phrase', 'Фраза'),
  particle('particle', 'Служебная часть речи');

  final String id;
  final String labelRu;

  const LexicalCategory(this.id, this.labelRu);

  static Result<LexicalCategory, ParsingFailure> parseStrict(String raw) {
    final normalized = raw.trim().toLowerCase();
    for (final category in LexicalCategory.values) {
      if (category.id == normalized) {
        return Success(category);
      }
    }
    return Error(ParsingFailure('Unknown lexical category: "$raw"'));
  }
}

final class ContentAttribution extends Equatable {
  final String sourceName;
  final String licenseName;
  final String? attributionText;

  const ContentAttribution({
    required this.sourceName,
    required this.licenseName,
    this.attributionText,
  });

  @override
  List<Object?> get props => [sourceName, licenseName, attributionText];
}

final class SrsCard extends Equatable {
  final String id;
  final HebrewText hebrew;
  final String russianTranslation;
  final Shoresh? root;
  final Binyan binyan;
  final LexicalCategory category;
  final HebrewText? exampleHebrew;
  final String? exampleRussian;
  final String? audioUrl;
  final ContentAttribution attribution;
  final FsrsMemoryState memory;

  const SrsCard({
    required this.id,
    required this.hebrew,
    required this.russianTranslation,
    required this.attribution,
    required this.memory,
    this.root,
    this.binyan = Binyan.none,
    this.category = LexicalCategory.phrase,
    this.exampleHebrew,
    this.exampleRussian,
    this.audioUrl,
  });

  SrsCard copyWith({FsrsMemoryState? memory}) {
    return SrsCard(
      id: id,
      hebrew: hebrew,
      russianTranslation: russianTranslation,
      root: root,
      binyan: binyan,
      category: category,
      exampleHebrew: exampleHebrew,
      exampleRussian: exampleRussian,
      audioUrl: audioUrl,
      attribution: attribution,
      memory: memory ?? this.memory,
    );
  }

  @override
  List<Object?> get props => [
        id,
        hebrew,
        russianTranslation,
        root,
        binyan,
        category,
        exampleHebrew,
        exampleRussian,
        audioUrl,
        attribution,
        memory,
      ];
}

final class TypingAnswerEvaluation extends Equatable {
  final bool isMatch;
  final String normalizedUserInput;
  final String expectedNormalized;
  final String expectedVocalized;

  const TypingAnswerEvaluation({
    required this.isMatch,
    required this.normalizedUserInput,
    required this.expectedNormalized,
    required this.expectedVocalized,
  });

  @override
  List<Object?> get props => [
        isMatch,
        normalizedUserInput,
        expectedNormalized,
        expectedVocalized,
      ];
}
