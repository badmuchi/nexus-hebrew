import 'package:flutter/material.dart';

import '../../domain/entities/israeli_life_scene.dart';

class SceneChallengeCard extends StatefulWidget {
  const SceneChallengeCard({
    super.key,
    required this.challenge,
    required this.index,
    required this.total,
    required this.onAnswerSelected,
  });

  final SceneChallenge challenge;
  final int index;
  final int total;
  final void Function(int challengeIndex, bool isCorrect) onAnswerSelected;

  @override
  State<SceneChallengeCard> createState() => _SceneChallengeCardState();
}

class _SceneChallengeCardState extends State<SceneChallengeCard> {
  int? _selectedIndex;
  bool _hasAnswered = false;

  void _selectOption(int optionIndex) {
    if (_hasAnswered) return;

    final isCorrect = optionIndex == widget.challenge.correctIndex;
    setState(() {
      _selectedIndex = optionIndex;
      _hasAnswered = true;
    });

    widget.onAnswerSelected(widget.index, isCorrect);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top: Question index and status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Ситуация ${widget.index + 1} из ${widget.total}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const Spacer(),
                if (_hasAnswered)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _selectedIndex == widget.challenge.correctIndex
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        color: _selectedIndex == widget.challenge.correctIndex
                            ? Colors.green
                            : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _selectedIndex == widget.challenge.correctIndex
                            ? 'Верно!'
                            : 'Ошибка',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _selectedIndex == widget.challenge.correctIndex
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Situation Description
            Text(
              widget.challenge.situationRu,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 16),

            // Options list
            for (int i = 0; i < widget.challenge.options.length; i++) ...[
              _ChallengeOptionTile(
                index: i,
                optionText: widget.challenge.options[i],
                isSelected: _selectedIndex == i,
                isCorrect: i == widget.challenge.correctIndex,
                hasAnswered: _hasAnswered,
                isDark: isDark,
                onTap: () => _selectOption(i),
              ),
              const SizedBox(height: 8),
            ],

            // Explanation Block
            if (_hasAnswered) ...[
              const SizedBox(height: 10),
              _ChallengeExplanationCard(
                explanation: widget.challenge.explanationRu,
                isCorrect: _selectedIndex == widget.challenge.correctIndex,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChallengeOptionTile extends StatelessWidget {
  const _ChallengeOptionTile({
    required this.index,
    required this.optionText,
    required this.isSelected,
    required this.isCorrect,
    required this.hasAnswered,
    required this.isDark,
    required this.onTap,
  });

  final int index;
  final String optionText;
  final bool isSelected;
  final bool isCorrect;
  final bool hasAnswered;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color borderColor = isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08);
    Color bgColor = theme.colorScheme.surface;

    if (hasAnswered) {
      if (isCorrect) {
        borderColor = Colors.green;
        bgColor = Colors.green.withValues(alpha: isDark ? 0.25 : 0.12);
      } else if (isSelected) {
        borderColor = Colors.red;
        bgColor = Colors.red.withValues(alpha: isDark ? 0.25 : 0.12);
      }
    } else if (isSelected) {
      borderColor = theme.colorScheme.primary;
      bgColor = theme.colorScheme.primaryContainer.withValues(alpha: 0.2);
    }

    return InkWell(
      onTap: hasAnswered ? null : onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: borderColor,
            width: isSelected || (hasAnswered && isCorrect) ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? (hasAnswered && !isCorrect ? Colors.red : theme.colorScheme.primary)
                    : theme.colorScheme.surfaceContainerHighest,
              ),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  optionText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Heebo',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChallengeExplanationCard extends StatelessWidget {
  const _ChallengeExplanationCard({
    required this.explanation,
    required this.isCorrect,
  });

  final String explanation;
  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isCorrect ? Colors.green : Colors.orange).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isCorrect ? Colors.green : Colors.orange).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            size: 18,
            color: isCorrect ? Colors.green : Colors.orange.shade800,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              explanation,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
