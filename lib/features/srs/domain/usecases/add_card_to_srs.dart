import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../../conversation/domain/entities/binyan.dart';
import '../../../conversation/domain/entities/hebrew_text.dart';
import '../entities/fsrs_models.dart';
import '../entities/srs_card.dart';
import '../repositories/srs_repository.dart';

typedef SrsCardClockUtc = DateTime Function();

/// Input payload for saving a word or phrase from any feature into the FSRS deck.
final class AddCardToSrsParams extends Equatable {
  const AddCardToSrsParams({
    required this.id,
    required this.hebrewVocalized,
    required this.russianTranslation,
    this.root,
    this.binyan = Binyan.none,
    this.category = LexicalCategory.phrase,
    this.exampleHebrewVocalized,
    this.exampleRussian,
    this.audioUrl,
    this.attribution = const ContentAttribution(
      sourceName: 'Nexus User Deck',
      licenseName: 'CC0 1.0',
    ),
  });

  final String id;
  final String hebrewVocalized;
  final String russianTranslation;
  final Shoresh? root;
  final Binyan binyan;
  final LexicalCategory category;
  final String? exampleHebrewVocalized;
  final String? exampleRussian;
  final String? audioUrl;
  final ContentAttribution attribution;

  @override
  List<Object?> get props => [
        id,
        hebrewVocalized,
        russianTranslation,
        root,
        binyan,
        category,
        exampleHebrewVocalized,
        exampleRussian,
        audioUrl,
        attribution,
      ];
}

/// Validates and adds a Hebrew word/phrase to the user's FSRS deck if absent.
/// Returns `true` if newly inserted or `false` if already present.
class AddCardToSrsUseCase {
  AddCardToSrsUseCase({
    required SrsRepository repository,
    SrsCardClockUtc? clock,
  })  : _repository = repository,
        _clock = clock ?? (() => DateTime.now().toUtc());

  final SrsRepository _repository;
  final SrsCardClockUtc _clock;

  /// Validates [params] and inserts the flashcard into FSRS storage.
  Future<Result<bool, Failure>> call(AddCardToSrsParams params) async {
    final trimmedId = params.id.trim();
    if (trimmedId.isEmpty) {
      return const Error<bool, Failure>(
        ValidationFailure('ID карточки не может быть пустым.'),
      );
    }

    final trimmedTranslation = params.russianTranslation.trim();
    if (trimmedTranslation.isEmpty) {
      return const Error<bool, Failure>(
        ValidationFailure('Перевод карточки не может быть пустым.'),
      );
    }

    final hebrewRes = HebrewText.create(params.hebrewVocalized);
    if (hebrewRes case Error<HebrewText, ValidationFailure>(:final failure)) {
      return Error<bool, Failure>(failure);
    }

    HebrewText? exampleHeb;
    final rawExample = params.exampleHebrewVocalized?.trim();
    if (rawExample != null && rawExample.isNotEmpty) {
      final exRes = HebrewText.create(rawExample);
      switch (exRes) {
        case Success<HebrewText, ValidationFailure>(:final data):
          exampleHeb = data;
        case Error<HebrewText, ValidationFailure>(:final failure):
          return Error<bool, Failure>(failure);
      }
    }

    final now = _clock();
    final card = SrsCard(
      id: trimmedId,
      hebrew: hebrewRes.getOrNull()!,
      russianTranslation: trimmedTranslation,
      root: params.root,
      binyan: params.binyan,
      category: params.category,
      exampleHebrew: exampleHeb,
      exampleRussian: params.exampleRussian?.trim().isEmpty ?? true
          ? null
          : params.exampleRussian?.trim(),
      audioUrl: params.audioUrl?.trim().isEmpty ?? true
          ? null
          : params.audioUrl?.trim(),
      attribution: params.attribution,
      memory: FsrsMemoryState.initial(now: now),
    );

    return _repository.addCustomCard(card);
  }
}
