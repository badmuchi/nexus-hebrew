import 'package:flutter/material.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../conversation/presentation/widgets/pronunciation_practice_sheet.dart';
import '../../../srs/domain/entities/srs_card.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../domain/entities/ai_chat_message.dart';
import '../../domain/entities/ai_roleplay_character.dart';

class AiChatBubble extends StatefulWidget {
  final AiChatMessage message;
  final AiRoleplayCharacter character;
  final AudioPlaybackService? audioService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;

  const AiChatBubble({
    super.key,
    required this.message,
    required this.character,
    this.audioService,
    this.addCardToSrsUseCase,
  });

  @override
  State<AiChatBubble> createState() => _AiChatBubbleState();
}

class _AiChatBubbleState extends State<AiChatBubble> {
  bool _showTranslation = true;
  bool _isPlayingAudio = false;
  bool _isAddedToSrs = false;

  Future<void> _playAudio() async {
    if (_isPlayingAudio || widget.audioService == null) return;
    setState(() => _isPlayingAudio = true);
    await widget.audioService!.playWithTtsFallback(
      sourcePath: null,
      fallbackHebrewText: widget.message.hebrewText,
    );
    if (mounted) {
      setState(() => _isPlayingAudio = false);
    }
  }

  void _openPronunciationPractice() {
    PronunciationPracticeSheet.show(
      context,
      phraseVocalized: widget.message.hebrewText,
      phraseRussian: widget.message.russianTranslation ?? '',
      transliteration: widget.message.transliteration,
      audioService: widget.audioService,
    );
  }

  Future<void> _addToSrs() async {
    if (_isAddedToSrs || widget.addCardToSrsUseCase == null) return;
    final params = AddCardToSrsParams(
      id: 'ai_phrase_${DateTime.now().microsecondsSinceEpoch}',
      hebrewVocalized: widget.message.hebrewText,
      russianTranslation: widget.message.russianTranslation ?? 'Разговорная фраза',
      attribution: ContentAttribution(
        sourceName: 'AI Диалог: ${widget.character.nameRussian}',
        licenseName: 'User Dialogue',
      ),
    );
    final res = await widget.addCardToSrsUseCase!(params);
    if (res.isSuccess && mounted) {
      setState(() => _isAddedToSrs = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Фраза добавлена в карточки FSRS! 🗂️'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = widget.message.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                CircleAvatar(
                  radius: 18,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    widget.character.avatarEmoji,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 520),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isUser
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isUser ? 18 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: isUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      // Hebrew text with proper Bidi RTL & line height for Nikkud
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(
                          widget.message.hebrewText,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isUser
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            height: 1.5, // Nikkud protection
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      if (widget.message.russianTranslation != null &&
                          _showTranslation) ...[
                        const SizedBox(height: 6),
                        Text(
                          widget.message.russianTranslation!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isUser
                                ? theme.colorScheme.onPrimary.withValues(alpha: 0.9)
                                : theme.colorScheme.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                      ],
                      if (widget.message.transliteration != null &&
                          _showTranslation) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.message.transliteration!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isUser
                                ? theme.colorScheme.onPrimary.withValues(alpha: 0.75)
                                : theme.colorScheme.outline,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (isUser) ...[
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  child: const Text('👤', style: TextStyle(fontSize: 16)),
                ),
              ],
            ],
          ),

          // Grammar correction alert card if present
          if (widget.message.grammarCorrection != null) ...[
            const SizedBox(height: 6),
            Padding(
              padding: EdgeInsetsDirectional.only(
                start: isUser ? 0 : 44,
                end: isUser ? 44 : 0,
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 520),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lightbulb_rounded,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.message.grammarCorrection!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.brown.shade900,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Action toolbar for AI messages
          if (!isUser) ...[
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 44, top: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: _playAudio,
                    icon: Icon(
                      _isPlayingAudio
                          ? Icons.volume_up_rounded
                          : Icons.volume_down_rounded,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    tooltip: 'Озвучить фразу',
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    onPressed: _openPronunciationPractice,
                    icon: Icon(
                      Icons.mic_none_rounded,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    tooltip: 'Потренировать произношение',
                    visualDensity: VisualDensity.compact,
                  ),
                  if (widget.addCardToSrsUseCase != null)
                    IconButton(
                      onPressed: _isAddedToSrs ? null : _addToSrs,
                      icon: Icon(
                        _isAddedToSrs
                            ? Icons.bookmark_added_rounded
                            : Icons.bookmark_add_outlined,
                        size: 20,
                        color: _isAddedToSrs
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline,
                      ),
                      tooltip: _isAddedToSrs
                          ? 'Уже в колоде FSRS'
                          : 'Добавить фразу в FSRS',
                      visualDensity: VisualDensity.compact,
                    ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _showTranslation = !_showTranslation;
                      });
                    },
                    icon: Icon(
                      _showTranslation
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 18,
                      color: theme.colorScheme.outline,
                    ),
                    tooltip: _showTranslation ? 'Скрыть перевод' : 'Показать перевод',
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
