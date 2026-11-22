import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result/result.dart';
import '../../domain/entities/ai_chat_message.dart';
import '../../domain/entities/ai_roleplay_scenario.dart';
import '../../domain/repositories/ai_roleplay_repository.dart';
import 'ai_roleplay_state.dart';

class AiRoleplayCubit extends Cubit<AiRoleplayState> {
  final AiRoleplayRepository _repository;

  AiRoleplayCubit({
    required AiRoleplayRepository repository,
  })  : _repository = repository,
        super(const AiRoleplayInitial());

  Future<void> loadScenarios() async {
    final res = await _repository.getScenarios();
    if (res case Success(:final data)) {
      emit(AiRoleplayCatalogLoaded(data));
    }
  }

  void startScenario(AiRoleplayScenario scenario) {
    final initialMessage = AiChatMessage(
      id: 'greeting_${scenario.id}',
      isUser: false,
      hebrewText: scenario.character.initialGreetingHebrew,
      russianTranslation: scenario.character.initialGreetingRussian,
      transliteration: scenario.character.initialGreetingTranslit,
      timestamp: DateTime.now(),
    );

    emit(
      AiRoleplayChatActive(
        scenario: scenario,
        messages: [initialMessage],
      ),
    );
  }

  Future<void> sendUserMessage(String userHebrew) async {
    final currentState = state;
    if (currentState is! AiRoleplayChatActive) return;

    final trimmed = userHebrew.trim();
    if (trimmed.isEmpty) return;

    final userMessage = AiChatMessage.user(trimmed);

    final updatedMessages = List<AiChatMessage>.from(currentState.messages)
      ..add(userMessage);

    emit(currentState.copyWith(
      messages: updatedMessages,
      isAiTyping: true,
      errorMessage: null,
    ));

    final res = await _repository.sendMessage(
      scenario: currentState.scenario,
      conversationHistory: updatedMessages,
      userHebrewInput: trimmed,
    );

    if (res case Success(:final data)) {
      emit(currentState.copyWith(
        messages: List<AiChatMessage>.from(updatedMessages)..add(data),
        isAiTyping: false,
      ));
    } else if (res case Error(:final failure)) {
      emit(currentState.copyWith(
        isAiTyping: false,
        errorMessage: failure.message,
      ));
    }
  }

  Future<void> sendMessage(String text) => sendUserMessage(text);

  void resetChat() {
    final currentState = state;
    if (currentState is! AiRoleplayChatActive) return;
    startScenario(currentState.scenario);
  }

  void resetConversation() => resetChat();
}
