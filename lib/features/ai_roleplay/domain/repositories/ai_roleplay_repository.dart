import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../entities/ai_chat_message.dart';
import '../entities/ai_roleplay_scenario.dart';

abstract interface class AiRoleplayRepository {
  Future<Result<List<AiRoleplayScenario>, Failure>> getScenarios();

  Future<Result<AiRoleplayScenario, Failure>> getScenarioById(String scenarioId);

  Future<Result<AiChatMessage, Failure>> sendMessage({
    required AiRoleplayScenario scenario,
    required List<AiChatMessage> conversationHistory,
    required String userHebrewInput,
  });
}
