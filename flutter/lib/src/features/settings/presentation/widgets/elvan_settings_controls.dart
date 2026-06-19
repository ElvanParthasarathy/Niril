import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/elvan_text_field.dart';
import '../../../../localization/locale_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ElvanSettingsSwitch — A standard switch with Elvan's monochrome styling
// ─────────────────────────────────────────────────────────────────────────────
class ElvanSettingsSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const ElvanSettingsSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Switch(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      value: value,
      activeColor: Theme.of(context).colorScheme.surface,
      activeTrackColor: Theme.of(context).colorScheme.onSurface,
      inactiveThumbColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
      inactiveTrackColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
      onChanged: onChanged,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ElvanSettingsSelectionBottomSheet — The standard bottom sheet for selections
// ─────────────────────────────────────────────────────────────────────────────
class ElvanSettingsSelectionBottomSheet extends ConsumerWidget {
  final String title;
  final List<String> items;
  final String currentValue;
  final ValueChanged<String> onSelected;

  const ElvanSettingsSelectionBottomSheet({
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

// ─────────────────────────────────────────────────────────────────────────────
// ElvanSettingsDropdown — A pill-shaped row that triggers a bottom sheet
// ─────────────────────────────────────────────────────────────────────────────
class ElvanSettingsDropdown extends ConsumerWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const ElvanSettingsDropdown({
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
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
        InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              useRootNavigator: true,
              showDragHandle: true,
              backgroundColor: Theme.of(context).brightness == Brightness.dark 
                  ? const Color(0xFF111111) 
                  : Colors.white,
              builder: (BuildContext context) {
                return ElvanSettingsSelectionBottomSheet(
                  title: label,
                  items: items,
                  currentValue: value,
                  onSelected: (val) {
                    Navigator.pop(context);
                    onChanged(val);
                  },
                );
              },
            );
          },
          borderRadius: BorderRadius.circular(100),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(100),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value.toLowerCase().tr(context, ref),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded, 
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ElvanSettingsAutocomplete — A text field that supports autocomplete
// ─────────────────────────────────────────────────────────────────────────────
class ElvanSettingsAutocomplete extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final void Function(String)? onSelected;
  final bool Function(String option, String query)? searchMatch;
  final bool enabled;

  const ElvanSettingsAutocomplete({
    super.key,
    required this.label,
    required this.controller,
    required this.options,
    required this.onChanged,
    this.onSelected,
    this.searchMatch,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
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
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
        RawAutocomplete<String>(
          textEditingController: controller,
          focusNode: FocusNode(),
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (!enabled) return const Iterable<String>.empty();
            if (textEditingValue.text.isEmpty) {
              return options;
            }
            return options.where((String option) {
              if (searchMatch != null) {
                return searchMatch!(option, textEditingValue.text);
              }
              return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
            });
          },
          onSelected: (String selection) {
            if (!enabled) return;
            onChanged(selection);
            if (onSelected != null) {
              onSelected!(selection);
            }
          },
          fieldViewBuilder: (context, fieldController, focusNode, onEditingComplete) {
            return ElvanTextField(
              controller: fieldController,
              focusNode: focusNode,
              onChanged: enabled ? onChanged : null,
              onEditingComplete: onEditingComplete,
              enabled: enabled,
              style: TextStyle(
                fontSize: 16,
                color: enabled 
                    ? Theme.of(context).colorScheme.onSurface 
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: enabled 
                    ? ValueListenableBuilder<TextEditingValue>(
                        valueListenable: fieldController,
                        builder: (context, value, child) {
                          if (value.text.isNotEmpty) {
                            return IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                              onPressed: () {
                                fieldController.clear();
                                onChanged('');
                                // Close keyboard when clearing if they want, but usually leave it open
                              },
                            );
                          }
                          return Icon(
                            Icons.arrow_drop_down,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                          );
                        },
                      ) 
                    : null,
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final bgColor = isDark ? const Color(0xFF111111) : Colors.white;
            final textColor = isDark ? Colors.white : Colors.black;

            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: bgColor,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 200,
                    maxWidth: MediaQuery.of(context).size.width - 64, // Estimate width
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return InkWell(
                        onTap: () => onSelected(option),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Text(
                            option,
                            style: TextStyle(
                              color: textColor,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
