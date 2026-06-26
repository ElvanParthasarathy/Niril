import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elvan_niril/src/adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import 'package:elvan_niril/src/koorugal/maeladukkugal/elvan_kizh_maeladukku.dart';

/// A dropdown component designed specifically for the Elvan Editors (Thiruthi).
/// It visually matches the standard text fields (same padding and background alpha).
class ElvanThiruthiKeezhvirivu extends ConsumerWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const ElvanThiruthiKeezhvirivu({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.3,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
            ),
          ),
        ),
        InkWell(
          onTap: () {
            showElvanSelectionBottomSheet(
              context: context,
              title: label,
              items: items,
              currentValue: value,
              onSelected: onChanged,
            );
          },
          borderRadius: BorderRadius.circular(100),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.08), // Editor pill color
              borderRadius: BorderRadius.circular(100),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Matches editor text fields
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value.toLowerCase().tr(context, ref),
                  style: TextStyle(
                    fontSize: 14, // Matches text fields
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
