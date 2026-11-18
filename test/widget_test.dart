import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/core/audio/audio_playback_service.dart';
import 'package:nexus_hebrew_app/core/error/failures.dart';
import 'package:nexus_hebrew_app/core/logging/app_logger.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/binyan.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/dialogue_node.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/hebrew_text.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/repositories/conversation_repository.dart';
import 'package:nexus_hebrew_app/features/conversation/presentation/screens/conversation_screen.dart';
import 'package:nexus_hebrew_app/features/dictionary/domain/entities/dictionary_entry.dart';
import 'package:nexus_hebrew_app/features/dictionary/domain/repositories/dictionary_repository.dart';
import 'package:nexus_hebrew_app/features/grammar/domain/entities/verb_conjugation.dart';
import 'package:nexus_hebrew_app/features/grammar/domain/repositories/grammar_repository.dart';
import 'package:nexus_hebrew_app/features/listening/domain/entities/listening_exercise.dart';
import 'package:nexus_hebrew_app/features/listening/domain/repositories/listening_repository.dart';
import 'package:nexus_hebrew_app/features/progress/domain/entities/learning_progress_summary.dart';
import 'package:nexus_hebrew_app/features/progress/domain/repositories/progress_repository.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/fsrs_models.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/srs_card.dart';
import 'package:nexus_hebrew_app/features/srs/domain/repositories/srs_repository.dart';
import 'package:nexus_hebrew_app/features/stories/domain/entities/story.dart';
import 'package:nexus_hebrew_app/features/stories/domain/repositories/stories_repository.dart';
import 'package:nexus_hebrew_app/main.dart';

final class _FakeConversationRepository implements ConversationRepository {
  @override
  Future<Result<DialogueNode, Failure>> getDialogueNode(String nodeId) async {
    return Success<DialogueNode, Failure>(
      DialogueNode(
        id: ConversationScreen.initialNodeId,
        speaker: SpeakerName(
          hebrew: HebrewText.create('רוֹעִי').getOrNull()!,
          russian: 'Рои',
        ),
        lineHebrew: HebrewText.create('בֹּקֶר טוֹב!').getOrNull()!,
        lineRussian: 'Доброе утро!',
        options: const <DialogueOption>[],
      ),
    );
  }

  @override
  Future<Result<List<DialogueNode>, Failure>> searchDialoguesByHebrew(
    String normalizedQuery,
  ) async =>
      const Success<List<DialogueNode>, Failure>(<DialogueNode>[]);

  @override
  Future<Result<void, Failure>> recordDialogueSelection({
    required String nodeId,
    required String optionId,
  }) async =>
      const Success<void, Failure>(null);

  @override
  Future<Result<int, Failure>> syncDialogueHistory() async =>
      const Success<int, Failure>(0);
}

final class _FakeSrsRepository implements SrsRepository {
  @override
  Future<Result<List<SrsCard>, Failure>> getDueCards({
    required DateTime asOf,
    int limit = 20,
  }) async =>
      const Success<List<SrsCard>, Failure>(<SrsCard>[]);

  @override
  Future<Result<int, Failure>> getTotalCardsCount() async =>
      const Success<int, Failure>(0);

  @override
  Future<Result<void, Failure>> saveReview({
    required SrsCard updatedCard,
    required FsrsRating rating,
    required int scheduledDays,
    required double stabilityBefore,
    required bool wasTypedCheck,
    required bool wasTypedExact,
    required DateTime reviewedAt,
  }) async =>
      const Success<void, Failure>(null);

  @override
  Future<Result<List<SrsCard>, Failure>> importOpenTatoebaCards({
    required String query,
    int limit = 10,
  }) async =>
      const Success<List<SrsCard>, Failure>(<SrsCard>[]);

  @override
  Future<Result<bool, Failure>> addCustomCard(SrsCard card) async =>
      const Success<bool, Failure>(true);
}

final class _FakeGrammarRepository implements GrammarRepository {
  @override
  Future<Result<List<VerbLexeme>, Failure>> getVerbs({
    Binyan? binyan,
    String query = '',
  }) async =>
      const Success<List<VerbLexeme>, Failure>(<VerbLexeme>[]);

  @override
  Future<Result<void, Failure>> recordPracticeAttempt({
    required String verbId,
    required VerbTense tense,
    required GrammaticalPerson person,
    required bool isCorrect,
    required DateTime practicedAt,
  }) async =>
      const Success<void, Failure>(null);
}

final class _FakeListeningRepository implements ListeningRepository {
  @override
  Future<Result<List<ListeningExercise>, Failure>> getExercises({
    ListeningDifficulty? difficulty,
  }) async =>
      const Success<List<ListeningExercise>, Failure>(<ListeningExercise>[]);

  @override
  Future<Result<List<ListeningExercise>, Failure>> importFromTatoeba({
    required String query,
    int limit = 8,
  }) async =>
      const Success<List<ListeningExercise>, Failure>(<ListeningExercise>[]);

  @override
  Future<Result<void, Failure>> recordAttempt({
    required String exerciseId,
    required double wordAccuracy,
    required bool isExactMatch,
    required DateTime attemptedAt,
  }) async =>
      const Success<void, Failure>(null);
}

