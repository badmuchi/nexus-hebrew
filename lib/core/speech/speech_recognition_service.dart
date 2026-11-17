import 'dart:async';

import '../error/failures.dart';
import '../logging/app_logger.dart';
import '../result/result.dart';
import 'speech_recognition_service_factory_io.dart'
    if (dart.library.js_interop) 'speech_recognition_service_factory_web.dart'
    as platform_factory;

abstract interface class SpeechRecognitionService {
  bool get isSupported;
  bool get isListening;
  Stream<String> get textStream;

  Future<Result<bool, Failure>> initialize({String language = 'he-IL'});
  Future<Result<void, Failure>> startListening();
  Future<Result<void, Failure>> stopListening();
  Future<void> dispose();
}

SpeechRecognitionService createPlatformSpeechRecognitionService({
  required AppLogger logger,
}) {
  return platform_factory.buildPlatformSpeechRecognitionService(logger: logger);
}
