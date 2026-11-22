import 'package:flutter/material.dart';

import '../../domain/entities/ai_roleplay_scenario.dart';

/// Horizontal list of interactive prompt suggestions that user can tap
/// to quickly respond in Hebrew with proper RTL formatting.
class SuggestedPromptChips extends StatelessWidget {
  final List<SuggestedPromptItem> prompts;
  final ValueChanged<String> onPromptSelected;

  const SuggestedPromptChips({
    super.key,
    required this.prompts,
    required this.onPromptSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (prompts.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        scrollDirection: Axis.horizontal,
        itemCount: prompts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final prompt = prompts[index];
          return ActionChip(
            avatar: const Icon(Icons.quickreply_rounded, size: 16),
            backgroundColor: theme.colorScheme.surfaceContainerHighest.withAlpha(200),
            side: BorderSide(
              color: theme.colorScheme.outlineVariant.withAlpha(120),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  prompt.hebrew,
                  textDirection: TextDirection.rtl,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Noto Sans Hebrew',
                    height: 1.45,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '• ${prompt.russian}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            onPressed: () => onPromptSelected(prompt.hebrew),
          );
        },
      ),
    );
  }
}
