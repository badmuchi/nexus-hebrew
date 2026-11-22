import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Denominations of legal tender in the State of Israel (New Israeli Shekels / ₪).
enum IsraeliCurrencyUnit {
  coin1(1, '₪1', 'שֶׁקֶל', Color(0xFFCFD8DC), isCoin: true),
  coin2(2, '₪2', 'שְׁנֵי שְׁקָלִים', Color(0xFFB0BEC5), isCoin: true),
  coin5(5, '₪5', 'חֲמִשָּׁה', Color(0xFF90A4AE), isCoin: true),
  coin10(10, '₪10', 'עֲשָׂרָה', Color(0xFFFFD54F), isCoin: true), // Gold & silver ring
  note20(20, '₪20', 'עֶשְׂרִים', Color(0xFFE53935), isCoin: false), // Red
  note50(50, '₪50', 'חֲמִשִּׁים', Color(0xFF43A047), isCoin: false), // Green
  note100(100, '₪100', 'מֵאָה', Color(0xFFFB8C00), isCoin: false), // Orange
  note200(200, '₪200', 'מָאתַיִם', Color(0xFF1E88E5), isCoin: false); // Blue

  final int value;
  final String label;
  final String hebrewShort;
  final Color baseColor;
  final bool isCoin;

  const IsraeliCurrencyUnit(
    this.value,
    this.label,
    this.hebrewShort,
    this.baseColor, {
    required this.isCoin,
  });
}

/// Interactive tray of Israeli coins and banknotes allowing learners to pay
/// exact change and build muscle memory for Hebrew money amounts.
class IsraeliCoinsCounter extends StatefulWidget {
  final int? targetAmount;
  final ValueChanged<int>? onAmountSubmitted;

  const IsraeliCoinsCounter({
    super.key,
    this.targetAmount,
    this.onAmountSubmitted,
  });

  @override
  State<IsraeliCoinsCounter> createState() => _IsraeliCoinsCounterState();
}

class _IsraeliCoinsCounterState extends State<IsraeliCoinsCounter> {
  int _currentTotal = 0;
  final Map<int, int> _counts = {};

  void _add(IsraeliCurrencyUnit unit) {
    unawaited(HapticFeedback.lightImpact());
    setState(() {
      _currentTotal += unit.value;
      _counts[unit.value] = (_counts[unit.value] ?? 0) + 1;
    });
  }

  void _clear() {
    unawaited(HapticFeedback.selectionClick());
    setState(() {
      _currentTotal = 0;
      _counts.clear();
    });
  }

  void _submit() {
    unawaited(HapticFeedback.mediumImpact());
    widget.onAmountSubmitted?.call(_currentTotal);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExact = widget.targetAmount != null && _currentTotal == widget.targetAmount;
    final isOver = widget.targetAmount != null && _currentTotal > widget.targetAmount!;

    return Container(
      padding: const EdgeInsetsDirectional.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isExact
              ? const Color(0xFF2E7D32)
              : (isOver ? Colors.red.shade400 : theme.colorScheme.outlineVariant.withValues(alpha: 0.6)),
          width: isExact ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cashier Display Screen
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1B2838), // Dark digital cash register screen
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF37474F)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ИТОГО К ОПЛАТЕ',
                      style: TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '₪$_currentTotal',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: isExact ? const Color(0xFF69F0AE) : Colors.amberAccent,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                if (widget.targetAmount != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'ЦЕЛЬ СУММЫ',
                        style: TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '₪${widget.targetAmount}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Coins Row
          Text(
            'Монеты (מַטְבְּעוֹת):',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (final unit in IsraeliCurrencyUnit.values.where((u) => u.isCoin))
                _buildCoinItem(unit),
            ],
          ),
          const SizedBox(height: 14),

          // Banknotes Row
          Text(
            'Банкноты (שְׁטָרוֹת):',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (final unit in IsraeliCurrencyUnit.values.where((u) => !u.isCoin))
                _buildNoteItem(unit),
            ],
          ),
          const SizedBox(height: 16),

          // Controls: Reset & Pay
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _currentTotal > 0 ? _clear : null,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Сброс'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _currentTotal > 0 ? _submit : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: isExact ? const Color(0xFF2E7D32) : theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.check_circle_rounded),
                  label: Text(
                    isExact ? 'Оплатить точно! ₪$_currentTotal' : 'Оплатить ₪$_currentTotal',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoinItem(IsraeliCurrencyUnit unit) {
    final count = _counts[unit.value] ?? 0;
    final is10 = unit.value == 10;

    return InkWell(
      onTap: () => _add(unit),
      borderRadius: BorderRadius.circular(24),
      child: Badge(
        label: Text('$count'),
        isLabelVisible: count > 0,
        backgroundColor: const Color(0xFF2E7D32),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: unit.baseColor,
            border: Border.all(
              color: is10 ? const Color(0xFFB0BEC5) : Colors.white70,
              width: is10 ? 3 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              unit.label,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoteItem(IsraeliCurrencyUnit unit) {
    final count = _counts[unit.value] ?? 0;

    return InkWell(
      onTap: () => _add(unit),
      borderRadius: BorderRadius.circular(8),
      child: Badge(
        label: Text('$count'),
        isLabelVisible: count > 0,
        backgroundColor: const Color(0xFF2E7D32),
        child: Container(
          width: 66,
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: unit.baseColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white70, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                unit.label,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  unit.hebrewShort,
                  style: const TextStyle(
                    fontSize: 8,
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
