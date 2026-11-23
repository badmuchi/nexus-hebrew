import 'package:flutter/material.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../../srs/domain/entities/srs_card.dart';
import '../../../srs/domain/usecases/add_card_to_srs.dart';
import '../../domain/entities/apartment_listing.dart';

/// Interactive Yad2 real estate ad decoder card with abbreviation explanations and trap warnings.
class Yad2ListingDecoderCard extends StatefulWidget {
  final ApartmentListing listing;
  final AudioPlaybackService? audioService;
  final AddCardToSrsUseCase? addCardToSrsUseCase;

  const Yad2ListingDecoderCard({
    super.key,
    required this.listing,
    this.audioService,
    this.addCardToSrsUseCase,
  });

  @override
  State<Yad2ListingDecoderCard> createState() => _Yad2ListingDecoderCardState();
}

class _Yad2ListingDecoderCardState extends State<Yad2ListingDecoderCard> {
  Yad2Abbreviation? _selectedAbbreviation;

  void _onSelectAbbreviation(Yad2Abbreviation abbr) {
    setState(() {
      _selectedAbbreviation =
          _selectedAbbreviation?.id == abbr.id ? null : abbr;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final a = widget.listing;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Header with Price Badge and City
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(
                bottom: BorderSide(color: Colors.deepPurple.shade100),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${a.cityRu} • ${a.neighborhoodRu}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      a.neighborhoodHebrewWithNikkud,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple.shade800,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade700,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '₪${a.priceMonthlyShekels} / мес',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (widget.audioService != null)
                      IconButton(
                        icon: const Icon(Icons.volume_up_rounded, size: 20),
                        tooltip: 'Озвучить объявление',
                        onPressed: () =>
                            widget.audioService?.playWithTtsFallback(
                          sourcePath: null,
                          fallbackHebrewText: a.rawAdTextHebrew,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Quick Feature Badges Row
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _FeatureBadge(
                      label: '${a.roomsCount} комн.',
                      icon: Icons.meeting_room_outlined,
                      color: Colors.blue.shade700,
                    ),
                    _FeatureBadge(
                      label: '${a.squareMeters} מ״ר (м²)',
                      icon: Icons.square_foot_rounded,
                      color: Colors.blue.shade700,
                    ),
                    _FeatureBadge(
                      label: 'Этаж ${a.floor}',
                      icon: Icons.stairs_outlined,
                      color: Colors.grey.shade800,
                    ),
                    _FeatureBadge(
                      label: a.hasMamad ? 'МАМАД ✅' : 'Без МАМАДа ⚠️',
                      icon: Icons.shield_outlined,
                      color: a.hasMamad
                          ? Colors.green.shade800
                          : Colors.orange.shade900,
                    ),
                    _FeatureBadge(
                      label: a.hasElevator ? 'Лифт ✅' : 'Без лифта',
                      icon: Icons.elevator_outlined,
                      color: a.hasElevator
                          ? Colors.teal.shade800
                          : Colors.grey.shade700,
                    ),
                    _FeatureBadge(
                      label: a.hasDudShemesh ? 'Бойлер ☀️' : 'Электро',
                      icon: Icons.wb_sunny_outlined,
                      color: Colors.amber.shade900,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Original Yad2 ad text
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant
                          .withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Текст объявления в оригинале (Yad2):',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        a.rawAdTextHebrew,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 14.5,
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Abbreviation chips header
                const Text(
                  'Нажми на сокращение для расшифровки:',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),

                // Abbreviation filter chips
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: a.abbreviationsUsed.map((abbr) {
                    final isSel = _selectedAbbreviation?.id == abbr.id;
                    return FilterChip(
                      selected: isSel,
                      label: Text(abbr.abbreviationHebrew),
                      selectedColor:
                          Colors.deepPurple.withValues(alpha: 0.2),
                      checkmarkColor: Colors.deepPurple,
                      onSelected: (_) => _onSelectAbbreviation(abbr),
                    );
                  }).toList(),
                ),

                // Detailed Abbreviation Explanation Box
                if (_selectedAbbreviation != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.deepPurple.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedAbbreviation!.translationRu,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                                color: Colors.deepPurple,
                              ),
                            ),
                            Text(
                              _selectedAbbreviation!.fullHebrewWithNikkud,
                              textDirection: TextDirection.rtl,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '(${_selectedAbbreviation!.transcriptionRu})',
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '💡 ${_selectedAbbreviation!.significanceRu}',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.brown.shade900,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                // Hidden Traps Card
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('⚠️ ', style: TextStyle(fontSize: 18)),
                      Expanded(
                        child: Text(
                          a.hiddenTrapWarningRu,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.brown.shade900,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                // Add to SRS
                if (widget.addCardToSrsUseCase != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                      label: const Text('В карточки FSRS'),
                      onPressed: () async {
                        final res = await widget.addCardToSrsUseCase?.call(
                          AddCardToSrsParams(
                            id: 'yad2_${a.id}',
                            hebrewVocalized: a.neighborhoodHebrewWithNikkud,
                            russianTranslation:
                                '${a.cityRu}, ${a.neighborhoodRu} (${a.roomsCount} комн., ₪${a.priceMonthlyShekels})',
                            category: LexicalCategory.noun,
                            exampleHebrewVocalized: a.neighborhoodHebrewWithNikkud,
                            exampleRussian: '${a.cityRu}, ${a.neighborhoodRu}',
                          ),
                        );
                        if (context.mounted) {
                          final msg = (res?.isSuccess ?? false)
                              ? '«${a.neighborhoodRu}» добавлено в FSRS!'
                              : 'Уже есть в колоде или ошибка';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(msg),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _FeatureBadge({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
