import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/audio/audio_playback_service.dart';
import 'package:nexus_hebrew_app/core/logging/app_logger.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/dictionary/domain/entities/dictionary_entry.dart';
import 'package:nexus_hebrew_app/features/dictionary/domain/repositories/dictionary_repository.dart';
import 'package:nexus_hebrew_app/features/dictionary/domain/usecases/add_custom_dictionary_entry.dart';
import 'package:nexus_hebrew_app/features/dictionary/domain/usecases/search_dictionary_entries.dart';
import 'package:nexus_hebrew_app/features/dictionary/domain/usecases/search_online_dictionary.dart';
import 'package:nexus_hebrew_app/features/dictionary/presentation/cubit/dictionary_cubit.dart';
import 'package:nexus_hebrew_app/features/grammar/domain/repositories/grammar_repository.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/srs_card.dart';
import 'package:nexus_hebrew_app/features/srs/domain/usecases/add_card_to_srs.dart';
import 'package:nexus_hebrew_app/features/srs/domain/usecases/check_hebrew_typed_answer.dart';
import 'package:nexus_hebrew_app/features/srs/domain/usecases/get_due_srs_cards.dart';
import 'package:nexus_hebrew_app/features/srs/domain/usecases/import_open_tatoeba_cards.dart';
import 'package:nexus_hebrew_app/features/srs/domain/usecases/review_srs_card.dart';
import 'package:nexus_hebrew_app/features/srs/presentation/cubit/srs_session_cubit.dart';
import 'package:nexus_hebrew_app/features/srs/presentation/screens/srs_study_screen.dart';
import 'package:nexus_hebrew_app/features/srs/presentation/widgets/deck_import_dialog.dart';

class _MockGetDueSrsCardsUseCase extends Mock
    implements GetDueSrsCardsUseCase {}

class _MockReviewSrsCardUseCase extends Mock implements ReviewSrsCardUseCase {}

class _MockImportOpenTatoebaCardsUseCase extends Mock
    implements ImportOpenTatoebaCardsUseCase {}

class _MockDictionaryRepository extends Mock implements DictionaryRepository {}

class _MockGrammarRepository extends Mock implements GrammarRepository {}

class _MockAddCardToSrsUseCase extends Mock implements AddCardToSrsUseCase {}

class _MockAudioPlaybackService extends Mock implements AudioPlaybackService {}

void main() {
  late _MockGetDueSrsCardsUseCase mockGetDueCards;
  late _MockReviewSrsCardUseCase mockReviewCard;
  late _MockImportOpenTatoebaCardsUseCase mockImportTatoeba;
  late _MockDictionaryRepository mockDictRepo;
  late _MockGrammarRepository mockGrammarRepo;
  late _MockAddCardToSrsUseCase mockAddCardUseCase;
  late _MockAudioPlaybackService mockAudioService;
  late SrsSessionCubit srsCubit;
  late DictionaryCubit dictCubit;

  setUpAll(() {
    registerFallbackValue(
      const AddCardToSrsParams(
        id: 'fallback_id',
        hebrewVocalized: 'שָׁלוֹם',
        russianTranslation: 'Привет',
      ),
    );
  });

  setUp(() {
    mockGetDueCards = _MockGetDueSrsCardsUseCase();
    mockReviewCard = _MockReviewSrsCardUseCase();
    mockImportTatoeba = _MockImportOpenTatoebaCardsUseCase();
    mockDictRepo = _MockDictionaryRepository();
    mockGrammarRepo = _MockGrammarRepository();
    mockAddCardUseCase = _MockAddCardToSrsUseCase();
    mockAudioService = _MockAudioPlaybackService();

    when(() => mockAudioService.statusStream)
        .thenAnswer((_) => const Stream<AudioPlaybackEvent>.empty());
    when(() => mockAudioService.currentSpeed).thenReturn(1.0);
    when(() => mockAudioService.stop())
        .thenAnswer((_) async => const Success(null));
    when(() => mockGetDueCards.execute(
          asOf: any(named: 'asOf'),
          limit: any(named: 'limit'),
        )).thenAnswer((_) async => const Success(<SrsCard>[]));
    when(() => mockDictRepo.getAllEntries())
        .thenAnswer((_) async => const Success(<DictionaryEntry>[]));
    when(() => mockDictRepo.getSrsNormalizedForms())
        .thenAnswer((_) async => const Success(<String>{}));
    when(() => mockAddCardUseCase(any()))
        .thenAnswer((_) async => const Success(true));

    srsCubit = SrsSessionCubit(
      getDueCardsUseCase: mockGetDueCards,
      reviewCardUseCase: mockReviewCard,
      checkTypedAnswerUseCase: const CheckHebrewTypedAnswerUseCase(),
      importTatoebaCardsUseCase: mockImportTatoeba,
      audioService: mockAudioService,
      logger: const NoOpAppLogger(),
    );

    dictCubit = DictionaryCubit(
      repository: mockDictRepo,
      grammarRepository: mockGrammarRepo,
      searchUseCase: const SearchDictionaryEntriesUseCase(),
      addCustomEntryUseCase: AddCustomDictionaryEntryUseCase(
        repository: mockDictRepo,
      ),
      searchOnlineUseCase: SearchOnlineDictionaryUseCase(mockDictRepo),
      addCardToSrsUseCase: mockAddCardUseCase,
      audioService: mockAudioService,
      logger: const NoOpAppLogger(),
    );
  });

  tearDown(() async {
    await srsCubit.close();
    await dictCubit.close();
  });

  Widget createSubject() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<SrsSessionCubit>.value(value: srsCubit),
          BlocProvider<DictionaryCubit>.value(value: dictCubit),
        ],
        child: SrsStudyScreen(
          audioService: mockAudioService,
          addCardToSrsUseCase: mockAddCardUseCase,
        ),
      ),
    );
  }

  group('SrsStudyScreen', () {
    testWidgets('отображает кнопку импорта колоды на пустом экране и открывает диалог', (tester) async {
      await srsCubit.loadDueCards();

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      expect(find.text('На сегодня все карточки пройдены!'), findsOneWidget);
      expect(find.text('Импортировать свою колоду (Anki/JSON)'), findsOneWidget);

      await tester.tap(find.text('Импортировать свою колоду (Anki/JSON)'));
      await tester.pumpAndSettle();

      expect(find.byType(DeckImportDialog), findsOneWidget);
      expect(find.text('Импорт колоды слов'), findsOneWidget);
    });

    testWidgets('меню в AppBar содержит пункт Импорт колоды', (tester) async {
      await srsCubit.loadDueCards();

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      final popupMenuFinder = find.byType(PopupMenuButton<String>);
      expect(popupMenuFinder, findsOneWidget);

      await tester.tap(popupMenuFinder);
      await tester.pumpAndSettle();

      expect(find.text('Импорт колоды'), findsOneWidget);
      expect(find.text('Anki TSV / CSV / JSON'), findsOneWidget);
      expect(find.text('Экспорт в Anki'), findsOneWidget);

      await tester.tap(find.text('Импорт колоды'));
      await tester.pumpAndSettle();

      expect(find.byType(DeckImportDialog), findsOneWidget);
    });
  });
}
