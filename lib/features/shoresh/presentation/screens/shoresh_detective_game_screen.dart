import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/shoresh_bloc.dart';
import '../bloc/shoresh_event.dart';
import '../bloc/shoresh_state.dart';
import '../widgets/root_extractor_quiz_card.dart';

/// Gamified screen for the "Root Detective" challenge mode.
class ShoreshDetectiveGameScreen extends StatefulWidget {
  const ShoreshDetectiveGameScreen({
    super.key,
    required this.bloc,
  });

  final ShoreshBloc bloc;

  @override
  State<ShoreshDetectiveGameScreen> createState() =>
      _ShoreshDetectiveGameScreenState();
}

class _ShoreshDetectiveGameScreenState
    extends State<ShoreshDetectiveGameScreen> {
  @override
  void initState() {
    super.initState();
    widget.bloc.add(const StartShoreshQuizEvent(questionCount: 8));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<ShoreshBloc, ShoreshState>(
      bloc: widget.bloc,
      builder: (context, state) {
        if (state is! ShoreshCatalogLoaded) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final quiz = state.activeQuiz;
        if (quiz == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final currentQuestion = quiz.currentQuestion;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Шореш-Детектив 🔍'),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: colorScheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${quiz.score} / ${quiz.questions.length}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              LinearProgressIndicator(
                value: quiz.questions.isEmpty
                    ? 0
                    : (quiz.currentIndex + (quiz.isAnswerSubmitted ? 1 : 0)) /
                        quiz.questions.length,
                minHeight: 4,
              ),
              Expanded(
                child: quiz.isCompleted || currentQuestion == null
                    ? _DetectiveCelebrationView(
                        score: quiz.score,
                        totalQuestions: quiz.questions.length,
                        onRestart: () {
                          widget.bloc.add(
                            const StartShoreshQuizEvent(questionCount: 8),
                          );
                        },
                        onBackToCatalog: () => Navigator.of(context).pop(),
                      )
                    : RootExtractorQuizCard(
                        question: currentQuestion,
                        showNikkud: state.showNikkud,
                        selectedOptionIndex: quiz.selectedOptionIndex,
                        isSubmitted: quiz.isAnswerSubmitted,
                        isLastQuestion:
                            quiz.currentIndex == quiz.questions.length - 1,
                        onSelectOption: (index) {
                          widget.bloc.add(AnswerShoreshQuizEvent(index));
                        },
                        onNext: () {
                          widget.bloc.add(const NextShoreshQuizQuestionEvent());
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DetectiveCelebrationView extends StatelessWidget {
  const _DetectiveCelebrationView({
    required this.score,
    required this.totalQuestions,
    required this.onRestart,
    required this.onBackToCatalog,
  });

  final int score;
  final int totalQuestions;
  final VoidCallback onRestart;
  final VoidCallback onBackToCatalog;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final ratio = totalQuestions > 0 ? score / totalQuestions : 0.0;
    final (rankEmoji, rankTitle, rankDescription) = switch (ratio) {
      >= 0.9 => (
          '🕵️‍♂️🏆',
          'Шериф Морфологии!',
          'Вы безошибочно вычленяете трехбуквенные корни из любых грамматических конструкций!'
        ),
      >= 0.6 => (
          '🔍✨',
          'Старший Детектив Корней',
          'Отличная интуиция! Префиксы и суффиксы больше не могут запутать вас.'
        ),
      _ => (
          '📜🔍',
          'Младший Следователь',
          'Хорошая тренировка! Изучите корни в каталоге и повторите расследование.'
        ),
    };

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              rankEmoji,
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            Text(
              rankTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ваш результат: $score из $totalQuestions правильных корней',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              rankDescription,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Пройти новое расследование'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: onRestart,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Вернуться в каталог корней'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: onBackToCatalog,
            ),
          ],
        ),
      ),
    );
  }
}
