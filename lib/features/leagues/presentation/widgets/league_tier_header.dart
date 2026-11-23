import 'package:flutter/material.dart';

import '../../domain/entities/sabra_league.dart';

/// Header widget displaying the user's current league tier, weekly countdown,
/// and tier progression ladder.
class LeagueTierHeader extends StatelessWidget {
  final SabraLeagueState state;
  final VoidCallback? onRulesTap;

  const LeagueTierHeader({
    super.key,
    required this.state,
    this.onRulesTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tier = state.tier;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: tier.color.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: tier.color.withAlpha(120),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: tier.color.withAlpha(20),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tier badge and titles
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: tier.color.withAlpha(45),
                  shape: BoxShape.circle,
                  border: Border.all(color: tier.color, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  tier.badgeEmoji,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tier.titleHebrewWithNikkud,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: tier.color,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tier.titleRu,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (onRulesTap != null)
                IconButton(
                  tooltip: 'Правила лиги',
                  icon: const Icon(Icons.info_outline_rounded),
                  onPressed: onRulesTap,
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Tier progression row (Bronze -> Silver -> Gold -> Ruby -> Diamond)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: SabraLeagueTier.values.map((t) {
              final isCurrent = t == tier;
              final isReached = t.index <= tier.index;
              return Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? t.color
                            : (isReached ? t.color.withAlpha(75) : Colors.grey.withAlpha(35)),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCurrent ? Colors.white : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        t.badgeEmoji,
                        style: TextStyle(
                          fontSize: isCurrent ? 20 : 15,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        color: isCurrent ? t.color : Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Status & Info Pills
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusPill(
                icon: Icons.timer_outlined,
                text: 'До финиша: ${state.daysRemainingInWeek} дн.',
                color: Colors.blueGrey,
              ),
              _StatusPill(
                icon: Icons.star_rounded,
                text: '${state.userWeeklyXp} XP набрано',
                color: Colors.amber.shade800,
              ),
              _StatusPill(
                icon: state.isPromotionZone
                    ? Icons.trending_up_rounded
                    : (state.isDemotionZone ? Icons.trending_down_rounded : Icons.check_circle_outline),
                text: state.isPromotionZone
                    ? 'Место #${state.userRank}: Зона повышения!'
                    : (state.isDemotionZone
                        ? 'Место #${state.userRank}: Зона вылета!'
                        : 'Место #${state.userRank}: Безопасная зона'),
                color: state.isPromotionZone
                    ? Colors.green
                    : (state.isDemotionZone ? Colors.redAccent : Colors.blue),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _StatusPill({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
