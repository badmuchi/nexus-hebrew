import 'package:flutter/material.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../srs/domain/entities/srs_card.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../data/datasources/health_seed_data.dart';
import '../../domain/entities/medical_scenario.dart';
import '../widgets/interactive_body_map.dart';

/// Screen for Israeli Healthcare, Clinic/Doctor visits, Body Anatomy, and Pharmacy dialogue training.
class HealthClinicScreen extends StatefulWidget {
  final AudioPlaybackService? audioService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;

  const HealthClinicScreen({
    super.key,
    this.audioService,
    this.addCardToSrsUseCase,
  });

  @override
  State<HealthClinicScreen> createState() => _HealthClinicScreenState();
}

class _HealthClinicScreenState extends State<HealthClinicScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Medical scenario state
  MedicalScenarioCategory? _selectedCategory;
  int _currentCaseIndex = 0;
  int? _selectedAnswerIndex;
  bool _hasAnswered = false;

  // Glossary search state
  String _glossarySearchQuery = '';

  List<MedicalCaseQuestion> get _filteredCases {
    if (_selectedCategory == null) return HealthSeedData.medicalCases;
    return HealthSeedData.medicalCases
        .where((c) => c.category == _selectedCategory)
        .toList();
  }

  MedicalCaseQuestion get _currentCase {
    final list = _filteredCases;
    if (_currentCaseIndex >= list.length) {
      _currentCaseIndex = 0;
    }
    return list[_currentCaseIndex];
  }

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

  void _onCategorySelected(MedicalScenarioCategory? cat) {
    setState(() {
      _selectedCategory = cat;
      _currentCaseIndex = 0;
      _selectedAnswerIndex = null;
      _hasAnswered = false;
    });
  }

  void _onSelectAnswer(int index) {
    if (_hasAnswered) return;
    setState(() {
      _selectedAnswerIndex = index;
      _hasAnswered = true;
    });
  }

  void _goToNextCase() {
    final list = _filteredCases;
    if (_currentCaseIndex < list.length - 1) {
      setState(() {
        _currentCaseIndex++;
        _selectedAnswerIndex = null;
        _hasAnswered = false;
      });
    }
  }

  void _goToPreviousCase() {
    if (_currentCaseIndex > 0) {
      setState(() {
        _currentCaseIndex--;
        _selectedAnswerIndex = null;
        _hasAnswered = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Медицинский гид и Купат Холим'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.accessibility_new_rounded),
              text: 'Части тела и боли',
            ),
            Tab(
              icon: Icon(Icons.forum_rounded),
              text: 'Врач и Аптека',
            ),
            Tab(
              icon: Icon(Icons.local_pharmacy_rounded),
              text: 'Атлас медицины',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: Body Map & Pain Phrasing
          InteractiveBodyMap(
            bodyParts: HealthSeedData.bodyParts,
            audioService: widget.audioService,
            addCardToSrsUseCase: widget.addCardToSrsUseCase,
          ),

          // TAB 2: Interactive Doctor & Pharmacy Cases
          _buildCasesTab(theme),

          // TAB 3: Medical & Pharmacy Glossary
          _buildGlossaryTab(theme),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 2: Clinic & Pharmacy Cases
  // ---------------------------------------------------------------------------
  Widget _buildCasesTab(ThemeData theme) {
    final cases = _filteredCases;
    final c = _currentCase;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // Category Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('Все ситуации'),
                selected: _selectedCategory == null,
                onSelected: (val) {
                  if (val) _onCategorySelected(null);
                },
              ),
              const SizedBox(width: 8),
              ...MedicalScenarioCategory.values.map((cat) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('${cat.emoji} ${cat.titleRu}'),
                    selected: _selectedCategory == cat,
                    onSelected: (val) {
                      _onCategorySelected(val ? cat : null);
                    },
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Case counter & role
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Кейс ${_currentCaseIndex + 1} из ${cases.length}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                  fontSize: 13,
                ),
              ),
            ),
            Text(
              c.doctorRoleRu,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.secondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Question Card
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
                        c.speechHebrewWithNikkud,
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
                        tooltip: 'Озвучить врача',
                        onPressed: () =>
                            widget.audioService?.playWithTtsFallback(
                          sourcePath: null,
                          fallbackHebrewText: c.speechHebrewWithNikkud,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  c.transcriptionRu,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  c.translationRu,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),

                // Patient tip box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.teal.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('💡 ', style: TextStyle(fontSize: 18)),
                      Expanded(
                        child: Text(
                          c.patientTipRu,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.teal.shade900,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Response options
        Text(
          'Что ответишь врачу или фармацевту?',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        ...List.generate(c.responseOptions.length, (index) {
          final option = c.responseOptions[index];
          final isBest = index == c.bestResponseIndex;
          final isSelected = _selectedAnswerIndex == index;

          Color borderColor = Colors.grey.shade300;
          Color bgColor = theme.cardColor;

          if (_hasAnswered) {
            if (isBest) {
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
              onTap: () => _onSelectAnswer(index),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: isSelected
                          ? (isBest ? Colors.green : Colors.red)
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
                        option,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          height: 1.45,
                          color: _hasAnswered && isBest
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

        // Feedback Box
        if (_hasAnswered) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _selectedAnswerIndex == c.bestResponseIndex
                  ? Colors.green.shade50
                  : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _selectedAnswerIndex == c.bestResponseIndex
                    ? Colors.green.shade300
                    : Colors.orange.shade300,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _selectedAnswerIndex == c.bestResponseIndex
                          ? Icons.check_circle_rounded
                          : Icons.info_outline_rounded,
                      color: _selectedAnswerIndex == c.bestResponseIndex
                          ? Colors.green.shade800
                          : Colors.orange.shade800,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _selectedAnswerIndex == c.bestResponseIndex
                          ? 'Правильно и четко!'
                          : 'Внимание:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _selectedAnswerIndex == c.bestResponseIndex
                            ? Colors.green.shade900
                            : Colors.orange.shade900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  c.explanationRu,
                  style: const TextStyle(fontSize: 13, height: 1.35),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 16),

        // Navigation buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Назад'),
              onPressed: _currentCaseIndex > 0 ? _goToPreviousCase : null,
            ),
            FilledButton.icon(
              icon: const Icon(Icons.arrow_forward_rounded),
              label: Text(
                _currentCaseIndex < cases.length - 1
                    ? 'Следующий'
                    : 'Завершить',
              ),
              onPressed: _currentCaseIndex < cases.length - 1
                  ? _goToNextCase
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 3: Medical Glossary
  // ---------------------------------------------------------------------------
  Widget _buildGlossaryTab(ThemeData theme) {
    final query = _glossarySearchQuery.trim().toLowerCase();
    final items = HealthSeedData.medicalGlossary.where((item) {
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

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search_rounded),
              hintText: 'Поиск по медицинскому словарю (рецепт, тофес 17...)',
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
        ),

        // Terms List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final term = items[index];
              final hebrew = term['hebrew'] ?? '';
              final plain = term['plain'] ?? '';
              final transcription = term['transcription'] ?? '';
              final translation = term['translation'] ?? '';
              final tip = term['tip'] ?? '';

              return Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
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
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.audioService != null)
                                IconButton(
                                  icon: const Icon(Icons.volume_up_rounded),
                                  tooltip: 'Озвучить',
                                  onPressed: () =>
                                      widget.audioService?.playWithTtsFallback(
                                    sourcePath: null,
                                    fallbackHebrewText: hebrew,
                                  ),
                                ),
                              if (widget.addCardToSrsUseCase != null)
                                IconButton(
                                  icon: const Icon(Icons.bookmark_add_outlined),
                                  tooltip: 'В карточки FSRS',
                                  onPressed: () async {
                                    final res =
                                        await widget.addCardToSrsUseCase?.call(
                                      AddCardToSrsParams(
                                        id: 'health_${plain.hashCode}',
                                        hebrewVocalized: hebrew,
                                        russianTranslation:
                                            '$translation ($transcription) — $tip',
                                        category: LexicalCategory.noun,
                                        exampleHebrewVocalized: hebrew,
                                        exampleRussian: translation,
                                      ),
                                    );
                                    if (context.mounted) {
                                      final msg = (res?.isSuccess ?? false)
                                          ? '«$plain» добавлен в карточки!'
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
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hebrew,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
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
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
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
                            fontSize: 12.5,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
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
