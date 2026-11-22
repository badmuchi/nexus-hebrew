import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/core/error/failures.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/ai_roleplay/data/datasources/ai_roleplay_seed_data.dart';
import 'package:nexus_hebrew_app/features/ai_roleplay/data/datasources/grammar_correction_engine.dart';
import 'package:nexus_hebrew_app/features/ai_roleplay/data/repositories/ai_roleplay_repository_impl.dart';
import 'package:nexus_hebrew_app/features/ai_roleplay/domain/entities/ai_chat_message.dart';
import 'package:nexus_hebrew_app/features/ai_roleplay/domain/entities/ai_roleplay_scenario.dart';

void main() {
  group('GrammarCorrectionEngine', () {
    const engine = GrammarCorrectionEngine();

    test('detects gender mismatch with קפה', () {
      final hint = engine.analyzeUserInput('אני רוצה קפה קרה');
      expect(hint, isNotNull);
      expect(hint, contains('Род существительного'));
      expect(hint, contains('קָפֶה קַר'));
    });

    test('detects plural and gender mismatch with מים', () {
      final hint = engine.analyzeUserInput('אפשר מים קרה?');
      expect(hint, isNotNull);
      expect(hint, contains('Число и род'));
      expect(hint, contains('מַיִם קָרִים'));
    });

    test('detects missing direct object marker את before definite noun', () {
      final hint = engine.analyzeUserInput('אני רוצה הקפה שלי');
      expect(hint, isNotNull);
      expect(hint, contains('Прямое дополнение (אֶת)'));
      expect(hint, contains('רוצה אֶת הקפה'));
    });

    test('detects preposition error with להתקשר', () {
      final hint = engine.analyzeUserInput('אני מתקשר עם המשכיר');
      expect(hint, isNotNull);
      expect(hint, contains('Управление глагола'));
      expect(hint, contains('לְ־'));
    });

    test('suggests polite phrase instead of abrupt תן לי', () {
      final hint = engine.analyzeUserInput('תן לי קפה');
      expect(hint, isNotNull);
      expect(hint, contains('Разговорный этикет'));
      expect(hint, contains('אֶפְשָׁר בְּבַקָּשָׁה'));
    });

    test('returns null when sentence has no detected mistakes', () {
      final hint = engine.analyzeUserInput('אֶפְשָׁר קָפֶה הָפוּךְ קָטָן, בְּבַקָּשָׁה?');
      expect(hint, isNull);
    });
  });

  group('AiRoleplayRepositoryImpl', () {
    final repo = AiRoleplayRepositoryImpl();
    final cafeScenario = AiRoleplaySeedData.scenarios.firstWhere((s) => s.id == 'scene_cafe');

    test('getScenarios returns all seed scenarios', () async {
      final res = await repo.getScenarios();
      expect(res, isA<Success<List<AiRoleplayScenario>, Failure>>());
      final list = (res as Success<List<AiRoleplayScenario>, Failure>).data;
      expect(list.length, greaterThanOrEqualTo(5));
    });

    test('getScenarioById finds scenario by ID', () async {
      final res = await repo.getScenarioById('scene_cafe');
      expect(res, isA<Success<AiRoleplayScenario, Failure>>());
      expect(
        (res as Success<AiRoleplayScenario, Failure>).data.id,
        equals('scene_cafe'),
      );
    });

    test('sendMessage returns validation failure on empty input', () async {
      final res = await repo.sendMessage(
        scenario: cafeScenario,
        conversationHistory: [],
        userHebrewInput: '   ',
      );
      expect(res, isA<Error<AiChatMessage, Failure>>());
    });

    test('sendMessage produces contextual Hebrew reply with translation and grammar feedback', () async {
      final res = await repo.sendMessage(
        scenario: cafeScenario,
        conversationHistory: [],
        userHebrewInput: 'תן לי קפה קרה',
      );

      expect(res, isA<Success<AiChatMessage, Failure>>());
      final msg = (res as Success<AiChatMessage, Failure>).data;
      expect(msg.isUser, isFalse);
      expect(msg.hebrewText, isNotEmpty);
      expect(msg.russianTranslation, isNotEmpty);
      expect(msg.transliteration, isNotEmpty);
      expect(msg.grammarCorrection, isNotNull);
      expect(msg.grammarCorrection, contains('Род существительного'));
    });
  });
}
