import 'package:equatable/equatable.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../../core/error/failures.dart';
import '../../../conversation/domain/entities/binyan.dart';
import '../../domain/entities/verb_conjugation.dart';

/// Base sealed UI state for the Grammar feature.
sealed class GrammarState extends Equatable {
  const GrammarState();

  @override
  List<Object?> get props => [];
}

/// Initial state before verb paradigms are loaded.
final class GrammarInitial extends GrammarState {
  const GrammarInitial();
}

/// Loading state while seeding or querying verb paradigms.
final class GrammarLoading extends GrammarState {
  const GrammarLoading();
}

/// Unrecoverable load failure state with typed [Failure].
final class GrammarError extends GrammarState {
  const GrammarError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

/// Active Grammar workspace containing filtered verbs, selected paradigm, and drill state.
final class GrammarLoaded extends GrammarState {
  GrammarLoaded({
    required List<VerbLexeme> verbs,
    required this.selectedVerb,
    this.selectedBinyan,
    this.searchQuery = '',
    this.selectedTense = VerbTense.present,
    this.showNikkud = true,
    this.drillPrompt,
    this.lastCheckResult,
    this.audioStatus = AudioPlaybackStatus.idle,
    this.activeSpokenHebrew,
    this.transientNotice,
  }) : verbs = List<VerbLexeme>.unmodifiable(verbs);

  final List<VerbLexeme> verbs;
  final VerbLexeme? selectedVerb;
  final Binyan? selectedBinyan;
  final String searchQuery;
  final VerbTense selectedTense;
  final bool showNikkud;
  final ConjugatedForm? drillPrompt;
  final ConjugationCheckResult? lastCheckResult;
  final AudioPlaybackStatus audioStatus;
  final String? activeSpokenHebrew;
  final String? transientNotice;

  /// Returns a copy preserving or clearing specified optional fields.
  GrammarLoaded copyWith({
    List<VerbLexeme>? verbs,
    VerbLexeme? selectedVerb,
    bool clearSelectedVerb = false,
    Binyan? selectedBinyan,
    bool clearSelectedBinyan = false,
    String? searchQuery,
    VerbTense? selectedTense,
    bool? showNikkud,
    ConjugatedForm? drillPrompt,
    bool clearDrillPrompt = false,
    ConjugationCheckResult? lastCheckResult,
    bool clearLastCheckResult = false,
    AudioPlaybackStatus? audioStatus,
    String? activeSpokenHebrew,
    bool clearActiveSpokenHebrew = false,
    String? transientNotice,
    bool clearTransientNotice = false,
  }) {
    return GrammarLoaded(
      verbs: verbs ?? this.verbs,
      selectedVerb:
          clearSelectedVerb ? null : (selectedVerb ?? this.selectedVerb),
      selectedBinyan:
          clearSelectedBinyan ? null : (selectedBinyan ?? this.selectedBinyan),
      searchQuery: searchQuery ?? this.searchQuery,
      selectedTense: selectedTense ?? this.selectedTense,
      showNikkud: showNikkud ?? this.showNikkud,
      drillPrompt: clearDrillPrompt ? null : (drillPrompt ?? this.drillPrompt),
      lastCheckResult: clearLastCheckResult
          ? null
          : (lastCheckResult ?? this.lastCheckResult),
      audioStatus: audioStatus ?? this.audioStatus,
      activeSpokenHebrew: clearActiveSpokenHebrew
          ? null
          : (activeSpokenHebrew ?? this.activeSpokenHebrew),
      transientNotice: clearTransientNotice
          ? null
          : (transientNotice ?? this.transientNotice),
    );
  }

  @override
  List<Object?> get props => [
        verbs,
        selectedVerb,
        selectedBinyan,
        searchQuery,
        selectedTense,
        showNikkud,
        drillPrompt,
        lastCheckResult,
        audioStatus,
        activeSpokenHebrew,
        transientNotice,
      ];
}
