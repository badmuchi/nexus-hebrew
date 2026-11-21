import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/audio/audio_playback_service.dart';
import 'package:nexus_hebrew_app/core/error/failures.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/core/settings/app_settings_storage.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/binyan.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/hebrew_text.dart';
import 'package:nexus_hebrew_app/features/grammar/domain/entities/verb_conjugation.dart';
import 'package:nexus_hebrew_app/features/listening/domain/entities/listening_exercise.dart';
import 'package:nexus_hebrew_app/features/progress/domain/entities/daily_workout_plan.dart';
import 'package:nexus_hebrew_app/features/progress/domain/usecases/complete_daily_workout.dart';
import 'package:nexus_hebrew_app/features/progress/presentation/screens/daily_workout_screen.dart';
import 'package:nexus_hebrew_app/features/scenes/domain/entities/israeli_life_scene.dart';
import 'package:nexus_hebrew_app/features/shoresh/domain/entities/shoresh_entity.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/fsrs_models.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/srs_card.dart';

class _MockAppSettingsStorage extends Mock implements AppSettingsStorage {}
class _MockAudioPlaybackService extends Mock implements AudioPlaybackService {}

void main() {
  late _MockAppSettingsStorage settingsStorage;
  late _MockAudioPlaybackService audioService;
  late CompleteDailyWorkoutUseCase completeUseCase;

  final testCard = SrsCard(
    id: 'card-1',
    hebrew: const HebrewText.fixture(vocalized: 'שָׁלוֹם', normalized: 'שלום'),
    russianTranslation: 'Привет, мир',
    memory: FsrsMemoryState.initial(now: DateTime.utc(2026, 1, 1)),
    attribution: const ContentAttribution(sourceName: 'Seed', licenseName: 'CC-BY'),
  );

  final testVerb = VerbLexeme(
    id: 'verb-1',
    lemma: const HebrewText.fixture(vocalized: 'כָּתַב', normalized: 'כתб'),
    infinitive: const HebrewText.fixture(vocalized: 'לִכְתֹּב', normalized: 'לכתוב'),
    root: const Shoresh.fixture(['כ', 'ת', 'ב']),
    binyan: Binyan.paal,
    russianMeaning: 'писать',
    grammarNotesRu: '',
    conjugations: const [
      ConjugatedForm(
        tense: VerbTense.past,
        person: GrammaticalPerson.firstSingular,
        form: HebrewText.fixture(vocalized: 'כָּתַבְתִּי', normalized: 'כתבתי'),
        transliteration: 'katavti',
      ),
    ],
    attribution: const ContentAttribution(sourceName: 'Seed', licenseName: 'CC-BY'),
  );

  final testExercise = ListeningExercise(
    id: 'ex-1',
    transcript: const HebrewText.fixture(vocalized: 'בֹּקֶר טוֹב', normalized: 'בוקר טוב'),
    russianTranslation: 'Доброе утро',
    difficulty: ListeningDifficulty.beginner,
    focusWords: const ['בוקר'],
    attribution: const ContentAttribution(sourceName: 'Seed', licenseName: 'CC-BY'),
  );

  final testPlan = DailyWorkoutPlan(
    date: DateTime.utc(2026, 11, 16),
    cards: [testCard],
    grammarChallenge: DailyGrammarChallenge(
      verb: testVerb,
      targetForm: testVerb.conjugations.first,
      distractors: const ['כָּתַב', 'כָּתְבוּ'],
    ),
    listeningExercise: testExercise,
    isCompletedToday: false,
  );

  final testPlan5Steps = DailyWorkoutPlan(
    date: DateTime.utc(2026, 11, 16),
    cards: [testCard],
    grammarChallenge: DailyGrammarChallenge(
      verb: testVerb,
      targetForm: testVerb.conjugations.first,
      distractors: const ['כָּתַב', 'כָּתְבוּ'],
    ),
    listeningExercise: testExercise,
    shoreshChallenge: const ShoreshQuizQuestion(
      id: 'quiz-1',
      wordVocalized: 'מִכְתָּב',
      wordNormalized: 'מכתב',
      wordTranslation: 'письмо',
      correctRootLetters: ['כ', 'ת', 'ב'],
      options: ['כ-ת-ב', 'ס-פ-ר', 'ל-מ-ד'],
      correctIndex: 0,
      affixesExplanationRu: 'מכתב происходит от корня כ-ת-ב',
    ),
    sceneChallenge: const SceneChallenge(
      id: 'sc-1',
      situationRu: 'Бариста спрашивает о молоке',
      promptHebrew: 'איזה חלב לשים לך?',
      options: ['חלב סויה בבקשה', 'לא יודע', 'תודה'],
      correctIndex: 0,
      explanationRu: 'Вежливый ответ в кофейне',
    ),
    isCompletedToday: false,
  );

  setUp(() {
    settingsStorage = _MockAppSettingsStorage();
    audioService = _MockAudioPlaybackService();
    completeUseCase = CompleteDailyWorkoutUseCase(settingsStorage: settingsStorage);

    when(() => settingsStorage.writeLastDailyWorkoutDate(any()))
        .thenAnswer((_) async {});
    when(() => audioService.playWithTtsFallback(
          sourcePath: any(named: 'sourcePath'),
          fallbackHebrewText: any(named: 'fallbackHebrewText'),
        )).thenAnswer((_) async => const Success<void, Failure>(null));
  });

  Widget createSubject(DailyWorkoutPlan plan) {
    return MaterialApp(
      home: DailyWorkoutScreen(
        plan: plan,
        completeUseCase: completeUseCase,
        audioService: audioService,
      ),
    );
  }

  group('DailyWorkoutScreen', () {
    testWidgets('проходит все 3 шага тренировки и отображает финал с +50 XP', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createSubject(testPlan));
      await tester.pumpAndSettle();

      // ШАГ 1: FSRS-экспресс
      expect(find.textContaining('FSRS-ЭКСПРЕСС'), findsOneWidget);
      expect(find.text('שָׁלוֹם'), findsOneWidget);

      // Переворачиваем карточку
      await tester.tap(find.text('Показать перевод'));
      await tester.pumpAndSettle();
      expect(find.text('Привет, мир'), findsOneWidget);

      // Оцениваем карточку как "Хорошо"
      await tester.tap(find.text('Хорошо'));
      await tester.pumpAndSettle();

      // ШАГ 2: Грамматический блиц
      expect(find.textContaining('ГРАММАТИЧЕСКИЙ БЛИЦ'), findsOneWidget);
      expect(find.text('Значение: писать'), findsOneWidget);
      expect(find.text('כָּתַבְתִּי'), findsOneWidget);

      // Выбираем правильный ответ
      await tester.tap(find.text('כָּתַבְתִּי'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // ШАГ 3: Аудио-челлендж
      expect(find.textContaining('АУДИО-ЧЕЛЛЕНДЖ'), findsOneWidget);
      expect(find.text('Прослушай фразу на иврите'), findsOneWidget);

      // Проверяем понимание
      await tester.tap(find.text('Проверить понимание'));
      await tester.pumpAndSettle();
      expect(find.text('בֹּקֶר טוֹב'), findsOneWidget);
      expect(find.text('Доброе утро'), findsOneWidget);

      // Завершаем тренировку
      await tester.tap(find.text('Завершить тренировку дня'));
      await tester.pumpAndSettle();

      // Финальный экран
      expect(find.text('Тренировка дня завершена! 🎉'), findsOneWidget);
      expect(find.text('+50 XP НАЧИСЛЕНО 🏅'), findsOneWidget);
      expect(find.text('Отлично, к прогрессу!'), findsOneWidget);

      // Проверяем, что завершение сохранилось
      verify(() => settingsStorage.writeLastDailyWorkoutDate(any())).called(1);
    });

    testWidgets('проходит все 5 шагов тренировки 2.0 (включая шореш и сцену) до победного финала', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createSubject(testPlan5Steps));
      await tester.pumpAndSettle();

      // ШАГ 1: FSRS-экспресс
      expect(find.textContaining('FSRS-ЭКСПРЕСС'), findsOneWidget);
      await tester.tap(find.text('Показать перевод'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Хорошо'));
      await tester.pumpAndSettle();

      // ШАГ 2: Грамматический блиц
      expect(find.textContaining('ГРАММАТИЧЕСКИЙ БЛИЦ'), findsOneWidget);
      await tester.tap(find.text('כָּתַבְתִּי'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // ШАГ 3: Аудио-челлендж
      expect(find.textContaining('АУДИО-ЧЕЛЛЕНДЖ'), findsOneWidget);
      await tester.tap(find.text('Проверить понимание'));
      await tester.pumpAndSettle();
      expect(find.text('Следующий шаг'), findsOneWidget);
      await tester.tap(find.text('Следующий шаг'));
      await tester.pumpAndSettle();

      // ШАГ 4: Шореш дня
      expect(find.textContaining('ШОРЕШ ДНЯ: РАСКРОЙ КОРЕНЬ'), findsOneWidget);
      expect(find.text('מִכְתָּב'), findsOneWidget);
      expect(find.text('כ-ת-ב'), findsOneWidget);
      await tester.tap(find.text('כ-ת-ב'));
      await tester.pumpAndSettle();
      expect(find.text('מכתב происходит от корня כ-ת-ב'), findsOneWidget);
      expect(find.text('Следующий шаг'), findsOneWidget);
      await tester.tap(find.text('Следующий шаг'));
      await tester.pumpAndSettle();

      // ШАГ 5: Ситуация дня
      expect(find.textContaining('РЕАЛЬНЫЙ ИЗРАИЛЬ: СИТУАЦИЯ ДНЯ'), findsOneWidget);
      expect(find.text('Бариста спрашивает о молоке'), findsOneWidget);
      expect(find.text('חלב סויה בבקשה'), findsOneWidget);
      await tester.tap(find.text('חלב סויה בבקשה'));
      await tester.pumpAndSettle();
      expect(find.text('Вежливый ответ в кофейне'), findsOneWidget);
      expect(find.text('Завершить тренировку дня'), findsOneWidget);
      await tester.tap(find.text('Завершить тренировку дня'));
      await tester.pumpAndSettle();

      // Финальный экран
      expect(find.text('Тренировка дня завершена! 🎉'), findsOneWidget);
      expect(find.text('+50 XP НАЧИСЛЕНО 🏅'), findsOneWidget);
      expect(find.text('Отлично, к прогрессу!'), findsOneWidget);
      verify(() => settingsStorage.writeLastDailyWorkoutDate(any())).called(1);
    });
  });
}
