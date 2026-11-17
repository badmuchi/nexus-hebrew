import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/audio/audio_playback_service.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/srs/presentation/screens/hands_free_player_screen.dart';

class _MockAudioPlaybackService extends Mock implements AudioPlaybackService {}

void main() {
  late _MockAudioPlaybackService audioService;
  late StreamController<AudioPlaybackEvent> audioEvents;

  final items = [
    const HandsFreeItem(
      id: 'item_1',
      hebrewVocalized: 'שָׁלוֹם',
      hebrewNormalized: 'שלום',
      russianTranslation: 'Мир / Привет',
      transliteration: 'shalom',
    ),
    const HandsFreeItem(
      id: 'item_2',
      hebrewVocalized: 'תּוֹדָה',
      hebrewNormalized: 'תודה',
      russianTranslation: 'Спасибо',
      transliteration: 'toda',
    ),
  ];

  setUp(() {
    audioService = _MockAudioPlaybackService();
    audioEvents = StreamController<AudioPlaybackEvent>.broadcast();

    when(() => audioService.statusStream).thenAnswer((_) => audioEvents.stream);
    when(() => audioService.stop())
        .thenAnswer((_) async => const Success(null));
    when(
      () => audioService.playWithTtsFallback(
        sourcePath: any(named: 'sourcePath'),
        fallbackHebrewText: any(named: 'fallbackHebrewText'),
      ),
    ).thenAnswer((_) async => const Success(null));
    when(() => audioService.setPlaybackSpeed(any()))
        .thenAnswer((_) async => const Success(null));
  });

  tearDown(() async {
    await audioEvents.close();
  });

  Widget createSubject({List<HandsFreeItem>? customItems}) {
    return MaterialApp(
      home: HandsFreePlayerScreen(
        items: customItems ?? items,
        audioService: audioService,
      ),
    );
  }

  testWidgets('Отображает первое слово и элементы управления плеером', (tester) async {
    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    expect(find.text('Иврит на ходу 🎧'), findsOneWidget);
    expect(find.text('שָׁלוֹם'), findsOneWidget);
    expect(find.text('shalom'), findsOneWidget);
    expect(find.text('Карточка 1 из 2'), findsOneWidget);
    expect(find.text('1.0x'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    expect(find.byIcon(Icons.skip_next_rounded), findsOneWidget);
  });

  testWidgets('Кнопка скорости переключает режимы 1.0x -> 0.8x -> 1.2x', (tester) async {
    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    final speedBtn = find.text('1.0x');
    await tester.tap(speedBtn);
    await tester.pumpAndSettle();
    expect(find.text('0.8x'), findsOneWidget);

    await tester.tap(find.text('0.8x'));
    await tester.pumpAndSettle();
    expect(find.text('1.2x'), findsOneWidget);

    verify(() => audioService.setPlaybackSpeed(any())).called(2);
  });

  testWidgets('Кнопка Next переключает на следующее слово', (tester) async {
    await tester.pumpWidget(createSubject());
    await tester.pumpAndSettle();

    final nextBtn = find.byIcon(Icons.skip_next_rounded);
    await tester.tap(nextBtn);
    await tester.pumpAndSettle();

    expect(find.text('תּוֹדָה'), findsOneWidget);
    expect(find.text('toda'), findsOneWidget);
    expect(find.text('Карточка 2 из 2'), findsOneWidget);
  });

  testWidgets('Отображает заглушку, если список слов пуст', (tester) async {
    await tester.pumpWidget(createSubject(customItems: const []));
    await tester.pumpAndSettle();

    expect(find.textContaining('Плейлист пуст'), findsOneWidget);
  });
}
