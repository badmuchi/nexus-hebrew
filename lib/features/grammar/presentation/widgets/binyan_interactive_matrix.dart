import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../conversation/domain/entities/binyan.dart';
import '../../../srs/domain/entities/srs_card.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../domain/entities/root_matrix_paradigm.dart';
import '../../domain/entities/verb_conjugation.dart';

/// Educational meta-information about one of the 7 Hebrew binyanim.
class BinyanMetaInfo {
  final Binyan binyan;
  final String hebrewPattern;
  final String transliteration;
  final String actionTypeRu;
  final String descriptionRu;
  final String exampleHebrew;
  final String exampleRu;
  final Binyan? passiveCounterpart;

  const BinyanMetaInfo({
    required this.binyan,
    required this.hebrewPattern,
    required this.transliteration,
    required this.actionTypeRu,
    required this.descriptionRu,
    required this.exampleHebrew,
    required this.exampleRu,
    this.passiveCounterpart,
  });

  static const List<BinyanMetaInfo> catalog = [
    BinyanMetaInfo(
      binyan: Binyan.paal,
      hebrewPattern: 'פָּעַל',
      transliteration: "Pa'al (Qal)",
      actionTypeRu: 'Базовое действие (актив)',
      descriptionRu:
          'Самый распространённый биньян. Простое первичное действие без дополнительных оттенков.',
      exampleHebrew: 'כָּתַב (לִכְתֹּב)',
      exampleRu: 'писал (писать)',
      passiveCounterpart: Binyan.nifal,
    ),
    BinyanMetaInfo(
      binyan: Binyan.nifal,
      hebrewPattern: 'נִפְעַל',
      transliteration: "Nif'al",
      actionTypeRu: 'Пассив Пааля / вход в состояние',
      descriptionRu:
          'Пассивное действие к Паалю («был написан») или переход в состояние / действие само по себе («вошёл»).',
      exampleHebrew: 'נִכְתַּב (לְהִכָּתֵב)',
      exampleRu: 'был написан (писаться)',
      passiveCounterpart: null,
    ),
    BinyanMetaInfo(
      binyan: Binyan.piel,
      hebrewPattern: 'פִּעֵל',
      transliteration: "Pi'el",
      actionTypeRu: 'Интенсивное / целевое действие',
      descriptionRu:
          'Активное действие с оттенком целенаправленности, обучения, профессиональной деятельности или каузатива.',
      exampleHebrew: 'לִמֵּד (לְלַמֵּד)',
      exampleRu: 'обучал (обучать / учить кого-то)',
      passiveCounterpart: Binyan.pual,
    ),
    BinyanMetaInfo(
      binyan: Binyan.pual,
      hebrewPattern: 'פֻּעַל',
      transliteration: "Pu'al",
      actionTypeRu: 'Пассив Пиэля (без инфинитива)',
      descriptionRu:
          'Чистый пассив к действию Пиэля. В современном языке не имеет активного инфинитива.',
      exampleHebrew: 'לֻמַּד',
      exampleRu: 'был обучен',
      passiveCounterpart: null,
    ),
    BinyanMetaInfo(
      binyan: Binyan.hifil,
      hebrewPattern: 'הִפְעִיל',
      transliteration: "Hif'il",
      actionTypeRu: 'Каузатив / побуждение к действию',
      descriptionRu:
          'Побуждение кого-то или чего-то к действию: «заставить писать» → диктовать, «заставить гореть» → зажечь.',
      exampleHebrew: 'הִכְתִּיב (לְהַכְתִּיב)',
      exampleRu: 'диктовал (диктовать)',
      passiveCounterpart: Binyan.hufal,
    ),
    BinyanMetaInfo(
      binyan: Binyan.hufal,
      hebrewPattern: 'הֻפְעַל',
      transliteration: "Huf'al",
      actionTypeRu: 'Пассив Ифъиля (без инфинитива)',
      descriptionRu:
          'Пассивное состояние в результате каузативного действия Ифъиля. Без инфинитива.',
      exampleHebrew: 'הֻכְתַּב',
      exampleRu: 'был продиктован',
      passiveCounterpart: null,
    ),
    BinyanMetaInfo(
      binyan: Binyan.hitpael,
      hebrewPattern: 'הִתְפַּעֵל',
      transliteration: "Hitpa'el",
      actionTypeRu: 'Возвратное / взаимное действие',
      descriptionRu:
          'Действие, направленное на себя (одеваться), между собой (переписываться) или изображение состояния.',
      exampleHebrew: 'הִתְכַּתֵּב (לְהִתְכַּתֵּב)',
      exampleRu: 'переписывался (переписываться)',
      passiveCounterpart: null,
    ),
  ];
}

