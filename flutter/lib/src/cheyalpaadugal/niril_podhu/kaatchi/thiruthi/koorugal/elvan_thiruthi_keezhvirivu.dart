import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elvan_niril/src/adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import 'package:elvan_niril/src/koorugal/maeladukkugal/elvan_kizh_maeladukku/elvan_kizh_maeladukku.dart';
import 'package:elvan_niril/src/koorugal/ulleedugal/elvan_thiruthi_marabu.dart';

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
  final Widget Function(BuildContext, WidgetRef, T)? leadingBuilder;
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
    this.leadingBuilder,
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
        GestureDetector(
          onTap: () {
            showElvanSelectionBottomSheet<T>(
              context: context,
              title: label,
              items: items,
              currentValue: value,
              onSelected: onChanged,
              itemLabelBuilder: itemLabelBuilder,
              subtitleBuilder: subtitleBuilder,
              leadingBuilder: leadingBuilder,
              showSearch: showSearch,
              searchFilter: searchFilter,
              onRequestAddNew: onRequestAddNew,
            );
          },
          child: Row(
            children: [
                if (value != null && leadingBuilder != null) ...[
                  leadingBuilder!(context, ref, value as T),
                  const SizedBox(width: 8),
                ],
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
                        size: ElvanThiruthiMarabu.iconSize,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: ElvanThiruthiMarabu.iconSize,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
                ),
              ],
            ),
        ),
      ],
    );
  }
}
