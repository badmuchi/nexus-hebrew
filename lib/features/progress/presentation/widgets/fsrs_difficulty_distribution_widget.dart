import 'package:flutter/material.dart';

import '../../../srs/domain/entities/fsrs_analytics_data.dart';

/// Widget displaying the difficulty distribution of Hebrew vocabulary under FSRS-4.5.
class FsrsDifficultyDistributionWidget extends StatelessWidget {
  final Map<FsrsDifficultyTier, int> cardsByDifficultyTier;
  final double averageDifficulty;

  const FsrsDifficultyDistributionWidget({
    super.key,
    required this.cardsByDifficultyTier,
    required this.averageDifficulty,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final easyCount = cardsByDifficultyTier[FsrsDifficultyTier.easy] ?? 0;
    final mediumCount = cardsByDifficultyTier[FsrsDifficultyTier.medium] ?? 0;
    final hardCount = cardsByDifficultyTier[FsrsDifficultyTier.hard] ?? 0;
    final total = easyCount + mediumCount + hardCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Спектр сложности слов (D)',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Средняя сложность: ${averageDifficulty.toStringAsFixed(1)} / 10',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Tri-color bar
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 10,
            child: Row(
              children: [
                if (total == 0)
                  Expanded(
                    child: Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                    ),
                  )
                else ...[
                  if (easyCount > 0)
                    Expanded(
                      flex: easyCount,
                      child: Container(
                        color: Color(FsrsDifficultyTier.easy.colorValue),
                      ),
                    ),
                  if (mediumCount > 0)
                    Expanded(
                      flex: mediumCount,
                      child: Container(
                        color: Color(FsrsDifficultyTier.medium.colorValue),
                      ),
                    ),
                  if (hardCount > 0)
                    Expanded(
                      flex: hardCount,
                      child: Container(
                        color: Color(FsrsDifficultyTier.hard.colorValue),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Breakdown chips
        Row(
          children: [
            Expanded(
              child: _buildItem(
                context,
                'Легкие',
                easyCount,
                total,
                Color(FsrsDifficultyTier.easy.colorValue),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildItem(
                context,
                'Средние',
                mediumCount,
                total,
                Color(FsrsDifficultyTier.medium.colorValue),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildItem(
                context,
                'Трудные',
                hardCount,
                total,
                Color(FsrsDifficultyTier.hard.colorValue),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildItem(
    BuildContext context,
    String label,
    int count,
    int total,
    Color color,
  ) {
    final theme = Theme.of(context);
    final pct = total > 0 ? (count / total * 100).toStringAsFixed(0) : '0';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '$count ($pct%)',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
