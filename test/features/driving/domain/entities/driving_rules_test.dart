import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/driving/data/datasources/driving_seed_data.dart';
import 'package:nexus_hebrew_app/features/driving/domain/entities/parking_curb_rule.dart';

void main() {
  group('DrivingSeedData & Entities Tests', () {
    test('all curb cases and waze prompts are properly populated', () {
      expect(DrivingSeedData.parkingCurbCases.length, equals(4));
      expect(DrivingSeedData.wazePrompts.length, equals(8));
      expect(DrivingSeedData.drivingScenarios.length, equals(5));
      expect(DrivingSeedData.drivingGlossary.length, equals(16));
    });

    test('red-white curb strictly forbids parking', () {
      final redWhite = DrivingSeedData.parkingCurbCases
          .firstWhere((c) => c.curbType == CurbColorType.redWhite);
      expect(redWhite.isParkingAllowed, isFalse);
      expect(redWhite.fineAmountTextRu, contains('Штраф'));
    });

    test('gray curb allows free parking when no signs', () {
      final gray = DrivingSeedData.parkingCurbCases
          .firstWhere((c) => c.curbType == CurbColorType.gray);
      expect(gray.isParkingAllowed, isTrue);
    });

    test('Waze prompts have valid action options and correct index', () {
      for (final prompt in DrivingSeedData.wazePrompts) {
        expect(prompt.actionOptionsRu.length, greaterThanOrEqualTo(2));
        expect(prompt.correctOptionIndex,
            lessThan(prompt.actionOptionsRu.length));
        expect(prompt.hebrewWithNikkud, isNotEmpty);
      }
    });
  });
}
