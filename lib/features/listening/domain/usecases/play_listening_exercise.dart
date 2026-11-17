import 'package:equatable/equatable.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../entities/listening_exercise.dart';

/// Input parameters for playing a listening exercise at a controlled speed.
final class PlayListeningExerciseParams extends Equatable {
  const PlayListeningExerciseParams({
    required this.exercise,
    this.speed = 1.0,
  });

  final ListeningExercise exercise;
  final double speed;

  @override
  List<Object?> get props => [exercise, speed];
}

/// Configures playback speed (e.g. 0.75x or 1.0x) and plays audio or he-IL TTS fallback.
class PlayListeningExerciseUseCase {
  const PlayListeningExerciseUseCase(this._audioService);

  final AudioPlaybackService _audioService;

  static const double minSpeed = 0.5;
  static const double maxSpeed = 1.5;

  /// Applies [params.speed] and plays [params.exercise].
  Future<Result<void, Failure>> call(
    PlayListeningExerciseParams params,
  ) async {
    if (params.speed < minSpeed || params.speed > maxSpeed) {
      return const Error<void, Failure>(
        ValidationFailure(
          'Скорость воспроизведения должна быть от ${minSpeed}x до ${maxSpeed}x.',
        ),
      );
    }

    final speedRes = await _audioService.setPlaybackSpeed(params.speed);
    if (speedRes case Error<void, Failure>(:final failure)) {
      return Error<void, Failure>(failure);
    }

    return _audioService.playWithTtsFallback(
      sourcePath: params.exercise.audioUrl,
      fallbackHebrewText: params.exercise.transcript.vocalized,
    );
  }
}
