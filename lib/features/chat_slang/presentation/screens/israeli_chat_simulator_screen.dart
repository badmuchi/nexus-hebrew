import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../srs/domain/entities/srs_card.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../data/datasources/chat_slang_seed_data.dart';
import '../../domain/entities/chat_channel.dart';
import '../widgets/chat_bubble_card.dart';

/// Interactive Israeli WhatsApp chat simulator and slang abbreviation training screen.
class IsraeliChatSimulatorScreen extends StatefulWidget {
  final AudioPlaybackService? audioService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;

  const IsraeliChatSimulatorScreen({
    super.key,
    this.audioService,
    this.addCardToSrsUseCase,
  });

  @override
  State<IsraeliChatSimulatorScreen> createState() =>
      _IsraeliChatSimulatorScreenState();
}

class _IsraeliChatSimulatorScreenState extends State<IsraeliChatSimulatorScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  int _selectedThreadIndex = 0;
  int? _selectedReplyOption;
  bool _hasSentReply = false;
  String _glossaryQuery = '';

  List<ChatThread> get _threads => ChatSlangSeedData.threads;
  ChatThread get _currentThread => _threads[_selectedThreadIndex];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onSelectThread(int index) {
    if (_selectedThreadIndex == index) return;
    unawaited(HapticFeedback.selectionClick());
    setState(() {
      _selectedThreadIndex = index;
      _selectedReplyOption = null;
      _hasSentReply = false;
    });
  }

  void _onChooseReply(int index) {
    if (_hasSentReply) return;
    unawaited(HapticFeedback.selectionClick());
    setState(() {
      _selectedReplyOption = index;
    });
  }

  void _sendReply() {
    if (_selectedReplyOption == null) return;
    unawaited(HapticFeedback.mediumImpact());
    setState(() {
      _hasSentReply = true;
    });
  }

  void _resetReplyChallenge() {
    unawaited(HapticFeedback.lightImpact());
    setState(() {
      _selectedReplyOption = null;
      _hasSentReply = false;
    });
  }

  Future<void> _addSlangToSrs(Map<String, String> slang) async {
    final useCase = widget.addCardToSrsUseCase;
    if (useCase == null) return;

    final hebrew = slang['fullHebrew'] ?? slang['abbreviation'] ?? '';
    final meaning = slang['meaningRu'] ?? '';
    final trans = slang['transcription'] ?? '';

    await useCase(
      AddCardToSrsParams(
        id: 'slang_${slang['abbreviation']}',
        hebrewVocalized: hebrew,
        russianTranslation: '$meaning ($trans)',
        category: LexicalCategory.phrase,
      ),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('«$hebrew» добавлено в FSRS повторение!'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WhatsApp и сленг Израиля'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.chat_bubble_rounded), text: 'Симулятор переписок'),
            Tab(icon: Icon(Icons.bolt_rounded), text: 'Словарь аббревиатур'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatSimulatorTab(),
          _buildSlangGlossaryTab(),
        ],
      ),
    );
  }

  Widget _buildChatSimulatorTab() {
    final theme = Theme.of(context);
    final thread = _currentThread;
    final challenge = thread.challenge;

    return Column(
      children: [
        // Thread Selector Chips
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_threads.length, (idx) {
                final t = _threads[idx];
                final isSel = idx == _selectedThreadIndex;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    avatar: Text(t.category.iconEmoji, style: const TextStyle(fontSize: 16)),
                    label: Text(t.groupNameRu),
                    selected: isSel,
                    onSelected: (_) => _onSelectThread(idx),
                  ),
                );
              }),
            ),
          ),
        ),

        // Group Info Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF075E54).withValues(alpha: 0.08),
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF075E54),
                child: Text(
                  thread.category.iconEmoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      thread.groupNameHebrew,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.5,
                        color: Color(0xFF075E54),
                      ),
                    ),
                    Text(
                      thread.participantsSummaryRu,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Chat Messages Stream
        Expanded(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                children: [
                  for (final msg in thread.messages)
                    ChatBubbleCard(
                      message: msg,
                      audioService: widget.audioService,
                    ),

                  // If user sent a reply, show it as outgoing message
                  if (_hasSentReply && _selectedReplyOption != null) ...[
                    ChatBubbleCard(
                      message: ChatMessage(
                        id: 'my_reply_${thread.id}',
                        senderName: 'Ты (אֲנִי)',
                        senderRoleRu: 'Отправлено',
                        isMe: true,
                        timeString: 'Только что',
                        textHebrewWithNikkud:
                            challenge.optionsHebrewWithNikkud[_selectedReplyOption!],
                        textPlain:
                            challenge.optionsHebrewWithNikkud[_selectedReplyOption!],
                        transcriptionRu: 'Твой ответ в чат',
                        translationRu:
                            challenge.optionsTranslationRu[_selectedReplyOption!],
                      ),
                      audioService: widget.audioService,
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Interactive Reply Challenge Box
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                const Text('✍️ ', style: TextStyle(fontSize: 20)),
                                Expanded(
                                  child: Text(
                                    'Твой ответ в чат: ${challenge.contextRu}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Option choices
                            for (int i = 0;
                                i < challenge.optionsHebrewWithNikkud.length;
                                i++) ...[
                              _buildReplyOptionTile(
                                index: i,
                                optionHebrew:
                                    challenge.optionsHebrewWithNikkud[i],
                                optionRu: challenge.optionsTranslationRu[i],
                                isBest: i == challenge.bestOptionIndex,
                              ),
                              const SizedBox(height: 8),
                            ],

                            const SizedBox(height: 8),

                            if (!_hasSentReply)
                              FilledButton.icon(
                                onPressed: _selectedReplyOption != null
                                    ? _sendReply
                                    : null,
                                icon: const Icon(Icons.send_rounded),
                                label: const Text('Отправить сообщение в группу'),
                              )
                            else ...[
                              // Feedback banner
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _selectedReplyOption ==
                                          challenge.bestOptionIndex
                                      ? Colors.green.shade50
                                      : Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _selectedReplyOption ==
                                            challenge.bestOptionIndex
                                        ? Colors.green.shade300
                                        : Colors.amber.shade300,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedReplyOption ==
                                              challenge.bestOptionIndex
                                          ? '🎯 Отличный выбор! Естественный израильский сленг.'
                                          : '💡 Полезный совет по переписке:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.5,
                                        color: _selectedReplyOption ==
                                                challenge.bestOptionIndex
                                            ? Colors.green.shade900
                                            : Colors.brown.shade900,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      challenge.feedbackRu,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '📌 Правило этикета: ${challenge.culturalEtiquetteRuleRu}',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.brown.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                onPressed: _resetReplyChallenge,
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('Попробовать другой ответ'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReplyOptionTile({
    required int index,
    required String optionHebrew,
    required String optionRu,
    required bool isBest,
  }) {
    final theme = Theme.of(context);
    final isSelected = _selectedReplyOption == index;

    Color borderColor = theme.colorScheme.outlineVariant.withValues(alpha: 0.7);
    Color bgColor = theme.colorScheme.surface;

    if (_hasSentReply) {
      if (isBest) {
        borderColor = Colors.green;
        bgColor = Colors.green.shade50;
      } else if (isSelected) {
        borderColor = Colors.red;
        bgColor = Colors.red.shade50;
      }
    } else if (isSelected) {
      borderColor = const Color(0xFF075E54);
      bgColor = const Color(0xFF075E54).withValues(alpha: 0.08);
    }

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _hasSentReply ? null : () => _onChooseReply(index),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  optionHebrew,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    height: 1.45,
                    color: isSelected ? const Color(0xFF075E54) : theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                optionRu,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlangGlossaryTab() {
    final theme = Theme.of(context);
    final q = _glossaryQuery.toLowerCase().trim();

    final filtered = ChatSlangSeedData.chatSlangGlossary.where((item) {
      if (q.isEmpty) return true;
      final abbr = (item['abbreviation'] ?? '').toLowerCase();
      final full = (item['fullHebrew'] ?? '').toLowerCase();
      final meaning = (item['meaningRu'] ?? '').toLowerCase();
      final trans = (item['transcription'] ?? '').toLowerCase();
      return abbr.contains(q) || full.contains(q) || meaning.contains(q) || trans.contains(q);
    }).toList();

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search_rounded),
                hintText: 'Поиск по сленгу (חחח, אמלק, תכלס, סופ״ש...)',
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) => setState(() => _glossaryQuery = val),
            ),
            const SizedBox(height: 14),

            Text(
              'Найдено выражений: ${filtered.length}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12.5,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),

            ...filtered.map((item) {
              final abbr = item['abbreviation'] ?? '';
              final full = item['fullHebrew'] ?? '';
              final meaning = item['meaningRu'] ?? '';
              final trans = item['transcription'] ?? '';
              final cat = item['category'] ?? '';

              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF075E54).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          abbr,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF075E54),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  full,
                                  textDirection: TextDirection.rtl,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    height: 1.45,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    cat,
                                    style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '($trans)',
                              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              meaning,
                              style: const TextStyle(fontSize: 13, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Column(
                        children: [
                          if (widget.audioService != null)
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.volume_up_rounded, size: 20),
                              tooltip: 'Озвучить',
                              onPressed: () => widget.audioService?.playWithTtsFallback(
                                sourcePath: null,
                                fallbackHebrewText: full,
                              ),
                            ),
                          if (widget.addCardToSrsUseCase != null)
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.bookmark_add_outlined, size: 20),
                              tooltip: 'В словарь FSRS',
                              onPressed: () => _addSlangToSrs(item),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
