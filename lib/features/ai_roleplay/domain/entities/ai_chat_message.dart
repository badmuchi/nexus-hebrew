import 'package:equatable/equatable.dart';

/// Single message in an interactive roleplay dialogue.
final class AiChatMessage extends Equatable {
  final String id;
  final bool isUser;
  final String hebrewText;
  final String? russianTranslation;
  final String? transliteration;
  final String? grammarCorrection;
  final DateTime timestamp;

  const AiChatMessage({
    required this.id,
    required this.isUser,
    required this.hebrewText,
    this.russianTranslation,
    this.transliteration,
    this.grammarCorrection,
    required this.timestamp,
  });

  factory AiChatMessage.user(
    String hebrewText, {
    String? grammarCorrection,
    DateTime? timestamp,
  }) {
    return AiChatMessage(
      id: 'user_${DateTime.now().microsecondsSinceEpoch}',
      isUser: true,
      hebrewText: hebrewText,
      grammarCorrection: grammarCorrection,
      timestamp: timestamp ?? DateTime.now(),
    );
  }

  factory AiChatMessage.ai({
    required String hebrewText,
    String? russianTranslation,
    String? transliteration,
    String? grammarCorrection,
    DateTime? timestamp,
  }) {
    return AiChatMessage(
      id: 'ai_${DateTime.now().microsecondsSinceEpoch}',
      isUser: false,
      hebrewText: hebrewText,
      russianTranslation: russianTranslation,
      transliteration: transliteration,
      grammarCorrection: grammarCorrection,
      timestamp: timestamp ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        isUser,
        hebrewText,
        russianTranslation,
        transliteration,
        grammarCorrection,
        timestamp,
      ];
}
