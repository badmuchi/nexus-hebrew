import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/career/data/datasources/career_seed_data.dart';
import 'package:nexus_hebrew_app/features/career/domain/entities/payslip_item.dart';

void main() {
  group('IsraeliPayslip Entity & Calculations', () {
    test('sampleHighTechPayslip calculates totals correctly', () {
      const p = CareerSeedData.sampleHighTechPayslip;

      expect(p.grossSalaryShekels, equals(25000.0));
      expect(p.nekudotZikuy, equals(5.25));
      expect(p.nekudotZikuyValueMonthly, equals(1270.50));

      // Gross should be sum of base + overtime
      final totalIncome = p.items
          .where((i) => i.category == PayslipCategory.income)
          .fold<double>(0.0, (acc, i) => acc + i.amountShekels);
      expect(totalIncome, equals(25000.0));

      // Deductions
      const expectedDeductions = 2430.0 + 1310.0 + 975.0 + 1500.0 + 393.75 + 200.0;
      expect(p.totalDeductions, closeTo(expectedDeductions, 0.01));

      // Net salary
      expect(p.netSalary, closeTo(25000.0 - expectedDeductions, 0.01));

      // Employer benefits
      const expectedEmployer = 1625.0 + 2082.50 + 1178.40;
      expect(p.totalEmployerBenefits, closeTo(expectedEmployer, 0.01));
    });

    test('PayslipItem flags isDeduction and isEmployerContribution correctly', () {
      const deduction = PayslipItem(
        id: 'tax',
        titleRu: 'Налог',
        hebrewWithNikkud: 'מַס',
        hebrewPlain: 'מס',
        transcriptionRu: 'mas',
        amountShekels: 100,
        category: PayslipCategory.mandatoryDeduction,
        explanationRu: 'exp',
        lawOrTipRu: 'law',
      );
      expect(deduction.isDeduction, isTrue);
      expect(deduction.isEmployerContribution, isFalse);

      const employer = PayslipItem(
        id: 'keren',
        titleRu: 'Керен',
        hebrewWithNikkud: 'קֶרֶן',
        hebrewPlain: 'קרן',
        transcriptionRu: 'keren',
        amountShekels: 500,
        category: PayslipCategory.employerContribution,
        explanationRu: 'exp',
        lawOrTipRu: 'law',
      );
      expect(employer.isDeduction, isFalse);
      expect(employer.isEmployerContribution, isTrue);
    });
  });
}
