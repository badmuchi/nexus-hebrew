import '../logging/app_logger.dart';
import 'tts_speech_service.dart';

TtsSpeechService buildPlatformTtsSpeechService({
  required AppLogger logger,
  void Function()? onComplete,
  void Function(String message)? onError,
}) {
  return FlutterTtsSpeechService(
    logger: logger,
    onComplete: onComplete,
    onError: onError,
  );
}
