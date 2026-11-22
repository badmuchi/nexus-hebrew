import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../domain/entities/handwritten_note.dart';

enum NoteViewMode {
  cursive('✍️ Ктав Яд'),
  printedWithNikkud('🖨️ Печатный'),
  transcription('🔤 Транскрипция'),
  translation('🇷🇺 Перевод');

  final String label;
  const NoteViewMode(this.label);
}

/// Rich, interactive paper card presenting a real Israeli handwritten note
/// with multi-level X-ray inspection (cursive -> vocalized print -> transcription -> translation).
class HandwrittenNoteCard extends StatefulWidget {
  final HandwrittenNote note;
  final AudioPlaybackService? audioService;
  final ValueChanged<int>? onXpEarned;

  const HandwrittenNoteCard({
    super.key,
    required this.note,
    this.audioService,
    this.onXpEarned,
  });

  @override
  State<HandwrittenNoteCard> createState() => _HandwrittenNoteCardState();
}

class _HandwrittenNoteCardState extends State<HandwrittenNoteCard> {
  NoteViewMode _viewMode = NoteViewMode.cursive;
  bool _isPlayingAudio = false;
  int? _selectedAnswerIndex;
  bool _isAnswered = false;

  void _onAnswer(int index) {
    if (_isAnswered) return;
    unawaited(HapticFeedback.lightImpact());

    final isCorrect = index == widget.note.quiz.correctAnswerIndex;
    if (isCorrect) {
      unawaited(HapticFeedback.mediumImpact());
      widget.onXpEarned?.call(20);
    }

    setState(() {
      _selectedAnswerIndex = index;
      _isAnswered = true;
    });
  }

  Future<void> _playAudio() async {
    final audio = widget.audioService;
    if (audio == null) return;

    setState(() => _isPlayingAudio = true);
    try {
      await audio.playWithTtsFallback(
        sourcePath: widget.note.audioPath,
        fallbackHebrewText: widget.note.hebrewWithNikkud,
      );
    } finally {
      if (mounted) {
        setState(() => _isPlayingAudio = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final note = widget.note;

    // Distinctive warm stationery look
    final paperColor = isDark ? const Color(0xFF262A34) : const Color(0xFFFFFDE7); // Warm yellow note
    final borderColor = isDark ? const Color(0xFF454B5C) : const Color(0xFFFFF176);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: borderColor, width: 1.5),
      ),
      color: paperColor,
      child: Padding(
        padding: const EdgeInsetsDirectional.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header: Category & Situation Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(note.category.emoji, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(
                        note.category.titleRu,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF57F17),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                IconButton.filledTonal(
                  tooltip: 'Озвучить записку',
                  visualDensity: VisualDensity.compact,
                  onPressed: _isPlayingAudio ? null : _playAudio,
                  icon: Icon(
                    _isPlayingAudio ? Icons.volume_up_rounded : Icons.volume_down_rounded,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Text(
              note.situationTitleRu,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF37474F),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              note.contextDescriptionRu,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 14),

            // 4-way Mode Selector Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final mode in NoteViewMode.values) ...[
                    ChoiceChip(
                      label: Text(mode.label),
                      selected: _viewMode == mode,
                      visualDensity: VisualDensity.compact,
                      onSelected: (val) {
                        if (val) setState(() => _viewMode = mode);
                      },
                    ),
                    const SizedBox(width: 6),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Note Content Box
            Container(
              padding: const EdgeInsetsDirectional.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E212B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white12 : const Color(0xFFFFEE58),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _buildInspectedText(theme, isDark),
            ),
            const SizedBox(height: 12),

            // Tricky Letters Tip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF00897B).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF00897B).withValues(alpha: 0.25)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🔍', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      note.trickyLettersTipRu,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? const Color(0xFF80CBC4) : const Color(0xFF004D40),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Note Comprehension Quiz
            Text(
              'Задание дешифровщика:',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              note.quiz.questionRu,
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),

            for (int i = 0; i < note.quiz.options.length; i++) ...[
              _buildQuizOptionTile(theme, note.quiz, i, isDark),
              const SizedBox(height: 6),
            ],

            // Quiz Explanation Feedback
            if (_isAnswered) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (_selectedAnswerIndex == note.quiz.correctAnswerIndex)
                      ? const Color(0xFF2E7D32).withValues(alpha: 0.12)
                      : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (_selectedAnswerIndex == note.quiz.correctAnswerIndex)
                        ? const Color(0xFF2E7D32).withValues(alpha: 0.3)
                        : Colors.red.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  note.quiz.explanationRu,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: (_selectedAnswerIndex == note.quiz.correctAnswerIndex)
                        ? const Color(0xFF2E7D32)
                        : Colors.red.shade800,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInspectedText(ThemeData theme, bool isDark) {
    final note = widget.note;

    switch (_viewMode) {
      case NoteViewMode.cursive:
        // Stylized Israeli cursive handwriting simulation
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            note.rawHebrew,
            style: TextStyle(
              fontSize: 22,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
              height: 1.6,
              color: isDark ? const Color(0xFF90CAF9) : const Color(0xFF0D47A1), // Classic blue ballpoint pen ink
            ),
          ),
        );
      case NoteViewMode.printedWithNikkud:
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            note.hebrewWithNikkud,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1.5,
              color: theme.colorScheme.primary,
            ),
          ),
        );
      case NoteViewMode.transcription:
        return Text(
          note.transcriptionRu,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontStyle: FontStyle.italic,
            height: 1.45,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        );
      case NoteViewMode.translation:
        return Text(
          note.translationRu,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            height: 1.45,
            color: isDark ? Colors.white : const Color(0xFF2E7D32),
          ),
        );
    }
  }

  Widget _buildQuizOptionTile(ThemeData theme, NoteQuizQuestion quiz, int index, bool isDark) {
    final isSelected = _selectedAnswerIndex == index;
    final isCorrect = index == quiz.correctAnswerIndex;

    Color borderColor = theme.colorScheme.outlineVariant.withValues(alpha: 0.4);
    Color bgColor = isDark ? const Color(0xFF1E212B) : Colors.white;

    if (_isAnswered) {
      if (isCorrect) {
        borderColor = const Color(0xFF2E7D32);
        bgColor = const Color(0xFF2E7D32).withValues(alpha: 0.15);
      } else if (isSelected) {
        borderColor = Colors.red;
        bgColor = Colors.red.withValues(alpha: 0.12);
      }
    }

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: _isAnswered ? null : () => _onAnswer(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: isSelected || (_isAnswered && isCorrect) ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  quiz.options[index],
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
              if (_isAnswered && isCorrect)
                const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 18)
              else if (_isAnswered && isSelected)
                const Icon(Icons.cancel_rounded, color: Colors.red, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
