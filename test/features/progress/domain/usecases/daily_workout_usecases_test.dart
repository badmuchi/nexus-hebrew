import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/core/settings/app_settings_storage.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/binyan.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/hebrew_text.dart';
import 'package:nexus_hebrew_app/features/grammar/domain/entities/verb_conjugation.dart';
import 'package:nexus_hebrew_app/features/grammar/domain/repositories/grammar_repository.dart';
import 'package:nexus_hebrew_app/features/listening/domain/entities/listening_exercise.dart';
import 'package:nexus_hebrew_app/features/listening/domain/repositories/listening_repository.dart';
import 'package:nexus_hebrew_app/features/progress/domain/usecases/complete_daily_workout.dart';
import 'package:nexus_hebrew_app/features/progress/domain/usecases/get_daily_workout.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/fsrs_models.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/srs_card.dart';
import 'package:nexus_hebrew_app/features/srs/domain/repositories/srs_repository.dart';

class _MockSrsRepository extends Mock implements SrsRepository {}
class _MockGrammarRepository extends Mock implements GrammarRepository {}
class _MockListeningRepository extends Mock implements ListeningRepository {}
class _MockAppSettingsStorage extends Mock implements AppSettingsStorage {}

void main() {
  late _MockSrsRepository srsRepo;
  late _MockGrammarRepository grammarRepo;
  late _MockListeningRepository listeningRepo;
  late _MockAppSettingsStorage settingsStorage;
  late GetDailyWorkoutUseCase getUseCase;
  late CompleteDailyWorkoutUseCase completeUseCase;

  final testCard = SrsCard(
    id: 'card-1',
    hebrew: const HebrewText.fixture(vocalized: 'שָׁלוֹם', normalized: 'שלום'),
    russianTranslation: 'Привет',
    memory: FsrsMemoryState.initial(now: DateTime.utc(2026, 1, 1)),
    attribution: const ContentAttribution(sourceName: 'Seed', licenseName: 'CC-BY'),
  );

  final testVerb = VerbLexeme(
    id: 'verb-1',
    lemma: const HebrewText.fixture(vocalized: 'כָּתַב', normalized: 'כתב'),
    infinitive: const HebrewText.fixture(vocalized: 'לִכְתֹּב', normalized: 'לכתוב'),
    root: const Shoresh.fixture(['כ', 'ת', 'ב']),
    binyan: Binyan.paal,
    russianMeaning: 'писать',
    grammarNotesRu: '',
    conjugations: const [
      ConjugatedForm(
        tense: VerbTense.past,
        person: GrammaticalPerson.thirdMasculineSingular,
        form: HebrewText.fixture(vocalized: 'כָּתַב', normalized: 'כתב'),
        transliteration: 'katav',
      ),
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

  setUp(() {
    srsRepo = _MockSrsRepository();
    grammarRepo = _MockGrammarRepository();
    listeningRepo = _MockListeningRepository();
    settingsStorage = _MockAppSettingsStorage();

    when(() => settingsStorage.readAssessedLevel())
        .thenAnswer((_) async => null);

    getUseCase = GetDailyWorkoutUseCase(
      srsRepository: srsRepo,
      grammarRepository: grammarRepo,
      listeningRepository: listeningRepo,
      settingsStorage: settingsStorage,
    );

    completeUseCase = CompleteDailyWorkoutUseCase(
      settingsStorage: settingsStorage,
    );
  });

  group('Daily Workout UseCases', () {
    test('собирает карточки, грамматику, аудирование, корни и сцены в единый план 2.0', () async {
      when(() => settingsStorage.readLastDailyWorkoutDate())
          .thenAnswer((_) async => null);
      when(() => srsRepo.getDueCards(asOf: any(named: 'asOf'), limit: any(named: 'limit')))
          .thenAnswer((_) async => Success([testCard]));
      when(() => grammarRepo.getVerbs(binyan: any(named: 'binyan')))
          .thenAnswer((_) async => Success([testVerb]));
      when(() => listeningRepo.getExercises())
          .thenAnswer((_) async => Success([testExercise]));

      final result = await getUseCase();
      expect(result.isSuccess, isTrue);

      final plan = result.getOrNull()!;
      expect(plan.isCompletedToday, isFalse);
      expect(plan.cards.length, equals(1));
      expect(plan.grammarChallenge, isNotNull);
      expect(plan.grammarChallenge!.verb.id, equals('verb-1'));
      expect(plan.listeningExercise, isNotNull);
      expect(plan.shoreshChallenge, isNotNull);
      expect(plan.sceneChallenge, isNotNull);
      expect(plan.totalSteps, equals(5));
      expect(plan.bonusXp, equals(50));
    });

    test('определяет, если тренировка уже была выполнена сегодня', () async {
      final now = DateTime.utc(2026, 11, 16, 12, 0);
      when(() => settingsStorage.readLastDailyWorkoutDate())
          .thenAnswer((_) async => DateTime.utc(2026, 11, 16, 8, 30));
      when(() => srsRepo.getDueCards(asOf: any(named: 'asOf'), limit: any(named: 'limit')))
          .thenAnswer((_) async => Success([testCard]));
      when(() => grammarRepo.getVerbs(binyan: any(named: 'binyan')))
          .thenAnswer((_) async => Success([testVerb]));
      when(() => listeningRepo.getExercises())
          .thenAnswer((_) async => Success([testExercise]));

      final result = await getUseCase(asOf: now);
      expect(result.getOrNull()!.isCompletedToday, isTrue);
    });

    test('адаптирует подборку биньяна и сцен под уровень A2+ / B1', () async {
      when(() => settingsStorage.readLastDailyWorkoutDate())
          .thenAnswer((_) async => null);
      when(() => settingsStorage.readAssessedLevel())
          .thenAnswer((_) async => 'A2.1');
      when(() => srsRepo.getDueCards(asOf: any(named: 'asOf'), limit: any(named: 'limit')))
          .thenAnswer((_) async => Success([testCard]));
      when(() => grammarRepo.getVerbs(binyan: any(named: 'binyan')))
          .thenAnswer((_) async => Success([testVerb]));
      when(() => listeningRepo.getExercises())
          .thenAnswer((_) async => Success([testExercise]));

      final result = await getUseCase();
      expect(result.isSuccess, isTrue);

      final plan = result.getOrNull()!;
      expect(plan.sceneChallenge, isNotNull);
      expect(plan.grammarChallenge, isNotNull);
    });

    test('CompleteDailyWorkoutUseCase сохраняет дату завершения в хранилище', () async {
      when(() => settingsStorage.writeLastDailyWorkoutDate(any()))
          .thenAnswer((_) async {});

      final completedAt = DateTime.utc(2026, 11, 16, 15, 0);
      final res = await completeUseCase(completedAt: completedAt);

      expect(res.isSuccess, isTrue);
      verify(() => settingsStorage.writeLastDailyWorkoutDate(completedAt)).called(1);
    });
  });
}
