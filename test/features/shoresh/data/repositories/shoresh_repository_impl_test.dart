import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/database/app_database.dart';
import 'package:nexus_hebrew_app/core/error/failures.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/shoresh/data/repositories/shoresh_repository_impl.dart';

class _MockAppDatabase extends Mock implements AppDatabase {}

void main() {
  group('ShoreshRepositoryImpl', () {
    test('getAllRoots and getRootById work without database', () {
      final repo = ShoreshRepositoryImpl();
      final all = repo.getAllRoots();
      expect(all.length, greaterThanOrEqualTo(20));

      final ktv = repo.getRootById('root_ktv');
      expect(ktv, isNotNull);
      expect(ktv?.lettersDisplay, 'כ-ת-ב');
      expect(ktv?.derivatives.length, equals(5));

      final notFound = repo.getRootById('unknown_root_id');
      expect(notFound, isNull);
    });

    test('getMasteredRootIds and recordRootMastery work in in-memory mode', () async {
      final repo = ShoreshRepositoryImpl();

      final initial = await repo.getMasteredRootIds();
      expect(initial, isA<Success<Map<String, bool>, Failure>>());
      expect(initial.getOrNull(), isEmpty);

      final recordRes = await repo.recordRootMastery(
        rootId: 'root_ktv',
        isMastered: true,
        quizCorrectIncrement: 2,
      );
      expect(recordRes, isA<Success<void, Failure>>());

      final updated = await repo.getMasteredRootIds();
      final map = updated.getOrNull();
      expect(map?['root_ktv'], isTrue);
    });

    test('getMasteredRootIds loads from database when provided', () async {
      final db = _MockAppDatabase();
      final repo = ShoreshRepositoryImpl(database: db);

      when(() => db.getAllShoreshProgress()).thenAnswer(
        (_) async => [
          ShoreshProgressRow(
            rootId: 'root_ktv',
            masteryLevel: 0.9,
            cardsPracticedCount: 5,
            quizCorrectCount: 4,
            isBookmarked: false,
            lastPracticedAt: DateTime.utc(2026, 11, 21),
          ),
          ShoreshProgressRow(
            rootId: 'root_lmd',
            masteryLevel: 0.5,
            cardsPracticedCount: 2,
            quizCorrectCount: 1,
            isBookmarked: false,
            lastPracticedAt: DateTime.utc(2026, 11, 21),
          ),
        ],
      );

      final res = await repo.getMasteredRootIds();
      expect(res, isA<Success<Map<String, bool>, Failure>>());
      final map = res.getOrNull()!;
      expect(map['root_ktv'], isTrue);
      expect(map['root_lmd'], isFalse);
    });

    test('getMasteredRootIds returns CacheFailure on database exception', () async {
      final db = _MockAppDatabase();
      final repo = ShoreshRepositoryImpl(database: db);

      when(() => db.getAllShoreshProgress()).thenThrow(Exception('DB error'));

      final res = await repo.getMasteredRootIds();
      expect(res, isA<Error<Map<String, bool>, Failure>>());
      expect(res.failureOrNull(), isA<CacheFailure>());
    });

    test('recordRootMastery upserts into database', () async {
      final db = _MockAppDatabase();
      final repo = ShoreshRepositoryImpl(database: db);

      when(() => db.getShoreshProgress('root_ktv')).thenAnswer((_) async => null);
      when(
        () => db.upsertShoreshProgress(
          rootId: any(named: 'rootId'),
          masteryLevel: any(named: 'masteryLevel'),
          cardsPracticedCount: any(named: 'cardsPracticedCount'),
          quizCorrectCount: any(named: 'quizCorrectCount'),
          lastPracticedAt: any(named: 'lastPracticedAt'),
        ),
      ).thenAnswer((_) async {});

      final res = await repo.recordRootMastery(
        rootId: 'root_ktv',
        isMastered: true,
        quizCorrectIncrement: 3,
      );
      expect(res, isA<Success<void, Failure>>());

      verify(
        () => db.upsertShoreshProgress(
          rootId: 'root_ktv',
          masteryLevel: 1.0,
          cardsPracticedCount: 1,
          quizCorrectCount: 3,
          lastPracticedAt: any(named: 'lastPracticedAt'),
        ),
      ).called(1);
    });

    test('generateQuizQuestions returns limited questions with valid data', () {
      final repo = ShoreshRepositoryImpl();
      final questions = repo.generateQuizQuestions(count: 3);

      expect(questions.length, equals(3));
      for (final q in questions) {
        expect(q.wordVocalized.isNotEmpty, isTrue);
        expect(q.options.length, greaterThanOrEqualTo(3));
        expect(q.correctIndex, inInclusiveRange(0, q.options.length - 1));
      }
    });
  });
}
