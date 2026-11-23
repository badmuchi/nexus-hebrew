import 'package:flutter/material.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../domain/entities/chat_channel.dart';

/// Authentic WhatsApp-style chat message bubble with slang chips and audio preview.
class ChatBubbleCard extends StatelessWidget {
  final ChatMessage message;
  final AudioPlaybackService? audioService;
  final ValueChanged<String>? onSelectSlang;

  const ChatBubbleCard({
    super.key,
    required this.message,
    this.audioService,
    this.onSelectSlang,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMe = message.isMe;

    final bubbleBg = isMe
        ? const Color(0xFFDCF8C6) // Classic WhatsApp outgoing green
        : theme.colorScheme.surface;

    final textColor = isMe ? Colors.black87 : theme.colorScheme.onSurface;

    return Align(
      alignment: isMe ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
          decoration: BoxDecoration(
            color: bubbleBg,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMe ? 16 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: isMe
                  ? const Color(0xFFC7EBB0)
                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sender name and role (if not me)
              if (!isMe) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      message.senderName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF075E54), // WhatsApp teal dark
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        message.senderRoleRu,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.teal.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
              ],

              // Hebrew message text
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  message.textHebrewWithNikkud,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(height: 4),

              // Russian transcription
              Text(
                '(${message.transcriptionRu})',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: isMe ? Colors.black54 : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),

              // Russian translation
              Text(
                message.translationRu,
                style: TextStyle(
                  fontSize: 13,
                  color: isMe ? Colors.black87 : theme.colorScheme.onSurface,
                  height: 1.3,
                ),
              ),

              // Slang badges if present in message
              if (message.slangDictionary.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: message.slangDictionary.entries.map((entry) {
                    return ActionChip(
                      visualDensity: VisualDensity.compact,
                      avatar: const Icon(Icons.bolt_rounded, size: 14, color: Colors.amber),
                      label: Text('${entry.key}: ${entry.value}'),
                      labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      onPressed: () => onSelectSlang?.call(entry.key),
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 6),

              // Bottom row: audio button, timestamp, and checkmarks
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (audioService != null)
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => audioService?.playWithTtsFallback(
                        sourcePath: null,
                        fallbackHebrewText: message.textHebrewWithNikkud,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.volume_up_rounded, size: 16, color: Color(0xFF075E54)),
                            SizedBox(width: 4),
                            Text('Озвучить', style: TextStyle(fontSize: 11, color: Color(0xFF075E54))),
                          ],
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message.timeString,
                        style: TextStyle(
                          fontSize: 11,
                          color: isMe ? Colors.black45 : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.done_all_rounded,
                        size: 16,
                        color: isMe ? const Color(0xFF34B7F1) : Colors.grey,
                      ),
                    ],
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
