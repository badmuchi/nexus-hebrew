import 'package:equatable/equatable.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/dialogue_node.dart';

sealed class ConversationState extends Equatable {
  const ConversationState();

  @override
  List<Object?> get props => const [];
}

final class ConversationInitial extends ConversationState {
  const ConversationInitial();
}

final class ConversationLoading extends ConversationState {
  final String? nodeId;

  const ConversationLoading({this.nodeId});

  @override
  List<Object?> get props => [nodeId];
}

final class ConversationLoaded extends ConversationState {
  final DialogueNode activeNode;
  final bool showNikkud;
  final AudioPlaybackStatus audioStatus;
  final bool isTransitioning;
  final List<String> navigationHistory;
  final String? transientNotice;
  final double playbackSpeed;

  ConversationLoaded({
    required this.activeNode,
    this.showNikkud = true,
    this.audioStatus = AudioPlaybackStatus.idle,
    this.isTransitioning = false,
    List<String> navigationHistory = const [],
    this.transientNotice,
    this.playbackSpeed = 1.0,
  }) : navigationHistory = List<String>.unmodifiable(navigationHistory);

  bool get canGoBack => navigationHistory.isNotEmpty;

  ConversationLoaded copyWith({
    DialogueNode? activeNode,
    bool? showNikkud,
    AudioPlaybackStatus? audioStatus,
    bool? isTransitioning,
    List<String>? navigationHistory,
    String? transientNotice,
    bool clearTransientNotice = false,
    double? playbackSpeed,
  }) {
    return ConversationLoaded(
      activeNode: activeNode ?? this.activeNode,
      showNikkud: showNikkud ?? this.showNikkud,
      audioStatus: audioStatus ?? this.audioStatus,
      isTransitioning: isTransitioning ?? this.isTransitioning,
      navigationHistory: navigationHistory ?? this.navigationHistory,
      transientNotice: clearTransientNotice
          ? null
          : (transientNotice ?? this.transientNotice),
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
    );
  }

  @override
  List<Object?> get props => [
        activeNode,
        showNikkud,
        audioStatus,
        isTransitioning,
        navigationHistory,
        transientNotice,
        playbackSpeed,
      ];
}

final class ConversationError extends ConversationState {
  final Failure failure;
  final String? retryNodeId;

  const ConversationError({
    required this.failure,
    this.retryNodeId,
  });

  String get errorMessage => failure.message;

  @override
  List<Object?> get props => [failure, retryNodeId];
}
