import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/speech/speech_recognition_service.dart';
import '../../../../core/widgets/hebrew_niqqud_keyboard.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../data/repositories/ai_roleplay_repository_impl.dart';
import '../../domain/entities/ai_roleplay_character.dart';
import '../../domain/entities/ai_roleplay_scenario.dart';
import '../../domain/repositories/ai_roleplay_repository.dart';
import '../cubit/ai_roleplay_cubit.dart';
import '../cubit/ai_roleplay_state.dart';
import '../widgets/ai_chat_bubble.dart';
import '../widgets/suggested_prompt_chips.dart';

class AiRoleplayChatScreen extends StatefulWidget {
  final AiRoleplayScenario scenario;
  final AiRoleplayCubit? cubit;
  final AiRoleplayRepository? repository;
  final AudioPlaybackService? audioService;
  final SpeechRecognitionService? speechService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;

  const AiRoleplayChatScreen({
    super.key,
    required this.scenario,
    this.cubit,
    this.repository,
    this.audioService,
    this.speechService,
    this.addCardToSrsUseCase,
  });

  @override
  State<AiRoleplayChatScreen> createState() => _AiRoleplayChatScreenState();
}

class _AiRoleplayChatScreenState extends State<AiRoleplayChatScreen> {
  late final AiRoleplayCubit _cubit;
  late final bool _isCubitInternallyCreated;
  late final SpeechRecognitionService _speechService;

  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  bool _showVirtualKeyboard = false;
  bool _isListening = false;
  StreamSubscription<String>? _speechSubscription;

  @override
  void initState() {
    super.initState();
    if (widget.cubit != null) {
      _cubit = widget.cubit!;
      _isCubitInternallyCreated = false;
    } else {
      _cubit = AiRoleplayCubit(
        repository: widget.repository ?? AiRoleplayRepositoryImpl(),
      );
      _isCubitInternallyCreated = true;
    }
    _cubit.startScenario(widget.scenario);

    _speechService = widget.speechService ??
        createPlatformSpeechRecognitionService(
          logger: const DeveloperAppLogger(),
        );
  }

