import 'package:flutter/material.dart';

import '../../domain/entities/shoresh_entity.dart';

/// Interactive challenge card for the "Root Detective" simulator.
/// Prompts the user to isolate the 3 pure root letters from a derived Hebrew word.
class RootExtractorQuizCard extends StatelessWidget {
  const RootExtractorQuizCard({
    super.key,
    required this.question,
    required this.showNikkud,
    required this.selectedOptionIndex,
    required this.isSubmitted,
    required this.onSelectOption,
    required this.onNext,
    required this.isLastQuestion,
  });

  final ShoreshQuizQuestion question;
  final bool showNikkud;
  final int? selectedOptionIndex;
  final bool isSubmitted;
  final ValueChanged<int> onSelectOption;
  final VoidCallback onNext;
  final bool isLastQuestion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final word =
        showNikkud ? question.wordVocalized : question.wordNormalized;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Detective badge header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'Раскройте корень слова',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Mystery Hebrew Word Display
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.6),
              ),
            ),
            child: Column(
              children: [
                Text(
                  word,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  question.wordTranslation,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Выберите 3 коренные буквы (отбросьте приставки и суффиксы):',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.outline,
            ),
          ),
          const SizedBox(height: 12),

          // Options Grid
          for (var i = 0; i < question.options.length; i++) ...[
            _QuizOptionTile(
              index: i,
              optionText: question.options[i],
              isSelected: selectedOptionIndex == i,
              isSubmitted: isSubmitted,
              isCorrect: i == question.correctIndex,
              onTap: isSubmitted ? null : () => onSelectOption(i),
            ),
            const SizedBox(height: 10),
          ],

          // Morphological Revelation Card
          if (isSubmitted) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: selectedOptionIndex == question.correctIndex
                    ? Colors.teal.withValues(alpha: 0.1)
                    : Colors.amber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selectedOptionIndex == question.correctIndex
                      ? Colors.teal.withValues(alpha: 0.5)
                      : Colors.amber.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        selectedOptionIndex == question.correctIndex
                            ? Icons.verified_rounded
                            : Icons.lightbulb_outline_rounded,
                        color: selectedOptionIndex == question.correctIndex
                            ? Colors.teal
                            : Colors.amber.shade800,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        selectedOptionIndex == question.correctIndex
                            ? 'Верно раскрыто!'
                            : 'Разбор аффиксов:',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: selectedOptionIndex == question.correctIndex
                              ? Colors.teal
                              : Colors.amber.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    question.affixesExplanationRu,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onNext,
              icon: Icon(
                isLastQuestion
                    ? Icons.emoji_events_rounded
                    : Icons.arrow_forward_rounded,
              ),
              label: Text(
                isLastQuestion
                    ? 'Завершить расследование'
                    : 'Следующее слово',
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuizOptionTile extends StatelessWidget {
  const _QuizOptionTile({
    required this.index,
    required this.optionText,
    required this.isSelected,
    required this.isSubmitted,
    required this.isCorrect,
    required this.onTap,
  });

  final int index;
  final String optionText;
  final bool isSelected;
  final bool isSubmitted;
  final bool isCorrect;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color backgroundColor = colorScheme.surfaceContainerLow;
    Color borderColor = colorScheme.outlineVariant.withValues(alpha: 0.5);
    Color textColor = colorScheme.onSurface;

    if (isSubmitted) {
      if (isCorrect) {
        backgroundColor = Colors.teal.withValues(alpha: 0.15);
        borderColor = Colors.teal;
        textColor = Colors.teal.shade800;
      } else if (isSelected) {
        backgroundColor = Colors.red.withValues(alpha: 0.15);
        borderColor = Colors.red;
        textColor = Colors.red.shade800;
      }
    } else if (isSelected) {
      backgroundColor = colorScheme.primaryContainer;
      borderColor = colorScheme.primary;
      textColor = colorScheme.onPrimaryContainer;
    }

    return Material(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: borderColor, width: isSelected || (isSubmitted && isCorrect) ? 1.5 : 1.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSubmitted && isCorrect
                      ? Colors.teal
                      : (isSubmitted && isSelected ? Colors.red : colorScheme.surfaceContainerHighest),
                  shape: BoxShape.circle,
                ),
                child: isSubmitted && isCorrect
                    ? const Icon(Icons.check, size: 18, color: Colors.white)
                    : (isSubmitted && isSelected
                        ? const Icon(Icons.close, size: 18, color: Colors.white)
                        : Text(
                            String.fromCharCode(65 + index),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          )),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  optionText,
                  textDirection: TextDirection.rtl,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: textColor,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
