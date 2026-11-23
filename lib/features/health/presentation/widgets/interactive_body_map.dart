import 'package:flutter/material.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../srs/domain/entities/srs_card.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../domain/entities/body_part.dart';

/// Interactive body map and symptoms explorer with grammatical gender and dual-form rules.
class InteractiveBodyMap extends StatefulWidget {
  final List<BodyPart> bodyParts;
  final AudioPlaybackService? audioService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;

  const InteractiveBodyMap({
    super.key,
    required this.bodyParts,
    this.audioService,
    this.addCardToSrsUseCase,
  });

  @override
  State<InteractiveBodyMap> createState() => _InteractiveBodyMapState();
}

class _InteractiveBodyMapState extends State<InteractiveBodyMap> {
  BodyRegion? _selectedRegion;
  String? _expandedPartId;

  List<BodyPart> get _filteredParts {
    if (_selectedRegion == null) return widget.bodyParts;
    return widget.bodyParts
        .where((part) => part.region == _selectedRegion)
        .toList();
  }

  void _toggleExpanded(String id) {
    setState(() {
      _expandedPartId = _expandedPartId == id ? null : id;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final parts = _filteredParts;

    return Column(
      children: [
        // Top Information Banner
        Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('💡 ', style: TextStyle(fontSize: 22)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Секрет анатомии в иврите:',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Парные части тела (глаза, уши, руки, ноги, колени) оканчиваются на ־ַיִם (-а́йим) и почти всегда ЖЕНСКОГО рода! «כּוֹאֲבוֹת לִי הָעֵינַיִם» (коаво́т), а не «כואבים».',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.brown.shade900,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Region Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('Все части тела'),
                selected: _selectedRegion == null,
                onSelected: (val) {
                  if (val) setState(() => _selectedRegion = null);
                },
              ),
              const SizedBox(width: 8),
              ...BodyRegion.values.map((reg) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('${reg.emoji} ${reg.titleRu}'),
                    selected: _selectedRegion == reg,
                    onSelected: (val) {
                      setState(() => _selectedRegion = val ? reg : null);
                    },
                  ),
                );
              }),
            ],
          ),
        ),

        // Body Parts List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: parts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final part = parts[index];
              final isExpanded = _expandedPartId == part.id;

              return Card(
                elevation: 1.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isExpanded
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                    width: isExpanded ? 1.5 : 1.0,
                  ),
                ),
                child: InkWell(
                  onTap: () => _toggleExpanded(part.id),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Main row
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer
                                    .withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                part.iconEmoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        part.russianName,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 1.5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: part.isFeminine
                                              ? Colors.pink.shade50
                                              : Colors.blue.shade50,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border: Border.all(
                                            color: part.isFeminine
                                                ? Colors.pink.shade200
                                                : Colors.blue.shade200,
                                          ),
                                        ),
                                        child: Text(
                                          part.isDualForm
                                              ? 'Жен. род (двойств.)'
                                              : (part.isFeminine
                                                  ? 'Жен. род'
                                                  : 'Муж. род'),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: part.isFeminine
                                                ? Colors.pink.shade900
                                                : Colors.blue.shade900,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '(${part.transcriptionRu})'
                                    '${part.pluralOrDualHebrewWithNikkud != null ? ' • мн. ч.: ${part.pluralOrDualHebrewWithNikkud}' : ''}',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              part.hebrewWithNikkud,
                              textDirection: TextDirection.rtl,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.volume_up_rounded),
                              tooltip: 'Озвучить слово',
                              onPressed: () {
                                widget.audioService?.playWithTtsFallback(
                                  sourcePath: null,
                                  fallbackHebrewText: part.hebrewWithNikkud,
                                );
                              },
                            ),
                          ],
                        ),

                        // Expanded section: Pain phrase & Grammar tip
                        if (isExpanded) ...[
                          const Divider(height: 20),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      '🗣️ Как сказать врачу:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      icon: const Icon(
                                        Icons.volume_up_rounded,
                                        size: 20,
                                      ),
                                      tooltip: 'Озвучить фразу',
                                      onPressed: () {
                                        widget.audioService
                                            ?.playWithTtsFallback(
                                          sourcePath: null,
                                          fallbackHebrewText:
                                              part.painPhraseHebrewWithNikkud,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                Text(
                                  part.painPhraseHebrewWithNikkud,
                                  textDirection: TextDirection.rtl,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                    height: 1.45,
                                  ),
                                ),
                                Text(
                                  part.painPhraseTranscriptionRu,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  part.painPhraseRussian,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.amber.shade200,
                                    ),
                                  ),
                                  child: Text(
                                    '💡 ${part.grammaticalTipRu}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.brown.shade900,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (widget.addCardToSrsUseCase != null)
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      icon: const Icon(
                                        Icons.bookmark_add_outlined,
                                        size: 18,
                                      ),
                                      label: const Text('В карточки FSRS'),
                                      onPressed: () async {
                                        final res = await widget
                                            .addCardToSrsUseCase
                                            ?.call(
                                          AddCardToSrsParams(
                                            id: 'body_${part.id}',
                                            hebrewVocalized:
                                                part.hebrewWithNikkud,
                                            russianTranslation:
                                                '${part.russianName} • ${part.painPhraseRussian}',
                                            category: LexicalCategory.noun,
                                            exampleHebrewVocalized:
                                                part.painPhraseHebrewWithNikkud,
                                            exampleRussian:
                                                part.painPhraseRussian,
                                          ),
                                        );
                                        if (context.mounted) {
                                          final msg = (res?.isSuccess ?? false)
                                              ? '«${part.hebrewPlain}» добавлено в FSRS!'
                                              : 'Уже есть в колоде или ошибка';
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(msg),
                                              duration:
                                                  const Duration(seconds: 2),
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
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
