import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elvan_niril/src/localization/locale_provider.dart';

Future<T?> showElvanBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF111111)
        : Colors.white,
    builder: builder,
  );
}

Future<void> showElvanSelectionBottomSheet({
  required BuildContext context,
  required String title,
  required List<String> items,
  required String currentValue,
  required ValueChanged<String> onSelected,
}) {
  return showElvanBottomSheet(
    context: context,
    builder: (context) {
      return ElvanSelectionBottomSheet(
        title: title,
        items: items,
        currentValue: currentValue,
        onSelected: (val) {
          Navigator.pop(context);
          onSelected(val);
        },
      );
    },
  );
}

class ElvanSelectionBottomSheet extends ConsumerWidget {
  final String title;
  final List<String> items;
  final String currentValue;
  final ValueChanged<String> onSelected;

  const ElvanSelectionBottomSheet({
    super.key,
    required this.title,
    required this.items,
    required this.currentValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 8, top: 12),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
          ...items.map((item) {
            final isSelected = item == currentValue;
            return InkWell(
              onTap: () {
                onSelected(item);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Text(
                      item.toLowerCase().tr(context, ref),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected 
                            ? Theme.of(context).colorScheme.onSurface 
                            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const Spacer(),
                    if (isSelected)
                      Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 20,
                      ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
