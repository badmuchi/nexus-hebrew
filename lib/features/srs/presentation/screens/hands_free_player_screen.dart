import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../domain/entities/srs_card.dart';

/// One playable item in the Hands-Free audio loop.
class HandsFreeItem {
  final String id;
  final String hebrewVocalized;
  final String hebrewNormalized;
  final String russianTranslation;
  final String? audioUrl;
  final String? transliteration;

  const HandsFreeItem({
    required this.id,
    required this.hebrewVocalized,
    required this.hebrewNormalized,
    required this.russianTranslation,
    this.audioUrl,
    this.transliteration,
  });

  factory HandsFreeItem.fromSrsCard(SrsCard card) {
    return HandsFreeItem(
      id: card.id,
      hebrewVocalized: card.hebrew.vocalized,
      hebrewNormalized: card.hebrew.normalized,
      russianTranslation: card.russianTranslation,
      audioUrl: card.audioUrl,
    );
  }
}

/// Hands-free audio player ("Иврит на ходу") for continuous listening.
class HandsFreePlayerScreen extends StatefulWidget {
  const HandsFreePlayerScreen({
    super.key,
    required this.items,
    required this.audioService,
    this.title = 'Иврит на ходу 🎧',
  });

  final List<HandsFreeItem> items;
  final AudioPlaybackService? audioService;
  final String title;

  @override
  State<HandsFreePlayerScreen> createState() => _HandsFreePlayerScreenState();
}

class _HandsFreePlayerScreenState extends State<HandsFreePlayerScreen> {
  late List<HandsFreeItem> _playlist;
  int _currentIndex = 0;
  bool _isPlaying = false;
  bool _isTranslationPhase = false;
  bool _isLooping = true;
  double _playbackSpeed = 1.0;
  int _runToken = 0;

  @override
  void initState() {
    super.initState();
    _playlist = List<HandsFreeItem>.from(widget.items);
  }

  @override
  void dispose() {
    _isPlaying = false;
    _runToken++;
    unawaited(widget.audioService?.stop());
    super.dispose();
  }

  void _togglePlayPause() {
    if (_playlist.isEmpty) return;

    if (_isPlaying) {
      _pause();
    } else {
      _play();
    }
  }

  void _pause() {
    setState(() {
      _isPlaying = false;
      _runToken++;
    });
    unawaited(widget.audioService?.stop());
  }

  void _play() {
    if (_playlist.isEmpty) return;
    setState(() {
      _isPlaying = true;
    });
    _runAudioLoop(++_runToken);
  }

  Future<void> _runAudioLoop(int token) async {
    while (_isPlaying && mounted && token == _runToken) {
      if (_playlist.isEmpty || _currentIndex >= _playlist.length) {
        if (_isLooping && _playlist.isNotEmpty) {
          setState(() {
            _currentIndex = 0;
          });
        } else {
          _pause();
          break;
        }
      }

      final item = _playlist[_currentIndex];

      // 1. Hebrew phase
      if (!mounted || token != _runToken || !_isPlaying) break;
      setState(() {
        _isTranslationPhase = false;
      });

      final audio = widget.audioService;
      if (audio != null) {
        await audio.playWithTtsFallback(
          sourcePath: item.audioUrl,
          fallbackHebrewText: item.hebrewVocalized,
        );
      }

      // Thinking pause: 2000 ms
      await Future<void>.delayed(const Duration(milliseconds: 2000));
      if (!mounted || token != _runToken || !_isPlaying) break;

      // 2. Translation phase
      setState(() {
        _isTranslationPhase = true;
      });

      // Pause while translation is shown before advancing
      await Future<void>.delayed(const Duration(milliseconds: 1800));
      if (!mounted || token != _runToken || !_isPlaying) break;

      // Advance
      setState(() {
        if (_currentIndex + 1 < _playlist.length) {
          _currentIndex++;
        } else if (_isLooping) {
          _currentIndex = 0;
        } else {
          _isPlaying = false;
        }
      });

      // Inter-card buffer
      await Future<void>.delayed(const Duration(milliseconds: 600));
    }
  }

