import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/logging/app_logger.dart';
import 'package:nexus_hebrew_app/core/settings/app_settings_storage.dart';

class _MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockFlutterSecureStorage storage;
  late SecureAppSettingsStorage settingsStorage;

  setUp(() {
    storage = _MockFlutterSecureStorage();
    settingsStorage = SecureAppSettingsStorage(
      storage: storage,
      logger: const DeveloperAppLogger(),
    );
  });

  group('SecureAppSettingsStorage', () {
    test('readPlaybackSpeed returns default 1.0 when nothing stored', () async {
      when(() => storage.read(key: any(named: 'key')))
          .thenAnswer((_) async => null);

      final speed = await settingsStorage.readPlaybackSpeed();
      expect(speed, equals(1.0));
    });

    test('readPlaybackSpeed parses stored valid double', () async {
      when(() => storage.read(key: any(named: 'key')))
          .thenAnswer((_) async => '0.85');

      final speed = await settingsStorage.readPlaybackSpeed();
      expect(speed, equals(0.85));
    });

    test('readPlaybackSpeed returns 1.0 on invalid or out-of-range value', () async {
      when(() => storage.read(key: any(named: 'key')))
          .thenAnswer((_) async => 'invalid_number');

      expect(await settingsStorage.readPlaybackSpeed(), equals(1.0));

      when(() => storage.read(key: any(named: 'key')))
          .thenAnswer((_) async => '99.0');

      expect(await settingsStorage.readPlaybackSpeed(), equals(1.0));
    });

    test('writePlaybackSpeed persists valid speed', () async {
      when(() => storage.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async {});

      await settingsStorage.writePlaybackSpeed(0.75);

      verify(
        () => storage.write(
          key: 'nexus_hebrew_audio_speed',
          value: '0.75',
        ),
      ).called(1);
    });

    test('writePlaybackSpeed ignores invalid or out-of-range speed', () async {
      await settingsStorage.writePlaybackSpeed(-1.0);
      await settingsStorage.writePlaybackSpeed(5.0);

      verifyNever(
        () => storage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      );
    });

    test('readLastDailyWorkoutDate and writeLastDailyWorkoutDate roundtrip', () async {
      when(() => storage.read(key: 'nexus_hebrew_daily_workout_date'))
          .thenAnswer((_) async => null);

      expect(await settingsStorage.readLastDailyWorkoutDate(), isNull);

      when(() => storage.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async {});

      final date = DateTime.utc(2026, 11, 16, 10, 0);
      await settingsStorage.writeLastDailyWorkoutDate(date);

      verify(
        () => storage.write(
          key: 'nexus_hebrew_daily_workout_date',
          value: date.toIso8601String(),
        ),
      ).called(1);

      when(() => storage.read(key: 'nexus_hebrew_daily_workout_date'))
          .thenAnswer((_) async => date.toIso8601String());

      final readDate = await settingsStorage.readLastDailyWorkoutDate();
      expect(readDate, equals(date));
    });

    test('readAssessedLevel and writeAssessedLevel roundtrip', () async {
      when(() => storage.read(key: 'nexus_hebrew_assessed_level'))
          .thenAnswer((_) async => null);

      expect(await settingsStorage.readAssessedLevel(), isNull);

      when(() => storage.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async {});

      await settingsStorage.writeAssessedLevel('A2.1');

      verify(
        () => storage.write(
          key: 'nexus_hebrew_assessed_level',
          value: 'A2.1',
        ),
      ).called(1);

      when(() => storage.read(key: 'nexus_hebrew_assessed_level'))
          .thenAnswer((_) async => 'A2.1');

      final level = await settingsStorage.readAssessedLevel();
      expect(level, equals('A2.1'));
    });

    test('readLastAssessmentDate and writeLastAssessmentDate roundtrip', () async {
      when(() => storage.read(key: 'nexus_hebrew_last_assessment_date'))
          .thenAnswer((_) async => null);

      expect(await settingsStorage.readLastAssessmentDate(), isNull);

      when(() => storage.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async {});

      final date = DateTime.utc(2026, 11, 20, 15, 30);
      await settingsStorage.writeLastAssessmentDate(date);

      verify(
        () => storage.write(
          key: 'nexus_hebrew_last_assessment_date',
          value: date.toIso8601String(),
        ),
      ).called(1);

      when(() => storage.read(key: 'nexus_hebrew_last_assessment_date'))
          .thenAnswer((_) async => date.toIso8601String());

      final readDate = await settingsStorage.readLastAssessmentDate();
      expect(readDate, equals(date));
    });

    test('readOfflineCachedAudioCount and writeOfflineCachedAudioCount roundtrip', () async {
      when(() => storage.read(key: 'nexus_hebrew_cached_audio_count'))
          .thenAnswer((_) async => null);

      expect(await settingsStorage.readOfflineCachedAudioCount(), equals(0));

      when(() => storage.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async {});

      await settingsStorage.writeOfflineCachedAudioCount(72);

      verify(
        () => storage.write(
          key: 'nexus_hebrew_cached_audio_count',
          value: '72',
        ),
      ).called(1);

      when(() => storage.read(key: 'nexus_hebrew_cached_audio_count'))
          .thenAnswer((_) async => '72');

      final count = await settingsStorage.readOfflineCachedAudioCount();
      expect(count, equals(72));
    });

    test('readLastAudioPreloadDate and writeLastAudioPreloadDate roundtrip', () async {
      when(() => storage.read(key: 'nexus_hebrew_last_audio_preload_date'))
          .thenAnswer((_) async => null);

      expect(await settingsStorage.readLastAudioPreloadDate(), isNull);

      when(() => storage.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async {});

      final date = DateTime.utc(2026, 11, 21, 12, 0);
      await settingsStorage.writeLastAudioPreloadDate(date);

      verify(
        () => storage.write(
          key: 'nexus_hebrew_last_audio_preload_date',
          value: date.toIso8601String(),
        ),
      ).called(1);

      when(() => storage.read(key: 'nexus_hebrew_last_audio_preload_date'))
          .thenAnswer((_) async => date.toIso8601String());

      final readDate = await settingsStorage.readLastAudioPreloadDate();
      expect(readDate, equals(date));
    });

    test('readDailyGoalJson and writeDailyGoalJson roundtrip correctly', () async {
      when(() => storage.read(key: 'nexus_hebrew_daily_goal_state'))
          .thenAnswer((_) async => null);

      expect(await settingsStorage.readDailyGoalJson(), isNull);

      when(() => storage.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async {});

      const sampleJson = '{"dateKey":"2026-11-23","intensity":"regular","cardsReviewed":15}';
      await settingsStorage.writeDailyGoalJson(sampleJson);

      verify(
        () => storage.write(
          key: 'nexus_hebrew_daily_goal_state',
          value: sampleJson,
        ),
      ).called(1);

      when(() => storage.read(key: 'nexus_hebrew_daily_goal_state'))
          .thenAnswer((_) async => sampleJson);

      final readJson = await settingsStorage.readDailyGoalJson();
      expect(readJson, equals(sampleJson));
    });
  });
}
