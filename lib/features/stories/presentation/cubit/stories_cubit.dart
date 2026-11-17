import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/result/result.dart';
import '../../../../core/settings/app_settings_storage.dart';
import '../../../dictionary/domain/repositories/dictionary_repository.dart';
import '../../domain/entities/story.dart';
import '../../domain/usecases/get_stories.dart';
import '../../domain/usecases/mark_story_completed.dart';
import 'stories_state.dart';

final class StoriesCubit extends Cubit<StoriesState> {
  static const String _tag = 'StoriesCubit';

  final GetStoriesUseCase _getStoriesUseCase;
  final MarkStoryCompletedUseCase _markCompletedUseCase;
  final DictionaryRepository _dictionaryRepository;
  final AudioPlaybackService _audioService;
  final AppSettingsStorage? _settingsStorage;
  final AppLogger _logger;

  StreamSubscription<AudioPlaybackEvent>? _audioSubscription;
  Timer? _singleSentenceSafetyTimer;
  bool _cancelFullStoryPlayback = false;

  StoriesCubit({
    required GetStoriesUseCase getStoriesUseCase,
    required MarkStoryCompletedUseCase markCompletedUseCase,
    required DictionaryRepository dictionaryRepository,
    required AudioPlaybackService audioService,
    AppSettingsStorage? settingsStorage,
    required AppLogger logger,
  })  : _getStoriesUseCase = getStoriesUseCase,
        _markCompletedUseCase = markCompletedUseCase,
        _dictionaryRepository = dictionaryRepository,
        _audioService = audioService,
        _settingsStorage = settingsStorage,
        _logger = logger,
        super(const StoriesInitial()) {
    _audioSubscription = _audioService.statusStream.listen(_handleAudioEvent);
  }

  void _handleAudioEvent(AudioPlaybackEvent event) {
    if (state is! StoriesLoaded) return;
    final current = state as StoriesLoaded;

    if (event.status == AudioPlaybackStatus.completed ||
        event.status == AudioPlaybackStatus.error ||
        event.status == AudioPlaybackStatus.idle) {
      _singleSentenceSafetyTimer?.cancel();
      if (!current.isPlayingStory && current.playingSentenceId != null) {
        emit(current.copyWith(clearPlayingSentence: true));
      }
    }
  }

  Future<void> loadStories() async {
    final current = state is StoriesLoaded ? state as StoriesLoaded : null;
    if (current == null) {
      emit(const StoriesLoading());
    }

    final storiesRes = await _getStoriesUseCase.execute();
    final completedRes =
        await _dictionaryRepository.getSrsNormalizedForms();

    switch (storiesRes) {
      case Success(:final data):
        final srsForms = completedRes.getOrNull() ??
            current?.srsNormalizedForms ??
            const <String>{};
        emit(
          StoriesLoaded(
            allStories: data,
            completedStoryIds: current?.completedStoryIds ?? const <String>{},
            activeLevelFilter: current?.activeLevelFilter ?? 'all',
            showNikkud: current?.showNikkud ?? true,
            showTranslation: current?.showTranslation ?? true,
            fontSizeDelta: current?.fontSizeDelta ?? 0.0,
            srsNormalizedForms: srsForms,
            playbackSpeed: current?.playbackSpeed ?? _audioService.currentSpeed,
          ),
        );
      case Error(:final failure):
        _logger.warning(_tag, 'Failed to load stories: ${failure.message}');
        if (current == null) {
          emit(StoriesError(failure.message));
        } else {
          emit(current.copyWith(transientNotice: failure.message));
        }
    }
  }

  void setLevelFilter(String level) {
    if (state is! StoriesLoaded) return;
    emit((state as StoriesLoaded).copyWith(activeLevelFilter: level));
  }

  void toggleNikkud() {
    if (state is! StoriesLoaded) return;
    final current = state as StoriesLoaded;
    emit(current.copyWith(showNikkud: !current.showNikkud));
  }

  void toggleTranslation() {
    if (state is! StoriesLoaded) return;
    final current = state as StoriesLoaded;
    emit(current.copyWith(showTranslation: !current.showTranslation));
  }

  void adjustFontSize(double delta) {
    if (state is! StoriesLoaded) return;
    final current = state as StoriesLoaded;
    final newDelta = (current.fontSizeDelta + delta).clamp(-4.0, 8.0);
    emit(current.copyWith(fontSizeDelta: newDelta));
  }

  Future<void> setPlaybackSpeed(double speed) async {
    if (state is! StoriesLoaded) return;
    final current = state as StoriesLoaded;
    final res = await _audioService.setPlaybackSpeed(speed);
    if (res.isSuccess) {
      unawaited(_settingsStorage?.writePlaybackSpeed(speed));
      emit(current.copyWith(playbackSpeed: speed));
    }
  }

