import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/progress/presentation/widgets/fsrs_review_forecast_chart.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/fsrs_analytics_data.dart';

void main() {
  group('FsrsReviewForecastChart Widget Tests', () {
    testWidgets('renders forecast title, queue total, and days bars',
        (tester) async {
      final days = [
        FsrsForecastDay(
          date: DateTime(2026, 11, 22),
          dueCount: 4,
          dayLabel: 'Сегодня',
          isToday: true,
        ),
        FsrsForecastDay(
          date: DateTime(2026, 11, 23),
          dueCount: 7,
          dayLabel: 'Завтра',
        ),
        FsrsForecastDay(
          date: DateTime(2026, 11, 24),
          dueCount: 2,
          dayLabel: 'Вт',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FsrsReviewForecastChart(forecastDays: days),
          ),
        ),
      );

      expect(find.text('Прогноз повторений на 14 дней'), findsOneWidget);
      expect(find.text('Всего в очереди: 13'), findsOneWidget);
      expect(find.text('Сегодня'), findsOneWidget);
      expect(find.text('Завтра'), findsOneWidget);
      expect(find.text('Вт'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });
  });
}
