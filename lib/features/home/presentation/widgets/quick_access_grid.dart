import 'package:flutter/material.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../ai_roleplay/presentation/screens/ai_roleplay_catalog_screen.dart';
import '../../../alphabet/presentation/screens/alphabet_screen.dart';
import '../../../banking/presentation/screens/banking_services_screen.dart';
import '../../../career/presentation/screens/job_interview_simulator_screen.dart';
import '../../../chat_slang/presentation/screens/israeli_chat_simulator_screen.dart';
import '../../../cursive/presentation/screens/cursive_decryptor_screen.dart';
import '../../../driving/presentation/screens/driving_roads_screen.dart';
import '../../../grammar/presentation/widgets/sentence_builder_view.dart';
import '../../../health/presentation/screens/health_clinic_screen.dart';
import '../../../holidays/presentation/screens/holidays_shabbat_screen.dart';
import '../../../housing/presentation/screens/apartment_rental_screen.dart';
import '../../../numbers/presentation/screens/numbers_cashier_screen.dart';
import '../../../scenes/data/repositories/scenes_repository_impl.dart';
import '../../../scenes/presentation/screens/scenes_catalog_screen.dart';
import '../../../shoresh/presentation/screens/shoresh_catalog_screen.dart';
import '../../../slang/data/datasources/slang_seed_datasource.dart';
import '../../../slang/data/repositories/slang_repository_impl.dart';
import '../../../slang/domain/usecases/get_slang_expressions.dart';
import '../../../slang/presentation/screens/slang_screen.dart';
import '../../../speech_lab/presentation/screens/speech_lab_screen.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../../stories/presentation/screens/stories_catalog_view.dart';
import '../../../yael_exam/presentation/screens/yael_exam_screen.dart';

/// Interactive grid of feature launch tiles on the Home dashboard.
class QuickAccessGrid extends StatelessWidget {
  final ValueChanged<int>? onNavigateToTab;
  final AudioPlaybackService? audioService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;
  final GetSlangExpressionsUseCase? getSlangUseCase;
  final AppDatabase? database;

