import 'package:flutter/material.dart';

import '../../../../../../koorugal/podhu_koorugal/elvan_thiruthi_attai_kooru.dart';
import '../../../../../niril_podhu/tharavuru/pattiyal_tharavuru.dart';

/// Builds a dynamic "other charge" row inside an ElvanUrupadiAttai.
class KooliPiraVarivuKooru extends StatelessWidget {
  final int index;
  final PiraVarivu charge;
  final ValueChanged<PiraVarivu> onUpdated;
  final VoidCallback onDeleted;
  final VoidCallback onRecalculate;

  const KooliPiraVarivuKooru({
    super.key,
    required this.index,
    required this.charge,
    required this.onUpdated,
    required this.onDeleted,
    required this.onRecalculate,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            children: [
              Text('Other Charge #${index + 1}',
                  style: tt.titleSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  )),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.remove_circle_outline,
                    color: cs.error, size: 20),
                onPressed: onDeleted,
              ),
            ],
          ),
          const SizedBox(height: 4),
          ElvanUrupadiAttai(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    initialValue: charge.peyar,
                    decoration: const InputDecoration(
                      hintText: 'Charge Name',
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    ),
                    onChanged: (v) {
                      onUpdated(charge.copyWith(peyar: v));
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue:
                        charge.thogai > 0 ? charge.thogai.toString() : '',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      hintText: '₹',
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    ),
                    onChanged: (v) {
                      onUpdated(
                          charge.copyWith(thogai: double.tryParse(v) ?? 0));
                      onRecalculate();
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
