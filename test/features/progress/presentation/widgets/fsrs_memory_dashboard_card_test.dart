import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/progress/domain/entities/learning_progress_summary.dart';
import 'package:nexus_hebrew_app/features/progress/presentation/widgets/fsrs_difficulty_distribution_widget.dart';
import 'package:nexus_hebrew_app/features/progress/presentation/widgets/fsrs_memory_dashboard_card.dart';
import 'package:nexus_hebrew_app/features/progress/presentation/widgets/fsrs_retention_chart.dart';
import 'package:nexus_hebrew_app/features/progress/presentation/widgets/fsrs_review_forecast_chart.dart';
import 'package:nexus_hebrew_app/features/progress/presentation/widgets/fsrs_stability_matrix_widget.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/fsrs_analytics_data.dart';

void main() {
  final sampleAnalytics = FsrsAnalyticsData(
    totalCards: 20,
    unlearnedCards: 2,
    cardsByStabilityTier: const {
      FsrsStabilityTier.unlearned: 2,
      FsrsStabilityTier.shortTerm: 4,
      FsrsStabilityTier.mediumTerm: 8,
      FsrsStabilityTier.longTerm: 4,
      FsrsStabilityTier.permanent: 2,
    },
    cardsByDifficultyTier: const {
      FsrsDifficultyTier.easy: 6,
      FsrsDifficultyTier.medium: 10,
      FsrsDifficultyTier.hard: 2,
    },
    averageStabilityDays: 16.4,
    averageDifficulty: 4.5,
    currentRetentionRate: 0.935,
    historicalSuccessRate: 0.89,
    totalLapses: 3,
    totalReviews: 45,
    forecastDays: [
      FsrsForecastDay(
        date: DateTime(2026, 11, 22),
        dueCount: 3,
        dayLabel: 'Сегодня',
        isToday: true,
      ),
    ],
    retentionCurvePoints: List.generate(31, (i) => 1.0 - (i * 0.01)),
  );

  final sampleSummary = LearningProgressSummary(
    totalSrsCards: 20,
    dueSrsCards: 3,
    newCards: 2,
    learningCards: 4,
    reviewCards: 14,
    relearningCards: 0,
    totalSrsReviews: 45,
    currentStreakDays: 5,
    activeTodayCount: 8,
    grammarAttempts: 10,
    grammarCorrect: 9,
    binyanStats: const [],
    listeningAttempts: 5,
    listeningExactMatches: 4,
    averageListeningAccuracy: 0.9,
    fsrsAnalytics: sampleAnalytics,
  );

  group('FsrsMemoryDashboardCard Widget Tests', () {
    testWidgets('renders overview tab with key metrics and allows tab switching',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: FsrsMemoryDashboardCard(summary: sampleSummary),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Header verification
      expect(find.text('Память FSRS-4.5'), findsOneWidget);
      expect(find.text('Всего в колоде: 20 карточек'), findsOneWidget);
      expect(find.text('94%'), findsOneWidget); // 0.935 rounded

      // Overview metrics
      expect(find.text('К повторению'), findsOneWidget);
      expect(find.text('Стабильность S'), findsOneWidget);
      expect(find.text('16.4 дн'), findsOneWidget);
      expect(find.text('Успешность'), findsOneWidget);
      expect(find.text('89%'), findsOneWidget);

      // Switch to 'Кривая R(t)' tab
      await tester.tap(find.text('Кривая R(t)'));
      await tester.pumpAndSettle();
      expect(find.byType(FsrsRetentionChart), findsOneWidget);

      // Switch to 'Прогноз' tab
      await tester.tap(find.text('Прогноз'));
      await tester.pumpAndSettle();
      expect(find.byType(FsrsReviewForecastChart), findsOneWidget);

      // Switch to 'Матрица' tab
      await tester.tap(find.text('Матрица'));
      await tester.pumpAndSettle();
      expect(find.byType(FsrsStabilityMatrixWidget), findsOneWidget);
      expect(find.byType(FsrsDifficultyDistributionWidget), findsOneWidget);
    });
  });
}
