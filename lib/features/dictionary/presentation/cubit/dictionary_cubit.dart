import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/result/result.dart';
import '../../../conversation/domain/entities/binyan.dart';
import '../../../conversation/domain/entities/hebrew_text.dart';
import '../../../grammar/domain/entities/verb_conjugation.dart';
import '../../../grammar/domain/repositories/grammar_repository.dart';
import '../../../srs/domain/entities/srs_card.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../domain/entities/dictionary_entry.dart';
import '../../domain/repositories/dictionary_repository.dart';
import '../../domain/usecases/add_custom_dictionary_entry.dart';
import '../../domain/usecases/search_dictionary_entries.dart';
import '../../domain/usecases/search_online_dictionary.dart';
import 'dictionary_state.dart';

/// State manager for the offline-first Hebrew-Russian Dictionary feature.
final class DictionaryCubit extends Cubit<DictionaryState> {
  static const String _tag = 'DictionaryCubit';

  DictionaryCubit({
    required DictionaryRepository repository,
    required SearchDictionaryEntriesUseCase searchUseCase,
    required AddCustomDictionaryEntryUseCase addCustomEntryUseCase,
    required SearchOnlineDictionaryUseCase searchOnlineUseCase,
    required AddCardToSrsUseCase addCardToSrsUseCase,
    required AudioPlaybackService audioService,
    required AppLogger logger,
    GrammarRepository? grammarRepository,
  })  : _repository = repository,
        _searchUseCase = searchUseCase,
        _addCustomEntryUseCase = addCustomEntryUseCase,
        _searchOnlineUseCase = searchOnlineUseCase,
        _addCardToSrsUseCase = addCardToSrsUseCase,
        _audioService = audioService,
        _logger = logger,
        _grammarRepository = grammarRepository,
        super(const DictionaryInitial()) {
    _audioSubscription = _audioService.statusStream.listen(_handleAudioEvent);
  }

  final DictionaryRepository _repository;
  final SearchDictionaryEntriesUseCase _searchUseCase;
  final AddCustomDictionaryEntryUseCase _addCustomEntryUseCase;
  final SearchOnlineDictionaryUseCase _searchOnlineUseCase;
  final AddCardToSrsUseCase _addCardToSrsUseCase;
  final AudioPlaybackService _audioService;
  final AppLogger _logger;
  final GrammarRepository? _grammarRepository;

  AudioPlaybackService get audioService => _audioService;
  AddCardToSrsUseCase get addCardToSrsUseCase => _addCardToSrsUseCase;

  StreamSubscription<AudioPlaybackEvent>? _audioSubscription;

  /// Loads dictionary entries, SRS membership status, and linked verb paradigms.
  Future<void> loadDictionary() async {
    final prev = state is DictionaryLoaded ? state as DictionaryLoaded : null;
    if (prev == null) {
      emit(const DictionaryLoading());
    }

    final entriesFuture = _repository.getAllEntries();
    final srsFuture = _repository.getSrsNormalizedForms();
    final verbsFuture = _grammarRepository?.getVerbs() ??
        Future<Result<List<VerbLexeme>, Failure>>.value(
          const Success<List<VerbLexeme>, Failure>(<VerbLexeme>[]),
        );

    final entriesRes = await entriesFuture;
    final srsRes = await srsFuture;
    final verbsRes = await verbsFuture;
    if (isClosed) return;

    switch (entriesRes) {
      case Error(:final failure):
        _logger.warning(_tag, 'Failed to load dictionary: ${failure.message}');
        if (prev == null) {
          emit(DictionaryError(failure));
        } else {
          emit(prev.copyWith(transientNotice: failure.message));
        }
      case Success(data: final entries):
        final srsForms = srsRes.getOrNull() ?? prev?.srsNormalizedForms ?? const <String>{};
        final verbs = verbsRes.getOrNull() ?? prev?.verbParadigms ?? const <VerbLexeme>[];
        final activeFilter = prev?.filter ?? const DictionaryFilter();
        final matches = _searchUseCase(
          entries: entries,
          filter: activeFilter,
          srsNormalizedForms: srsForms,
        );
        emit(
          DictionaryLoaded(
            allEntries: entries,
            visibleMatches: matches,
            srsNormalizedForms: srsForms,
            verbParadigms: verbs,
            filter: activeFilter,
            showNikkud: prev?.showNikkud ?? true,
          ),
        );
    }
  }

