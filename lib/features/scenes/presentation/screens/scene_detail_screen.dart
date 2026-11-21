import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../../core/speech/speech_recognition_service.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../domain/entities/israeli_life_scene.dart';
import '../../domain/repositories/scenes_repository.dart';
import '../widgets/scene_challenge_card.dart';
import '../widgets/scene_phrase_tile.dart';
import '../widgets/scene_word_card.dart';

class SceneDetailScreen extends StatefulWidget {
  const SceneDetailScreen({
    super.key,
    required this.scene,
    required this.repository,
    this.audioService,
    this.speechService,
    this.addCardToSrsUseCase,
    this.onSceneCompleted,
  });

  final IsraeliLifeScene scene;
  final ScenesRepository repository;
  final AudioPlaybackService? audioService;
  final SpeechRecognitionService? speechService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;
  final VoidCallback? onSceneCompleted;

  @override
  State<SceneDetailScreen> createState() => _SceneDetailScreenState();
}

class _SceneDetailScreenState extends State<SceneDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showNikkud = true;

  final Map<int, bool> _challengeResults = {};
  bool _isSceneCompleted = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onAnswerSelected(int challengeIndex, bool isCorrect) {
    setState(() {
      _challengeResults[challengeIndex] = isCorrect;
    });

    if (_challengeResults.length == widget.scene.challenges.length && !_isSceneCompleted) {
      final allCorrect = _challengeResults.values.every((v) => v);
      if (allCorrect) {
        _markCompleted();
      }
    }
  }

  Future<void> _markCompleted() async {
    setState(() => _isSceneCompleted = true);

    await widget.repository.recordSceneCompletion(
      sceneId: widget.scene.id,
      wordsMasteredCount: widget.scene.words.length,
      challengeScore: widget.scene.challenges.length,
    );

    widget.onSceneCompleted?.call();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.celebration_rounded, color: Colors.amber),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Сцена «${widget.scene.titleRussian}» пройдена! +50 XP 🎉',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(widget.scene.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.scene.titleRussian,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.scene.cefrLevel,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          IconButton(
            tooltip: _showNikkud ? 'Огласовки включены' : 'Огласовки выключены',
            icon: Icon(
              _showNikkud ? Icons.spellcheck_rounded : Icons.abc_rounded,
              color: _showNikkud ? theme.colorScheme.primary : theme.colorScheme.outline,
            ),
            onPressed: () => setState(() => _showNikkud = !_showNikkud),
          ),
          const SizedBox(width: 6),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelPadding: const EdgeInsets.symmetric(horizontal: 14),
          tabs: [
            Tab(text: 'Словарь (${widget.scene.words.length})'),
            Tab(text: 'Фразы (${widget.scene.phrases.length})'),
            Tab(text: 'Ситуации (${widget.scene.challenges.length})'),
            const Tab(text: 'Лайфхак 💡'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Vocabulary List
          ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: widget.scene.words.length,
            itemBuilder: (context, index) {
              final word = widget.scene.words[index];
              return SceneWordCard(
                word: word,
                showNikkud: _showNikkud,
                audioService: widget.audioService,
                addCardToSrsUseCase: widget.addCardToSrsUseCase,
              );
            },
          ),

          // 2. Phrases List
          ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: widget.scene.phrases.length,
            itemBuilder: (context, index) {
              final phrase = widget.scene.phrases[index];
              return ScenePhraseTile(
                phrase: phrase,
                showNikkud: _showNikkud,
                audioService: widget.audioService,
                speechService: widget.speechService,
                addCardToSrsUseCase: widget.addCardToSrsUseCase,
              );
            },
          ),

          // 3. Situational Challenges
          ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              for (int i = 0; i < widget.scene.challenges.length; i++)
                SceneChallengeCard(
                  challenge: widget.scene.challenges[i],
                  index: i,
                  total: widget.scene.challenges.length,
                  onAnswerSelected: _onAnswerSelected,
                  audioService: widget.audioService,
                  speechService: widget.speechService,
                ),
              if (_isSceneCompleted) ...[
                const SizedBox(height: 12),
                _CompletionCelebrationCard(isDark: isDark),
              ],
            ],
          ),

          // 4. Cultural Lifehack
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: _SceneLifehackView(
              scene: widget.scene,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletionCelebrationCard extends StatelessWidget {
  const _CompletionCelebrationCard({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.green.withValues(alpha: isDark ? 0.25 : 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.green),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.stars_rounded, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Локация успешно освоена! Вы готовы к этой ситуации в Израиле.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SceneLifehackView extends StatelessWidget {
  const _SceneLifehackView({
    required this.scene,
    required this.isDark,
  });

  final IsraeliLifeScene scene;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('💡', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Израильский культурный лайфхак',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              scene.cultureLifehack,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 16),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                scene.titleHebrew,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontFamily: 'Heebo',
                  fontWeight: FontWeight.bold,
                  height: 1.45,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
