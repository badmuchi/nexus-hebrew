import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/audio/audio_playback_service.dart';
import 'package:nexus_hebrew_app/core/error/failures.dart';
import 'package:nexus_hebrew_app/core/logging/app_logger.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/binyan.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/hebrew_text.dart';
import 'package:nexus_hebrew_app/features/grammar/domain/entities/verb_conjugation.dart';
import 'package:nexus_hebrew_app/features/grammar/domain/usecases/check_verb_conjugation.dart';
import 'package:nexus_hebrew_app/features/grammar/domain/usecases/get_verbs_by_binyan.dart';
import 'package:nexus_hebrew_app/features/grammar/domain/usecases/record_grammar_practice.dart';
import 'package:nexus_hebrew_app/features/grammar/presentation/cubit/grammar_cubit.dart';
import 'package:nexus_hebrew_app/features/grammar/presentation/cubit/grammar_state.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/srs_card.dart';
import 'package:nexus_hebrew_app/features/srs/domain/usecases/add_card_to_srs.dart';

class _MockGetVerbsByBinyanUseCase extends Mock
    implements GetVerbsByBinyanUseCase {}

class _MockRecordGrammarPracticeUseCase extends Mock
    implements RecordGrammarPracticeUseCase {}

class _MockAddCardToSrsUseCase extends Mock implements AddCardToSrsUseCase {}

class _MockAudioPlaybackService extends Mock implements AudioPlaybackService {}

