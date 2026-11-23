import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/army_tzahal/data/datasources/army_tzahal_seed_data.dart';
import 'package:nexus_hebrew_app/features/army_tzahal/domain/entities/army_term.dart';

void main() {
  group('Army & Tzahal Entities & Seed Data', () {
    test('Contains rich dictionary of military slang, abbreviations and civil service', () {
      const terms = ArmyTzahalSeedData.terms;
      expect(terms.length, greaterThanOrEqualTo(12));

      for (final t in terms) {
        expect(t.id, isNotEmpty);
        expect(t.hebrewWithNikkud, isNotEmpty);
        expect(t.hebrewNormalized, isNotEmpty);
        expect(t.transcriptionRu, isNotEmpty);
        expect(t.meaningRu, isNotEmpty);
        expect(t.culturalContextRu, isNotEmpty);
        expect(t.exampleHebrewWithNikkud, isNotEmpty);
        expect(t.exampleRu, isNotEmpty);
      }

      // Check Pakal
      final pakal = terms.firstWhere((t) => t.id == 'term_pakal');
      expect(pakal.abbreviationExpansionHebrew, contains('פְּקֻדּוֹת קֶבַע'));
      expect(pakal.category, ArmyCategory.slang);

      // Check Dapar
      final dapar = terms.firstWhere((t) => t.id == 'term_dapar');
      expect(dapar.abbreviationExpansionHebrew, contains('פְּסִיכוֹטֶכְנִי'));
      expect(dapar.category, ArmyCategory.tsavRishon);

      // Check Sherut Leumi
      final sherut = terms.firstWhere((t) => t.id == 'term_sherut_leumi');
      expect(sherut.category, ArmyCategory.sherutLeumi);
      expect(sherut.transcriptionRu, contains('Шерут Леуми'));
    });

    test('Tsav Rishon interview scenarios contain valid stages and tips', () {
      const scenarios = ArmyTzahalSeedData.interviewScenarios;
      expect(scenarios.length, greaterThanOrEqualTo(2));

      for (final s in scenarios) {
        expect(s.id, isNotEmpty);
        expect(s.stageTitleRu, isNotEmpty);
        expect(s.interviewerRoleRu, isNotEmpty);
        expect(s.interviewerSpeechHebrewWithNikkud, isNotEmpty);
        expect(s.optionsHebrew.length, 3);
        expect(s.optionsRu.length, 3);
        expect(s.bestOptionIndex, inInclusiveRange(0, 2));
        expect(s.explanationRu, isNotEmpty);
        expect(s.insiderTipRu, isNotEmpty);
      }
    });
  });
}
