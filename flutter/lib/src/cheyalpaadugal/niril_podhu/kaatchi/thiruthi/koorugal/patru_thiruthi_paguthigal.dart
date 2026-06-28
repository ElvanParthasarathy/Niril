import 'package:elvan_niril/src/adippadai/vazhikaattal/niril_nav.dart';
import 'package:elvan_niril/src/adippadai/tharavuru/uruvugal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../adippadai/mozhiyaakkam/k.dart';
import '../../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../../koorugal/ulleedugal/elvan_ulleedu_vadivamaippigal.dart';
import '../../../../../koorugal/ulleedugal/elvan_thiruthi_ulleedu.dart';

import '../../../../niril_podhu/tharavuru/seluthi_vagai.dart';
import 'elvan_thiruthi_keezhvirivu.dart';

// ─────────────────────────────────────────────────────────────────────────────
// RECEIPT EDITOR — EXTRACTED SECTION BUILDERS
// ─────────────────────────────────────────────────────────────────────────────

/// Invoice picker button + selected invoice chips.
class PatruPattiyalTheervuPagudhi extends ConsumerStatefulWidget {
  const PatruPattiyalTheervuPagudhi({
    super.key,
    required this.selectedInvoices,
    required this.isDark,
    required this.onPickInvoices,
    required this.onRemoveInvoice,
  });

  final List<PattiyalTharavuru> selectedInvoices;
  final bool isDark;
  final VoidCallback onPickInvoices;
  final void Function(PattiyalTharavuru invoice) onRemoveInvoice;

  @override
  ConsumerState<PatruPattiyalTheervuPagudhi> createState() =>
      _PatruPattiyalTheervuPagudhiState();
}

class _PatruPattiyalTheervuPagudhiState
    extends ConsumerState<PatruPattiyalTheervuPagudhi> {
  final ScrollController _scrollController = ScrollController();
  bool _showLeftFade = false;
  bool _showRightFade = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  @override
  void didUpdateWidget(covariant PatruPattiyalTheervuPagudhi oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedInvoices.length != oldWidget.selectedInvoices.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    final isAtStart = pos.pixels <= 0;
    final isAtEnd = pos.pixels >= pos.maxScrollExtent - 1;

    if (_showLeftFade == !isAtStart && _showRightFade == !isAtEnd) return;

    setState(() {
      _showLeftFade = !isAtStart && pos.maxScrollExtent > 0;
      _showRightFade = !isAtEnd && pos.maxScrollExtent > 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // "Select Invoices" button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: widget.onPickInvoices,
            icon: const Icon(CupertinoIcons.doc_text, size: 18),
            label: Text(
              widget.selectedInvoices.isEmpty
                  ? K.pattiyalgalaiThaernhedu.tr(context, ref)
                  : '${widget.selectedInvoices.length} ${K.pattiyalgal.tr(context, ref)}',
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              backgroundColor: widget.isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05),
              foregroundColor: widget.isDark ? Colors.white : Colors.black87,
              elevation: 0,
            ),
          ),
        ),

        // Selected invoice chips
        if (widget.selectedInvoices.isNotEmpty) ...[
          const SizedBox(height: 12),
          ShaderMask(
            shaderCallback: (Rect bounds) {
              if (!_showLeftFade && !_showRightFade) {
                return const LinearGradient(
                    colors: [Colors.black, Colors.black]).createShader(bounds);
              }
              return LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  _showLeftFade ? Colors.transparent : Colors.black,
                  Colors.black,
                  Colors.black,
                  _showRightFade ? Colors.transparent : Colors.black,
                ],
                stops: const [0.0, 0.05, 0.95, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
                child: Row(
                  children: widget.selectedInvoices.map((inv) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 6.0),
                        decoration: ShapeDecoration(
                          shape: const StadiumBorder(),
                          color: Theme.of(context).chipTheme.backgroundColor ??
                              Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              inv.patrucheettuEn,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: widget.isDark
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 6.0),
                            InkWell(
                              onTap: () => widget.onRemoveInvoice(inv),
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Icon(
                                  CupertinoIcons.clear_thick_circled,
                                  size: 16,
                                  color: widget.isDark
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Payment section: amount, payment mode, reference, note.
class PatruSeluthiPagudhi extends ConsumerWidget {
  const PatruSeluthiPagudhi({
    super.key,
    required this.thogaiCtrl,
    required this.suttruEnCtrl,
    required this.ullkurippuCtrl,
    required this.seluthiVagai,
    required this.isDark,
    required this.onThogaiChanged,
    required this.onSeluthiVagaiChanged,
    required this.onSuttruEnChanged,
    required this.onUllkurippuChanged,
  });

  final TextEditingController thogaiCtrl;
  final TextEditingController suttruEnCtrl;
  final TextEditingController ullkurippuCtrl;
  final SeluthiVagai? seluthiVagai;
  final bool isDark;
  final ValueChanged<String> onThogaiChanged;
  final ValueChanged<SeluthiVagai?> onSeluthiVagaiChanged;
  final ValueChanged<String> onSuttruEnChanged;
  final ValueChanged<String> onUllkurippuChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 800;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            // Amount field
            SizedBox(
              width: isDesktop ? 280 : double.infinity,
              child: ElvanThiruthiUlleedu(
                controller: thogaiCtrl,
                label: K.thogaiVinmeen.tr(context, ref),
                prefixText: '₹ ',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: ElvanVadivamaippigal.thasamamEnngal,
                onChanged: onThogaiChanged,
              ),
            ),
            // Payment mode dropdown
            SizedBox(
              width: isDesktop ? 280 : double.infinity,
              child: ElvanThiruthiKeezhvirivu<SeluthiVagai>(
                label: K.cheluthumMuraiVinmeen.tr(context, ref),
                value: seluthiVagai,
                items: SeluthiVagai.values,
                itemLabelBuilder: (ctx, ref, mode) => mode.label(ctx, ref),
                leadingBuilder: (ctx, ref, mode) => Icon(mode.icon,
                    size: 18,
                    color: Theme.of(ctx)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7)),
                onChanged: (val) {
                  if (onSeluthiVagaiChanged != null) {
                    onSeluthiVagaiChanged!(val);
                  }
                },
              ),
            ),
          ],
        ),

        // Reference number (shown only when not Cash)
        if (seluthiVagai != null && seluthiVagai!.needsReference) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: isDesktop ? 380 : double.infinity,
            child: ElvanThiruthiUlleedu(
              controller: suttruEnCtrl,
              label: K.kurippuEnParimaatraEn.tr(context, ref),
              onChanged: onSuttruEnChanged,
            ),
          ),
        ],

        // Note
        const SizedBox(height: 16),
        ElvanThiruthiUlleedu(
          controller: ullkurippuCtrl,
          label: K.kurippu.tr(context, ref),
          maxLines: 3,
          onChanged: onUllkurippuChanged,
        ),
      ],
    );
  }
}
