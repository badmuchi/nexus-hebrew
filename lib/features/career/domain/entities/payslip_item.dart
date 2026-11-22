import 'package:equatable/equatable.dart';

/// Categories of items on an Israeli payslip (תלוש משכורת).
enum PayslipCategory {
  income(
    id: 'income',
    titleRu: 'Доход брутто (הכנסות)',
    emoji: '💵',
  ),
  mandatoryDeduction(
    id: 'mandatory_deduction',
    titleRu: 'Обязательные налоги (ניכויי חובה)',
    emoji: '🏛️',
  ),
  socialDeduction(
    id: 'social_deduction',
    titleRu: 'Пенсия и сбережения работника (ניכויי רשות וחיסכון)',
    emoji: '🛡️',
  ),
  voluntaryDeduction(
    id: 'voluntary_deduction',
    titleRu: 'Прочие удержания (שונות)',
    emoji: '🍽️',
  ),
  employerContribution(
    id: 'employer_contribution',
    titleRu: 'Взносы работодателя (הפרשות מעסיק לחיסכון)',
    emoji: '🎁',
  );

  final String id;
  final String titleRu;
  final String emoji;

  const PayslipCategory({
    required this.id,
    required this.titleRu,
    required this.emoji,
  });
}

/// A line item in the payslip.
final class PayslipItem extends Equatable {
  final String id;
  final String titleRu;
  final String hebrewWithNikkud;
  final String hebrewPlain;
  final String transcriptionRu;
  final double amountShekels;
  final double? percentage;
  final PayslipCategory category;
  final String explanationRu;
  final String lawOrTipRu;

  const PayslipItem({
    required this.id,
    required this.titleRu,
    required this.hebrewWithNikkud,
    required this.hebrewPlain,
    required this.transcriptionRu,
    required this.amountShekels,
    this.percentage,
    required this.category,
    required this.explanationRu,
    required this.lawOrTipRu,
  });

  bool get isDeduction =>
      category == PayslipCategory.mandatoryDeduction ||
      category == PayslipCategory.socialDeduction ||
      category == PayslipCategory.voluntaryDeduction;

  bool get isEmployerContribution =>
      category == PayslipCategory.employerContribution;

  @override
  List<Object?> get props => [
        id,
        titleRu,
        hebrewWithNikkud,
        hebrewPlain,
        transcriptionRu,
        amountShekels,
        percentage,
        category,
        explanationRu,
        lawOrTipRu,
      ];
}

/// Representation of an entire Israeli monthly payslip.
final class IsraeliPayslip extends Equatable {
  final String employeeNameRu;
  final String employerNameRu;
  final String roleTitleRu;
  final String monthYearHebrew;
  final double grossSalaryShekels;
  final double nekudotZikuy;
  final double nekudotZikuyValueMonthly;
  final List<PayslipItem> items;

  const IsraeliPayslip({
    required this.employeeNameRu,
    required this.employerNameRu,
    required this.roleTitleRu,
    required this.monthYearHebrew,
    required this.grossSalaryShekels,
    required this.nekudotZikuy,
    required this.nekudotZikuyValueMonthly,
    required this.items,
  });

  /// Total deductions taken from gross pay.
  double get totalDeductions => items
      .where((item) => item.isDeduction)
      .fold<double>(0.0, (acc, item) => acc + item.amountShekels);

  /// Net salary deposited into employee's Israeli bank account.
  double get netSalary => grossSalaryShekels - totalDeductions;

  /// Total employer savings benefits deposited on behalf of the employee.
  double get totalEmployerBenefits => items
      .where((item) => item.isEmployerContribution)
      .fold<double>(0.0, (acc, item) => acc + item.amountShekels);

  @override
  List<Object?> get props => [
        employeeNameRu,
        employerNameRu,
        roleTitleRu,
        monthYearHebrew,
        grossSalaryShekels,
        nekudotZikuy,
        nekudotZikuyValueMonthly,
        items,
      ];
}
