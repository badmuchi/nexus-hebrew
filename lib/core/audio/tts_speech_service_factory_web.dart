import '../logging/app_logger.dart';
import 'tts_speech_service.dart';
import 'tts_speech_service_web.dart';

TtsSpeechService buildPlatformTtsSpeechService({
  required AppLogger logger,
  void Function()? onComplete,
  void Function(String message)? onError,
}) {
  return WebTtsSpeechService(
    logger: logger,
    onComplete: onComplete,
    onError: onError,
  );
}
