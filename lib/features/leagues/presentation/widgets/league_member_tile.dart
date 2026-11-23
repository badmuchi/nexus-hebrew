import 'package:flutter/material.dart';

import '../../domain/entities/sabra_league.dart';

/// Renders a single competitor tile on the Sabra weekly league leaderboard.
class LeagueMemberTile extends StatelessWidget {
  final LeagueMember member;
  final bool showPromotionDivider;
  final bool showDemotionDivider;

  const LeagueMemberTile({
    super.key,
    required this.member,
    this.showPromotionDivider = false,
    this.showDemotionDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTopThree = member.rank <= 3;

    final rankWidget = switch (member.rank) {
      1 => const Text('🥇', style: TextStyle(fontSize: 22)),
      2 => const Text('🥈', style: TextStyle(fontSize: 22)),
      3 => const Text('🥉', style: TextStyle(fontSize: 22)),
      _ => Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: member.isCurrentUser
                ? theme.colorScheme.primary.withAlpha(40)
                : Colors.grey.withAlpha(25),
            shape: BoxShape.circle,
          ),
          child: Text(
            '${member.rank}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: member.isCurrentUser
                  ? theme.colorScheme.primary
                  : theme.textTheme.bodyMedium?.color,
            ),
          ),
        ),
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: member.isCurrentUser
                ? theme.colorScheme.primaryContainer.withAlpha(90)
                : (isTopThree
                    ? theme.colorScheme.surfaceContainerHighest.withAlpha(45)
                    : theme.colorScheme.surface),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: member.isCurrentUser
                  ? theme.colorScheme.primary
                  : (isTopThree ? Colors.amber.withAlpha(100) : Colors.grey.withAlpha(40)),
              width: member.isCurrentUser ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Rank representation
              SizedBox(width: 32, child: Center(child: rankWidget)),

              const SizedBox(width: 10),

              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  member.avatarEmoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),

              const SizedBox(width: 12),

              // Member names
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            member.nameHebrew,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  member.isCurrentUser ? FontWeight.bold : FontWeight.w600,
                              height: 1.45,
                            ),
                          ),
                        ),
                        if (member.isCurrentUser) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'ВЫ',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      member.nameRu,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withAlpha(180),
                      ),
                    ),
                  ],
                ),
              ),

              // Rank movement delta
              if (member.rankChange != 0)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        member.rankChange > 0
                            ? Icons.arrow_drop_up_rounded
                            : Icons.arrow_drop_down_rounded,
                        color: member.rankChange > 0 ? Colors.green : Colors.red,
                        size: 20,
                      ),
                      Text(
                        '${member.rankChange.abs()}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: member.rankChange > 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),

              // Weekly XP
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${member.weeklyXp}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: member.isCurrentUser
                          ? theme.colorScheme.primary
                          : theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const Text(
                    'XP',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Zone dividing banners
        if (showPromotionDivider)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withAlpha(80)),
            ),
            alignment: Alignment.center,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.arrow_upward_rounded, size: 14, color: Colors.green),
                SizedBox(width: 6),
                Text(
                  '▲ ЗОНА ПОВЫШЕНИЯ В СЛЕДУЮЩУЮ ЛИГУ ▲',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

        if (showDemotionDivider)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withAlpha(80)),
            ),
            alignment: Alignment.center,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.arrow_downward_rounded, size: 14, color: Colors.red),
                SizedBox(width: 6),
                Text(
                  '▼ ЗОНА ПОНИЖЕНИЯ ЛИГИ ▼',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
