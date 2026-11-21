import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_mastered_shoresh_roots_use_case.dart';
import '../../domain/usecases/get_shoresh_family_use_case.dart';
import '../../domain/usecases/get_shoresh_quiz_use_case.dart';
import '../../domain/usecases/get_shoresh_roots_use_case.dart';
import '../../domain/usecases/save_shoresh_mastery_use_case.dart';
import 'shoresh_event.dart';
import 'shoresh_state.dart';

/// Business logic component managing the Shoresh Detective catalog,
/// morphological family exploration, and interactive detective quiz challenges.
class ShoreshBloc extends Bloc<ShoreshEvent, ShoreshState> {
  ShoreshBloc({
    required GetShoreshRootsUseCase getShoreshRootsUseCase,
    required GetShoreshFamilyUseCase getShoreshFamilyUseCase,
    required GetMasteredShoreshRootsUseCase getMasteredShoreshRootsUseCase,
    required GetShoreshQuizUseCase getShoreshQuizUseCase,
    required SaveShoreshMasteryUseCase saveShoreshMasteryUseCase,
  })  : _getShoreshRootsUseCase = getShoreshRootsUseCase,
        _getShoreshFamilyUseCase = getShoreshFamilyUseCase,
        _getMasteredShoreshRootsUseCase = getMasteredShoreshRootsUseCase,
        _getShoreshQuizUseCase = getShoreshQuizUseCase,
        _saveShoreshMasteryUseCase = saveShoreshMasteryUseCase,
        super(const ShoreshInitial()) {
    on<LoadShoreshCatalogEvent>(_onLoadCatalog);
    on<FilterShoreshCatalogEvent>(_onFilterCatalog);
    on<SelectShoreshRootEvent>(_onSelectRoot);
    on<ToggleShoreshNikkudEvent>(_onToggleNikkud);
    on<StartShoreshQuizEvent>(_onStartQuiz);
    on<AnswerShoreshQuizEvent>(_onAnswerQuiz);
    on<NextShoreshQuizQuestionEvent>(_onNextQuizQuestion);
  }

  final GetShoreshRootsUseCase _getShoreshRootsUseCase;
  final GetShoreshFamilyUseCase _getShoreshFamilyUseCase;
  final GetMasteredShoreshRootsUseCase _getMasteredShoreshRootsUseCase;
  final GetShoreshQuizUseCase _getShoreshQuizUseCase;
  final SaveShoreshMasteryUseCase _saveShoreshMasteryUseCase;

  Future<void> _onLoadCatalog(
    LoadShoreshCatalogEvent event,
    Emitter<ShoreshState> emit,
  ) async {
    emit(const ShoreshLoading());

    final roots = _getShoreshRootsUseCase();
    final categories = roots.map((r) => r.categoryRu).toSet().toList()..sort();
    final masteredResult = await _getMasteredShoreshRootsUseCase();

    final masteredMap = masteredResult.fold(
      (failure) => <String, bool>{},
      (map) => map,
    );

    emit(
      ShoreshCatalogLoaded(
        allRoots: roots,
        filteredRoots: roots,
        categories: categories,
        masteredRootIds: masteredMap,
      ),
    );
  }

  void _onFilterCatalog(
    FilterShoreshCatalogEvent event,
    Emitter<ShoreshState> emit,
  ) {
    final current = state;
    if (current is! ShoreshCatalogLoaded) return;

    final query = event.searchQuery ?? current.searchQuery;
    final category = event.category ?? current.selectedCategory;

    final filtered = _getShoreshRootsUseCase(
      category: category,
      query: query,
    );

    emit(
      current.copyWith(
        filteredRoots: filtered,
        selectedCategory: category,
        clearSelectedCategory: event.category == null && category == null,
        searchQuery: query,
      ),
    );
  }

  void _onSelectRoot(
    SelectShoreshRootEvent event,
    Emitter<ShoreshState> emit,
  ) {
    final current = state;
    if (current is! ShoreshCatalogLoaded) return;

    final root = _getShoreshFamilyUseCase(event.rootId);
    emit(current.copyWith(selectedRoot: root));
  }

  void _onToggleNikkud(
    ToggleShoreshNikkudEvent event,
    Emitter<ShoreshState> emit,
  ) {
    final current = state;
    if (current is! ShoreshCatalogLoaded) return;

    emit(current.copyWith(showNikkud: !current.showNikkud));
  }

  void _onStartQuiz(
    StartShoreshQuizEvent event,
    Emitter<ShoreshState> emit,
  ) {
    final current = state;
    if (current is! ShoreshCatalogLoaded) return;

    final questions = _getShoreshQuizUseCase(count: event.questionCount);
    emit(
      current.copyWith(
        activeQuiz: ShoreshQuizSessionState(questions: questions),
      ),
    );
  }

  void _onAnswerQuiz(
    AnswerShoreshQuizEvent event,
    Emitter<ShoreshState> emit,
  ) {
    final current = state;
    if (current is! ShoreshCatalogLoaded) return;
    final quiz = current.activeQuiz;
    if (quiz == null || quiz.isAnswerSubmitted || quiz.isCompleted) return;

    final question = quiz.currentQuestion;
    if (question == null) return;

    final isCorrect = event.selectedOptionIndex == question.correctIndex;
    final newScore = isCorrect ? quiz.score + 1 : quiz.score;

    emit(
      current.copyWith(
        activeQuiz: quiz.copyWith(
          selectedOptionIndex: event.selectedOptionIndex,
          isAnswerSubmitted: true,
          score: newScore,
        ),
      ),
    );
  }

  Future<void> _onNextQuizQuestion(
    NextShoreshQuizQuestionEvent event,
    Emitter<ShoreshState> emit,
  ) async {
    final current = state;
    if (current is! ShoreshCatalogLoaded) return;
    final quiz = current.activeQuiz;
    if (quiz == null) return;

    if (quiz.currentIndex + 1 < quiz.questions.length) {
      emit(
        current.copyWith(
          activeQuiz: quiz.copyWith(
            currentIndex: quiz.currentIndex + 1,
            clearSelected: true,
            isAnswerSubmitted: false,
          ),
        ),
      );
    } else {
      // Quiz completed!
      final completedSession = quiz.copyWith(isCompleted: true);
      emit(current.copyWith(activeQuiz: completedSession));

      // Persist mastery for the selected root if active, or general quiz victory
      final activeRootId = current.selectedRoot?.id;
      if (activeRootId != null) {
        await _saveShoreshMasteryUseCase(
          SaveShoreshMasteryParams(
            rootId: activeRootId,
            isMastered: quiz.score >= (quiz.questions.length * 0.7),
            quizCorrectIncrement: quiz.score,
          ),
        );

        final updatedMastered = Map<String, bool>.from(current.masteredRootIds);
        if (quiz.score >= (quiz.questions.length * 0.7)) {
          updatedMastered[activeRootId] = true;
        }
        emit(current.copyWith(masteredRootIds: updatedMastered));
      }
    }
  }
}
