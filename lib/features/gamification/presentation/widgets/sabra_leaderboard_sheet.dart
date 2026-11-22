import 'package:flutter/material.dart';

import '../../domain/entities/sabra_league.dart';

/// Modal bottom sheet displaying the weekly Sabra League leaderboard.
class SabraLeaderboardSheet extends StatelessWidget {
  final SabraLeagueStatus status;

  const SabraLeaderboardSheet({
    super.key,
    required this.status,
  });

  static Future<void> show(BuildContext context, SabraLeagueStatus status) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      constraints: const BoxConstraints(maxWidth: 640),
      builder: (_) => SabraLeaderboardSheet(status: status),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tier = status.tier;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: League Title & Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(tier.colorHex).withAlpha(30),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  tier.emoji,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tier.nameRussian,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${tier.nameHebrew} • Неделя #${status.daysRemainingInWeek} дн. до итогов',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontFamily: 'Noto Sans Hebrew',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '#${status.userRank} из ${status.totalParticipants}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Promotion note banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withAlpha(20),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF10B981).withAlpha(80)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.upgrade_rounded,
                  color: Color(0xFF10B981),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    status.isInPromotionZone
                      ? 'Ты в зоне перехода в высшую лигу! Удерживай позицию до конца недели 🚀'
                      : 'Займи топ-5 в таблице, чтобы перейти в следующую лигу!',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF047857),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Leaderboard list
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: status.leaderboard.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final competitor = status.leaderboard[index];
                return _LeaderboardRow(
                  competitor: competitor,
                  isPromotionZone: competitor.rank <= 5,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final LeaderboardCompetitor competitor;
  final bool isPromotionZone;

  const _LeaderboardRow({
    required this.competitor,
    required this.isPromotionZone,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMe = competitor.isCurrentUser;

    Widget rankWidget;
    if (competitor.rank == 1) {
      rankWidget = const Text('🥇', style: TextStyle(fontSize: 20));
    } else if (competitor.rank == 2) {
      rankWidget = const Text('🥈', style: TextStyle(fontSize: 20));
    } else if (competitor.rank == 3) {
      rankWidget = const Text('🥉', style: TextStyle(fontSize: 20));
    } else {
      rankWidget = Container(
        width: 24,
        alignment: Alignment.center,
        child: Text(
          '#${competitor.rank}',
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: isPromotionZone ? FontWeight.bold : FontWeight.normal,
            color: isPromotionZone
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isMe
            ? theme.colorScheme.primaryContainer.withAlpha(120)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          rankWidget,
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 16,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            child: Text(
              competitor.avatarEmoji,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      competitor.nameRussian,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight:
                            isMe ? FontWeight.bold : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '(${competitor.nameHebrew})',
                      textDirection: TextDirection.rtl,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontFamily: 'Noto Sans Hebrew',
                      ),
                    ),
                  ],
                ),
                Text(
                  competitor.city,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${competitor.weeklyXp} XP',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isMe
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
              ),
              if (isPromotionZone)
                Text(
                  'Переход ⬆️',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
