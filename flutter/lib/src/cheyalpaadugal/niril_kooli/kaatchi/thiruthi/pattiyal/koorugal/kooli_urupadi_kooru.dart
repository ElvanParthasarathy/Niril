import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import 'package:intl/intl.dart';

import '../../../../../../koorugal/podhu_koorugal/elvan_thiruthi_attai_kooru.dart';
import '../../../../../niril_podhu/kaatchi/koorugal/porul_thaedu_kooru.dart';
import '../../../../../niril_podhu/tharavuru/pattiyal_tharavuru.dart';

/// Builds a single coolie line-item row: header label + delete + ElvanUrupadiAttai.
class KooliUrupadiKooru extends ConsumerStatefulWidget {
  final int index;
  final KooliUrupadi item;
  final int itemCount;
  final NumberFormat formatter;
  final ValueChanged<KooliUrupadi> onUpdated;
  final VoidCallback onDeleted;
  final VoidCallback? onRequestAddNewProduct;

  const KooliUrupadiKooru({
    super.key,
    required this.index,
    required this.item,
    required this.itemCount,
    required this.formatter,
    required this.onUpdated,
    required this.onDeleted,
    this.onRequestAddNewProduct,
  });

  @override
  ConsumerState<KooliUrupadiKooru> createState() => _KooliUrupadiKooruState();
}

class _KooliUrupadiKooruState extends ConsumerState<KooliUrupadiKooru> {
  late final TextEditingController _edaiCtrl;
  late final TextEditingController _vilaiCtrl;

  @override
  void initState() {
    super.initState();
    _edaiCtrl = TextEditingController(
      text: widget.item.edai > 0 ? widget.item.edai.toString() : '',
    );
    _vilaiCtrl = TextEditingController(
      text: widget.item.vilai > 0 ? widget.item.vilai.toString() : '',
    );
  }

  @override
  void didUpdateWidget(covariant KooliUrupadiKooru oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync controllers when parent pushes new values (e.g. product selected
    // sets a default rate), but NOT while the user is actively editing.
    if (oldWidget.item.edai != widget.item.edai) {
      final current = double.tryParse(_edaiCtrl.text) ?? 0;
      if (current != widget.item.edai) {
        _edaiCtrl.text =
            widget.item.edai > 0 ? widget.item.edai.toString() : '';
      }
    }
    if (oldWidget.item.vilai != widget.item.vilai) {
      final current = double.tryParse(_vilaiCtrl.text) ?? 0;
      if (current != widget.item.vilai) {
        _vilaiCtrl.text =
            widget.item.vilai > 0 ? widget.item.vilai.toString() : '';
      }
    }
  }

  @override
  void dispose() {
    _edaiCtrl.dispose();
    _vilaiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final item = widget.item;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          // Item #N header + trash
          Row(
            children: [
              Text('${K.porul.tr(context, ref)} #${widget.index + 1}',
                  style: tt.titleSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  )),
              const Spacer(),
              if (widget.itemCount > 1)
                IconButton(
                  icon: Icon(Icons.delete_outline,
                      color: cs.error, size: 20),
                  onPressed: widget.onDeleted,
                ),
            ],
          ),
          const SizedBox(height: 4),
          ElvanUrupadiAttai(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    // Product search — wider
                    SizedBox(
                      width: 280,
                      child: PorulThaeduKooru(
                        seyaliVagai: 'coolie',
                        initialText: item.porulPeyar,
                        onSelected: (p) {
                          final tamilName = p.porulPeyar['Tamil'] ?? '';
                          final englishName = p.porulPeyar['English'] ?? '';
                          widget.onUpdated(item.copyWith(
                            porulId: p.id.toString(),
                            porulPeyar: tamilName.isNotEmpty
                                ? tamilName
                                : englishName,
                            porulPeyarEn: tamilName.isNotEmpty
                                ? englishName
                                : '',
                            vilai: p.vilai,
                          ));
                        },
                        onRequestAddNew: widget.onRequestAddNewProduct,
                      ),
                    ),
                    // Weight (kg)
                    SizedBox(
                      width: 120,
                      child: TextFormField(
                        controller: _edaiCtrl,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: K.kiKi.tr(context, ref),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 12),
                          isDense: true,
                        ),
                        onChanged: (v) {
                          widget.onUpdated(
                            item.copyWith(edai: double.tryParse(v) ?? 0),
                          );
                        },
                      ),
                    ),
                    // Rate (per kg)
                    SizedBox(
                      width: 120,
                      child: TextFormField(
                        controller: _vilaiCtrl,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: K.vilaiKiKi.tr(context, ref),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 12),
                          isDense: true,
                        ),
                        onChanged: (v) {
                          widget.onUpdated(
                            item.copyWith(vilai: double.tryParse(v) ?? 0),
                          );
                        },
                      ),
                    ),
                    // Row total (read-only)
                    SizedBox(
                      width: 120,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                            '₹${widget.formatter.format(item.varisaiThogai)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: cs.primary,
                            )),
                      ),
                    ),
                  ],
                ),
                // English subtitle
                if (item.porulPeyarEn.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      item.porulPeyarEn,
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
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
