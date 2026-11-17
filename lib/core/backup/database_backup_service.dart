import 'dart:convert';

import 'package:flutter/material.dart';

import '../database/app_database.dart';
import '../error/failures.dart';
import '../result/result.dart';
import '../settings/app_settings_storage.dart';

/// Full database and progress backup service supporting JSON export and atomic restore.
final class DatabaseBackupService {
  const DatabaseBackupService();

  Future<String> exportBackup({
    required AppDatabase database,
    AppSettingsStorage? settingsStorage,
  }) async {
    final srsCards = await database.getAllSrsCards();
    final srsLogs = await database.getAllSrsReviewLogs();
    final grammarLogs = await database.getAllGrammarPracticeLogs();
    final listeningLogs = await database.getAllListeningAttemptLogs();
    final dictionaryEntries = await database.getAllDictionaryEntries();

    final themeMode = await settingsStorage?.readThemeMode();
    final speed = await settingsStorage?.readPlaybackSpeed();
    final workoutDate = await settingsStorage?.readLastDailyWorkoutDate();

    final backupMap = <String, dynamic>{
      'version': 1,
      'app': 'NexusHebrew',
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'settings': {
        'themeMode': themeMode?.name ?? 'system',
        'playbackSpeed': speed ?? 1.0,
        'lastDailyWorkoutDate': workoutDate?.toIso8601String(),
      },
      'srsCards': srsCards.map((c) => c.toJson()).toList(),
      'srsReviewLogs': srsLogs.map((l) => l.toJson()).toList(),
      'grammarPracticeLogs': grammarLogs.map((g) => g.toJson()).toList(),
      'listeningAttemptLogs': listeningLogs.map((l) => l.toJson()).toList(),
      'dictionaryEntries': dictionaryEntries.map((d) => d.toJson()).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(backupMap);
  }

  Future<Result<int, Failure>> restoreBackup({
    required String jsonString,
    required AppDatabase database,
    AppSettingsStorage? settingsStorage,
  }) async {
    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      final version = map['version'] as int?;
      if (version == null || version < 1) {
        return const Error(ValidationFailure('Неверный формат или версия бэкапа'));
      }

      var restoredCount = 0;

      await database.transaction(() async {
        // Restore cards
        if (map['srsCards'] is List) {
          for (final raw in map['srsCards'] as List) {
            final row = SrsCardRow.fromJson(raw as Map<String, dynamic>);
            await database.into(database.srsCards).insertOnConflictUpdate(row);
            restoredCount += 1;
          }
        }
        // Restore review logs
        if (map['srsReviewLogs'] is List) {
          for (final raw in map['srsReviewLogs'] as List) {
            final row = SrsReviewLogRow.fromJson(raw as Map<String, dynamic>);
            await database.into(database.srsReviewLogs).insertOnConflictUpdate(row);
            restoredCount += 1;
          }
        }
        // Restore grammar practice logs
        if (map['grammarPracticeLogs'] is List) {
          for (final raw in map['grammarPracticeLogs'] as List) {
            final row = GrammarPracticeLogRow.fromJson(raw as Map<String, dynamic>);
            await database.into(database.grammarPracticeLogs).insertOnConflictUpdate(row);
            restoredCount += 1;
          }
        }
        // Restore listening attempt logs
        if (map['listeningAttemptLogs'] is List) {
          for (final raw in map['listeningAttemptLogs'] as List) {
            final row = ListeningAttemptLogRow.fromJson(raw as Map<String, dynamic>);
            await database.into(database.listeningAttemptLogs).insertOnConflictUpdate(row);
            restoredCount += 1;
          }
        }
        // Restore dictionary entries
        if (map['dictionaryEntries'] is List) {
          for (final raw in map['dictionaryEntries'] as List) {
            final row = DictionaryEntryRow.fromJson(raw as Map<String, dynamic>);
            await database.into(database.dictionaryEntries).insertOnConflictUpdate(row);
            restoredCount += 1;
          }
        }
      });

      // Restore settings
      if (map['settings'] is Map<String, dynamic> && settingsStorage != null) {
        final settings = map['settings'] as Map<String, dynamic>;
        if (settings['playbackSpeed'] is num) {
          await settingsStorage
              .writePlaybackSpeed((settings['playbackSpeed'] as num).toDouble());
        }
        if (settings['themeMode'] is String) {
          final mode = switch (settings['themeMode']) {
            'light' => ThemeMode.light,
            'dark' => ThemeMode.dark,
            _ => ThemeMode.system,
          };
          await settingsStorage.writeThemeMode(mode);
        }
        if (settings['lastDailyWorkoutDate'] is String) {
          final dt =
              DateTime.tryParse(settings['lastDailyWorkoutDate'] as String);
          if (dt != null) {
            await settingsStorage.writeLastDailyWorkoutDate(dt);
          }
        }
      }

      return Success(restoredCount);
    } on Object catch (e) {
      return Error(ValidationFailure('Ошибка при чтении бэкапа: $e'));
    }
  }
}
