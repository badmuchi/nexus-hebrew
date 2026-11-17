import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../dictionary/domain/entities/dictionary_entry.dart';
import '../../domain/entities/srs_card.dart';
import '../../domain/services/anki_deck_export_service.dart';

/// Modal dialog for exporting SRS cards or Dictionary entries directly into Anki format.
class AnkiExportDialog extends StatefulWidget {
  final List<SrsCard>? srsCards;
  final List<DictionaryEntry>? dictionaryEntries;
  final String title;

  const AnkiExportDialog({
    super.key,
    this.srsCards,
    this.dictionaryEntries,
    this.title = 'Экспорт в Anki',
  });

  static Future<void> showSrsExport(
    BuildContext context, {
    required List<SrsCard> cards,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => AnkiExportDialog(
        srsCards: cards,
        title: 'Экспорт FSRS колоды в Anki',
      ),
    );
  }

  static Future<void> showDictionaryExport(
    BuildContext context, {
    required List<DictionaryEntry> entries,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => AnkiExportDialog(
        dictionaryEntries: entries,
        title: 'Экспорт словаря в Anki',
      ),
    );
  }

  @override
  State<AnkiExportDialog> createState() => _AnkiExportDialogState();
}

class _AnkiExportDialogState extends State<AnkiExportDialog> {
  static const _exportService = AnkiDeckExportService();

  AnkiExportFormat _format = AnkiExportFormat.tsv;
  bool _includeNikkud = true;
  bool _showInstructions = false;
  bool _copied = false;

  int get _itemCount =>
      widget.srsCards?.length ?? widget.dictionaryEntries?.length ?? 0;

  String _generateExportText() {
    if (widget.srsCards != null) {
      return _exportService.exportSrsCards(
        widget.srsCards!,
        format: _format,
        includeNikkud: _includeNikkud,
      );
    } else if (widget.dictionaryEntries != null) {
      return _exportService.exportDictionaryEntries(
        widget.dictionaryEntries!,
        format: _format,
        includeNikkud: _includeNikkud,
      );
    }
    return '';
  }

  Future<void> _copyToClipboard() async {
    final text = _generateExportText();
    setState(() {
      _copied = true;
    });
    try {
      await Clipboard.setData(ClipboardData(text: text));
    } catch (_) {
      // Ignored for platform-specific mock channels in tests
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$_itemCount карточек скопировано в буфер обмена в формате ${_format.fileExtension.toUpperCase()}!',
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      Future<void>.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _copied = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final previewText = _generateExportText();
    final previewLines = previewText.split('\n').take(6).join('\n');

    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.download_for_offline_rounded,
              color: theme.colorScheme.onPrimaryContainer,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.format_list_bulleted_rounded,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Всего карточек к экспорту: $_itemCount',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Формат выгрузки:',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<AnkiExportFormat>(
                segments: const [
                  ButtonSegment<AnkiExportFormat>(
                    value: AnkiExportFormat.tsv,
                    label: Text('Anki TSV (реком.)'),
                    tooltip: 'Табуляция — стандарт для Anki Desktop и AnkiDroid',
                  ),
                  ButtonSegment<AnkiExportFormat>(
                    value: AnkiExportFormat.csv,
                    label: Text('CSV'),
                    tooltip: 'Стандартный текстовый файл через запятую',
                  ),
                ],
                selected: {_format},
                onSelectionChanged: (Set<AnkiExportFormat> newSelection) {
                  setState(() {
                    _format = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _includeNikkud,
                onChanged: (bool value) {
                  setState(() {
                    _includeNikkud = value;
                  });
                },
                title: const Text('Включать огласовки (никуд)'),
                subtitle: Text(
                  _includeNikkud
                      ? 'Слова выгружаются с полной диакритикой'
                      : 'Только буквы без огласовок (ktiv male)',
                  style: theme.textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Предпросмотр данных:',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Text(
                  previewLines,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    fontSize: 11,
                  ),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 14),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  setState(() {
                    _showInstructions = !_showInstructions;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        _showInstructions
                            ? Icons.expand_less_rounded
                            : Icons.help_outline_rounded,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Как импортировать в Anki?',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_showInstructions) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '1. Нажми «Скопировать для Anki» ниже.\n'
                        '2. В приложении Anki (ПК или мобильном) открой «Файл» ➔ «Импорт» (или вставь текст в заметку).\n'
                        '3. Выбери разделитель: Tab (для TSV) или Запятая (для CSV).\n'
                        '4. Первое поле будет словом на иврите (Front), второе — переводом (Back), а корень и биньян сохранятся в метаданных.',
                        style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Закрыть'),
        ),
        FilledButton.icon(
          onPressed: _itemCount == 0 ? null : _copyToClipboard,
          icon: Icon(
            _copied ? Icons.check_circle_rounded : Icons.copy_rounded,
          ),
          label: Text(
            _copied ? 'Скопировано!' : 'Скопировать для Anki',
          ),
        ),
      ],
    );
  }
}
