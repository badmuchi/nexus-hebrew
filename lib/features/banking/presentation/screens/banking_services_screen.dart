import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../srs/domain/entities/srs_card.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../data/datasources/banking_seed_data.dart';
import '../widgets/israeli_check_card.dart';

/// Comprehensive interactive screen for Israeli banking, checks, mortgages, and social security.
class BankingServicesScreen extends StatefulWidget {
  final AudioPlaybackService? audioService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;

  const BankingServicesScreen({
    super.key,
    this.audioService,
    this.addCardToSrsUseCase,
  });

  @override
  State<BankingServicesScreen> createState() => _BankingServicesScreenState();
}

class _BankingServicesScreenState extends State<BankingServicesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Selected check index
  int _selectedCheckIndex = 0;

  // Financial scenario state
  int _selectedScenarioIndex = 0;
  int? _selectedScenarioOption;
  bool _hasAnsweredScenario = false;

  // Glossary query
  String _glossaryQuery = '';

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
    unawaited(HapticFeedback.selectionClick());
    setState(() {
      _selectedScenarioOption = index;
      _hasAnsweredScenario = true;
    });
  }

  void _nextScenario() {
    unawaited(HapticFeedback.lightImpact());
    setState(() {
      _selectedScenarioIndex =
          (_selectedScenarioIndex + 1) % BankingSeedData.financialScenarios.length;
      _selectedScenarioOption = null;
      _hasAnsweredScenario = false;
    });
  }

  Future<void> _addFinancialTermToSrs(Map<String, String> term) async {
    final useCase = widget.addCardToSrsUseCase;
    if (useCase == null) return;

    final hebrew = term['hebrew'] ?? '';
    final trans = term['transcription'] ?? '';
    final transRu = term['translation'] ?? '';

    await useCase(
      AddCardToSrsParams(
        id: 'bank_${term['plain'] ?? hebrew}',
        hebrewVocalized: hebrew,
        russianTranslation: '$transRu ($trans)',
        category: LexicalCategory.phrase,
      ),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('«$hebrew» добавлено в FSRS повторение!'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Банк, Машканта и Битуах Леуми'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.account_balance_rounded), text: 'Банк и Чеки'),
            Tab(icon: Icon(Icons.home_work_rounded), text: 'Машканта'),
            Tab(icon: Icon(Icons.shield_outlined), text: 'Битуах Леуми и Словарь'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBankAndChecksTab(),
          _buildMortgageTab(),
          _buildSocialSecurityAndGlossaryTab(),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 1: Bank Account & Checks
  // ---------------------------------------------------------------------------
  Widget _buildBankAndChecksTab() {
    const checks = BankingSeedData.sampleChecks;
    final currentCheck = checks[_selectedCheckIndex];
    final currentScenario = BankingSeedData.financialScenarios[_selectedScenarioIndex];

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Check Case Selector
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(checks.length, (idx) {
                  final c = checks[idx];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(c.purposeRu),
                      selected: idx == _selectedCheckIndex,
                      onSelected: (_) => setState(() => _selectedCheckIndex = idx),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 12),

            // Visual Israeli Check Card
            IsraeliCheckCard(
              check: currentCheck,
              audioService: widget.audioService,
            ),
            const SizedBox(height: 18),

            // Financial Dialogue Simulator Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🗣️ ${currentScenario.interlocutorRoleRu}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF0D47A1),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Цель: ${currentScenario.clientGoalRu}',
                            textAlign: TextAlign.end,
                            style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Teller Speech
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: Text(
                              currentScenario.tellerSpeechHebrewWithNikkud,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                height: 1.45,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentScenario.tellerSpeechRu,
                            style: const TextStyle(fontSize: 12.5, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    const Text(
                      'Ваш ответ сотруднику банка:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 8),

                    // Response options
                    for (int i = 0; i < currentScenario.clientResponseOptionsHebrew.length; i++) ...[
                      _buildScenarioOptionTile(
                        index: i,
                        optionHebrew: currentScenario.clientResponseOptionsHebrew[i],
                        optionRu: currentScenario.clientResponseOptionsRu[i],
                        isBest: i == currentScenario.bestOptionIndex,
                      ),
                      const SizedBox(height: 8),
                    ],

                    if (_hasAnsweredScenario) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _selectedScenarioOption == currentScenario.bestOptionIndex
                              ? Colors.green.shade50
                              : Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedScenarioOption == currentScenario.bestOptionIndex
                                ? Colors.green.shade300
                                : Colors.amber.shade300,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedScenarioOption == currentScenario.bestOptionIndex
                                  ? '🎯 Грамотно и профессионально!'
                                  : '💡 Полезный совет:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12.5,
                                color: _selectedScenarioOption == currentScenario.bestOptionIndex
                                    ? Colors.green.shade900
                                    : Colors.brown.shade900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(currentScenario.explanationRu, style: const TextStyle(fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(
                              '📌 Совет инсайдера: ${currentScenario.insiderFinancialTipRu}',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.brown.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: _nextScenario,
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: const Text('Следующая ситуация'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScenarioOptionTile({
    required int index,
    required String optionHebrew,
    required String optionRu,
    required bool isBest,
  }) {
    final theme = Theme.of(context);
    final isSelected = _selectedScenarioOption == index;

    Color borderColor = theme.colorScheme.outlineVariant.withValues(alpha: 0.7);
    Color bgColor = theme.colorScheme.surface;

    if (_hasAnsweredScenario) {
      if (isBest) {
        borderColor = Colors.green;
        bgColor = Colors.green.shade50;
      } else if (isSelected) {
        borderColor = Colors.red;
        bgColor = Colors.red.shade50;
      }
    } else if (isSelected) {
      borderColor = const Color(0xFF0D47A1);
      bgColor = const Color(0xFF0D47A1).withValues(alpha: 0.08);
    }

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _hasAnsweredScenario ? null : () => _onAnswerScenario(index),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
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
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    height: 1.45,
                    color: isSelected ? const Color(0xFF0D47A1) : theme.colorScheme.onSurface,
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
  // TAB 2: Mortgage (Машканта)
  // ---------------------------------------------------------------------------
  Widget _buildMortgageTab() {
    const tracks = BankingSeedData.mortgageTracks;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Intro Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Row(
                children: [
                  Text('🏡 ', style: TextStyle(fontSize: 26)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ипотека в Израиле (מַשְׁכַּנְתָּא)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Машканта делится минимум на 2–3 разных трека (מסלולים) для балансировки риска процентных ставок и инфляции.',
                          style: TextStyle(fontSize: 12, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3 Mortgage Tracks Cards
            for (final track in tracks) ...[
              Card(
                elevation: 1.5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              track.titleRu,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              track.abbreviationHebrew,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.indigo),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Тип ставки: ${track.interestTypeRu}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 10),

                      // Pros & Cons
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text('✅ Плюсы: ${track.prosRu}', style: const TextStyle(fontSize: 11.5)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text('⚠️ Минусы: ${track.consRu}', style: const TextStyle(fontSize: 11.5)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      Text(
                        '💡 Совет советника: ${track.insiderRecommendationRu}',
                        style: TextStyle(fontSize: 12, color: Colors.brown.shade800, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 3: Bituach Leumi & Financial Glossary
  // ---------------------------------------------------------------------------
  Widget _buildSocialSecurityAndGlossaryTab() {
    final theme = Theme.of(context);
    final q = _glossaryQuery.toLowerCase().trim();

    final filtered = BankingSeedData.bankingGlossary.where((item) {
      if (q.isEmpty) return true;
      final hebrew = (item['hebrew'] ?? '').toLowerCase();
      final plain = (item['plain'] ?? '').toLowerCase();
      final trans = (item['transcription'] ?? '').toLowerCase();
      final translation = (item['translation'] ?? '').toLowerCase();
      return hebrew.contains(q) || plain.contains(q) || trans.contains(q) || translation.contains(q);
    }).toList();

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search_rounded),
                hintText: 'Поиск по финансовым терминам (ош, чеки, машканта, налоги...)',
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) => setState(() => _glossaryQuery = val),
            ),
            const SizedBox(height: 14),

            Text(
              'Найдено терминов: ${filtered.length}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12.5,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),

            ...filtered.map((item) {
              final hebrew = item['hebrew'] ?? '';
              final trans = item['transcription'] ?? '';
              final transRu = item['translation'] ?? '';
              final tip = item['tip'] ?? '';
              final cat = item['category'] ?? '';

              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Directionality(
                              textDirection: TextDirection.rtl,
                              child: Text(
                                hebrew,
                                style: const TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.bold,
                                  height: 1.45,
                                ),
                              ),
                            ),
                            Text('($trans)', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                            const SizedBox(height: 3),
                            Text(transRu, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(tip, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          if (widget.audioService != null)
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.volume_up_rounded, size: 20),
                              tooltip: 'Озвучить',
                              onPressed: () => widget.audioService?.playWithTtsFallback(
                                sourcePath: null,
                                fallbackHebrewText: hebrew,
                              ),
                            ),
                          if (widget.addCardToSrsUseCase != null)
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.bookmark_add_outlined, size: 20),
                              tooltip: 'В словарь FSRS',
                              onPressed: () => _addFinancialTermToSrs(item),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
