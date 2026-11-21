import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../domain/entities/israeli_life_scene.dart';
import '../../domain/repositories/scenes_repository.dart';
import 'scene_detail_screen.dart';

class ScenesCatalogScreen extends StatefulWidget {
  const ScenesCatalogScreen({
    super.key,
    required this.repository,
    this.audioService,
    this.addCardToSrsUseCase,
    this.onSceneCompleted,
  });

  final ScenesRepository repository;
  final AudioPlaybackService? audioService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;
  final VoidCallback? onSceneCompleted;

  @override
  State<ScenesCatalogScreen> createState() => _ScenesCatalogScreenState();
}

class _ScenesCatalogScreenState extends State<ScenesCatalogScreen> {
  Map<String, bool> _completedMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final res = await widget.repository.getCompletedSceneIds();
    if (mounted) {
      setState(() {
        _completedMap = res.getOrNull() ?? {};
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scenes = widget.repository.getAllScenes();
    final completedCount = scenes.where((s) => _completedMap[s.id] == true).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Реальный Израиль: Бытовые сцены',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // Header Banner
                Card(
                  elevation: 0,
                  color: theme.colorScheme.primaryContainer.withOpacity(0.35),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('🏙️', style: TextStyle(fontSize: 28)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Живые ситуации Израиля',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Слова, фразы кассиров и водителей, чек-листы',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: scenes.isEmpty ? 0 : completedCount / scenes.length,
                                  minHeight: 8,
                                  backgroundColor: theme.colorScheme.surfaceVariant,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Пройдено: $completedCount из ${scenes.length}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Scenes List
                for (final scene in scenes) ...[
                  _buildSceneCard(scene, theme, isDark),
                  const SizedBox(height: 12),
                ],
              ],
            ),
    );
  }

  Widget _buildSceneCard(IsraeliLifeScene scene, ThemeData theme, bool isDark) {
    final isCompleted = _completedMap[scene.id] == true;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isCompleted
              ? Colors.green.withOpacity(0.5)
              : (isDark ? Colors.white12 : Colors.black.withOpacity(0.08)),
          width: isCompleted ? 1.5 : 1.0,
        ),
      ),
      child: InkWell(
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => SceneDetailScreen(
                scene: scene,
                repository: widget.repository,
                audioService: widget.audioService,
                addCardToSrsUseCase: widget.addCardToSrsUseCase,
                onSceneCompleted: () {
                  widget.onSceneCompleted?.call();
                  unawaited(_loadProgress());
                },
              ),
            ),
          );
          await _loadProgress();
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Row: Emoji, Level, and Completed Badge
              Row(
                children: [
                  Text(scene.emoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      scene.cefrLevel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(isDark ? 0.25 : 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded, size: 14, color: Colors.green),
                          SizedBox(width: 4),
                          Text(
                            'Пройдено',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // Title Russian & Hebrew (RTL)
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Text(
                      scene.titleRussian,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      scene.titleHebrew,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontFamily: 'Heebo',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Description
              Text(
                scene.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),

              // Stats row: words, phrases, challenges
              Row(
                children: [
                  _buildStatBadge(Icons.translate_rounded, '${scene.words.length} слов', theme),
                  const SizedBox(width: 8),
                  _buildStatBadge(Icons.chat_bubble_outline_rounded, '${scene.phrases.length} фраз', theme),
                  const SizedBox(width: 8),
                  _buildStatBadge(Icons.quiz_outlined, '${scene.challenges.length} ситуации', theme),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBadge(IconData icon, String text, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
