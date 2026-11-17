import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/core/error/failures.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/conversation/data/models/dialogue_node_dto.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/binyan.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/dialogue_node.dart';

void main() {
  group('DialogueNodeDto', () {
    test('маппит валидный JSON с породами pual/hufal и корнями в Domain', () {
      const jsonPayload = '''
      {
        "id": "node_test",
        "speaker_hebrew": "מוֹכֵר",
        "speaker_russian": "Продавец",
        "line_hebrew": "שָׁלוֹם!",
        "line_russian": "Привет!",
        "audio_path": null,
        "options": [
          {
            "id": "opt_pual",
            "text_hebrew": "מְדֻבָּר",
            "text_russian": "Обсуждается",
            "next_node_id": "node_2",
            "binyan": "pual",
            "root": "ד-ב-ר"
          },
          {
            "id": "opt_hufal",
            "text_hebrew": "הֻזְמַן",
            "text_russian": "Был заказан",
            "next_node_id": "node_3",
            "binyan": "hufal",
            "root": "ז-מ-ן"
          }
        ]
      }
      ''';

      final dtoRes = DialogueNodeDto.fromJsonString(jsonPayload);
      expect(dtoRes, isA<Success<DialogueNodeDto, ParsingFailure>>());

      final domainRes = dtoRes.getOrNull()!.toDomain();
      expect(domainRes, isA<Success<DialogueNode, Failure>>());

      final node = domainRes.getOrNull()!;
      expect(node.speaker.hebrew.vocalized, equals('מוֹכֵר'));
      expect(node.speaker.russian, equals('Продавец'));
      expect(node.lineHebrew.normalized, equals('שלום!'));
      expect(node.options[0].binyan, equals(Binyan.pual));
      expect(node.options[0].root?.hyphenated, equals('ד-ב-ר'));
      expect(node.options[1].binyan, equals(Binyan.hufal));
    });

    test('поддерживает legacy поле character_name вида "מוֹכֵר (Продавец)"', () {
      const legacyJson = '''
      {
        "id": "node_legacy",
        "character_name": "מוֹכֵר (Продавец)",
        "line_hebrew": "שָׁלוֹם",
        "line_russian": "Привет",
        "options": []
      }
      ''';

      final node = DialogueNodeDto.fromJsonString(legacyJson)
          .getOrNull()!
          .toDomain()
          .getOrNull()!;

      expect(node.speaker.hebrew.vocalized, equals('מוֹכֵר'));
      expect(node.speaker.russian, equals('Продавец'));
    });

    test('возвращает ParsingFailure при неизвестном биньяне или невалидном корне', () {
      const invalidBinyanJson = '''
      {
        "id": "node_bad",
        "speaker_hebrew": "מוֹכֵר",
        "line_hebrew": "שָׁלוֹם",
        "line_russian": "Привет",
        "options": [
          {
            "id": "opt_bad",
            "text_hebrew": "שָׁלוֹם",
            "text_russian": "Привет",
            "next_node_id": "node_2",
            "binyan": "unknown_binyan",
            "root": "א-ב"
          }
        ]
      }
      ''';

      final dto = DialogueNodeDto.fromJsonString(invalidBinyanJson).getOrNull()!;
      final domainRes = dto.toDomain();

      expect(domainRes, isA<Error<DialogueNode, Failure>>());
      expect(domainRes.failureOrNull(), isA<ParsingFailure>());
    });
  });
}
