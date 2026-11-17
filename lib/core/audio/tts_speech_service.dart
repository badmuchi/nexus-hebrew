import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../error/failures.dart';
import '../logging/app_logger.dart';
import '../result/result.dart';
import 'tts_speech_service_factory_io.dart'
    if (dart.library.js_interop) 'tts_speech_service_factory_web.dart'
    as platform_factory;
import 'tts_text_sanitizer.dart';

abstract interface class TtsSpeechService {
  Future<Result<void, Failure>> setSpeed(double speed);
  Future<Result<void, Failure>> speak(
    String text, {
    String languageTag = 'he-IL',
  });
  Future<Result<void, Failure>> stop();
  Future<void> dispose();
}

/// Instantiates the best TTS backend for the current platform (dedicated Web
/// Speech API on Web, [FlutterTtsSpeechService] on mobile/desktop).
TtsSpeechService createPlatformTtsSpeechService({
  required AppLogger logger,
  void Function()? onComplete,
  void Function(String message)? onError,
}) {
  return platform_factory.buildPlatformTtsSpeechService(
    logger: logger,
    onComplete: onComplete,
    onError: onError,
  );
}

final class FlutterTtsSpeechService implements TtsSpeechService {
  static const String _tag = 'FlutterTtsSpeechService';

  final FlutterTts _tts;
  final AppLogger _logger;
  final void Function()? _onComplete;
  final void Function(String message)? _onError;

  bool _isConfigured = false;
  bool _isDisposed = false;
  double _speechRate = _calibrateNativeRate(1.0);

  FlutterTtsSpeechService({
    FlutterTts? tts,
    required AppLogger logger,
    void Function()? onComplete,
    void Function(String message)? onError,
  })  : _tts = tts ?? FlutterTts(),
        _logger = logger,
        _onComplete = onComplete,
        _onError = onError {
    _tts.setCompletionHandler(() {
      _onComplete?.call();
    });
    _tts.setErrorHandler((Object? msg) {
      final text = msg?.toString() ?? 'Unknown TTS engine error';
      _logger.warning(_tag, 'TTS handler reported error: $text');
      _onError?.call(text);
    });
  }

  static double _calibrateNativeRate(double speed) {
    final base = defaultTargetPlatform == TargetPlatform.iOS ? 0.5 : 0.95;
    return (base * speed).clamp(0.25, 1.4);
  }

  @override
  Future<Result<void, Failure>> setSpeed(double speed) async {
    if (speed <= 0.0 || speed > 2.5) {
      return const Error(
        ValidationFailure('TTS speed multiplier must be between 0.1 and 2.5'),
      );
    }
    _speechRate = _calibrateNativeRate(speed);
    if (_isDisposed || !_isConfigured) {
      return const Success(null);
    }
    try {
      await _tts.setSpeechRate(_speechRate);
      return const Success(null);
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Failed to update TTS speech rate',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
      return const Error(AudioFailure('Unable to adjust TTS speech rate'));
    }
  }

  @override
  Future<Result<void, Failure>> speak(
    String text, {
    String languageTag = 'he-IL',
  }) async {
    if (_isDisposed) {
      return const Error(AudioFailure('TTS service is disposed'));
    }

    final cleaned = TtsTextSanitizer.sanitizeForHebrewTts(text);
    if (cleaned.isEmpty) {
      return const Error(
        ValidationFailure('TTS text cannot be empty'),
      );
    }

    try {
      if (!_isConfigured) {
        await _tts.setLanguage(languageTag);
        await _tts.setSpeechRate(_speechRate);
        await _tts.setVolume(1.0);
        await _tts.setPitch(1.0);
        _isConfigured = true;
      }
      await _tts.stop();
      await _tts.speak(cleaned);
      return const Success(null);
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'System TTS failed to speak Hebrew text',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
      return const Error(
        AudioFailure('System Hebrew TTS is unavailable on this device'),
      );
    }
  }

  @override
  Future<Result<void, Failure>> stop() async {
    if (_isDisposed) {
      return const Success(null);
    }
    try {
      await _tts.stop();
      return const Success(null);
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Failed to stop TTS engine',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
      return const Error(AudioFailure('Unable to stop system TTS'));
    }
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) {
      return;
    }
    _isDisposed = true;
    await stop();
  }
}
