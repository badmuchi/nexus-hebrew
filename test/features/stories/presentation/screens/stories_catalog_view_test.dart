import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/audio/audio_playback_service.dart';
import 'package:nexus_hebrew_app/core/database/app_database.dart';
import 'package:nexus_hebrew_app/core/logging/app_logger.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/hebrew_text.dart';
import 'package:nexus_hebrew_app/features/dictionary/domain/entities/dictionary_entry.dart';
import 'package:nexus_hebrew_app/features/dictionary/domain/repositories/dictionary_repository.dart';
import 'package:nexus_hebrew_app/features/dictionary/domain/usecases/add_custom_dictionary_entry.dart';
import 'package:nexus_hebrew_app/features/dictionary/domain/usecases/search_dictionary_entries.dart';
import 'package:nexus_hebrew_app/features/dictionary/domain/usecases/search_online_dictionary.dart';
import 'package:nexus_hebrew_app/features/dictionary/presentation/cubit/dictionary_cubit.dart';
import 'package:nexus_hebrew_app/features/grammar/domain/usecases/check_verb_conjugation.dart';
import 'package:nexus_hebrew_app/features/grammar/domain/usecases/get_verbs_by_binyan.dart';
import 'package:nexus_hebrew_app/features/grammar/domain/usecases/record_grammar_practice.dart';
import 'package:nexus_hebrew_app/features/grammar/presentation/cubit/grammar_cubit.dart';
import 'package:nexus_hebrew_app/features/srs/domain/usecases/add_card_to_srs.dart';
import 'package:nexus_hebrew_app/features/stories/domain/entities/story.dart';
import 'package:nexus_hebrew_app/features/stories/domain/repositories/stories_repository.dart';
import 'package:nexus_hebrew_app/features/stories/domain/usecases/get_stories.dart';
import 'package:nexus_hebrew_app/features/stories/domain/usecases/mark_story_completed.dart';
import 'package:nexus_hebrew_app/features/stories/presentation/cubit/stories_cubit.dart';
import 'package:nexus_hebrew_app/features/stories/presentation/screens/stories_catalog_view.dart';
import 'package:nexus_hebrew_app/features/stories/presentation/screens/story_reader_screen.dart';

class _MockStoriesRepository extends Mock implements StoriesRepository {}
class _MockDictionaryRepository extends Mock implements DictionaryRepository {}
class _MockGetVerbsByBinyanUseCase extends Mock implements GetVerbsByBinyanUseCase {}
class _MockRecordGrammarPracticeUseCase extends Mock implements RecordGrammarPracticeUseCase {}
class _MockAudioPlaybackService extends Mock implements AudioPlaybackService {}
class _MockAddCardToSrsUseCase extends Mock implements AddCardToSrsUseCase {}
class _MockAppDatabase extends Mock implements AppDatabase {}

