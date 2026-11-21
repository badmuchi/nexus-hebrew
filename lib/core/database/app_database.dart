import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DataClassName('DialogueNodeRow')
class DialogueNodes extends Table {
  TextColumn get id => text()();
  TextColumn get characterName => text()();
  TextColumn get lineHebrewVocalized => text()();
  TextColumn get lineHebrewNormalized => text()();
  TextColumn get lineRussian => text()();
  TextColumn get audioPath => text().nullable()();
  TextColumn get optionsJson => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('DialogueHistoryRow')
class DialogueHistoryEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nodeId => text()();
  TextColumn get selectedOptionId => text()();
  DateTimeColumn get answeredAt => dateTime()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
}

@DataClassName('SrsCardRow')
class SrsCards extends Table {
  TextColumn get id => text()();
  TextColumn get hebrewVocalized => text()();
  TextColumn get hebrewNormalized => text()();
  TextColumn get russianTranslation => text()();
  TextColumn get root => text().nullable()();
  TextColumn get binyan => text().withDefault(const Constant('none'))();
  TextColumn get category => text().withDefault(const Constant('phrase'))();
  TextColumn get exampleHebrewVocalized => text().nullable()();
  TextColumn get exampleHebrewNormalized => text().nullable()();
  TextColumn get exampleRussian => text().nullable()();
  TextColumn get audioUrl => text().nullable()();
  TextColumn get sourceName => text()();
  TextColumn get licenseName => text()();
  TextColumn get attributionText => text().nullable()();
  TextColumn get fsrsState => text().withDefault(const Constant('newCard'))();
  RealColumn get stability => real().withDefault(const Constant(0.0))();
  RealColumn get difficulty => real().withDefault(const Constant(0.0))();
  IntColumn get reps => integer().withDefault(const Constant(0))();
  IntColumn get lapses => integer().withDefault(const Constant(0))();
  DateTimeColumn get dueAt => dateTime()();
  DateTimeColumn get lastReviewedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SrsReviewLogRow')
class SrsReviewLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get cardId => text()();
  IntColumn get rating => integer()();
  RealColumn get stabilityBefore => real()();
  RealColumn get stabilityAfter => real()();
  RealColumn get difficultyAfter => real()();
  IntColumn get scheduledDays => integer()();
  BoolColumn get wasTypedCheck => boolean().withDefault(const Constant(false))();
  BoolColumn get wasTypedExact => boolean().withDefault(const Constant(false))();
  DateTimeColumn get reviewedAt => dateTime()();
}

@DataClassName('GrammarVerbRow')
class GrammarVerbs extends Table {
  TextColumn get id => text()();
  TextColumn get lemmaVocalized => text()();
  TextColumn get lemmaNormalized => text()();
  TextColumn get infinitiveVocalized => text().nullable()();
  TextColumn get root => text()();
  TextColumn get binyan => text()();
  TextColumn get russianMeaning => text()();
  TextColumn get grammarNotesRu => text()();
  TextColumn get conjugationsJson => text()();
  TextColumn get sourceName => text()();
  TextColumn get licenseName => text()();
  TextColumn get attributionText => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('GrammarPracticeLogRow')
class GrammarPracticeLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get verbId => text()();
  TextColumn get tense => text()();
  TextColumn get person => text()();
  BoolColumn get isCorrect => boolean()();
  DateTimeColumn get practicedAt => dateTime()();
}

@DataClassName('ListeningExerciseRow')
class ListeningExercises extends Table {
  TextColumn get id => text()();
  TextColumn get transcriptVocalized => text()();
  TextColumn get transcriptNormalized => text()();
  TextColumn get russianTranslation => text()();
  TextColumn get audioUrl => text().nullable()();
  TextColumn get difficulty => text().withDefault(const Constant('beginner'))();
  TextColumn get focusWordsJson => text()();
  TextColumn get sourceName => text()();
  TextColumn get licenseName => text()();
  TextColumn get attributionText => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ListeningAttemptLogRow')
class ListeningAttemptLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get exerciseId => text()();
  RealColumn get wordAccuracy => real()();
  BoolColumn get isExactMatch => boolean()();
  DateTimeColumn get attemptedAt => dateTime()();
}

