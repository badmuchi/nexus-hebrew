import 'dart:math' as math;
import 'package:flutter/material.dart';

/// CustomPainter rendering the mathematical FSRS-4.5 forgetting curve R(t) = 0.9^(t / S).
class FsrsRetentionChart extends StatelessWidget {
  final double averageStabilityDays;
  final double currentRetentionRate;
  final List<double> retentionCurvePoints; // R(0)..R(30)
  final double height;

  const FsrsRetentionChart({
    super.key,
    required this.averageStabilityDays,
    required this.currentRetentionRate,
    required this.retentionCurvePoints,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Legend & Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Кривая забывания R(t)',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Текущее удержание: ${(currentRetentionRate * 100).toStringAsFixed(1)}%',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Curve canvas
        SizedBox(
          height: height,
          child: CustomPaint(
            painter: _RetentionCurvePainter(
              points: retentionCurvePoints,
              stability: averageStabilityDays > 0 ? averageStabilityDays : 7.0,
              currentRetention: currentRetentionRate,
              isDark: isDark,
              primaryColor: theme.colorScheme.primary,
            ),
          ),
        ),

        // X-Axis labels
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'День 0 (100%)',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              Text(
                'День 10',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              Text(
                'День 20',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              Text(
                'День 30',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RetentionCurvePainter extends CustomPainter {
  final List<double> points;
  final double stability;
  final double currentRetention;
  final bool isDark;
  final Color primaryColor;

  _RetentionCurvePainter({
    required this.points,
    required this.stability,
    required this.currentRetention,
    required this.isDark,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    const padding = EdgeInsets.fromLTRB(4, 8, 4, 16);
    final drawWidth = size.width - padding.left - padding.right;
    final drawHeight = size.height - padding.top - padding.bottom;

    final targetThresholdY = padding.top + drawHeight * (1.0 - 0.90);

    // Dashed line at 90% target retention
    final dashPaint = Paint()
      ..color = const Color(0xFF10B981).withAlpha(160)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    _drawDashedHorizontalLine(
      canvas,
      padding.left,
      size.width - padding.right,
      targetThresholdY,
      dashPaint,
    );

    // Label for 90% target line
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '90% порог FSRS',
        style: TextStyle(
          color: Color(0xFF10B981),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(size.width - padding.right - textPainter.width - 4, targetThresholdY - 14),
    );

    // Construct curve path
    final curvePath = Path();
    final fillPath = Path();

    final stepX = drawWidth / (points.length - 1);

    for (var i = 0; i < points.length; i++) {
      final x = padding.left + i * stepX;
      // Clamp R in [0.0, 1.0]
      final r = points[i].clamp(0.0, 1.0);
      final y = padding.top + drawHeight * (1.0 - r);

      if (i == 0) {
        curvePath.moveTo(x, y);
        fillPath.moveTo(x, padding.top + drawHeight);
        fillPath.lineTo(x, y);
      } else {
        curvePath.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(padding.left + drawWidth, padding.top + drawHeight);
    fillPath.close();

    // Fill gradient under curve
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        primaryColor.withAlpha(isDark ? 80 : 60),
        primaryColor.withAlpha(5),
      ],
    );

    final fillPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      )
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Stroke line for the curve
    final strokePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(curvePath, strokePaint);

    // Draw Optimal Review Point (where R = 0.90, i.e. at day = stability)
    final optDay = stability.clamp(0.0, 30.0);
    final optX = padding.left + (optDay / 30.0) * drawWidth;
    final optY = targetThresholdY;

    final optCirclePaint = Paint()
      ..color = const Color(0xFF10B981)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(optX, optY), 5, optCirclePaint);
    canvas.drawCircle(
      Offset(optX, optY),
      8,
      Paint()
        ..color = const Color(0xFF10B981).withAlpha(80)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawDashedHorizontalLine(
    Canvas canvas,
    double startX,
    double endX,
    double y,
    Paint paint,
  ) {
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    var curX = startX;
    while (curX < endX) {
      final nextX = math.min(curX + dashWidth, endX);
      canvas.drawLine(Offset(curX, y), Offset(nextX, y), paint);
      curX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _RetentionCurvePainter oldDelegate) {
    return oldDelegate.stability != stability ||
        oldDelegate.currentRetention != currentRetention ||
        oldDelegate.points != points ||
        oldDelegate.isDark != isDark;
  }
}
