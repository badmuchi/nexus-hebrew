import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../logging/app_logger.dart';

abstract interface class AppSettingsStorage {
  Future<double> readPlaybackSpeed();
  Future<void> writePlaybackSpeed(double speed);
  Future<ThemeMode> readThemeMode();
  Future<void> writeThemeMode(ThemeMode mode);
  Future<DateTime?> readLastDailyWorkoutDate();
  Future<void> writeLastDailyWorkoutDate(DateTime date);
  Future<String?> readAssessedLevel();
  Future<void> writeAssessedLevel(String level);
  Future<DateTime?> readLastAssessmentDate();
  Future<void> writeLastAssessmentDate(DateTime date);
  Future<int> readOfflineCachedAudioCount();
  Future<void> writeOfflineCachedAudioCount(int count);
  Future<DateTime?> readLastAudioPreloadDate();
  Future<void> writeLastAudioPreloadDate(DateTime date);
}

final class SecureAppSettingsStorage implements AppSettingsStorage {
  static const String _tag = 'SecureAppSettingsStorage';
  static const String _speedKey = 'nexus_hebrew_audio_speed';
  static const String _themeKey = 'nexus_hebrew_theme_mode';
  static const String _dailyWorkoutKey = 'nexus_hebrew_daily_workout_date';
  static const String _assessedLevelKey = 'nexus_hebrew_assessed_level';
  static const String _lastAssessmentDateKey = 'nexus_hebrew_last_assessment_date';
  static const String _cachedAudioCountKey = 'nexus_hebrew_cached_audio_count';
  static const String _lastAudioPreloadKey = 'nexus_hebrew_last_audio_preload_date';
  static const double _defaultSpeed = 1.0;

  final FlutterSecureStorage _storage;
  final AppLogger _logger;

  const SecureAppSettingsStorage({
    required FlutterSecureStorage storage,
    required AppLogger logger,
  })  : _storage = storage,
        _logger = logger;

  factory SecureAppSettingsStorage.withDefaultOptions({
    required AppLogger logger,
  }) {
    const storage = FlutterSecureStorage(
      aOptions: AndroidOptions(resetOnError: true),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
      ),
    );
    return SecureAppSettingsStorage(storage: storage, logger: logger);
  }

  @override
  Future<double> readPlaybackSpeed() async {
    try {
      final raw = await _storage.read(key: _speedKey);
      if (raw == null || raw.trim().isEmpty) {
        return _defaultSpeed;
      }
      final parsed = double.tryParse(raw.trim());
      if (parsed == null || parsed <= 0.0 || parsed > 2.5) {
        return _defaultSpeed;
      }
      return parsed;
    } on Object catch (error) {
      _logger.warning(
        _tag,
        'Failed to read audio playback speed from storage; fallback to default $_defaultSpeed ($error)',
      );
      return _defaultSpeed;
    }
  }

  @override
  Future<void> writePlaybackSpeed(double speed) async {
    if (speed <= 0.0 || speed > 2.5) {
      return;
    }
    try {
      await _storage.write(key: _speedKey, value: speed.toString());
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Failed to persist audio playback speed "$speed" to storage',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<ThemeMode> readThemeMode() async {
    try {
      final raw = await _storage.read(key: _themeKey);
      if (raw == null) return ThemeMode.system;
      return switch (raw.trim()) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
    } on Object catch (error) {
      _logger.warning(
        _tag,
        'Failed to read theme mode from storage; fallback to system ($error)',
      );
      return ThemeMode.system;
    }
  }

  @override
  Future<void> writeThemeMode(ThemeMode mode) async {
    try {
      final value = switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };
      await _storage.write(key: _themeKey, value: value);
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Failed to persist theme mode "$mode" to storage',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<DateTime?> readLastDailyWorkoutDate() async {
    try {
      final raw = await _storage.read(key: _dailyWorkoutKey);
      if (raw == null || raw.trim().isEmpty) return null;
      return DateTime.tryParse(raw.trim());
    } on Object catch (error) {
      _logger.warning(
        _tag,
        'Failed to read daily workout date from storage ($error)',
      );
      return null;
    }
  }

  @override
  Future<void> writeLastDailyWorkoutDate(DateTime date) async {
    try {
      await _storage.write(
        key: _dailyWorkoutKey,
        value: date.toUtc().toIso8601String(),
      );
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Failed to persist daily workout date "$date" to storage',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<String?> readAssessedLevel() async {
    try {
      final raw = await _storage.read(key: _assessedLevelKey);
      if (raw == null || raw.trim().isEmpty) return null;
      return raw.trim();
    } on Object catch (error) {
      _logger.warning(
        _tag,
        'Failed to read assessed CEFR level from storage ($error)',
      );
      return null;
    }
  }

  @override
  Future<void> writeAssessedLevel(String level) async {
    try {
      await _storage.write(key: _assessedLevelKey, value: level.trim());
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Failed to persist assessed CEFR level "$level" to storage',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<DateTime?> readLastAssessmentDate() async {
    try {
      final raw = await _storage.read(key: _lastAssessmentDateKey);
      if (raw == null || raw.trim().isEmpty) return null;
      return DateTime.tryParse(raw.trim());
    } on Object catch (error) {
      _logger.warning(
        _tag,
        'Failed to read last assessment date from storage ($error)',
      );
      return null;
    }
  }

  @override
  Future<void> writeLastAssessmentDate(DateTime date) async {
    try {
      await _storage.write(
        key: _lastAssessmentDateKey,
        value: date.toUtc().toIso8601String(),
      );
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Failed to persist last assessment date "$date" to storage',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<int> readOfflineCachedAudioCount() async {
    try {
      final raw = await _storage.read(key: _cachedAudioCountKey);
      if (raw == null || raw.trim().isEmpty) return 0;
      return int.tryParse(raw.trim()) ?? 0;
    } on Object catch (error) {
      _logger.warning(
        _tag,
        'Failed to read cached audio count from storage ($error)',
      );
      return 0;
    }
  }

  @override
  Future<void> writeOfflineCachedAudioCount(int count) async {
    try {
      await _storage.write(
        key: _cachedAudioCountKey,
        value: count.toString(),
      );
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Failed to persist cached audio count "$count" to storage',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<DateTime?> readLastAudioPreloadDate() async {
    try {
      final raw = await _storage.read(key: _lastAudioPreloadKey);
      if (raw == null || raw.trim().isEmpty) return null;
      return DateTime.tryParse(raw.trim());
    } on Object catch (error) {
      _logger.warning(
        _tag,
        'Failed to read last audio preload date from storage ($error)',
      );
      return null;
    }
  }

  @override
  Future<void> writeLastAudioPreloadDate(DateTime date) async {
    try {
      await _storage.write(
        key: _lastAudioPreloadKey,
        value: date.toUtc().toIso8601String(),
      );
    } on Object catch (error, stackTrace) {
      _logger.error(
        _tag,
        'Failed to persist last audio preload date "$date" to storage',
        errorDetails: error.toString(),
        stackTrace: stackTrace,
      );
    }
  }
}
