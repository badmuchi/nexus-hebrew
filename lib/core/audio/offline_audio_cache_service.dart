import 'dart:async';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';

import '../logging/app_logger.dart';
import '../settings/app_settings_storage.dart';

/// Progress state emitted during audio preloading.
final class AudioPreloadProgress extends Equatable {
  final int total;
  final int completed;
  final int failed;
  final String currentItem;
  final bool isFinished;

  const AudioPreloadProgress({
    required this.total,
    required this.completed,
    required this.failed,
    required this.currentItem,
    required this.isFinished,
  });

  const AudioPreloadProgress.idle()
      : total = 0,
        completed = 0,
        failed = 0,
        currentItem = '',
        isFinished = false;

  double get progressRatio =>
      total <= 0 ? 1.0 : (completed / total).clamp(0.0, 1.0);

  int get percent => (progressRatio * 100).round();

  @override
  List<Object?> get props => [total, completed, failed, currentItem, isFinished];
}

/// Service managing offline cached audio files and preloading.
abstract interface class OfflineAudioCacheService {
  Future<int> getCachedAudioCount();
  Future<DateTime?> getLastPreloadDate();
  bool isAudioCached(String sourcePath);
  Future<String> resolveAudioSource(String sourcePath);
  Stream<AudioPreloadProgress> preloadAllEssentialAudio({
    List<String>? additionalUrls,
  });
  Future<void> clearCache();
}

final class OfflineAudioCacheServiceImpl implements OfflineAudioCacheService {
  static const String _tag = 'OfflineAudioCacheService';

  final AppSettingsStorage _settingsStorage;
  final Dio? _dio;
  final AssetBundle _assetBundle;
  final AppLogger _logger;

  final Set<String> _cachedLocalAssets = <String>{};
  final Map<String, String> _cachedRemoteSources = <String, String>{};
  final Map<String, List<int>> _memoryAudioBytes = <String, List<int>>{};

  OfflineAudioCacheServiceImpl({
    required AppSettingsStorage settingsStorage,
    Dio? dio,
    AssetBundle? assetBundle,
    required AppLogger logger,
  })  : _settingsStorage = settingsStorage,
        _dio = dio,
        _assetBundle = assetBundle ?? rootBundle,
        _logger = logger;

  @override
  Future<int> getCachedAudioCount() async {
    final storedCount = await _settingsStorage.readOfflineCachedAudioCount();
    if (storedCount > 0) {
      return storedCount;
    }
    final inMemoryTotal =
        _cachedLocalAssets.length + _cachedRemoteSources.length;
    if (inMemoryTotal > 0) {
      return inMemoryTotal;
    }
    return 0;
  }

  @override
  Future<DateTime?> getLastPreloadDate() {
    return _settingsStorage.readLastAudioPreloadDate();
  }

  @override
  bool isAudioCached(String sourcePath) {
    final trimmed = sourcePath.trim();
    if (trimmed.isEmpty) return false;

    if (trimmed.startsWith('assets/')) {
      if (_cachedLocalAssets.contains(trimmed)) return true;
      if (trimmed.startsWith('assets/audio/')) return true;
    }

    if (_cachedRemoteSources.containsKey(trimmed)) return true;
    if (_memoryAudioBytes.containsKey(trimmed)) return true;

    return false;
  }

  @override
  Future<String> resolveAudioSource(String sourcePath) async {
    final trimmed = sourcePath.trim();
    if (trimmed.isEmpty) return sourcePath;

    if (_cachedRemoteSources.containsKey(trimmed)) {
      return _cachedRemoteSources[trimmed]!;
    }

    return trimmed;
  }

  @override
  Stream<AudioPreloadProgress> preloadAllEssentialAudio({
    List<String>? additionalUrls,
  }) async* {
    _logger.info(_tag, 'Starting essential audio preloading...');

    // 1. Discover and index local bundle audio assets
    final localAssets = await _discoverLocalAudioAssets();
    _cachedLocalAssets.addAll(localAssets);

    final remoteUrls = additionalUrls ?? <String>[];
    final totalItems = _cachedLocalAssets.length + remoteUrls.length;
    var completedCount = _cachedLocalAssets.length;
    var failedCount = 0;

    yield AudioPreloadProgress(
      total: totalItems,
      completed: completedCount,
      failed: failedCount,
      currentItem: 'Проверено ${_cachedLocalAssets.length} локальных аудиофайлов',
      isFinished: false,
    );

    // 2. Pre-fetch remote audio files if any and Dio is available
    if (remoteUrls.isNotEmpty && _dio != null) {
      for (final url in remoteUrls) {
        final trimmedUrl = url.trim();
        if (trimmedUrl.isEmpty) continue;

        if (_cachedRemoteSources.containsKey(trimmedUrl)) {
          completedCount++;
          yield AudioPreloadProgress(
            total: totalItems,
            completed: completedCount,
            failed: failedCount,
            currentItem: trimmedUrl,
            isFinished: false,
          );
          continue;
        }

        try {
          final response = await _dio.get<List<int>>(
            trimmedUrl,
            options: Options(
              responseType: ResponseType.bytes,
              receiveTimeout: const Duration(seconds: 8),
              sendTimeout: const Duration(seconds: 8),
            ),
          );

          if (response.statusCode == 200 && response.data != null) {
            _memoryAudioBytes[trimmedUrl] = response.data!;
            _cachedRemoteSources[trimmedUrl] = trimmedUrl;
            completedCount++;
          } else {
            failedCount++;
          }
        } on Object catch (error) {
          _logger.warning(_tag, 'Failed to preload remote audio: $trimmedUrl ($error)');
          failedCount++;
        }

        yield AudioPreloadProgress(
          total: totalItems,
          completed: completedCount,
          failed: failedCount,
          currentItem: trimmedUrl,
          isFinished: false,
        );
      }
    }

    // 3. Persist summary statistics to settings storage
    final finalCachedCount = _cachedLocalAssets.length + _cachedRemoteSources.length;
    await _settingsStorage.writeOfflineCachedAudioCount(finalCachedCount);
    await _settingsStorage.writeLastAudioPreloadDate(DateTime.now());

    _logger.info(
      _tag,
      'Preloading completed. Total cached audio: $finalCachedCount (failed: $failedCount)',
    );

    yield AudioPreloadProgress(
      total: totalItems,
      completed: completedCount,
      failed: failedCount,
      currentItem: 'Предзагрузка завершена',
      isFinished: true,
    );
  }

  @override
  Future<void> clearCache() async {
    _cachedRemoteSources.clear();
    _memoryAudioBytes.clear();
    await _settingsStorage.writeOfflineCachedAudioCount(_cachedLocalAssets.length);
    _logger.info(_tag, 'Remote audio cache cleared');
  }

  Future<Set<String>> _discoverLocalAudioAssets() async {
    final assets = <String>{};
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(_assetBundle);
      final list = manifest.listAssets();
      for (final asset in list) {
        if (asset.startsWith('assets/audio/')) {
          assets.add(asset);
        }
      }
    } on Object catch (error) {
      _logger.warning(_tag, 'Could not inspect AssetManifest, using default asset discovery ($error)');
    }
    return assets;
  }
}
