import 'dart:async';

import '../error/failures.dart';
import '../logging/app_logger.dart';
import '../result/result.dart';
import 'audio_playback_service.dart';
import 'tts_speech_service.dart';

/// Audio service that prefers native recordings (Tatoeba / Wikimedia / local assets)
/// and gracefully falls back to on-device `he-IL` TTS when audio assets are missing or offline.
final class HybridAudioPlaybackService implements AudioPlaybackService {
  static const String _tag = 'HybridAudioPlaybackService';

  final AudioPlaybackService _primaryAudioService;
  final TtsSpeechService _ttsService;
  final AppLogger _logger;
  final StreamController<AudioPlaybackEvent> _statusController =
      StreamController<AudioPlaybackEvent>.broadcast();

  StreamSubscription<AudioPlaybackEvent>? _primarySub;
  AudioPlaybackEvent _currentState = const AudioPlaybackEvent.idle();
  double _currentSpeed = 1.0;
  bool _isDisposed = false;

  HybridAudioPlaybackService({
    required AudioPlaybackService primaryAudioService,
    required TtsSpeechService ttsService,
    required AppLogger logger,
  })  : _primaryAudioService = primaryAudioService,
        _ttsService = ttsService,
        _logger = logger {
    _primarySub = _primaryAudioService.statusStream.listen((event) {
      _emitState(event);
    });
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
    final primaryRes = await _primaryAudioService.setPlaybackSpeed(speed);
    final ttsRes = await _ttsService.setSpeed(speed);
    if (primaryRes.isError) return primaryRes;
    return ttsRes;
  }

  @override
  Future<Result<void, Failure>> play(String sourcePath) async {
    if (_isDisposed) {
      return const Error(AudioFailure('Audio service has been disposed'));
    }
    await _ttsService.stop();
    return _primaryAudioService.play(sourcePath);
  }

  @override
  Future<Result<void, Failure>> playWithTtsFallback({
    required String? sourcePath,
    required String fallbackHebrewText,
  }) async {
    if (_isDisposed) {
      return const Error(AudioFailure('Audio service has been disposed'));
    }

    final trimmedSource = sourcePath?.trim() ?? '';
    if (trimmedSource.isNotEmpty) {
      final primaryRes = await play(trimmedSource);
      if (primaryRes.isSuccess) {
        return primaryRes;
      }
      _logger.warning(
        _tag,
        'Primary audio "$trimmedSource" failed, falling back to he-IL TTS',
        failure: primaryRes.failureOrNull(),
      );
    }

    final fallbackTrimmed = fallbackHebrewText.trim();
    if (fallbackTrimmed.isEmpty) {
      return const Error(
        ValidationFailure('No audio source or Hebrew text available to speak'),
      );
    }

    final ttsSourceKey = 'tts://he-IL/$fallbackTrimmed';
    _emitState(
      AudioPlaybackEvent(
        sourcePath: ttsSourceKey,
        status: AudioPlaybackStatus.playing,
      ),
    );
    final ttsRes = await _ttsService.speak(fallbackTrimmed);
    if (ttsRes case Error(:final failure)) {
      _emitState(
        AudioPlaybackEvent(
          sourcePath: ttsSourceKey,
          status: AudioPlaybackStatus.error,
        ),
      );
      return Error(failure);
    }
    return const Success(null);
  }

  @override
  Future<Result<void, Failure>> stop() async {
    if (_isDisposed) {
      return const Success(null);
    }
    final primaryStop = await _primaryAudioService.stop();
    final ttsStop = await _ttsService.stop();
    _emitState(
      AudioPlaybackEvent(
        sourcePath: _currentState.sourcePath,
        status: AudioPlaybackStatus.idle,
      ),
    );
    if (primaryStop.isError) return primaryStop;
    return ttsStop;
  }

  @override
  Future<Result<void, Failure>> dispose() async {
    if (_isDisposed) {
      return const Success(null);
    }
    _isDisposed = true;
    await _primarySub?.cancel();
    await _ttsService.dispose();
    final primaryDispose = await _primaryAudioService.dispose();
    await _statusController.close();
    return primaryDispose;
  }

  void handleTtsComplete() {
    if (_isDisposed) {
      return;
    }
    final activeSource = _currentState.sourcePath;
    if (activeSource == null || !activeSource.startsWith('tts://')) {
      return;
    }
    _emitState(
      AudioPlaybackEvent(
        sourcePath: activeSource,
        status: AudioPlaybackStatus.completed,
      ),
    );
  }

  void handleTtsError([String? message]) {
    if (_isDisposed) {
      return;
    }
    final activeSource = _currentState.sourcePath;
    if (activeSource == null || !activeSource.startsWith('tts://')) {
      return;
    }
    if (message != null && message.isNotEmpty) {
      _logger.warning(_tag, 'TTS playback reported error: $message');
    }
    _emitState(
      AudioPlaybackEvent(
        sourcePath: activeSource,
        status: AudioPlaybackStatus.error,
      ),
    );
  }

  void _emitState(AudioPlaybackEvent event) {
    if (_isDisposed || _statusController.isClosed) {
      return;
    }
    _currentState = event;
    _statusController.add(event);
  }
}
