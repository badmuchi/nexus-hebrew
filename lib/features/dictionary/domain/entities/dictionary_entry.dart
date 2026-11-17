import 'package:equatable/equatable.dart';

import '../../../conversation/domain/entities/binyan.dart';
import '../../../conversation/domain/entities/hebrew_text.dart';
import '../../../srs/domain/entities/srs_card.dart';

/// Immutable lexical entry shown in the bilingual Hebrew-Russian dictionary.
final class DictionaryEntry extends Equatable {
  const DictionaryEntry({
    required this.id,
    required this.hebrew,
    required this.russianTranslation,
    required this.attribution,
    required this.createdAt,
    this.transliteration,
    this.category = LexicalCategory.noun,
    this.root,
    this.binyan = Binyan.none,
    this.formsSummary,
    this.exampleHebrew,
    this.exampleRussian,
    this.audioUrl,
    this.frequencyRank,
    this.isUserAdded = false,
  });

  final String id;
  final HebrewText hebrew;
  final String russianTranslation;
  final String? transliteration;
  final LexicalCategory category;
  final Shoresh? root;
  final Binyan binyan;
  final String? formsSummary;
  final HebrewText? exampleHebrew;
  final String? exampleRussian;
  final String? audioUrl;
  final int? frequencyRank;
  final ContentAttribution attribution;
  final bool isUserAdded;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
        id,
        hebrew,
        russianTranslation,
        transliteration,
        category,
        root,
        binyan,
        formsSummary,
        exampleHebrew,
        exampleRussian,
        audioUrl,
        frequencyRank,
        attribution,
        isUserAdded,
        createdAt,
      ];
}

/// Filter & search specification for querying local dictionary entries.
final class DictionaryFilter extends Equatable {
  const DictionaryFilter({
    this.query = '',
    this.category,
    this.binyan,
    this.rootFilter,
    this.onlyInSrs = false,
    this.onlyWithRoot = false,
  });

  final String query;
  final LexicalCategory? category;
  final Binyan? binyan;
  final Shoresh? rootFilter;
  final bool onlyInSrs;
  final bool onlyWithRoot;

  bool get hasActiveFilters =>
      query.trim().isNotEmpty ||
      category != null ||
      binyan != null ||
      rootFilter != null ||
      onlyInSrs ||
      onlyWithRoot;

  DictionaryFilter copyWith({
    String? query,
    LexicalCategory? category,
    bool clearCategory = false,
    Binyan? binyan,
    bool clearBinyan = false,
    Shoresh? rootFilter,
    bool clearRootFilter = false,
    bool? onlyInSrs,
    bool? onlyWithRoot,
  }) {
    return DictionaryFilter(
      query: query ?? this.query,
      category: clearCategory ? null : (category ?? this.category),
      binyan: clearBinyan ? null : (binyan ?? this.binyan),
      rootFilter: clearRootFilter ? null : (rootFilter ?? this.rootFilter),
      onlyInSrs: onlyInSrs ?? this.onlyInSrs,
      onlyWithRoot: onlyWithRoot ?? this.onlyWithRoot,
    );
  }

  @override
  List<Object?> get props => [
        query,
        category,
        binyan,
        rootFilter,
        onlyInSrs,
        onlyWithRoot,
      ];
}

/// Dictionary entry paired with its presence status in the learner's FSRS deck.
final class DictionarySearchMatch extends Equatable {
  const DictionarySearchMatch({
    required this.entry,
    required this.isInSrs,
  });

  final DictionaryEntry entry;
  final bool isInSrs;

  @override
  List<Object?> get props => [entry, isInSrs];
}
