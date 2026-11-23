import 'package:flutter/material.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../srs/domain/entities/srs_card.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../data/datasources/holidays_seed_data.dart';
import '../../domain/entities/jewish_holiday.dart';
import '../widgets/shabbat_survival_card.dart';

/// Screen for Israeli Shabbat rules, Jewish holiday calendar, greeting etiquette, and cultural vocabulary.
class HolidaysShabbatScreen extends StatefulWidget {
  final AudioPlaybackService? audioService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;

  const HolidaysShabbatScreen({
    super.key,
    this.audioService,
    this.addCardToSrsUseCase,
  });

  @override
  State<HolidaysShabbatScreen> createState() => _HolidaysShabbatScreenState();
}

class _HolidaysShabbatScreenState extends State<HolidaysShabbatScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Holiday season filter
  HolidaySeason? _selectedSeason;

  // Scenario state
  int _currentScenarioIndex = 0;
  int? _selectedScenarioOption;
  bool _hasAnsweredScenario = false;

  // Glossary search
  String _glossarySearchQuery = '';

  List<JewishHoliday> get _filteredHolidays {
    if (_selectedSeason == null) return HolidaysSeedData.jewishHolidays;
    return HolidaysSeedData.jewishHolidays
        .where((h) => h.season == _selectedSeason)
        .toList();
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

  void _onAnswerScenario(int index) {
    if (_hasAnsweredScenario) return;
    setState(() {
      _selectedScenarioOption = index;
      _hasAnsweredScenario = true;
    });
  }

  void _nextScenario() {
    if (_currentScenarioIndex < HolidaysSeedData.holidayScenarios.length - 1) {
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
        title: const Text('Шаббат, Праздники и Традиции Израиля'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.wb_twilight_rounded),
              text: 'Шаббат в Израиле',
            ),
            Tab(
              icon: Icon(Icons.calendar_month_rounded),
              text: 'Праздники',
            ),
            Tab(
              icon: Icon(Icons.waving_hand_rounded),
              text: 'Этикет и Словарь',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildShabbatTab(theme),
          _buildHolidaysTab(theme),
          _buildEtiquetteAndGlossaryTab(theme),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 1: Shabbat Rhythm & Guide
  // ---------------------------------------------------------------------------
  Widget _buildShabbatTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // Interactive 4-stage Shabbat Survival Card
        ShabbatSurvivalCard(
          stages: HolidaysSeedData.shabbatStages,
          audioService: widget.audioService,
          addCardToSrsUseCase: widget.addCardToSrsUseCase,
        ),

        const SizedBox(height: 12),

        // Shabbat Transportation & Survival FAQ Card
        Card(
          elevation: 1,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.help_outline_rounded,
                        color: Colors.teal, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Шпаргалка передвижения в Шаббат',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildFaqItem(
                  question: 'Как добраться до моря или в гости без поезда?',
                  answer:
                      '• Автобусы «נעים בסופ״ש» (Наим ба-Софаш) — бесплатные автобусы по выходным в Тель-Авиве, Рамат-Гане, Гиватаиме и Герцлии.\n'
                      '• Маршрутки (מוניות שירות) курсируют по основным линиям.\n'
                      '• Такси (Gett / Yango) работают по специальному субботнему тарифу (מונה שבת).',
                ),
                const Divider(height: 18),
                _buildFaqItem(
                  question: 'Где купить продукты, если супермаркеты закрыты?',
                  answer:
                      'В светских городах работают ночные киоски (פיצוציות), круглосуточные маркеты (Tiv Taam, AM:PM, Super Yuda), а в субботу вечером (מוצ״ש) открываются крупные каньоны и суперы.',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFaqItem({required String question, required String answer}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
        ),
        const SizedBox(height: 4),
        Text(
          answer,
          style: TextStyle(
            fontSize: 12.5,
            color: Colors.grey.shade800,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 2: Holiday Calendar
  // ---------------------------------------------------------------------------
  Widget _buildHolidaysTab(ThemeData theme) {
    final holidays = _filteredHolidays;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // Season Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('Все праздники'),
                selected: _selectedSeason == null,
                onSelected: (val) {
                  if (val) setState(() => _selectedSeason = null);
                },
              ),
              const SizedBox(width: 8),
              ...HolidaySeason.values.map((s) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('${s.emoji} ${s.titleRu}'),
                    selected: _selectedSeason == s,
                    onSelected: (val) {
                      setState(() => _selectedSeason = val ? s : null);
                    },
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Holidays Cards
        ...holidays.map((hol) {
          return Card(
            elevation: 1.5,
            margin: const EdgeInsets.only(bottom: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer
                              .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(hol.iconEmoji,
                            style: const TextStyle(fontSize: 24)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hol.russianTitle,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              hol.monthHebrew,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        hol.hebrewNameWithNikkud,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                          height: 1.45,
                        ),
                      ),
                      if (widget.audioService != null)
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.volume_up_rounded, size: 20),
                          tooltip: 'Озвучить название',
                          onPressed: () =>
                              widget.audioService?.playWithTtsFallback(
                            sourcePath: null,
                            fallbackHebrewText: hol.hebrewNameWithNikkud,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Official Greeting Banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '🗣️ Как правильно поздравлять:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12.5,
                                color: Colors.green,
                              ),
                            ),
                            if (widget.audioService != null)
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(Icons.volume_up_rounded,
                                    size: 18, color: Colors.green),
                                tooltip: 'Озвучить поздравление',
                                onPressed: () =>
                                    widget.audioService?.playWithTtsFallback(
                                  sourcePath: null,
                                  fallbackHebrewText:
                                      hol.greetingHebrewWithNikkud,
                                ),
                              ),
                          ],
                        ),
                        Text(
                          hol.greetingHebrewWithNikkud,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade900,
                            height: 1.45,
                          ),
                        ),
                        Text(
                          '${hol.greetingRussian} (${hol.greetingTranscriptionRu})',
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Customs & Food
                  Text(
                    '🍽️ Обычаи и угощения: ${hol.customsAndFoodRu}',
                    style: const TextStyle(fontSize: 12.5, height: 1.35),
                  ),
                  const SizedBox(height: 6),

                  // Modern Reality
                  Text(
                    '🏙️ В современном Израиле: ${hol.modernIsraeliRealityRu}',
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.35,
                      color: Colors.brown.shade800,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Add to SRS
                  if (widget.addCardToSrsUseCase != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                        label: const Text('В карточки FSRS'),
                        onPressed: () async {
                          final res = await widget.addCardToSrsUseCase?.call(
                            AddCardToSrsParams(
                              id: 'holiday_${hol.id}',
                              hebrewVocalized: hol.hebrewNameWithNikkud,
                              russianTranslation:
                                  '${hol.russianTitle} — поздравление: ${hol.greetingRussian}',
                              category: LexicalCategory.noun,
                              exampleHebrewVocalized:
                                  hol.greetingHebrewWithNikkud,
                              exampleRussian: hol.greetingRussian,
                            ),
                          );
                          if (mounted) {
                            final msg = (res?.isSuccess ?? false)
                                ? '«${hol.russianTitle}» добавлено в FSRS!'
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
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 3: Etiquette Scenarios & Cultural Glossary
  // ---------------------------------------------------------------------------
  Widget _buildEtiquetteAndGlossaryTab(ThemeData theme) {
    const scenarios = HolidaysSeedData.holidayScenarios;
    final sc = scenarios[_currentScenarioIndex];

    final query = _glossarySearchQuery.trim().toLowerCase();
    final glossary = HolidaysSeedData.holidaysGlossary.where((item) {
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
        // Dialogue Etiquette Card
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
                      '🎭 ${sc.interlocutorRoleRu}',
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
                const SizedBox(height: 4),
                Text(
                  sc.situationRu,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.brown.shade800,
                  ),
                ),
                const SizedBox(height: 10),

                // Speech
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

                // Etiquette tip box
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Text(
                    '💡 Совет сабры: ${sc.etiquetteTipRu}',
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
                  final isBest = idx == sc.bestOptionIndex;
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

        // Cultural Glossary Section
        Text(
          'Атлас еврейского календаря и Шаббата',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        // Search bar
        TextField(
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search_rounded),
            hintText: 'Поиск (шаббат, хала, кидуш, моцаш...)',
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
                                    id: 'holiday_${plain.hashCode}',
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
