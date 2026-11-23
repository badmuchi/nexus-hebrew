import 'package:equatable/equatable.dart';

/// Categories of banking and financial services in Israel.
enum BankTopicCategory {
  checkingAccount(
    id: 'checking',
    titleRu: 'Текущий счет (עוֹ״שׁ) и комиссии',
    hebrewTitle: 'עוֹבֵר וָשָׁב וַעֲמָלוֹת',
    iconEmoji: '💳',
  ),
  checksAndPayments(
    id: 'checks',
    titleRu: 'Чековая книжка и переводы',
    hebrewTitle: 'פִּנְקַס צֶ׳קִים וְתַשְׁלוּמִים',
    iconEmoji: '📝',
  ),
  mortgage(
    id: 'mortgage',
    titleRu: 'Ипотека (Машканта)',
    hebrewTitle: 'מַשְׁכַּנְתָּא וּמַסְלוּלִים',
    iconEmoji: '🏠',
  ),
  socialSecurity(
    id: 'social_security',
    titleRu: 'Битуах Леуми и Налоги',
    hebrewTitle: 'בִּטּוּחַ לְאֻמִּי וּמִסִּים',
    iconEmoji: '🛡️',
  );

  final String id;
  final String titleRu;
  final String hebrewTitle;
  final String iconEmoji;

  const BankTopicCategory({
    required this.id,
    required this.titleRu,
    required this.hebrewTitle,
    required this.iconEmoji,
  });
}

/// An Israeli bank check simulator data model.
final class IsraeliCheckModel extends Equatable {
  final String id;
  final String bankName;
  final String branchNumber;
  final String accountNumber;
  final String checkNumber;
  final String dateString;
  final String payeeHebrewWithNikkud;
  final String payeeRu;
  final double amountShekels;
  final String amountInHebrewWordsWithNikkud;
  final bool hasCrossLines;
  final bool isPayeeOnlyRestricted; // למוטב בלבד
  final String purposeRu;
  final String securityTipRu;

  const IsraeliCheckModel({
    required this.id,
    required this.bankName,
    required this.branchNumber,
    required this.accountNumber,
    required this.checkNumber,
    required this.dateString,
    required this.payeeHebrewWithNikkud,
    required this.payeeRu,
    required this.amountShekels,
    required this.amountInHebrewWordsWithNikkud,
    required this.hasCrossLines,
    required this.isPayeeOnlyRestricted,
    required this.purposeRu,
    required this.securityTipRu,
  });

  @override
  List<Object?> get props => [
        id,
        bankName,
        branchNumber,
        accountNumber,
        checkNumber,
        dateString,
        payeeHebrewWithNikkud,
        payeeRu,
        amountShekels,
        amountInHebrewWordsWithNikkud,
        hasCrossLines,
        isPayeeOnlyRestricted,
        purposeRu,
        securityTipRu,
      ];
}

/// A dialogue scenario at a bank or Bituach Leumi branch.
final class FinancialScenario extends Equatable {
  final String id;
  final BankTopicCategory category;
  final String titleRu;
  final String interlocutorRoleRu;
  final String clientGoalRu;
  final String tellerSpeechHebrewWithNikkud;
  final String tellerSpeechRu;
  final List<String> clientResponseOptionsHebrew;
  final List<String> clientResponseOptionsRu;
  final int bestOptionIndex;
  final String explanationRu;
  final String insiderFinancialTipRu;

  const FinancialScenario({
    required this.id,
    required this.category,
    required this.titleRu,
    required this.interlocutorRoleRu,
    required this.clientGoalRu,
    required this.tellerSpeechHebrewWithNikkud,
    required this.tellerSpeechRu,
    required this.clientResponseOptionsHebrew,
    required this.clientResponseOptionsRu,
    required this.bestOptionIndex,
    required this.explanationRu,
    required this.insiderFinancialTipRu,
  });

  @override
  List<Object?> get props => [
        id,
        category,
        titleRu,
        interlocutorRoleRu,
        clientGoalRu,
        tellerSpeechHebrewWithNikkud,
        tellerSpeechRu,
        clientResponseOptionsHebrew,
        clientResponseOptionsRu,
        bestOptionIndex,
        explanationRu,
        insiderFinancialTipRu,
      ];
}
