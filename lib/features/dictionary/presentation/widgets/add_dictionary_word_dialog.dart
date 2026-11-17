import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/hebrew_niqqud_keyboard.dart';
import '../../../conversation/domain/entities/binyan.dart';
import '../../../srs/domain/entities/srs_card.dart';
import '../cubit/dictionary_cubit.dart';

/// Opens a modal dialog to add a custom word/phrase into the local dictionary.
Future<void> showAddDictionaryWordDialog(BuildContext context) {
  final cubit = context.read<DictionaryCubit>();
  return showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return _AddDictionaryWordDialog(cubit: cubit);
    },
  );
}

class _AddDictionaryWordDialog extends StatefulWidget {
  const _AddDictionaryWordDialog({required this.cubit});

  final DictionaryCubit cubit;

  @override
  State<_AddDictionaryWordDialog> createState() =>
      _AddDictionaryWordDialogState();
}

class _AddDictionaryWordDialogState extends State<_AddDictionaryWordDialog> {
  final _hebrewController = TextEditingController();
  final _russianController = TextEditingController();
  final _translitController = TextEditingController();
  final _rootController = TextEditingController();
  final _exampleHebController = TextEditingController();
  final _exampleRuController = TextEditingController();

  LexicalCategory _category = LexicalCategory.noun;
  Binyan _binyan = Binyan.none;
  bool _alsoAddToSrs = true;
  bool _isSaving = false;
  bool _showKeyboard = false;

  @override
  void dispose() {
    _hebrewController.dispose();
    _russianController.dispose();
    _translitController.dispose();
    _rootController.dispose();
    _exampleHebController.dispose();
    _exampleRuController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    final ok = await widget.cubit.addCustomWord(
      hebrewVocalized: _hebrewController.text,
      russianTranslation: _russianController.text,
      transliteration: _translitController.text,
      category: _category,
      rawRoot: _rootController.text,
      binyan: _category == LexicalCategory.verb ? _binyan : Binyan.none,
      exampleHebrewVocalized: _exampleHebController.text,
      exampleRussian: _exampleRuController.text,
      alsoAddToSrs: _alsoAddToSrs,
    );
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (ok) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Добавить слово в словарь'),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Directionality(
                textDirection: TextDirection.rtl,
                child: TextField(
                  controller: _hebrewController,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    labelText: 'Слово или фраза на иврите *',
                    hintText: 'מַחְשֵׁב / מחשב',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showKeyboard
                            ? Icons.keyboard_hide_rounded
                            : Icons.keyboard_rounded,
                      ),
                      tooltip: 'Клавиатура иврита с огласовками',
                      onPressed: () =>
                          setState(() => _showKeyboard = !_showKeyboard),
                    ),
                  ),
                ),
              ),
              if (_showKeyboard) ...[
                const SizedBox(height: 8),
                HebrewNiqqudKeyboard(
                  controller: _hebrewController,
                  onClose: () => setState(() => _showKeyboard = false),
                ),
              ],
              const SizedBox(height: 10),
              TextField(
                controller: _russianController,
                decoration: const InputDecoration(
                  labelText: 'Перевод на русский *',
                  hintText: 'компьютер',
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<LexicalCategory>(
                      initialValue: _category,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Часть речи'),
                      items: LexicalCategory.values
                          .map(
                            (LexicalCategory cat) =>
                                DropdownMenuItem<LexicalCategory>(
                              value: cat,
                              child: Text(
                                cat.labelRu,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (LexicalCategory? next) {
                        if (next == null) return;
                        setState(() => _category = next);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: TextField(
                        controller: _rootController,
                        textDirection: TextDirection.rtl,
                        decoration: const InputDecoration(
                          labelText: 'Корень (опц.)',
                          hintText: 'ח-ש-ב',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_category == LexicalCategory.verb) ...[
                const SizedBox(height: 10),
                DropdownButtonFormField<Binyan>(
                  initialValue: _binyan,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Биньян'),
                  items: Binyan.values
                      .map(
                        (Binyan b) => DropdownMenuItem<Binyan>(
                          value: b,
                          child: Text(
                            b == Binyan.none
                                ? 'Не указан'
                                : '${b.hebrewLabel} · ${b.transliteration}',
                          ),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (Binyan? next) {
                    if (next == null) return;
                    setState(() => _binyan = next);
                  },
                ),
              ],
              const SizedBox(height: 10),
              TextField(
                controller: _translitController,
                decoration: const InputDecoration(
                  labelText: 'Транскрипция (опц.)',
                  hintText: 'makhshev',
                ),
              ),
              const SizedBox(height: 10),
              Directionality(
                textDirection: TextDirection.rtl,
                child: TextField(
                  controller: _exampleHebController,
                  textDirection: TextDirection.rtl,
                  decoration: const InputDecoration(
                    labelText: 'Пример на иврите (опц.)',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _exampleRuController,
                decoration: const InputDecoration(
                  labelText: 'Перевод примера (опц.)',
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _alsoAddToSrs,
                onChanged: (bool value) => setState(() => _alsoAddToSrs = value),
                title: const Text('Сразу добавить в FSRS'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : () => unawaited(_submit()),
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Сохранить'),
        ),
      ],
    );
  }
}
