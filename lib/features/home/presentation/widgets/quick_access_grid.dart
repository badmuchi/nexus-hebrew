import 'package:flutter/material.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../alphabet/presentation/screens/alphabet_screen.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../../stories/presentation/screens/stories_catalog_view.dart';

/// Interactive grid of feature launch tiles on the Home dashboard.
class QuickAccessGrid extends StatelessWidget {
  final ValueChanged<int>? onNavigateToTab;
  final AudioPlaybackService? audioService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;

  const QuickAccessGrid({
    super.key,
    this.onNavigateToTab,
    this.audioService,
    this.addCardToSrsUseCase,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final items = [
      _QuickItem(
        title: 'Диалоги',
        hebrewTitle: 'שִׂיחוֹת',
        description: 'Разговорные кейсы: кафе, такси, рынок, банк',
        icon: Icons.forum_rounded,
        color: const Color(0xFF1E88E5),
        onTap: () => onNavigateToTab?.call(1),
      ),
      _QuickItem(
        title: 'FSRS Карточки',
        hebrewTitle: 'כַּרְטִיסִיּוֹת',
        description: 'Интервальные повторения памяти на века',
        icon: Icons.style_rounded,
        color: const Color(0xFF7B1FA2),
        onTap: () => onNavigateToTab?.call(2),
      ),
      _QuickItem(
        title: '7 Биньянов',
        hebrewTitle: 'בִּנְיָנִים',
        description: 'Атлас пород, цветная анатомия и квиз',
        icon: Icons.account_tree_rounded,
        color: const Color(0xFF00897B),
        onTap: () => onNavigateToTab?.call(3),
      ),
      _QuickItem(
        title: 'Аудирование',
        hebrewTitle: 'הַאֲזָנָה',
        description: 'Слуховые диктанты, минимальные пары и пазлы',
        icon: Icons.headphones_rounded,
        color: const Color(0xFFE65100),
        onTap: () => onNavigateToTab?.call(4),
      ),
      _QuickItem(
        title: 'Словарь',
        hebrewTitle: 'מִלּוֹן',
        description: 'Поиск по корню, биньяну и добавление слов',
        icon: Icons.menu_book_rounded,
        color: const Color(0xFF3949AB),
        onTap: () => onNavigateToTab?.call(5),
      ),
      _QuickItem(
        title: 'Прогресс',
        hebrewTitle: 'הִתְקַדְּמוּת',
        description: 'Карта активности (Heatmap) и статистика',
        icon: Icons.insights_rounded,
        color: const Color(0xFF2E7D32),
        onTap: () => onNavigateToTab?.call(6),
      ),
      _QuickItem(
        title: 'Алеф-Бет',
        hebrewTitle: 'אָלֶף־בֵּית',
        description: 'Прописи ктав яд, софиты, никуд и гематрия',
        icon: Icons.spellcheck_rounded,
        color: const Color(0xFFC2185B),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => AlphabetScreen(
              audioService: audioService,
              addCardToSrsUseCase: addCardToSrsUseCase,
            ),
          ),
        ),
      ),
      _QuickItem(
        title: 'Микро-рассказы',
        hebrewTitle: 'סִפּוּרִים',
        description: 'Чтение на иврите с рентгеном фраз и аудио',
        icon: Icons.auto_stories_rounded,
        color: const Color(0xFF0097A7),
        onTap: () {
          if (audioService != null && addCardToSrsUseCase != null) {
            showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              builder: (_) => Scaffold(
                appBar: AppBar(title: const Text('Микро-рассказы')),
                body: StoriesCatalogView(
                  audioService: audioService!,
                  addCardToSrsUseCase: addCardToSrsUseCase!,
                ),
              ),
            );
          }
        },
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 600 ? 4 : 2;
        final aspectRatio = constraints.maxWidth >= 600 ? 1.35 : 1.22;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: aspectRatio,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return _QuickItemCard(item: item, theme: theme);
          },
        );
      },
    );
  }
}

class _QuickItem {
  final String title;
  final String hebrewTitle;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickItem({
    required this.title,
    required this.hebrewTitle,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class _QuickItemCard extends StatelessWidget {
  const _QuickItemCard({
    required this.item,
    required this.theme,
  });

  final _QuickItem item;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      color: theme.colorScheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: item.onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Icon(item.icon, color: item.color, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(
                          item.hebrewTitle,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: item.color,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.description,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
