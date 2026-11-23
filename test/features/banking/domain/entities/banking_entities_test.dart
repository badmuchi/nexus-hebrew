import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/banking/data/datasources/banking_seed_data.dart';

void main() {
  group('Banking & Financial Entities & Seed Data', () {
    test('Contains 3 authentic Israeli check samples with correct legal fields', () {
      const checks = BankingSeedData.sampleChecks;
      expect(checks.length, 3);

      for (final c in checks) {
        expect(c.bankName, isNotEmpty);
        expect(c.branchNumber, isNotEmpty);
        expect(c.accountNumber, isNotEmpty);
        expect(c.checkNumber, isNotEmpty);
        expect(c.dateString, isNotEmpty);
        expect(c.payeeHebrewWithNikkud, isNotEmpty);
        expect(c.amountShekels, greaterThan(0));
        expect(c.amountInHebrewWordsWithNikkud, isNotEmpty);
        expect(c.hasCrossLines, isTrue);
        expect(c.isPayeeOnlyRestricted, isTrue);
      }

      // Rent check
      final rentCheck = checks.firstWhere((c) => c.id == 'check_1_rent');
      expect(rentCheck.amountShekels, 4500.0);
      expect(rentCheck.amountInHebrewWordsWithNikkud, contains('אַרְבַּעַת אֲלָפִים'));

      // Security deposit check
      final secCheck = checks.firstWhere((c) => c.id == 'check_2_security');
      expect(secCheck.dateString, contains('לְלֹא תַּאֲרִיךְ'));
    });

    test('Mortgage tracks cover KALATZ, Prime and 5-year variable tracks', () {
      const tracks = BankingSeedData.mortgageTracks;
      expect(tracks.length, 3);

      final kalatz = tracks.firstWhere((t) => t.id == 'track_kalatz');
      expect(kalatz.abbreviationHebrew, 'קַלַ״ץ');
      expect(kalatz.prosRu, contains('зафиксирован навсегда'));

      final prime = tracks.firstWhere((t) => t.id == 'track_prime');
      expect(prime.abbreviationHebrew, contains('פְּרַיְם'));
      expect(prime.prosRu, contains('без штрафа'));

      final variable = tracks.firstWhere((t) => t.id == 'track_variable_5');
      expect(variable.abbreviationHebrew, contains('מִשְׁתַּנָּה'));
    });

    test('Financial scenarios cover account opening, credit limits and social security', () {
      const scenarios = BankingSeedData.financialScenarios;
      expect(scenarios.length, 4);

      for (final s in scenarios) {
        expect(s.titleRu, isNotEmpty);
        expect(s.tellerSpeechHebrewWithNikkud, isNotEmpty);
        expect(s.clientResponseOptionsHebrew.length, 3);
        expect(s.bestOptionIndex, inInclusiveRange(0, 2));
        expect(s.explanationRu, isNotEmpty);
        expect(s.insiderFinancialTipRu, isNotEmpty);
      }
    });

    test('Banking glossary contains at least 16 essential financial terms', () {
      const glossary = BankingSeedData.bankingGlossary;
      expect(glossary.length, greaterThanOrEqualTo(16));

      for (final item in glossary) {
        expect(item['hebrew'], isNotEmpty);
        expect(item['transcription'], isNotEmpty);
        expect(item['translation'], isNotEmpty);
        expect(item['category'], isNotEmpty);
      }
    });
  });
}
