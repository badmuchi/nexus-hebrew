import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/gamification/presentation/widgets/memory_stability_badges_section.dart';
import 'package:nexus_hebrew_app/features/progress/domain/entities/learning_progress_summary.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/fsrs_analytics_data.dart';

void main() {
  const sampleAnalytics = FsrsAnalyticsData(
    totalCards: 20,
    unlearnedCards: 2,
    cardsByStabilityTier: {
      FsrsStabilityTier.unlearned: 2,
      FsrsStabilityTier.shortTerm: 4,
      FsrsStabilityTier.mediumTerm: 8,
      FsrsStabilityTier.longTerm: 4,
      FsrsStabilityTier.permanent: 2,
    },
    cardsByDifficultyTier: {
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
    forecastDays: [],
    retentionCurvePoints: [],
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

  group('MemoryStabilityBadgesSection Widget Tests', () {
    testWidgets('renders badges title and opens detail dialog on tap',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MemoryStabilityBadgesSection(summary: sampleSummary),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Бейджи стабильности FSRS'), findsOneWidget);
      expect(find.text('Железная память'), findsOneWidget);
      expect(find.text('Перманентный запас'), findsOneWidget);

      // Tap on Iron Memory badge
      await tester.tap(find.text('Железная память'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('זִכָּרוֹן בַּרְזֶל'), findsOneWidget);
      expect(find.text('Понятно'), findsOneWidget);

      await tester.tap(find.text('Понятно'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });
  });
}