  void _next() {
    if (_playlist.isEmpty) return;
    setState(() {
      _runToken++;
      _isTranslationPhase = false;
      if (_currentIndex + 1 < _playlist.length) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
    });
    if (_isPlaying) {
      _runAudioLoop(_runToken);
    }
  }

  void _previous() {
    if (_playlist.isEmpty) return;
    setState(() {
      _runToken++;
      _isTranslationPhase = false;
      if (_currentIndex > 0) {
        _currentIndex--;
      } else {
        _currentIndex = _playlist.length - 1;
      }
    });
    if (_isPlaying) {
      _runAudioLoop(_runToken);
    }
  }

  void _shuffle() {
    setState(() {
      _runToken++;
      _playlist.shuffle();
      _currentIndex = 0;
      _isTranslationPhase = false;
    });
    if (_isPlaying) {
      _runAudioLoop(_runToken);
    }
  }

  void _toggleSpeed() {
    setState(() {
      if (_playbackSpeed == 1.0) {
        _playbackSpeed = 0.8;
      } else if (_playbackSpeed == 0.8) {
        _playbackSpeed = 1.2;
      } else {
        _playbackSpeed = 1.0;
      }
    });
    unawaited(widget.audioService?.setPlaybackSpeed(_playbackSpeed));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_playlist.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Center(
          child: Padding(
            padding: const EdgeInsetsDirectional.all(24),
            child: Text(
              'Плейлист пуст. Добавьте слова в FSRS или откройте словарь.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ),
      );
    }

    final item = _playlist[_currentIndex];
    final progress = (_currentIndex + 1) / _playlist.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: _isLooping ? 'Зацикливание вкл.' : 'Зацикливание выкл.',
            icon: Icon(
              Icons.repeat_rounded,
              color: _isLooping ? theme.colorScheme.primary : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _isLooping = !_isLooping;
              });
            },
          ),
          IconButton(
            tooltip: 'Перемешать плейлист',
            icon: const Icon(Icons.shuffle_rounded),
            onPressed: _shuffle,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 24, 28),
          child: Column(
            children: [
              // Progress bar & counter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Карточка ${_currentIndex + 1} из ${_playlist.length}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsetsDirectional.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                    ),
                    icon: const Icon(Icons.speed_rounded, size: 16),
                    label: Text('${_playbackSpeed}x'),
                    onPressed: _toggleSpeed,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                ),
              ),
              const Spacer(),

              // Central Card
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: _isPlaying
                        ? theme.colorScheme.primary.withValues(alpha: 0.5)
                        : theme.colorScheme.outlineVariant,
                    width: _isPlaying ? 2 : 1,
                  ),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: 24,
                    vertical: 36,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Hebrew word
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(
                          item.hebrewVocalized,
                          style: theme.textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (item.transliteration != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          item.transliteration!,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                      const SizedBox(height: 28),

                      // Translation or listening hint
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 300),
                        crossFadeState: _isTranslationPhase
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        firstChild: Container(
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.hearing_rounded,
                                size: 18,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Вспомни перевод...',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        secondChild: Text(
                          item.russianTranslation,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Player Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 36,
                    icon: const Icon(Icons.skip_previous_rounded),
                    tooltip: 'Предыдущее слово',
                    onPressed: _previous,
                  ),
                  const SizedBox(width: 20),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsetsDirectional.all(20),
                    ),
                    onPressed: _togglePlayPause,
                    child: Icon(
                      _isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      size: 40,
                    ),
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    iconSize: 36,
                    icon: const Icon(Icons.skip_next_rounded),
                    tooltip: 'Следующее слово',
                    onPressed: _next,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Режим для прогулок и наушников',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
