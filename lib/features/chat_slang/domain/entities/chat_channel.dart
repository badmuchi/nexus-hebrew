import 'package:equatable/equatable.dart';

/// Categories of authentic Israeli WhatsApp chat groups.
enum ChatChannelCategory {
  buildingCommittee(
    id: 'vaad_bayit',
    titleRu: 'Ваад байт (Домовой комитет)',
    hebrewTitle: 'וַעַד בַּיִת',
    iconEmoji: '🏢',
  ),
  highTechTeam(
    id: 'tech_team',
    titleRu: 'Хайтек-команда и стартап',
    hebrewTitle: 'צֶוֶת הַיְיטֶק',
    iconEmoji: '💻',
  ),
  weekendFriends(
    id: 'friends',
    titleRu: 'Друзья и планы на выходные',
    hebrewTitle: 'חֲבֵרִים בַּסּוֹפַ״שׁ',
    iconEmoji: '🍻',
  );

  final String id;
  final String titleRu;
  final String hebrewTitle;
  final String iconEmoji;

  const ChatChannelCategory({
    required this.id,
    required this.titleRu,
    required this.hebrewTitle,
    required this.iconEmoji,
  });
}

/// A message in an Israeli WhatsApp thread.
final class ChatMessage extends Equatable {
  final String id;
  final String senderName;
  final String senderRoleRu;
  final bool isMe;
  final String timeString;
  final String textHebrewWithNikkud;
  final String textPlain;
  final String transcriptionRu;
  final String translationRu;
  final Map<String, String> slangDictionary;
  final bool isVoiceMessage;
  final int? audioDurationSeconds;

  const ChatMessage({
    required this.id,
    required this.senderName,
    required this.senderRoleRu,
    required this.isMe,
    required this.timeString,
    required this.textHebrewWithNikkud,
    required this.textPlain,
    required this.transcriptionRu,
    required this.translationRu,
    this.slangDictionary = const {},
    this.isVoiceMessage = false,
    this.audioDurationSeconds,
  });

  @override
  List<Object?> get props => [
        id,
        senderName,
        senderRoleRu,
        isMe,
        timeString,
        textHebrewWithNikkud,
        textPlain,
        transcriptionRu,
        translationRu,
        slangDictionary,
        isVoiceMessage,
        audioDurationSeconds,
      ];
}

/// Interactive response challenge for the learner in the chat.
final class ChatReplyChallenge extends Equatable {
  final String id;
  final String contextRu;
  final List<String> optionsHebrewWithNikkud;
  final List<String> optionsTranslationRu;
  final int bestOptionIndex;
  final String feedbackRu;
  final String culturalEtiquetteRuleRu;

  const ChatReplyChallenge({
    required this.id,
    required this.contextRu,
    required this.optionsHebrewWithNikkud,
    required this.optionsTranslationRu,
    required this.bestOptionIndex,
    required this.feedbackRu,
    required this.culturalEtiquetteRuleRu,
  });

  @override
  List<Object?> get props => [
        id,
        contextRu,
        optionsHebrewWithNikkud,
        optionsTranslationRu,
        bestOptionIndex,
        feedbackRu,
        culturalEtiquetteRuleRu,
      ];
}

/// A complete WhatsApp chat thread with participants, messages, and a reply challenge.
final class ChatThread extends Equatable {
  final String id;
  final ChatChannelCategory category;
  final String groupNameRu;
  final String groupNameHebrew;
  final String participantsSummaryRu;
  final List<ChatMessage> messages;
  final ChatReplyChallenge challenge;

  const ChatThread({
    required this.id,
    required this.category,
    required this.groupNameRu,
    required this.groupNameHebrew,
    required this.participantsSummaryRu,
    required this.messages,
    required this.challenge,
  });

  @override
  List<Object?> get props => [
        id,
        category,
        groupNameRu,
        groupNameHebrew,
        participantsSummaryRu,
        messages,
        challenge,
      ];
}
