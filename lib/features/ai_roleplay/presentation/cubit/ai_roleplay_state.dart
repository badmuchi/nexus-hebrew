import 'package:equatable/equatable.dart';

import '../../domain/entities/ai_chat_message.dart';
import '../../domain/entities/ai_roleplay_scenario.dart';

sealed class AiRoleplayState extends Equatable {
  const AiRoleplayState();

  AiRoleplayScenario? get scenario => switch (this) {
        AiRoleplayChatActive(:final scenario) => scenario,
        _ => null,
      };

  List<AiChatMessage> get messages => switch (this) {
        AiRoleplayChatActive(:final messages) => messages,
        _ => const [],
      };

  bool get isAiTyping => switch (this) {
        AiRoleplayChatActive(:final isAiTyping) => isAiTyping,
        _ => false,
      };

  @override
  List<Object?> get props => [];
}

final class AiRoleplayInitial extends AiRoleplayState {
  const AiRoleplayInitial();
}

final class AiRoleplayCatalogLoaded extends AiRoleplayState {
  final List<AiRoleplayScenario> scenarios;

  const AiRoleplayCatalogLoaded(this.scenarios);

  @override
  List<Object?> get props => [scenarios];
}

final class AiRoleplayChatActive extends AiRoleplayState {
  @override
  final AiRoleplayScenario scenario;
  @override
  final List<AiChatMessage> messages;
  @override
  final bool isAiTyping;
  final String? errorMessage;

  const AiRoleplayChatActive({
    required this.scenario,
    required this.messages,
    this.isAiTyping = false,
    this.errorMessage,
  });

  AiRoleplayChatActive copyWith({
    AiRoleplayScenario? scenario,
    List<AiChatMessage>? messages,
    bool? isAiTyping,
    String? errorMessage,
  }) {
    return AiRoleplayChatActive(
      scenario: scenario ?? this.scenario,
      messages: messages ?? this.messages,
      isAiTyping: isAiTyping ?? this.isAiTyping,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [scenario, messages, isAiTyping, errorMessage];
}
