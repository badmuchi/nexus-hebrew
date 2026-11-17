import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../../core/widgets/hebrew_niqqud_keyboard.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../domain/services/custom_text_story_parser.dart';
import '../cubit/stories_cubit.dart';
import '../screens/story_reader_screen.dart';

/// Modal bottom sheet allowing users to paste any Hebrew article, news item,
/// or social media text and instantly read it with synchronized TTS and dictionary lookup.
Future<void> showCustomTextImporterSheet({
  required BuildContext context,
  required AudioPlaybackService audioService,
  required AddCardToSrsUseCase addCardToSrsUseCase,
}) {
  final storiesCubit = context.read<StoriesCubit>();

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (modalContext) {
      return BlocProvider.value(
        value: storiesCubit,
        child: _CustomTextImporterContent(
          audioService: audioService,
          addCardToSrsUseCase: addCardToSrsUseCase,
        ),
      );
    },
  );
}

class _CustomTextImporterContent extends StatefulWidget {
  final AudioPlaybackService audioService;
  final AddCardToSrsUseCase addCardToSrsUseCase;

  const _CustomTextImporterContent({
    required this.audioService,
    required this.addCardToSrsUseCase,
  });

  @override
  State<_CustomTextImporterContent> createState() =>
      _CustomTextImporterContentState();
}

class _CustomTextImporterContentState
    extends State<_CustomTextImporterContent> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  bool _showKeyboard = false;

  static const _samples = [
    (
      title: 'Новости технологий',
      text:
          'תֵּל אָבִיב הִיא מֶרְכַּז הַהַיְטֶק שֶׁל יִשְׂרָאֵל. הַרְבֵּה חֲבָרוֹת סְטַארְט-אַפּ פּוֹתְחוֹת כָּאן מִשְׂרָדִים חֲדָשִׁים.',
    ),
    (
      title: 'Погода и море',
      text:
          'הַיּוֹם מֶזֶג הָאֲוִיר חַם וְיָפֶה. אֲנָשִׁים רַבִּים הוֹלְכִים לַיָּם לִשְׂחוֹת וּלְשַׂחֵק בְּמַטְקוֹת.',
    ),
    (
      title: 'Рынок в Иерусалиме',
      text:
          'בְּשׁוּק מַחֲנֵה יְהוּדָה בִּירוּשָׁלַיִם יֵשׁ פֵּרוֹת, יְרָקוֹת, מַאֲפִים וְתַבְלִינִים מְצוּיָנִים.',
    ),
  ];

  @override
  void dispose() {
    _textController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _openInReader() {
    final rawText = _textController.text.trim();
    if (rawText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пожалуйста, вставьте или напишите текст на иврите'),
        ),
      );
      return;
    }

    final story = CustomTextStoryParser.parse(
      rawText: rawText,
      titleRussian: _titleController.text.trim().isNotEmpty
          ? _titleController.text.trim()
          : null,
    );

    final storiesCubit = context.read<StoriesCubit>();
    Navigator.of(context).pop();

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: storiesCubit,
          child: StoryReaderScreen(
            story: story,
            audioService: widget.audioService,
            addCardToSrsUseCase: widget.addCardToSrsUseCase,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: bottomInset + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.auto_stories_rounded,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Умная читалка любого текста',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Вставь новость, пост или песню с разбором слов',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Название текста (необязательно)',
                hintText: 'Например: Заметка из новостей Ynet',
                prefixIcon: const Icon(Icons.title_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Directionality(
              textDirection: TextDirection.rtl,
              child: TextField(
                controller: _textController,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.start,
                minLines: 4,
                maxLines: 8,
                decoration: InputDecoration(
                  labelText: 'Текст на иврите (с огласовками или без)',
                  hintText: 'הַדְבֵּק כָּאן אֶת הַטֶּקְסְט שֶׁלְּךָ...',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showKeyboard
                          ? Icons.keyboard_hide_rounded
                          : Icons.keyboard_rounded,
                      color: _showKeyboard ? theme.colorScheme.primary : null,
                    ),
                    tooltip: 'Экранная клавиатура иврита',
                    onPressed: () {
                      setState(() {
                        _showKeyboard = !_showKeyboard;
                      });
                    },
                  ),
                ),
              ),
            ),
            if (_showKeyboard) ...[
              const SizedBox(height: 8),
              HebrewNiqqudKeyboard(
                controller: _textController,
                onClose: () => setState(() => _showKeyboard = false),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              'Или выберите готовый образец для теста:',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final sample in _samples)
                  ActionChip(
                    avatar: const Icon(Icons.article_outlined, size: 16),
                    label: Text(sample.title),
                    onPressed: () {
                      setState(() {
                        _titleController.text = sample.title;
                        _textController.text = sample.text;
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.menu_book_rounded),
              label: const Text(
                'Читать с умным переводом и озвучкой',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              onPressed: _openInReader,
            ),
          ],
        ),
      ),
    );
  }
}
