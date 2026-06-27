import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elvan_niril/src/adippadai/mozhiyaakkam/k.dart';
import '../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';
import '../../../../adippadai/tharavuru/uruvugal.dart';

// Helper method to show this bottom sheet
Future<void> showElvanVaangunarSelectionBottomSheet({
  required BuildContext context,
  required String title,
  required List<VaangunarTharavuru> items,
  required int? currentValueId,
  required ValueChanged<VaangunarTharavuru> onSelected,
  required String Function(VaangunarTharavuru) titleBuilder,
  required String Function(VaangunarTharavuru) subtitleBuilder,
  bool Function(VaangunarTharavuru, String)? searchFilter,
  VoidCallback? onRequestAddNew,
}) {
  final isDesktop = MediaQuery.sizeOf(context).width >= 800;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    showDragHandle: !isDesktop,
    backgroundColor: Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF111111)
        : Colors.white,
    shape: isDesktop
        ? RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          )
        : const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
    constraints: isDesktop
        ? const BoxConstraints(
            maxWidth: 500,
            maxHeight: 600,
          )
        : BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.9,
          ),
    builder: (context) {
      return ElvanVaangunarSelectionBottomSheet(
        title: title,
        items: items,
        currentValueId: currentValueId,
        onSelected: (val) {
          Navigator.pop(context);
          onSelected(val);
        },
        titleBuilder: titleBuilder,
        subtitleBuilder: subtitleBuilder,
        searchFilter: searchFilter,
        onRequestAddNew: onRequestAddNew == null ? null : () {
          Navigator.pop(context);
          onRequestAddNew();
        },
      );
    },
  );
}

class ElvanVaangunarSelectionBottomSheet extends ConsumerStatefulWidget {
  final String title;
  final List<VaangunarTharavuru> items;
  final int? currentValueId;
  final ValueChanged<VaangunarTharavuru> onSelected;
  final String Function(VaangunarTharavuru) titleBuilder;
  final String Function(VaangunarTharavuru) subtitleBuilder;
  final bool Function(VaangunarTharavuru, String)? searchFilter;
  final VoidCallback? onRequestAddNew;

  const ElvanVaangunarSelectionBottomSheet({
    super.key,
    required this.title,
    required this.items,
    required this.currentValueId,
    required this.onSelected,
    required this.titleBuilder,
    required this.subtitleBuilder,
    this.searchFilter,
    this.onRequestAddNew,
  });

  @override
  ConsumerState<ElvanVaangunarSelectionBottomSheet> createState() =>
      _ElvanVaangunarSelectionBottomSheetState();
}

class _ElvanVaangunarSelectionBottomSheetState
    extends ConsumerState<ElvanVaangunarSelectionBottomSheet> {
  String _searchQuery = '';
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter items based on search query
    final filteredItems = widget.items.where((item) {
      if (_searchQuery.trim().isEmpty) return true;
      if (widget.searchFilter != null) {
        return widget.searchFilter!(item, _searchQuery);
      }
      return true; // Fallback
    }).toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 24, right: 24, bottom: 12, top: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded,
                        size: 20,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5)),
                  )
                ],
              ),
            ),
            
            // Search Pill
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                decoration: InputDecoration(
                  hintText: K.thaeduga.tr(context, ref),
                  hintStyle: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.4),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.4),
                  ),
                  filled: true,
                  fillColor: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.05),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),
            
            // List
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  final isSelected = item.id == widget.currentValueId;
                  final title = widget.titleBuilder(item);
                  final subtitle = widget.subtitleBuilder(item);

                  return InkWell(
                    onTap: () {
                      widget.onSelected(item);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: isSelected
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.8),
                                  ),
                                ),
                                if (subtitle.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    subtitle,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                                ]
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_rounded,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (widget.onRequestAddNew != null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FilledButton.icon(
                  onPressed: widget.onRequestAddNew,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(K.pudhiyaChaerkkai.tr(context, ref)),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
