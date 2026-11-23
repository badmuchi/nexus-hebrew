import 'package:flutter/material.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../srs/domain/entities/srs_card.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../domain/entities/shabbat_survival_rule.dart';

/// Interactive Shabbat Survival Guide card showcasing the 4 phases of an Israeli weekend.
class ShabbatSurvivalCard extends StatefulWidget {
  final List<ShabbatRule> stages;
  final AudioPlaybackService? audioService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;

  const ShabbatSurvivalCard({
    super.key,
    required this.stages,
    this.audioService,
    this.addCardToSrsUseCase,
  });

  @override
  State<ShabbatSurvivalCard> createState() => _ShabbatSurvivalCardState();
}

class _ShabbatSurvivalCardState extends State<ShabbatSurvivalCard> {
  int _selectedStageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stage = widget.stages[_selectedStageIndex];

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade100.withValues(alpha: 0.6),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Text('🕯️ ', style: TextStyle(fontSize: 26)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Шаббат в Израиле (שַׁבָּת קֹדֶשׁ)',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.brown.shade900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Ритм выходных: от пятничной суеты до вечерней Авдалы',
                        style: TextStyle(fontSize: 12, color: Colors.brown),
                      ),
                    ],
                  ),
                ),
                if (widget.audioService != null)
                  IconButton.filledTonal(
                    icon: const Icon(Icons.volume_up_rounded),
                    tooltip: 'Озвучить пожелание субботы',
                    onPressed: () => widget.audioService?.playWithTtsFallback(
                      sourcePath: null,
                      fallbackHebrewText: 'שַׁבָּת שָׁלוֹם וּמְבֹרָךְ!',
                    ),
                  ),
              ],
            ),
          ),

          // Timeline segment selector
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 6),
            child: Row(
              children: List.generate(widget.stages.length, (index) {
                final s = widget.stages[index];
                final isSel = index == _selectedStageIndex;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: InkWell(
                      onTap: () => setState(() => _selectedStageIndex = index),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSel
                              ? theme.colorScheme.primary
                              : theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSel
                                ? theme.colorScheme.primary
                                : Colors.transparent,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(s.iconEmoji, style: const TextStyle(fontSize: 18)),
                            const SizedBox(height: 3),
                            Text(
                              'Этап ${index + 1}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isSel
                                    ? Colors.white
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Stage Details Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        stage.titleRu,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      stage.timeWindowRu,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        stage.hebrewTitleWithNikkud,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                          height: 1.45,
                        ),
                      ),
                    ),
                    if (widget.audioService != null)
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.volume_up_rounded, size: 20),
                        tooltip: 'Озвучить название этапа',
                        onPressed: () =>
                            widget.audioService?.playWithTtsFallback(
                          sourcePath: null,
                          fallbackHebrewText: stage.hebrewTitleWithNikkud,
                        ),
                      ),
                  ],
                ),
                Text(
                  '(${stage.transcriptionRu})',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  stage.descriptionRu,
                  style: const TextStyle(fontSize: 13, height: 1.35),
                ),
                const SizedBox(height: 12),

                // Transport & Shops Callout
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.directions_bus_filled_rounded,
                              size: 18, color: Colors.blue),
                          const SizedBox(width: 6),
                          Text(
                            'Транспорт и магазины:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stage.transportAndShopsRu,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade900,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Etiquette Tip Callout
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('💡 ', style: TextStyle(fontSize: 18)),
                      Expanded(
                        child: Text(
                          stage.etiquetteTipRu,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.brown.shade900,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Add to SRS
                if (widget.addCardToSrsUseCase != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                      label: const Text('В карточки FSRS'),
                      onPressed: () async {
                        final res = await widget.addCardToSrsUseCase?.call(
                          AddCardToSrsParams(
                            id: 'shabbat_${stage.id}',
                            hebrewVocalized: stage.hebrewTitleWithNikkud,
                            russianTranslation:
                                '${stage.titleRu} (${stage.transcriptionRu}) — ${stage.etiquetteTipRu}',
                            category: LexicalCategory.noun,
                            exampleHebrewVocalized: stage.hebrewTitleWithNikkud,
                            exampleRussian: stage.titleRu,
                          ),
                        );
                        if (context.mounted) {
                          final msg = (res?.isSuccess ?? false)
                              ? '«${stage.titleRu}» добавлено в FSRS!'
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
}