  const QuickAccessGrid({
    super.key,
    this.onNavigateToTab,
    this.audioService,
    this.addCardToSrsUseCase,
    this.getSlangUseCase,
    this.database,
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
        title: 'AI-Собеседник',
        hebrewTitle: 'שִׂיחָה עִם AI',
        description: 'Живые диалоги, распознавание речи и разбор ошибок',
        icon: Icons.smart_toy_rounded,
        color: const Color(0xFF00838F),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => AiRoleplayCatalogScreen(
              audioService: audioService,
              addCardToSrsUseCase: addCardToSrsUseCase,
            ),
          ),
        ),
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
                  database: database,
                ),
              ),
            );
          }
        },
      ),
      _QuickItem(
        title: 'Израильский сленг',
        hebrewTitle: 'סְלֶנְג',
        description: 'Улица, кафе, Тель-Авив, армия и эмоции',
        icon: Icons.chat_bubble_outline_rounded,
        color: const Color(0xFFD81B60),
        onTap: () {
          final useCase = getSlangUseCase ??
              GetSlangExpressionsUseCase(
                SlangRepositoryImpl(
                  dataSource: AssetSlangSeedDataSource(
                    logger: const DeveloperAppLogger(),
                  ),
                ),
              );
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => SlangScreen(
                getSlangUseCase: useCase,
                audioService: audioService,
                addCardToSrsUseCase: addCardToSrsUseCase,
              ),
            ),
          );
        },
      ),
      _QuickItem(
        title: 'Матрица корней',
        hebrewTitle: 'שָׁרָשִׁים',
        description: 'Трансформатор корня в 7 пород (Биньяним)',
        icon: Icons.hub_rounded,
        color: const Color(0xFF6A1B9A),
        onTap: () => onNavigateToTab?.call(3),
      ),
      _QuickItem(
        title: 'Лаборатория речи',
        hebrewTitle: 'הִגּוּי וְדִבּוּר',
        description: 'Тренажёр произношения, гортанные звуки и AI-оценка',
        icon: Icons.record_voice_over_rounded,
        color: const Color(0xFFE91E63),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => SpeechLabScreen(
                audioService: audioService,
                addCardToSrsUseCase: addCardToSrsUseCase,
              ),
            ),
          );
        },
      ),
      _QuickItem(
        title: 'Конструктор фраз',
        hebrewTitle: 'מִבְנֶה מִשְׁפָּט',
        description: 'Сборка предложений, синтаксис и порядок слов',
        icon: Icons.construction_rounded,
        color: const Color(0xFF00796B),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => Scaffold(
                appBar: AppBar(title: const Text('Конструктор предложений')),
                body: SentenceBuilderView(
                  audioService: audioService,
                  addCardToSrsUseCase: addCardToSrsUseCase,
                ),
              ),
            ),
          );
        },
      ),
      _QuickItem(
        title: 'Шореш-Детектив',
        hebrewTitle: 'בַּלָּשׁ הַשֹּׁרֶשׁ',
        description: 'Лаборатория 35 корней, древо слов и детектив-квиз',
        icon: Icons.biotech_rounded,
        color: const Color(0xFF00897B),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ShoreshCatalogScreen(
                audioService: audioService,
                addCardToSrsUseCase: addCardToSrsUseCase,
              ),
            ),
          );
        },
      ),
      _QuickItem(
        title: 'Реальный Израиль',
        hebrewTitle: 'חַיִּים בְּיִשְׂרָאֵל',
        description: 'Бытовые сцены: супермаркет, рав-кав, мисрад а-пним',
        icon: Icons.location_city_rounded,
        color: const Color(0xFF0288D1),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ScenesCatalogScreen(
                repository: ScenesRepositoryImpl(),
                audioService: audioService,
                addCardToSrsUseCase: addCardToSrsUseCase,
              ),
            ),
          );
        },
      ),
      _QuickItem(
        title: 'Касса и Шекели',
        hebrewTitle: 'קֻפָּה וּמִסְפָּרִים',
        description: 'Числа, перевернутый род, счет шекелей и касса Шуферсаль',
        icon: Icons.point_of_sale_rounded,
        color: const Color(0xFFF57F17),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => NumbersCashierScreen(
                audioService: audioService,
                addCardToSrsUseCase: addCardToSrsUseCase,
              ),
            ),
          );
        },
      ),
      _QuickItem(
        title: 'Дешифровщик Ктав Яд',
        hebrewTitle: 'כְּתָב יָד',
        description: 'Рукописные записки соседей, ваад байт, поликлиники и списки',
        icon: Icons.draw_rounded,
        color: const Color(0xFF6A1B9A),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => CursiveDecryptorScreen(
                audioService: audioService,
                addCardToSrsUseCase: addCardToSrsUseCase,
              ),
            ),
          );
        },
      ),
      _QuickItem(
        title: 'Карьера и Тлуш',
        hebrewTitle: 'רֵאָיוֹן וְתְלוּשׁ',
        description: 'Собеседование в хайтек, тлуш маскорет, налоги и офисный сленг',
        icon: Icons.badge_rounded,
        color: const Color(0xFF00695C),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => JobInterviewSimulatorScreen(
                audioService: audioService,
                addCardToSrsUseCase: addCardToSrsUseCase,
              ),
            ),
          );
        },
      ),
      _QuickItem(
        title: 'Врачи и Аптека',
        hebrewTitle: 'בְּרִיאוּת וּמִרְפָּאָה',
        description: 'Части тела, симптомы, купат холим, супер-фарм и скорая',
        icon: Icons.medical_services_rounded,
        color: const Color(0xFFD32F2F),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => HealthClinicScreen(
                audioService: audioService,
                addCardToSrsUseCase: addCardToSrsUseCase,
              ),
            ),
          );
        },
      ),
      _QuickItem(
        title: 'Вождение и Waze',
        hebrewTitle: 'נְהִיגָה וַחֲנָיָה',
        description: 'Цвета бордюров, Pango, голосовой Waze, заправка и полиция',
        icon: Icons.directions_car_rounded,
        color: const Color(0xFFE65100),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => DrivingRoadsScreen(
                audioService: audioService,
                addCardToSrsUseCase: addCardToSrsUseCase,
              ),
            ),
          );
        },
      ),
      _QuickItem(
        title: 'Аренда и Договор',
        hebrewTitle: 'שְׂכִירוּת וְדִירָה',
        description: 'Объявления Yad2, чеки безопасности, поломки и арнона',
        icon: Icons.apartment_rounded,
        color: const Color(0xFF4527A0),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ApartmentRentalScreen(
                audioService: audioService,
                addCardToSrsUseCase: addCardToSrsUseCase,
              ),
            ),
          );
        },
      ),
      _QuickItem(
        title: 'Шаббат и Традиции',
        hebrewTitle: 'שַׁבָּת וְחַגִּים',
        description: 'Календарь праздников, сирены, транспорт в Шаббат и застольный этикет',
        icon: Icons.celebration_rounded,
        color: const Color(0xFFC2185B),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => HolidaysShabbatScreen(
                audioService: audioService,
                addCardToSrsUseCase: addCardToSrsUseCase,
              ),
            ),
          );
        },
      ),
      _QuickItem(
        title: 'Экзамен Яэль',
        hebrewTitle: 'מִבְחַן יַעֵ״ל',
        description: 'Академический иврит, тексты, синтаксис предлогов и сертификат',
        icon: Icons.school_rounded,
        color: const Color(0xFF1565C0),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => YaelExamScreen(
                audioService: audioService,
                addCardToSrsUseCase: addCardToSrsUseCase,
              ),
            ),
          );
        },
      ),
      _QuickItem(
        title: 'Сленг WhatsApp',
        hebrewTitle: 'וָואטְסְאַפּ וּסְלֶנְג',
        description: 'Сокращения, переписки ваад байта, хайтек-команды и аудио-войсы',
        icon: Icons.chat_bubble_rounded,
        color: const Color(0xFF00796B),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => IsraeliChatSimulatorScreen(
                audioService: audioService,
                addCardToSrsUseCase: addCardToSrsUseCase,
              ),
            ),
          );
        },
      ),
      _QuickItem(
        title: 'Банк и Машканта',
        hebrewTitle: 'בַּנְק וּמַשְׁכַּנְתָּא',
        description: 'Чеки, овердрафт, открытие счета, машканта и Битуах Леуми',
        icon: Icons.account_balance_rounded,
        color: const Color(0xFF0D47A1),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => BankingServicesScreen(
                audioService: audioService,
                addCardToSrsUseCase: addCardToSrsUseCase,
              ),
            ),
          );
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
