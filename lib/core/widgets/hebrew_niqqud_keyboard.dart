import 'package:flutter/material.dart';

/// Interactive on-screen Hebrew keyboard supporting all 22 letters, 5 final
/// forms (sofit), and standard Hebrew vowel points (niqqud diacritics).
class HebrewNiqqudKeyboard extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback? onSubmitted;
  final VoidCallback? onClose;
  final bool showHeader;

  const HebrewNiqqudKeyboard({
    super.key,
    required this.controller,
    this.onSubmitted,
    this.onClose,
    this.showHeader = true,
  });

  @override
  State<HebrewNiqqudKeyboard> createState() => _HebrewNiqqudKeyboardState();
}

class _HebrewNiqqudKeyboardState extends State<HebrewNiqqudKeyboard> {
  bool _showAllNiqqud = false;

  // Standard Israeli layout rows (RTL natural order)
  static const List<String> _row1 = ['ק', 'ר', 'א', 'ט', 'ו', 'ן', 'ם', 'פ'];
  static const List<String> _row2 = ['ש', 'ד', 'ג', 'כ', 'ע', 'י', 'ח', 'ל', 'ך', 'ף'];
  static const List<String> _row3 = ['ז', 'ס', 'ב', 'ה', 'נ', 'מ', 'צ', 'ת', 'ץ'];

  // Quick primary niqqud bar
  static const List<_NiqqudItem> _primaryNiqqud = [
    _NiqqudItem(char: '\u05B8', label: 'ָ', name: 'Камац (а)'),
    _NiqqudItem(char: '\u05B7', label: 'ַ', name: 'Патах (а)'),
    _NiqqudItem(char: '\u05B4', label: 'ִ', name: 'Хирик (и)'),
    _NiqqudItem(char: '\u05B5', label: 'ֵ', name: 'Цере (э)'),
    _NiqqudItem(char: '\u05B6', label: 'ֶ', name: 'Сэголь (э)'),
    _NiqqudItem(char: '\u05B9', label: 'ֹ', name: 'Холам (о)'),
    _NiqqudItem(char: '\u05BB', label: 'ֻ', name: 'Кубуц (у)'),
    _NiqqudItem(char: '\u05B0', label: 'ְ', name: 'Шва (немой/э)'),
    _NiqqudItem(char: '\u05BC', label: 'ּ', name: 'Дагеш (точка)'),
  ];

  // Extended niqqud (Hatafim, Shin/Sin dots, Maqaf)
  static const List<_NiqqudItem> _extendedNiqqud = [
    _NiqqudItem(char: '\u05B1', label: 'ֱ', name: 'Хатаф Сэголь'),
    _NiqqudItem(char: '\u05B2', label: 'ֲ', name: 'Хатаф Патах'),
    _NiqqudItem(char: '\u05B3', label: 'ֳ', name: 'Хатаф Камац'),
    _NiqqudItem(char: '\u05C1', label: 'ׁ', name: 'Шин точка (ш)'),
    _NiqqudItem(char: '\u05C2', label: 'ׂ', name: 'Син точка (с)'),
    _NiqqudItem(char: '\u05BE', label: '־', name: 'Макаф (дефис)'),
  ];

  void _insert(String textToInsert) {
    final text = widget.controller.text;
    final selection = widget.controller.selection;
    final start = selection.start >= 0 ? selection.start : text.length;
    final end = selection.end >= 0 ? selection.end : text.length;

    final newText = text.replaceRange(start, end, textToInsert);
    final newPosition = start + textToInsert.length;

    widget.controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newPosition),
    );
  }

  void _deleteBackward() {
    final text = widget.controller.text;
    final selection = widget.controller.selection;
    final start = selection.start >= 0 ? selection.start : text.length;
    final end = selection.end >= 0 ? selection.end : text.length;

    if (start != end) {
      widget.controller.value = TextEditingValue(
        text: text.replaceRange(start, end, ''),
        selection: TextSelection.collapsed(offset: start),
      );
    } else if (start > 0) {
      final newText = text.substring(0, start - 1) + text.substring(start);
      widget.controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: start - 1),
      );
    }
  }

  void _clear() {
    widget.controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.showHeader) ...[
            Row(
              children: [
                Icon(
                  Icons.keyboard_rounded,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Клавиатура иврита с огласовками',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showAllNiqqud = !_showAllNiqqud;
                    });
                  },
                  icon: Icon(
                    _showAllNiqqud
                        ? Icons.expand_less_rounded
                        : Icons.tune_rounded,
                    size: 16,
                  ),
                  label: Text(
                    _showAllNiqqud ? 'Меньше огласовок' : 'Все огласовки',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (widget.onClose != null)
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    tooltip: 'Скрыть клавиатуру',
                    onPressed: widget.onClose,
                  ),
              ],
            ),
            const SizedBox(height: 6),
          ],

          // Niqqud diacritics bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final item in _primaryNiqqud) ...[
                  _buildNiqqudKey(theme, item),
                  const SizedBox(width: 4),
                ],
                if (_showAllNiqqud)
                  for (final item in _extendedNiqqud) ...[
                    _buildNiqqudKey(theme, item, isExtended: true),
                    const SizedBox(width: 4),
                  ],
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Letter rows (RTL)
          Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              children: [
                _buildRow(theme, _row1),
                const SizedBox(height: 6),
                _buildRow(theme, _row2),
                const SizedBox(height: 6),
                _buildRow(theme, _row3),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Bottom control row
          Row(
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
                onPressed: _clear,
                icon: const Icon(Icons.delete_sweep_outlined, size: 18),
                label: const Text('Очистить'),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: FilledButton.tonal(
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => _insert(' '),
                  child: const Text('Пробел (רווח)'),
                ),
              ),
              const SizedBox(width: 6),
              FilledButton.tonal(
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                onPressed: _deleteBackward,
                child: const Icon(Icons.backspace_outlined, size: 18),
              ),
              if (widget.onSubmitted != null) ...[
                const SizedBox(width: 6),
                FilledButton(
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  onPressed: widget.onSubmitted,
                  child: const Icon(Icons.check_rounded, size: 20),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(ThemeData theme, List<String> letters) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final letter in letters) ...[
          Expanded(child: _buildLetterKey(theme, letter)),
          const SizedBox(width: 4),
        ],
      ],
    );
  }

  Widget _buildLetterKey(ThemeData theme, String letter) {
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      elevation: 0.5,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _insert(letter),
        child: Container(
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Text(
            letter,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 19,
              height: 1.35,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNiqqudKey(
    ThemeData theme,
    _NiqqudItem item, {
    bool isExtended = false,
  }) {
    return Tooltip(
      message: item.name,
      child: Material(
        color: isExtended
            ? theme.colorScheme.secondaryContainer.withValues(alpha: 0.7)
            : theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _insert(item.char),
          child: Container(
            constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: (isExtended
                        ? theme.colorScheme.secondary
                        : theme.colorScheme.primary)
                    .withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              '◌${item.label}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                height: 1.35,
                color: isExtended
                    ? theme.colorScheme.onSecondaryContainer
                    : theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NiqqudItem {
  final String char;
  final String label;
  final String name;

  const _NiqqudItem({
    required this.char,
    required this.label,
    required this.name,
  });
}
