import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/core/error/failures.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';
import 'package:nexus_hebrew_app/features/conversation/domain/entities/hebrew_text.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/fsrs_models.dart';
import 'package:nexus_hebrew_app/features/srs/domain/entities/srs_card.dart';
import 'package:nexus_hebrew_app/features/srs/domain/usecases/check_hebrew_typed_answer.dart';

void main() {
  const useCase = CheckHebrewTypedAnswerUseCase();
  final card = SrsCard(
    id: 'srs_ledaber',
    hebrew: const HebrewText.fixture(vocalized: 'לְדַבֵּר', normalized: 'לדבר'),
    russianTranslation: 'Говорить',
    attribution: const ContentAttribution(
      sourceName: 'Wiktionary / Kaikki Hebrew',
      licenseName: 'CC BY-SA 4.0',
    ),
    memory: FsrsMemoryState.initial(now: DateTime.utc(2026, 11, 11)),
  );

  group('CheckHebrewTypedAnswerUseCase', () {
    test('засчитывает ответ без огласовок и в другой форме Unicode-нормализации', () {
      final result = useCase.execute(card: card, rawUserInput: '  לדבר  ');

      expect(result, isA<Success<TypingAnswerEvaluation, Failure>>());
      final eval = result.getOrNull()!;
      expect(eval.isMatch, isTrue);
      expect(eval.expectedNormalized, equals('לדבר'));
      expect(eval.expectedVocalized, equals('לְדַבֵּר'));
    });

    test('фиксирует несовпадение при ошибке в буквах', () {
      final result = useCase.execute(card: card, rawUserInput: 'לכתוב');

      expect(result, isA<Success<TypingAnswerEvaluation, Failure>>());
      final eval = result.getOrNull()!;
      expect(eval.isMatch, isFalse);
      expect(eval.normalizedUserInput, equals('לכתוב'));
    });

    test('возвращает ValidationFailure для пустого ввода или одних огласовок', () {
      final emptyRes = useCase.execute(card: card, rawUserInput: '   ');
      final nikkudOnlyRes = useCase.execute(card: card, rawUserInput: '\u05B8');

      expect(emptyRes.failureOrNull(), isA<ValidationFailure>());
      expect(nikkudOnlyRes.failureOrNull(), isA<ValidationFailure>());
    });
  });
}
