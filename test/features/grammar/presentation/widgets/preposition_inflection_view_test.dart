import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/audio/audio_playback_service.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/grammar/presentation/widgets/preposition_inflection_view.dart';
import 'package:nexus_hebrew_app/features/srs/domain/usecases/add_card_to_srs.dart';

class _MockAudioPlaybackService extends Mock implements AudioPlaybackService {}

class _MockAddCardToSrsUseCase extends Mock implements AddCardToSrsUseCase {}

void main() {
  late _MockAudioPlaybackService audioService;
  late _MockAddCardToSrsUseCase addCardToSrsUseCase;

  setUp(() {
    audioService = _MockAudioPlaybackService();
    addCardToSrsUseCase = _MockAddCardToSrsUseCase();

    when(
      () => audioService.playWithTtsFallback(
        sourcePath: any(named: 'sourcePath'),
        fallbackHebrewText: any(named: 'fallbackHebrewText'),
      ),
    ).thenAnswer((_) async => const Success(null));
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: Scaffold(
        body: PrepositionInflectionView(
          audioService: audioService,
          addCardToSrsUseCase: addCardToSrsUseCase,
        ),
      ),
    );
  }

  group('PrepositionInflectionView', () {
    testWidgets('renders prepositions chips and paradigm cards for shel',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Склонение предлогов (נְטִיָּה)'), findsOneWidget);
      expect(find.text('שֶׁל (Shel)'), findsOneWidget);
      expect(find.text('שֶׁלִּי'), findsOneWidget);
      expect(find.textContaining('Шели'), findsOneWidget);
      expect(find.textContaining('Мой / моя / моё'), findsOneWidget);
    });

    testWidgets('switches prepositions and updates paradigm', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap on preposition "לְ... (Le...)"
      final leChip = find.text('לְ... (Le...)');
      expect(leChip, findsOneWidget);

      await tester.tap(leChip);
      await tester.pumpAndSettle();

      expect(find.text('לִי'), findsOneWidget);
      expect(find.textContaining('Ли'), findsOneWidget);
      expect(find.textContaining('Мне / у меня'), findsOneWidget);
    });

    testWidgets('switches to drill mode and handles answer', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap on "Тренажер" filter chip
      final drillChip = find.text('Тренажер');
      expect(drillChip, findsOneWidget);

      await tester.tap(drillChip);
      await tester.pumpAndSettle();

      expect(find.text('Тренажер склонений'), findsOneWidget);
      expect(find.textContaining('Счёт: 0'), findsOneWidget);

      // Find first option
      final firstOption = find.byKey(const Key('drill_option_0'));
      expect(firstOption, findsOneWidget);
      await tester.ensureVisible(firstOption);
      await tester.tap(firstOption);
      await tester.pumpAndSettle();

      expect(find.text('Следующий вопрос'), findsOneWidget);
    });
  });
}
