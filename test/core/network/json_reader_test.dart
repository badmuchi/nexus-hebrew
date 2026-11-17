import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_hebrew_app/core/error/failures.dart';
import 'package:nexus_hebrew_app/core/network/json_reader.dart';
import 'package:nexus_hebrew_app/core/result/result.dart';

void main() {
  group('JsonReader', () {
    test('корректно парсит валидный JSON-объект и извлекает поля', () {
      const payload = '''
      {
        "id": "node_1",
        "audio_path": null,
        "options": [{"id": "opt_1"}]
      }
      ''';

      final readerRes = JsonReader.parseObject(payload);
      expect(readerRes, isA<Success<JsonReader, ParsingFailure>>());

      final reader = readerRes.getOrNull()!;
      expect(reader.requireNonEmptyString('id').getOrNull(), equals('node_1'));
      expect(reader.optionalNonEmptyString('audio_path').getOrNull(), isNull);
      expect(reader.requireObjectList('options').getOrNull()?.length, equals(1));
    });

    test('возвращает ParsingFailure для битого JSON и неверных типов полей', () {
      expect(
        JsonReader.parseObject('{invalid'),
        isA<Error<JsonReader, ParsingFailure>>(),
      );
      expect(
        JsonReader.parseObject('   '),
        isA<Error<JsonReader, ParsingFailure>>(),
      );

      final reader = JsonReader.parseObject('{"id": 123, "empty": "  ", "options": "not_list"}')
          .getOrNull()!;

      expect(
        reader.requireNonEmptyString('id'),
        isA<Error<String, ParsingFailure>>(),
      );
      expect(
        reader.requireNonEmptyString('empty'),
        isA<Error<String, ParsingFailure>>(),
      );
      expect(
        reader.requireObjectList('options'),
        isA<Error<List<JsonReader>, ParsingFailure>>(),
      );
    });

    test('optionalInt корректно обрабатывает int, null/отсутствие и невалидные типы', () {
      final reader = JsonReader.parseObject(
        '{"rank": 42, "empty_rank": null, "bad_rank": "high", "float_rank": 3.5}',
      ).getOrNull()!;

      expect(reader.optionalInt('rank'), equals(const Success<int?, ParsingFailure>(42)));
      expect(
        reader.optionalInt('empty_rank'),
        equals(const Success<int?, ParsingFailure>(null)),
      );
      expect(
        reader.optionalInt('missing_rank'),
        equals(const Success<int?, ParsingFailure>(null)),
      );
      expect(
        reader.optionalInt('bad_rank'),
        isA<Error<int?, ParsingFailure>>(),
      );
      expect(
        reader.optionalInt('float_rank'),
        isA<Error<int?, ParsingFailure>>(),
      );
    });
  });
}
