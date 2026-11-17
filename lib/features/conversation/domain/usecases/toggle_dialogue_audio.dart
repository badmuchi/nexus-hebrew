import '../../../../core/audio/audio_playback_service.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';

class ToggleDialogueAudioUseCase {
  final AudioPlaybackService _audioService;

  const ToggleDialogueAudioUseCase(this._audioService);

  Future<Result<void, Failure>> execute(
    String? audioPath, {
    String? fallbackHebrewText,
  }) async {
    final trimmedPath = audioPath?.trim() ?? '';
    final trimmedFallback = fallbackHebrewText?.trim() ?? '';

    if (trimmedPath.isEmpty && trimmedFallback.isEmpty) {
      return const Error(
        ValidationFailure('No audio track attached to this dialogue line'),
      );
    }

    final current = _audioService.currentState;
    final isCurrentlyActive = current.status == AudioPlaybackStatus.playing ||
        current.status == AudioPlaybackStatus.loading;
    final matchesPath = trimmedPath.isNotEmpty && current.sourcePath == trimmedPath;
    final matchesTts = trimmedFallback.isNotEmpty &&
        current.sourcePath == 'tts://he-IL/$trimmedFallback';

    if (isCurrentlyActive && (matchesPath || matchesTts)) {
      return _audioService.stop();
    }

    if (trimmedFallback.isNotEmpty) {
      return _audioService.playWithTtsFallback(
        sourcePath: trimmedPath.isEmpty ? null : trimmedPath,
        fallbackHebrewText: trimmedFallback,
      );
    }

    return _audioService.play(trimmedPath);
  }
}