  /// Syncs FSRS membership badges when navigating back to the Dictionary tab.
  Future<void> refreshSrsStatus() async {
    final current = state;
    if (current is! DictionaryLoaded) return;

    final srsRes = await _repository.getSrsNormalizedForms();
    if (isClosed) return;

    if (srsRes case Success(data: final srsForms)) {
      final latest = state;
      if (latest is! DictionaryLoaded) return;
      final matches = _searchUseCase(
        entries: latest.allEntries,
        filter: latest.filter,
        srsNormalizedForms: srsForms,
      );
      emit(
        latest.copyWith(
          srsNormalizedForms: srsForms,
          visibleMatches: matches,
        ),
      );
    }
  }

  void updateQuery(String query) {
    final current = state;
    if (current is! DictionaryLoaded) return;
    _applyFilter(
      current,
      current.filter.copyWith(query: query),
      clearOnlineMeta: true,
    );
  }

  void selectCategory(LexicalCategory? category) {
    final current = state;
    if (current is! DictionaryLoaded) return;
    final nextFilter = category == null
        ? current.filter.copyWith(clearCategory: true, clearBinyan: true)
        : current.filter.copyWith(
            category: category,
            clearBinyan: category != LexicalCategory.verb,
          );
    _applyFilter(current, nextFilter);
  }

  void selectBinyan(Binyan? binyan) {
    final current = state;
    if (current is! DictionaryLoaded) return;
    final nextFilter = binyan == null
        ? current.filter.copyWith(clearBinyan: true)
        : current.filter.copyWith(
            binyan: binyan,
            category: LexicalCategory.verb,
          );
    _applyFilter(current, nextFilter);
  }

  void filterByRoot(Shoresh? root) {
    final current = state;
    if (current is! DictionaryLoaded) return;
    final nextFilter = root == null
        ? current.filter.copyWith(clearRootFilter: true)
        : current.filter.copyWith(rootFilter: root);
    _applyFilter(current, nextFilter);
  }

  void toggleOnlyInSrs() {
    final current = state;
    if (current is! DictionaryLoaded) return;
    _applyFilter(
      current,
      current.filter.copyWith(onlyInSrs: !current.filter.onlyInSrs),
    );
  }

  void toggleOnlyWithRoot() {
    final current = state;
    if (current is! DictionaryLoaded) return;
    _applyFilter(
      current,
      current.filter.copyWith(onlyWithRoot: !current.filter.onlyWithRoot),
    );
  }

  void clearAllFilters() {
    final current = state;
    if (current is! DictionaryLoaded) return;
    _applyFilter(current, const DictionaryFilter(), clearOnlineMeta: true);
  }

  void toggleNikkud() {
    final current = state;
    if (current is! DictionaryLoaded) return;
    emit(current.copyWith(showNikkud: !current.showNikkud));
  }

  /// Pronounces the dictionary headword via bundled MP3 or he-IL TTS fallback.
  Future<void> speakEntry(DictionaryEntry entry) {
    return _speakHebrew(
      hebrewVocalized: entry.hebrew.vocalized,
      audioUrl: entry.audioUrl,
    );
  }

  /// Pronounces the entry's example sentence in Hebrew.
  Future<void> speakExample(DictionaryEntry entry) {
    final example = entry.exampleHebrew;
    if (example == null) {
      return Future<void>.value();
    }
    return _speakHebrew(
      hebrewVocalized: example.vocalized,
      audioUrl: null,
    );
  }

  Future<void> _speakHebrew({
    required String hebrewVocalized,
    required String? audioUrl,
  }) async {
    final current = state;
    if (current is! DictionaryLoaded) return;

    final isSamePlaying = current.activeSpokenHebrew == hebrewVocalized &&
        current.audioStatus == AudioPlaybackStatus.playing;
    if (isSamePlaying) {
      await _audioService.stop();
      return;
    }

    emit(
      current.copyWith(
        activeSpokenHebrew: hebrewVocalized,
        activeAudioUrl: audioUrl,
        clearActiveAudioUrl: audioUrl == null,
        audioStatus: AudioPlaybackStatus.loading,
      ),
    );

    final res = await _audioService.playWithTtsFallback(
      sourcePath: audioUrl,
      fallbackHebrewText: hebrewVocalized,
    );
    if (isClosed) return;

    res.fold(
      (Failure failure) {
        final latest = state;
        if (latest is DictionaryLoaded) {
          emit(
            latest.copyWith(
              audioStatus: AudioPlaybackStatus.error,
              transientNotice: failure.message,
            ),
          );
        }
      },
      (_) {},
    );
  }

