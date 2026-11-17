import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/audio/audio_playback_service.dart';
import 'package:nexus_hebrew_app/core/error/failures.dart';
import 'package:nexus_hebrew_app/core/logging/app_logger.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/hebrew_text.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/fsrs_models.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/srs_card.dart';
import 'package:nexus_hebrew_app/features/srs/domain/services/fsrs_scheduler.dart';
import 'package:nexus_hebrew_app/features/srs/domain/usecases/check_hebrew_typed_answer.dart';
import 'package:nexus_hebrew_app/features/srs/domain/usecases/get_due_srs_cards.dart';
import 'package:nexus_hebrew_app/features/srs/domain/usecases/import_open_tatoeba_cards.dart';
import 'package:nexus_hebrew_app/features/srs/domain/usecases/review_srs_card.dart';
import 'package:nexus_hebrew_app/features/srs/presentation/cubit/srs_session_cubit.dart';
import 'package:nexus_hebrew_app/features/srs/presentation/cubit/srs_session_state.dart';

class _MockGetDueSrsCardsUseCase extends Mock
    implements GetDueSrsCardsUseCase {}

class _MockReviewSrsCardUseCase extends Mock implements ReviewSrsCardUseCase {}

class _MockImportOpenTatoebaCardsUseCase extends Mock
    implements ImportOpenTatoebaCardsUseCase {}

class _MockAudioPlaybackService extends Mock implements AudioPlaybackService {}

