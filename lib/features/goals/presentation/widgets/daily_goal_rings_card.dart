import 'package:flutter/material.dart';

import '../../../../core/utils/hebrew_normalizer.dart';
import '../../domain/entities/daily_goal.dart';
import 'daily_goal_rings_painter.dart';
import 'goal_settings_sheet.dart';

/// Interactive dashboard card showing Apple-style concentric activity rings,
/// daily targets, and streak continuity.
class DailyGoalRingsCard extends StatelessWidget {
  final DailyGoalProgress progress;
  final ValueChanged<DailyGoalIntensity>? onIntensityChanged;
  final VoidCallback? onNavigateToCards;
  final VoidCallback? onNavigateToPractice;
  final VoidCallback? onNavigateToQuests;
  final bool showNikkud;

  const DailyGoalRingsCard({
    super.key,
    required this.progress,
    this.onIntensityChanged,
    this.onNavigateToCards,
    this.onNavigateToPractice,
    this.onNavigateToQuests,
    this.showNikkud = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Header: Title & Settings trigger
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('🎯 ', style: TextStyle(fontSize: 16)),
                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: Text(
                              showNikkud
                                  ? 'יַעַד יוֹמִי וְהֶרְגֵּלִים'
                                  : HebrewNormalizer.stripNikkud('יַעַד יוֹמִי וְהֶרְגֵּלִים'),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                height: 1.45,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              progress.intensity.titleRu,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Кольца активности • Стрик: ${progress.streakDays} ${progress.streakDays == 1 ? 'день' : 'дн.'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onIntensityChanged != null)
                  IconButton(
                    icon: const Icon(Icons.tune_rounded, size: 20),
                    tooltip: 'Настроить цель',
                    onPressed: () => GoalSettingsSheet.show(
                      context: context,
                      currentIntensity: progress.intensity,
                      onIntensitySelected: onIntensityChanged!,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),

            // Rings & Targets Section
            Row(
              children: [
                // Activity Rings Painter Widget
                SizedBox(
                  width: 92,
                  height: 92,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(92, 92),
                        painter: DailyGoalRingsPainter(
                          cardsProgress: progress.cardsProgress,
                          minutesProgress: progress.minutesProgress,
                          questsProgress: progress.questsProgress,
                          strokeWidth: 7.5,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${progress.overallPercent}%',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${progress.closedRingsCount}/3',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // Ring Target Tiles
                Expanded(
                  child: Column(
                    children: [
                      _buildTargetRow(
                        context: context,
                        color: const Color(0xFF00BFA5),
                        icon: Icons.style_rounded,
                        label: 'Карточки FSRS',
                        current: progress.cardsReviewed,
                        target: progress.targetCards,
                        isClosed: progress.isCardsRingClosed,
                        unit: 'шт.',
                        onTap: onNavigateToCards,
                      ),
                      const SizedBox(height: 8),
                      _buildTargetRow(
                        context: context,
                        color: const Color(0xFFFF9100),
                        icon: Icons.timer_rounded,
                        label: 'Минуты практики',
                        current: progress.practiceMinutes,
                        target: progress.targetMinutes,
                        isClosed: progress.isMinutesRingClosed,
                        unit: 'мин',
                        onTap: onNavigateToPractice,
                      ),
                      const SizedBox(height: 8),
                      _buildTargetRow(
                        context: context,
                        color: const Color(0xFF7C4DFF),
                        icon: Icons.flag_rounded,
                        label: 'Квесты Сабры',
                        current: progress.questsCompleted,
                        target: progress.targetQuests,
                        isClosed: progress.isQuestsRingClosed,
                        unit: 'кв.',
                        onTap: onNavigateToQuests,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Celebration Banner when all rings closed
            if (progress.isAllGoalsMet) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: const Row(
                  children: [
                    Text('🎉 ', style: TextStyle(fontSize: 22)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: Text(
                              'כָּל הַכָּבוֹד! הַיַּעַד הַיּוֹמִי הֻשְׁלַם!',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Color(0xFF1B5E20),
                                height: 1.45,
                              ),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Все 3 кольца активности закрыты. Стрик непрерывен!',
                            style: TextStyle(fontSize: 11.5, color: Color(0xFF2E7D32)),
                          ),
                        ],
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

  Widget _buildTargetRow({
    required BuildContext context,
    required Color color,
    required IconData icon,
    required String label,
    required int current,
    required int target,
    required bool isClosed,
    required String unit,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '$current / $target $unit',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: isClosed ? Colors.green.shade700 : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 4),
          if (isClosed)
            const Icon(Icons.check_circle_rounded, size: 14, color: Colors.green)
          else
            Icon(Icons.chevron_right_rounded, size: 14, color: theme.colorScheme.outlineVariant),
        ],
      ),
    );
  }
}
