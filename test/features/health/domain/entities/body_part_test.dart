import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/health/data/datasources/health_seed_data.dart';

void main() {
  group('BodyPart & HealthSeedData Entity Tests', () {
    test('verifies dual-form paired body parts are marked feminine', () {
      const parts = HealthSeedData.bodyParts;
      final dualParts = parts.where((p) => p.isDualForm).toList();

      expect(dualParts, isNotEmpty);
      for (final part in dualParts) {
        // Paired body parts in Hebrew are feminine (עיניים, אוזניים, ידיים, רגליים, שיניים, ברכיים)
        expect(part.isFeminine, isTrue,
            reason: '${part.russianName} (${part.hebrewPlain}) should be feminine');
      }
    });

    test('verifies stomach (בטן) is marked feminine despite singular form', () {
      final stomach = HealthSeedData.bodyParts.firstWhere((p) => p.id == 'stomach');
      expect(stomach.isFeminine, isTrue);
      expect(stomach.painPhraseHebrewWithNikkud, contains('כּוֹאֶבֶת'));
    });

    test('verifies head (ראש) is masculine', () {
      final head = HealthSeedData.bodyParts.firstWhere((p) => p.id == 'head');
      expect(head.isFeminine, isFalse);
      expect(head.painPhraseHebrewWithNikkud, contains('כּוֹאֵב'));
    });

    test('all 16 body parts and 10 medical cases are populated', () {
      expect(HealthSeedData.bodyParts.length, equals(16));
      expect(HealthSeedData.medicalCases.length, equals(10));
      expect(HealthSeedData.medicalGlossary.length, equals(16));
    });
  });
}
