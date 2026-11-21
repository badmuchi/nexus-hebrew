import 'package:equatable/equatable.dart';
import '../../domain/entities/shoresh_entity.dart';

/// State of an active Root Detective interactive quiz game.
final class ShoreshQuizSessionState extends Equatable {
  const ShoreshQuizSessionState({
    required this.questions,
    this.currentIndex = 0,
    this.score = 0,
    this.selectedOptionIndex,
    this.isAnswerSubmitted = false,
    this.isCompleted = false,
  });

  final List<ShoreshQuizQuestion> questions;
  final int currentIndex;
  final int score;
  final int? selectedOptionIndex;
  final bool isAnswerSubmitted;
  final bool isCompleted;

  ShoreshQuizQuestion? get currentQuestion =>
      currentIndex < questions.length ? questions[currentIndex] : null;

  bool get isCorrect =>
      isAnswerSubmitted &&
      selectedOptionIndex != null &&
      currentQuestion != null &&
      selectedOptionIndex == currentQuestion!.correctIndex;

  ShoreshQuizSessionState copyWith({
    List<ShoreshQuizQuestion>? questions,
    int? currentIndex,
    int? score,
    int? selectedOptionIndex,
    bool? isAnswerSubmitted,
    bool? isCompleted,
    bool clearSelected = false,
  }) {
    return ShoreshQuizSessionState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      score: score ?? this.score,
      selectedOptionIndex: clearSelected
          ? null
          : (selectedOptionIndex ?? this.selectedOptionIndex),
      isAnswerSubmitted: isAnswerSubmitted ?? this.isAnswerSubmitted,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [
        questions,
        currentIndex,
        score,
        selectedOptionIndex,
        isAnswerSubmitted,
        isCompleted,
      ];
}

/// Base sealed state for Shoresh Bloc.
sealed class ShoreshState extends Equatable {
  const ShoreshState();

  @override
  List<Object?> get props => [];
}

/// Initial uninitialized state.
final class ShoreshInitial extends ShoreshState {
  const ShoreshInitial();
}

/// State while loading roots and user progress.
final class ShoreshLoading extends ShoreshState {
  const ShoreshLoading();
}

/// Active catalog state holding roots, filters, active selection, and optional quiz session.
final class ShoreshCatalogLoaded extends ShoreshState {
  const ShoreshCatalogLoaded({
    required this.allRoots,
    required this.filteredRoots,
    required this.categories,
    this.selectedCategory,
    this.searchQuery = '',
    required this.masteredRootIds,
    this.showNikkud = true,
    this.selectedRoot,
    this.activeQuiz,
  });

  final List<ShoreshRoot> allRoots;
  final List<ShoreshRoot> filteredRoots;
  final List<String> categories;
  final String? selectedCategory;
  final String searchQuery;
  final Map<String, bool> masteredRootIds;
  final bool showNikkud;
  final ShoreshRoot? selectedRoot;
  final ShoreshQuizSessionState? activeQuiz;

  ShoreshCatalogLoaded copyWith({
    List<ShoreshRoot>? allRoots,
    List<ShoreshRoot>? filteredRoots,
    List<String>? categories,
    String? selectedCategory,
    bool clearSelectedCategory = false,
    String? searchQuery,
    Map<String, bool>? masteredRootIds,
    bool? showNikkud,
    ShoreshRoot? selectedRoot,
    bool clearSelectedRoot = false,
    ShoreshQuizSessionState? activeQuiz,
    bool clearActiveQuiz = false,
  }) {
    return ShoreshCatalogLoaded(
      allRoots: allRoots ?? this.allRoots,
      filteredRoots: filteredRoots ?? this.filteredRoots,
      categories: categories ?? this.categories,
      selectedCategory: clearSelectedCategory
          ? null
          : (selectedCategory ?? this.selectedCategory),
      searchQuery: searchQuery ?? this.searchQuery,
      masteredRootIds: masteredRootIds ?? this.masteredRootIds,
      showNikkud: showNikkud ?? this.showNikkud,
      selectedRoot: clearSelectedRoot ? null : (selectedRoot ?? this.selectedRoot),
      activeQuiz: clearActiveQuiz ? null : (activeQuiz ?? this.activeQuiz),
    );
  }

  @override
  List<Object?> get props => [
        allRoots,
        filteredRoots,
        categories,
        selectedCategory,
        searchQuery,
        masteredRootIds,
        showNikkud,
        selectedRoot,
        activeQuiz,
      ];
}

/// Failure state.
final class ShoreshError extends ShoreshState {
  const ShoreshError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
