import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../adippadai/tharavuthalam/seyali_tharavuthalam.dart';
import '../../../../../adippadai/mozhiyaakkam/k.dart';
import '../../../../../adippadai/mozhiyaakkam/mozhi_vazhanguthi.dart';

/// Bottom-sheet dialog for picking one or more invoices.
/// Returns the selected list via [onConfirmed].
class PatruPattiyalTheervuMaeladukku {
  static void show({
    required BuildContext context,
    required WidgetRef ref,
    required List<PatrucheettuEntry> invoices,
    required Set<int> initialSelectedIds,
    required void Function(List<PatrucheettuEntry> selected) onConfirmed,
  }) {
    final searchCtrl = TextEditingController();
    var searchQuery = '';
    final selectedIds = Set<int>.from(initialSelectedIds);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            // Smart Filtering: Lock to the first selected invoice's company, customer, and exact address
            PatrucheettuEntry? firstSelected;
            if (selectedIds.isNotEmpty) {
              final firstId = selectedIds.first;
              for (var i in invoices) {
                if (i.id == firstId) {
                  firstSelected = i;
                  break;
                }
              }
            }

            final availableInvoices = firstSelected != null
                ? invoices.where((inv) {
                    final sameNiruvanam = inv.niruvanamId == firstSelected!.niruvanamId;
                    
                    final pName1 = inv.vaangunarPeyar['Tamil'] ?? inv.vaangunarPeyar['English'] ?? '';
                    final pName2 = firstSelected.vaangunarPeyar['Tamil'] ?? firstSelected.vaangunarPeyar['English'] ?? '';
                    final sameName = pName1 == pName2;

                    final pAddr1 = inv.vaangunarMunvari['Tamil'] ?? inv.vaangunarMunvari['English'] ?? '';
                    final pAddr2 = firstSelected.vaangunarMunvari['Tamil'] ?? firstSelected.vaangunarMunvari['English'] ?? '';
                    final sameAddr = pAddr1 == pAddr2;

                    return sameNiruvanam && sameName && sameAddr;
                  }).toList()
                : invoices;

            final filtered = searchQuery.isEmpty
                ? availableInvoices
                : availableInvoices.where((inv) {
                    final q = searchQuery.toLowerCase();
                    final pName = (inv.vaangunarPeyar['Tamil'] ?? inv.vaangunarPeyar['English'] ?? '').toLowerCase();
                    return inv.patrucheettuEn.toLowerCase().contains(q) ||
                        pName.contains(q);
                  }).toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              maxChildSize: 0.95,
              minChildSize: 0.4,
              expand: false,
              builder: (_, scrollController) {
                return Column(
                  children: [
                    // Handle bar
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Text(
                            K.pattiyalgalaiThaernhedu.tr(context, ref),
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              final selected = invoices
                                  .where((i) => selectedIds.contains(i.id))
                                  .toList();
                              onConfirmed(selected);
                              Navigator.of(ctx).pop();
                            },
                            child: Text(K.mudindhadhu.tr(context, ref),
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                    // Search
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: searchCtrl,
                        decoration: InputDecoration(
                          hintText: K.pattiyalEnVaangunar.tr(context, ref),
                          prefixIcon:
                              const Icon(CupertinoIcons.search, size: 18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          isDense: true,
                        ),
                        onChanged: (val) {
                          setDialogState(() => searchQuery = val);
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    // Invoice list
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                              child: Text(K.pattiyalgalIllai.tr(context, ref),
                                  style: const TextStyle(color: Colors.grey)))
                          : ListView.separated(
                              controller: scrollController,
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1, indent: 56),
                              itemBuilder: (_, index) {
                                final inv = filtered[index];
                                final isSelected =
                                    selectedIds.contains(inv.id);
                                final currFmt = NumberFormat.currency(
                                    locale: 'en_IN', symbol: '₹');
                                final dateFmt = DateFormat('dd/MM/yyyy');

                                return ListTile(
                                  leading: Checkbox(
                                    value: isSelected,
                                    onChanged: (val) {
                                      setDialogState(() {
                                        if (val == true) {
                                          selectedIds.add(inv.id);
                                        } else {
                                          selectedIds.remove(inv.id);
                                        }
                                      });
                                    },
                                  ),
                                  title: Row(
                                    children: [
                                      Text(
                                        inv.patrucheettuEn,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        dateFmt.format(inv.pattiyalNaal),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: (inv.vaangunarPeyar['Tamil'] ?? inv.vaangunarPeyar['English'] ?? '').isNotEmpty
                                      ? Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(inv.vaangunarPeyar['Tamil'] ?? inv.vaangunarPeyar['English'] ?? '',
                                                style: const TextStyle(fontSize: 13),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis),
                                            if ((inv.vaangunarMunvari['Tamil'] ?? inv.vaangunarMunvari['English'] ?? '').isNotEmpty)
                                              Text(inv.vaangunarMunvari['Tamil'] ?? inv.vaangunarMunvari['English'] ?? '',
                                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis),
                                          ],
                                        )
                                      : null,
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        currFmt.format(inv.mothaThogai),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    setDialogState(() {
                                      if (isSelected) {
                                        selectedIds.remove(inv.id);
                                      } else {
                                        selectedIds.add(inv.id);
                                      }
                                    });
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