@DataClassName('DictionaryEntryRow')
class DictionaryEntries extends Table {
  TextColumn get id => text()();
  TextColumn get hebrewVocalized => text()();
  TextColumn get hebrewNormalized => text()();
  TextColumn get russianTranslation => text()();
  TextColumn get transliteration => text().nullable()();
  TextColumn get category => text().withDefault(const Constant('noun'))();
  TextColumn get root => text().nullable()();
  TextColumn get binyan => text().withDefault(const Constant('none'))();
  TextColumn get formsSummary => text().nullable()();
  TextColumn get exampleHebrewVocalized => text().nullable()();
  TextColumn get exampleHebrewNormalized => text().nullable()();
  TextColumn get exampleRussian => text().nullable()();
  TextColumn get audioUrl => text().nullable()();
  IntColumn get frequencyRank => integer().nullable()();
  TextColumn get sourceName => text()();
  TextColumn get licenseName => text()();
  TextColumn get attributionText => text().nullable()();
  BoolColumn get isUserAdded => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SceneProgressRow')
class SceneProgressEntries extends Table {
  TextColumn get sceneId => text()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  IntColumn get wordsMasteredCount => integer().withDefault(const Constant(0))();
  IntColumn get challengeScore => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastVisitedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {sceneId};
}

@DataClassName('ShoreshProgressRow')
class ShoreshProgressEntries extends Table {
  TextColumn get rootId => text()();
  RealColumn get masteryLevel => real().withDefault(const Constant(0.0))();
  IntColumn get cardsPracticedCount => integer().withDefault(const Constant(0))();
  IntColumn get quizCorrectCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastPracticedAt => dateTime().nullable()();
  BoolColumn get isBookmarked => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {rootId};
}

@DriftDatabase(
  tables: [
    DialogueNodes,
    DialogueHistoryEntries,
    SrsCards,
    SrsReviewLogs,
    GrammarVerbs,
    GrammarPracticeLogs,
    ListeningExercises,
    ListeningAttemptLogs,
    DictionaryEntries,
    SceneProgressEntries,
    ShoreshProgressEntries,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase({QueryExecutor? executor})
      : super(
          executor ??
              driftDatabase(
                name: 'nexus_hebrew_app',
                web: DriftWebOptions(
                  sqlite3Wasm: Uri.parse('sqlite3.wasm'),
                  driftWorker: Uri.parse('drift_worker.js'),
                ),
              ),
        );

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) => m.createAll(),
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.createTable(srsCards);
            await m.createTable(srsReviewLogs);
          }
          if (from < 3) {
            await m.createTable(grammarVerbs);
            await m.createTable(grammarPracticeLogs);
            await m.createTable(listeningExercises);
            await m.createTable(listeningAttemptLogs);
          }
          if (from < 4) {
            await m.createTable(dictionaryEntries);
          }
          if (from < 5) {
            await m.createTable(sceneProgressEntries);
          }
          if (from < 6) {
            await m.createTable(shoreshProgressEntries);
          }
        },
      );

  // --- Conversation queries ---

  Future<DialogueNodeRow?> findDialogueNodeById(String nodeId) {
    return (select(dialogueNodes)..where((t) => t.id.equals(nodeId)))
        .getSingleOrNull();
  }

  Future<List<DialogueNodeRow>> searchDialogueNodesByNormalizedHebrew(
    String normalizedQuery,
  ) {
    return (select(dialogueNodes)
          ..where((t) => t.lineHebrewNormalized.contains(normalizedQuery)))
        .get();
  }

  Future<void> upsertDialogueNode(DialogueNodesCompanion row) {
    return into(dialogueNodes).insertOnConflictUpdate(row);
  }

  Future<void> upsertDialogueNodes(List<DialogueNodesCompanion> rows) {
    return batch((batch) {
      batch.insertAllOnConflictUpdate(dialogueNodes, rows);
    });
  }

  Future<int> insertDialogueHistoryEntry({
    required String nodeId,
    required String selectedOptionId,
    required DateTime answeredAt,
  }) {
    return into(dialogueHistoryEntries).insert(
      DialogueHistoryEntriesCompanion.insert(
        nodeId: nodeId,
        selectedOptionId: selectedOptionId,
        answeredAt: answeredAt,
      ),
    );
  }

  Future<List<DialogueHistoryRow>> getUnsyncedHistoryEntries() {
    return (select(dialogueHistoryEntries)
          ..where((t) => t.synced.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.answeredAt)]))
        .get();
  }

  Future<void> markHistoryEntriesSynced(List<int> entryIds) {
    if (entryIds.isEmpty) {
      return Future<void>.value();
    }
    return (update(dialogueHistoryEntries)..where((t) => t.id.isIn(entryIds)))
        .write(const DialogueHistoryEntriesCompanion(synced: Value(true)));
  }

  // --- SRS / FSRS queries ---

  Future<List<SrsCardRow>> getDueSrsCards({
    required DateTime asOf,
    required int limit,
  }) {
    return (select(srsCards)
          ..where((t) => t.dueAt.isSmallerOrEqualValue(asOf))
          ..orderBy([(t) => OrderingTerm.asc(t.dueAt)])
          ..limit(limit))
        .get();
  }

  Future<int> countAllSrsCards() async {
    final rows = await select(srsCards).get();
    return rows.length;
  }

  Future<SrsCardRow?> findSrsCardById(String cardId) {
    return (select(srsCards)..where((t) => t.id.equals(cardId)))
        .getSingleOrNull();
  }

  Future<List<SrsCardRow>> searchSrsCardsByNormalizedHebrew(
    String normalizedQuery,
  ) {
    return (select(srsCards)
          ..where((t) => t.hebrewNormalized.contains(normalizedQuery)))
        .get();
  }

  Future<void> upsertSrsCard(SrsCardsCompanion card) {
    return into(srsCards).insertOnConflictUpdate(card);
  }

  Future<void> upsertSrsCardsIfAbsent(List<SrsCardsCompanion> cards) {
    return batch((batch) {
      batch.insertAll(
        srsCards,
        cards,
        mode: InsertMode.insertOrIgnore,
      );
    });
  }

  Future<void> saveSrsReviewTransaction({
    required SrsCardsCompanion updatedCard,
    required SrsReviewLogsCompanion reviewLog,
  }) {
    return transaction(() async {
      await into(srsCards).insertOnConflictUpdate(updatedCard);
      await into(srsReviewLogs).insert(reviewLog);
    });
  }

  // --- Grammar queries ---

  Future<int> countGrammarVerbs() async {
    final rows = await select(grammarVerbs).get();
    return rows.length;
  }

  Future<List<GrammarVerbRow>> getGrammarVerbs({String? binyanFilter}) {
    final query = select(grammarVerbs);
    if (binyanFilter != null && binyanFilter.isNotEmpty) {
      query.where((t) => t.binyan.equals(binyanFilter));
    }
    return query.get();
  }

  Future<List<GrammarVerbRow>> searchGrammarVerbs(String normalizedQuery) {
    return (select(grammarVerbs)
          ..where(
            (t) =>
                t.lemmaNormalized.contains(normalizedQuery) |
                t.root.contains(normalizedQuery),
          ))
        .get();
  }

  Future<void> upsertGrammarVerbs(List<GrammarVerbsCompanion> rows) {
    return batch((batch) {
      batch.insertAllOnConflictUpdate(grammarVerbs, rows);
    });
  }

  Future<int> insertGrammarPracticeLog({
    required String verbId,
    required String tense,
    required String person,
    required bool isCorrect,
    required DateTime practicedAt,
  }) {
    return into(grammarPracticeLogs).insert(
      GrammarPracticeLogsCompanion.insert(
        verbId: verbId,
        tense: tense,
        person: person,
        isCorrect: isCorrect,
        practicedAt: practicedAt,
      ),
    );
  }

  // --- Listening queries ---

  Future<int> countListeningExercises() async {
    final rows = await select(listeningExercises).get();
    return rows.length;
  }

  Future<List<ListeningExerciseRow>> getListeningExercises({
    String? difficultyFilter,
  }) {
    final query = select(listeningExercises);
    if (difficultyFilter != null && difficultyFilter.isNotEmpty) {
      query.where((t) => t.difficulty.equals(difficultyFilter));
    }
    return query.get();
  }

  Future<void> upsertListeningExercisesIfAbsent(
    List<ListeningExercisesCompanion> rows,
  ) {
    return batch((batch) {
      batch.insertAll(
        listeningExercises,
        rows,
        mode: InsertMode.insertOrIgnore,
      );
    });
  }

  Future<int> insertListeningAttemptLog({
    required String exerciseId,
    required double wordAccuracy,
    required bool isExactMatch,
    required DateTime attemptedAt,
  }) {
    return into(listeningAttemptLogs).insert(
      ListeningAttemptLogsCompanion.insert(
        exerciseId: exerciseId,
        wordAccuracy: wordAccuracy,
        isExactMatch: isExactMatch,
        attemptedAt: attemptedAt,
      ),
    );
  }

  // --- Progress & cross-feature queries ---

  Future<List<DialogueNodeRow>> getAllDialogueNodes() {
    return select(dialogueNodes).get();
  }

  Future<List<SrsCardRow>> getAllSrsCards() {
    return select(srsCards).get();
  }

  Future<List<SrsReviewLogRow>> getAllSrsReviewLogs() {
    return select(srsReviewLogs).get();
  }

  Future<List<GrammarPracticeLogRow>> getAllGrammarPracticeLogs() {
    return select(grammarPracticeLogs).get();
  }

  Future<List<ListeningAttemptLogRow>> getAllListeningAttemptLogs() {
    return select(listeningAttemptLogs).get();
  }

  // --- Dictionary queries ---

  Future<int> countDictionaryEntries() async {
    final rows = await select(dictionaryEntries).get();
    return rows.length;
  }

  Future<List<DictionaryEntryRow>> getAllDictionaryEntries() {
    return (select(dictionaryEntries)
          ..orderBy([
            (t) => OrderingTerm.asc(t.frequencyRank),
            (t) => OrderingTerm.asc(t.hebrewNormalized),
          ]))
        .get();
  }

  Future<void> upsertDictionaryEntriesIfAbsent(
    List<DictionaryEntriesCompanion> rows,
  ) {
    return batch((batch) {
      batch.insertAll(
        dictionaryEntries,
        rows,
        mode: InsertMode.insertOrIgnore,
      );
    });
  }

  Future<void> upsertDictionaryEntry(DictionaryEntriesCompanion row) {
    return into(dictionaryEntries).insertOnConflictUpdate(row);
  }

  /// Populates missing local audio paths on already-seeded rows without
  /// overwriting existing external URLs or user FSRS/practice progress.
  Future<void> backfillSeedAudio({
    required Map<String, String> dialogueAudioById,
    required Map<String, String> listeningAudioById,
    required Map<String, String> srsAudioById,
    Map<String, String> dictionaryAudioById = const <String, String>{},
  }) {
    return transaction(() async {
      for (final entry in dialogueAudioById.entries) {
        await (update(dialogueNodes)
              ..where(
                (t) =>
                    t.id.equals(entry.key) &
                    (t.audioPath.isNull() | t.audioPath.equals('')),
              ))
            .write(DialogueNodesCompanion(audioPath: Value(entry.value)));
      }
      for (final entry in listeningAudioById.entries) {
        await (update(listeningExercises)
              ..where(
                (t) =>
                    t.id.equals(entry.key) &
                    (t.audioUrl.isNull() | t.audioUrl.equals('')),
              ))
            .write(ListeningExercisesCompanion(audioUrl: Value(entry.value)));
      }
      for (final entry in srsAudioById.entries) {
        await (update(srsCards)
              ..where(
                (t) =>
                    t.id.equals(entry.key) &
                    (t.audioUrl.isNull() | t.audioUrl.equals('')),
              ))
            .write(SrsCardsCompanion(audioUrl: Value(entry.value)));
      }
      for (final entry in dictionaryAudioById.entries) {
        await (update(dictionaryEntries)
              ..where(
                (t) =>
                    t.id.equals(entry.key) &
                    (t.audioUrl.isNull() | t.audioUrl.equals('')),
              ))
            .write(DictionaryEntriesCompanion(audioUrl: Value(entry.value)));
      }
    });
  }

  // --- Israeli Life Scenes queries ---
  Future<List<SceneProgressRow>> getAllSceneProgress() =>
      select(sceneProgressEntries).get();

  Future<SceneProgressRow?> getSceneProgress(String sceneId) =>
      (select(sceneProgressEntries)..where((tbl) => tbl.sceneId.equals(sceneId)))
          .getSingleOrNull();

  Future<void> upsertSceneProgress({
    required String sceneId,
    required bool isCompleted,
    required int wordsMasteredCount,
    required int challengeScore,
    required DateTime lastVisitedAt,
  }) =>
      into(sceneProgressEntries).insertOnConflictUpdate(
        SceneProgressEntriesCompanion(
          sceneId: Value(sceneId),
          isCompleted: Value(isCompleted),
          wordsMasteredCount: Value(wordsMasteredCount),
          challengeScore: Value(challengeScore),
          lastVisitedAt: Value(lastVisitedAt),
        ),
      );

  // --- Shoresh Detective queries ---
  Future<List<ShoreshProgressRow>> getAllShoreshProgress() =>
      select(shoreshProgressEntries).get();

  Future<ShoreshProgressRow?> getShoreshProgress(String rootId) =>
      (select(shoreshProgressEntries)..where((tbl) => tbl.rootId.equals(rootId)))
          .getSingleOrNull();

  Future<void> upsertShoreshProgress({
    required String rootId,
    required double masteryLevel,
    required int cardsPracticedCount,
    required int quizCorrectCount,
    DateTime? lastPracticedAt,
    bool? isBookmarked,
  }) =>
      into(shoreshProgressEntries).insertOnConflictUpdate(
        ShoreshProgressEntriesCompanion(
          rootId: Value(rootId),
          masteryLevel: Value(masteryLevel),
          cardsPracticedCount: Value(cardsPracticedCount),
          quizCorrectCount: Value(quizCorrectCount),
          lastPracticedAt: Value(lastPracticedAt),
          isBookmarked: isBookmarked != null
              ? Value(isBookmarked)
              : const Value.absent(),
        ),
      );
}
