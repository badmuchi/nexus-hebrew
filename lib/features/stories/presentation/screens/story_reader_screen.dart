import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../dictionary/domain/entities/dictionary_entry.dart';
import '../../../dictionary/presentation/cubit/dictionary_cubit.dart';
import '../../../dictionary/presentation/cubit/dictionary_state.dart';
import '../../../grammar/domain/entities/verb_conjugation.dart';
import '../../../grammar/presentation/cubit/grammar_cubit.dart';
import '../../../grammar/presentation/cubit/grammar_state.dart';
import '../../../morphology/presentation/widgets/sentence_xray_sheet.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../domain/entities/story.dart';
import '../cubit/stories_cubit.dart';
import '../cubit/stories_state.dart';
import '../widgets/story_word_bottom_sheet.dart';

class StoryReaderScreen extends StatelessWidget {
  const StoryReaderScreen({
    super.key,
    required this.story,
    required this.audioService,
    required this.addCardToSrsUseCase,
  });

  final Story story;
  final AudioPlaybackService audioService;
  final AddCardToSrsUseCase addCardToSrsUseCase;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StoriesCubit, StoriesState>(
      listenWhen: (prev, curr) =>
          curr is StoriesLoaded &&
          curr.transientNotice != null &&
          (prev is! StoriesLoaded ||
              prev.transientNotice != curr.transientNotice),
      listener: (context, state) {
        if (state is StoriesLoaded && state.transientNotice != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(state.transientNotice!)),
            );
          context.read<StoriesCubit>().clearTransientNotice();
        }
      },
      builder: (context, state) {
        final cubit = context.read<StoriesCubit>();
        final loaded = state is StoriesLoaded ? state : null;
        final showNikkud = loaded?.showNikkud ?? true;
        final showTranslation = loaded?.showTranslation ?? true;
        final fontDelta = loaded?.fontSizeDelta ?? 0.0;
        final playingSentenceId = loaded?.playingSentenceId;
        final isPlayingStory = loaded?.isPlayingStory ?? false;
        final isCompleted =
            loaded?.completedStoryIds.contains(story.id) ?? false;
        final srsForms = loaded?.srsNormalizedForms ?? const <String>{};
        final playbackSpeed = loaded?.playbackSpeed ?? 1.0;

        final dictState = context.watch<DictionaryCubit>().state;
        final allDictEntries = dictState is DictionaryLoaded
            ? dictState.allEntries
            : const <DictionaryEntry>[];

        final grammarState = context.watch<GrammarCubit>().state;
        final allVerbs = grammarState is GrammarLoaded
            ? grammarState.verbs
            : const <VerbLexeme>[];

        final theme = Theme.of(context);

        return PopScope(
          onPopInvokedWithResult: (didPop, result) {
            unawaited(cubit.stopAudio());
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(story.titleRussian),
              actions: [
                IconButton(
                  icon: Icon(
                    showNikkud
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                  ),
                  tooltip: showNikkud
                      ? 'Скрыть огласовки (некудот)'
                      : 'Показать огласовки (некудот)',
                  onPressed: cubit.toggleNikkud,
                ),
                IconButton(
                  icon: Icon(
                    showTranslation
                        ? Icons.subtitles_rounded
                        : Icons.subtitles_off_rounded,
                  ),
                  tooltip: showTranslation
                      ? 'Скрыть русский перевод'
                      : 'Показать русский перевод',
                  onPressed: cubit.toggleTranslation,
                ),
                PopupMenuButton<double>(
                  icon: const Icon(Icons.format_size_rounded),
                  tooltip: 'Размер шрифта',
                  onSelected: (delta) => cubit.adjustFontSize(delta),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 2.0,
                      child: Text('Увеличить шрифт (A+)'),
                    ),
                    const PopupMenuItem(
                      value: -2.0,
                      child: Text('Уменьшить шрифт (A-)'),
                    ),
                  ],
                ),
              ],
            ),
            body: Column(
              children: [
                // Top Audio Controls Bar
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  color: theme.colorScheme.surfaceContainer,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          story.level,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Directionality(
                          textDirection: TextDirection.rtl,
                          child: Text(
                            showNikkud
                                ? story.titleHebrew.vocalized
                                : story.titleHebrew.normalized,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      PopupMenuButton<double>(
                        tooltip: 'Скорость воспроизведения',
                        initialValue: playbackSpeed,
                        onSelected: (speed) => cubit.setPlaybackSpeed(speed),
                        itemBuilder: (context) => [
                          _buildSpeedMenuItem(
                            context,
                            0.75,
                            '0.75x — Медленно',
                            playbackSpeed,
                          ),
                          _buildSpeedMenuItem(
                            context,
                            0.85,
                            '0.85x — Умеренно',
                            playbackSpeed,
                          ),
                          _buildSpeedMenuItem(
                            context,
                            1.0,
                            '1.0x — Обычная',
                            playbackSpeed,
                          ),
                          _buildSpeedMenuItem(
                            context,
                            1.25,
                            '1.25x — Быстро',
                            playbackSpeed,
                          ),
                        ],
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: theme.colorScheme.outlineVariant
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.speed_rounded,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${playbackSpeed == 1.0 ? "1.0" : playbackSpeed.toString()}x',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.tonalIcon(
                        icon: Icon(
                          isPlayingStory
                              ? Icons.stop_rounded
                              : Icons.play_arrow_rounded,
                        ),
                        label: Text(
                          isPlayingStory ? 'Стоп' : 'Слушать рассказ',
                        ),
                        onPressed: () => cubit.playFullStory(story),
                      ),
                    ],
                  ),
                ),
                // Reader Content
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    children: [
                      if (story.level == 'FSRS Smart') ...[
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.amber.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text('🪄', style: TextStyle(fontSize: 20)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Адаптивный контекстный тренажер',
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: theme.brightness == Brightness.dark
                                            ? Colors.amber.shade200
                                            : Colors.amber.shade900,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Трудные слова FSRS выделены волнистой линией. Нажмите на любое слово для перевода и озвучки.',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      for (final paragraph in story.paragraphs)
                        Card(
                          elevation: 0,
                          margin: const EdgeInsetsDirectional.only(bottom: 16),
                          color: theme.colorScheme.surfaceContainerLow,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: theme.colorScheme.outlineVariant,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                for (final sentence in paragraph.sentences) ...[
                                  _SentenceView(
                                    sentence: sentence,
                                    showNikkud: showNikkud,
                                    showTranslation: showTranslation,
                                    fontDelta: fontDelta,
                                    isPlaying:
                                        playingSentenceId == sentence.id,
                                    srsForms: srsForms,
                                    allDictEntries: allDictEntries,
                                    allVerbs: allVerbs,
                                    audioService: audioService,
                                    addCardToSrsUseCase: addCardToSrsUseCase,
                                    onPlaySentence: () =>
                                        cubit.playSentence(sentence),
                                    onWordAddedToSrs: cubit.refreshSrsStatus,
                                  ),
                                  if (sentence != paragraph.sentences.last)
                                    const Divider(height: 24),
                                ],
                              ],
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                          top: 16,
                          bottom: 40,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FilledButton.icon(
                                icon: Icon(
                                  isCompleted
                                      ? Icons.check_circle_rounded
                                      : Icons.done_all_rounded,
                                ),
                                label: Text(
                                  isCompleted
                                      ? 'Прочитано!'
                                      : 'Я прочитал этот рассказ',
                                ),
                                onPressed: isCompleted
                                    ? null
                                    : () => cubit.markCompleted(story.id),
                              ),
                              if (story.level == 'FSRS Smart') ...[
                                const SizedBox(height: 10),
                                Text(
                                  'Слова закреплены в долговременной памяти 🎉',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
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
              ],
            ),
          ),
        );
      },
    );
  }

  PopupMenuItem<double> _buildSpeedMenuItem(
    BuildContext context,
    double speed,
    String label,
    double currentSpeed,
  ) {
    final theme = Theme.of(context);
    final isSelected = (currentSpeed - speed).abs() < 0.01;
    return PopupMenuItem<double>(
      value: speed,
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.check_rounded : Icons.speed_rounded,
            size: 18,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              color: isSelected ? theme.colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _SentenceView extends StatelessWidget {
  const _SentenceView({
    required this.sentence,
    required this.showNikkud,
    required this.showTranslation,
    required this.fontDelta,
    required this.isPlaying,
    required this.srsForms,
    required this.allDictEntries,
    required this.allVerbs,
    required this.audioService,
    required this.addCardToSrsUseCase,
    required this.onPlaySentence,
    required this.onWordAddedToSrs,
  });

  final StorySentence sentence;
  final bool showNikkud;
  final bool showTranslation;
  final double fontDelta;
  final bool isPlaying;
  final Set<String> srsForms;
  final List<DictionaryEntry> allDictEntries;
  final List<VerbLexeme> allVerbs;
  final AudioPlaybackService audioService;
  final AddCardToSrsUseCase addCardToSrsUseCase;
  final VoidCallback onPlaySentence;
  final VoidCallback onWordAddedToSrs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isPlaying
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.38)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  isPlaying
                      ? Icons.volume_up_rounded
                      : Icons.volume_down_rounded,
                  size: 20,
                  color: isPlaying
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                tooltip: 'Озвучить предложение',
                onPressed: onPlaySentence,
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(
                  Icons.biotech_rounded,
                  size: 20,
                  color: Colors.teal,
                ),
                tooltip: 'Рентген фразы 🔬',
                onPressed: () => unawaited(
                  SentenceXRaySheet.show(
                    context,
                    sentenceHebrew: sentence.hebrewVocalized,
                    sentenceRussian: sentence.russianTranslation,
                    allDictionaryEntries: allDictEntries,
                    allGrammarVerbs: allVerbs,
                    srsNormalizedForms: srsForms,
                    audioService: audioService,
                    addCardToSrsUseCase: addCardToSrsUseCase,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 6,
                    children: [
                      for (final token in sentence.tokens)
                        _WordTokenChip(
                          token: token,
                          sentence: sentence,
                          showNikkud: showNikkud,
                          fontDelta: fontDelta,
                          isInSrs: srsForms.contains(token.wordNormalized),
                          allDictEntries: allDictEntries,
                          allVerbs: allVerbs,
                          srsForms: srsForms,
                          audioService: audioService,
                          addCardToSrsUseCase: addCardToSrsUseCase,
                          onWordAddedToSrs: onWordAddedToSrs,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (showTranslation) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 44),
              child: Text(
                sentence.russianTranslation,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                  fontSize: 13.5 + (fontDelta * 0.5),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WordTokenChip extends StatelessWidget {
  const _WordTokenChip({
    required this.token,
    required this.sentence,
    required this.showNikkud,
    required this.fontDelta,
    required this.isInSrs,
    required this.allDictEntries,
    required this.allVerbs,
    required this.srsForms,
    required this.audioService,
    required this.addCardToSrsUseCase,
    required this.onWordAddedToSrs,
  });

  final StoryWordToken token;
  final StorySentence sentence;
  final bool showNikkud;
  final double fontDelta;
  final bool isInSrs;
  final List<DictionaryEntry> allDictEntries;
  final List<VerbLexeme> allVerbs;
  final Set<String> srsForms;
  final AudioPlaybackService audioService;
  final AddCardToSrsUseCase addCardToSrsUseCase;
  final VoidCallback onWordAddedToSrs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final text = showNikkud ? token.wordVocalized : token.wordNormalized;
    final isWeakWord = token.category == 'weak_word_practice';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () {
          showStoryWordBottomSheet(
            context: context,
            token: token,
            sentence: sentence,
            isInSrs: isInSrs,
            audioService: audioService,
            addCardToSrsUseCase: addCardToSrsUseCase,
            allDictionaryEntries: allDictEntries,
            allGrammarVerbs: allVerbs,
            srsNormalizedForms: srsForms,
            onWordAddedToSrs: onWordAddedToSrs,
          );
        },
        child: Container(
          decoration: isWeakWord
              ? BoxDecoration(
                  color: (isDark ? Colors.amber.shade700 : Colors.amber.shade200)
                      .withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: (isDark ? Colors.amber.shade400 : Colors.amber.shade800)
                        .withValues(alpha: 0.35),
                  ),
                )
              : null,
          padding: EdgeInsets.symmetric(
            horizontal: isWeakWord ? 5 : 3,
            vertical: isWeakWord ? 3 : 2,
          ),
          child: Text(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 18.0 + fontDelta,
              fontWeight: isWeakWord ? FontWeight.w700 : FontWeight.w600,
              height: 1.5,
              color: isWeakWord
                  ? (isDark ? Colors.amber.shade300 : Colors.amber.shade900)
                  : null,
              decoration: isWeakWord
                  ? TextDecoration.underline
                  : (isInSrs ? TextDecoration.underline : TextDecoration.none),
              decorationColor: isWeakWord
                  ? (isDark ? Colors.amber.shade400 : Colors.amber.shade800)
                  : theme.colorScheme.primary,
              decorationStyle: isWeakWord
                  ? TextDecorationStyle.wavy
                  : TextDecorationStyle.solid,
            ),
          ),
        ),
      ),
    );
  }
}