  Future<void> playSentence(StorySentence sentence) async {
    if (state is! StoriesLoaded) return;
    final current = state as StoriesLoaded;

    _cancelFullStoryPlayback = true;
    _singleSentenceSafetyTimer?.cancel();
    await _audioService.stop();

    emit(
      current.copyWith(
        playingSentenceId: sentence.id,
        isPlayingStory: false,
      ),
    );

    final words =
        sentence.hebrewVocalized.trim().split(RegExp(r'\s+')).length;
    final speed = current.playbackSpeed.clamp(0.5, 2.0);
    final ms = ((3000 + words * 600) / speed).round();
    _singleSentenceSafetyTimer =
        Timer(Duration(milliseconds: ms), () {
      if (!isClosed && state is StoriesLoaded) {
        final loaded = state as StoriesLoaded;
        if (!loaded.isPlayingStory &&
            loaded.playingSentenceId == sentence.id) {
          emit(loaded.copyWith(clearPlayingSentence: true));
        }
      }
    });

    final playRes = await _audioService.playWithTtsFallback(
      sourcePath: sentence.audioUrl,
      fallbackHebrewText: sentence.hebrewVocalized,
    );

    if (playRes.isError && !isClosed && state is StoriesLoaded) {
      _singleSentenceSafetyTimer?.cancel();
      emit((state as StoriesLoaded).copyWith(clearPlayingSentence: true));
    }
  }

  Future<void> playFullStory(Story story) async {
    if (state is! StoriesLoaded) return;
    final current = state as StoriesLoaded;

    if (current.isPlayingStory) {
      await stopAudio();
      return;
    }

    _cancelFullStoryPlayback = false;
    _singleSentenceSafetyTimer?.cancel();
    emit(current.copyWith(isPlayingStory: true));

    final allSentences = <StorySentence>[];
    for (final p in story.paragraphs) {
      allSentences.addAll(p.sentences);
    }

    for (final sentence in allSentences) {
      if (_cancelFullStoryPlayback || isClosed) break;

      if (state is StoriesLoaded) {
        emit(
          (state as StoriesLoaded).copyWith(
            playingSentenceId: sentence.id,
            isPlayingStory: true,
          ),
        );
      }

      final waitCompleter = Completer<void>();
      StreamSubscription<AudioPlaybackEvent>? sub;
      Timer? safetyTimer;

      final words =
          sentence.hebrewVocalized.trim().split(RegExp(r'\s+')).length;
      final speed = (state is StoriesLoaded
              ? (state as StoriesLoaded).playbackSpeed
              : 1.0)
          .clamp(0.5, 2.0);
      final ms = ((3500 + words * 600) / speed).round();
      final maxDuration = Duration(milliseconds: ms);

      void finish() {
        if (!waitCompleter.isCompleted) {
          safetyTimer?.cancel();
          sub?.cancel();
          waitCompleter.complete();
        }
      }

      safetyTimer = Timer(maxDuration, finish);
      sub = _audioService.statusStream.listen((event) {
        if (_cancelFullStoryPlayback || isClosed) {
          finish();
          return;
        }
        if (event.status == AudioPlaybackStatus.completed ||
            event.status == AudioPlaybackStatus.error ||
            event.status == AudioPlaybackStatus.idle) {
          finish();
        }
      });

      final playRes = await _audioService.playWithTtsFallback(
        sourcePath: sentence.audioUrl,
        fallbackHebrewText: sentence.hebrewVocalized,
      );

      if (playRes.isError) {
        finish();
      } else {
        await waitCompleter.future;
      }
      finish();

      if (_cancelFullStoryPlayback || isClosed) break;

      // Small natural pause between sentences (cancellable)
      for (var i = 0; i < 5 && !_cancelFullStoryPlayback && !isClosed; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
    }

    if (!isClosed && state is StoriesLoaded) {
      emit(
        (state as StoriesLoaded).copyWith(
          clearPlayingSentence: true,
          isPlayingStory: false,
        ),
      );
    }
  }

  Future<void> stopAudio() async {
    _cancelFullStoryPlayback = true;
    _singleSentenceSafetyTimer?.cancel();
    await _audioService.stop();
    if (state is StoriesLoaded) {
      emit(
        (state as StoriesLoaded).copyWith(
          clearPlayingSentence: true,
          isPlayingStory: false,
        ),
      );
    }
  }

  Future<void> markCompleted(String storyId) async {
    final res = await _markCompletedUseCase.execute(storyId);
    if (res.isSuccess && state is StoriesLoaded) {
      final current = state as StoriesLoaded;
      final updated = Set<String>.from(current.completedStoryIds)..add(storyId);
      emit(
        current.copyWith(
          completedStoryIds: updated,
          transientNotice: 'Рассказ отмечен прочитанным! Молодец!',
        ),
      );
    }
  }

  Future<void> refreshSrsStatus() async {
    if (state is! StoriesLoaded) return;
    final current = state as StoriesLoaded;
    final srsRes = await _dictionaryRepository.getSrsNormalizedForms();
    if (srsRes case Success(:final data)) {
      emit(current.copyWith(srsNormalizedForms: data));
    }
  }

  void clearTransientNotice() {
    if (state is StoriesLoaded) {
      emit((state as StoriesLoaded).copyWith(clearTransientNotice: true));
    }
  }

  @override
  Future<void> close() {
    _cancelFullStoryPlayback = true;
    _singleSentenceSafetyTimer?.cancel();
    _audioSubscription?.cancel();
    return super.close();
  }
}
