import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../data/datasources/army_tzahal_seed_data.dart';
import '../../domain/entities/army_term.dart';
import '../widgets/army_term_card.dart';

/// Interactive guide to IDF slang, Tsav Rishon interview simulator,
/// military ranks and Sherut Leumi national civil service.
class ArmyTzahalScreen extends StatefulWidget {
  final AudioPlaybackService? audioService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;

  const ArmyTzahalScreen({
    super.key,
    this.audioService,
    this.addCardToSrsUseCase,
  });

  @override
  State<ArmyTzahalScreen> createState() => _ArmyTzahalScreenState();
}

class _ArmyTzahalScreenState extends State<ArmyTzahalScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final List<ArmyTerm> _allTerms = ArmyTzahalSeedData.terms;
  final List<TsavRishonScenario> _scenarios = ArmyTzahalSeedData.interviewScenarios;

  ArmyCategory? _selectedCategory;
  String _searchQuery = '';
  bool _showNikkud = true;

  // Interview state
  int _currentScenarioIndex = 0;
  int? _selectedAnswerIndex;
  bool _hasAnswered = false;

  TsavRishonScenario get _currentScenario => _scenarios[_currentScenarioIndex];

  List<ArmyTerm> get _filteredTerms {
    return _allTerms.where((t) {
      final matchesCat =
          _selectedCategory == null || t.category == _selectedCategory;
      if (!matchesCat) return false;
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.toLowerCase().trim();
      return t.hebrewNormalized.toLowerCase().contains(q) ||
          t.meaningRu.toLowerCase().contains(q) ||
          t.transcriptionRu.toLowerCase().contains(q);
    }).toList();
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

  void _onAnswerSelected(int index) {
    if (_hasAnswered) return;
    unawaited(HapticFeedback.selectionClick());
    setState(() {
      _selectedAnswerIndex = index;
      _hasAnswered = true;
    });
  }

  void _nextScenario() {
    unawaited(HapticFeedback.lightImpact());
    setState(() {
      _currentScenarioIndex = (_currentScenarioIndex + 1) % _scenarios.length;
      _selectedAnswerIndex = null;
      _hasAnswered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text('🪖 ', style: TextStyle(fontSize: 22)),
            Text(
              'ЦАХАЛ и Шерут Леуми',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: _showNikkud ? 'Скрыть огласовки' : 'Показать огласовки',
            icon: Icon(
              _showNikkud ? Icons.visibility_rounded : Icons.visibility_off_rounded,
            ),
            onPressed: () => setState(() => _showNikkud = !_showNikkud),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'Сленг и словарь'),
            Tab(text: 'Собеседование (Цав Ришон)'),
            Tab(text: 'Шерут Леуми и Звания'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSlangTab(),
          _buildInterviewTab(),
          _buildRanksAndSherutTab(),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 1: Slang & Vocabulary
  // ---------------------------------------------------------------------------
  Widget _buildSlangTab() {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Search field
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search_rounded),
                hintText: 'Поиск по сленгу (пакаль, гимелим, крави)...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                isDense: true,
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
            const SizedBox(height: 12),

            // Category filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: const Text('Все термины'),
                      selected: _selectedCategory == null,
                      onSelected: (_) => setState(() => _selectedCategory = null),
                    ),
                  ),
                  for (final cat in ArmyCategory.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        avatar: Text(cat.iconEmoji),
                        label: Text(cat.titleRu),
                        selected: _selectedCategory == cat,
                        onSelected: (_) => setState(() => _selectedCategory = cat),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            Text(
              'Найдено терминов: ${_filteredTerms.length}',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 10),

            for (final term in _filteredTerms) ...[
              ArmyTermCard(
                term: term,
                showNikkud: _showNikkud,
                audioService: widget.audioService,
                addCardToSrsUseCase: widget.addCardToSrsUseCase,
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 2: Tsav Rishon Interview Simulator
  // ---------------------------------------------------------------------------
  Widget _buildInterviewTab() {
    final theme = Theme.of(context);
    final scenario = _currentScenario;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF33691E).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF33691E).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Text('🎖️ ', style: TextStyle(fontSize: 26)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scenario.stageTitleRu,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.5,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Интервьюер: ${scenario.interviewerRoleRu}',
                          style: const TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B5E20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_currentScenarioIndex + 1}/${_scenarios.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Interviewer Speech Bubble
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Вопрос военного интервьюера:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.brown),
                      ),
                      if (widget.audioService != null)
                        IconButton(
                          icon: const Icon(Icons.volume_up_rounded, size: 20),
                          tooltip: 'Озвучить вопрос',
                          visualDensity: VisualDensity.compact,
                          onPressed: () => widget.audioService?.playWithTtsFallback(
                            sourcePath: null,
                            fallbackHebrewText: scenario.interviewerSpeechHebrewWithNikkud,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      _showNikkud
                          ? scenario.interviewerSpeechHebrewWithNikkud
                          : scenario.interviewerSpeechRu,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        height: 1.45,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    scenario.interviewerSpeechRu,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Ваш ответ на иврите:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 10),

            // Options
            for (int i = 0; i < scenario.optionsHebrew.length; i++) ...[
              _buildOptionTile(
                index: i,
                optionHebrew: scenario.optionsHebrew[i],
                optionRu: scenario.optionsRu[i],
                isBest: i == scenario.bestOptionIndex,
              ),
              const SizedBox(height: 10),
            ],

            if (_hasAnswered) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _selectedAnswerIndex == scenario.bestOptionIndex
                      ? Colors.green.shade50
                      : Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _selectedAnswerIndex == scenario.bestOptionIndex
                        ? Colors.green.shade300
                        : Colors.amber.shade300,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Text(
                          _selectedAnswerIndex == scenario.bestOptionIndex ? '🎯 ' : '💡 ',
                          style: const TextStyle(fontSize: 18),
                        ),
                        Text(
                          _selectedAnswerIndex == scenario.bestOptionIndex
                              ? 'Отличный ответ для интервьюера!'
                              : 'Рекомендация по формулировке:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: _selectedAnswerIndex == scenario.bestOptionIndex
                                ? Colors.green.shade900
                                : Colors.brown.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      scenario.explanationRu,
                      style: const TextStyle(fontSize: 12.5, height: 1.35),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Совет инсайдера: ${scenario.insiderTipRu}',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.brown.shade900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _nextScenario,
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                      label: const Text('Следующая ситуация Цав Ришон'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required int index,
    required String optionHebrew,
    required String optionRu,
    required bool isBest,
  }) {
    final theme = Theme.of(context);
    final isSelected = _selectedAnswerIndex == index;

    Color borderColor = theme.colorScheme.outlineVariant.withValues(alpha: 0.7);
    Color bgColor = theme.colorScheme.surface;

    if (_hasAnswered) {
      if (isBest) {
        borderColor = Colors.green;
        bgColor = Colors.green.shade50;
      } else if (isSelected) {
        borderColor = Colors.red;
        bgColor = Colors.red.shade50;
      }
    } else if (isSelected) {
      borderColor = const Color(0xFF33691E);
      bgColor = const Color(0xFF33691E).withValues(alpha: 0.08);
    }

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: _hasAnswered ? null : () => _onAnswerSelected(index),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  optionHebrew,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    height: 1.45,
                    color: isSelected ? const Color(0xFF1B5E20) : theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                optionRu,
                style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 3: Sherut Leumi & Ranks
  // ---------------------------------------------------------------------------
  Widget _buildRanksAndSherutTab() {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Sherut Leumi Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('🕊️ ', style: TextStyle(fontSize: 26)),
                      Expanded(
                        child: Text(
                          'Шерут Леуми (שֵׁרוּת לְאֻמִּי-אֶזְרָחִי)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF0D47A1),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Гражданская альтернативная служба в больницах, школах, скорой помощи (МАДА), полиции и заповедниках. '
                    'Длится 1 или 2 года. Предоставляет аналогичные демобилизационные гранты (пикадон) и льготы при поступлении в вузы.',
                    style: TextStyle(fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Key Ranks in IDF
            const Text(
              'Иерархия званий в ЦАХАЛе (דַּרְגּוֹת צַהַ״ל):',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 10),

            _buildRankCard(
              titleHebrew: 'טוּרַאי ➔ רַב-טוּרַאי (רַבָּ״ט)',
              titleRu: 'Рядовой ➔ Ефрейтор (Рабат)',
              descriptionRu: 'Начальное звание новобранцев во время курса молодого бойца (тиронут).',
            ),
            const SizedBox(height: 8),
            _buildRankCard(
              titleHebrew: 'סַמָּל ➔ סַמָּ״ל רִאשׁוֹן (סַמָּ״ר)',
              titleRu: 'Сержант ➔ Старший сержант (Самар)',
              descriptionRu: 'Командиры отделений и опытные старослужащие бойцы.',
            ),
            const SizedBox(height: 8),
            _buildRankCard(
              titleHebrew: 'סֶגֶן-מִשְׁנֶה (סָגָ״ם) ➔ סֶגֶן ➔ סֶרֶן',
              titleRu: 'Младший лейтенант (Сагам) ➔ Лейтенант ➔ Капитан (Серен)',
              descriptionRu: 'Офицеры взводного и ротного звена после окончания Баад 1.',
            ),
            const SizedBox(height: 8),
            _buildRankCard(
              titleHebrew: 'רַב-סֶרֶן (רַסָּ״ן) ➔ סְגַן-אַלּוּף (סָגָ״ל) ➔ אַלּוּף',
              titleRu: 'Майор (Расан) ➔ Подполковник ➔ Генерал (Алуф)',
              descriptionRu: 'Старший командный состав батальонов, бригад и Генерального штаба.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankCard({
    required String titleHebrew,
    required String titleRu,
    required String descriptionRu,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                titleHebrew,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.5,
                  height: 1.45,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              titleRu,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 2),
            Text(
              descriptionRu,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}
