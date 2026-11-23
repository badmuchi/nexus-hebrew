import 'package:flutter/material.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../srs/domain/entities/srs_card.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../data/datasources/housing_seed_data.dart';
import '../../domain/entities/rental_contract_clause.dart';
import '../widgets/yad2_listing_decoder_card.dart';

/// Screen for Israeli Apartment Rental, Yad2 Ad Decryptor, Contract Clauses, and Landlord Scenarios.
class ApartmentRentalScreen extends StatefulWidget {
  final AudioPlaybackService? audioService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;

  const ApartmentRentalScreen({
    super.key,
    this.audioService,
    this.addCardToSrsUseCase,
  });

  @override
  State<ApartmentRentalScreen> createState() => _ApartmentRentalScreenState();
}

class _ApartmentRentalScreenState extends State<ApartmentRentalScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Contract clause filter
  ContractClauseCategory? _selectedClauseCategory;

  // Maintenance scenario state
  int _currentScenarioIndex = 0;
  int? _selectedScenarioOption;
  bool _hasAnsweredScenario = false;

  // Glossary search state
  String _glossarySearchQuery = '';

  List<RentalContractClause> get _filteredClauses {
    if (_selectedClauseCategory == null) {
      return HousingSeedData.contractClauses;
    }
    return HousingSeedData.contractClauses
        .where((c) => c.category == _selectedClauseCategory)
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
    if (_currentScenarioIndex < HousingSeedData.housingScenarios.length - 1) {
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
        title: const Text('Аренда квартиры и Договор в Израиле'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.search_rounded),
              text: 'Объявления Yad2',
            ),
            Tab(
              icon: Icon(Icons.gavel_rounded),
              text: 'Договор и Права',
            ),
            Tab(
              icon: Icon(Icons.home_repair_service_rounded),
              text: 'Поломки и Словарь',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildYad2Tab(theme),
          _buildContractTab(theme),
          _buildScenariosAndGlossaryTab(theme),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 1: Yad2 Ad Decryptor
  // ---------------------------------------------------------------------------
  Widget _buildYad2Tab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // Top Guideline Banner
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.deepPurple.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('🏠 ', style: TextStyle(fontSize: 22)),
                  Text(
                    'Поиск жилья в Израиле (Yad2 и Facebook):',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple.shade900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'В Израиле объявления пестрят сокращениями (ש״ח, כ״א, מ״ר, ממ״ד, דוד שמש). '
                'Нажимай на плашки сокращений в карточках ниже, чтобы узнать их смысл, сэкономить тысячи шекелей и не попасться на скрытые ловушки!',
                style: TextStyle(fontSize: 12.5, height: 1.4),
              ),
            ],
          ),
        ),

        // Listings
        ...HousingSeedData.apartmentListings.map((listing) {
          return Yad2ListingDecoderCard(
            listing: listing,
            audioService: widget.audioService,
            addCardToSrsUseCase: widget.addCardToSrsUseCase,
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 2: Rental Contract Clauses
  // ---------------------------------------------------------------------------
  Widget _buildContractTab(ThemeData theme) {
    final clauses = _filteredClauses;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('Все пункты'),
                selected: _selectedClauseCategory == null,
                onSelected: (val) {
                  if (val) setState(() => _selectedClauseCategory = null);
                },
              ),
              const SizedBox(width: 8),
              ...ContractClauseCategory.values.map((cat) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('${cat.emoji} ${cat.titleRu}'),
                    selected: _selectedClauseCategory == cat,
                    onSelected: (val) {
                      setState(() => _selectedClauseCategory = val ? cat : null);
                    },
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 12),

        ...clauses.map((clause) {
          return Card(
            elevation: 1.5,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: clause.isFairClause
                    ? Colors.green.shade200
                    : Colors.red.shade300,
                width: 1.5,
              ),
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
                          clause.clauseTitleRu,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.5,
                            color: clause.isFairClause
                                ? theme.colorScheme.primary
                                : Colors.red.shade900,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: clause.isFairClause
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: clause.isFairClause
                                ? Colors.green.shade300
                                : Colors.red.shade300,
                          ),
                        ),
                        child: Text(
                          clause.isFairClause ? 'Законно ✅' : 'Осторожно ⚠️',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: clause.isFairClause
                                ? Colors.green.shade900
                                : Colors.red.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Hebrew Clause Text
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          clause.clauseHebrewWithNikkud,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.5,
                            height: 1.45,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (widget.audioService != null)
                        IconButton(
                          icon: const Icon(Icons.volume_up_rounded, size: 20),
                          tooltip: 'Озвучить пункт договора',
                          onPressed: () =>
                              widget.audioService?.playWithTtsFallback(
                            sourcePath: null,
                            fallbackHebrewText: clause.clauseHebrewWithNikkud,
                          ),
                        ),
                    ],
                  ),
                  Text(
                    '(${clause.transcriptionRu})',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Plain language explanation
                  Text(
                    clause.plainLanguageExplanationRu,
                    style: const TextStyle(fontSize: 13, height: 1.35),
                  ),
                  const SizedBox(height: 8),

                  // Tenant protection law callout
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Text(
                      '⚖️ Закон Израиля: ${clause.tenantProtectionLawRu}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade900,
                        height: 1.3,
                      ),
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
  // TAB 3: Maintenance Scenarios & Housing Glossary
  // ---------------------------------------------------------------------------
  Widget _buildScenariosAndGlossaryTab(ThemeData theme) {
    const scenarios = HousingSeedData.housingScenarios;
    final sc = scenarios[_currentScenarioIndex];

    final query = _glossarySearchQuery.trim().toLowerCase();
    final glossary = HousingSeedData.housingGlossary.where((item) {
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
        // Dialogue Scenario Card
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
                      '👨‍💼 ${sc.interlocutorRoleRu}',
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

                // Interlocutor Speech
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

                // Tenant tip
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Text(
                    '💡 Совет жильцу: ${sc.tenantTipRu}',
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

        // Housing Glossary Section
        Text(
          'Словарь аренды и недвижимости',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        // Search bar
        TextField(
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search_rounded),
            hintText: 'Поиск по терминам (арнона, бойлер, чеки...)',
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
                                    id: 'housing_${plain.hashCode}',
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
