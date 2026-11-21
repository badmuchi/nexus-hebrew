import 'package:flutter/material.dart';

import '../../domain/entities/israeli_life_scene.dart';

class SceneChallengeCard extends StatefulWidget {
  const SceneChallengeCard({
    super.key,
    required this.challenge,
    required this.index,
    required this.total,
    this.onAnswerSelected,
  });

  final SceneChallenge challenge;
  final int index;
  final int total;
  final ValueChanged<bool>? onAnswerSelected;

  @override
  State<SceneChallengeCard> createState() => _SceneChallengeCardState();
}

class _SceneChallengeCardState extends State<SceneChallengeCard> {
  int? _selectedIndex;
  bool _hasAnswered = false;

  void _selectOption(int index) {
    if (_hasAnswered) return;
    setState(() {
      _selectedIndex = index;
      _hasAnswered = true;
    });
    final isCorrect = index == widget.challenge.correctIndex;
    widget.onAnswerSelected?.call(isCorrect);
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
          color: isDark ? Colors.white12 : Colors.black.withOpacity(0.08),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Question Counter & Badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Ситуация ${widget.index + 1} из ${widget.total}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const Spacer(),
                if (_hasAnswered)
                  Row(
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

            // Options
            for (int i = 0; i < widget.challenge.options.length; i++) ...[
              _buildOption(i, theme, isDark),
              const SizedBox(height: 8),
            ],

            // Explanation Block (Revealed after answering)
            if (_hasAnswered) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (_selectedIndex == widget.challenge.correctIndex
                          ? Colors.green
                          : Colors.orange)
                      .withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (_selectedIndex == widget.challenge.correctIndex
                            ? Colors.green
                            : Colors.orange)
                        .withOpacity(0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      size: 18,
                      color: _selectedIndex == widget.challenge.correctIndex
                          ? Colors.green
                          : Colors.orange.shade800,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.challenge.explanationRu,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOption(int index, ThemeData theme, bool isDark) {
    final optionText = widget.challenge.options[index];
    final isSelected = _selectedIndex == index;
    final isCorrect = index == widget.challenge.correctIndex;

    Color borderColor = isDark ? Colors.white12 : Colors.black.withOpacity(0.08);
    Color bgColor = theme.colorScheme.surface;

    if (_hasAnswered) {
      if (isCorrect) {
        borderColor = Colors.green;
        bgColor = Colors.green.withOpacity(isDark ? 0.25 : 0.12);
      } else if (isSelected) {
        borderColor = Colors.red;
        bgColor = Colors.red.withOpacity(isDark ? 0.25 : 0.12);
      }
    } else if (isSelected) {
      borderColor = theme.colorScheme.primary;
      bgColor = theme.colorScheme.primaryContainer.withOpacity(0.2);
    }

    return InkWell(
      onTap: _hasAnswered ? null : () => _selectOption(index),
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: isSelected || (_hasAnswered && isCorrect) ? 1.8 : 1.0),
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
                    ? (_hasAnswered && !isCorrect ? Colors.red : theme.colorScheme.primary)
                    : theme.colorScheme.surfaceVariant,
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