  /// Adds a dictionary word directly to the learner's FSRS flashcard deck in 1 tap.
  Future<void> saveToSrs(DictionaryEntry entry) async {
    final current = state;
    if (current is! DictionaryLoaded) return;

    final res = await _addCardToSrsUseCase(
      AddCardToSrsParams(
        id: 'srs_dict_${entry.id}',
        hebrewVocalized: entry.hebrew.vocalized,
        russianTranslation: entry.russianTranslation,
        root: entry.root,
        binyan: entry.binyan,
        category: entry.category,
        exampleHebrewVocalized: entry.exampleHebrew?.vocalized,
        exampleRussian: entry.exampleRussian,
        audioUrl: entry.audioUrl,
        attribution: entry.attribution,
      ),
    );
    if (isClosed) return;

    switch (res) {
      case Error(:final failure):
        final latest = state;
        if (latest is DictionaryLoaded) {
          emit(latest.copyWith(transientNotice: failure.message));
        }
      case Success(data: final added):
        final latest = state;
        if (latest is! DictionaryLoaded) return;

        final updatedSrs = Set<String>.from(latest.srsNormalizedForms)
          ..add(entry.hebrew.normalized);
        final matches = _searchUseCase(
          entries: latest.allEntries,
          filter: latest.filter,
          srsNormalizedForms: updatedSrs,
        );
        emit(
          latest.copyWith(
            srsNormalizedForms: updatedSrs,
            visibleMatches: matches,
            transientNotice: added
                ? 'Добавлено в колоду FSRS!'
                : 'Слово уже есть в твоей колоде FSRS',
          ),
        );
    }
  }

  /// Creates and persists a custom learner word, optionally queuing it to FSRS.
  Future<bool> addCustomWord({
    required String hebrewVocalized,
    required String russianTranslation,
    String? transliteration,
    LexicalCategory category = LexicalCategory.noun,
    String? rawRoot,
    Binyan binyan = Binyan.none,
    String? formsSummary,
    String? exampleHebrewVocalized,
    String? exampleRussian,
    bool alsoAddToSrs = true,
  }) async {
    final current = state;
    if (current is! DictionaryLoaded) return false;

    final createRes = await _addCustomEntryUseCase(
      AddCustomDictionaryEntryParams(
        hebrewVocalized: hebrewVocalized,
        russianTranslation: russianTranslation,
        transliteration: transliteration,
        category: category,
        rawRoot: rawRoot,
        binyan: binyan,
        formsSummary: formsSummary,
        exampleHebrewVocalized: exampleHebrewVocalized,
        exampleRussian: exampleRussian,
      ),
    );
    if (isClosed) return false;

    switch (createRes) {
      case Error(:final failure):
        final latest = state;
        if (latest is DictionaryLoaded) {
          emit(latest.copyWith(transientNotice: failure.message));
        }
        return false;
      case Success(data: final savedEntry):
        final updatedSrs = Set<String>.from(current.srsNormalizedForms);
        if (alsoAddToSrs) {
          final srsRes = await _addCardToSrsUseCase(
            AddCardToSrsParams(
              id: 'srs_dict_${savedEntry.id}',
              hebrewVocalized: savedEntry.hebrew.vocalized,
              russianTranslation: savedEntry.russianTranslation,
              root: savedEntry.root,
              binyan: savedEntry.binyan,
              category: savedEntry.category,
              exampleHebrewVocalized: savedEntry.exampleHebrew?.vocalized,
              exampleRussian: savedEntry.exampleRussian,
              attribution: savedEntry.attribution,
            ),
          );
          if (srsRes is Success) {
            updatedSrs.add(savedEntry.hebrew.normalized);
          }
        }
        if (isClosed) return true;

        final latest = state;
        if (latest is! DictionaryLoaded) return true;

        final updatedAll = <DictionaryEntry>[
          savedEntry,
          ...latest.allEntries.where((DictionaryEntry e) => e.id != savedEntry.id),
        ];
        final matches = _searchUseCase(
          entries: updatedAll,
          filter: latest.filter,
          srsNormalizedForms: updatedSrs,
        );
        emit(
          latest.copyWith(
            allEntries: updatedAll,
            visibleMatches: matches,
            srsNormalizedForms: updatedSrs,
            transientNotice: alsoAddToSrs
                ? 'Слово сохранено в словарь и добавлено в FSRS!'
                : 'Слово сохранено в твой словарь!',
          ),
        );
        return true;
    }
  }

