import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/settings/app_settings_storage.dart';
import '../../../srs/domain/entities/srs_card.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../domain/entities/dialogue_node.dart';
import '../../domain/usecases/get_active_dialogue.dart';
import '../../domain/usecases/select_dialogue_option.dart';
import '../../domain/usecases/toggle_dialogue_audio.dart';
import 'conversation_state.dart';

final class ConversationCubit extends Cubit<ConversationState> {
  static const String _tag = 'ConversationCubit';

  final GetActiveDialogueUseCase _getDialogueUseCase;
  final SelectDialogueOptionUseCase _selectOptionUseCase;
  final ToggleDialogueAudioUseCase _toggleAudioUseCase;
  final AddCardToSrsUseCase? _addCardToSrsUseCase;
  final AudioPlaybackService _audioService;
  final AppSettingsStorage? _settingsStorage;
  final AppLogger _logger;

  StreamSubscription<AudioPlaybackEvent>? _audioSubscription;

  ConversationCubit({
    required GetActiveDialogueUseCase getDialogueUseCase,
    required SelectDialogueOptionUseCase selectOptionUseCase,
    required ToggleDialogueAudioUseCase toggleAudioUseCase,
    AddCardToSrsUseCase? addCardToSrsUseCase,
    required AudioPlaybackService audioService,
    AppSettingsStorage? settingsStorage,
    required AppLogger logger,
  })  : _getDialogueUseCase = getDialogueUseCase,
        _selectOptionUseCase = selectOptionUseCase,
        _toggleAudioUseCase = toggleAudioUseCase,
        _addCardToSrsUseCase = addCardToSrsUseCase,
        _audioService = audioService,
        _settingsStorage = settingsStorage,
        _logger = logger,
        super(const ConversationInitial()) {
    _audioSubscription = _audioService.statusStream.listen(_handleAudioEvent);
  }

  Future<void> loadDialogueNode(
    String nodeId, {
    bool resetHistory = false,
  }) async {
    final currentLoaded = state is ConversationLoaded
        ? state as ConversationLoaded
        : null;

    await _audioService.stop();
    if (isClosed) return;

    emit(ConversationLoading(nodeId: nodeId));

    final result = await _getDialogueUseCase.execute(nodeId);
    if (isClosed) return;

    result.fold(
      (failure) {
        _logger.warning(
          _tag,
          'Failed to load dialogue node "$nodeId"',
          failure: failure,
        );
        emit(
          ConversationError(
            failure: failure,
            retryNodeId: nodeId,
          ),
        );
      },
      (node) {
        emit(
          ConversationLoaded(
            activeNode: node,
            showNikkud: currentLoaded?.showNikkud ?? true,
            navigationHistory: resetHistory
                ? const []
                : (currentLoaded?.navigationHistory ?? const []),
            playbackSpeed:
                currentLoaded?.playbackSpeed ?? _audioService.currentSpeed,
          ),
        );
      },
    );
  }

  Future<void> selectOption(DialogueOption option) async {
    final current = state;
    if (current is! ConversationLoaded || current.isTransitioning) {
      return;
    }

    emit(
      current.copyWith(
        isTransitioning: true,
        clearTransientNotice: true,
      ),
    );

    await _audioService.stop();
    if (isClosed) return;

    final result = await _selectOptionUseCase.execute(
      currentNodeId: current.activeNode.id,
      selectedOption: option,
    );
    if (isClosed) return;

    result.fold(
      (failure) {
        _logger.warning(
          _tag,
          'Failed to advance from "${current.activeNode.id}" via "${option.id}"',
          failure: failure,
        );
        emit(
          current.copyWith(
            isTransitioning: false,
            transientNotice: failure.message,
          ),
        );
      },
      (nextNode) {
        final updatedHistory = <String>[
          ...current.navigationHistory,
          current.activeNode.id,
        ];
        emit(
          ConversationLoaded(
            activeNode: nextNode,
            showNikkud: current.showNikkud,
            navigationHistory: updatedHistory,
          ),
        );
      },
    );
  }

  Future<void> navigateBack() async {
    final current = state;
    if (current is! ConversationLoaded || !current.canGoBack) {
      return;
    }

    final previousNodeId = current.navigationHistory.last;
    final trimmedHistory = current.navigationHistory
        .sublist(0, current.navigationHistory.length - 1);

    emit(current.copyWith(isTransitioning: true, clearTransientNotice: true));
    await _audioService.stop();
    if (isClosed) return;

    final result = await _getDialogueUseCase.execute(previousNodeId);
    if (isClosed) return;

    result.fold(
      (failure) {
        emit(
          current.copyWith(
            isTransitioning: false,
            transientNotice: failure.message,
          ),
        );
      },
      (previousNode) {
        emit(
          ConversationLoaded(
            activeNode: previousNode,
            showNikkud: current.showNikkud,
            navigationHistory: trimmedHistory,
          ),
        );
      },
    );
  }

