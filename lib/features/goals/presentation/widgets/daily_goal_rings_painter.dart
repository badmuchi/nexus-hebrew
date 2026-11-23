import 'dart:math' as math;

import 'package:flutter/material.dart';

/// CustomPainter rendering 3 concentric activity rings (Apple Fitness style).
class DailyGoalRingsPainter extends CustomPainter {
  final double cardsProgress;
  final double minutesProgress;
  final double questsProgress;
  final Color cardsColor;
  final Color minutesColor;
  final Color questsColor;
  final double strokeWidth;

  const DailyGoalRingsPainter({
    required this.cardsProgress,
    required this.minutesProgress,
    required this.questsProgress,
    this.cardsColor = const Color(0xFF00BFA5), // Teal / Emerald
    this.minutesColor = const Color(0xFFFF9100), // Amber / Orange
    this.questsColor = const Color(0xFF7C4DFF), // Purple / Indigo
    this.strokeWidth = 8.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) / 2 - (strokeWidth / 2);
    final spacing = strokeWidth + 3.0;

    // Ring 1 (Outer: Cards)
    _drawRing(
      canvas: canvas,
      center: center,
      radius: maxRadius,
      progress: cardsProgress,
      color: cardsColor,
    );

    // Ring 2 (Middle: Practice Minutes)
    _drawRing(
      canvas: canvas,
      center: center,
      radius: (maxRadius - spacing).clamp(0.0, maxRadius),
      progress: minutesProgress,
      color: minutesColor,
    );

    // Ring 3 (Inner: Sabra Quests)
    _drawRing(
      canvas: canvas,
      center: center,
      radius: (maxRadius - (spacing * 2)).clamp(0.0, maxRadius),
      progress: questsProgress,
      color: questsColor,
    );
  }

  void _drawRing({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required double progress,
    required Color color,
  }) {
    if (radius <= 0) return;

    // Track Paint (background)
    final trackPaint = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0.0) return;

    // Progress Arc Paint
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (2 * math.pi * progress.clamp(0.0, 1.0));
    const startAngle = -math.pi / 2; // Top 12 o'clock

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant DailyGoalRingsPainter oldDelegate) {
    return oldDelegate.cardsProgress != cardsProgress ||
        oldDelegate.minutesProgress != minutesProgress ||
        oldDelegate.questsProgress != questsProgress ||
        oldDelegate.cardsColor != cardsColor ||
        oldDelegate.minutesColor != minutesColor ||
        oldDelegate.questsColor != questsColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