void main() {
  final fixedNow = DateTime.utc(2026, 11, 11, 15, 0);
  const scheduler = FsrsScheduler();

  late _MockGetDueSrsCardsUseCase getDueCardsUseCase;
  late _MockReviewSrsCardUseCase reviewCardUseCase;
  late _MockImportOpenTatoebaCardsUseCase importTatoebaUseCase;
  late _MockAudioPlaybackService audioService;
  late StreamController<AudioPlaybackEvent> audioEvents;

  final card1 = SrsCard(
    id: 'card_1',
    hebrew: const HebrewText.fixture(vocalized: 'שָׁלוֹם', normalized: 'שלום'),
    russianTranslation: 'Привет',
    audioUrl: 'https://audio.tatoeba.org/sentences/heb/1.mp3',
    attribution: const ContentAttribution(
      sourceName: 'Tatoeba',
      licenseName: 'CC0 1.0',
    ),
    memory: FsrsMemoryState.initial(now: fixedNow),
  );

  final updatedCard1 = card1.copyWith(
    memory: scheduler
        .schedule(current: card1.memory, rating: FsrsRating.good, now: fixedNow)
        .updatedMemory,
  );

  final previewForCard1 =
      scheduler.previewIntervals(current: card1.memory, now: fixedNow);

  setUpAll(() {
    registerFallbackValue(card1);
    registerFallbackValue(FsrsRating.good);
  });

  setUp(() {
    getDueCardsUseCase = _MockGetDueSrsCardsUseCase();
    reviewCardUseCase = _MockReviewSrsCardUseCase();
    importTatoebaUseCase = _MockImportOpenTatoebaCardsUseCase();
    audioService = _MockAudioPlaybackService();
    audioEvents = StreamController<AudioPlaybackEvent>.broadcast();

    when(() => audioService.statusStream).thenAnswer((_) => audioEvents.stream);
    when(() => audioService.stop())
        .thenAnswer((_) async => const Success(null));
  });

  tearDown(() async {
    await audioEvents.close();
  });

  SrsSessionCubit buildCubit() => SrsSessionCubit(
        getDueCardsUseCase: getDueCardsUseCase,
        reviewCardUseCase: reviewCardUseCase,
        checkTypedAnswerUseCase: const CheckHebrewTypedAnswerUseCase(),
        importTatoebaCardsUseCase: importTatoebaUseCase,
        audioService: audioService,
        logger: const NoOpAppLogger(),
        scheduler: scheduler,
        clock: () => fixedNow,
      );

  group('SrsSessionCubit', () {
    blocTest<SrsSessionCubit, SrsSessionState>(
      'загружает карточки в SrsSessionActive с предрасчётом интервалов FSRS',
      build: buildCubit,
      setUp: () {
        when(() => getDueCardsUseCase.execute(asOf: fixedNow, limit: 20))
            .thenAnswer((_) async => Success([card1]));
      },
      act: (cubit) => cubit.loadDueCards(),
      expect: () => [
        const SrsSessionLoading(),
        SrsSessionActive(
          queue: [card1],
          intervalPreview: previewForCard1,
        ),
      ],
    );

    blocTest<SrsSessionCubit, SrsSessionState>(
      'проверяет ввод на иврите без некудот и сохраняет оценку FSRS до SrsSessionEmpty',
      build: buildCubit,
      seed: () => SrsSessionActive(
        queue: [card1],
        studyMode: SrsStudyMode.typing,
        intervalPreview: previewForCard1,
      ),
      setUp: () {
        when(
          () => reviewCardUseCase.execute(
            card: card1,
            rating: FsrsRating.good,
            reviewedAt: fixedNow,
            wasTypedCheck: true,
            wasTypedExact: true,
          ),
        ).thenAnswer((_) async => Success(updatedCard1));
      },
      act: (cubit) async {
        cubit.submitTypedAnswer('שלום');
        await cubit.rateCard(FsrsRating.good);
      },
      expect: () => [
        SrsSessionActive(
          queue: [card1],
          studyMode: SrsStudyMode.typing,
          isAnswerRevealed: true,
          typingEvaluation: const TypingAnswerEvaluation(
            isMatch: true,
            normalizedUserInput: 'שלום',
            expectedNormalized: 'שלום',
            expectedVocalized: 'שָׁלוֹם',
          ),
          intervalPreview: previewForCard1,
        ),
        SrsSessionActive(
          queue: [card1],
          studyMode: SrsStudyMode.typing,
          isAnswerRevealed: true,
          isSubmittingReview: true,
          typingEvaluation: const TypingAnswerEvaluation(
            isMatch: true,
            normalizedUserInput: 'שלום',
            expectedNormalized: 'שלום',
            expectedVocalized: 'שָׁלוֹם',
          ),
          intervalPreview: previewForCard1,
        ),
        const SrsSessionEmpty(reviewedCount: 1),
      ],
    );

    blocTest<SrsSessionCubit, SrsSessionState>(
      'импортирует карточки из Tatoeba из пустого состояния и запускает сессию',
      build: buildCubit,
      seed: () => const SrsSessionEmpty(),
      setUp: () {
        when(() => importTatoebaUseCase.execute(rawQuery: 'שלום', limit: 10))
            .thenAnswer((_) async => Success([card1]));
        when(() => getDueCardsUseCase.execute(asOf: fixedNow, limit: 25))
            .thenAnswer((_) async => Success([card1]));
      },
      act: (cubit) => cubit.importFromTatoeba('שלום'),
      expect: () => [
        const SrsSessionEmpty(isImporting: true),
        SrsSessionActive(
          queue: [card1],
          intervalPreview: previewForCard1,
          transientNotice: 'Добавлено из Tatoeba: 1 карт.',
        ),
      ],
    );

    blocTest<SrsSessionCubit, SrsSessionState>(
      'показывает transientNotice при ошибке аудио и TTS',
      build: buildCubit,
      seed: () => SrsSessionActive(
        queue: [card1],
        intervalPreview: previewForCard1,
      ),
      setUp: () {
        when(
          () => audioService.playWithTtsFallback(
            sourcePath: card1.audioUrl,
            fallbackHebrewText: card1.hebrew.vocalized,
          ),
        ).thenAnswer((_) async => const Error(AudioFailure('Audio unavailable')));
      },
      act: (cubit) => cubit.playCurrentCardAudio(),
      expect: () => [
        SrsSessionActive(
          queue: [card1],
          intervalPreview: previewForCard1,
          transientNotice: 'Audio unavailable',
        ),
      ],
    );
  });
}
