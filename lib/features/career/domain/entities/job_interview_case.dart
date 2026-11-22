import 'package:equatable/equatable.dart';

/// Categories of job interview stages and workplace situations in Israel.
enum InterviewCategory {
  hrScreening(
    id: 'hr_screening',
    titleRu: 'Скрининг с HR',
    emoji: '👩‍💼',
    description: 'Первый созвон: рассказ о себе, опыт, мотивация',
  ),
  salaryAndContract(
    id: 'salary_contract',
    titleRu: 'Зарплата и Оффер',
    emoji: '💰',
    description: 'Ожидания брутто/нетто, керен иштальмут, тэн бис, отпуск',
  ),
  dailyWorkplace(
    id: 'daily_workplace',
    titleRu: 'Офис и Стендап',
    emoji: '💻',
    description: 'Дейли-митинги, таски, дедлайны, офисный сленг хайтека',
  ),
  payslipDecoding(
    id: 'payslip',
    titleRu: 'Тлуш Маскорет',
    emoji: '📄',
    description: 'Разбор расчетного листка: налоги, пенсионные отчисления, нетто',
  );

  final String id;
  final String titleRu;
  final String emoji;
  final String description;

  const InterviewCategory({
    required this.id,
    required this.titleRu,
    required this.emoji,
    required this.description,
  });
}

/// An interview simulation case with recruiter question and multiple response options.
final class InterviewQuestion extends Equatable {
  final String id;
  final InterviewCategory category;
  final String interviewerRoleRu;
  final String interviewerHebrewWithNikkud;
  final String interviewerHebrewPlain;
  final String transcriptionRu;
  final String translationRu;
  final String mentorCareerTipRu;
  final List<String> responseOptions;
  final int bestResponseIndex;
  final String explanationRu;
  final String? audioPath;

  const InterviewQuestion({
    required this.id,
    required this.category,
    required this.interviewerRoleRu,
    required this.interviewerHebrewWithNikkud,
    required this.interviewerHebrewPlain,
    required this.transcriptionRu,
    required this.translationRu,
    required this.mentorCareerTipRu,
    required this.responseOptions,
    required this.bestResponseIndex,
    required this.explanationRu,
    this.audioPath,
  });

  String get bestResponse => responseOptions[bestResponseIndex];

  @override
  List<Object?> get props => [
        id,
        category,
        interviewerRoleRu,
        interviewerHebrewWithNikkud,
        interviewerHebrewPlain,
        transcriptionRu,
        translationRu,
        mentorCareerTipRu,
        responseOptions,
        bestResponseIndex,
        explanationRu,
        audioPath,
      ];
}
