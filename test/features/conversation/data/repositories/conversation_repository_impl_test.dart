import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_hebrew_app/core/error/failures.dart';
import 'package:nexus_hebrew_app/core/logging/app_logger.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/conversation/data/datasources/dialogue_local_datasource.dart';
import 'package:nexus_hebrew_app/features/conversation/data/datasources/dialogue_remote_datasource.dart';
import 'package:nexus_hebrew_app/features/conversation/data/datasources/dialogue_seed_datasource.dart';
import 'package:nexus_hebrew_app/features/conversation/data/models/dialogue_node_dto.dart';
import 'package:nexus_hebrew_app/features/conversation/data/repositories/conversation_repository_impl.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/dialogue_node.dart';

class _MockLocalDataSource extends Mock implements DialogueLocalDataSource {}

class _MockRemoteDataSource extends Mock implements DialogueRemoteDataSource {}

class _MockSeedDataSource extends Mock implements DialogueSeedDataSource {}

void main() {
  late _MockLocalDataSource localDataSource;
  late _MockRemoteDataSource remoteDataSource;
  late _MockSeedDataSource seedDataSource;
  late ConversationRepositoryImpl repository;

  final seedNodeDto = DialogueNodeDto(
    id: 'node_market_start',
    speakerHebrew: 'מוֹכֵר',
    speakerRussian: 'Продавец',
    lineHebrew: 'שָׁלוֹם!',
    lineRussian: 'Привет!',
    options: const [],
  );

  final remoteNodeDto = DialogueNodeDto(
    id: 'node_remote_only',
    speakerHebrew: 'בָּרִיסְטָה',
    speakerRussian: 'Бариста',
    lineHebrew: 'מָה לְהָכִין?',
    lineRussian: 'Что приготовить?',
    options: const [],
  );

  setUpAll(() {
    registerFallbackValue(seedNodeDto);
  });

  setUp(() {
    localDataSource = _MockLocalDataSource();
    remoteDataSource = _MockRemoteDataSource();
    seedDataSource = _MockSeedDataSource();

    when(() => seedDataSource.loadAllSeedNodes())
        .thenAnswer((_) async => Success([seedNodeDto]));
    when(() => localDataSource.cacheNodes(any()))
        .thenAnswer((_) async => const Success(null));
    when(() => localDataSource.cacheNode(any()))
        .thenAnswer((_) async => const Success(null));

    repository = ConversationRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
      seedDataSource: seedDataSource,
      logger: const NoOpAppLogger(),
    );
  });

  group('ConversationRepositoryImpl', () {
    test('возвращает узел из локального кеша без обращения к сети', () async {
      when(() => localDataSource.getCachedNode('node_market_start'))
          .thenAnswer((_) async => Success(seedNodeDto));

      final result = await repository.getDialogueNode('node_market_start');

      expect(result, isA<Success<DialogueNode, Failure>>());
      expect(result.getOrNull()?.id, equals('node_market_start'));
      verifyNever(() => remoteDataSource.fetchNode(any()));
    });

    test('при отсутствии в кеше и seed обращается к remote и кеширует ответ', () async {
      when(() => localDataSource.getCachedNode('node_remote_only'))
          .thenAnswer((_) async => const Success(null));
      when(() => seedDataSource.findSeedNodeById('node_remote_only'))
          .thenAnswer((_) async => const Success(null));
      when(() => remoteDataSource.isRemoteEnabled).thenReturn(true);
      when(() => remoteDataSource.fetchNode('node_remote_only'))
          .thenAnswer((_) async => Success(remoteNodeDto));

      final result = await repository.getDialogueNode('node_remote_only');

      expect(result, isA<Success<DialogueNode, Failure>>());
      expect(result.getOrNull()?.id, equals('node_remote_only'));
      verify(() => localDataSource.cacheNode(remoteNodeDto)).called(1);
    });

    test('в offline-режиме возвращает CacheFailure если узла нет ни в кеше, ни в seed', () async {
      when(() => localDataSource.getCachedNode('missing_node'))
          .thenAnswer((_) async => const Success(null));
      when(() => seedDataSource.findSeedNodeById('missing_node'))
          .thenAnswer((_) async => const Success(null));
      when(() => remoteDataSource.isRemoteEnabled).thenReturn(false);

      final result = await repository.getDialogueNode('missing_node');

      expect(result, isA<Error<DialogueNode, Failure>>());
      expect(result.failureOrNull(), isA<CacheFailure>());
    });

    test('syncDialogueHistory синхронизирует записи при включённом remote и помечает их', () async {
      final pending = [
        DialogueHistoryRecord(
          entryId: 42,
          nodeId: 'node_market_start',
          selectedOptionId: 'opt_coffee',
          answeredAt: DateTime.utc(2026, 11, 11),
        ),
      ];
      when(() => localDataSource.getUnsyncedHistory())
          .thenAnswer((_) async => Success(pending));
      when(() => remoteDataSource.isRemoteEnabled).thenReturn(true);
      when(() => remoteDataSource.pushHistory(pending))
          .thenAnswer((_) async => const Success(null));
      when(() => localDataSource.markHistorySynced([42]))
          .thenAnswer((_) async => const Success(null));

      final result = await repository.syncDialogueHistory();

      expect(result, equals(const Success<int, Failure>(1)));
      verify(() => localDataSource.markHistorySynced([42])).called(1);
    });
  });
}
