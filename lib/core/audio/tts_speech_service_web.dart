import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import '../error/failures.dart';
import '../logging/app_logger.dart';
import '../result/result.dart';
import 'tts_speech_service.dart';
import 'tts_text_sanitizer.dart';

@JS('speechSynthesis')
external _WebSpeechSynthesis get _webSpeechSynthesis;

@JS()
extension type _WebSpeechSynthesis._(JSObject _) implements JSObject {
  external bool get speaking;
  external bool get pending;
  external bool get paused;
  external void cancel();
  external void resume();
  external JSArray<_WebSpeechSynthesisVoice> getVoices();
  external void speak(_WebSpeechUtterance utterance);
  @JS('addEventListener')
  external void addEventListener(String type, JSFunction listener);
  @JS('removeEventListener')
  external void removeEventListener(String type, JSFunction listener);
}

@JS('SpeechSynthesisUtterance')
extension type _WebSpeechUtterance._(JSObject _) implements JSObject {
  external factory _WebSpeechUtterance([String text]);
  external set lang(String value);
  external set pitch(double value);
  external set rate(double value);
  external set volume(double value);
  external set voice(_WebSpeechSynthesisVoice? value);
  @JS('onend')
  external set onEnd(JSFunction? value);
  @JS('onerror')
  external set onError(JSFunction? value);
}

@JS()
extension type _WebSpeechSynthesisVoice._(JSObject _) implements JSObject {
  external String get lang;
  @JS('localService')
  external bool get isLocalService;
  external String get name;
}

@JS()
extension type _WebSpeechErrorEvent._(JSObject _) implements JSObject {
  external String? get error;
}

/// Web Speech API implementation tailored for Chromium/macOS Hebrew playback.
final class WebTtsSpeechService implements TtsSpeechService {
  static const String _tag = 'WebTtsSpeechService';

  final AppLogger _logger;
  final void Function()? _onComplete;
  final void Function(String message)? _onError;

  double _speedMultiplier = 1.0;
  bool _isDisposed = false;
  int _requestToken = 0;
  int _activeToken = 0;
  _WebSpeechUtterance? _activeUtterance;

  WebTtsSpeechService({
    required AppLogger logger,
    void Function()? onComplete,
    void Function(String message)? onError,
  })  : _logger = logger,
        _onComplete = onComplete,
        _onError = onError;

  _WebSpeechSynthesis? get _synthOrNull {
    if (!globalContext.has('speechSynthesis')) {
      return null;
    }
    try {
      return _webSpeechSynthesis;
    } on Object {
      return null;
    }
  }

  @override
  Future<Result<void, Failure>> setSpeed(double speed) async {
    if (speed <= 0.0 || speed > 2.5) {
      return const Error<void, Failure>(
        ValidationFailure('TTS speed multiplier must be between 0.1 and 2.5'),
      );
    }
    _speedMultiplier = speed;
    return const Success<void, Failure>(null);
  }

