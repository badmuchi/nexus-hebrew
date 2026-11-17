import 'dart:async';

import '../error/failures.dart';
import '../logging/app_logger.dart';
import '../result/result.dart';
import 'speech_recognition_service.dart';

SpeechRecognitionService buildPlatformSpeechRecognitionService({
  required AppLogger logger,
}) {
  return IoSpeechRecognitionService(logger: logger);
}

final class IoSpeechRecognitionService implements SpeechRecognitionService {
  final AppLogger _logger;
  final StreamController<String> _textController = StreamController<String>.broadcast();
  bool _isListening = false;

  IoSpeechRecognitionService({required AppLogger logger}) : _logger = logger;

  @override
  bool get isSupported => false;

  @override
  bool get isListening => _isListening;

  @override
  Stream<String> get textStream => _textController.stream;

  @override
  Future<Result<bool, Failure>> initialize({String language = 'he-IL'}) async {
    _logger.info('IoSpeechRecognitionService', 'Initialized fallback speech service for IO');
    return const Success(false);
  }

  @override
  Future<Result<void, Failure>> startListening() async {
    _isListening = true;
    _logger.info('IoSpeechRecognitionService', 'Started fallback listening');
    return const Success(null);
  }

  @override
  Future<Result<void, Failure>> stopListening() async {
    _isListening = false;
    _logger.info('IoSpeechRecognitionService', 'Stopped fallback listening');
    return const Success(null);
  }

  @override
  Future<void> dispose() async {
    _isListening = false;
    await _textController.close();
  }
}
