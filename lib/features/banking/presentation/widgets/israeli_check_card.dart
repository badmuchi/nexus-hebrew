import 'package:flutter/material.dart';

import '../../../../core/audio/audio_playback_service.dart';
import '../../domain/entities/bank_service_item.dart';

/// Graphic simulator of an authentic Israeli bank check with security rules.
class IsraeliCheckCard extends StatelessWidget {
  final IsraeliCheckModel check;
  final AudioPlaybackService? audioService;

  const IsraeliCheckCard({
    super.key,
    required this.check,
    this.audioService,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Check Header Banner
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('🏦 ', style: TextStyle(fontSize: 20)),
                    Text(
                      check.bankName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.5,
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                  ],
                ),
                Text(
                  check.branchNumber,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Authentic Bank Check Container
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FBE7), // Light check paper tone
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFC5E1A5), width: 1.5),
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top Row: Date & Check Number
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'מס׳ צ׳ק: ${check.checkNumber}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                              color: Colors.brown,
                            ),
                          ),
                          Row(
                            children: [
                              const Text('תאריך: ', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.brown.shade300),
                                  borderRadius: BorderRadius.circular(4),
                                  color: Colors.white,
                                ),
                                child: Text(
                                  check.dateString,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Payee Row: שַׁלְמוּ לְפִי פְּקֻדַּת
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'שַׁלְמוּ לְפִי פְּקֻדַּת: ',
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: const BoxDecoration(
                                border: Border(bottom: BorderSide(color: Colors.brown, width: 1.5)),
                              ),
                              child: Directionality(
                                textDirection: TextDirection.rtl,
                                child: Text(
                                  check.payeeHebrewWithNikkud,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    height: 1.45,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Amount in words: סְכוּם בְּמִלִּים
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'סְכוּם בְּמִלִּים: ',
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: const BoxDecoration(
                                border: Border(bottom: BorderSide(color: Colors.brown, width: 1.5)),
                              ),
                              child: Directionality(
                                textDirection: TextDirection.rtl,
                                child: Text(
                                  check.amountInHebrewWordsWithNikkud,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    height: 1.45,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (audioService != null)
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.volume_up_rounded, size: 18),
                              tooltip: 'Озвучить сумму прописью',
                              onPressed: () => audioService?.playWithTtsFallback(
                                sourcePath: null,
                                fallbackHebrewText: check.amountInHebrewWordsWithNikkud,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Bottom Row: Amount Box in NIS & Account Number
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'חשבון: ${check.accountNumber}',
                            style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: Colors.brown),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.brown, width: 1.5),
                            ),
                            child: Text(
                              '₪ ${check.amountShekels.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1B5E20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Overlay stamp: למוטב בלבד
                  if (check.isPayeeOnlyRestricted)
                    Positioned(
                      top: 18,
                      left: 10,
                      child: Transform.rotate(
                        angle: -0.15,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red.shade800, width: 1.8),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'לַמּוּטָב בִּלְבַד',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: Colors.red.shade800,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Cross lines //
                  if (check.hasCrossLines)
                    Positioned(
                      top: 0,
                      left: 60,
                      child: Transform.rotate(
                        angle: 0.35,
                        child: Row(
                          children: [
                            Container(width: 2, height: 26, color: Colors.black87),
                            const SizedBox(width: 4),
                            Container(width: 2, height: 26, color: Colors.black87),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Security Rule Explanation
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡 ', style: TextStyle(fontSize: 18)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Назначение: ${check.purposeRu}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          check.securityTipRu,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.brown.shade900,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
