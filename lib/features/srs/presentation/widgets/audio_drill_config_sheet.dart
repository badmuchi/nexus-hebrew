import 'package:flutter/material.dart';

import '../../domain/entities/audio_drill_config.dart';

/// Modal bottom sheet allowing users to configure their hands-free audio drill session.
class AudioDrillConfigSheet extends StatefulWidget {
  final AudioDrillConfig initialConfig;
  final ValueChanged<AudioDrillConfig> onStart;

  const AudioDrillConfigSheet({
    super.key,
    required this.initialConfig,
    required this.onStart,
  });

  static Future<AudioDrillConfig?> show(
    BuildContext context, {
    AudioDrillConfig initialConfig = const AudioDrillConfig(),
  }) {
    return showModalBottomSheet<AudioDrillConfig>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) => AudioDrillConfigSheet(
        initialConfig: initialConfig,
        onStart: (cfg) => Navigator.of(sheetContext).pop(cfg),
      ),
    );
  }

  @override
  State<AudioDrillConfigSheet> createState() => _AudioDrillConfigSheetState();
}

class _AudioDrillConfigSheetState extends State<AudioDrillConfigSheet> {
  late AudioDrillFilter _filter;
  late AudioDrillDirection _direction;
  late double _pauseSeconds;
  late bool _includeExamples;
  late bool _isLooping;

  @override
  void initState() {
    super.initState();
    _filter = widget.initialConfig.filter;
    _direction = widget.initialConfig.direction;
    _pauseSeconds = widget.initialConfig.pauseSeconds;
    _includeExamples = widget.initialConfig.includeExamples;
    _isLooping = widget.initialConfig.isLooping;
  }

  AudioDrillConfig _buildConfig() {
    return AudioDrillConfig(
      filter: _filter,
      direction: _direction,
      pauseSeconds: _pauseSeconds,
      includeExamples: _includeExamples,
      isLooping: _isLooping,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('🎧', style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FSRS Аудиотренажер',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Hands-Free тренировка для наушников и авто',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ─── 1. Pool filter ─────────────────────────
          Text(
            'Какие слова тренировать:',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          for (final filterOption in AudioDrillFilter.values)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => setState(() => _filter = filterOption),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: _filter == filterOption
                        ? theme.colorScheme.primaryContainer.withValues(alpha: 0.4)
                        : theme.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _filter == filterOption
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(filterOption.icon, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              filterOption.labelRu,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              filterOption.description,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Radio<AudioDrillFilter>(
                        value: filterOption,
                        groupValue: _filter,
                        onChanged: (val) {
                          if (val != null) setState(() => _filter = val);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),

          // ─── 2. Direction ───────────────────────────
          Text(
            'Направление тренировки:',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final dir in AudioDrillDirection.values) ...[
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => setState(() => _direction = dir),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      decoration: BoxDecoration(
                        color: _direction == dir
                            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.4)
                            : theme.colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _direction == dir
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(dir.icon, style: const TextStyle(fontSize: 22)),
                          const SizedBox(height: 4),
                          Text(
                            dir.labelRu,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            dir.description,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (dir != AudioDrillDirection.values.last) const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // ─── 3. Pause duration ──────────────────────
          Text(
            'Время на ответ вслух:',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          SegmentedButton<double>(
            segments: const [
              ButtonSegment<double>(
                value: 2.0,
                label: Text('2 сек · Быстро'),
              ),
              ButtonSegment<double>(
                value: 3.0,
                label: Text('3 сек · Оптимально'),
              ),
              ButtonSegment<double>(
                value: 5.0,
                label: Text('5 сек · Спокойно'),
              ),
            ],
            selected: {_pauseSeconds},
            onSelectionChanged: (val) {
              if (val.isNotEmpty) {
                setState(() => _pauseSeconds = val.first);
              }
            },
          ),
          const SizedBox(height: 16),

          // ─── 4. Toggles ─────────────────────────────
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Озвучивать пример предложения'),
            subtitle: const Text('Если к слову есть контекстная фраза'),
            value: _includeExamples,
            onChanged: (val) => setState(() => _includeExamples = val),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Зациклить воспроизведение'),
            subtitle: const Text('Повторять список по кругу без остановки'),
            value: _isLooping,
            onChanged: (val) => setState(() => _isLooping = val),
          ),
          const SizedBox(height: 20),

          // ─── 5. Start button ────────────────────────
          FilledButton.icon(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text(
              'Начать тренировку',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onPressed: () => widget.onStart(_buildConfig()),
          ),
        ],
      ),
    );
  }
}
