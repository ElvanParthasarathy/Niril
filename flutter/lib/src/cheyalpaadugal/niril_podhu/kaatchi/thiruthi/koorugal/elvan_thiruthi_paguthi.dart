import 'package:elvan_niril/src/adippadai/vazhikaattal/niril_nav.dart';
import 'package:elvan_niril/src/adippadai/iru_mozhi/iru_mozhi_vazhanguthigal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elvan_niril/src/adippadai/nilaimai/seyali_nilaimai.dart';
import 'package:elvan_niril/src/koorugal/pulan_koorugal/elvan_irumozhi_pulan.dart';
import 'package:elvan_niril/src/koorugal/pulan_koorugal/elvan_irumozhi_autocomplete.dart';
import 'package:elvan_niril/src/cheyalpaadugal/niril_kooli/kaatchi/koorugal/elvan_kooli_irumozhi_pulan.dart';

class ElvanFullWidth extends StatelessWidget {
  const ElvanFullWidth({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => child;
}

class ElvanEditorSection extends ConsumerStatefulWidget {
  const ElvanEditorSection({
    super.key,
    required this.index,
    required this.title,
    required this.displayChild,
    required this.children,
    this.initiallyExpanded = false,
  });

  final int index;
  final String title;
  final Widget displayChild;
  final List<Widget> children;
  final bool initiallyExpanded;

  @override
  ConsumerState<ElvanEditorSection> createState() => _ElvanEditorSectionState();
}

class _ElvanEditorSectionState extends ConsumerState<ElvanEditorSection> {
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 800;
    final isBilingual = ref.watch(bilingualProvider);

    // Filter out SizedBox spacing which is unnecessary in desktop grid
    final filteredChildren = isDesktop
        ? widget.children.where((c) => c is! SizedBox).toList()
        : widget.children;

    if (isDesktop) {
      // Desktop: Two-side grid layout, always expanded
      return Padding(
        padding: const EdgeInsets.only(bottom: 48.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(isActive: true),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = (constraints.maxWidth - 16) / 2;
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: filteredChildren.map((child) {
                      bool isBilingualField = isBilingual &&
                          (child is ElvanIrumozhiPulan ||
                              child is ElvanIrumozhiAutocomplete);

                      if (child is ElvanKooliIrumozhiPulan) {
                        isBilingualField = !child.forceStacked;
                      }

                      final isFull =
                          child is ElvanFullWidth || isBilingualField;

                      return SizedBox(
                        width: isFull ? constraints.maxWidth : itemWidth,
                        child: child,
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    // Mobile: Continuous Vertical List (No Accordion)
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isActive: true),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < widget.children.length; i++) ...[
                  widget.children[i],
                  if (i < widget.children.length - 1)
                    const SizedBox(height: 24),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader({required bool isActive}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isActive
                  ? (isDark ? Colors.white : Colors.black)
                  : (isDark ? Colors.white10 : Colors.black12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${widget.index + 1}',
                style: TextStyle(
                  color: isActive
                      ? (isDark ? Colors.black : Colors.white)
                      : (isDark ? Colors.white54 : Colors.black54),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
