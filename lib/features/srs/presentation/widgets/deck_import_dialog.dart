import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/result/result.dart';
import '../../domain/entities/srs_card.dart';
import '../../domain/services/deck_import_service.dart';
import '../../domain/usecases/add_card_to_srs.dart';

/// Modal dialog allowing users to import flashcards from Anki TSV/CSV, JSON, or plain word lists.
class DeckImportDialog extends StatefulWidget {
  final AddCardToSrsUseCase addCardToSrsUseCase;
  final VoidCallback? onImportCompleted;

  const DeckImportDialog({
    super.key,
    required this.addCardToSrsUseCase,
    this.onImportCompleted,
  });

  static Future<void> show(
    BuildContext context, {
    required AddCardToSrsUseCase addCardToSrsUseCase,
    VoidCallback? onImportCompleted,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => DeckImportDialog(
        addCardToSrsUseCase: addCardToSrsUseCase,
        onImportCompleted: onImportCompleted,
      ),
    );
  }

  @override
  State<DeckImportDialog> createState() => _DeckImportDialogState();
}

class _DeckImportDialogState extends State<DeckImportDialog> {
  static const _importService = DeckImportService();

  final TextEditingController _textController = TextEditingController();
  DeckImportResult? _parsedResult;
  bool _isImporting = false;
  int _importProgress = 0;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _loadTemplate(String template) {
    setState(() {
      _textController.text = template;
      _parsedResult = _importService.parse(template);
    });
  }

  void _onTextChanged(String text) {
    if (text.trim().isEmpty) {
      if (_parsedResult != null) {
        setState(() => _parsedResult = null);
      }
      return;
    }
    setState(() {
      _parsedResult = _importService.parse(text);
    });
  }

  Future<void> _importCards() async {
    final result = _parsedResult;
    if (result == null || result.validCards.isEmpty || _isImporting) return;

    setState(() {
      _isImporting = true;
      _importProgress = 0;
    });

    var successCount = 0;
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    for (var i = 0; i < result.validCards.length; i++) {
      final card = result.validCards[i];
      final cardId = 'import_${nowMs}_$i';

      final params = AddCardToSrsParams(
        id: cardId,
        hebrewVocalized: card.hebrewVocalized,
        russianTranslation: card.russianTranslation,
        root: card.root,
        binyan: card.binyan,
        audioUrl: card.audioUrl,
        attribution: ContentAttribution(
          sourceName: 'Импорт (${result.formatDetected})',
          licenseName: 'User Deck',
        ),
      );

      final addRes = await widget.addCardToSrsUseCase(params);
      if (addRes is Success) {
        successCount++;
      }

      if (mounted) {
        setState(() {
          _importProgress = i + 1;
        });
      }
    }

    if (!mounted) return;

    setState(() {
      _isImporting = false;
    });

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Успешно импортировано $successCount карточек в колоду FSRS! 🎉',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );

    widget.onImportCompleted?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final result = _parsedResult;
    final totalValid = result?.totalValid ?? 0;

    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.file_download_rounded,
              color: theme.colorScheme.onSecondaryContainer,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Импорт колоды слов',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Anki TSV · CSV · JSON · Текстовые списки',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 580,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Быстрые примеры форматов:',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.table_chart_outlined, size: 16),
                    label: const Text('Anki TSV'),
                    onPressed: () => _loadTemplate(
                      'שָׁלוֹם\tПривет; Мир\tshalom\tש-ל-ם\tpaal\nסְלִיחָה\tИзвините\tslicha\tס-ל-ח\tpaal\nתּוֹדָה\tСпасибо\ttoda',
                    ),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.code_rounded, size: 16),
                    label: const Text('JSON'),
                    onPressed: () => _loadTemplate(
                      '[\n  {"hebrew": "בּוֹקֶר טוֹב", "russianTranslation": "Доброе утро"},\n  {"hebrew": "לַיְלָה טוֹב", "russianTranslation": "Спокойной ночи"}\n]',
                    ),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.format_list_bulleted_rounded, size: 16),
                    label: const Text('Список слов'),
                    onPressed: () => _loadTemplate(
                      'תּוֹדָה רַבָּה — Большое спасибо\nבְּבַקָּשָׁה — Пожалуйста\nלְהִתְרָאוֹת — До свидания',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _textController,
                maxLines: 6,
                minLines: 4,
                decoration: InputDecoration(
                  hintText:
                      'Вставьте строки колоды Anki (TSV), CSV, JSON или список вида "слово — перевод"...',
                  hintStyle: theme.textTheme.bodySmall,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                onChanged: _onTextChanged,
              ),
              if (result != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: totalValid > 0
                        ? theme.colorScheme.primaryContainer.withValues(alpha: 0.4)
                        : theme.colorScheme.errorContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: totalValid > 0
                          ? theme.colorScheme.primary.withValues(alpha: 0.3)
                          : theme.colorScheme.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        totalValid > 0
                            ? Icons.check_circle_outline_rounded
                            : Icons.info_outline_rounded,
                        size: 20,
                        color: totalValid > 0
                            ? theme.colorScheme.primary
                            : theme.colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Формат: ${result.formatDetected} · Распознано: $totalValid карточек'
                          '${result.totalSkipped > 0 ? " (пропущено: ${result.totalSkipped})" : ""}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (totalValid > 0) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Предпросмотр первых карточек:',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 180),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.colorScheme.outlineVariant),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: result.validCards.take(8).length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final card = result.validCards[index];
                        return ListTile(
                          dense: true,
                          title: Text(
                            card.hebrewVocalized,
                            textDirection: TextDirection.rtl,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.5,
                            ),
                          ),
                          subtitle: Text(
                            card.russianTranslation,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: card.root != null
                              ? Chip(
                                  label: Text(
                                    card.root!.hyphenated,
                                    textDirection: TextDirection.rtl,
                                  ),
                                  padding: EdgeInsets.zero,
                                  labelStyle: theme.textTheme.labelSmall,
                                )
                              : null,
                        );
                      },
                    ),
                  ),
                ],
              ],
              if (_isImporting) ...[
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: totalValid > 0 ? _importProgress / totalValid : null,
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Импортировано $_importProgress из $totalValid карточек...',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isImporting ? null : () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        FilledButton.icon(
          onPressed: (_isImporting || totalValid == 0) ? null : _importCards,
          icon: _isImporting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.add_task_rounded, size: 18),
          label: Text(
            _isImporting
                ? 'Импорт...'
                : (totalValid > 0
                    ? 'Импортировать $totalValid карточек'
                    : 'Вставьте текст выше'),
          ),
        ),
      ],
    );
  }
}
