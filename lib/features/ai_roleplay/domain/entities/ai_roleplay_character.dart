import 'package:equatable/equatable.dart';

/// Roleplay character (persona) representing a native speaker in a situational scenario.
final class AiRoleplayCharacter extends Equatable {
  final String id;
  final String nameHebrew;
  final String nameRussian;
  final String roleRussian;
  final String avatarEmoji;
  final String initialGreetingHebrew;
  final String initialGreetingRussian;
  final String initialGreetingTranslit;
  final String systemPrompt;

  const AiRoleplayCharacter({
    required this.id,
    required this.nameHebrew,
    required this.nameRussian,
    required this.roleRussian,
    required this.avatarEmoji,
    required this.initialGreetingHebrew,
    required this.initialGreetingRussian,
    required this.initialGreetingTranslit,
    required this.systemPrompt,
  });

  @override
  List<Object?> get props => [
        id,
        nameHebrew,
        nameRussian,
        roleRussian,
        avatarEmoji,
        initialGreetingHebrew,
        initialGreetingRussian,
        initialGreetingTranslit,
        systemPrompt,
      ];
}
