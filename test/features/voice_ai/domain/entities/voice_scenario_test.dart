import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/voice_ai/data/datasources/voice_ai_seed_data.dart';

void main() {
  group('Voice Scenario Entities & Seed Data', () {
    test('Contains 4 realistic conversational scenarios with complete turns', () {
      const scenarios = VoiceAiSeedData.scenarios;
      expect(scenarios.length, 4);

      for (final sc in scenarios) {
        expect(sc.id, isNotEmpty);
        expect(sc.titleRu, isNotEmpty);
        expect(sc.titleHebrewWithNikkud, isNotEmpty);
        expect(sc.locationRu, isNotEmpty);
        expect(sc.iconEmoji, isNotEmpty);
        expect(sc.turns, isNotEmpty);

        for (final t in sc.turns) {
          expect(t.sabraSpeechHebrewWithNikkud, isNotEmpty);
          expect(t.sabraSpeechNormalized, isNotEmpty);
          expect(t.sabraSpeechRu, isNotEmpty);
          expect(t.suggestedAnswers, isNotEmpty);
          expect(t.culturalTipRu, isNotEmpty);
          expect(t.grammarHintRu, isNotEmpty);

          for (final a in t.suggestedAnswers) {
            expect(a.hebrewWithNikkud, isNotEmpty);
            expect(a.hebrewNormalized, isNotEmpty);
            expect(a.transcriptionRu, isNotEmpty);
            expect(a.translationRu, isNotEmpty);
            expect(a.expectedKeywords, isNotEmpty);
          }
        }
      }

      // Check Cafe Dizengoff
      final cafe = scenarios.firstWhere((s) => s.id == 'scenario_coffee_shop');
      expect(cafe.titleHebrewWithNikkud, contains('קָפֶה בְּדִיזֶנְגּוֹף'));
      expect(cafe.turns.length, 2);

      // Check Shuk Carmel
      final shuk = scenarios.firstWhere((s) => s.id == 'scenario_shuk_carmel');
      expect(shuk.iconEmoji, '🍉');
      expect(shuk.turns.first.sabraSpeechHebrewWithNikkud, contains('הַכֹּל דְּבַשׁ'));
    });
  });
}
