import 'package:equatable/equatable.dart';

import 'binyan.dart';
import 'hebrew_text.dart';

final class SpeakerName extends Equatable {
  final HebrewText hebrew;
  final String? russian;

  const SpeakerName({
    required this.hebrew,
    this.russian,
  });

  @override
  List<Object?> get props => [hebrew, russian];
}

final class DialogueOption extends Equatable {
  final String id;
  final HebrewText textHebrew;
  final String textRussian;
  final Shoresh? root;
  final Binyan binyan;
  final String nextNodeId;

  const DialogueOption({
    required this.id,
    required this.textHebrew,
    required this.textRussian,
    required this.nextNodeId,
    this.root,
    this.binyan = Binyan.none,
  });

  @override
  List<Object?> get props => [
        id,
        textHebrew,
        textRussian,
        root,
        binyan,
        nextNodeId,
      ];
}

final class DialogueNode extends Equatable {
  final String id;
  final SpeakerName speaker;
  final HebrewText lineHebrew;
  final String lineRussian;
  final String? audioPath;
  final List<DialogueOption> options;

  DialogueNode({
    required this.id,
    required this.speaker,
    required this.lineHebrew,
    required this.lineRussian,
    required List<DialogueOption> options,
    this.audioPath,
  }) : options = List<DialogueOption>.unmodifiable(options);

  const DialogueNode.fixture({
    required this.id,
    required this.speaker,
    required this.lineHebrew,
    required this.lineRussian,
    required this.options,
    this.audioPath,
  });

  @override
  List<Object?> get props => [
        id,
        speaker,
        lineHebrew,
        lineRussian,
        audioPath,
        options,
      ];
}
