import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elvan_niril/src/adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import 'package:elvan_niril/src/koorugal/maeladukkugal/elvan_kizh_maeladukku/elvan_kizh_maeladukku.dart';

/// A dropdown component designed specifically for the Elvan Editors (Thiruthi).
/// It visually matches the standard text fields (same padding and background alpha).
class ElvanThiruthiKeezhvirivu<T> extends ConsumerWidget {
  final String label;
  final bool hideLabel;
  final T? value;
  final List<T> items;
  final ValueChanged<T> onChanged;
  final VoidCallback? onClear;
  final String Function(BuildContext, WidgetRef, T)? subtitleBuilder;
  final String Function(BuildContext, WidgetRef, T) itemLabelBuilder;
  
  // Optional features for the bottom sheet
  final bool showSearch;
  final bool Function(T, String)? searchFilter;
  final VoidCallback? onRequestAddNew;

  const ElvanThiruthiKeezhvirivu({
    super.key,
    required this.label,
    this.hideLabel = false,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.itemLabelBuilder,
    this.onClear,
    this.subtitleBuilder,
    this.showSearch = false,
    this.searchFilter,
    this.onRequestAddNew,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty && !hideLabel)
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
            showElvanSelectionBottomSheet<T>(
              context: context,
              title: label,
              items: items,
              currentValue: value,
              onSelected: onChanged,
              itemLabelBuilder: itemLabelBuilder,
              subtitleBuilder: subtitleBuilder,
              showSearch: showSearch,
              searchFilter: searchFilter,
              onRequestAddNew: onRequestAddNew,
            );
          },
          borderRadius: BorderRadius.circular(100),
          child: InputDecorator(
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.focused) ||
                    states.contains(WidgetState.hovered)) {
                  return Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.12);
                }
                return Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.08);
              }),
              contentPadding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(100),
                borderSide: BorderSide.none,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value == null
                        ? ''
                        : itemLabelBuilder(context, ref, value as T),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                if (onClear != null && value != null)
                  InkWell(
                    onTap: onClear,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 24,
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
