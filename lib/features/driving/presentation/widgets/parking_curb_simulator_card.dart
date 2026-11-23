import 'package:flutter/material.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../srs/domain/entities/srs_card.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../domain/entities/parking_curb_rule.dart';

/// Interactive Israeli parking curb simulator displaying sidewalk paint, municipal signs, and parking rules.
class ParkingCurbSimulatorCard extends StatefulWidget {
  final ParkingCurbCase curbCase;
  final AudioPlaybackService? audioService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;

  const ParkingCurbSimulatorCard({
    super.key,
    required this.curbCase,
    this.audioService,
    this.addCardToSrsUseCase,
  });

  @override
  State<ParkingCurbSimulatorCard> createState() =>
      _ParkingCurbSimulatorCardState();
}

class _ParkingCurbSimulatorCardState extends State<ParkingCurbSimulatorCard> {
  bool? _userAnswer;
  bool _hasAnswered = false;

  void _onAnswer(bool answer) {
    if (_hasAnswered) return;
    setState(() {
      _userAnswer = answer;
      _hasAnswered = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = widget.curbCase;
    final isCorrect = _userAnswer == c.isParkingAllowed;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Visual Sidewalk Curb Strip
          _buildCurbVisualStrip(c.curbType),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Street and Curb Type Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        c.titleRu,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      c.curbType.hebrewTitle,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${c.streetNameRu} (${c.streetNameHebrewWithNikkud})',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    if (widget.audioService != null)
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.volume_up_rounded, size: 20),
                        tooltip: 'Озвучить название улицы',
                        onPressed: () =>
                            widget.audioService?.playWithTtsFallback(
                          sourcePath: null,
                          fallbackHebrewText: c.streetNameHebrewWithNikkud,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Municipal Parking Sign Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade900,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.local_parking_rounded,
                              color: Colors.white, size: 28),
                          const SizedBox(width: 8),
                          Text(
                            'תַּמְרוּר חֲנָיָה עִירוֹנִי (Знак мэрии)',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        c.signTextHebrew,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          height: 1.4,
                        ),
                      ),
                      const Divider(color: Colors.white24, height: 16),
                      Text(
                        c.signTextRu,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Situation Question
                Text(
                  c.questionRu,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                // Action buttons: Can park vs Forbidden
                if (!_hasAnswered)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.check_circle_outline_rounded,
                              color: Colors.green),
                          label: const Text('Можно парковаться'),
                          onPressed: () => _onAnswer(true),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.cancel_outlined,
                              color: Colors.red),
                          label: const Text('Запрещено'),
                          onPressed: () => _onAnswer(false),
                        ),
                      ),
                    ],
                  )
                else ...[
                  // Feedback box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCorrect
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCorrect
                            ? Colors.green.shade300
                            : Colors.red.shade300,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isCorrect
                                  ? Icons.check_circle_rounded
                                  : Icons.error_outline_rounded,
                              color: isCorrect
                                  ? Colors.green.shade800
                                  : Colors.red.shade800,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isCorrect
                                  ? 'Верно! Отличная дорожная интуиция.'
                                  : 'Осторожно! Здесь вас оштрафуют.',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isCorrect
                                    ? Colors.green.shade900
                                    : Colors.red.shade900,
                              ),
                            ),
                          ],
                        ),
                        if (c.fineAmountTextRu != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '⚠️ Риск: ${c.fineAmountTextRu}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade800,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Text(
                          c.explanationRu,
                          style: const TextStyle(fontSize: 12.5, height: 1.35),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '💡 Совет водителя: ${c.sabraDriverTipRu}',
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.brown.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 8),

                // Add term to SRS
                if (widget.addCardToSrsUseCase != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                      label: const Text('В карточки FSRS'),
                      onPressed: () async {
                        final res = await widget.addCardToSrsUseCase?.call(
                          AddCardToSrsParams(
                            id: 'curb_${c.id}',
                            hebrewVocalized: c.curbType.hebrewTitle,
                            russianTranslation:
                                '${c.curbType.titleRu} — ${c.curbType.descriptionRu}',
                            category: LexicalCategory.noun,
                            exampleHebrewVocalized: c.streetNameHebrewWithNikkud,
                            exampleRussian: c.streetNameRu,
                          ),
                        );
                        if (context.mounted) {
                          final msg = (res?.isSuccess ?? false)
                              ? '«${c.curbType.hebrewTitle}» добавлено в FSRS!'
                              : 'Уже есть в колоде или ошибка';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(msg),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a realistic stylized painted sidewalk curb.
  Widget _buildCurbVisualStrip(CurbColorType type) {
    return Container(
      height: 24,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Row(
          children: List.generate(8, (index) {
            Color color;
            switch (type) {
              case CurbColorType.blueWhite:
                color = index.isEven ? Colors.blue.shade700 : Colors.white;
                break;
              case CurbColorType.redWhite:
                color = index.isEven ? Colors.red.shade700 : Colors.white;
                break;
              case CurbColorType.redYellow:
                color = index.isEven ? Colors.red.shade700 : Colors.amber.shade600;
                break;
              case CurbColorType.gray:
                color = Colors.grey.shade400;
                break;
            }
            return Expanded(
              child: Container(
                color: color,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: Colors.black.withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