  @override
  Future<Result<void, Failure>> speak(
    String text, {
    String languageTag = 'he-IL',
  }) async {
    if (_isDisposed) {
      return const Error<void, Failure>(AudioFailure('TTS service is disposed'));
    }

    final cleaned = TtsTextSanitizer.sanitizeForHebrewTts(text);
    if (cleaned.isEmpty) {
      return const Error<void, Failure>(
        ValidationFailure('TTS text cannot be empty'),
      );
    }

    final synth = _synthOrNull;
    if (synth == null) {
      return const Error<void, Failure>(
        AudioFailure('Web Speech API недоступен в этом браузере'),
      );
    }

    final token = ++_requestToken;
    try {
      if (_activeUtterance != null || synth.speaking || synth.pending) {
        _activeUtterance = null;
        synth.cancel();
        await Future<void>.delayed(const Duration(milliseconds: 60));
      }
      if (_isDisposed || token != _requestToken) {
        return const Success<void, Failure>(null);
      }

      final hebrewVoice = await _resolveHebrewVoice(synth);
      if (_isDisposed || token != _requestToken) {
        return const Success<void, Failure>(null);
      }

      final wordCount = cleaned.split(' ').length;
      final baseRate = wordCount <= 2 ? 0.86 : 0.94;
      final utterance = _WebSpeechUtterance(cleaned)
        ..lang = hebrewVoice?.lang ?? languageTag
        ..rate = (baseRate * _speedMultiplier).clamp(0.6, 1.4)
        ..pitch = 1.0
        ..volume = 1.0;
      if (hebrewVoice != null) {
        utterance.voice = hebrewVoice;
      }

      _activeToken = token;
      _activeUtterance = utterance;

      utterance.onEnd = (JSAny _) {
        if (_isDisposed || _activeToken != token) {
          return;
        }
        _activeUtterance = null;
        _onComplete?.call();
      }.toJS;

      utterance.onError = (_WebSpeechErrorEvent event) {
        if (_isDisposed || _activeToken != token) {
          return;
        }
        _activeUtterance = null;
        final code = (event.error ?? '').toLowerCase();
        if (code == 'canceled' || code == 'interrupted') {
          return;
        }
        final message = code.isEmpty
            ? 'Web Speech synthesis failed'
            : 'Web Speech error: $code';
        _logger.warning(_tag, message);
        _onError?.call(message);
      }.toJS;

      if (synth.paused) {
        synth.resume();
      }
      synth.speak(utterance);
      return const Success<void, Failure>(null);
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Web Speech TTS failed to speak Hebrew text',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
      return const Error<void, Failure>(
        AudioFailure('System Hebrew TTS is unavailable in this browser'),
      );
    }
  }

  Future<_WebSpeechSynthesisVoice?> _resolveHebrewVoice(
    _WebSpeechSynthesis synth,
  ) async {
    final initial = _pickBestHebrewVoice(synth.getVoices().toDart);
    if (initial != null) {
      return initial;
    }

    final completer = Completer<void>();
    late final JSFunction listener;
    listener = (JSAny _) {
      if (!completer.isCompleted) {
        completer.complete();
      }
    }.toJS;

    synth.addEventListener('voiceschanged', listener);
    final timer = Timer(const Duration(milliseconds: 350), () {
      if (!completer.isCompleted) {
        completer.complete();
      }
    });

    await completer.future;
    timer.cancel();
    synth.removeEventListener('voiceschanged', listener);

    return _pickBestHebrewVoice(synth.getVoices().toDart);
  }

  _WebSpeechSynthesisVoice? _pickBestHebrewVoice(
    List<_WebSpeechSynthesisVoice> voices,
  ) {
    _WebSpeechSynthesisVoice? best;
    var bestScore = -1;
    for (final voice in voices) {
      final normLang = voice.lang.trim().toLowerCase().replaceAll('_', '-');
      final isHebrew = normLang == 'he' ||
          normLang.startsWith('he-') ||
          normLang == 'iw' ||
          normLang.startsWith('iw-');
      if (!isHebrew) {
        continue;
      }
      var score = 0;
      if (normLang == 'he-il' || normLang == 'iw-il') {
        score += 100;
      }
      final lowerName = voice.name.toLowerCase();
      if (lowerName.contains('neural') ||
          lowerName.contains('natural') ||
          lowerName.contains('online')) {
        score += 60;
      } else if (lowerName.contains('google') ||
          lowerName.contains('enhanced') ||
          lowerName.contains('premium') ||
          lowerName.contains('siri')) {
        score += 40;
      }
      if (voice.isLocalService) {
        score += 10;
      }
      if (score > bestScore) {
        bestScore = score;
        best = voice;
      }
    }
    return best;
  }

  @override
  Future<Result<void, Failure>> stop() async {
    _requestToken++;
    _activeToken = _requestToken;
    _activeUtterance = null;
    if (_isDisposed) {
      return const Success<void, Failure>(null);
    }
    final synth = _synthOrNull;
    if (synth == null) {
      return const Success<void, Failure>(null);
    }
    try {
      if (synth.speaking || synth.pending) {
        synth.cancel();
      }
      return const Success<void, Failure>(null);
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Failed to stop Web Speech TTS',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
      return const Error<void, Failure>(
        AudioFailure('Unable to stop system TTS'),
      );
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
