import 'package:flutter/material.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../srs/domain/entities/srs_card.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../data/datasources/hebrew_numbers_seed_data.dart';
import '../../domain/entities/hebrew_number.dart';

/// Interactive workspace for Hebrew Numbers, gender agreement paradox,
/// natural time telling (?מַה הַשָּׁעָה), and interactive drills.
class NumbersAndTimeView extends StatefulWidget {
  final AudioPlaybackService? audioService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;
  final bool showNikkud;

  const NumbersAndTimeView({
    super.key,
    this.audioService,
    this.addCardToSrsUseCase,
    this.showNikkud = true,
  });

  @override
  State<NumbersAndTimeView> createState() => _NumbersAndTimeViewState();
}

class _NumbersAndTimeViewState extends State<NumbersAndTimeView> {
  int _activeTab = 0; // 0: Счёт и род, 1: Время, 2: Тренажёр

  // Simulator state
  int _simSelectedNumber = 3;
  CountableNoun _simSelectedNoun = HebrewNumbersSeedData.sampleNouns[0];

  // Time state
  int _timeSelectedHour = 3;
  int _timeSelectedMinute = 15;

  // Quiz state
  int _quizIndex = 0;
  String? _selectedQuizOption;
  bool _isQuizAnswered = false;
  int _quizScore = 0;
  int _quizStreak = 0;

  void _speakText(String hebrewText) {
    widget.audioService?.playWithTtsFallback(
      sourcePath: null,
      fallbackHebrewText: hebrewText,
    );
  }

  Future<void> _saveToSrs({
    required BuildContext context,
    required String id,
    required String frontRussian,
    required String backHebrew,
    String? exampleHebrew,
    String? exampleRussian,
  }) async {
    final useCase = widget.addCardToSrsUseCase;
    if (useCase == null) return;

    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    try {
      final result = await useCase.call(
        AddCardToSrsParams(
          id: id,
          hebrewVocalized: backHebrew,
          russianTranslation: frontRussian,
          exampleHebrewVocalized: exampleHebrew,
          exampleRussian: exampleRussian,
          attribution: const ContentAttribution(
            sourceName: 'Nexus Hebrew Numbers & Time',
            licenseName: 'CC0 1.0',
          ),
        ),
      );

      result.fold(
        (failure) => messenger.showSnackBar(
          SnackBar(content: Text('Ошибка: ${failure.message}')),
        ),
        (_) => messenger.showSnackBar(
          SnackBar(
            content: Text(
              '«$backHebrew» ($frontRussian) сохранено в FSRS!',
              style: TextStyle(color: theme.colorScheme.onSecondary),
            ),
            backgroundColor: theme.colorScheme.secondary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        ),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Не удалось сохранить карточку'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 8),
          child: SegmentedButton<int>(
            segments: const [
              ButtonSegment<int>(
                value: 0,
                icon: Icon(Icons.pin_outlined),
                label: Text('Счёт и род'),
              ),
              ButtonSegment<int>(
                value: 1,
                icon: Icon(Icons.access_time_rounded),
                label: Text('Время'),
              ),
              ButtonSegment<int>(
                value: 2,
                icon: Icon(Icons.fitness_center_rounded),
                label: Text('Тренажер'),
              ),
            ],
            selected: {_activeTab},
            onSelectionChanged: (newSelection) {
              setState(() {
                _activeTab = newSelection.first;
              });
            },
          ),
        ),
        Expanded(
          child: switch (_activeTab) {
            0 => _buildCountingTab(theme),
            1 => _buildTimeTab(theme),
            2 => _buildQuizTab(theme),
            _ => const SizedBox.shrink(),
          },
        ),
      ],
    );
  }

