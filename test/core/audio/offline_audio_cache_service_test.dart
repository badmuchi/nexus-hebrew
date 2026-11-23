import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/audio/offline_audio_cache_service.dart';
import 'package:nexus_hebrew_app/core/logging/app_logger.dart';
import 'package:nexus_hebrew_app/core/settings/app_settings_storage.dart';

class _FakeAppSettingsStorage implements AppSettingsStorage {
  double speed = 1.0;
  ThemeMode themeMode = ThemeMode.system;
  DateTime? dailyWorkoutDate;
  String? assessedLevel;
  DateTime? assessmentDate;
  int cachedCount = 0;
  DateTime? preloadDate;
  String? sabraQuestsJson;
  int sabraStreakDays = 0;
  String? dailyGoalJson;

  @override
  Future<double> readPlaybackSpeed() async => speed;
  @override
  Future<void> writePlaybackSpeed(double value) async => speed = value;
  @override
  Future<ThemeMode> readThemeMode() async => themeMode;
  @override
  Future<void> writeThemeMode(ThemeMode mode) async => themeMode = mode;
  @override
  Future<DateTime?> readLastDailyWorkoutDate() async => dailyWorkoutDate;
  @override
  Future<void> writeLastDailyWorkoutDate(DateTime date) async => dailyWorkoutDate = date;
  @override
  Future<String?> readAssessedLevel() async => assessedLevel;
  @override
  Future<void> writeAssessedLevel(String level) async => assessedLevel = level;
  @override
  Future<DateTime?> readLastAssessmentDate() async => assessmentDate;
  @override
  Future<void> writeLastAssessmentDate(DateTime date) async => assessmentDate = date;
  @override
  Future<int> readOfflineCachedAudioCount() async => cachedCount;
  @override
  Future<void> writeOfflineCachedAudioCount(int count) async => cachedCount = count;
  @override
  Future<DateTime?> readLastAudioPreloadDate() async => preloadDate;
  @override
  Future<void> writeLastAudioPreloadDate(DateTime date) async => preloadDate = date;
  @override
  Future<String?> readSabraQuestsJson() async => sabraQuestsJson;
  @override
  Future<void> writeSabraQuestsJson(String json) async => sabraQuestsJson = json;
  @override
  Future<int> readSabraStreakDays() async => sabraStreakDays;
  @override
  Future<void> writeSabraStreakDays(int days) async => sabraStreakDays = days;
  @override
  Future<String?> readDailyGoalJson() async => dailyGoalJson;
  @override
  Future<void> writeDailyGoalJson(String json) async => dailyGoalJson = json;
}

class _MockDio extends Mock implements Dio {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeAppSettingsStorage settingsStorage;
  late _MockDio mockDio;
  late OfflineAudioCacheServiceImpl service;

  setUp(() {
    settingsStorage = _FakeAppSettingsStorage();
    mockDio = _MockDio();
    service = OfflineAudioCacheServiceImpl(
      settingsStorage: settingsStorage,
      dio: mockDio,
      logger: const DeveloperAppLogger(),
    );
  });

  group('OfflineAudioCacheService', () {
    test('getCachedAudioCount returns 0 initially and stored value when available', () async {
      expect(await service.getCachedAudioCount(), equals(0));

      await settingsStorage.writeOfflineCachedAudioCount(524);
      expect(await service.getCachedAudioCount(), equals(524));
    });

    test('getLastPreloadDate returns null initially and date when written', () async {
      expect(await service.getLastPreloadDate(), isNull);

      final now = DateTime.utc(2026, 11, 22, 12, 0);
      await settingsStorage.writeLastAudioPreloadDate(now);
      expect(await service.getLastPreloadDate(), equals(now));
    });

    test('isAudioCached identifies local assets and un-cached remote paths', () {
      expect(service.isAudioCached('assets/audio/srs/srs_shalom.mp3'), isTrue);
      expect(service.isAudioCached('assets/audio/listening/listen_beg_1.mp3'), isTrue);
      expect(service.isAudioCached('https://audio.tatoeba.org/sentences/heb/123.mp3'), isFalse);
      expect(service.isAudioCached(''), isFalse);
    });

    test('preloadAllEssentialAudio emits progress and persists count', () async {
      when(
        () => mockDio.get<List<int>>(
          'https://audio.tatoeba.org/sentences/heb/101.mp3',
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response<List<int>>(
          data: <int>[1, 2, 3, 4],
          statusCode: 200,
          requestOptions: RequestOptions(path: 'https://audio.tatoeba.org/sentences/heb/101.mp3'),
        ),
      );

      final events = await service
          .preloadAllEssentialAudio(
            additionalUrls: ['https://audio.tatoeba.org/sentences/heb/101.mp3'],
          )
          .toList();

      expect(events, isNotEmpty);
      final lastEvent = events.last;
      expect(lastEvent.isFinished, isTrue);
      expect(lastEvent.completed, greaterThanOrEqualTo(1));

      // Verifies storage was updated
      expect(await settingsStorage.readOfflineCachedAudioCount(), greaterThanOrEqualTo(1));
      expect(await settingsStorage.readLastAudioPreloadDate(), isNotNull);

      // Cached remote source should now be recognized
      expect(
        service.isAudioCached('https://audio.tatoeba.org/sentences/heb/101.mp3'),
        isTrue,
      );
    });

    test('clearCache resets downloaded cache and count in settings', () async {
      when(
        () => mockDio.get<List<int>>(
          'https://audio.tatoeba.org/sentences/heb/102.mp3',
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response<List<int>>(
          data: <int>[5, 6, 7],
          statusCode: 200,
          requestOptions: RequestOptions(path: 'https://audio.tatoeba.org/sentences/heb/102.mp3'),
        ),
      );

      await service
          .preloadAllEssentialAudio(
            additionalUrls: ['https://audio.tatoeba.org/sentences/heb/102.mp3'],
          )
          .toList();

      expect(
        service.isAudioCached('https://audio.tatoeba.org/sentences/heb/102.mp3'),
        isTrue,
      );

      await service.clearCache();
      expect(
        service.isAudioCached('https://audio.tatoeba.org/sentences/heb/102.mp3'),
        isFalse,
      );
    });
  });
}
