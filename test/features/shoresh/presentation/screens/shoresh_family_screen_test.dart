import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/audio/audio_playback_service.dart';
import 'package:nexus_hebrew_app/features/shoresh/data/datasources/shoresh_seed_data.dart';
import 'package:nexus_hebrew_app/features/shoresh/presentation/bloc/shoresh_bloc.dart';
import 'package:nexus_hebrew_app/features/shoresh/presentation/bloc/shoresh_event.dart';
import 'package:nexus_hebrew_app/features/shoresh/presentation/bloc/shoresh_state.dart';
import 'package:nexus_hebrew_app/features/shoresh/presentation/screens/shoresh_detective_game_screen.dart';
import 'package:nexus_hebrew_app/features/shoresh/presentation/screens/shoresh_family_screen.dart';
import 'package:nexus_hebrew_app/features/srs/domain/usecases/add_card_to_srs.dart';

class _MockShoreshBloc extends Mock implements ShoreshBloc {}
class _MockAudioPlaybackService extends Mock implements AudioPlaybackService {}
class _MockAddCardToSrsUseCase extends Mock implements AddCardToSrsUseCase {}

void main() {
  late _MockShoreshBloc bloc;
  late _MockAudioPlaybackService audioService;
  late _MockAddCardToSrsUseCase addSrsUseCase;

  final testRoot = ShoreshSeedData.roots.first; // root_ktv

  setUp(() {
    bloc = _MockShoreshBloc();
    audioService = _MockAudioPlaybackService();
    addSrsUseCase = _MockAddCardToSrsUseCase();

    when(() => bloc.state).thenReturn(
      const ShoreshCatalogLoaded(
        allRoots: ShoreshSeedData.roots,
        filteredRoots: ShoreshSeedData.roots,
        categories: ['Культура и текст'],
        masteredRootIds: {},
        showNikkud: true,
      ),
    );
    when(() => bloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: BlocProvider<ShoreshBloc>.value(
        value: bloc,
        child: ShoreshFamilyScreen(
          root: testRoot,
          audioService: audioService,
          addCardToSrsUseCase: addSrsUseCase,
        ),
      ),
    );
  }

  group('ShoreshFamilyScreen', () {
    testWidgets('renders root banner, cultural notes, and derivatives', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Семья корня כ-ת-ב'), findsOneWidget);
      expect(find.text('Письмо, запись, книга'), findsOneWidget);
      expect(find.text(testRoot.culturalNoteRu), findsOneWidget);

      // Verify derivatives exist
      expect(find.text('כָּתַב'), findsOneWidget);
      expect(find.text('מִכְתָּב'), findsOneWidget);
      expect(find.text('כַּתָּב'), findsOneWidget);
      expect(find.text('כְּתֹבֶת'), findsOneWidget);
      expect(find.text('מִכְתָּבָה'), findsOneWidget);

      // Verify action button
      expect(find.text('Тренировать корень в детектив-квизе'), findsOneWidget);
    });

    testWidgets('tapping toggle nikkud adds ToggleShoreshNikkudEvent to bloc', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final toggleBtn = find.byTooltip('Скрыть огласовки');
      expect(toggleBtn, findsOneWidget);
      await tester.tap(toggleBtn);
      await tester.pumpAndSettle();

      verify(() => bloc.add(const ToggleShoreshNikkudEvent())).called(1);
    });

    testWidgets('tapping train root opens ShoreshDetectiveGameScreen', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final trainBtn = find.text('Тренировать корень в детектив-квизе');
      await tester.tap(trainBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.byType(ShoreshDetectiveGameScreen), findsOneWidget);
    });
  });
}
