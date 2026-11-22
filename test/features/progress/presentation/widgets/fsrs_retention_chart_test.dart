import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/progress/presentation/widgets/fsrs_retention_chart.dart';

void main() {
  group('FsrsRetentionChart Widget Tests', () {
    testWidgets('renders curve header, current retention badge and x-axis labels',
        (tester) async {
      final points = List.generate(31, (i) => 1.0 - (i * 0.01));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FsrsRetentionChart(
              averageStabilityDays: 14.5,
              currentRetentionRate: 0.924,
              retentionCurvePoints: points,
            ),
          ),
        ),
      );

      expect(find.text('Кривая забывания R(t)'), findsOneWidget);
      expect(find.text('Текущее удержание: 92.4%'), findsOneWidget);
      expect(find.text('День 0 (100%)'), findsOneWidget);
      expect(find.text('День 10'), findsOneWidget);
      expect(find.text('День 20'), findsOneWidget);
      expect(find.text('День 30'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });
}
