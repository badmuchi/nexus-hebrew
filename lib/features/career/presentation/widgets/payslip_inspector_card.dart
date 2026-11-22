import 'package:flutter/material.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../srs/domain/entities/srs_card.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../domain/entities/payslip_item.dart';

/// Interactive Israeli Payslip (תלוש משכורת) inspector widget with line-by-line breakdown.
class PayslipInspectorCard extends StatefulWidget {
  final IsraeliPayslip payslip;
  final AudioPlaybackService? audioService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;

  const PayslipInspectorCard({
    super.key,
    required this.payslip,
    this.audioService,
    this.addCardToSrsUseCase,
  });

  @override
  State<PayslipInspectorCard> createState() => _PayslipInspectorCardState();
}

class _PayslipInspectorCardState extends State<PayslipInspectorCard> {
  int _selectedFilterIndex = 0; // 0: All, 1: Deductions, 2: Employer benefits

  List<PayslipItem> get _filteredItems {
    switch (_selectedFilterIndex) {
      case 1:
        return widget.payslip.items.where((i) => i.isDeduction).toList();
      case 2:
        return widget.payslip.items
            .where((i) => i.isEmployerContribution)
            .toList();
      default:
        return widget.payslip.items;
    }
  }

  void _showItemDetails(PayslipItem item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.titleRu,
                        style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    if (widget.audioService != null)
                      IconButton.filledTonal(
                        icon: const Icon(Icons.volume_up_rounded),
                        tooltip: 'Озвучить термин',
                        onPressed: () =>
                            widget.audioService?.playWithTtsFallback(
                          sourcePath: null,
                          fallbackHebrewText: item.hebrewWithNikkud,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.hebrewWithNikkud,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(ctx).colorScheme.primary,
                        height: 1.45,
                      ),
                ),
                Text(
                  '(${item.transcriptionRu})',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '💡 Что это означает в Израиле:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(item.explanationRu),
                      const SizedBox(height: 8),
                      const Text(
                        '⚖️ Закон и права:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(item.lawOrTipRu),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (widget.addCardToSrsUseCase != null)
                  FilledButton.icon(
                    icon: const Icon(Icons.bookmark_add_rounded),
                    label: const Text('Добавить в словарь повторения'),
                    onPressed: () async {
                      final res = await widget.addCardToSrsUseCase?.call(
                        AddCardToSrsParams(
                          id: 'payslip_${item.id}',
                          hebrewVocalized: item.hebrewWithNikkud,
                          russianTranslation:
                              '${item.titleRu} (${item.transcriptionRu}) — ${item.explanationRu}',
                          category: LexicalCategory.noun,
                          exampleHebrewVocalized: item.hebrewWithNikkud,
                          exampleRussian: item.titleRu,
                        ),
                      );
                      if (ctx.mounted) {
                        Navigator.of(ctx).pop();
                      }
                      if (mounted) {
                        final msg = (res?.isSuccess ?? false)
                            ? '«${item.hebrewPlain}» добавлен в FSRS карточки!'
                            : 'Уже есть в колоде или ошибка';
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(msg)),
                        );
                      }
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = widget.payslip;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Payslip Official Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        p.employerNameRu,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      p.monthYearHebrew,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${p.employeeNameRu} • ${p.roleTitleRu}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Divider(height: 20),
                // Key metrics row
                Row(
                  children: [
                    Expanded(
                      child: _MetricBadge(
                        title: 'Брутто',
                        amount: '₪${p.grossSalaryShekels.toStringAsFixed(0)}',
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MetricBadge(
                        title: 'Вычеты',
                        amount: '-₪${p.totalDeductions.toStringAsFixed(0)}',
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MetricBadge(
                        title: 'Нетто в банк',
                        amount: '₪${p.netSalary.toStringAsFixed(0)}',
                        color: Colors.green.shade700,
                        isHighlighted: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Nekudot Zikuy Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.amber.shade50,
            child: Row(
              children: [
                const Icon(Icons.stars_rounded, color: Colors.amber, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.brown.shade900, fontSize: 13),
                      children: [
                        const TextSpan(
                          text: 'Льготные баллы (נְקֻדּוֹת זִכּוּי): ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              '${p.nekudotZikuy} пт. (скидка ₪${p.nekudotZikuyValueMonthly.toStringAsFixed(0)}/мес)',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filter chips
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Все статьи'),
                  selected: _selectedFilterIndex == 0,
                  onSelected: (val) {
                    if (val) setState(() => _selectedFilterIndex = 0);
                  },
                ),
                ChoiceChip(
                  label: const Text('Налоги и вычеты'),
                  selected: _selectedFilterIndex == 1,
                  onSelected: (val) {
                    if (val) setState(() => _selectedFilterIndex = 1);
                  },
                ),
                ChoiceChip(
                  label: const Text('Взносы работодателя'),
                  selected: _selectedFilterIndex == 2,
                  onSelected: (val) {
                    if (val) setState(() => _selectedFilterIndex = 2);
                  },
                ),
              ],
            ),
          ),

          // Line items list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filteredItems.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = _filteredItems[index];
              final isDed = item.isDeduction;
              final isEmp = item.isEmployerContribution;

              final Color amountColor = isDed
                  ? Colors.red.shade700
                  : (isEmp ? Colors.indigo.shade600 : Colors.green.shade800);

              final String prefix = isDed ? '-' : '+';
              final String suffix = isEmp ? ' (накопл.)' : '';

              return ListTile(
                onTap: () => _showItemDetails(item),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${item.category.emoji} ${item.titleRu}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      item.hebrewWithNikkud,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.transcriptionRu,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    Text(
                      '$prefix₪${item.amountShekels.toStringAsFixed(2)}$suffix',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: amountColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                trailing: const Icon(Icons.info_outline_rounded, size: 20),
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _MetricBadge extends StatelessWidget {
  final String title;
  final String amount;
  final Color color;
  final bool isHighlighted;

  const _MetricBadge({
    required this.title,
    required this.amount,
    required this.color,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: isHighlighted
            ? color.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isHighlighted ? color : Colors.grey.shade300,
          width: isHighlighted ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            child: Text(
              amount,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
