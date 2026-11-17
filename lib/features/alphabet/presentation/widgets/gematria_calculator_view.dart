import 'package:flutter/material.dart';

import '../../data/datasources/hebrew_alphabet_seed_data.dart';
import '../../domain/entities/hebrew_letter.dart';

/// Interactive Hebrew Gematria calculator and numerical symbolism explorer.
class GematriaCalculatorView extends StatefulWidget {
  const GematriaCalculatorView({super.key});

  @override
  State<GematriaCalculatorView> createState() => _GematriaCalculatorViewState();
}

class _GematriaCalculatorViewState extends State<GematriaCalculatorView> {
  final TextEditingController _textController =
      TextEditingController(text: 'שָׁלוֹם');

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _appendChar(String char) {
    final currentText = _textController.text;
    _textController.text = currentText + char;
    setState(() {});
  }

  void _backspace() {
    final text = _textController.text;
    if (text.isNotEmpty) {
      _textController.text = text.substring(0, text.length - 1);
      setState(() {});
    }
  }

  void _clear() {
    _textController.clear();
    setState(() {});
  }

  void _setPreset(String word) {
    _textController.text = word;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentText = _textController.text;
    final gematria = HebrewAlphabetSeedData.calculateGematria(currentText);
    final breakdown = HebrewAlphabetSeedData.getGematriaBreakdown(currentText);

    return ListView(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 32),
      children: [
        Card(
          elevation: 0,
          color: colorScheme.secondaryContainer.withValues(alpha: 0.45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.all(20),
            child: Column(
              children: [
                Text(
                  'Значение гематрии',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$gematria',
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _textController,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    height: 1.35,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Введите слово на иврите...',
                    hintTextDirection: TextDirection.rtl,
                    filled: true,
                    fillColor: colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: currentText.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.backspace_outlined),
                            tooltip: 'Стереть символ',
                            onPressed: _backspace,
                          )
                        : null,
                    prefixIcon: currentText.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_all_rounded),
                            tooltip: 'Очистить всё',
                            onPressed: _clear,
                          )
                        : null,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                if (breakdown.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: breakdown.map((entry) {
                      return Chip(
                        label: Text(
                          '${entry.key} = ${entry.value}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                            height: 1.3,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        backgroundColor: colorScheme.surface,
                        side: BorderSide(
                          color:
                              colorScheme.outlineVariant.withValues(alpha: 0.6),
                        ),
                      );
                    }).toList(growable: false),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Быстрый ввод букв',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: HebrewAlphabetSeedData.letters.map((HebrewLetter letter) {
            return ActionChip(
              label: Text(
                letter.printed,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
                textDirection: TextDirection.rtl,
              ),
              onPressed: () => _appendChar(letter.printed),
            );
          }).toList(growable: false),
        ),
        const SizedBox(height: 20),
        Text(
          'Известные слова и сакральные числа',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ActionChip(
              avatar: const Icon(Icons.favorite_rounded, size: 16),
              label: const Text('חַי = 18 (Жизнь)'),
              onPressed: () => _setPreset('חי'),
            ),
            ActionChip(
              avatar: const Icon(Icons.volunteer_activism_rounded, size: 16),
              label: const Text('אַהֲבָה = 13 (Любовь)'),
              onPressed: () => _setPreset('אהבה'),
            ),
            ActionChip(
              avatar: const Icon(Icons.star_rounded, size: 16),
              label: const Text('אֶחָד = 13 (Один)'),
              onPressed: () => _setPreset('אחד'),
            ),
            ActionChip(
              avatar: const Icon(Icons.handshake_rounded, size: 16),
              label: const Text('שָׁלוֹם = 376 (Мир)'),
              onPressed: () => _setPreset('שלום'),
            ),
            ActionChip(
              avatar: const Icon(Icons.diamond_rounded, size: 16),
              label: const Text('אֱמֶת = 441 (Истина)'),
              onPressed: () => _setPreset('אמת'),
            ),
            ActionChip(
              avatar: const Icon(Icons.wb_sunny_rounded, size: 16),
              label: const Text('אוֹר = 207 (Свет)'),
              onPressed: () => _setPreset('אור'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Card(
          elevation: 0,
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_rounded, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Знаете ли вы?',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Слово «Любовь» (אהבה) имеет гематрию 13, а слово «Один/Един» (אחד) — тоже 13. '
                  'В сумме 13 + 13 = 26 — это точное числовое значение Четырёхбуквенного имени Всевышнего (יהו״ה = 10 + 5 + 6 + 5 = 26). '
                  'Число 18 (חַי — «живой») символизирует жизнь и благополучие, поэтому традиционные пожертвования и подарки кратно кратны 18 шекелям.',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