/// Interactive 7 Binyanim architectural matrix and live root transformation explorer.
class BinyanInteractiveMatrix extends StatefulWidget {
  final List<VerbLexeme> allVerbs;
  final bool showNikkud;
  final AudioPlaybackService? audioService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;
  final ValueChanged<VerbLexeme>? onSelectVerb;

  const BinyanInteractiveMatrix({
    super.key,
    required this.allVerbs,
    required this.showNikkud,
    this.audioService,
    this.addCardToSrsUseCase,
    this.onSelectVerb,
  });

  @override
  State<BinyanInteractiveMatrix> createState() => _BinyanInteractiveMatrixState();
}

class _BinyanInteractiveMatrixState extends State<BinyanInteractiveMatrix> {
  int _selectedTabIndex = 0; // 0: Атлас 7 биньянов, 1: Трансформатор корней
  String? _selectedRootFilter;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedRootFilter = 'כ-ת-ב';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _speak(String text) {
    widget.audioService?.playWithTtsFallback(
      sourcePath: null,
      fallbackHebrewText: text,
    );
  }

  Future<void> _addToSrs({
    required BuildContext context,
    required String frontRussian,
    required String backHebrew,
    String? exampleHebrew,
    String? exampleRussian,
  }) async {
    final useCase = widget.addCardToSrsUseCase;
    if (useCase == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('FSRS сервис недоступен')),
      );
      return;
    }

    final params = AddCardToSrsParams(
      id: 'root_${DateTime.now().microsecondsSinceEpoch}',
      hebrewVocalized: backHebrew,
      russianTranslation: frontRussian,
      exampleHebrewVocalized: exampleHebrew,
      exampleRussian: exampleRussian,
      category: LexicalCategory.verb,
    );

    final res = await useCase.call(params);
    if (!context.mounted) return;
    final isSuccess = res.getOrNull() == true;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isSuccess
              ? '✅ Добавлено в FSRS: $backHebrew — $frontRussian'
              : 'Слово уже есть в вашей колоде повторений',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 8),
          child: SegmentedButton<int>(
            segments: const [
              ButtonSegment<int>(
                value: 0,
                icon: Icon(Icons.architecture_rounded),
                label: Text('7 Биньянов'),
              ),
              ButtonSegment<int>(
                value: 1,
                icon: Icon(Icons.hub_rounded),
                label: Text('Матрица корней'),
              ),
            ],
            selected: {_selectedTabIndex},
            onSelectionChanged: (Set<int> newSet) {
              setState(() {
                _selectedTabIndex = newSet.first;
              });
            },
          ),
        ),
        Expanded(
          child: _selectedTabIndex == 0
              ? _buildBinyanimAtlas(theme)
              : _buildRootTransformationLab(theme),
        ),
      ],
    );
  }

  Widget _buildBinyanimAtlas(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 24),
      itemCount: BinyanMetaInfo.catalog.length,
      itemBuilder: (context, index) {
        final info = BinyanMetaInfo.catalog[index];
        final verbsInBinyan = widget.allVerbs
            .where((v) => v.binyan == info.binyan)
            .toList(growable: false);

        return Card(
          elevation: 0,
          margin: const EdgeInsetsDirectional.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _binyanColor(info.binyan).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(
                          info.hebrewPattern,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: _binyanColor(info.binyan),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            info.transliteration,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            info.actionTypeRu,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: _binyanColor(info.binyan),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (verbsInBinyan.isNotEmpty)
                      Badge(
                        label: Text('${verbsInBinyan.length}'),
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        textColor: theme.colorScheme.onSurfaceVariant,
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  info.descriptionRu,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsetsDirectional.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb_outline_rounded, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Directionality(
                          textDirection: TextDirection.rtl,
                          child: Text(
                            info.exampleHebrew,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up_rounded, size: 20),
                        tooltip: 'Озвучить пример',
                        onPressed: () => _speak(info.exampleHebrew),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        info.exampleRu,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRootTransformationLab(ThemeData theme) {
    final query = _searchController.text.trim().toLowerCase();

    // Filter curated paradigms
    final curatedList = RootMatrixParadigm.curatedCatalog.where((p) {
      if (query.isEmpty) return true;
      return p.root.contains(query) ||
          p.rootLetters.contains(query) ||
          p.baseMeaningRu.toLowerCase().contains(query) ||
          p.forms.any((f) =>
              f.translationRu.toLowerCase().contains(query) ||
              f.transliteration.toLowerCase().contains(query));
    }).toList(growable: false);

    final selectedParadigm = RootMatrixParadigm.curatedCatalog.firstWhere(
      (p) => p.root == _selectedRootFilter,
      orElse: () => curatedList.isNotEmpty
          ? curatedList.first
          : RootMatrixParadigm.curatedCatalog.first,
    );

    // Matching verbs from database
    final dbVerbs = widget.allVerbs
        .where((v) =>
            v.root.hyphenated == selectedParadigm.root ||
            v.root.compact == selectedParadigm.rootLetters)
        .toList(growable: false);

    return ListView(
      key: const ValueKey('root_matrix_list'),
      padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 24),
      children: [
        // Search bar
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Поиск корня (например, כתב, שמר, учить, закрыть)...',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  )
                : null,
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),

        Text(
          'Популярные корни (שורש):',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),

        // Horizontal chips of roots
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: curatedList.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, idx) {
              final paradigm = curatedList[idx];
              final isSelected = paradigm.root == selectedParadigm.root;
              return ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        paradigm.root,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '· ${paradigm.forms.length}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
                selected: isSelected,
                onSelected: (_) {
                  setState(() {
                    _selectedRootFilter = paradigm.root;
                  });
                },
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        // Header Card for Active Root
        Card(
          elevation: 0,
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Корень (שורש):',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            selectedParadigm.baseMeaningRu,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(
                          selectedParadigm.root,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  selectedParadigm.culturalNoteRu,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Трансформация по Биньянам:',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              '${selectedParadigm.forms.length} пород',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Forms List
        ...selectedParadigm.forms.map((form) {
          final color = _binyanColor(form.binyan);
          final displayedHebrew = widget.showNikkud ? form.vocalized : form.normalized;

          return Card(
            elevation: 0,
            margin: const EdgeInsetsDirectional.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: color.withValues(alpha: 0.25)),
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          form.binyan.transliteration,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          form.nuanceRu,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Озвучить (TTS)',
                        icon: const Icon(Icons.volume_up_rounded, size: 20),
                        color: theme.colorScheme.primary,
                        onPressed: () => _speak(form.vocalized),
                      ),
                      IconButton(
                        tooltip: 'Добавить в FSRS',
                        icon: const Icon(Icons.bookmark_add_outlined, size: 20),
                        color: theme.colorScheme.secondary,
                        onPressed: () => _addToSrs(
                          context: context,
                          frontRussian: form.translationRu,
                          backHebrew: form.vocalized,
                          exampleHebrew: form.exampleHebrew,
                          exampleRussian: form.exampleRu,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              form.translationRu,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              form.transliteration,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(
                          displayedHebrew,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Example container
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Directionality(
                                textDirection: TextDirection.rtl,
                                child: Text(
                                  form.exampleHebrew,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text(
                                form.exampleRu,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Озвучить пример',
                          icon: const Icon(Icons.volume_up_outlined, size: 18),
                          onPressed: () => _speak(form.exampleHebrew),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),

        if (dbVerbs.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Спряжения из словаря базы данных:',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...dbVerbs.map(
            (verb) => _RootVerbTile(
              verb: verb,
              showNikkud: widget.showNikkud,
              audioService: widget.audioService,
              onTap: widget.onSelectVerb == null
                  ? null
                  : () => widget.onSelectVerb!(verb),
            ),
          ),
        ],
      ],
    );
  }

  static Color _binyanColor(Binyan binyan) {
    return switch (binyan) {
      Binyan.paal => const Color(0xFF1976D2), // Blue
      Binyan.nifal => const Color(0xFF00897B), // Teal
      Binyan.piel => const Color(0xFF7B1FA2), // Purple
      Binyan.pual => const Color(0xFF512DA8), // Deep purple
      Binyan.hitpael => const Color(0xFFF57C00), // Orange
      Binyan.hifil => const Color(0xFF283593), // Indigo
      Binyan.hufal => const Color(0xFF455A64), // Blue-grey
      Binyan.none => Colors.grey,
    };
  }
}

class _RootVerbTile extends StatelessWidget {
  const _RootVerbTile({
    required this.verb,
    required this.showNikkud,
    this.audioService,
    this.onTap,
  });

  final VerbLexeme verb;
  final bool showNikkud;
  final AudioPlaybackService? audioService;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayedHebrew = showNikkud
        ? (verb.infinitive?.vocalized ?? verb.lemma.vocalized)
        : (verb.infinitive?.normalized ?? verb.lemma.normalized);

    return Container(
      margin: const EdgeInsetsDirectional.only(bottom: 8),
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              verb.binyan.transliteration,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              verb.russianMeaning,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              displayedHebrew,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          if (audioService != null)
            IconButton(
              tooltip: 'Озвучить (TTS)',
              icon: const Icon(Icons.volume_up_rounded, size: 18),
              onPressed: () => audioService!.playWithTtsFallback(
                sourcePath: null,
                fallbackHebrewText: displayedHebrew,
              ),
            ),
          if (onTap != null)
            IconButton(
              tooltip: 'Открыть спряжение',
              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onPressed: onTap,
            ),
        ],
      ),
    );
  }
}
