import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/audio/audio_playback_service.dart';
import 'package:nexus_hebrew_app/core/error/failures.dart';
import 'package:nexus_hebrew_app/core/logging/app_logger.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/dialogue_node.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/hebrew_text.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/usecases/get_active_dialogue.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/usecases/select_dialogue_option.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/usecases/toggle_dialogue_audio.dart';
import 'package:nexus_hebrew_app/features/conversation/presentation/cubit/conversation_cubit.dart';
import 'package:nexus_hebrew_app/features/conversation/presentation/cubit/conversation_state.dart';
import 'package:nexus_hebrew_app/features/srs/domain/usecases/add_card_to_srs.dart';

class _MockGetActiveDialogueUseCase extends Mock
    implements GetActiveDialogueUseCase {}

class _MockSelectDialogueOptionUseCase extends Mock
    implements SelectDialogueOptionUseCase {}

class _MockToggleDialogueAudioUseCase extends Mock
    implements ToggleDialogueAudioUseCase {}

class _MockAudioPlaybackService extends Mock implements AudioPlaybackService {}

class _MockAddCardToSrsUseCase extends Mock implements AddCardToSrsUseCase {}

void main() {
  late _MockGetActiveDialogueUseCase getDialogueUseCase;
  late _MockSelectDialogueOptionUseCase selectOptionUseCase;
  late _MockToggleDialogueAudioUseCase toggleAudioUseCase;
  late _MockAddCardToSrsUseCase addCardToSrsUseCase;
  late _MockAudioPlaybackService audioService;
  late StreamController<AudioPlaybackEvent> audioEvents;

  const optionCoffee = DialogueOption(
    id: 'opt_coffee',
    textHebrew: HebrewText.fixture(vocalized: 'קָפֶה', normalized: 'קפה'),
    textRussian: 'Кофе',
    nextNodeId: 'node_coffee',
  );

  const startNode = DialogueNode.fixture(
    id: 'node_start',
    speaker: SpeakerName(
      hebrew: HebrewText.fixture(vocalized: 'מוֹכֵר', normalized: 'מוכר'),
    ),
    lineHebrew: HebrewText.fixture(vocalized: 'שָׁלוֹם!', normalized: 'שלום!'),
    lineRussian: 'Привет!',
    audioPath: 'assets/audio/market_dialogue_1.mp3',
    options: [optionCoffee],
  );

  const coffeeNode = DialogueNode.fixture(
    id: 'node_coffee',
    speaker: SpeakerName(
      hebrew: HebrewText.fixture(vocalized: 'מוֹכֵר', normalized: 'מוכר'),
    ),
    lineHebrew: HebrewText.fixture(vocalized: 'הָפוּךְ?', normalized: 'הפוך?'),
    lineRussian: 'Капучино?',
    options: [],
  );

  setUpAll(() {
    registerFallbackValue(optionCoffee);
    registerFallbackValue(
      const AddCardToSrsParams(
        id: 'fallback',
        hebrewVocalized: 'שָׁלוֹם',
        russianTranslation: 'Привет',
      ),
    );
  });

  setUp(() {
    getDialogueUseCase = _MockGetActiveDialogueUseCase();
    selectOptionUseCase = _MockSelectDialogueOptionUseCase();
    toggleAudioUseCase = _MockToggleDialogueAudioUseCase();
    addCardToSrsUseCase = _MockAddCardToSrsUseCase();
    audioService = _MockAudioPlaybackService();
    audioEvents = StreamController<AudioPlaybackEvent>.broadcast();

    when(() => audioService.statusStream).thenAnswer((_) => audioEvents.stream);
    when(() => audioService.currentSpeed).thenReturn(1.0);
    when(() => audioService.setPlaybackSpeed(any()))
        .thenAnswer((_) async => const Success(null));
    when(() => audioService.stop())
        .thenAnswer((_) async => const Success(null));
  });

  tearDown(() async {
    await audioEvents.close();
  });

  ConversationCubit buildCubit() => ConversationCubit(
        getDialogueUseCase: getDialogueUseCase,
        selectOptionUseCase: selectOptionUseCase,
        toggleAudioUseCase: toggleAudioUseCase,
        addCardToSrsUseCase: addCardToSrsUseCase,
        audioService: audioService,
        logger: const NoOpAppLogger(),
      );

  group('ConversationCubit', () {
    blocTest<ConversationCubit, ConversationState>(
      'эмитит [Loading, Loaded] при успешной загрузке узла',
      build: buildCubit,
      setUp: () {
        when(() => getDialogueUseCase.execute('node_start'))
            .thenAnswer((_) async => const Success(startNode));
      },
      act: (cubit) => cubit.loadDialogueNode('node_start'),
      expect: () => [
        const ConversationLoading(nodeId: 'node_start'),
        ConversationLoaded(activeNode: startNode),
      ],
    );

    blocTest<ConversationCubit, ConversationState>(
      'эмитит [Loading, Error] при провале Use Case',
      build: buildCubit,
      setUp: () {
        when(() => getDialogueUseCase.execute('bad_id')).thenAnswer(
          (_) async => const Error(CacheFailure('Not found')),
        );
      },
      act: (cubit) => cubit.loadDialogueNode('bad_id'),
      expect: () => const [
        ConversationLoading(nodeId: 'bad_id'),
        ConversationError(
          failure: CacheFailure('Not found'),
          retryNodeId: 'bad_id',
        ),
      ],
    );

    blocTest<ConversationCubit, ConversationState>(
      'обновляет историю при selectOption и возвращается по navigateBack',
      build: buildCubit,
      seed: () => ConversationLoaded(activeNode: startNode),
      setUp: () {
        when(
          () => selectOptionUseCase.execute(
            currentNodeId: 'node_start',
            selectedOption: optionCoffee,
          ),
        ).thenAnswer((_) async => const Success(coffeeNode));
        when(() => getDialogueUseCase.execute('node_start'))
            .thenAnswer((_) async => const Success(startNode));
      },
      act: (cubit) async {
        await cubit.selectOption(optionCoffee);
        await cubit.navigateBack();
      },
      expect: () => [
        ConversationLoaded(activeNode: startNode, isTransitioning: true),
        ConversationLoaded(
          activeNode: coffeeNode,
          navigationHistory: const ['node_start'],
        ),
        ConversationLoaded(
          activeNode: coffeeNode,
          isTransitioning: true,
          navigationHistory: const ['node_start'],
        ),
        ConversationLoaded(activeNode: startNode),
      ],
    );

    blocTest<ConversationCubit, ConversationState>(
      'переключает видимость огласовок через toggleNikkudVisibility',
      build: buildCubit,
      seed: () => ConversationLoaded(activeNode: startNode),
      act: (cubit) => cubit.toggleNikkudVisibility(),
      expect: () => [
        ConversationLoaded(activeNode: startNode, showNikkud: false),
      ],
    );

    blocTest<ConversationCubit, ConversationState>(
      'показывает transientNotice при ошибке аудио без потери экрана диалога',
      build: buildCubit,
      seed: () => ConversationLoaded(activeNode: startNode),
      setUp: () {
        when(
          () => toggleAudioUseCase.execute(
            startNode.audioPath,
            fallbackHebrewText: startNode.lineHebrew.vocalized,
          ),
        ).thenAnswer(
          (_) async => const Error(AudioFailure('Audio asset missing')),
        );
      },
      act: (cubit) => cubit.toggleAudio(),
      expect: () => [
        ConversationLoaded(
          activeNode: startNode,
          transientNotice: 'Audio asset missing',
        ),
      ],
    );

    blocTest<ConversationCubit, ConversationState>(
      'сохраняет реплику и вариант ответа в FSRS в 1 тап и сообщает о дубликатах',
      build: buildCubit,
      seed: () => ConversationLoaded(activeNode: startNode),
      setUp: () {
        var calls = 0;
        when(() => addCardToSrsUseCase(any())).thenAnswer((_) async {
          calls += 1;
          return Success<bool, Failure>(calls == 1);
        });
      },
      act: (ConversationCubit cubit) async {
        await cubit.saveNodeToSrs();
        await cubit.saveOptionToSrs(optionCoffee);
      },
      expect: () => <ConversationState>[
        ConversationLoaded(
          activeNode: startNode,
          transientNotice: 'Реплика добавлена в колоду FSRS!',
        ),
        ConversationLoaded(
          activeNode: startNode,
          transientNotice: 'Эта фраза уже есть в колоде FSRS',
        ),
      ],
    );

    blocTest<ConversationCubit, ConversationState>(
      'меняет playbackSpeed в стейте и вызывает audioService.setPlaybackSpeed',
      build: buildCubit,
      seed: () => ConversationLoaded(activeNode: startNode, playbackSpeed: 1.0),
      act: (ConversationCubit cubit) => cubit.setPlaybackSpeed(0.85),
      expect: () => [
        isA<ConversationLoaded>()
            .having((s) => s.playbackSpeed, 'playbackSpeed', 0.85),
      ],
      verify: (_) {
        verify(() => audioService.setPlaybackSpeed(0.85)).called(1);
      },
    );
  });
}
