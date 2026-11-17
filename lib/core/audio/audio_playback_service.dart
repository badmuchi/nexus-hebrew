import 'package:equatable/equatable.dart';

import '../error/failures.dart';
import '../result/result.dart';

enum AudioPlaybackStatus {
  idle,
  loading,
  playing,
  paused,
  completed,
  error,
}

final class AudioPlaybackEvent extends Equatable {
  final String? sourcePath;
  final AudioPlaybackStatus status;

  const AudioPlaybackEvent({
    required this.status,
    this.sourcePath,
  });

  const AudioPlaybackEvent.idle()
      : sourcePath = null,
        status = AudioPlaybackStatus.idle;

  @override
  List<Object?> get props => [sourcePath, status];
}

abstract interface class AudioPlaybackService {
  Stream<AudioPlaybackEvent> get statusStream;
  AudioPlaybackEvent get currentState;
  double get currentSpeed;

  Future<Result<void, Failure>> setPlaybackSpeed(double speed);
  Future<Result<void, Failure>> play(String sourcePath);
  Future<Result<void, Failure>> playWithTtsFallback({
    required String? sourcePath,
    required String fallbackHebrewText,
  });
  Future<Result<void, Failure>> stop();
  Future<Result<void, Failure>> dispose();
}
