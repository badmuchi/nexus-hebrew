import 'package:flutter/material.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../domain/entities/hebrew_letter.dart';

/// Interactive handwriting practice canvas (Прописи / Ктав Яд)
/// allowing the user to trace and practice Hebrew script with finger or stylus.
class CursivePracticeCanvas extends StatefulWidget {
  final HebrewLetter letter;
  final AudioPlaybackService? audioService;

  const CursivePracticeCanvas({
    super.key,
    required this.letter,
    this.audioService,
  });

  @override
  State<CursivePracticeCanvas> createState() => _CursivePracticeCanvasState();
}

class _CursivePracticeCanvasState extends State<CursivePracticeCanvas> {
  final List<List<Offset>> _strokes = [];
  bool _showGuidelines = true;
  bool _showTracingGuide = true;

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _strokes.add([details.localPosition]);
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_strokes.isEmpty) return;
    setState(() {
      _strokes.last.add(details.localPosition);
    });
  }

  void _clear() {
    setState(() {
      _strokes.clear();
    });
  }

  void _undo() {
    if (_strokes.isNotEmpty) {
      setState(() {
        _strokes.removeLast();
      });
    }
  }

  void _playAudio() {
    widget.audioService?.playWithTtsFallback(
      sourcePath: null,
      fallbackHebrewText: widget.letter.nameHebrew,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    widget.letter.printed,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                      height: 1.3,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Прописи · ${widget.letter.nameRussian} (${widget.letter.nameHebrew})',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Ктав яд (рукописный шрифт)',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: 'Произношение',
                  icon: const Icon(Icons.volume_up_rounded),
                  onPressed: _playAudio,
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Закрыть',
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsetsDirectional.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.edit_note_rounded,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.letter.cursiveDescription,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            AspectRatio(
              aspectRatio: 1.35,
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? const Color(0xFF1E222A)
                      : const Color(0xFFF9FAFD),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                ),
                child: GestureDetector(
                  key: const Key('cursive_drawing_area'),
                  onPanStart: _onPanStart,
                  onPanUpdate: _onPanUpdate,
                  child: CustomPaint(
                  painter: _HandwritingPainter(
                    strokes: _strokes,
                    letter: widget.letter,
                    showGuidelines: _showGuidelines,
                    showTracingGuide: _showTracingGuide,
                    strokeColor: colorScheme.primary,
                    guidelineColor:
                        colorScheme.outlineVariant.withValues(alpha: 0.4),
                    guideLetterColor: colorScheme.primary.withValues(alpha: 0.18),
                  ),
                  size: Size.infinite,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  FilterChip(
                    label: const Text('Сетка'),
                    selected: _showGuidelines,
                    onSelected: (bool value) {
                      setState(() {
                        _showGuidelines = value;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Контур'),
                    selected: _showTracingGuide,
                    onSelected: (bool value) {
                      setState(() {
                        _showTracingGuide = value;
                      });
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _strokes.isNotEmpty ? _undo : null,
                    icon: const Icon(Icons.undo_rounded, size: 18),
                    label: const Text('Отмена'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonalIcon(
                    onPressed: _strokes.isNotEmpty ? _clear : null,
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    label: const Text('Очистить'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
}

class _HandwritingPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final HebrewLetter letter;
  final bool showGuidelines;
  final bool showTracingGuide;
  final Color strokeColor;
  final Color guidelineColor;
  final Color guideLetterColor;

  _HandwritingPainter({
    required this.strokes,
    required this.letter,
    required this.showGuidelines,
    required this.showTracingGuide,
    required this.strokeColor,
    required this.guidelineColor,
    required this.guideLetterColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (showGuidelines) {
      _paintGuidelines(canvas, size);
    }

    if (showTracingGuide) {
      _paintTracingGuide(canvas, size);
    }

    final paint = Paint()
      ..color = strokeColor
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.isEmpty) continue;
      if (stroke.length == 1) {
        canvas.drawCircle(stroke.first, 3.0, Paint()..color = strokeColor);
      } else {
        final path = Path();
        path.moveTo(stroke.first.dx, stroke.first.dy);
        for (var i = 1; i < stroke.length; i++) {
          path.lineTo(stroke[i].dx, stroke[i].dy);
        }
        canvas.drawPath(path, paint);
      }
    }
  }

  void _paintGuidelines(Canvas canvas, Size size) {
    final guidePaint = Paint()
      ..color = guidelineColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final dashPaint = Paint()
      ..color = guidelineColor.withValues(alpha: 0.6)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Top ascender line
    canvas.drawLine(
      Offset(0, size.height * 0.2),
      Offset(size.width, size.height * 0.2),
      guidePaint,
    );

    // Midline (dashed)
    final midY = size.height * 0.5;
    for (double x = 0; x < size.width; x += 12) {
      canvas.drawLine(Offset(x, midY), Offset(x + 6, midY), dashPaint);
    }

    // Baseline
    canvas.drawLine(
      Offset(0, size.height * 0.8),
      Offset(size.width, size.height * 0.8),
      guidePaint,
    );
  }

  void _paintTracingGuide(Canvas canvas, Size size) {
    // Render the Hebrew letter watermark for tracing practice
    final textSpan = TextSpan(
      text: letter.printed,
      style: TextStyle(
        fontSize: size.height * 0.52,
        color: guideLetterColor,
        fontWeight: FontWeight.w300,
        height: 1.35,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.rtl,
    );
    textPainter.layout();
    final xCenter = (size.width - textPainter.width) / 2;
    final yCenter = (size.height - textPainter.height) / 2;
    textPainter.paint(canvas, Offset(xCenter, yCenter));
  }

  @override
  bool shouldRepaint(covariant _HandwritingPainter oldDelegate) {
    return true;
  }
}
