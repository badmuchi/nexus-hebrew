import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/housing/data/datasources/housing_seed_data.dart';
import 'package:nexus_hebrew_app/features/housing/domain/entities/rental_contract_clause.dart';

void main() {
  group('HousingSeedData & Entities Tests', () {
    test('all abbreviations, listings, clauses and scenarios are populated', () {
      expect(HousingSeedData.yad2Abbreviations.length, equals(10));
      expect(HousingSeedData.apartmentListings.length, equals(3));
      expect(HousingSeedData.contractClauses.length, equals(5));
      expect(HousingSeedData.housingScenarios.length, equals(5));
      expect(HousingSeedData.housingGlossary.length, equals(16));
    });

    test('contract clauses identify fair vs unfair clauses', () {
      final fairClauses =
          HousingSeedData.contractClauses.where((c) => c.isFairClause).toList();
      final unfairClauses =
          HousingSeedData.contractClauses.where((c) => !c.isFairClause).toList();

      expect(fairClauses, isNotEmpty);
      expect(unfairClauses, isNotEmpty);

      // Verify unfair repair clause is marked appropriately
      final repairTrap = HousingSeedData.contractClauses
          .firstWhere((c) => c.id == 'clause_5_unfair_repair_clause');
      expect(repairTrap.isFairClause, isFalse);
      expect(repairTrap.category, equals(ContractClauseCategory.repairsAndDefects));
    });

    test('apartment listings contain price and valid rooms count', () {
      for (final listing in HousingSeedData.apartmentListings) {
        expect(listing.priceMonthlyShekels, greaterThan(3000));
        expect(listing.roomsCount, greaterThan(1.0));
        expect(listing.rawAdTextHebrew, isNotEmpty);
        expect(listing.abbreviationsUsed, isNotEmpty);
      }
    });
  });
}
