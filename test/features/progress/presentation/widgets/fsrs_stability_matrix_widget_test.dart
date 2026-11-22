import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/progress/presentation/widgets/fsrs_stability_matrix_widget.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/fsrs_analytics_data.dart';

void main() {
  group('FsrsStabilityMatrixWidget Widget Tests', () {
    testWidgets('renders all four stability tiers with counts and durations',
        (tester) async {
      const tiers = {
        FsrsStabilityTier.shortTerm: 5,
        FsrsStabilityTier.mediumTerm: 12,
        FsrsStabilityTier.longTerm: 25,
        FsrsStabilityTier.permanent: 8,
      };

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FsrsStabilityMatrixWidget(
              cardsByStabilityTier: tiers,
              totalCards: 50,
            ),
          ),
        ),
      );

      expect(find.text('Краткосрочные'), findsOneWidget);
      expect(find.text('5 слов'), findsOneWidget);
      expect(find.text('Среднесрочные'), findsOneWidget);
      expect(find.text('12 слов'), findsOneWidget);
      expect(find.text('Долгосрочные'), findsOneWidget);
      expect(find.text('25 слов'), findsOneWidget);
      expect(find.text('Перманентные'), findsOneWidget);
      expect(find.text('8 слов'), findsOneWidget);
    });
  });
}
