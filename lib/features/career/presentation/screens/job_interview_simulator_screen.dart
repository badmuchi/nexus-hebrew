import 'package:flutter/material.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../srs/domain/entities/srs_card.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../data/datasources/career_seed_data.dart';
import '../../domain/entities/job_interview_case.dart';
import '../widgets/payslip_inspector_card.dart';

/// Screen for Israeli Tech Job Interview Simulation, Payslip Analysis, and Workplace Hebrew.
class JobInterviewSimulatorScreen extends StatefulWidget {
  final AudioPlaybackService? audioService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;

  const JobInterviewSimulatorScreen({
    super.key,
    this.audioService,
    this.addCardToSrsUseCase,
  });

  @override
  State<JobInterviewSimulatorScreen> createState() =>
      _JobInterviewSimulatorScreenState();
}

class _JobInterviewSimulatorScreenState
    extends State<JobInterviewSimulatorScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Interview simulation state
  InterviewCategory? _selectedCategory;
  int _currentQuestionIndex = 0;
  int? _selectedAnswerIndex;
  bool _hasAnswered = false;

  // Glossary search state
  String _glossarySearchQuery = '';

  // Gross-to-Net quick estimator state
  double _simulatorGrossSalary = 25000;

  List<InterviewQuestion> get _filteredQuestions {
    if (_selectedCategory == null) {
      return CareerSeedData.interviewQuestions;
    }
    return CareerSeedData.interviewQuestions
        .where((q) => q.category == _selectedCategory)
        .toList();
  }

  InterviewQuestion get _currentQuestion {
    final list = _filteredQuestions;
    if (_currentQuestionIndex >= list.length) {
      _currentQuestionIndex = 0;
    }
    return list[_currentQuestionIndex];
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

  void _onCategorySelected(InterviewCategory? category) {
    setState(() {
      _selectedCategory = category;
      _currentQuestionIndex = 0;
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

  void _goToNextQuestion() {
    final list = _filteredQuestions;
    if (_currentQuestionIndex < list.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswerIndex = null;
        _hasAnswered = false;
      });
    }
  }

  void _goToPreviousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
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
        title: const Text('Карьера и Собеседование в Израиле'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.record_voice_over_rounded),
              text: 'Собеседование',
            ),
            Tab(
              icon: Icon(Icons.receipt_long_rounded),
              text: 'Тлуш Маскорет',
            ),
            Tab(
              icon: Icon(Icons.menu_book_rounded),
              text: 'Хайтек-словарь',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInterviewTab(theme),
          _buildPayslipTab(theme),
          _buildGlossaryTab(theme),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 1: Interview Simulator
  // ---------------------------------------------------------------------------
  Widget _buildInterviewTab(ThemeData theme) {
    final questions = _filteredQuestions;
    final q = _currentQuestion;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // Category Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('Все этапы'),
                selected: _selectedCategory == null,
                onSelected: (val) {
                  if (val) _onCategorySelected(null);
                },
              ),
              const SizedBox(width: 8),
              ...InterviewCategory.values.map((cat) {
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

        // Progress counter
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
                'Вопрос ${_currentQuestionIndex + 1} из ${questions.length}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                  fontSize: 13,
                ),
              ),
            ),
            Text(
              q.interviewerRoleRu,
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
                        q.interviewerHebrewWithNikkud,
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
                        tooltip: 'Озвучить вопрос',
                        onPressed: () =>
                            widget.audioService?.playWithTtsFallback(
                          sourcePath: null,
                          fallbackHebrewText: q.interviewerHebrewWithNikkud,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  q.transcriptionRu,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  q.translationRu,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),

                // Mentor tip box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('💡 ', style: TextStyle(fontSize: 18)),
                      Expanded(
                        child: Text(
                          q.mentorCareerTipRu,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.brown.shade900,
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

        // Response Options
        Text(
          'Как ответишь рекрутеру?',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        ...List.generate(q.responseOptions.length, (index) {
          final option = q.responseOptions[index];
          final isBest = index == q.bestResponseIndex;
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

        // Feedback Explanation
        if (_hasAnswered) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _selectedAnswerIndex == q.bestResponseIndex
                  ? Colors.green.shade50
                  : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _selectedAnswerIndex == q.bestResponseIndex
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
                      _selectedAnswerIndex == q.bestResponseIndex
                          ? Icons.check_circle_rounded
                          : Icons.info_outline_rounded,
                      color: _selectedAnswerIndex == q.bestResponseIndex
                          ? Colors.green.shade800
                          : Colors.orange.shade800,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _selectedAnswerIndex == q.bestResponseIndex
                          ? 'Отличный ответ сабры!'
                          : 'Есть вариант получше:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _selectedAnswerIndex == q.bestResponseIndex
                            ? Colors.green.shade900
                            : Colors.orange.shade900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  q.explanationRu,
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
              onPressed: _currentQuestionIndex > 0 ? _goToPreviousQuestion : null,
            ),
            FilledButton.icon(
              icon: const Icon(Icons.arrow_forward_rounded),
              label: Text(
                _currentQuestionIndex < questions.length - 1
                    ? 'Следующий'
                    : 'Завершить',
              ),
              onPressed: _currentQuestionIndex < questions.length - 1
                  ? _goToNextQuestion
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 2: Payslip Inspector
  // ---------------------------------------------------------------------------
  Widget _buildPayslipTab(ThemeData theme) {
    // Quick calculation approximation for the slider
    final double gross = _simulatorGrossSalary;
    final double pensionEmployee = gross * 0.06;
    final double kerenEmployee = (gross > 15712 ? 15712 : gross) * 0.025;
    final double bituachLeumi = gross * 0.07; // average effective rate
    final double estimatedIncomeTax = (gross * 0.12) - 1270.50; // with Olim points
    final double taxClean = estimatedIncomeTax < 0 ? 0 : estimatedIncomeTax;
    final double totalEstimatedDeductions =
        pensionEmployee + kerenEmployee + bituachLeumi + taxClean;
    final double estimatedNet = gross - totalEstimatedDeductions;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // Realistic Payslip Inspector Card
        PayslipInspectorCard(
          payslip: CareerSeedData.sampleHighTechPayslip,
          audioService: widget.audioService,
          addCardToSrsUseCase: widget.addCardToSrsUseCase,
        ),

        const SizedBox(height: 12),

        // Interactive Gross -> Net Estimator Card
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
                    const Icon(Icons.calculate_rounded, color: Colors.teal),
                    const SizedBox(width: 8),
                    Text(
                      'Симулятор: Брутто ➔ Чистыми на руки',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Примерный расчет для нового репатрианта (5.25 льготных баллов, пенсионный фонд и керен иштальмут).',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Оклад брутто:'),
                    Text(
                      '₪${gross.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _simulatorGrossSalary,
                  min: 10000,
                  max: 50000,
                  divisions: 40,
                  label: '₪${_simulatorGrossSalary.toStringAsFixed(0)}',
                  onChanged: (val) {
                    setState(() => _simulatorGrossSalary = val);
                  },
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Все вычеты (налоги + фонды):',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            '-₪${totalEstimatedDeductions.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Примерное нетто в банк:',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            '₪${estimatedNet.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 3: Career & High-Tech Glossary
  // ---------------------------------------------------------------------------
  Widget _buildGlossaryTab(ThemeData theme) {
    final query = _glossarySearchQuery.trim().toLowerCase();
    final items = CareerSeedData.careerGlossary.where((item) {
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
              hintText: 'Поиск по словарю (тлуш, брутто, стендап...)',
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
                                        id: 'career_${plain.hashCode}',
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