  void toggleNikkudVisibility() {
    final current = state;
    if (current is! ConversationLoaded) {
      return;
    }
    emit(current.copyWith(showNikkud: !current.showNikkud));
  }

  Future<void> setPlaybackSpeed(double speed) async {
    final current = state;
    if (current is! ConversationLoaded) {
      return;
    }
    final res = await _audioService.setPlaybackSpeed(speed);
    if (res.isSuccess) {
      unawaited(_settingsStorage?.writePlaybackSpeed(speed));
      emit(current.copyWith(playbackSpeed: speed));
    }
  }

  Future<void> toggleAudio() async {
    final current = state;
    if (current is! ConversationLoaded) {
      return;
    }

    final result = await _toggleAudioUseCase.execute(
      current.activeNode.audioPath,
      fallbackHebrewText: current.activeNode.lineHebrew.vocalized,
    );
    if (isClosed) return;

    result.fold(
      (failure) {
        _logger.warning(
          _tag,
          'Audio toggle failed for node "${current.activeNode.id}"',
          failure: failure,
        );
        final latest = state;
        if (latest is ConversationLoaded) {
          emit(latest.copyWith(transientNotice: failure.message));
        }
      },
      (_) {},
    );
  }

  void clearTransientNotice() {
    final current = state;
    if (current is ConversationLoaded && current.transientNotice != null) {
      emit(current.copyWith(clearTransientNotice: true));
    }
  }

  /// Adds the active NPC dialogue line directly to the FSRS deck in one tap.
  Future<void> saveNodeToSrs() async {
    final current = state;
    final useCase = _addCardToSrsUseCase;
    if (current is! ConversationLoaded || useCase == null) return;

    final node = current.activeNode;
    final res = await useCase(
      AddCardToSrsParams(
        id: 'custom_dialogue_node_${node.id}',
        hebrewVocalized: node.lineHebrew.vocalized,
        russianTranslation: node.lineRussian,
        category: LexicalCategory.phrase,
        audioUrl: node.audioPath,
        attribution: const ContentAttribution(
          sourceName: 'Nexus Dialogues',
          licenseName: 'CC0 1.0',
        ),
      ),
    );
    if (isClosed) return;

    final latest = state;
    if (latest is! ConversationLoaded) return;
    res.fold(
      (failure) => emit(latest.copyWith(transientNotice: failure.message)),
      (added) => emit(
        latest.copyWith(
          transientNotice: added
              ? 'Реплика добавлена в колоду FSRS!'
              : 'Эта фраза уже есть в колоде FSRS',
        ),
      ),
    );
  }

  /// Adds a dialogue option phrase (with root and binyan metadata) to FSRS.
  Future<void> saveOptionToSrs(DialogueOption option) async {
    final current = state;
    final useCase = _addCardToSrsUseCase;
    if (current is! ConversationLoaded || useCase == null) return;

    final res = await useCase(
      AddCardToSrsParams(
        id: 'custom_dialogue_opt_${option.id}',
        hebrewVocalized: option.textHebrew.vocalized,
        russianTranslation: option.textRussian,
        root: option.root,
        binyan: option.binyan,
        category: LexicalCategory.phrase,
        exampleHebrewVocalized: current.activeNode.lineHebrew.vocalized,
        exampleRussian: current.activeNode.lineRussian,
        attribution: const ContentAttribution(
          sourceName: 'Nexus Dialogues',
          licenseName: 'CC0 1.0',
        ),
      ),
    );
    if (isClosed) return;

    final latest = state;
    if (latest is! ConversationLoaded) return;
    res.fold(
      (failure) => emit(latest.copyWith(transientNotice: failure.message)),
      (added) => emit(
        latest.copyWith(
          transientNotice: added
              ? 'Фраза «${option.textHebrew.normalized}» добавлена в FSRS!'
              : 'Эта фраза уже есть в колоде FSRS',
        ),
      ),
    );
  }

  void _handleAudioEvent(AudioPlaybackEvent event) {
    if (isClosed) return;
    final current = state;
    if (current is! ConversationLoaded) return;
    final expectedTtsKey = 'tts://he-IL/${current.activeNode.lineHebrew.vocalized}';
    final matchesNodeAudio = event.sourcePath == current.activeNode.audioPath ||
        event.sourcePath == expectedTtsKey;
    if (!matchesNodeAudio) return;

    emit(current.copyWith(audioStatus: event.status));
  }

  @override
  Future<void> close() async {
    await _audioSubscription?.cancel();
    await _audioService.stop();
    return super.close();
  }
}