  @override
  void dispose() {
    _speechSubscription?.cancel();
    _speechService.dispose();
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    if (_isCubitInternallyCreated) {
      _cubit.close();
    }
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  Future<void> _toggleSpeechRecognition() async {
    if (_isListening) {
      await _speechService.stopListening();
      await _speechSubscription?.cancel();
      if (mounted) {
        setState(() => _isListening = false);
      }
      return;
    }

    final initRes = await _speechService.initialize(language: 'he-IL');
    if (initRes.getOrNull() != true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Голосовой ввод на иврите не поддерживается в данном браузере/устройстве.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    _speechSubscription = _speechService.textStream.listen((text) {
      if (mounted && text.isNotEmpty) {
        setState(() {
          _textController.text = text;
          _textController.selection = TextSelection.fromPosition(
            TextPosition(offset: text.length),
          );
        });
      }
    });

    final startRes = await _speechService.startListening();
    if (startRes.isSuccess && mounted) {
      setState(() => _isListening = true);
    }
  }

  void _onSendPressed() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    if (_isListening) {
      _toggleSpeechRecognition();
    }

    _textController.clear();
    _cubit.sendMessage(text);
    _scrollToBottom();
  }

  void _onPromptSelected(String text) {
    _cubit.sendMessage(text);
    _scrollToBottom();
  }

  void _showScenarioInfo(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    widget.scenario.badgeEmoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.scenario.titleRussian,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Собеседник: ${widget.scenario.character.nameRussian} (${widget.scenario.character.nameHebrew})',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text(widget.scenario.level),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const Divider(height: 24),
              Text(
                widget.scenario.descriptionRussian,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withAlpha(80),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.tips_and_updates_rounded,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Совет: Слушай произношение, тренируй речь с микрофоном и нажимай на грамматические подсказки!',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRestartConfirmation() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Начать диалог сначала?'),
        content: const Text(
          'История текущей беседы будет сброшена, и собеседник поздоровается заново.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Отмена'),
          ),
          FilledButton.tonal(
            onPressed: () {
              Navigator.of(ctx).pop();
              _cubit.resetConversation();
            },
            child: const Text('Сбросить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<AiRoleplayCubit, AiRoleplayState>(
        listener: (context, state) {
          _scrollToBottom();
        },
        builder: (context, state) {
          final scenario = state.scenario ?? widget.scenario;
          final character = scenario.character;

          return Scaffold(
            appBar: AppBar(
              titleSpacing: 0,
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      character.avatarEmoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                character.nameRussian,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '(${character.nameHebrew})',
                              textDirection: TextDirection.rtl,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontFamily: 'Noto Sans Hebrew',
                              ),
                            ),
                          ],
                        ),
                        Text(
                          state.isAiTyping
                              ? 'Печатает ответ... ✍️'
                              : 'В сети • ${scenario.titleRussian}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: state.isAiTyping
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.info_outline_rounded),
                  tooltip: 'О сценарии',
                  onPressed: () => _showScenarioInfo(context),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Сбросить диалог',
                  onPressed: _showRestartConfirmation,
                ),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  // Chat message list
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(top: 12, bottom: 8),
                      itemCount: state.messages.length + (state.isAiTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == state.messages.length) {
                          // Typing indicator
                          return _AiTypingBubble(character: character);
                        }
                        final message = state.messages[index];
                        return AiChatBubble(
                          message: message,
                          character: character,
                          audioService: widget.audioService,
                          addCardToSrsUseCase: widget.addCardToSrsUseCase,
                        );
                      },
                    ),
                  ),

                  // Suggested prompts quick-reply bar
                  if (!state.isAiTyping && scenario.suggestedPrompts.isNotEmpty)
                    SuggestedPromptChips(
                      prompts: scenario.suggestedPrompts,
                      onPromptSelected: _onPromptSelected,
                    ),

                  // Input bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      border: Border(
                        top: BorderSide(
                          color: theme.colorScheme.outlineVariant.withAlpha(100),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Speech dictation button
                        IconButton(
                          icon: Icon(
                            _isListening
                                ? Icons.mic_rounded
                                : Icons.mic_none_rounded,
                            color: _isListening
                                ? theme.colorScheme.error
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                          tooltip: _isListening
                              ? 'Остановить запись'
                              : 'Диктовать на иврите',
                          onPressed: _toggleSpeechRecognition,
                        ),

                        // Virtual Nikkud Keyboard toggle
                        IconButton(
                          icon: Icon(
                            _showVirtualKeyboard
                                ? Icons.keyboard_hide_rounded
                                : Icons.keyboard_rounded,
                            color: _showVirtualKeyboard
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                          tooltip: _showVirtualKeyboard
                              ? 'Скрыть клавиатуру огласовок'
                              : 'Открыть клавиатуру с огласовками (Никуд)',
                          onPressed: () {
                            setState(() {
                              _showVirtualKeyboard = !_showVirtualKeyboard;
                            });
                          },
                        ),

                        // Text field
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            focusNode: _focusNode,
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.start,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontFamily: 'Noto Sans Hebrew',
                              height: 1.45,
                            ),
                            decoration: InputDecoration(
                              hintText: 'ענה בעברית... (ответь на иврите)',
                              hintTextDirection: TextDirection.rtl,
                              hintStyle: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant.withAlpha(150),
                                fontSize: 13,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide(
                                  color: theme.colorScheme.outlineVariant,
                                ),
                              ),
                              isDense: true,
                            ),
                            onSubmitted: (_) => _onSendPressed(),
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Send button
                        IconButton.filled(
                          icon: const Icon(Icons.send_rounded, size: 20),
                          onPressed: _onSendPressed,
                        ),
                      ],
                    ),
                  ),

                  // Virtual Nikkud Keyboard
                  if (_showVirtualKeyboard)
                    HebrewNiqqudKeyboard(
                      controller: _textController,
                      showHeader: true,
                      onClose: () {
                        setState(() => _showVirtualKeyboard = false);
                      },
                      onSubmitted: _onSendPressed,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AiTypingBubble extends StatelessWidget {
  final AiRoleplayCharacter character;

  const _AiTypingBubble({required this.character});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(
              character.avatarEmoji,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withAlpha(150),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Печатает...',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
