import 'package:flutter/material.dart';

import '../../../srs/domain/entities/fsrs_analytics_data.dart';

/// Widget displaying the distribution of Hebrew vocabulary across FSRS memory stability tiers.
class FsrsStabilityMatrixWidget extends StatelessWidget {
  final Map<FsrsStabilityTier, int> cardsByStabilityTier;
  final int totalCards;

  const FsrsStabilityMatrixWidget({
    super.key,
    required this.cardsByStabilityTier,
    required this.totalCards,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Learned cards (excluding unlearned)
    final tiers = [
      FsrsStabilityTier.shortTerm,
      FsrsStabilityTier.mediumTerm,
      FsrsStabilityTier.longTerm,
      FsrsStabilityTier.permanent,
    ];

    final learnedCardsCount = tiers.fold<int>(
      0,
      (sum, tier) => sum + (cardsByStabilityTier[tier] ?? 0),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Multi-segment progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 14,
            child: Row(
              children: [
                if (learnedCardsCount == 0)
                  Expanded(
                    child: Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                    ),
                  )
                else
                  ...tiers.map((tier) {
                    final count = cardsByStabilityTier[tier] ?? 0;
                    if (count == 0) return const SizedBox.shrink();
                    final flex = (count * 1000) ~/ learnedCardsCount;
                    return Expanded(
                      flex: mathMax(flex, 1),
                      child: Container(
                        color: Color(tier.colorValue),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Grid of stability cards
        Row(
          children: [
            Expanded(child: _buildTierTile(context, FsrsStabilityTier.shortTerm)),
            const SizedBox(width: 8),
            Expanded(child: _buildTierTile(context, FsrsStabilityTier.mediumTerm)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildTierTile(context, FsrsStabilityTier.longTerm)),
            const SizedBox(width: 8),
            Expanded(child: _buildTierTile(context, FsrsStabilityTier.permanent)),
          ],
        ),
      ],
    );
  }

  Widget _buildTierTile(BuildContext context, FsrsStabilityTier tier) {
    final theme = Theme.of(context);
    final count = cardsByStabilityTier[tier] ?? 0;
    final percentage = totalCards > 0 ? (count / totalCards * 100).toStringAsFixed(0) : '0';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Color(tier.colorValue).withAlpha(20),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Color(tier.colorValue).withAlpha(80),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Color(tier.colorValue),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  tier.labelRu,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$count слов',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$percentage% · ${tier.durationRange}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

int mathMax(int a, int b) => a > b ? a : b;
