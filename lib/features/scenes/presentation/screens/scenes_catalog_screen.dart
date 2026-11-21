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
    unawaited(_loadProgress());
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

  void _onSceneTapped(IsraeliLifeScene scene) async {
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
                _CatalogHeaderBanner(
                  completedCount: completedCount,
                  totalCount: scenes.length,
                ),
                const SizedBox(height: 16),
                for (final scene in scenes) ...[
                  _SceneCatalogCard(
                    scene: scene,
                    isCompleted: _completedMap[scene.id] == true,
                    isDark: isDark,
                    onTap: () => _onSceneTapped(scene),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
    );
  }
}

class _CatalogHeaderBanner extends StatelessWidget {
  const _CatalogHeaderBanner({
    required this.completedCount,
    required this.totalCount,
  });

  final int completedCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
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
                      value: totalCount == 0 ? 0 : completedCount / totalCount,
                      minHeight: 8,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      color: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Пройдено: $completedCount из $totalCount',
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
    );
  }
}

class _SceneCatalogCard extends StatelessWidget {
  const _SceneCatalogCard({
    required this.scene,
    required this.isCompleted,
    required this.isDark,
    required this.onTap,
  });

  final IsraeliLifeScene scene;
  final bool isCompleted;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isCompleted
              ? Colors.green.withValues(alpha: 0.5)
              : (isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08)),
          width: isCompleted ? 1.5 : 1.0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
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
                      color: theme.colorScheme.surfaceContainerHighest,
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
                        color: Colors.green.withValues(alpha: isDark ? 0.25 : 0.12),
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
                        height: 1.45,
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
                  _StatBadge(
                    icon: Icons.translate_rounded,
                    label: '${scene.words.length} слов',
                  ),
                  const SizedBox(width: 8),
                  _StatBadge(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: '${scene.phrases.length} фраз',
                  ),
                  const SizedBox(width: 8),
                  _StatBadge(
                    icon: Icons.quiz_outlined,
                    label: '${scene.challenges.length} ситуации',
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
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
