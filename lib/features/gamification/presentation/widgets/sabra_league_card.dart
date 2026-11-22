import 'package:flutter/material.dart';

import '../../domain/services/sabra_league_service.dart';
import 'sabra_leaderboard_sheet.dart';

/// Interactive card presenting current Sabra League, weekly progress, and leaderboard.
class SabraLeagueCard extends StatelessWidget {
  final int weeklyXp;
  final VoidCallback? onOpenLeaderboard;

  const SabraLeagueCard({
    super.key,
    required this.weeklyXp,
    this.onOpenLeaderboard,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = SabraLeagueService.computeLeagueStatus(weeklyXp: weeklyXp);
    final tier = status.tier;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withAlpha(120)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (onOpenLeaderboard != null) {
            onOpenLeaderboard!();
          } else {
            SabraLeaderboardSheet.show(context, status);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Row: League Avatar + Titles + Rank Badge
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Color(tier.colorHex).withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tier.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                tier.nameRussian,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              tier.nameHebrew,
                              textDirection: TextDirection.rtl,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontFamily: 'Noto Sans Hebrew',
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${status.weeklyXp} XP на этой неделе • ${status.daysRemainingInWeek} дн. до финала',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: status.isTopThree
                          ? Colors.amber.shade100
                          : theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          status.isTopThree ? '🏆 ' : '📍 ',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          '#${status.userRank}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: status.isTopThree
                                ? Colors.amber.shade900
                                : theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Progress bar towards next league tier
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        status.xpToNextTier > 0
                            ? 'До следующей лиги: ${status.xpToNextTier} XP'
                            : 'Высшая лига достигнута! 👑',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        '${(status.progressToNextTier * 100).toStringAsFixed(0)}%',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: status.progressToNextTier,
                      minHeight: 7,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      color: Color(tier.colorHex),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Bottom action hint
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    status.isInPromotionZone
                        ? '🔥 В зоне повышения (Топ-5)'
                        : 'Входи в Топ-5 для повышения',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: status.isInPromotionZone
                          ? Colors.green.shade700
                          : theme.colorScheme.outline,
                    ),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () => SabraLeaderboardSheet.show(context, status),
                    icon: const Icon(Icons.leaderboard_rounded, size: 16),
                    label: const Text('Турнирная таблица'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
