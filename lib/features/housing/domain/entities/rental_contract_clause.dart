import 'package:equatable/equatable.dart';

/// Categories of clauses in an Israeli standard rental contract (חוזה שכירות בלתי מוגנת).
enum ContractClauseCategory {
  guaranteesAndSecurity(
    id: 'guarantees',
    titleRu: 'Чеки и Гарантии (בטוחות וערבויות)',
    emoji: '🔐',
  ),
  repairsAndDefects(
    id: 'repairs',
    titleRu: 'Ремонт и поломки (תיקונים ובלאי)',
    emoji: '🛠️',
  ),
  earlyTermination(
    id: 'early_exit',
    titleRu: 'Досрочный выезд (פינוי מוקדם)',
    emoji: '🚪',
  ),
  billsAndTaxes(
    id: 'bills',
    titleRu: 'Счета и Арнона (חשבונות וארנונה)',
    emoji: '🧾',
  );

  final String id;
  final String titleRu;
  final String emoji;

  const ContractClauseCategory({
    required this.id,
    required this.titleRu,
    required this.emoji,
  });
}

/// A clause or condition from an Israeli rental agreement.
final class RentalContractClause extends Equatable {
  final String id;
  final ContractClauseCategory category;
  final String clauseTitleRu;
  final String clauseHebrewWithNikkud;
  final String clauseHebrewPlain;
  final String transcriptionRu;
  final String plainLanguageExplanationRu;
  final String tenantProtectionLawRu;
  final bool isFairClause;

  const RentalContractClause({
    required this.id,
    required this.category,
    required this.clauseTitleRu,
    required this.clauseHebrewWithNikkud,
    required this.clauseHebrewPlain,
    required this.transcriptionRu,
    required this.plainLanguageExplanationRu,
    required this.tenantProtectionLawRu,
    required this.isFairClause,
  });

  @override
  List<Object?> get props => [
        id,
        category,
        clauseTitleRu,
        clauseHebrewWithNikkud,
        clauseHebrewPlain,
        transcriptionRu,
        plainLanguageExplanationRu,
        tenantProtectionLawRu,
        isFairClause,
      ];
}
