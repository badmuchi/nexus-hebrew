import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../alphabet/presentation/screens/alphabet_screen.dart';
import '../../../conversation/domain/entities/binyan.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../domain/entities/verb_conjugation.dart';
import '../cubit/grammar_cubit.dart';
import '../cubit/grammar_state.dart';
import '../widgets/conjugation_table_widget.dart';
import '../widgets/preposition_inflection_view.dart';
import '../widgets/sentence_builder_view.dart';

/// Grammar workspace covering all 7 Hebrew binyanim, shoresh search, and conjugation drill.
class GrammarScreen extends StatefulWidget {
  final AudioPlaybackService? audioService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;

  const GrammarScreen({
    super.key,
    this.audioService,
    this.addCardToSrsUseCase,
  });

  @override
  State<GrammarScreen> createState() => _GrammarScreenState();
}

class _GrammarScreenState extends State<GrammarScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _drillController = TextEditingController();
  int _grammarModeIndex = 0; // 0: Биньяны, 1: Предлоги

  @override
  void dispose() {
    _searchController.dispose();
    _drillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String appBarTitle = switch (_grammarModeIndex) {
      1 => 'Грамматика · Предлоги',
      2 => 'Грамматика · Синтаксис',
      _ => 'Грамматика · Биньяны',
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        actions: [
          IconButton(
            tooltip: 'Алеф-Бет, прописи и никуд',
            icon: const Icon(Icons.spellcheck_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => AlphabetScreen(
                  audioService: widget.audioService,
                  addCardToSrsUseCase: widget.addCardToSrsUseCase,
                ),
              ),
            ),
          ),
          BlocBuilder<GrammarCubit, GrammarState>(
            builder: (BuildContext context, GrammarState state) {
              final showNikkud =
                  state is GrammarLoaded ? state.showNikkud : true;
              return Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: FilterChip(
                  label: const Text('Огласовки'),
                  selected: showNikkud,
                  onSelected: state is GrammarLoaded
                      ? (_) => context.read<GrammarCubit>().toggleNikkud()
                      : null,
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 8),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment<int>(
                  value: 0,
                  icon: Icon(Icons.account_tree_outlined),
                  label: Text('Биньяны'),
                ),
                ButtonSegment<int>(
                  value: 1,
                  icon: Icon(Icons.link_rounded),
                  label: Text('Предлоги'),
                ),
                ButtonSegment<int>(
                  value: 2,
                  icon: Icon(Icons.extension_outlined),
                  label: Text('Синтаксис'),
                ),
              ],
              selected: {_grammarModeIndex},
              onSelectionChanged: (Set<int> newSelection) {
                setState(() {
                  _grammarModeIndex = newSelection.first;
                });
              },
            ),
          ),
        ),
      ),
      body: BlocConsumer<GrammarCubit, GrammarState>(
        listenWhen: (GrammarState prev, GrammarState curr) =>
            curr is GrammarLoaded && curr.transientNotice != null,
        listener: (BuildContext context, GrammarState state) {
          if (state is GrammarLoaded && state.transientNotice != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.transientNotice!)),
            );
            context.read<GrammarCubit>().clearTransientNotice();
          }
        },
        builder: (BuildContext context, GrammarState state) {
          final showNikkud = state is GrammarLoaded ? state.showNikkud : true;
          if (_grammarModeIndex == 1) {
            return PrepositionInflectionView(
              audioService: widget.audioService,
              addCardToSrsUseCase: widget.addCardToSrsUseCase,
              showNikkud: showNikkud,
            );
          }
          if (_grammarModeIndex == 2) {
            return SentenceBuilderView(
              audioService: widget.audioService,
              addCardToSrsUseCase: widget.addCardToSrsUseCase,
              showNikkud: showNikkud,
            );
          }

          switch (state) {
            case GrammarInitial():
            case GrammarLoading():
              return const Center(child: CircularProgressIndicator());
            case GrammarError(:final failure):
              return _GrammarErrorView(
                message: failure.message,
                onRetry: () =>
                    unawaited(context.read<GrammarCubit>().loadVerbs()),
              );
            case GrammarLoaded():
              return _buildLoadedBody(context, theme, state);
          }
        },
      ),
    );
  }

  Widget _buildLoadedBody(
    BuildContext context,
    ThemeData theme,
    GrammarLoaded state,
  ) {
    final activeBinyanim = Binyan.values
        .where((Binyan b) => b != Binyan.none)
        .toList(growable: false);
    final selectedVerb = state.selectedVerb;

    return ListView(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 24),
      children: [
        Card(
          elevation: 0,
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: theme.colorScheme.primary.withValues(alpha: 0.25),
            ),
          ),
          child: InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => AlphabetScreen(
                  audioService: widget.audioService,
                  addCardToSrsUseCase: widget.addCardToSrsUseCase,
                ),
              ),
            ),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsetsDirectional.all(14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'א',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.25,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Алеф-Бет · Прописи · Никуд',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '22 буквы + 5 софитов, ктав яд, огласовки и гематрия',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Поиск по корню (כ-ת-ב), глаголу или значению...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: state.searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      unawaited(context.read<GrammarCubit>().search(''));
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onChanged: (String value) =>
              unawaited(context.read<GrammarCubit>().search(value)),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: ChoiceChip(
                  label: const Text('Все (7)'),
                  selected: state.selectedBinyan == null,
                  onSelected: (_) => unawaited(
                    context.read<GrammarCubit>().filterByBinyan(null),
                  ),
                ),
              ),
              ...activeBinyanim.map(
                (Binyan binyan) => Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: ChoiceChip(
                    label: Text('${binyan.hebrewLabel} · ${binyan.transliteration}'),
                    selected: state.selectedBinyan == binyan,
                    onSelected: (_) => unawaited(
                      context.read<GrammarCubit>().filterByBinyan(binyan),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (state.verbs.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsetsDirectional.all(20),
              child: Text(
                'По текущему фильтру глаголы не найдены.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          )
        else ...[
          SizedBox(
            height: 82,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: state.verbs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (BuildContext context, int index) {
                final verb = state.verbs[index];
                final isSelected = selectedVerb?.id == verb.id;
                final labelHebrew = state.showNikkud
                    ? (verb.infinitive?.vocalized ?? verb.lemma.vocalized)
                    : (verb.infinitive?.normalized ?? verb.lemma.normalized);
                return ChoiceChip(
                  selected: isSelected,
                  onSelected: (_) {
                    _drillController.clear();
                    context.read<GrammarCubit>().selectVerb(verb);
                  },
                  label: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(
                          labelHebrew,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        '${verb.russianMeaning} (${verb.root.hyphenated})',
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          if (selectedVerb != null) ...[
            _VerbSummaryCard(
              verb: selectedVerb,
              showNikkud: state.showNikkud,
              isSpeaking: state.activeSpokenHebrew ==
                      (selectedVerb.infinitive?.vocalized ??
                          selectedVerb.lemma.vocalized) &&
                  state.audioStatus == AudioPlaybackStatus.playing,
              onSpeakVerb: () {
                final text = selectedVerb.infinitive?.vocalized ??
                    selectedVerb.lemma.vocalized;
                unawaited(context.read<GrammarCubit>().speakHebrew(text));
              },
              onSaveVerbToSrs: () => unawaited(
                context.read<GrammarCubit>().saveVerbToSrs(selectedVerb),
              ),
            ),
            const SizedBox(height: 12),
            if (state.drillPrompt != null)
              _ConjugationDrillCard(
                verb: selectedVerb,
                prompt: state.drillPrompt!,
                showNikkud: state.showNikkud,
                controller: _drillController,
                checkResult: state.lastCheckResult,
                onCheck: () => unawaited(
                  context
                      .read<GrammarCubit>()
                      .checkDrillAnswer(_drillController.text),
                ),
                onNextPrompt: () {
                  _drillController.clear();
                  context.read<GrammarCubit>().nextDrillPrompt();
                },
              ),
            const SizedBox(height: 12),
            ConjugationTableWidget(
              verb: selectedVerb,
              selectedTense: state.selectedTense,
              showNikkud: state.showNikkud,
              activeSpokenHebrew: state.activeSpokenHebrew,
              audioStatus: state.audioStatus,
              onTenseChanged: (VerbTense tense) =>
                  context.read<GrammarCubit>().selectTense(tense),
              onSpeakForm: (String hebrew) =>
                  unawaited(context.read<GrammarCubit>().speakHebrew(hebrew)),
              onSaveFormToSrs: (ConjugatedForm form) => unawaited(
                context
                    .read<GrammarCubit>()
                    .saveConjugatedFormToSrs(selectedVerb, form),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Источник: ${selectedVerb.attribution.sourceName} (${selectedVerb.attribution.licenseName})',
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ],
    );
  }
}

class _VerbSummaryCard extends StatelessWidget {
  const _VerbSummaryCard({
    required this.verb,
    required this.showNikkud,
    required this.isSpeaking,
    required this.onSpeakVerb,
    required this.onSaveVerbToSrs,
  });

  final VerbLexeme verb;
  final bool showNikkud;
  final bool isSpeaking;
  final VoidCallback onSpeakVerb;
  final VoidCallback onSaveVerbToSrs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleHebrew = showNikkud
        ? (verb.infinitive?.vocalized ?? verb.lemma.vocalized)
        : (verb.infinitive?.normalized ?? verb.lemma.normalized);

    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(
                          titleHebrew,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${verb.russianMeaning} · Биньян ${verb.binyan.transliteration}',
                        style: theme.textTheme.titleSmall,
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: onSpeakVerb,
                  icon: Icon(isSpeaking ? Icons.stop : Icons.volume_up),
                  tooltip: 'Прослушать глагол',
                ),
                const SizedBox(width: 6),
                IconButton.outlined(
                  onPressed: onSaveVerbToSrs,
                  icon: const Icon(Icons.bookmark_add_outlined),
                  tooltip: 'Добавить глагол в FSRS',
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                Chip(
                  label: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text('Шореш: ${verb.root.hyphenated}'),
                  ),
                ),
                Chip(
                  label: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(verb.binyan.hebrewLabel),
                  ),
                ),
                if (verb.infinitive == null)
                  const Chip(
                    label: Text('Пассив · нет инфинитива'),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              verb.grammarNotesRu,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConjugationDrillCard extends StatelessWidget {
  const _ConjugationDrillCard({
    required this.verb,
    required this.prompt,
    required this.showNikkud,
    required this.controller,
    required this.checkResult,
    required this.onCheck,
    required this.onNextPrompt,
  });

  final VerbLexeme verb;
  final ConjugatedForm prompt;
  final bool showNikkud;
  final TextEditingController controller;
  final ConjugationCheckResult? checkResult;
  final VoidCallback onCheck;
  final VoidCallback onNextPrompt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final result = checkResult;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Тренажёр спряжения',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton.icon(
                  onPressed: onNextPrompt,
                  icon: const Icon(Icons.skip_next, size: 18),
                  label: const Text('Дальше'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Проспрягай «${verb.russianMeaning}» (${prompt.tense.russianLabel}):',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 6),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                '${prompt.person.hebrewPronoun} (${prompt.person.russianLabel})',
                textAlign: TextAlign.right,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Directionality(
              textDirection: TextDirection.rtl,
              child: TextField(
                controller: controller,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                decoration: const InputDecoration(
                  hintText: 'Введи форму на иврите (без огласовок)...',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => onCheck(),
              ),
            ),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: onCheck,
              child: const Text('Проверить форму'),
            ),
            if (result != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsetsDirectional.all(12),
                decoration: BoxDecoration(
                  color: result.isCorrect
                      ? Colors.green.withValues(alpha: 0.12)
                      : theme.colorScheme.errorContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.isCorrect ? 'Точно! Молодец!' : 'Пока мимо — проверь форму:',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: result.isCorrect
                            ? Colors.green.shade800
                            : theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        '${showNikkud ? result.expectedForm.vocalized : result.expectedForm.normalized} (${result.transliteration})',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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
}

class _GrammarErrorView extends StatelessWidget {
  const _GrammarErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 42),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }
}
