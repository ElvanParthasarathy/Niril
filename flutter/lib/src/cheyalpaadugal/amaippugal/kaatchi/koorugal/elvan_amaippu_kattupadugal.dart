import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../koorugal/maeladukkugal/elvan_kizh_maeladukku.dart';
import '../../../../koorugal/ulleedugal/elvan_ulleedu.dart';
import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';

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
      activeThumbColor: Theme.of(context).colorScheme.surface,
      activeTrackColor: Theme.of(context).colorScheme.onSurface,
      inactiveThumbColor:
          Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
      inactiveTrackColor:
          Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
      onChanged: onChanged,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ElvanSettingsDropdown — A pill-shaped row that triggers a bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

String _getLocalizedSettingsValue(BuildContext context, WidgetRef ref, String val) {
  if (val == 'Tamil' || val == 'tamil') return K.tamil.tr(context, ref);
  if (val == 'English' || val == 'english') return K.english.tr(context, ref);
  return val;
}

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
              itemLabelBuilder: (ctx, innerRef, item) => _getLocalizedSettingsValue(ctx, innerRef, item),
            );
          },
          borderRadius: BorderRadius.circular(100),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(100),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getLocalizedSettingsValue(context, ref, value),
                  style: TextStyle(
                    fontSize: 15,
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

// ─────────────────────────────────────────────────────────────────────────────
// ElvanSettingsAutocomplete — A text field that supports autocomplete
// ─────────────────────────────────────────────────────────────────────────────
class ElvanSettingsAutocomplete extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final void Function(String)? onSelected;
  final bool Function(String option, String query)? searchMatch;
  final String Function(String option)? subtitleBuilder;
  final bool enabled;

  const ElvanSettingsAutocomplete({
    super.key,
    required this.label,
    required this.controller,
    required this.options,
    required this.onChanged,
    this.onSelected,
    this.searchMatch,
    this.subtitleBuilder,
    this.enabled = true,
  });

  @override
  State<ElvanSettingsAutocomplete> createState() => _ElvanSettingsAutocompleteState();
}

class _ElvanSettingsAutocompleteState extends State<ElvanSettingsAutocomplete> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            widget.label,
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
        LayoutBuilder(
          builder: (context, constraints) {
            return RawAutocomplete<String>(
              textEditingController: widget.controller,
              focusNode: _focusNode,
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (!widget.enabled) return const Iterable<String>.empty();
                if (textEditingValue.text.isEmpty) {
                  return widget.options;
                }
                return widget.options.where((String option) {
                  if (widget.searchMatch != null) {
                    return widget.searchMatch!(option, textEditingValue.text);
                  }
                  return option
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase());
                });
              },
              onSelected: (String selection) {
                if (!widget.enabled) return;
                widget.onChanged(selection);
                if (widget.onSelected != null) {
                  widget.onSelected!(selection);
                }
              },
              fieldViewBuilder:
                  (context, fieldController, focusNode, onEditingComplete) {
                return ElvanTextField(
                  controller: fieldController,
                  focusNode: focusNode,
                  onChanged: widget.enabled ? widget.onChanged : null,
                  onEditingComplete: onEditingComplete,
                  enabled: widget.enabled,
                  style: TextStyle(
                    fontSize: 14,
                    color: widget.enabled
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: WidgetStateColor.resolveWith((states) {
                      if (states.contains(WidgetState.focused)) {
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
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: widget.enabled
                        ? ValueListenableBuilder<TextEditingValue>(
                            valueListenable: fieldController,
                            builder: (context, value, child) {
                              if (value.text.isNotEmpty) {
                                return IconButton(
                                  icon: const Icon(Icons.close, size: 20),
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.5),
                                  onPressed: () {
                                    fieldController.clear();
                                    widget.onChanged('');
                                    // Close keyboard when clearing if they want, but usually leave it open
                                  },
                                );
                              }
                              return IconButton(
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.5),
                                ),
                                onPressed: () {
                                  if (!focusNode.hasFocus) {
                                    focusNode.requestFocus();
                                  }
                                },
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
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    color: bgColor,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: 200,
                        maxWidth: constraints.maxWidth, // Use text field width
                      ),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final option = options.elementAt(index);
                          final subtitle = widget.subtitleBuilder?.call(option);
                          
                          return InkWell(
                            onTap: () => onSelected(option),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option,
                                    style: TextStyle(
                                        fontSize: 16, color: textColor),
                                  ),
                                  if (subtitle != null && subtitle.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                        subtitle,
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: textColor.withValues(alpha: 0.6)),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
