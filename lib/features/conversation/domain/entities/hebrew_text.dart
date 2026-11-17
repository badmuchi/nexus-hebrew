import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../../../core/utils/hebrew_normalizer.dart';

final class HebrewText extends Equatable {
  final String vocalized;
  final String normalized;

  const HebrewText._({
    required this.vocalized,
    required this.normalized,
  });

  /// Const constructor for deterministic unit test fixtures where both forms are explicit.
  const HebrewText.fixture({
    required this.vocalized,
    required this.normalized,
  });

  static Result<HebrewText, ValidationFailure> create(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return const Error(
        ValidationFailure('Hebrew text cannot be empty'),
      );
    }

    final vocalizedNfc = HebrewNormalizer.toNfc(trimmed);
    final normalized = HebrewNormalizer.normalizeForComparison(trimmed);
    if (normalized.isEmpty) {
      return const Error(
        ValidationFailure('Hebrew text must contain visible characters'),
      );
    }

    return Success(
      HebrewText._(
        vocalized: vocalizedNfc,
        normalized: normalized,
      ),
    );
  }

  bool matchesInput(
    String rawUserInput, {
    bool normalizeFinalForms = false,
  }) {
    final normalizedInput = HebrewNormalizer.normalizeForComparison(
      rawUserInput,
      normalizeFinalForms: normalizeFinalForms,
    );
    final comparableTarget = normalizeFinalForms
        ? HebrewNormalizer.replaceFinalLetters(normalized)
        : normalized;
    return normalizedInput == comparableTarget;
  }

  @override
  List<Object?> get props => [vocalized, normalized];
}

final class Shoresh extends Equatable {
  final List<String> letters;

  Shoresh._(List<String> letters)
      : letters = List<String>.unmodifiable(letters);

  const Shoresh.fixture(this.letters);

  static Result<Shoresh, ValidationFailure> create(String raw) {
    final pureLetters = HebrewNormalizer.extractHebrewLetters(raw);
    final runes = pureLetters.runes.toList(growable: false);
    if (runes.length < 3 || runes.length > 4) {
      return Error(
        ValidationFailure(
          'Shoresh must contain 3 or 4 Hebrew letters, got ${runes.length} in "$raw"',
        ),
      );
    }
    final charList = runes
        .map((rune) => String.fromCharCode(rune))
        .toList(growable: false);
    return Success(Shoresh._(charList));
  }

  String get hyphenated => letters.join('-');
  String get compact => letters.join();

  @override
  List<Object?> get props => [letters];
}
