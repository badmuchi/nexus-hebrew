import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/audio/audio_playback_service.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/scenes/data/repositories/scenes_repository_impl.dart';
import 'package:nexus_hebrew_app/features/scenes/domain/repositories/scenes_repository.dart';
import 'package:nexus_hebrew_app/features/scenes/presentation/screens/scene_detail_screen.dart';
import 'package:nexus_hebrew_app/features/scenes/presentation/screens/scenes_catalog_screen.dart';
import 'package:nexus_hebrew_app/features/srs/domain/usecases/add_card_to_srs.dart';

class _MockAudioPlaybackService extends Mock implements AudioPlaybackService {}
class _MockAddCardToSrsUseCase extends Mock implements AddCardToSrsUseCase {}
class _MockScenesRepository extends Mock implements ScenesRepository {}

void main() {
  late _MockAudioPlaybackService audioService;
  late _MockAddCardToSrsUseCase addSrsUseCase;

  setUp(() {
    audioService = _MockAudioPlaybackService();
    addSrsUseCase = _MockAddCardToSrsUseCase();
  });

  Widget buildTestWidget({required ScenesRepository repository}) {
    return MaterialApp(
      home: ScenesCatalogScreen(
        repository: repository,
        audioService: audioService,
        addCardToSrsUseCase: addSrsUseCase,
      ),
    );
  }

  group('ScenesCatalogScreen', () {
    testWidgets('renders all 6 scene cards and header info', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repo = ScenesRepositoryImpl();

      await tester.pumpWidget(buildTestWidget(repository: repo));
      await tester.pumpAndSettle();

      expect(find.text('Реальный Израиль: Бытовые сцены'), findsOneWidget);
      expect(find.text('Живые ситуации Израиля'), findsOneWidget);

      // Check scene titles
      expect(find.text('Супермаркет и покупки'), findsOneWidget);
      expect(find.text('Автобус, поезд и Рав-Кав'), findsOneWidget);
      expect(find.text('Поликлиника и аптека'), findsOneWidget);
      expect(find.text('Кафе и заказ'), findsOneWidget);
      expect(find.text('Аренда жилья и коммуналка'), findsOneWidget);
      expect(find.text('МВД (Мисрад а-Пним) и Почта'), findsOneWidget);
    });

    testWidgets('displays completed badge for completed scenes', (tester) async {
      final repo = _MockScenesRepository();
      final defaultRepo = ScenesRepositoryImpl();
      final scenes = defaultRepo.getAllScenes();

      when(() => repo.getAllScenes()).thenReturn(scenes);
      when(() => repo.getCompletedSceneIds()).thenAnswer((_) async => const Success({
        'scene_supermarket': true,
      }));

      await tester.pumpWidget(buildTestWidget(repository: repo));
      await tester.pumpAndSettle();

      expect(find.text('Пройдено'), findsOneWidget);
      expect(find.textContaining('1 из 6'), findsOneWidget);
    });

    testWidgets('tapping a scene card navigates to SceneDetailScreen', (tester) async {
      final repo = ScenesRepositoryImpl();

      await tester.pumpWidget(buildTestWidget(repository: repo));
      await tester.pumpAndSettle();

      final supermarketCard = find.text('Супермаркет и покупки');
      expect(supermarketCard, findsOneWidget);

      await tester.tap(supermarketCard);
      await tester.pumpAndSettle();

      expect(find.byType(SceneDetailScreen), findsOneWidget);
      expect(find.textContaining('Словарь'), findsOneWidget);
      expect(find.textContaining('Фразы'), findsOneWidget);
      expect(find.textContaining('Ситуации'), findsOneWidget);
      expect(find.textContaining('Лайфхак'), findsOneWidget);
    });
  });
}
