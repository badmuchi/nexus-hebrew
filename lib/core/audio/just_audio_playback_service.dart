import 'dart:async';

import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

import '../error/failures.dart';
import '../logging/app_logger.dart';
import '../result/result.dart';
import 'audio_playback_service.dart';

final class JustAudioPlaybackService implements AudioPlaybackService {
  static const String _tag = 'JustAudioPlaybackService';

  final AudioPlayer _player;
  final AppLogger _logger;
  final StreamController<AudioPlaybackEvent> _statusController =
      StreamController<AudioPlaybackEvent>.broadcast();

  StreamSubscription<PlayerState>? _playerStateSub;
  AudioPlaybackEvent _currentState = const AudioPlaybackEvent.idle();
  double _currentSpeed = 1.0;
  bool _isDisposed = false;

  JustAudioPlaybackService({
    AudioPlayer? player,
    required AppLogger logger,
  })  : _player = player ?? AudioPlayer(),
        _logger = logger {
    _playerStateSub = _player.playerStateStream.listen(_handlePlayerState);
  }

  @override
  Stream<AudioPlaybackEvent> get statusStream => _statusController.stream;

  @override
  AudioPlaybackEvent get currentState => _currentState;

  @override
  double get currentSpeed => _currentSpeed;

  @override
  Future<Result<void, Failure>> setPlaybackSpeed(double speed) async {
    if (speed <= 0.0 || speed > 2.5) {
      return const Error(
        ValidationFailure('Playback speed must be between 0.1 and 2.5'),
      );
    }
    _currentSpeed = speed;
    if (_isDisposed) {
      return const Success(null);
    }
    try {
      await _player.setSpeed(speed);
      return const Success(null);
    } on Object catch (error, stackTrace) {
      _logger.warning(
        _tag,
        'Unable to apply playback speed $speed on player: $error',
      );
      _logger.debug(_tag, stackTrace.toString());
      return const Error(AudioFailure('Unable to adjust playback speed'));
    }
  }

  @override
  Future<Result<void, Failure>> play(String sourcePath) async {
    if (_isDisposed) {
      return const Error(
        AudioFailure('Audio service has already been disposed'),
      );
    }

    final trimmed = sourcePath.trim();
    if (trimmed.isEmpty) {
      return const Error(
        ValidationFailure('Audio source path cannot be empty'),
      );
    }

    _emitState(
      AudioPlaybackEvent(
        sourcePath: trimmed,
        status: AudioPlaybackStatus.loading,
      ),
    );

    try {
      await _player.stop();
      if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
        await _player.setUrl(trimmed);
      } else if (trimmed.startsWith('assets/')) {
        await _player.setAsset(trimmed);
      } else {
        await _player.setFilePath(trimmed);
      }
      await _player.setSpeed(_currentSpeed);

      _emitState(
        AudioPlaybackEvent(
          sourcePath: trimmed,
          status: AudioPlaybackStatus.playing,
        ),
      );
      unawaited(_runPlayLoop(trimmed));
      return const Success(null);
    } on PlayerException catch (error, stackTrace) {
      return _handleAudioError(
        trimmed,
        'Player failed to load "$trimmed": ${error.message ?? error.code}',
        error.toString(),
        stackTrace,
      );
    } on PlatformException catch (error, stackTrace) {
      return _handleAudioError(
        trimmed,
        'Platform audio error for "$trimmed": ${error.message ?? error.code}',
        error.toString(),
        stackTrace,
      );
    } on Object catch (error, stackTrace) {
      return _handleAudioError(
        trimmed,
        'Unable to play audio "$trimmed"',
        error.toString(),
        stackTrace,
      );
    }
  }

  @override
  Future<Result<void, Failure>> playWithTtsFallback({
    required String? sourcePath,
    required String fallbackHebrewText,
  }) {
    final trimmed = sourcePath?.trim() ?? '';
    if (trimmed.isEmpty) {
      return Future<Result<void, Failure>>.value(
        const Error<void, Failure>(
          AudioFailure('Primary audio source is missing and TTS is not configured'),
        ),
      );
    }
    return play(trimmed);
  }

  Future<void> _runPlayLoop(String sourcePath) async {
    try {
      await _player.play();
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Audio playback interrupted for "$sourcePath"',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
      if (!_isDisposed) {
        _emitState(
          AudioPlaybackEvent(
            sourcePath: sourcePath,
            status: AudioPlaybackStatus.error,
          ),
        );
      }
    }
  }

  @override
  Future<Result<void, Failure>> stop() async {
    if (_isDisposed) {
      return const Success(null);
    }
    try {
      await _player.stop();
      _emitState(
        AudioPlaybackEvent(
          sourcePath: _currentState.sourcePath,
          status: AudioPlaybackStatus.idle,
        ),
      );
      return const Success(null);
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Failed to stop audio playback',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
      return const Error(AudioFailure('Unable to stop audio playback'));
    }
  }

  @override
  Future<Result<void, Failure>> dispose() async {
    if (_isDisposed) {
      return const Success(null);
    }
    _isDisposed = true;
    try {
      await _playerStateSub?.cancel();
      await _player.dispose();
      await _statusController.close();
      return const Success(null);
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Failed to dispose audio player',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
      return const Error(AudioFailure('Unable to dispose audio service'));
    }
  }

  void _handlePlayerState(PlayerState state) {
    if (_isDisposed) {
      return;
    }
    final activePath = _currentState.sourcePath;
    if (activePath == null) {
      return;
    }
    if (state.processingState == ProcessingState.completed) {
      _emitState(
        AudioPlaybackEvent(
          sourcePath: activePath,
          status: AudioPlaybackStatus.completed,
        ),
      );
    }
  }

  Error<void, Failure> _handleAudioError(
    String sourcePath,
    String userMessage,
    String details,
    StackTrace stackTrace,
  ) {
    _logger.error(
      _tag,
      userMessage,
      errorDetails: details,
      stackTrace: stackTrace,
    );
    _emitState(
      AudioPlaybackEvent(
        sourcePath: sourcePath,
        status: AudioPlaybackStatus.error,
      ),
    );
    return Error(AudioFailure(userMessage));
  }

  void _emitState(AudioPlaybackEvent event) {
    if (_isDisposed || _statusController.isClosed) {
      return;
    }
    _currentState = event;
    _statusController.add(event);
  }
}