void main() {
  final fixedNow = DateTime.utc(2026, 11, 11, 21, 0);

  late _MockGetVerbsByBinyanUseCase getVerbsUseCase;
  late _MockRecordGrammarPracticeUseCase recordPracticeUseCase;
  late _MockAddCardToSrsUseCase addCardToSrsUseCase;
  late _MockAudioPlaybackService audioService;
  late StreamController<AudioPlaybackEvent> audioEvents;

  const presentForm = ConjugatedForm(
    tense: VerbTense.present,
    person: GrammaticalPerson.masculineSingular,
    form: HebrewText.fixture(vocalized: 'כּוֹתֵב', normalized: 'כותב'),
    transliteration: 'kotev',
  );
  const pastForm = ConjugatedForm(
    tense: VerbTense.past,
    person: GrammaticalPerson.firstSingular,
    form: HebrewText.fixture(vocalized: 'כָּתַבְתִּי', normalized: 'כתבתי'),
    transliteration: 'katavti',
  );

  final paalVerb = VerbLexeme(
    id: 'verb_paal_katav',
    lemma: const HebrewText.fixture(vocalized: 'כָּתַב', normalized: 'כתב'),
    infinitive:
        const HebrewText.fixture(vocalized: 'לִכְתֹּב', normalized: 'לכתוב'),
    root: const Shoresh.fixture(<String>['כ', 'ת', 'ב']),
    binyan: Binyan.paal,
    russianMeaning: 'писать',
    grammarNotesRu: 'Классический глагол',
    conjugations: const <ConjugatedForm>[presentForm, pastForm],
    attribution: const ContentAttribution(
      sourceName: 'Kaikki / Wiktionary',
      licenseName: 'CC BY-SA 4.0',
    ),
  );

  setUpAll(() {
    registerFallbackValue(const GetVerbsByBinyanParams());
    registerFallbackValue(
      RecordGrammarPracticeParams(
        verbId: 'verb_paal_katav',
        tense: VerbTense.present,
        person: GrammaticalPerson.masculineSingular,
        isCorrect: true,
        practicedAt: fixedNow,
      ),
    );
    registerFallbackValue(
      const AddCardToSrsParams(
        id: 'fallback',
        hebrewVocalized: 'לִכְתֹּב',
        russianTranslation: 'писать',
      ),
    );
  });

  setUp(() {
    getVerbsUseCase = _MockGetVerbsByBinyanUseCase();
    recordPracticeUseCase = _MockRecordGrammarPracticeUseCase();
    addCardToSrsUseCase = _MockAddCardToSrsUseCase();
    audioService = _MockAudioPlaybackService();
    audioEvents = StreamController<AudioPlaybackEvent>.broadcast();

    when(() => audioService.statusStream).thenAnswer((_) => audioEvents.stream);
    when(() => audioService.stop())
        .thenAnswer((_) async => const Success<void, Failure>(null));
    when(() => recordPracticeUseCase(any()))
        .thenAnswer((_) async => const Success<void, Failure>(null));
  });

  tearDown(() async {
    await audioEvents.close();
  });

  GrammarCubit buildCubit() => GrammarCubit(
        getVerbsUseCase: getVerbsUseCase,
        checkConjugationUseCase: const CheckVerbConjugationUseCase(),
        recordPracticeUseCase: recordPracticeUseCase,
        addCardToSrsUseCase: addCardToSrsUseCase,
        audioService: audioService,
        logger: const NoOpAppLogger(),
        clock: () => fixedNow,
      );

  group('GrammarCubit', () {
    blocTest<GrammarCubit, GrammarState>(
      'emits [GrammarLoading, GrammarLoaded] when loadVerbs succeeds',
      setUp: () {
        when(() => getVerbsUseCase(const GetVerbsByBinyanParams())).thenAnswer(
          (_) async =>
              Success<List<VerbLexeme>, Failure>(<VerbLexeme>[paalVerb]),
        );
      },
      build: buildCubit,
      act: (GrammarCubit cubit) => cubit.loadVerbs(),
      expect: () => <GrammarState>[
        const GrammarLoading(),
        GrammarLoaded(
          verbs: <VerbLexeme>[paalVerb],
          selectedVerb: paalVerb,
          drillPrompt: presentForm,
        ),
      ],
    );

    blocTest<GrammarCubit, GrammarState>(
      'emits [GrammarLoading, GrammarError] when loadVerbs fails',
      setUp: () {
        when(() => getVerbsUseCase(const GetVerbsByBinyanParams())).thenAnswer(
          (_) async => const Error<List<VerbLexeme>, Failure>(
            CacheFailure('Grammar seed missing'),
          ),
        );
      },
      build: buildCubit,
      act: (GrammarCubit cubit) => cubit.loadVerbs(),
      expect: () => <GrammarState>[
        const GrammarLoading(),
        const GrammarError(CacheFailure('Grammar seed missing')),
      ],
    );

    blocTest<GrammarCubit, GrammarState>(
      'evaluates typed conjugation drill and persists attempt log',
      setUp: () {
        when(() => getVerbsUseCase(const GetVerbsByBinyanParams())).thenAnswer(
          (_) async =>
              Success<List<VerbLexeme>, Failure>(<VerbLexeme>[paalVerb]),
        );
      },
      build: buildCubit,
      act: (GrammarCubit cubit) async {
        await cubit.loadVerbs();
        cubit.selectTense(VerbTense.past);
        await cubit.checkDrillAnswer('כתבתי');
      },
      expect: () => <GrammarState>[
        const GrammarLoading(),
        GrammarLoaded(
          verbs: <VerbLexeme>[paalVerb],
          selectedVerb: paalVerb,
          drillPrompt: presentForm,
        ),
        GrammarLoaded(
          verbs: <VerbLexeme>[paalVerb],
          selectedVerb: paalVerb,
          selectedTense: VerbTense.past,
          drillPrompt: pastForm,
        ),
        GrammarLoaded(
          verbs: <VerbLexeme>[paalVerb],
          selectedVerb: paalVerb,
          selectedTense: VerbTense.past,
          drillPrompt: pastForm,
          lastCheckResult: const ConjugationCheckResult(
            isCorrect: true,
            normalizedUserInput: 'כתבתי',
            normalizedExpected: 'כתבתי',
            expectedForm: HebrewText.fixture(
              vocalized: 'כָּתַבְתִּי',
              normalized: 'כתבתי',
            ),
            transliteration: 'katavti',
            tense: VerbTense.past,
            person: GrammaticalPerson.firstSingular,
          ),
        ),
      ],
      verify: (_) {
        verify(
          () => recordPracticeUseCase(
            RecordGrammarPracticeParams(
              verbId: 'verb_paal_katav',
              tense: VerbTense.past,
              person: GrammaticalPerson.firstSingular,
              isCorrect: true,
              practicedAt: fixedNow,
            ),
          ),
        ).called(1);
      },
    );

    blocTest<GrammarCubit, GrammarState>(
      'shows transientNotice on empty drill answer and tracks matching TTS audio events',
      setUp: () {
        when(() => getVerbsUseCase(const GetVerbsByBinyanParams())).thenAnswer(
          (_) async =>
              Success<List<VerbLexeme>, Failure>(<VerbLexeme>[paalVerb]),
        );
        when(
          () => audioService.playWithTtsFallback(
            sourcePath: null,
            fallbackHebrewText: 'כּוֹתֵב',
          ),
        ).thenAnswer((_) async {
          audioEvents.add(
            const AudioPlaybackEvent(
              status: AudioPlaybackStatus.playing,
              sourcePath: 'tts://he-IL/כּוֹתֵב',
            ),
          );
          return const Success<void, Failure>(null);
        });
      },
      build: buildCubit,
      act: (GrammarCubit cubit) async {
        await cubit.loadVerbs();
        await cubit.checkDrillAnswer('   ');
        await cubit.speakHebrew('כּוֹתֵב');
        audioEvents.add(
          const AudioPlaybackEvent(
            status: AudioPlaybackStatus.playing,
            sourcePath: 'tts://he-IL/אחר',
          ),
        );
      },
      expect: () => <GrammarState>[
        const GrammarLoading(),
        GrammarLoaded(
          verbs: <VerbLexeme>[paalVerb],
          selectedVerb: paalVerb,
          drillPrompt: presentForm,
        ),
        GrammarLoaded(
          verbs: <VerbLexeme>[paalVerb],
          selectedVerb: paalVerb,
          drillPrompt: presentForm,
          transientNotice: 'Введи форму глагола на иврите для проверки.',
        ),
        GrammarLoaded(
          verbs: <VerbLexeme>[paalVerb],
          selectedVerb: paalVerb,
          drillPrompt: presentForm,
          transientNotice: 'Введи форму глагола на иврите для проверки.',
          activeSpokenHebrew: 'כּוֹתֵב',
          audioStatus: AudioPlaybackStatus.loading,
        ),
        GrammarLoaded(
          verbs: <VerbLexeme>[paalVerb],
          selectedVerb: paalVerb,
          drillPrompt: presentForm,
          transientNotice: 'Введи форму глагола на иврите для проверки.',
          activeSpokenHebrew: 'כּוֹתֵב',
          audioStatus: AudioPlaybackStatus.playing,
        ),
      ],
    );

    blocTest<GrammarCubit, GrammarState>(
      'saves verb and conjugated form to FSRS in one tap and handles error notice',
      setUp: () {
        when(() => getVerbsUseCase(const GetVerbsByBinyanParams())).thenAnswer(
          (_) async =>
              Success<List<VerbLexeme>, Failure>(<VerbLexeme>[paalVerb]),
        );
        var call = 0;
        when(() => addCardToSrsUseCase(any())).thenAnswer((_) async {
          call += 1;
          if (call == 1) {
            return const Success<bool, Failure>(true);
          }
          return const Error<bool, Failure>(CacheFailure('Deck write failed'));
        });
      },
      build: buildCubit,
      act: (GrammarCubit cubit) async {
        await cubit.loadVerbs();
        await cubit.saveVerbToSrs(paalVerb);
        await cubit.saveConjugatedFormToSrs(paalVerb, presentForm);
      },
      expect: () => <GrammarState>[
        const GrammarLoading(),
        GrammarLoaded(
          verbs: <VerbLexeme>[paalVerb],
          selectedVerb: paalVerb,
          drillPrompt: presentForm,
        ),
        GrammarLoaded(
          verbs: <VerbLexeme>[paalVerb],
          selectedVerb: paalVerb,
          drillPrompt: presentForm,
          transientNotice: 'Глагол добавлен в колоду FSRS!',
        ),
        GrammarLoaded(
          verbs: <VerbLexeme>[paalVerb],
          selectedVerb: paalVerb,
          drillPrompt: presentForm,
          transientNotice: 'Deck write failed',
        ),
      ],
    );
  });
}