void main() {
  late _MockStoriesRepository mockStoriesRepo;
  late _MockDictionaryRepository mockDictRepo;
  late _MockGetVerbsByBinyanUseCase mockGetVerbsUseCase;
  late _MockRecordGrammarPracticeUseCase mockRecordPracticeUseCase;
  late _MockAudioPlaybackService mockAudio;
  late _MockAddCardToSrsUseCase mockAddCard;
  late _MockAppDatabase mockDatabase;
  late StreamController<AudioPlaybackEvent> audioStreamCtrl;
  late StoriesCubit storiesCubit;
  late DictionaryCubit dictCubit;
  late GrammarCubit grammarCubit;

  final testStory = Story(
    id: 'story_catalog_1',
    titleHebrew: HebrewText.create('קָפֶה בַּבֹּקֶר').getOrNull()!,
    titleRussian: 'Утренний кофе',
    level: 'A1',
    readingTimeMinutes: 2,
    coverEmoji: '☕',
    summaryRussian: 'История про кофе в Тель-Авиве',
    paragraphs: const [
      StoryParagraph(
        id: 'p1',
        sentences: [
          StorySentence(
            id: 's1',
            hebrewVocalized: 'אֲנִי אוֹהֵב קָפֶה.',
            hebrewNormalized: 'אני אוהב קפה.',
            russianTranslation: 'Я люблю кофе.',
            tokens: [
              StoryWordToken(
                wordVocalized: 'קָפֶה',
                wordNormalized: 'קפה',
                russianTranslation: 'кофе',
                category: 'weak_word_practice',
              ),
            ],
          ),
        ],
      ),
    ],
  );

  setUpAll(() {
    registerFallbackValue(const GetVerbsByBinyanParams());
  });

  setUp(() {
    mockStoriesRepo = _MockStoriesRepository();
    mockDictRepo = _MockDictionaryRepository();
    mockGetVerbsUseCase = _MockGetVerbsByBinyanUseCase();
    mockRecordPracticeUseCase = _MockRecordGrammarPracticeUseCase();
    mockAudio = _MockAudioPlaybackService();
    mockAddCard = _MockAddCardToSrsUseCase();
    mockDatabase = _MockAppDatabase();
    audioStreamCtrl = StreamController<AudioPlaybackEvent>.broadcast();

    when(() => mockAudio.statusStream).thenAnswer((_) => audioStreamCtrl.stream);
    when(() => mockAudio.currentSpeed).thenReturn(1.0);
    when(() => mockDictRepo.getSrsNormalizedForms())
        .thenAnswer((_) async => const Success(<String>{}));
    when(() => mockDictRepo.getAllEntries())
        .thenAnswer((_) async => const Success(<DictionaryEntry>[]));
    when(() => mockGetVerbsUseCase(any()))
        .thenAnswer((_) async => const Success([]));
    when(() => mockStoriesRepo.getStories())
        .thenAnswer((_) async => Success([testStory]));
    when(() => mockStoriesRepo.getCompletedStoryIds())
        .thenAnswer((_) async => const Success(<String>{}));
    when(() => mockDatabase.getAllSrsCards())
        .thenAnswer((_) async => <SrsCardRow>[]);

    storiesCubit = StoriesCubit(
      getStoriesUseCase: GetStoriesUseCase(mockStoriesRepo),
      markCompletedUseCase: MarkStoryCompletedUseCase(mockStoriesRepo),
      dictionaryRepository: mockDictRepo,
      audioService: mockAudio,
      logger: const NoOpAppLogger(),
    );

    dictCubit = DictionaryCubit(
      repository: mockDictRepo,
      searchUseCase: const SearchDictionaryEntriesUseCase(),
      addCustomEntryUseCase: AddCustomDictionaryEntryUseCase(
        repository: mockDictRepo,
      ),
      searchOnlineUseCase: SearchOnlineDictionaryUseCase(mockDictRepo),
      addCardToSrsUseCase: mockAddCard,
      audioService: mockAudio,
      logger: const NoOpAppLogger(),
    );

    grammarCubit = GrammarCubit(
      getVerbsUseCase: mockGetVerbsUseCase,
      checkConjugationUseCase: const CheckVerbConjugationUseCase(),
      recordPracticeUseCase: mockRecordPracticeUseCase,
      audioService: mockAudio,
      logger: const NoOpAppLogger(),
    );
  });

  tearDown(() async {
    await audioStreamCtrl.close();
    await storiesCubit.close();
    await dictCubit.close();
    await grammarCubit.close();
  });

  Widget buildSubject() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<StoriesCubit>.value(value: storiesCubit),
          BlocProvider<DictionaryCubit>.value(value: dictCubit),
          BlocProvider<GrammarCubit>.value(value: grammarCubit),
        ],
        child: Scaffold(
          body: StoriesCatalogView(
            audioService: mockAudio,
            addCardToSrsUseCase: mockAddCard,
            database: mockDatabase,
          ),
        ),
      ),
    );
  }

  testWidgets('renders FSRS Smart Story Card and tapping create launches reader', (tester) async {
    await storiesCubit.loadStories();
    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    // Verify FSRS Smart Story Generator Card is present
    expect(find.text('Персональный рассказ FSRS'), findsOneWidget);
    expect(find.text('Создать'), findsOneWidget);
    expect(find.text('Умная читалка любого текста'), findsOneWidget);

    // Tap "Создать"
    await tester.tap(find.text('Создать'));
    await tester.pumpAndSettle();

    // Verify that StoryReaderScreen opened with FSRS Smart Story
    expect(find.byType(StoryReaderScreen), findsOneWidget);
    expect(find.text('Адаптивный контекстный тренажер'), findsOneWidget);
  });
}
