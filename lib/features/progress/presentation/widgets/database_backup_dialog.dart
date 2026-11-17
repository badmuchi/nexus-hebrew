import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/backup/database_backup_service.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/settings/app_settings_storage.dart';

class DatabaseBackupDialog extends StatefulWidget {
  final AppDatabase database;
  final AppSettingsStorage? settingsStorage;
  final VoidCallback? onRestored;

  const DatabaseBackupDialog({
    super.key,
    required this.database,
    this.settingsStorage,
    this.onRestored,
  });

  static Future<void> show(
    BuildContext context, {
    required AppDatabase database,
    AppSettingsStorage? settingsStorage,
    VoidCallback? onRestored,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => DatabaseBackupDialog(
        database: database,
        settingsStorage: settingsStorage,
        onRestored: onRestored,
      ),
    );
  }

  @override
  State<DatabaseBackupDialog> createState() => _DatabaseBackupDialogState();
}

class _DatabaseBackupDialogState extends State<DatabaseBackupDialog> {
  static const _backupService = DatabaseBackupService();
  final TextEditingController _importController = TextEditingController();

  int _selectedTab = 0; // 0: Export, 1: Import
  String? _exportedJson;
  bool _isExporting = false;
  bool _isRestoring = false;
  bool _copied = false;
  String? _statusMessage;

  @override
  void dispose() {
    _importController.dispose();
    super.dispose();
  }

  Future<void> _handleExport() async {
    setState(() {
      _isExporting = true;
      _statusMessage = null;
    });

    try {
      final json = await _backupService.exportBackup(
        database: widget.database,
        settingsStorage: widget.settingsStorage,
      );
      if (mounted) {
        setState(() {
          _isExporting = false;
          _exportedJson = json;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isExporting = false;
          _statusMessage = 'Ошибка экспорта: $e';
        });
      }
    }
  }

  Future<void> _copyExportToClipboard() async {
    if (_exportedJson == null) return;
    await Clipboard.setData(ClipboardData(text: _exportedJson!));
    if (mounted) {
      setState(() {
        _copied = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('JSON бэкапа успешно скопирован в буфер обмена!'),
          duration: Duration(seconds: 3),
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

  Future<void> _handleRestore() async {
    final text = _importController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _statusMessage = 'Пожалуйста, вставьте JSON бэкапа в поле ниже';
      });
      return;
    }

    setState(() {
      _isRestoring = true;
      _statusMessage = null;
    });

    final res = await _backupService.restoreBackup(
      jsonString: text,
      database: widget.database,
      settingsStorage: widget.settingsStorage,
    );

    if (!mounted) return;

    setState(() {
      _isRestoring = false;
    });

    if (res.isSuccess) {
      final count = res.getOrNull() ?? 0;
      widget.onRestored?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Успешно восстановлено $count записей!'),
          backgroundColor: Colors.green.shade800,
        ),
      );
      Navigator.of(context).pop();
    } else {
      setState(() {
        _statusMessage = res.failureOrNull()?.message ?? 'Ошибка восстановления';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              Icons.backup_rounded,
              color: theme.colorScheme.onPrimaryContainer,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Резервная копия прогресса',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment<int>(
                    value: 0,
                    label: Text('Экспорт (Создать)'),
                    icon: Icon(Icons.file_upload_outlined),
                  ),
                  ButtonSegment<int>(
                    value: 1,
                    label: Text('Восстановление'),
                    icon: Icon(Icons.file_download_outlined),
                  ),
                ],
                selected: {_selectedTab},
                onSelectionChanged: (Set<int> newSelection) {
                  setState(() {
                    _selectedTab = newSelection.first;
                    _statusMessage = null;
                  });
                },
              ),
              const SizedBox(height: 16),
              if (_selectedTab == 0) ...[
                Text(
                  'Выгрузите все данные приложения (FSRS-карточки, историю повторений, логи грамматики и тренировки дня) в единый JSON файл.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                if (_exportedJson == null)
                  FilledButton.icon(
                    onPressed: _isExporting ? null : _handleExport,
                    icon: _isExporting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.data_object_rounded),
                    label: const Text('Сформировать JSON бэкапа'),
                  )
                else ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: theme.colorScheme.outlineVariant),
                    ),
                    child: Text(
                      _exportedJson!.split('\n').take(8).join('\n'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                      maxLines: 6,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _copyExportToClipboard,
                    icon: Icon(
                      _copied ? Icons.check_circle_rounded : Icons.copy_rounded,
                    ),
                    label: Text(
                      _copied ? 'Скопировано!' : 'Скопировать JSON в буфер',
                    ),
                  ),
                ],
              ] else ...[
                Text(
                  'Вставьте текст сохраненного ранее JSON бэкапа для восстановления прогресса:',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _importController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: '{\n  "version": 1,\n  "app": "NexusHebrew"...\n}',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: _isRestoring ? null : _handleRestore,
                  icon: _isRestoring
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.restore_rounded),
                  label: const Text('Восстановить прогресс'),
                ),
              ],
              if (_statusMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _statusMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w600,
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
      ],
    );
  }
}
