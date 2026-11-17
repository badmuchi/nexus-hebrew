import 'package:equatable/equatable.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../../core/error/failures.dart';
import '../../../grammar/domain/entities/verb_conjugation.dart';
import '../../../srs/domain/entities/srs_card.dart';
import '../../domain/entities/dictionary_entry.dart';

/// Base sealed UI state for the Hebrew-Russian Dictionary feature.
sealed class DictionaryState extends Equatable {
  const DictionaryState();

  @override
  List<Object?> get props => [];
}

final class DictionaryInitial extends DictionaryState {
  const DictionaryInitial();
}

final class DictionaryLoading extends DictionaryState {
  const DictionaryLoading();
}

final class DictionaryError extends DictionaryState {
  const DictionaryError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

final class DictionaryLoaded extends DictionaryState {
  DictionaryLoaded({
    required List<DictionaryEntry> allEntries,
    required List<DictionarySearchMatch> visibleMatches,
    required Set<String> srsNormalizedForms,
    List<VerbLexeme> verbParadigms = const <VerbLexeme>[],
    this.filter = const DictionaryFilter(),
    this.showNikkud = true,
    this.isSearchingOnline = false,
    this.lastOnlineQuery,
    this.lastOnlineResultsCount,
    this.audioStatus = AudioPlaybackStatus.idle,
    this.activeSpokenHebrew,
    this.activeAudioUrl,
    this.transientNotice,
  })  : allEntries = List<DictionaryEntry>.unmodifiable(allEntries),
        visibleMatches = List<DictionarySearchMatch>.unmodifiable(visibleMatches),
        srsNormalizedForms = Set<String>.unmodifiable(srsNormalizedForms),
        verbParadigms = List<VerbLexeme>.unmodifiable(verbParadigms);

  final List<DictionaryEntry> allEntries;
  final List<DictionarySearchMatch> visibleMatches;
  final Set<String> srsNormalizedForms;
  final List<VerbLexeme> verbParadigms;
  final DictionaryFilter filter;
  final bool showNikkud;
  final bool isSearchingOnline;
  final String? lastOnlineQuery;
  final int? lastOnlineResultsCount;
  final AudioPlaybackStatus audioStatus;
  final String? activeSpokenHebrew;
  final String? activeAudioUrl;
  final String? transientNotice;

  DictionaryLoaded copyWith({
    List<DictionaryEntry>? allEntries,
    List<DictionarySearchMatch>? visibleMatches,
    Set<String>? srsNormalizedForms,
    List<VerbLexeme>? verbParadigms,
    DictionaryFilter? filter,
    bool? showNikkud,
    bool? isSearchingOnline,
    String? lastOnlineQuery,
    int? lastOnlineResultsCount,
    bool clearOnlineMeta = false,
    AudioPlaybackStatus? audioStatus,
    String? activeSpokenHebrew,
    bool clearActiveSpokenHebrew = false,
    String? activeAudioUrl,
    bool clearActiveAudioUrl = false,
    String? transientNotice,
    bool clearTransientNotice = false,
  }) {
    return DictionaryLoaded(
      allEntries: allEntries ?? this.allEntries,
      visibleMatches: visibleMatches ?? this.visibleMatches,
      srsNormalizedForms: srsNormalizedForms ?? this.srsNormalizedForms,
      verbParadigms: verbParadigms ?? this.verbParadigms,
      filter: filter ?? this.filter,
      showNikkud: showNikkud ?? this.showNikkud,
      isSearchingOnline: isSearchingOnline ?? this.isSearchingOnline,
      lastOnlineQuery:
          clearOnlineMeta ? null : (lastOnlineQuery ?? this.lastOnlineQuery),
      lastOnlineResultsCount: clearOnlineMeta
          ? null
          : (lastOnlineResultsCount ?? this.lastOnlineResultsCount),
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

  /// Counts words per lexical category across all loaded dictionary entries.
  Map<LexicalCategory, int> get categoryCounts {
    final counts = <LexicalCategory, int>{};
    for (final entry in allEntries) {
      counts[entry.category] = (counts[entry.category] ?? 0) + 1;
    }
    return counts;
  }

  @override
  List<Object?> get props => [
        allEntries,
        visibleMatches,
        srsNormalizedForms,
        verbParadigms,
        filter,
        showNikkud,
        isSearchingOnline,
        lastOnlineQuery,
        lastOnlineResultsCount,
        audioStatus,
        activeSpokenHebrew,
        activeAudioUrl,
        transientNotice,
      ];
}
