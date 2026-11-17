import 'package:equatable/equatable.dart';

import '../../../../core/utils/hebrew_normalizer.dart';
import '../../../conversation/domain/entities/hebrew_text.dart';

/// The morphological grammatical role of a segment in a conjugated Hebrew verb.
enum MorphologicalRole {
  /// Prefix indicating tense (e.g., future א/ת/י/נ) or binyan marker (e.g., הִ/מִ/נִ/הִתְ).
  prefix,

  /// Root consonant (אות שורש) belonging to the 3 or 4-letter root.
  root,

  /// Stem vowel/infix characteristic of the binyan pattern (e.g., י in Hif'il or וֹ in Pa'al).
  infix,

  /// Suffix indicating grammatical person, gender, or number (e.g., תִּי, תָּ, נוּ, ים, ות).
  suffix,

  /// Fallback general stem when precise morphological dissection is unavailable.
  base;

  String get localizedNameRu => switch (this) {
        MorphologicalRole.prefix => 'Приставка',
        MorphologicalRole.root => 'Корень (שורש)',
        MorphologicalRole.infix => 'Гласная основа',
        MorphologicalRole.suffix => 'Окончание',
        MorphologicalRole.base => 'Основа',
      };
}

/// An immutable segment of a Hebrew verb form with its morphological classification.
final class ConjugationSegment extends Equatable {
  const ConjugationSegment({
    required this.text,
    required this.role,
  });

  final String text;
  final MorphologicalRole role;

  @override
  List<Object?> get props => [text, role];

  @override
  String toString() => 'ConjugationSegment($role: "$text")';
}

/// Deconstructs conjugated Hebrew verb forms into color-codeable morphological segments.
final class HebrewConjugationHighlighter {
  const HebrewConjugationHighlighter();

  static final RegExp _clusterRegex = RegExp(r'[\u05D0-\u05EA][\u0591-\u05C7]*');

  /// Splits [vocalizedForm] into a list of [ConjugationSegment]s according to [root].
  List<ConjugationSegment> highlight({
    required String vocalizedForm,
    required Shoresh root,
  }) {
    final trimmed = vocalizedForm.trim();
    if (trimmed.isEmpty) return const [];

    final matches = _clusterRegex.allMatches(trimmed).toList(growable: false);
    if (matches.isEmpty) {
      return [ConjugationSegment(text: trimmed, role: MorphologicalRole.base)];
    }

    final rootLetters = root.letters
        .map((l) => HebrewNormalizer.replaceFinalLetters(HebrewNormalizer.stripNikkud(l)))
        .toList(growable: false);

    final clusterBaseLetters = matches.map((m) {
      final rawLetter = m.group(0)!;
      final stripped = HebrewNormalizer.stripNikkud(rawLetter);
      return HebrewNormalizer.replaceFinalLetters(stripped);
    }).toList(growable: false);

    // Find the subsequence indices of root letters in the cluster list
    final rootIndices = <int>[];
    int searchStart = 0;

    for (final rLetter in rootLetters) {
      int foundIndex = -1;
      for (int i = searchStart; i < clusterBaseLetters.length; i++) {
        if (clusterBaseLetters[i] == rLetter) {
          foundIndex = i;
          break;
        }
      }
      if (foundIndex != -1) {
        rootIndices.add(foundIndex);
        searchStart = foundIndex + 1;
      } else {
        // If a root letter is missing (e.g. weak/defective root גזרת חסרי פ״נ or פ״י),
        // we can still highlight the other root letters found.
      }
    }

    if (rootIndices.isEmpty) {
      return [ConjugationSegment(text: trimmed, role: MorphologicalRole.base)];
    }

    final firstRootIdx = rootIndices.first;
    final lastRootIdx = rootIndices.last;
    final rootSet = rootIndices.toSet();

    final rawSegments = <ConjugationSegment>[];

    for (int i = 0; i < matches.length; i++) {
      final clusterText = matches[i].group(0)!;
      final MorphologicalRole role;

      if (rootSet.contains(i)) {
        role = MorphologicalRole.root;
      } else if (i < firstRootIdx) {
        role = MorphologicalRole.prefix;
      } else if (i > lastRootIdx) {
        role = MorphologicalRole.suffix;
      } else {
        // Inside between root consonants (e.g. infix 'י' in Hif'il or 'ו' in Pa'al)
        role = MorphologicalRole.infix;
      }

      rawSegments.add(ConjugationSegment(text: clusterText, role: role));
    }

    return _mergeAdjacentSegments(rawSegments);
  }

  List<ConjugationSegment> _mergeAdjacentSegments(List<ConjugationSegment> segments) {
    if (segments.isEmpty) return const [];

    final merged = <ConjugationSegment>[];
    var currentRole = segments.first.role;
    var currentBuffer = StringBuffer(segments.first.text);

    for (int i = 1; i < segments.length; i++) {
      final seg = segments[i];
      if (seg.role == currentRole) {
        currentBuffer.write(seg.text);
      } else {
        merged.add(ConjugationSegment(text: currentBuffer.toString(), role: currentRole));
        currentRole = seg.role;
        currentBuffer = StringBuffer(seg.text);
      }
    }
    merged.add(ConjugationSegment(text: currentBuffer.toString(), role: currentRole));

    return List<ConjugationSegment>.unmodifiable(merged);
  }
}
