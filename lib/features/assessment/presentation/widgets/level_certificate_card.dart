import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../srs/domain/entities/srs_card.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../domain/entities/level_quiz_question.dart';
import '../../domain/entities/level_quiz_result.dart';

/// Interactive certificate card presenting determined CEFR level,
/// skill breakdown, targeted recommendations, and 1-tap FSRS mistake import.
class LevelCertificateCard extends StatefulWidget {
  final LevelQuizResult result;
  final VoidCallback onRetake;
  final AddCardToSrsUseCase? addCardToSrsUseCase;

  const LevelCertificateCard({
    super.key,
    required this.result,
    required this.onRetake,
    this.addCardToSrsUseCase,
  });

  @override
  State<LevelCertificateCard> createState() => _LevelCertificateCardState();
}

class _LevelCertificateCardState extends State<LevelCertificateCard> {
  final Set<String> _savedMistakeIds = {};
  bool _isSavingAll = false;

  Future<void> _saveWordToSrs(LevelQuizQuestion question) async {
    final useCase = widget.addCardToSrsUseCase;
    if (useCase == null) return;

    final word = question.keyWord ?? question.correctOption;
    final trans = question.keyWordRussian ?? question.explanationRu;

    final params = AddCardToSrsParams(
      id: 'srs_quiz_${question.id}_${DateTime.now().millisecondsSinceEpoch}',
      hebrewVocalized: word,
      russianTranslation: trans,
      category: LexicalCategory.phrase,
      audioUrl: question.audioPath,
    );

    final res = await useCase(params);
    if (mounted && res.isSuccess) {
      setState(() {
        _savedMistakeIds.add(question.id);
      });
      unawaited(HapticFeedback.lightImpact());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('«$word» добавлено в FSRS повторения!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _saveAllMistakesToSrs() async {
    final useCase = widget.addCardToSrsUseCase;
    if (useCase == null || widget.result.mistakes.isEmpty) return;

    setState(() => _isSavingAll = true);

    for (final q in widget.result.mistakes) {
      if (_savedMistakeIds.contains(q.id)) continue;
      final word = q.keyWord ?? q.correctOption;
      final trans = q.keyWordRussian ?? q.explanationRu;

      final params = AddCardToSrsParams(
        id: 'srs_quiz_all_${q.id}_${DateTime.now().millisecondsSinceEpoch}',
        hebrewVocalized: word,
        russianTranslation: trans,
        category: LexicalCategory.phrase,
        audioUrl: q.audioPath,
      );

      final res = await useCase(params);
      if (res.isSuccess) {
        _savedMistakeIds.add(q.id);
      }
    }

    if (mounted) {
      setState(() => _isSavingAll = false);
      unawaited(HapticFeedback.mediumImpact());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Все сложные слова сохранены в колоду FSRS!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Color _getLevelColor(String level) {
    if (level.startsWith('B')) {
      return const Color(0xFF6A1B9A); // Purple B1
    } else if (level.startsWith('A2')) {
      return const Color(0xFF00897B); // Teal A2
    } else {
      return const Color(0xFF1E88E5); // Blue A1
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final res = widget.result;
    final levelColor = _getLevelColor(res.determinedLevel);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Certificate Hero Banner
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                levelColor.withValues(alpha: 0.85),
                levelColor,
                theme.colorScheme.primary,
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: levelColor.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsetsDirectional.all(24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_rounded, size: 16, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'NEXUS HEBREW DIPLOMA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${res.scorePercentageRounded}% верно',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Level Crown Badge
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    res.determinedLevel,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: levelColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Hebrew & Russian Titles
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  res.levelTitleHe,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                res.levelTitleRu,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 14),

              // Questions counter pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${res.correctAnswers} из ${res.totalQuestions} верных ответов',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Skill Breakdown Section
        Card(
          elevation: 0,
          color: theme.colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Диагностика навыков:',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                for (final skill in SkillFocus.values) ...[
                  _SkillScoreRow(
                    skill: skill,
                    score: res.skillScores[skill] ?? 1.0,
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Personalized Recommendations Card
        Card(
          elevation: 0,
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsetsDirectional.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.psychology_rounded, color: Colors.amber, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Индивидуальный план развития:',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                for (final rec in res.recommendations) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('💡 ', style: TextStyle(fontSize: 14)),
                        Expanded(
                          child: Text(
                            rec,
                            style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Mistakes Review & FSRS Add Section
        if (res.mistakes.isNotEmpty) ...[
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.3)),
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.error_outline_rounded,
                              color: theme.colorScheme.error, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Работа над ошибками (${res.mistakes.length}):',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (widget.addCardToSrsUseCase != null)
                        TextButton.icon(
                          onPressed: _isSavingAll ? null : _saveAllMistakesToSrs,
                          icon: _isSavingAll
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.bookmark_add_rounded, size: 18),
                          label: const Text('Все в FSRS'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  for (final q in res.mistakes) ...[
                    _MistakeQuestionTile(
                      question: q,
                      isSaved: _savedMistakeIds.contains(q.id),
                      onSave: () => _saveWordToSrs(q),
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Retake Test Button
        FilledButton.tonalIcon(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: widget.onRetake,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Пройти диагностику заново'),
        ),
      ],
    );
  }
}

class _SkillScoreRow extends StatelessWidget {
  final SkillFocus skill;
  final double score;

  const _SkillScoreRow({required this.skill, required this.score});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = (score * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(skill.icon, size: 16, color: skill.color),
                const SizedBox(width: 6),
                Text(
                  skill.labelRu,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            Text(
              '$percent%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: skill.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: score,
            minHeight: 8,
            backgroundColor: skill.color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(skill.color),
          ),
        ),
      ],
    );
  }
}

class _MistakeQuestionTile extends StatelessWidget {
  final LevelQuizQuestion question;
  final bool isSaved;
  final VoidCallback onSave;

  const _MistakeQuestionTile({
    required this.question,
    required this.isSaved,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsetsDirectional.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  question.promptRussian,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  isSaved ? Icons.check_circle_rounded : Icons.bookmark_add_outlined,
                  color: isSaved ? Colors.green : theme.colorScheme.primary,
                ),
                tooltip: isSaved ? 'Добавлено в FSRS' : '+ FSRS карточка',
                onPressed: isSaved ? null : onSave,
              ),
            ],
          ),
          if (question.promptHebrew != null) ...[
            const SizedBox(height: 4),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                question.promptHebrew!,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ],
          const SizedBox(height: 6),
          Row(
            children: [
              const Text('Правильный ответ: ', style: TextStyle(fontSize: 12, color: Colors.grey)),
              Expanded(
                child: Text(
                  question.correctOption,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            question.explanationRu,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