  // ===========================================================================
  // TAB 0: COUNTING & GENDER PARADOX
  // ===========================================================================
  Widget _buildCountingTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 32),
      children: [
        _buildGenderParadoxBanner(theme),
        const SizedBox(height: 16),
        _buildSimulatorCard(theme),
        const SizedBox(height: 20),
        Text(
          'Справочник числительных 1–10:',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ...HebrewNumbersSeedData.cardinalNumbers.map((numberItem) {
          return _buildNumberRowCard(theme, numberItem);
        }),
      ],
    );
  }

  Widget _buildGenderParadoxBanner(ThemeData theme) {
    return Container(
      padding: const EdgeInsetsDirectional.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.amber.shade900),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Парадокс рода в иврите (1–10)',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Род числительных обратен роду существительных! С мужским родом числительные имеют окончание ה- (-а): שְׁלוֹשָׁה שְׁקָלִים. С женским родом — БЕЗ окончания: שָׁלוֹשׁ עוּגוֹת.',
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulatorCard(ThemeData theme) {
    final numData = HebrewNumbersSeedData.cardinalNumbers.firstWhere(
      (n) => n.value == _simSelectedNumber,
      orElse: () => HebrewNumbersSeedData.cardinalNumbers[2],
    );

    // Calculate assembled phrase
    String hebrewPhrase;
    String transliteration;
    String translation;

    if (_simSelectedNoun.isMasculine) {
      if (_simSelectedNumber == 1) {
        hebrewPhrase = '${_simSelectedNoun.singularHebrew} ${numData.masculine}';
        transliteration = '${_simSelectedNoun.singularTranslation} echad';
        translation = '1 ${_simSelectedNoun.singularTranslation}';
      } else if (_simSelectedNumber == 2) {
        hebrewPhrase = '${numData.masculineConstruct ?? numData.masculine} ${_simSelectedNoun.pluralHebrew}';
        transliteration = 'shnei ${_simSelectedNoun.pluralTranslation}';
        translation = '2 ${_simSelectedNoun.pluralTranslation}';
      } else {
        hebrewPhrase = '${numData.masculine} ${_simSelectedNoun.pluralHebrew}';
        transliteration = '${numData.masculineTranslit.toLowerCase()} ${_simSelectedNoun.pluralTranslation}';
        translation = '$_simSelectedNumber ${_simSelectedNoun.pluralTranslation}';
      }
    } else {
      if (_simSelectedNumber == 1) {
        hebrewPhrase = '${_simSelectedNoun.singularHebrew} ${numData.feminine}';
        transliteration = '${_simSelectedNoun.singularTranslation} achat';
        translation = '1 ${_simSelectedNoun.singularTranslation}';
      } else if (_simSelectedNumber == 2) {
        hebrewPhrase = '${numData.feminineConstruct ?? numData.feminine} ${_simSelectedNoun.pluralHebrew}';
        transliteration = 'shtei ${_simSelectedNoun.pluralTranslation}';
        translation = '2 ${_simSelectedNoun.pluralTranslation}';
      } else {
        hebrewPhrase = '${numData.feminine} ${_simSelectedNoun.pluralHebrew}';
        transliteration = '${numData.feminineTranslit.toLowerCase()} ${_simSelectedNoun.pluralTranslation}';
        translation = '$_simSelectedNumber ${_simSelectedNoun.pluralTranslation}';
      }
    }

    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Интерактивный симулятор счёта:',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '1. Выберите число:',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(10, (idx) {
                  final val = idx + 1;
                  final isSelected = val == _simSelectedNumber;
                  return Padding(
                    padding: const EdgeInsetsDirectional.only(end: 6),
                    child: ChoiceChip(
                      label: Text('$val'),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          _simSelectedNumber = val;
                        });
                      },
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '2. Выберите предмет:',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: HebrewNumbersSeedData.sampleNouns.map((noun) {
                final isSelected = noun.id == _simSelectedNoun.id;
                final genderLabel = noun.isMasculine ? 'м.р.' : 'ж.р.';
                return ChoiceChip(
                  label: Text('${noun.singularHebrew} ($genderLabel)'),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      _simSelectedNoun = noun;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Result Box
            Container(
              padding: const EdgeInsetsDirectional.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.volume_up_rounded),
                        tooltip: 'Слушать фразу',
                        onPressed: () => _speakText(hebrewPhrase),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        hebrewPhrase,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          fontFamily: 'Noto Sans Hebrew',
                          fontSize: 24,
                          height: 1.35,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.bookmark_add_outlined),
                        tooltip: 'В FSRS',
                        onPressed: () => _saveToSrs(
                          context: context,
                          id: 'num_${_simSelectedNumber}_${_simSelectedNoun.id}',
                          frontRussian: translation,
                          backHebrew: hebrewPhrase,
                          exampleRussian:
                              'Род: ${_simSelectedNoun.isMasculine ? "мужской" : "женский"}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '[$transliteration] — $translation',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _simSelectedNoun.isMasculine
                        ? '💡 Мужской род: числительное оканчивается на ה- (парадокс).'
                        : '💡 Женский род: числительное употребляется в краткой форме без ה-.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberRowCard(ThemeData theme, HebrewNumber numberItem) {
    return Card(
      margin: const EdgeInsetsDirectional.only(bottom: 8),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(12),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    '${numberItem.value}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('М.р.: ', style: theme.textTheme.labelSmall),
                          Text(
                            numberItem.masculine,
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              fontFamily: 'Noto Sans Hebrew',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(' [${numberItem.masculineTranslit}]',
                              style: theme.textTheme.bodySmall),
                          IconButton(
                            icon: const Icon(Icons.volume_up_rounded, size: 16),
                            onPressed: () => _speakText(numberItem.masculine),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text('Ж.р.: ', style: theme.textTheme.labelSmall),
                          Text(
                            numberItem.feminine,
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              fontFamily: 'Noto Sans Hebrew',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(' [${numberItem.feminineTranslit}]',
                              style: theme.textTheme.bodySmall),
                          IconButton(
                            icon: const Icon(Icons.volume_up_rounded, size: 16),
                            onPressed: () => _speakText(numberItem.feminine),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (numberItem.note != null) ...[
              const Divider(height: 12),
              Text(
                numberItem.note!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // TAB 1: TELLING TIME (?מַה הַשָּׁעָה)
  // ===========================================================================
  Widget _buildTimeTab(ThemeData theme) {
    final phrase = HebrewNumbersSeedData.calculateTimePhrase(
      _timeSelectedHour,
      _timeSelectedMinute,
    );

    return ListView(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 32),
      children: [
        // Hero Clock Card
        Container(
          padding: const EdgeInsetsDirectional.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.schedule_rounded, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    '${_timeSelectedHour.toString().padLeft(2, '0')}:${_timeSelectedMinute.toString().padLeft(2, '0')}',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.volume_up_rounded, size: 28),
                    tooltip: 'Озвучить время',
                    onPressed: () => _speakText(phrase.hebrewPhrase),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      phrase.hebrewPhrase,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Noto Sans Hebrew',
                        fontSize: 26,
                        height: 1.35,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.bookmark_add_outlined),
                    tooltip: 'В FSRS',
                    onPressed: () => _saveToSrs(
                      context: context,
                      id: 'time_${_timeSelectedHour}_$_timeSelectedMinute',
                      frontRussian: phrase.russianTranslation,
                      backHebrew: phrase.hebrewPhrase,
                      exampleRussian: phrase.transliteration,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '[${phrase.transliteration}]',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                phrase.russianTranslation,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsetsDirectional.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.tips_and_updates_outlined, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        phrase.explanation,
                        style: theme.textTheme.bodySmall?.copyWith(height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Часы:',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(12, (index) {
              final h = index + 1;
              final isSelected = h == _timeSelectedHour;
              return Padding(
                padding: const EdgeInsetsDirectional.only(end: 6),
                child: ChoiceChip(
                  label: Text('$h:00'),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      _timeSelectedHour = h;
                    });
                  },
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Минуты и интервалы:',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            (0, ':00 Ровно (בְּדִיּוּק)'),
            (10, ':10 Десять минут'),
            (15, ':15 С четвертью (וָרֶבַע)'),
            (20, ':20 Двадцать минут'),
            (30, ':30 Половина (וָחֵצִי)'),
            (40, ':40 Без двадцати'),
            (45, ':45 Без четверти (רֶבַע לְ...)'),
            (50, ':50 Без десяти'),
          ].map((pair) {
            final m = pair.$1;
            final label = pair.$2;
            final isSelected = m == _timeSelectedMinute;
            return ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  _timeSelectedMinute = m;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // ===========================================================================
  // TAB 2: DRILL QUIZ
  // ===========================================================================
  Widget _buildQuizTab(ThemeData theme) {
    final questions = HebrewNumbersSeedData.quizQuestions;
    final currentQ = questions[_quizIndex];

    return ListView(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 32),
      children: [
        // Score Header
        Container(
          padding: const EdgeInsetsDirectional.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Вопрос ${_quizIndex + 1} из ${questions.length}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_quizStreak > 1)
                Text(
                  '🔥 Серия: $_quizStreak',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              Text(
                'Счёт: $_quizScore',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Question Card
        Card(
          elevation: 0,
          color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  currentQ.questionPrompt,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Options
        ...currentQ.options.map((opt) {
          final isSelected = opt == _selectedQuizOption;
          final isCorrect = opt == currentQ.correctAnswer;

          Color btnColor = theme.colorScheme.surface;
          Color borderColor = theme.colorScheme.outlineVariant;

          if (_isQuizAnswered) {
            if (isCorrect) {
              btnColor = Colors.green.withValues(alpha: 0.15);
              borderColor = Colors.green;
            } else if (isSelected) {
              btnColor = Colors.red.withValues(alpha: 0.15);
              borderColor = Colors.red;
            }
          }

          return Padding(
            padding: const EdgeInsetsDirectional.only(bottom: 10),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: btnColor,
                side: BorderSide(color: borderColor, width: 1.5),
                padding: const EdgeInsetsDirectional.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _isQuizAnswered
                  ? null
                  : () {
                      final isAnswerCorrect = currentQ.isCorrect(opt);
                      setState(() {
                        _selectedQuizOption = opt;
                        _isQuizAnswered = true;
                        if (isAnswerCorrect) {
                          _quizScore += 20;
                          _quizStreak += 1;
                          _speakText(currentQ.audioPrompt);
                        } else {
                          _quizStreak = 0;
                        }
                      });
                    },
              child: Text(
                opt,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontFamily: 'Noto Sans Hebrew',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }),
        if (_isQuizAnswered) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsetsDirectional.all(14),
            decoration: BoxDecoration(
              color: currentQ.isCorrect(_selectedQuizOption!)
                  ? Colors.green.withValues(alpha: 0.12)
                  : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      currentQ.isCorrect(_selectedQuizOption!)
                          ? Icons.check_circle
                          : Icons.info,
                      color: currentQ.isCorrect(_selectedQuizOption!)
                          ? Colors.green
                          : Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      currentQ.isCorrect(_selectedQuizOption!)
                          ? 'Правильно!'
                          : 'Внимание к правилу:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: currentQ.isCorrect(_selectedQuizOption!)
                            ? Colors.green.shade900
                            : Colors.red.shade900,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.volume_up_rounded),
                      onPressed: () => _speakText(currentQ.audioPrompt),
                    ),
                    IconButton(
                      icon: const Icon(Icons.bookmark_add_outlined),
                      onPressed: () => _saveToSrs(
                        context: context,
                        id: 'quiz_${currentQ.id}',
                        frontRussian: currentQ.questionPrompt,
                        backHebrew: currentQ.correctAnswer,
                        exampleRussian: currentQ.explanation,
                      ),
                    ),
                  ],
                ),
                Text(
                  currentQ.explanation,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            key: const Key('next_number_quiz_button'),
            onPressed: () {
              setState(() {
                _quizIndex = (_quizIndex + 1) % questions.length;
                _selectedQuizOption = null;
                _isQuizAnswered = false;
              });
            },
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text('Следующий вопрос'),
          ),
        ],
      ],
    );
  }
}
