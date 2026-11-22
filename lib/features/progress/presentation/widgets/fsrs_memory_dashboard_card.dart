import 'package:flutter/material.dart';

import '../../../srs/domain/entities/fsrs_analytics_data.dart';
import '../../domain/entities/learning_progress_summary.dart';
import 'fsrs_difficulty_distribution_widget.dart';
import 'fsrs_retention_chart.dart';
import 'fsrs_review_forecast_chart.dart';
import 'fsrs_stability_matrix_widget.dart';

/// Interactive FSRS-4.5 memory analytics dashboard card for [ProgressScreen].
class FsrsMemoryDashboardCard extends StatefulWidget {
  final LearningProgressSummary summary;
  final VoidCallback? onStartAudioDrill;

  const FsrsMemoryDashboardCard({
    super.key,
    required this.summary,
    this.onStartAudioDrill,
  });

  @override
  State<FsrsMemoryDashboardCard> createState() =>
      _FsrsMemoryDashboardCardState();
}

class _FsrsMemoryDashboardCardState extends State<FsrsMemoryDashboardCard> {
  int _selectedTab = 0; // 0: Обзор, 1: Кривая R(t), 2: Прогноз, 3: Стабильность

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summary = widget.summary;
    final analytics = summary.fsrsAnalytics;

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
            // Card Title & FSRS-4.5 badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.psychology_rounded,
                    color: theme.colorScheme.primary,
                    size: 22,
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
                              'Память FSRS-4.5',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'AI Sched',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Всего в колоде: ${summary.totalSrsCards} карточек',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Retention rate pill
                if (analytics != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF10B981).withAlpha(100),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${(analytics.currentRetentionRate * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF10B981),
                          ),
                        ),
                        const Text(
                          'удержание',
                          style: TextStyle(
                            fontSize: 9,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),

            // Segmented Tab Selector
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<int>(
                segments: const [
                  ButtonSegment(
                    value: 0,
                    label: Text('Обзор'),
                    icon: Icon(Icons.dashboard_rounded, size: 16),
                  ),
                  ButtonSegment(
                    value: 1,
                    label: Text('Кривая R(t)'),
                    icon: Icon(Icons.show_chart_rounded, size: 16),
                  ),
                  ButtonSegment(
                    value: 2,
                    label: Text('Прогноз'),
                    icon: Icon(Icons.calendar_view_week_rounded, size: 16),
                  ),
                  ButtonSegment(
                    value: 3,
                    label: Text('Матрица'),
                    icon: Icon(Icons.grid_view_rounded, size: 16),
                  ),
                ],
                selected: {_selectedTab},
                onSelectionChanged: (set) {
                  setState(() => _selectedTab = set.first);
                },
              ),
            ),
            const SizedBox(height: 16),

            // Tab Content
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: switch (_selectedTab) {
                0 => _buildOverviewTab(context, summary, analytics),
                1 => analytics != null
                    ? FsrsRetentionChart(
                        averageStabilityDays: analytics.averageStabilityDays,
                        currentRetentionRate: analytics.currentRetentionRate,
                        retentionCurvePoints: analytics.retentionCurvePoints,
                      )
                    : const Center(child: Text('Нет данных кривой')),
                2 => analytics != null
                    ? FsrsReviewForecastChart(
                        forecastDays: analytics.forecastDays,
                      )
                    : const Center(child: Text('Нет данных прогноза')),
                _ => analytics != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FsrsStabilityMatrixWidget(
                            cardsByStabilityTier: analytics.cardsByStabilityTier,
                            totalCards: analytics.totalCards,
                          ),
                          const Divider(height: 24),
                          FsrsDifficultyDistributionWidget(
                            cardsByDifficultyTier:
                                analytics.cardsByDifficultyTier,
                            averageDifficulty: analytics.averageDifficulty,
                          ),
                        ],
                      )
                    : const Center(child: Text('Нет данных матрицы')),
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(
    BuildContext context,
    LearningProgressSummary summary,
    FsrsAnalyticsData? analytics,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Metric tiles row
        Row(
          children: [
            Expanded(
              child: _buildMetricBox(
                context,
                title: 'К повторению',
                value: '${summary.dueSrsCards}',
                subtitle: 'ждут сегодня',
                color: theme.colorScheme.primary,
                icon: Icons.alarm_rounded,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricBox(
                context,
                title: 'Стабильность S',
                value: analytics != null
                    ? '${analytics.averageStabilityDays.toStringAsFixed(1)} дн'
                    : '—',
                subtitle: 'средняя по колоде',
                color: const Color(0xFF42A5F5),
                icon: Icons.hourglass_top_rounded,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricBox(
                context,
                title: 'Успешность',
                value: analytics != null
                    ? '${(analytics.historicalSuccessRate * 100).toStringAsFixed(0)}%'
                    : '—',
                subtitle: 'Good / Easy ответы',
                color: const Color(0xFF10B981),
                icon: Icons.check_circle_outline_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Phase chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(
              avatar: const Icon(Icons.fiber_new_rounded, size: 16),
              label: Text('Новые: ${summary.newCards}'),
            ),
            Chip(
              avatar: const Icon(Icons.school_rounded, size: 16),
              label: Text('Изучаются: ${summary.learningCards}'),
            ),
            Chip(
              avatar: const Icon(Icons.verified_rounded, size: 16),
              label: Text('Закреплены: ${summary.reviewCards}'),
            ),
            Chip(
              avatar: const Icon(Icons.replay_rounded, size: 16),
              label: Text('Сбои (Lapses): ${summary.relearningCards}'),
            ),
            Chip(
              avatar: const Icon(Icons.repeat_rounded, size: 16),
              label: Text('Всего ревью: ${summary.totalSrsReviews}'),
            ),
          ],
        ),
        if (widget.onStartAudioDrill != null) ...[
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: widget.onStartAudioDrill,
            icon: const Icon(Icons.headphones_rounded),
            label: const Text('Запустить Hands-Free аудиотренажер'),
          ),
        ],
      ],
    );
  }

  Widget _buildMetricBox(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(70)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 9,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
