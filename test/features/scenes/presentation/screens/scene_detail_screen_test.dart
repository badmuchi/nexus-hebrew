import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/audio/audio_playback_service.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/scenes/data/repositories/scenes_repository_impl.dart';
import 'package:nexus_hebrew_app/features/scenes/domain/entities/israeli_life_scene.dart';
import 'package:nexus_hebrew_app/features/scenes/presentation/screens/scene_detail_screen.dart';
import 'package:nexus_hebrew_app/features/scenes/presentation/widgets/scene_challenge_card.dart';
import 'package:nexus_hebrew_app/features/scenes/presentation/widgets/scene_phrase_tile.dart';
import 'package:nexus_hebrew_app/features/scenes/presentation/widgets/scene_word_card.dart';
import 'package:nexus_hebrew_app/features/srs/domain/usecases/add_card_to_srs.dart';

class _MockAudioPlaybackService extends Mock implements AudioPlaybackService {}
class _MockAddCardToSrsUseCase extends Mock implements AddCardToSrsUseCase {}

void main() {
  late _MockAudioPlaybackService audioService;
  late _MockAddCardToSrsUseCase addSrsUseCase;
  late ScenesRepositoryImpl repository;

  const testScene = IsraeliLifeScene(
    id: 'test_market',
    type: SceneType.supermarket,
    titleHebrew: 'בַּסּוּפֶּרְמַרְקֶט',
    titleRussian: 'Тестовый супермаркет',
    description: 'Тренировка покупок в магазине.',
    emoji: '🛒',
    cefrLevel: 'A1-A2',
    cultureLifehack: 'Не забудьте монетку 5 шекелей для тележки!',
    words: [
      SceneWord(
        id: 'tw_1',
        hebrewVocalized: 'קֻפָּה',
        hebrewNormalized: 'קופה',
        transliteration: 'kupa',
        russianMeaning: 'касса',
      ),
      SceneWord(
        id: 'tw_2',
        hebrewVocalized: 'עֲגָלָה',
        hebrewNormalized: 'עגלה',
        transliteration: 'agala',
        russianMeaning: 'тележка',
      ),
    ],
    phrases: [
      ScenePhrase(
        id: 'tp_1',
        role: PhraseRole.theySay,
        hebrewVocalized: 'רוֹצֶה שַׂקִּיּוֹת?',
        hebrewNormalized: 'רוצה שקיות?',
        transliteration: 'rotze sakiyot?',
        russianTranslation: 'Нужны пакеты?',
      ),
      ScenePhrase(
        id: 'tp_2',
        role: PhraseRole.youSay,
        hebrewVocalized: 'שְׁתַּיִם בְּבַקָּשָׁה',
        hebrewNormalized: 'שתים בבקשה',
        transliteration: 'shtayim bevakasha',
        russianTranslation: 'Два, пожалуйста',
      ),
    ],
    challenges: [
      SceneChallenge(
        id: 'tc_1',
        situationRu: 'Кассир спрашивает про пакеты.',
        promptHebrew: 'רוֹצֶה שַׂקִּיּוֹת?',
        options: [
          'כֵּן, אַחַת בְּבַקָּשָׁה (Да, один, пожалуйста)',
          'לֹא, תּוֹדָה (Нет, спасибо)',
          'אֵיפֹה הַבַּנְבּוּק? (Где бамбук?)',
        ],
        correctIndex: 0,
        explanationRu: '«Кен, ахат бевакаша» — стандартный вежливый ответ.',
      ),
    ],
  );

  setUpAll(() {
    registerFallbackValue(
      const AddCardToSrsParams(
        id: 'fallback',
        hebrewVocalized: 'מִלָּה',
        russianTranslation: 'слово',
      ),
    );
  });

  setUp(() {
    audioService = _MockAudioPlaybackService();
    addSrsUseCase = _MockAddCardToSrsUseCase();
    repository = ScenesRepositoryImpl();

    when(() => audioService.playWithTtsFallback(
      sourcePath: any(named: 'sourcePath'),
      fallbackHebrewText: any(named: 'fallbackHebrewText'),
    )).thenAnswer((_) async => const Success(null));

    when(() => addSrsUseCase.call(any()))
        .thenAnswer((_) async => const Success(true));
  });

  Widget buildDetailWidget({VoidCallback? onCompleted}) {
    return MaterialApp(
      home: SceneDetailScreen(
        scene: testScene,
        repository: repository,
        audioService: audioService,
        addCardToSrsUseCase: addSrsUseCase,
        onSceneCompleted: onCompleted,
      ),
    );
  }

  group('SceneDetailScreen', () {
    testWidgets('renders tabs, words, phrases, and handles audio & FSRS', (tester) async {
      await tester.pumpWidget(buildDetailWidget());
      await tester.pumpAndSettle();

      expect(find.text('Тестовый супермаркет'), findsOneWidget);

      // Verify Words Tab is active by default
      expect(find.byType(SceneWordCard), findsNWidgets(2));
      expect(find.text('касса'), findsOneWidget);
      expect(find.text('тележка'), findsOneWidget);

      // Test Audio Playback on first word card
      final audioButtons = find.byIcon(Icons.volume_up_rounded);
      expect(audioButtons, findsWidgets);
      await tester.tap(audioButtons.first);
      await tester.pump();
      verify(() => audioService.playWithTtsFallback(
        sourcePath: any(named: 'sourcePath'),
        fallbackHebrewText: any(named: 'fallbackHebrewText'),
      )).called(1);

      // Test Add to FSRS on word card
      final srsButtons = find.byIcon(Icons.bookmark_add_outlined);
      expect(srsButtons, findsWidgets);
      await tester.tap(srsButtons.first);
      await tester.pumpAndSettle();
      verify(() => addSrsUseCase.call(any())).called(1);
      expect(find.textContaining('добавлено в FSRS'), findsOneWidget);

      // Switch to Phrases Tab
      await tester.tap(find.textContaining('Фразы'));
      await tester.pumpAndSettle();

      expect(find.byType(ScenePhraseTile), findsNWidgets(2));
      expect(find.text('Вам скажут 👂'), findsOneWidget);
      expect(find.text('Вы ответите 🗣️'), findsOneWidget);
      expect(find.text('Нужны пакеты?'), findsOneWidget);
      expect(find.text('Два, пожалуйста'), findsOneWidget);

      // Switch to Lifehack Tab
      await tester.tap(find.textContaining('Лайфхак'));
      await tester.pumpAndSettle();

      expect(find.text('Израильский культурный лайфхак'), findsOneWidget);
      expect(find.textContaining('монетку 5 шекелей'), findsOneWidget);
    });

    testWidgets('Nikkud toggle changes display state', (tester) async {
      await tester.pumpWidget(buildDetailWidget());
      await tester.pumpAndSettle();

      expect(find.text('קֻפָּה'), findsOneWidget);

      // Tap Nikkud toggle in AppBar
      final nikkudToggle = find.byTooltip('Огласовки включены');
      expect(nikkudToggle, findsOneWidget);
      await tester.tap(nikkudToggle);
      await tester.pumpAndSettle();

      // Vocalized form should be replaced with normalized form 'קופה'
      expect(find.text('קופה'), findsOneWidget);
    });

    testWidgets('Challenge simulation evaluates answers and records progress', (tester) async {
      var completedCalled = false;
      await tester.pumpWidget(buildDetailWidget(onCompleted: () => completedCalled = true));
      await tester.pumpAndSettle();

      // Switch to Simulator / Situations Tab
      await tester.tap(find.textContaining('Ситуации'));
      await tester.pumpAndSettle();

      expect(find.byType(SceneChallengeCard), findsOneWidget);
      expect(find.text('Кассир спрашивает про пакеты.'), findsOneWidget);

      // Tap correct option
      final correctOption = find.text('כֵּן, אַחַת בְּבַקָּשָׁה (Да, один, пожалуйста)');
      expect(correctOption, findsOneWidget);
      await tester.tap(correctOption);
      await tester.pumpAndSettle();

      expect(find.text('Верно!'), findsOneWidget);
      expect(find.textContaining('стандартный вежливый ответ'), findsOneWidget);
      expect(find.textContaining('Локация успешно освоена!'), findsOneWidget);
      expect(completedCalled, isTrue);

      // Verify repository updated
      final completed = await repository.getCompletedSceneIds();
      expect(completed.getOrNull()?['test_market'], isTrue);
    });
  });
}
