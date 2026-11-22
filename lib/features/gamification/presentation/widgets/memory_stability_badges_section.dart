import 'package:flutter/material.dart';

import '../../../progress/domain/entities/learning_progress_summary.dart';
import '../../domain/entities/sabra_league.dart';
import '../../domain/services/sabra_league_service.dart';

/// Section rendering the FSRS Memory Stability Badges with interactive dialog inspection.
class MemoryStabilityBadgesSection extends StatelessWidget {
  final LearningProgressSummary summary;

  const MemoryStabilityBadgesSection({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badges = SabraLeagueService.evaluateMemoryBadges(summary: summary);
    final unlockedCount = badges.where((b) => b.isUnlocked).length;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('🧠', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      'Бейджи стабильности FSRS',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$unlockedCount из ${badges.length}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: badges.map((badge) {
                return _BadgeItemTile(
                  badge: badge,
                  onTap: () => _showBadgeDetailDialog(context, badge),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showBadgeDetailDialog(BuildContext context, MemoryStabilityBadge badge) {
    final theme = Theme.of(context);

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Text(
          badge.iconEmoji,
          style: const TextStyle(fontSize: 48),
        ),
        title: Column(
          children: [
            Text(badge.titleRu),
            const SizedBox(height: 2),
            Text(
              badge.titleHebrew,
              textDirection: TextDirection.rtl,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontFamily: 'Noto Sans Hebrew',
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              badge.descriptionRu,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: badge.isUnlocked
                    ? Colors.green.withAlpha(30)
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    badge.isUnlocked
                        ? Icons.check_circle_rounded
                        : Icons.timelapse_rounded,
                    size: 16,
                    color: badge.isUnlocked ? Colors.green.shade700 : theme.colorScheme.outline,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    badge.isUnlocked ? 'Разблокировано!' : badge.progressText,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: badge.isUnlocked
                          ? Colors.green.shade700
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }
}

class _BadgeItemTile extends StatelessWidget {
  final MemoryStabilityBadge badge;
  final VoidCallback onTap;

  const _BadgeItemTile({
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnlocked = badge.isUnlocked;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isUnlocked
              ? theme.colorScheme.primaryContainer.withAlpha(40)
              : theme.colorScheme.surfaceContainerHighest.withAlpha(80),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnlocked
                ? theme.colorScheme.primary.withAlpha(120)
                : theme.colorScheme.outlineVariant.withAlpha(80),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              badge.iconEmoji,
              style: TextStyle(
                fontSize: 18,
                color: isUnlocked ? null : Colors.grey,
              ),
            ),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  badge.titleRu,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isUnlocked
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.outline,
                  ),
                ),
                Text(
                  isUnlocked ? '✓ Получено' : badge.progressText,
                  style: TextStyle(
                    fontSize: 9,
                    color: isUnlocked
                        ? Colors.green.shade700
                        : theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
