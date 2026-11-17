import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../../../core/settings/app_settings_storage.dart';

class CompleteDailyWorkoutUseCase {
  final AppSettingsStorage? _settingsStorage;

  const CompleteDailyWorkoutUseCase({
    AppSettingsStorage? settingsStorage,
  }) : _settingsStorage = settingsStorage;

  Future<Result<void, Failure>> call({DateTime? completedAt}) async {
    final date = completedAt?.toUtc() ?? DateTime.now().toUtc();
    await _settingsStorage?.writeLastDailyWorkoutDate(date);
    return const Success(null);
  }
}
