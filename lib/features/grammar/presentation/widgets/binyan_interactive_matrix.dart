import 'package:flutter/material.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../conversation/domain/entities/binyan.dart';
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

/// Interactive 7 Binyanim architectural matrix and root transformation explorer.
class BinyanInteractiveMatrix extends StatefulWidget {
  final List<VerbLexeme> allVerbs;
  final bool showNikkud;
  final AudioPlaybackService? audioService;
  final ValueChanged<VerbLexeme>? onSelectVerb;

  const BinyanInteractiveMatrix({
    super.key,
    required this.allVerbs,
    required this.showNikkud,
    this.audioService,
    this.onSelectVerb,
  });

  @override
  State<BinyanInteractiveMatrix> createState() => _BinyanInteractiveMatrixState();
}

class _BinyanInteractiveMatrixState extends State<BinyanInteractiveMatrix> {
  int _selectedTabIndex = 0; // 0: Атлас 7 биньянов, 1: Путешествие корней
  String? _selectedRootFilter;

  @override
  void initState() {
    super.initState();
    // Default root filter to a rich multi-binyan root if available
    final commonRoots = _extractCommonRoots();
    if (commonRoots.isNotEmpty) {
      _selectedRootFilter = commonRoots.first;
    }
  }

  List<String> _extractCommonRoots() {
    final rootCounts = <String, int>{};
    for (final verb in widget.allVerbs) {
      final key = verb.root.hyphenated;
      rootCounts[key] = (rootCounts[key] ?? 0) + 1;
    }
    // Sort roots with most verbs first
    final sorted = rootCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.map((e) => e.key).toList(growable: false);
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
                icon: Icon(Icons.hub_outlined),
                label: Text('Трансформация корня'),
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
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(
                          info.hebrewPattern,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onPrimaryContainer,
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
                              color: theme.colorScheme.primary,
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
                      const SizedBox(width: 8),
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
    final commonRoots = _extractCommonRoots();

    if (commonRoots.isEmpty) {
      return Center(
        child: Text(
          'Список корней пока пуст.',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    final activeRoot = _selectedRootFilter ?? commonRoots.first;
    final matchingVerbs = widget.allVerbs
        .where((v) => v.root.hyphenated == activeRoot)
        .toList(growable: false);

    return ListView(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 24),
      children: [
        Text(
          'Выберите корень (שורש):',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: commonRoots.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, idx) {
              final root = commonRoots[idx];
              final isSelected = root == activeRoot;
              return ChoiceChip(
                label: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    root,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                selected: isSelected,
                onSelected: (_) {
                  setState(() {
                    _selectedRootFilter = root;
                  });
                },
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: theme.colorScheme.secondary.withValues(alpha: 0.3),
            ),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Превращения корня:',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        activeRoot,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Один и тот же корень в разных биньянах меняет смысл от базового действия до пассива или взаимности:',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                if (matchingVerbs.isEmpty)
                  Text(
                    'Для этого корня в текущей выборке нет глаголов.',
                    style: theme.textTheme.bodySmall,
                  )
                else
                  ...matchingVerbs.map(
                    (verb) => _RootVerbTile(
                      verb: verb,
                      showNikkud: widget.showNikkud,
                      onTap: widget.onSelectVerb == null
                          ? null
                          : () => widget.onSelectVerb!(verb),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RootVerbTile extends StatelessWidget {
  const _RootVerbTile({
    required this.verb,
    required this.showNikkud,
    this.onTap,
  });

  final VerbLexeme verb;
  final bool showNikkud;
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  verb.russianMeaning,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
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
          if (onTap != null) ...[
            const SizedBox(width: 4),
            IconButton(
              tooltip: 'Открыть спряжение',
              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onPressed: onTap,
            ),
          ],
        ],
      ),
    );
  }
}
