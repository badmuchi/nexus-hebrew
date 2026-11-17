import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/features/listening/data/datasources/minimal_pairs_seed_data.dart';
import 'package:nexus_hebrew_app/features/listening/presentation/widgets/minimal_pairs_view.dart';

void main() {
  Widget createTestWidget() {
    return const MaterialApp(
      home: Scaffold(
        body: MinimalPairsView(),
      ),
    );
  }

  group('MinimalPairsView', () {
    testWidgets('renders category chips, audio player, and choice cards',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Все звуки'), findsOneWidget);
      expect(find.text('Слушайте произношение слова:'), findsOneWidget);
      expect(find.byKey(const Key('play_audio_hero_button')), findsOneWidget);
      expect(find.text('Какое слово прозвучало?'), findsOneWidget);

      final firstEx = MinimalPairsSeedData.allExercises.first;
      expect(find.byKey(Key('choice_card_${firstEx.targetWord.id}')), findsOneWidget);
      expect(find.byKey(Key('choice_card_${firstEx.contrastWord.id}')), findsOneWidget);
    });

    testWidgets('answering exercise shows feedback card and comparison rows',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final firstEx = MinimalPairsSeedData.allExercises.first;

      // Select target card
      final targetCard = find.byKey(Key('choice_card_${firstEx.targetWord.id}'));
      await tester.ensureVisible(targetCard);
      await tester.tap(targetCard);
      await tester.pumpAndSettle();

      // Feedback is now visible
      expect(find.text('Точно! Вы безошибочно распознали слово'), findsOneWidget);
      expect(find.text('Сравнение слов лицом к лицу:'), findsOneWidget);
      expect(find.byKey(const Key('next_minimal_pair_button')), findsOneWidget);
    });

    testWidgets('category chip filters minimal pair exercises', (tester) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap on 'Род на слух: м.р. vs ж.р.'
      final genderChip = find.text('Род на слух: м.р. vs ж.р.');
      await tester.ensureVisible(genderChip);
      await tester.tap(genderChip);
      await tester.pumpAndSettle();

      expect(find.textContaining('ג-ו-ר'), findsWidgets);
      expect(find.text('גָּר'), findsOneWidget);
    });
  });
}
