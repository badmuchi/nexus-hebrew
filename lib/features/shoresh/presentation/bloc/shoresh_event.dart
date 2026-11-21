import 'package:equatable/equatable.dart';

sealed class ShoreshEvent extends Equatable {
  const ShoreshEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the Hebrew roots catalog and user progress from database.
final class LoadShoreshCatalogEvent extends ShoreshEvent {
  const LoadShoreshCatalogEvent();
}

/// Filters the roots list by category tag and/or Hebrew/Russian search query.
final class FilterShoreshCatalogEvent extends ShoreshEvent {
  const FilterShoreshCatalogEvent({
    this.category,
    this.searchQuery,
  });

  final String? category;
  final String? searchQuery;

  @override
  List<Object?> get props => [category, searchQuery];
}

/// Selects a specific root to display its full family tree in the Word Family Lab.
final class SelectShoreshRootEvent extends ShoreshEvent {
  const SelectShoreshRootEvent(this.rootId);

  final String rootId;

  @override
  List<Object?> get props => [rootId];
}

/// Toggles vowel marks (Niqqud) visibility across the screens.
final class ToggleShoreshNikkudEvent extends ShoreshEvent {
  const ToggleShoreshNikkudEvent();
}

/// Initiates a Root Detective challenge quiz session.
final class StartShoreshQuizEvent extends ShoreshEvent {
  const StartShoreshQuizEvent({this.questionCount = 8});

  final int questionCount;

  @override
  List<Object?> get props => [questionCount];
}

/// Submits an answer for the current quiz question.
final class AnswerShoreshQuizEvent extends ShoreshEvent {
  const AnswerShoreshQuizEvent(this.selectedOptionIndex);

  final int selectedOptionIndex;

  @override
  List<Object?> get props => [selectedOptionIndex];
}

/// Advances to the next quiz challenge or concludes the quiz session.
final class NextShoreshQuizQuestionEvent extends ShoreshEvent {
  const NextShoreshQuizQuestionEvent();
}
