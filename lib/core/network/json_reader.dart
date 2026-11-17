import 'dart:convert';

import '../error/failures.dart';
import '../result/result.dart';

/// Strict boundary reader over decoded JSON objects that forbids `dynamic`
/// and avoids unvalidated raw casts across the Data layer.
final class JsonReader {
  final Map<String, Object?> _data;

  const JsonReader._(this._data);

  static Result<JsonReader, ParsingFailure> parseObject(String rawJson) {
    if (rawJson.trim().isEmpty) {
      return const Error(ParsingFailure('JSON payload cannot be empty'));
    }
    try {
      final decoded = jsonDecode(rawJson);
      return _fromDecodedObject(decoded);
    } on FormatException catch (error) {
      return Error(ParsingFailure('Malformed JSON: ${error.message}'));
    }
  }

  static Result<List<JsonReader>, ParsingFailure> parseObjectList(
    String rawJson,
  ) {
    if (rawJson.trim().isEmpty) {
      return const Error(ParsingFailure('JSON array payload cannot be empty'));
    }
    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is! List<Object?>) {
        return const Error(
          ParsingFailure('Expected top-level JSON array'),
        );
      }
      final readers = <JsonReader>[];
      for (var i = 0; i < decoded.length; i++) {
        final itemResult = _fromDecodedObject(decoded[i]);
        switch (itemResult) {
          case Success<JsonReader, ParsingFailure>(:final data):
            readers.add(data);
          case Error<JsonReader, ParsingFailure>(:final failure):
            return Error(
              ParsingFailure('Item at index $i: ${failure.message}'),
            );
        }
      }
      return Success(List<JsonReader>.unmodifiable(readers));
    } on FormatException catch (error) {
      return Error(ParsingFailure('Malformed JSON array: ${error.message}'));
    }
  }

  static Result<JsonReader, ParsingFailure> fromRawMap(
    Map<Object?, Object?> rawMap,
  ) {
    return _fromDecodedObject(rawMap);
  }

  static Result<JsonReader, ParsingFailure> _fromDecodedObject(Object? value) {
    if (value is! Map<Object?, Object?>) {
      return const Error(ParsingFailure('Expected JSON object'));
    }
    final typedMap = <String, Object?>{};
    for (final entry in value.entries) {
      final key = entry.key;
      if (key is! String) {
        return const Error(
          ParsingFailure('JSON object contains a non-string key'),
        );
      }
      typedMap[key] = entry.value;
    }
    return Success(JsonReader._(Map<String, Object?>.unmodifiable(typedMap)));
  }

  Result<String, ParsingFailure> requireNonEmptyString(String key) {
    final value = _data[key];
    if (value is! String) {
      return Error(
        ParsingFailure('Field "$key" is missing or not a String'),
      );
    }
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return Error(ParsingFailure('Field "$key" must not be empty'));
    }
    return Success(trimmed);
  }

  Result<String?, ParsingFailure> optionalNonEmptyString(String key) {
    if (!_data.containsKey(key) || _data[key] == null) {
      return const Success(null);
    }
    final value = _data[key];
    if (value is! String) {
      return Error(ParsingFailure('Field "$key" must be a String or null'));
    }
    final trimmed = value.trim();
    return Success(trimmed.isEmpty ? null : trimmed);
  }

  Result<int, ParsingFailure> requireInt(String key) {
    final value = _data[key];
    if (value is int) {
      return Success(value);
    }
    if (value is String) {
      final parsed = int.tryParse(value.trim());
      if (parsed != null) {
        return Success(parsed);
      }
    }
    return Error(ParsingFailure('Field "$key" is missing or not an integer'));
  }

  Result<int?, ParsingFailure> optionalInt(String key) {
    if (!_data.containsKey(key) || _data[key] == null) {
      return const Success(null);
    }
    final value = _data[key];
    if (value is int) {
      return Success(value);
    }
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) {
        return const Success(null);
      }
      final parsed = int.tryParse(trimmed);
      if (parsed != null) {
        return Success(parsed);
      }
    }
    return Error(ParsingFailure('Field "$key" must be an integer or null'));
  }

  Result<List<JsonReader>, ParsingFailure> requireObjectList(String key) {
    final value = _data[key];
    if (value is! List<Object?>) {
      return Error(
        ParsingFailure('Field "$key" is missing or not a JSON array'),
      );
    }
    return _readObjectArray(value, fieldLabel: key);
  }

  Result<List<JsonReader>, ParsingFailure> optionalObjectList(String key) {
    if (!_data.containsKey(key) || _data[key] == null) {
      return const Success(<JsonReader>[]);
    }
    return requireObjectList(key);
  }

  /// Reads either `[ {...}, ... ]` or nested `[ [{...}], ... ]` arrays (e.g. Tatoeba translations).
  Result<List<JsonReader>, ParsingFailure> optionalFlattenedObjectList(
    String key,
  ) {
    if (!_data.containsKey(key) || _data[key] == null) {
      return const Success(<JsonReader>[]);
    }
    final value = _data[key];
    if (value is! List<Object?>) {
      return Error(ParsingFailure('Field "$key" must be a JSON array'));
    }

    final flattened = <JsonReader>[];
    for (var i = 0; i < value.length; i++) {
      final item = value[i];
      if (item is List<Object?>) {
        final nestedRes = _readObjectArray(item, fieldLabel: '$key[$i]');
        switch (nestedRes) {
          case Success(:final data):
            flattened.addAll(data);
          case Error(:final failure):
            return Error(failure);
        }
      } else {
        final objRes = _fromDecodedObject(item);
        switch (objRes) {
          case Success(:final data):
            flattened.add(data);
          case Error(:final failure):
            return Error(ParsingFailure('Field "$key"[$i]: ${failure.message}'));
        }
      }
    }
    return Success(List<JsonReader>.unmodifiable(flattened));
  }

  Result<List<JsonReader>, ParsingFailure> firstPresentObjectList(
    List<String> candidateKeys,
  ) {
    for (final key in candidateKeys) {
      if (_data.containsKey(key) && _data[key] != null) {
        return requireObjectList(key);
      }
    }
    return Error(
      ParsingFailure(
        'None of expected array keys (${candidateKeys.join(', ')}) were present',
      ),
    );
  }

  static Result<List<JsonReader>, ParsingFailure> _readObjectArray(
    List<Object?> items, {
    required String fieldLabel,
  }) {
    final readers = <JsonReader>[];
    for (var i = 0; i < items.length; i++) {
      final itemResult = _fromDecodedObject(items[i]);
      switch (itemResult) {
        case Success<JsonReader, ParsingFailure>(:final data):
          readers.add(data);
        case Error<JsonReader, ParsingFailure>(:final failure):
          return Error(
            ParsingFailure('Field "$fieldLabel"[$i]: ${failure.message}'),
          );
      }
    }
    return Success(List<JsonReader>.unmodifiable(readers));
  }

  Result<List<String>, ParsingFailure> optionalStringList(String key) {
    if (!_data.containsKey(key) || _data[key] == null) {
      return const Success(<String>[]);
    }
    final value = _data[key];
    return _readStringArray(value, fieldLabel: key);
  }

  static Result<List<String>, ParsingFailure> parseStringList(String rawJson) {
    if (rawJson.trim().isEmpty) {
      return const Error(ParsingFailure('JSON string array cannot be empty'));
    }
    try {
      final decoded = jsonDecode(rawJson);
      return _readStringArray(decoded, fieldLabel: 'root');
    } on FormatException catch (error) {
      return Error(
        ParsingFailure('Malformed JSON string array: ${error.message}'),
      );
    }
  }

  static Result<List<String>, ParsingFailure> _readStringArray(
    Object? value, {
    required String fieldLabel,
  }) {
    if (value is! List<Object?>) {
      return Error(ParsingFailure('Field "$fieldLabel" must be a JSON array'));
    }
    final strings = <String>[];
    for (var i = 0; i < value.length; i++) {
      final item = value[i];
      if (item is! String) {
        return Error(
          ParsingFailure('Field "$fieldLabel"[$i] must be a String'),
        );
      }
      final trimmed = item.trim();
      if (trimmed.isNotEmpty) {
        strings.add(trimmed);
      }
    }
    return Success(List<String>.unmodifiable(strings));
  }

  Map<String, Object?> toUnmodifiableMap() => _data;
}
