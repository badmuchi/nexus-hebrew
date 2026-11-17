import 'package:equatable/equatable.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/learning_progress_summary.dart';

/// Base sealed UI state for the Progress & Global Search feature.
sealed class ProgressState extends Equatable {
  const ProgressState();

  @override
  List<Object?> get props => [];
}

/// Initial state before progress stats are loaded.
final class ProgressInitial extends ProgressState {
  const ProgressInitial();
}

/// Loading state while reading local statistics.
final class ProgressLoading extends ProgressState {
  const ProgressLoading();
}

/// Error state when local progress aggregation fails.
final class ProgressError extends ProgressState {
  const ProgressError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

/// Loaded progress dashboard state plus unified Hebrew/shoresh search results.
final class ProgressLoaded extends ProgressState {
  ProgressLoaded({
    required this.summary,
    this.searchQuery = '',
    List<GlobalHebrewSearchResult> searchResults =
        const <GlobalHebrewSearchResult>[],
    this.isSearching = false,
    this.audioStatus = AudioPlaybackStatus.idle,
    this.activeSpokenHebrew,
    this.activeAudioUrl,
    this.transientNotice,
  }) : searchResults =
            List<GlobalHebrewSearchResult>.unmodifiable(searchResults);

  final LearningProgressSummary summary;
  final String searchQuery;
  final List<GlobalHebrewSearchResult> searchResults;
  final bool isSearching;
  final AudioPlaybackStatus audioStatus;
  final String? activeSpokenHebrew;
  final String? activeAudioUrl;
  final String? transientNotice;

  /// Creates an updated immutable copy of [ProgressLoaded].
  ProgressLoaded copyWith({
    LearningProgressSummary? summary,
    String? searchQuery,
    List<GlobalHebrewSearchResult>? searchResults,
    bool? isSearching,
    AudioPlaybackStatus? audioStatus,
    String? activeSpokenHebrew,
    bool clearActiveSpokenHebrew = false,
    String? activeAudioUrl,
    bool clearActiveAudioUrl = false,
    String? transientNotice,
    bool clearTransientNotice = false,
  }) {
    return ProgressLoaded(
      summary: summary ?? this.summary,
      searchQuery: searchQuery ?? this.searchQuery,
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
      audioStatus: audioStatus ?? this.audioStatus,
      activeSpokenHebrew: clearActiveSpokenHebrew
          ? null
          : (activeSpokenHebrew ?? this.activeSpokenHebrew),
      activeAudioUrl:
          clearActiveAudioUrl ? null : (activeAudioUrl ?? this.activeAudioUrl),
      transientNotice: clearTransientNotice
          ? null
          : (transientNotice ?? this.transientNotice),
    );
  }

  @override
  List<Object?> get props => [
        summary,
        searchQuery,
        searchResults,
        isSearching,
        audioStatus,
        activeSpokenHebrew,
        activeAudioUrl,
        transientNotice,
      ];
}
