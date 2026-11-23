import 'package:flutter/material.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../srs/domain/entities/srs_card.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../data/datasources/driving_seed_data.dart';
import '../widgets/parking_curb_simulator_card.dart';

/// Screen for Israeli Driving Rules, Parking Curb color simulator, Waze prompts, and Road glossary.
class DrivingRoadsScreen extends StatefulWidget {
  final AudioPlaybackService? audioService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;

  const DrivingRoadsScreen({
    super.key,
    this.audioService,
    this.addCardToSrsUseCase,
  });

  @override
  State<DrivingRoadsScreen> createState() => _DrivingRoadsScreenState();
}

class _DrivingRoadsScreenState extends State<DrivingRoadsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Waze prompt challenge state
  int _currentWazeIndex = 0;
  int? _selectedWazeOption;
  bool _hasAnsweredWaze = false;

  // Dialogue scenario state
  int _currentScenarioIndex = 0;
  int? _selectedScenarioOption;
  bool _hasAnsweredScenario = false;

  // Glossary search
  String _glossarySearchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onAnswerWaze(int index) {
    if (_hasAnsweredWaze) return;
    setState(() {
      _selectedWazeOption = index;
      _hasAnsweredWaze = true;
    });
  }

  void _nextWazePrompt() {
    if (_currentWazeIndex < DrivingSeedData.wazePrompts.length - 1) {
      setState(() {
        _currentWazeIndex++;
        _selectedWazeOption = null;
        _hasAnsweredWaze = false;
      });
    }
  }

  void _prevWazePrompt() {
    if (_currentWazeIndex > 0) {
      setState(() {
        _currentWazeIndex--;
        _selectedWazeOption = null;
        _hasAnsweredWaze = false;
      });
    }
  }

  void _onAnswerScenario(int index) {
    if (_hasAnsweredScenario) return;
    setState(() {
      _selectedScenarioOption = index;
      _hasAnsweredScenario = true;
    });
  }

  void _nextScenario() {
    if (_currentScenarioIndex < DrivingSeedData.drivingScenarios.length - 1) {
      setState(() {
        _currentScenarioIndex++;
        _selectedScenarioOption = null;
        _hasAnsweredScenario = false;
      });
    }
  }

  void _prevScenario() {
    if (_currentScenarioIndex > 0) {
      setState(() {
        _currentScenarioIndex--;
        _selectedScenarioOption = null;
        _hasAnsweredScenario = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Вождение, Парковка и Waze в Израиле'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.local_parking_rounded),
              text: 'Бордюры и Парковка',
            ),
            Tab(
              icon: Icon(Icons.navigation_rounded),
              text: 'Голосовой Waze',
            ),
            Tab(
              icon: Icon(Icons.local_gas_station_rounded),
              text: 'Заправка и Дороги',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildParkingTab(theme),
          _buildWazeTab(theme),
          _buildScenarioAndGlossaryTab(theme),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 1: Parking & Curbs
  // ---------------------------------------------------------------------------
  Widget _buildParkingTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // Top Guideline Banner
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('🚦 ', style: TextStyle(fontSize: 22)),
                  Text(
                    'Цвета бордюров в Израиле:',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                '• 🟦⬜ כחול-לבן: платная парковка (Pango/Cello), вечером часто только для жителей района.\n'
                '• 🟥⬜ אדום-לבן: стоянка строго запрещена (эвакуатор или штраф ₪250-500).\n'
                '• 🟥🟨 אדום-צהוב: остановка автобусов/такси (штраф ₪500-1000).\n'
                '• ⬜ אפור: бесплатная парковка для всех.',
                style: TextStyle(fontSize: 12.5, height: 1.4),
              ),
            ],
          ),
        ),

        // Cases list
        ...DrivingSeedData.parkingCurbCases.map((curbCase) {
          return ParkingCurbSimulatorCard(
            curbCase: curbCase,
            audioService: widget.audioService,
            addCardToSrsUseCase: widget.addCardToSrsUseCase,
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 2: Waze Voice Navigation Challenge
  // ---------------------------------------------------------------------------
  Widget _buildWazeTab(ThemeData theme) {
    const prompts = DrivingSeedData.wazePrompts;
    final p = prompts[_currentWazeIndex];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // Counter
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.cyan.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Подсказка ${_currentWazeIndex + 1} из ${prompts.length}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.cyan.shade900,
                  fontSize: 13,
                ),
              ),
            ),
            Row(
              children: [
                const Text('Waze Израиль ', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(p.iconEmoji, style: const TextStyle(fontSize: 20)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Waze Audio Callout Card
        Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        p.hebrewWithNikkud,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                          height: 1.45,
                        ),
                      ),
                    ),
                    if (widget.audioService != null)
                      IconButton.filledTonal(
                        icon: const Icon(Icons.volume_up_rounded),
                        tooltip: 'Озвучить команду навигатора',
                        onPressed: () =>
                            widget.audioService?.playWithTtsFallback(
                          sourcePath: null,
                          fallbackHebrewText: p.hebrewWithNikkud,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  p.transcriptionRu,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  p.translationRu,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        Text(
          'Какое действие требует навигатор?',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        // Options
        ...List.generate(p.actionOptionsRu.length, (index) {
          final opt = p.actionOptionsRu[index];
          final isCorrect = index == p.correctOptionIndex;
          final isSelected = _selectedWazeOption == index;

          Color borderColor = Colors.grey.shade300;
          Color bgColor = theme.cardColor;

          if (_hasAnsweredWaze) {
            if (isCorrect) {
              borderColor = Colors.green;
              bgColor = Colors.green.shade50;
            } else if (isSelected) {
              borderColor = Colors.red;
              bgColor = Colors.red.shade50;
            }
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => _onAnswerWaze(index),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 1.5),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: isSelected
                          ? (isCorrect ? Colors.green : Colors.red)
                          : theme.colorScheme.surfaceContainerHighest,
                      child: Text(
                        String.fromCharCode(65 + index),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        opt,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          color: _hasAnsweredWaze && isCorrect
                              ? Colors.green.shade900
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),

        if (_hasAnsweredWaze) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _selectedWazeOption == p.correctOptionIndex
                  ? Colors.green.shade50
                  : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _selectedWazeOption == p.correctOptionIndex
                    ? Colors.green.shade300
                    : Colors.orange.shade300,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _selectedWazeOption == p.correctOptionIndex
                      ? Icons.check_circle_rounded
                      : Icons.info_outline_rounded,
                  color: _selectedWazeOption == p.correctOptionIndex
                      ? Colors.green.shade800
                      : Colors.orange.shade800,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedWazeOption == p.correctOptionIndex
                        ? 'Верно! Вы не пропустите нужный маневр.'
                        : 'Внимание: правильное действие — ${p.correctActionRu}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _selectedWazeOption == p.correctOptionIndex
                          ? Colors.green.shade900
                          : Colors.orange.shade900,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 16),

        // Navigation
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Назад'),
              onPressed: _currentWazeIndex > 0 ? _prevWazePrompt : null,
            ),
            FilledButton.icon(
              icon: const Icon(Icons.arrow_forward_rounded),
              label: Text(
                _currentWazeIndex < prompts.length - 1
                    ? 'Следующая'
                    : 'Завершить',
              ),
              onPressed: _currentWazeIndex < prompts.length - 1
                  ? _nextWazePrompt
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 3: Road Scenarios & Driver Glossary
  // ---------------------------------------------------------------------------
  Widget _buildScenarioAndGlossaryTab(ThemeData theme) {
    const scenarios = DrivingSeedData.drivingScenarios;
    final sc = scenarios[_currentScenarioIndex];

    final query = _glossarySearchQuery.trim().toLowerCase();
    final glossary = DrivingSeedData.drivingGlossary.where((item) {
      if (query.isEmpty) return true;
      final plain = (item['plain'] ?? '').toLowerCase();
      final hebrew = (item['hebrew'] ?? '').toLowerCase();
      final translation = (item['translation'] ?? '').toLowerCase();
      final transcription = (item['transcription'] ?? '').toLowerCase();
      return plain.contains(query) ||
          hebrew.contains(query) ||
          translation.contains(query) ||
          transcription.contains(query);
    }).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // Dialogue Situation Card
        Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${sc.category.emoji} ${sc.interlocutorRoleRu}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      'Ситуация ${_currentScenarioIndex + 1} из ${scenarios.length}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        sc.speechHebrewWithNikkud,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          height: 1.45,
                        ),
                      ),
                    ),
                    if (widget.audioService != null)
                      IconButton(
                        icon: const Icon(Icons.volume_up_rounded),
                        onPressed: () =>
                            widget.audioService?.playWithTtsFallback(
                          sourcePath: null,
                          fallbackHebrewText: sc.speechHebrewWithNikkud,
                        ),
                      ),
                  ],
                ),
                Text(
                  '(${sc.transcriptionRu})',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade600,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(sc.translationRu),
                const SizedBox(height: 10),

                // Driver tip
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Text(
                    '💡 Совет: ${sc.driverTipRu}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.brown.shade900,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Response options
                ...List.generate(sc.responseOptions.length, (idx) {
                  final opt = sc.responseOptions[idx];
                  final isBest = idx == sc.bestResponseIndex;
                  final isSel = _selectedScenarioOption == idx;

                  Color borderC = Colors.grey.shade300;
                  Color bgC = theme.cardColor;

                  if (_hasAnsweredScenario) {
                    if (isBest) {
                      borderC = Colors.green;
                      bgC = Colors.green.shade50;
                    } else if (isSel) {
                      borderC = Colors.red;
                      bgC = Colors.red.shade50;
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () => _onAnswerScenario(idx),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: bgC,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: borderC),
                        ),
                        child: Text(
                          opt,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                if (_hasAnsweredScenario) ...[
                  const SizedBox(height: 4),
                  Text(
                    sc.explanationRu,
                    style: const TextStyle(fontSize: 12.5, color: Colors.green),
                  ),
                ],

                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      onPressed:
                          _currentScenarioIndex > 0 ? _prevScenario : null,
                      child: const Text('Назад'),
                    ),
                    FilledButton(
                      onPressed:
                          _currentScenarioIndex < scenarios.length - 1
                              ? _nextScenario
                              : null,
                      child: const Text('Следующая'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const Divider(height: 32),

        // Glossary Section
        Text(
          'Атлас израильского водителя',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        // Search bar
        TextField(
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search_rounded),
            hintText: 'Поиск по дорожному словарю (панго, права, тест...)',
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          onChanged: (val) {
            setState(() => _glossarySearchQuery = val);
          },
        ),
        const SizedBox(height: 12),

        ...glossary.map((term) {
          final hebrew = term['hebrew'] ?? '';
          final plain = term['plain'] ?? '';
          final transcription = term['transcription'] ?? '';
          final translation = term['translation'] ?? '';
          final tip = term['tip'] ?? '';

          return Card(
            elevation: 1,
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          translation,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.5,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.audioService != null)
                            IconButton(
                              icon: const Icon(Icons.volume_up_rounded),
                              onPressed: () =>
                                  widget.audioService?.playWithTtsFallback(
                                sourcePath: null,
                                fallbackHebrewText: hebrew,
                              ),
                            ),
                          if (widget.addCardToSrsUseCase != null)
                            IconButton(
                              icon: const Icon(Icons.bookmark_add_outlined),
                              onPressed: () async {
                                final res =
                                    await widget.addCardToSrsUseCase?.call(
                                  AddCardToSrsParams(
                                    id: 'drive_${plain.hashCode}',
                                    hebrewVocalized: hebrew,
                                    russianTranslation:
                                        '$translation ($transcription) — $tip',
                                    category: LexicalCategory.noun,
                                    exampleHebrewVocalized: hebrew,
                                    exampleRussian: translation,
                                  ),
                                );
                                if (mounted) {
                                  final msg = (res?.isSuccess ?? false)
                                      ? '«$plain» добавлен в карточки!'
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
                        ],
                      ),
                    ],
                  ),
                  Text(
                    hebrew,
                    textDirection: TextDirection.rtl,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                      height: 1.45,
                    ),
                  ),
                  Text(
                    '($transcription)',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '💡 $tip',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 20),
      ],
    );
  }
}
