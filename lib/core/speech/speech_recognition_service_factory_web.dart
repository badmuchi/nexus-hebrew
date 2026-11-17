import '../logging/app_logger.dart';
import 'speech_recognition_service.dart';
import 'speech_recognition_service_web.dart';

SpeechRecognitionService buildPlatformSpeechRecognitionService({
  required AppLogger logger,
}) {
  return WebSpeechRecognitionService(logger: logger);
}
