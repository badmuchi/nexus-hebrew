import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/backup/database_backup_service.dart';
import 'package:nexus_hebrew_app/core/database/app_database.dart';
import 'package:nexus_hebrew_app/core/settings/app_settings_storage.dart';

class _MockAppDatabase extends Mock implements AppDatabase {}
class _MockAppSettingsStorage extends Mock implements AppSettingsStorage {}

void main() {
  late _MockAppDatabase database;
  late _MockAppSettingsStorage settingsStorage;
  const service = DatabaseBackupService();

  setUp(() {
    database = _MockAppDatabase();
    settingsStorage = _MockAppSettingsStorage();
  });

  group('DatabaseBackupService', () {
    test('exportBackup генерирует валидный JSON с версией и таблицами', () async {
      when(() => database.getAllSrsCards()).thenAnswer((_) async => []);
      when(() => database.getAllSrsReviewLogs()).thenAnswer((_) async => []);
      when(() => database.getAllGrammarPracticeLogs()).thenAnswer((_) async => []);
      when(() => database.getAllListeningAttemptLogs()).thenAnswer((_) async => []);
      when(() => database.getAllDictionaryEntries()).thenAnswer((_) async => []);

      when(() => settingsStorage.readThemeMode()).thenAnswer((_) async => ThemeMode.dark);
      when(() => settingsStorage.readPlaybackSpeed()).thenAnswer((_) async => 0.85);
      when(() => settingsStorage.readLastDailyWorkoutDate()).thenAnswer((_) async => null);

      final json = await service.exportBackup(
        database: database,
        settingsStorage: settingsStorage,
      );

      expect(json, contains('"version": 1'));
      expect(json, contains('"app": "NexusHebrew"'));
      expect(json, contains('"themeMode": "dark"'));
      expect(json, contains('"playbackSpeed": 0.85'));
    });

    test('restoreBackup возвращает ошибку при невалидном JSON', () async {
      final res = await service.restoreBackup(
        jsonString: 'invalid json',
        database: database,
        settingsStorage: settingsStorage,
      );

      expect(res.isError, isTrue);
      expect(res.failureOrNull()?.message, contains('Ошибка при чтении бэкапа'));
    });
  });
}
