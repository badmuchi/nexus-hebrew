import 'package:flutter/material.dart';

import '../../../srs/domain/entities/fsrs_analytics_data.dart';

/// 14-day review forecast bar chart visualizing upcoming study workload.
class FsrsReviewForecastChart extends StatelessWidget {
  final List<FsrsForecastDay> forecastDays;
  final double height;

  const FsrsReviewForecastChart({
    super.key,
    required this.forecastDays,
    this.height = 130,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (forecastDays.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(child: Text('Нет данных прогноза')),
      );
    }

    final maxDue = forecastDays.fold<int>(
      1,
      (max, day) => day.dueCount > max ? day.dueCount : max,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Прогноз повторений на 14 дней',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Всего в очереди: ${forecastDays.fold<int>(0, (sum, d) => sum + d.dueCount)}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: forecastDays.map((day) {
              final ratio = (day.dueCount / maxDue).clamp(0.05, 1.0);
              final isToday = day.isToday;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Due count number
                      Text(
                        day.dueCount > 0 ? '${day.dueCount}' : '0',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                              isToday ? FontWeight.bold : FontWeight.normal,
                          color: isToday
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 3),

                      // Bar
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: FractionallySizedBox(
                            heightFactor: ratio,
                            child: Container(
                              decoration: BoxDecoration(
                                color: isToday
                                    ? theme.colorScheme.primary
                                    : day.dueCount > 0
                                        ? theme.colorScheme.secondary.withAlpha(160)
                                        : theme.colorScheme.surfaceContainerHighest,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Day label
                      Text(
                        day.dayLabel,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight:
                              isToday ? FontWeight.bold : FontWeight.normal,
                          color: isToday
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
