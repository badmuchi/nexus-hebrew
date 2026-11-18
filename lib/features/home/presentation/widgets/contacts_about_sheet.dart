import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Modal bottom sheet presenting application details, architecture notes, and creator contacts.
class ContactsAboutSheet extends StatelessWidget {
  const ContactsAboutSheet({super.key});

  static const String appVersion = 'v0.3.0';
  static const String githubRepoUrl = 'https://github.com/badmuchi/nexus-hebrew';
  static const String liveWebUrl = 'https://badmuchi.github.io/nexus-hebrew/';
  static const String creatorHandle = 'badmuchi';

  void _copyToClipboard(BuildContext context, String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('О приложении и контакты'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 32),
        children: [
          // App Logo & Tagline Header
          Center(
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.tertiary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'נ',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.15,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Nexus Hebrew',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    appVersion,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Интерактивная среда для глубокого освоения современного иврита',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Creator Card
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
              ),
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: theme.colorScheme.primary,
                        child: const Text(
                          'B',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              creatorHandle,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Создатель & Архитектор проекта',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    '«Иврит устроен удивительно логично вокруг корней и биньянов. Nexus Hebrew создан для того, чтобы обучение доставляло радость открытий, а не мучение зубрежки.»',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Links & Contacts Actions
          Text(
            'Ссылки и контакты:',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          _LinkTile(
            icon: Icons.code_rounded,
            title: 'GitHub Репозиторий',
            subtitle: 'badmuchi/nexus-hebrew (открытый исходный код)',
            onTap: () => _copyToClipboard(
              context,
              githubRepoUrl,
              'Ссылка на GitHub репозиторий скопирована!',
            ),
          ),
          const SizedBox(height: 8),
          _LinkTile(
            icon: Icons.language_rounded,
            title: 'Живая Web-версия (GitHub Pages)',
            subtitle: liveWebUrl,
            onTap: () => _copyToClipboard(
              context,
              liveWebUrl,
              'Ссылка на веб-версию скопирована!',
            ),
          ),
          const SizedBox(height: 8),
          _LinkTile(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Связь и обратная связь',
            subtitle: 'GitHub Issues & Pull Requests',
            onTap: () => _copyToClipboard(
              context,
              '$githubRepoUrl/issues',
              'Ссылка на создание задачи в GitHub скопирована!',
            ),
          ),
          const SizedBox(height: 20),

          // PWA Install Guidance
          Card(
            elevation: 0,
            color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.35),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.secondary.withValues(alpha: 0.25),
              ),
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.install_mobile_rounded,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Установка на смартфон (PWA)',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Приложение можно установить на экран iPhone или Android как обычное нативное приложение без App Store:\n'
                    '1. Откройте ссылку в браузере Safari на iPhone (или Chrome на Android).\n'
                    '2. Нажмите кнопку «Поделиться» ➔ «На экран "Домой"» (Add to Home Screen).\n'
                    '3. Готово! Иконка появится рядом с остальными приложениями.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Tech Stack Highlights
          Text(
            'Архитектура и технологии:',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _TechChip(label: 'Flutter 3 (Multi-platform)'),
              _TechChip(label: 'Clean Architecture & DDD'),
              _TechChip(label: 'Drift / SQLite Offline DB'),
              _TechChip(label: 'FSRS Spaced Repetition'),
              _TechChip(label: 'RTL & Bidi Unicode Isolation'),
              _TechChip(label: 'Hebrew Niqqud Vocalization'),
              _TechChip(label: '7 Binyanim Morpho-Parser'),
              _TechChip(label: 'Web Speech API & Audio TTS'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsetsDirectional.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsetsDirectional.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.copy_rounded, size: 16),
          ],
        ),
      ),
    );
  }
}

class _TechChip extends StatelessWidget {
  const _TechChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}
