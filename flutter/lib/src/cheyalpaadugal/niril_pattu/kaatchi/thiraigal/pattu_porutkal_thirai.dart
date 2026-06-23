import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../adippadai/nilaimai/thaedal_nilaimai.dart';
import '../../../chattagam/kaatchi/koorugal/elvan_uyir_valai.dart';

class SilkItemsPage extends ConsumerWidget {
  const SilkItemsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(silkItemsSearchQueryProvider).toLowerCase();

    // Mock data generation
    final allItems =
        List.generate(50, (index) => 'Silk Items Page - Item $index');
    final filteredItems = query.isEmpty
        ? allItems
        : allItems.where((item) => item.toLowerCase().contains(query)).toList();

    return SliverPadding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 120),
      sliver: ElvanResponsiveGrid(
        itemCount: filteredItems.length,
        desktopCrossAxisCount: 2,
        childAspectRatio: 2.5,
        itemBuilder: (context, index) {
          final item = filteredItems[index];
          return Container(
            height: 100, // Mobile only
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(item,
                  style: TextStyle(
                      color: Colors.blue.withOpacity(0.8), fontSize: 16)),
            ),
          );
        },
      ),
    );
  }
}
