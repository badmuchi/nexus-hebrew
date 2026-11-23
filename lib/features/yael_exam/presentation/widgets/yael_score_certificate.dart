import 'package:flutter/material.dart';

import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../domain/entities/yael_exam_result.dart';
import '../../domain/entities/yael_question.dart';

/// Official NITE-style score certificate displaying the YAEL test outcome.
class YaelScoreCertificate extends StatelessWidget {
  final YaelExamResult result;
  final VoidCallback onRetake;
  final VoidCallback onReviewMistakes;
  final AddCardToSrsUseCase? addCardToSrsUseCase;

  const YaelScoreCertificate({
    super.key,
    required this.result,
    required this.onRetake,
    required this.onReviewMistakes,
    this.addCardToSrsUseCase,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final band = result.band;
    final bandColor = Color(band.colorHex);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.school_rounded, color: Color(0xFF1E88E5), size: 28),
                const SizedBox(width: 8),
                Text(
                  'РЕЗУЛЬТАТ ТЕСТА ЯЭЛЬ (צִיּוּן מִבְחַן יַעֵ״ל)',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: const Color(0xFF1E88E5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Big Score Circle / Card
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: bandColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: bandColor.withValues(alpha: 0.4), width: 1.5),
              ),
              child: Column(
                children: [
                  Text(
                    '${result.scaledScore}',
                    style: TextStyle(
                      fontSize: 54,
                      fontWeight: FontWeight.w900,
                      color: bandColor,
                      height: 1.0,
                    ),
                  ),
                  const Text(
                    'из 150 баллов (Шкала NITE Израиль)',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      band.hebrewTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: bandColor,
                        height: 1.45,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    band.titleRu,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Academic Exemption Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🏛️ ', style: TextStyle(fontSize: 20)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Академический допуск в университеты:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          band.academicExemptionRu,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Section Performance Breakdown
            Text(
              'Успеваемость по разделам экзамена:',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            ...YaelSection.values.map((section) {
              final correct = result.sectionCorrectCounts[section] ?? 0;
              final total = result.sectionTotals[section] ?? 0;
              final percent = total > 0 ? (correct / total) : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${section.iconEmoji} ${section.titleRu}',
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          '$correct / $total',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                            color: percent >= 0.75 ? Colors.green : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percent,
                        minHeight: 6,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          percent >= 0.75 ? Colors.green : Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),

            // Action Buttons: Review Mistakes / Retake Exam
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReviewMistakes,
                    icon: const Icon(Icons.fact_check_rounded),
                    label: const Text('Разбор ответов'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onRetake,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Пройти заново'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
