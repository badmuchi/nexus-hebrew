import 'dart:convert';

import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/json_reader.dart';
import '../../../../core/result/result.dart';
import '../../../conversation/domain/entities/hebrew_text.dart';
import '../../../srs/data/models/srs_card_dto.dart';
import '../../../srs/domain/entities/srs_card.dart';
import '../../domain/entities/listening_exercise.dart';

/// Strict boundary DTO for Hebrew listening exercises and dictation transcripts.
final class ListeningExerciseDto extends Equatable {
  ListeningExerciseDto({
    required this.id,
    required this.transcriptVocalized,
    required this.russianTranslation,
    this.audioUrl,
    this.difficulty = 'beginner',
    List<String> focusWords = const <String>[],
    required this.sourceName,
    required this.licenseName,
    this.attributionText,
  }) : focusWords = List<String>.unmodifiable(focusWords);

  final String id;
  final String transcriptVocalized;
  final String russianTranslation;
  final String? audioUrl;
  final String difficulty;
  final List<String> focusWords;
  final String sourceName;
  final String licenseName;
  final String? attributionText;

  static final RegExp _splitWordsRegex = RegExp(r'[\s,.\?!:;—–\-"]+');

  /// Parses and validates a listening exercise object from [reader].
  static Result<ListeningExerciseDto, ParsingFailure> fromReader(
    JsonReader reader,
  ) {
    final idRes = reader.requireNonEmptyString('id');
    if (idRes case Error(:final failure)) {
      return Error(failure);
    }

    final transcriptRes = reader.requireNonEmptyString('transcript_vocalized');
    if (transcriptRes case Error(:final failure)) {
      return Error(failure);
    }

    final translationRes = reader.requireNonEmptyString('russian_translation');
    if (translationRes case Error(:final failure)) {
      return Error(failure);
    }

    final audioRes = reader.optionalNonEmptyString('audio_url');
    if (audioRes case Error(:final failure)) {
      return Error(failure);
    }

    final difficultyRes = reader.optionalNonEmptyString('difficulty');
    if (difficultyRes case Error(:final failure)) {
      return Error(failure);
    }

    final focusWordsRes = reader.optionalStringList('focus_words');
    if (focusWordsRes case Error(:final failure)) {
      return Error(failure);
    }

    final sourceRes = reader.requireNonEmptyString('source_name');
    if (sourceRes case Error(:final failure)) {
      return Error(failure);
    }

    final licenseRes = reader.requireNonEmptyString('license_name');
    if (licenseRes case Error(:final failure)) {
      return Error(failure);
    }

    final attributionRes = reader.optionalNonEmptyString('attribution_text');
    if (attributionRes case Error(:final failure)) {
      return Error(failure);
    }

    return Success(
      ListeningExerciseDto(
        id: idRes.getOrNull()!,
        transcriptVocalized: transcriptRes.getOrNull()!,
        russianTranslation: translationRes.getOrNull()!,
        audioUrl: audioRes.getOrNull(),
        difficulty: difficultyRes.getOrNull() ?? 'beginner',
        focusWords: focusWordsRes.getOrNull()!,
        sourceName: sourceRes.getOrNull()!,
        licenseName: licenseRes.getOrNull()!,
        attributionText: attributionRes.getOrNull(),
      ),
    );
  }

  /// Adapts a filtered open-licensed Tatoeba [SrsCardDto] into a listening exercise DTO.
  factory ListeningExerciseDto.fromTatoebaSrsDto(SrsCardDto dto) {
    final tokens = dto.hebrewVocalized
        .split(_splitWordsRegex)
        .map((String w) => w.trim())
        .where((String w) => w.isNotEmpty)
        .toList(growable: false);

    final tier = switch (tokens.length) {
      <= 4 => 'beginner',
      <= 8 => 'intermediate',
      _ => 'advanced',
    };

    final distinctFocusWords = <String>[];
    for (final token in tokens) {
      if (token.runes.length >= 2 && !distinctFocusWords.contains(token)) {
        distinctFocusWords.add(token);
        if (distinctFocusWords.length == 4) break;
      }
    }

    return ListeningExerciseDto(
      id: 'listen_${dto.id}',
      transcriptVocalized: dto.hebrewVocalized,
      russianTranslation: dto.russianTranslation,
      audioUrl: dto.audioUrl,
      difficulty: tier,
      focusWords: distinctFocusWords,
      sourceName: dto.sourceName,
      licenseName: dto.licenseName,
      attributionText: dto.attributionText,
    );
  }

  /// Converts validated DTO fields into a domain [ListeningExercise].
  Result<ListeningExercise, Failure> toDomain() {
    final transcriptRes = HebrewText.create(transcriptVocalized);
    if (transcriptRes case Error(:final failure)) {
      return Error(failure);
    }

    final difficultyRes = ListeningDifficulty.parseStrict(difficulty);
    if (difficultyRes case Error(:final failure)) {
      return Error(failure);
    }

    return Success(
      ListeningExercise(
        id: id,
        transcript: transcriptRes.getOrNull()!,
        russianTranslation: russianTranslation,
        audioUrl: audioUrl,
        difficulty: difficultyRes.getOrNull()!,
        focusWords: focusWords,
        attribution: ContentAttribution(
          sourceName: sourceName,
          licenseName: licenseName,
          attributionText: attributionText,
        ),
      ),
    );
  }

  /// Serializes [focusWords] to a JSON string array for Drift storage.
  static String encodeFocusWordsJson(List<String> focusWords) {
    return jsonEncode(focusWords);
  }

  /// Decodes a stored JSON array string into an unmodifiable list of focus words.
  static Result<List<String>, ParsingFailure> decodeFocusWordsJson(
    String rawJson,
  ) {
    return JsonReader.parseStringList(rawJson);
  }

  @override
  List<Object?> get props => [
        id,
        transcriptVocalized,
        russianTranslation,
        audioUrl,
        difficulty,
        focusWords,
        sourceName,
        licenseName,
        attributionText,
      ];
}
