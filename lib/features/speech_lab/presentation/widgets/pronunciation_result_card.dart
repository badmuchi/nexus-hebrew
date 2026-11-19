import 'package:flutter/material.dart';

import '../../../../core/speech/pronunciation_accuracy_evaluator.dart';

/// Interactive result card displaying pronunciation evaluation,
/// word-by-word phonetics breakdown, feedback, and XP earnings.
class PronunciationResultCard extends StatelessWidget {
  final PronunciationEvaluationResult result;
  final VoidCallback onRetry;
  final VoidCallback? onSaveToSrs;
  final bool isSavedToSrs;

  const PronunciationResultCard({
    super.key,
    required this.result,
    required this.onRetry,
    this.onSaveToSrs,
    this.isSavedToSrs = false,
  });

  Color _getScoreColor(ThemeData theme) {
    if (result.accuracyScore >= 0.85) {
      return Colors.green;
    } else if (result.accuracyScore >= 0.65) {
      return Colors.orange;
    } else {
      return theme.colorScheme.error;
    }
  }

  IconData _getGradeIcon() {
    return switch (result.grade) {
      PronunciationGrade.perfect => Icons.stars_rounded,
      PronunciationGrade.good => Icons.thumb_up_alt_rounded,
      PronunciationGrade.retry => Icons.replay_circle_filled_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scoreColor = _getScoreColor(theme);
    final scorePercent = result.accuracyPercentage;

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: scoreColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Row: Percentage Gauge + Grade Header + XP Pill
            Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: scoreColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: scoreColor.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$scorePercent%',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: scoreColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(_getGradeIcon(), size: 20, color: scoreColor),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              result.hebrewFeedback,
                              textDirection: TextDirection.rtl,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: scoreColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        result.russianFeedback,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (result.xpEarned > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.amber.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.bolt_rounded,
                          size: 16,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '+${result.xpEarned} XP',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 10),

            // Word-by-word Breakdown
            Text(
              'Пословный фонетический разбор:',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: result.wordMatches.map((match) {
                  final isOk = match.isMatched;
                  final isClose = !isOk && match.similarity >= 0.5;

                  final chipBg = isOk
                      ? Colors.green.withValues(alpha: 0.15)
                      : (isClose
                          ? Colors.orange.withValues(alpha: 0.15)
                          : theme.colorScheme.errorContainer.withValues(alpha: 0.3));

                  final chipBorder = isOk
                      ? Colors.green.withValues(alpha: 0.4)
                      : (isClose
                          ? Colors.orange.withValues(alpha: 0.4)
                          : theme.colorScheme.error.withValues(alpha: 0.4));

                  final textColor = isOk
                      ? Colors.green
                      : (isClose
                          ? Colors.deepOrange
                          : theme.colorScheme.error);

                  return Container(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: chipBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: chipBorder),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          match.targetWord,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: textColor,
                            height: 1.3,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        if (match.spokenMatch != null &&
                            match.spokenMatch != match.targetWord) ...[
                          const SizedBox(height: 2),
                          Text(
                            match.spokenMatch!,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              color: textColor.withValues(alpha: 0.8),
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(growable: false),
              ),
            ),
            const SizedBox(height: 18),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Попробовать снова'),
                  ),
                ),
                if (onSaveToSrs != null) ...[
                  const SizedBox(width: 10),
                  FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isSavedToSrs ? null : onSaveToSrs,
                    icon: Icon(
                      isSavedToSrs
                          ? Icons.check_circle_rounded
                          : Icons.bookmark_add_rounded,
                      size: 20,
                    ),
                    label: Text(
                      isSavedToSrs ? 'В FSRS ✓' : '+ FSRS',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