  /// Fetches live heb<->rus phrases from Tatoeba and caches them in the local dictionary.
  Future<void> searchOnline({String? queryOverride}) async {
    final current = state;
    if (current is! DictionaryLoaded || current.isSearchingOnline) return;

    final query = (queryOverride ?? current.filter.query).trim();
    if (query.isEmpty) {
      emit(
        current.copyWith(
          transientNotice: 'Введи слово или фразу для онлайн-поиска.',
        ),
      );
      return;
    }

    emit(
      current.copyWith(
        isSearchingOnline: true,
        clearTransientNotice: true,
      ),
    );

    final onlineRes = await _searchOnlineUseCase(
      SearchOnlineDictionaryParams(query: query),
    );
    if (isClosed) return;

    final latest = state;
    if (latest is! DictionaryLoaded) return;

    switch (onlineRes) {
      case Error(:final failure):
        emit(
          latest.copyWith(
            isSearchingOnline: false,
            transientNotice: failure.message,
          ),
        );
      case Success(data: final fetched):
        if (fetched.isEmpty) {
          emit(
            latest.copyWith(
              isSearchingOnline: false,
              lastOnlineQuery: query,
              lastOnlineResultsCount: 0,
              transientNotice: 'В Tatoeba ничего нового по «$query» не найдено.',
            ),
          );
          return;
        }

        final existingIds =
            latest.allEntries.map((DictionaryEntry e) => e.id).toSet();
        final newlyAdded = fetched
            .where((DictionaryEntry e) => !existingIds.contains(e.id))
            .toList(growable: false);

        final merged = <DictionaryEntry>[
          ...latest.allEntries,
          ...newlyAdded,
        ];
        final matches = _searchUseCase(
          entries: merged,
          filter: latest.filter,
          srsNormalizedForms: latest.srsNormalizedForms,
        );

        emit(
          latest.copyWith(
            allEntries: merged,
            visibleMatches: matches,
            isSearchingOnline: false,
            lastOnlineQuery: query,
            lastOnlineResultsCount: fetched.length,
            transientNotice: newlyAdded.isNotEmpty
                ? 'Tatoeba: добавлено ${newlyAdded.length} совпад. в словарь'
                : 'Tatoeba: найдено ${fetched.length} (уже есть в словаре)',
          ),
        );
    }
  }

  /// Finds all other dictionary entries sharing the same Hebrew shoresh.
  List<DictionaryEntry> findRelatedWords(DictionaryEntry entry) {
    final current = state;
    final root = entry.root;
    if (current is! DictionaryLoaded || root == null) {
      return const <DictionaryEntry>[];
    }
    return _searchUseCase.findRelatedByRoot(
      entries: current.allEntries,
      root: root,
      excludeEntryId: entry.id,
    );
  }

  /// Returns a matching verb conjugation paradigm if present in local Grammar DB.
  VerbLexeme? findMatchingVerbParadigm(DictionaryEntry entry) {
    final current = state;
    if (current is! DictionaryLoaded || entry.category != LexicalCategory.verb) {
      return null;
    }
    final targetNorm = entry.hebrew.normalized;
    for (final verb in current.verbParadigms) {
      if (verb.lemma.normalized == targetNorm ||
          verb.infinitive?.normalized == targetNorm) {
        return verb;
      }
    }
    if (entry.root != null && entry.binyan != Binyan.none) {
      for (final verb in current.verbParadigms) {
        if (verb.root.compact == entry.root!.compact &&
            verb.binyan == entry.binyan) {
          return verb;
        }
      }
    }
    return null;
  }

  void clearTransientNotice() {
    final current = state;
    if (current is! DictionaryLoaded || current.transientNotice == null) return;
    emit(current.copyWith(clearTransientNotice: true));
  }

  void _applyFilter(
    DictionaryLoaded current,
    DictionaryFilter nextFilter, {
    bool clearOnlineMeta = false,
  }) {
    final matches = _searchUseCase(
      entries: current.allEntries,
      filter: nextFilter,
      srsNormalizedForms: current.srsNormalizedForms,
    );
    emit(
      current.copyWith(
        filter: nextFilter,
        visibleMatches: matches,
        clearOnlineMeta: clearOnlineMeta,
        clearTransientNotice: true,
      ),
    );
  }

  void _handleAudioEvent(AudioPlaybackEvent event) {
    if (isClosed) return;
    final current = state;
    if (current is! DictionaryLoaded) return;
    final spoken = current.activeSpokenHebrew;
    if (spoken == null) return;

    final expectedTts = 'tts://he-IL/$spoken';
    final matches = event.sourcePath == current.activeAudioUrl ||
        event.sourcePath == expectedTts;
    if (!matches) return;

    emit(current.copyWith(audioStatus: event.status));
  }

  @override
  Future<void> close() async {
    await _audioSubscription?.cancel();
    return super.close();
  }
}