final class _FakeProgressRepository implements ProgressRepository {
  @override
  Future<Result<LearningProgressSummary, Failure>> getProgressSummary({
    required DateTime asOf,
  }) async {
    return Success<LearningProgressSummary, Failure>(
      LearningProgressSummary(
        totalSrsCards: 0,
        dueSrsCards: 0,
        newCards: 0,
        learningCards: 0,
        reviewCards: 0,
        relearningCards: 0,
        totalSrsReviews: 0,
        currentStreakDays: 0,
        activeTodayCount: 0,
        grammarAttempts: 0,
        grammarCorrect: 0,
        binyanStats: const <BinyanAccuracyStat>[],
        listeningAttempts: 0,
        listeningExactMatches: 0,
        averageListeningAccuracy: 0.0,
      ),
    );
  }

  @override
  Future<Result<List<GlobalHebrewSearchResult>, Failure>> searchAcrossLibrary(
    String query,
  ) async =>
      const Success<List<GlobalHebrewSearchResult>, Failure>(
        <GlobalHebrewSearchResult>[],
      );
}

final class _FakeAudioPlaybackService implements AudioPlaybackService {
  final StreamController<AudioPlaybackEvent> _controller =
      StreamController<AudioPlaybackEvent>.broadcast();

  @override
  Stream<AudioPlaybackEvent> get statusStream => _controller.stream;

  @override
  AudioPlaybackEvent get currentState => const AudioPlaybackEvent.idle();

  @override
  double get currentSpeed => 1.0;

  @override
  Future<Result<void, Failure>> setPlaybackSpeed(double speed) async =>
      const Success<void, Failure>(null);

  @override
  Future<Result<void, Failure>> play(String sourcePath) async =>
      const Success<void, Failure>(null);

  @override
  Future<Result<void, Failure>> playWithTtsFallback({
    required String? sourcePath,
    required String fallbackHebrewText,
  }) async =>
      const Success<void, Failure>(null);

  @override
  Future<Result<void, Failure>> stop() async =>
      const Success<void, Failure>(null);

  @override
  Future<Result<void, Failure>> dispose() async {
    await _controller.close();
    return const Success<void, Failure>(null);
  }
}

final class _FakeDictionaryRepository implements DictionaryRepository {
  @override
  Future<Result<List<DictionaryEntry>, Failure>> getAllEntries() async =>
      const Success<List<DictionaryEntry>, Failure>(<DictionaryEntry>[]);

  @override
  Future<Result<Set<String>, Failure>> getSrsNormalizedForms() async =>
      const Success<Set<String>, Failure>(<String>{});

  @override
  Future<Result<DictionaryEntry, Failure>> saveCustomEntry(
    DictionaryEntry entry,
  ) async =>
      Success<DictionaryEntry, Failure>(entry);

  @override
  Future<Result<List<DictionaryEntry>, Failure>> searchOnlineAndCache({
    required String query,
    int limit = 12,
  }) async =>
      const Success<List<DictionaryEntry>, Failure>(<DictionaryEntry>[]);
}

final class _FakeStoriesRepository implements StoriesRepository {
  @override
  Future<Result<List<Story>, Failure>> getStories() async =>
      const Success<List<Story>, Failure>(<Story>[]);

  @override
  Future<Result<Story, Failure>> getStoryById(String id) async =>
      const Error<Story, Failure>(ValidationFailure('Not found'));

  @override
  Future<Result<Set<String>, Failure>> getCompletedStoryIds() async =>
      const Success<Set<String>, Failure>(<String>{});

  @override
  Future<Result<void, Failure>> markStoryCompleted(String id) async =>
      const Success<void, Failure>(null);
}

Widget _buildTestApp() {
  return NexusHebrewApp(
    conversationRepository: _FakeConversationRepository(),
    srsRepository: _FakeSrsRepository(),
    grammarRepository: _FakeGrammarRepository(),
    listeningRepository: _FakeListeningRepository(),
    dictionaryRepository: _FakeDictionaryRepository(),
    progressRepository: _FakeProgressRepository(),
    storiesRepository: _FakeStoriesRepository(),
    audioService: _FakeAudioPlaybackService(),
    logger: const DeveloperAppLogger(),
  );
}

void main() {
  testWidgets(
    'NexusHebrewApp renders all seven navigation tabs in compact NavigationBar',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.text('Главная'), findsWidgets);
      expect(find.text('Диалоги'), findsWidgets);
      expect(find.text('FSRS'), findsWidgets);
      expect(find.text('Грамматика'), findsWidgets);
      expect(find.text('Аудирование'), findsWidgets);
      expect(find.text('Словарь'), findsWidgets);
      expect(find.text('Прогресс'), findsWidgets);

      final dialogueDest = find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Диалоги'),
      );
      await tester.tap(dialogueDest);
      await tester.pumpAndSettle();
      expect(find.text('בֹּקֶר טוֹב!'), findsOneWidget);

      final dictionaryDest = find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Словарь'),
      );
      await tester.tap(dictionaryDest);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'NexusHebrewApp adapts to NavigationRail on wide screens (>= 840px)',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.text('Главная'), findsWidgets);
      expect(find.text('Диалоги'), findsWidgets);
      expect(find.text('Словарь'), findsWidgets);
      expect(find.text('Прогресс'), findsWidgets);

      final dictionaryDest = find.descendant(
        of: find.byType(NavigationRail),
        matching: find.text('Словарь'),
      );
      await tester.tap(dictionaryDest);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
