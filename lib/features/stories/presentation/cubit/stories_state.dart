import 'package:equatable/equatable.dart';

import '../../domain/entities/story.dart';

sealed class StoriesState extends Equatable {
  const StoriesState();

  @override
  List<Object?> get props => [];
}

final class StoriesInitial extends StoriesState {
  const StoriesInitial();
}

final class StoriesLoading extends StoriesState {
  const StoriesLoading();
}

final class StoriesError extends StoriesState {
  final String message;

  const StoriesError(this.message);

  @override
  List<Object?> get props => [message];
}

final class StoriesLoaded extends StoriesState {
  final List<Story> allStories;
  final Set<String> completedStoryIds;
  final String activeLevelFilter;
  final bool showNikkud;
  final bool showTranslation;
  final double fontSizeDelta;
  final String? playingSentenceId;
  final bool isPlayingStory;
  final Set<String> srsNormalizedForms;
  final String? transientNotice;
  final double playbackSpeed;

  const StoriesLoaded({
    required this.allStories,
    required this.completedStoryIds,
    this.activeLevelFilter = 'all',
    this.showNikkud = true,
    this.showTranslation = true,
    this.fontSizeDelta = 0.0,
    this.playingSentenceId,
    this.isPlayingStory = false,
    this.srsNormalizedForms = const <String>{},
    this.transientNotice,
    this.playbackSpeed = 1.0,
  });

  List<Story> get visibleStories {
    if (activeLevelFilter == 'all') {
      return allStories;
    }
    return allStories
        .where((s) => s.level.toLowerCase() == activeLevelFilter.toLowerCase())
        .toList();
  }

  StoriesLoaded copyWith({
    List<Story>? allStories,
    Set<String>? completedStoryIds,
    String? activeLevelFilter,
    bool? showNikkud,
    bool? showTranslation,
    double? fontSizeDelta,
    String? playingSentenceId,
    bool clearPlayingSentence = false,
    bool? isPlayingStory,
    Set<String>? srsNormalizedForms,
    String? transientNotice,
    bool clearTransientNotice = false,
    double? playbackSpeed,
  }) {
    return StoriesLoaded(
      allStories: allStories ?? this.allStories,
      completedStoryIds: completedStoryIds ?? this.completedStoryIds,
      activeLevelFilter: activeLevelFilter ?? this.activeLevelFilter,
      showNikkud: showNikkud ?? this.showNikkud,
      showTranslation: showTranslation ?? this.showTranslation,
      fontSizeDelta: fontSizeDelta ?? this.fontSizeDelta,
      playingSentenceId: clearPlayingSentence
          ? null
          : (playingSentenceId ?? this.playingSentenceId),
      isPlayingStory: isPlayingStory ?? this.isPlayingStory,
      srsNormalizedForms: srsNormalizedForms ?? this.srsNormalizedForms,
      transientNotice: clearTransientNotice
          ? null
          : (transientNotice ?? this.transientNotice),
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
    );
  }

  @override
  List<Object?> get props => [
        allStories,
        completedStoryIds,
        activeLevelFilter,
        showNikkud,
        showTranslation,
        fontSizeDelta,
        playingSentenceId,
        isPlayingStory,
        srsNormalizedForms,
        transientNotice,
        playbackSpeed,
      ];
}
