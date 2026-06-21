import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/state/search_state.dart';
import '../../../shell/presentation/widgets/elvan_responsive_grid.dart';

class CoolieReceiptsPage extends ConsumerWidget {
  const CoolieReceiptsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(coolieReceiptsSearchQueryProvider).toLowerCase();
    
    // Mock data generation
    final allItems = List.generate(50, (index) => 'Coolie Receipts Page - Item $index');
    final filteredItems = query.isEmpty 
        ? allItems 
        : allItems.where((item) => item.toLowerCase().contains(query)).toList();

    return SliverPadding(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 32, bottom: 120),
      sliver: ElvanResponsiveGrid(
        itemCount: filteredItems.length,
        desktopCrossAxisCount: 2,
        childAspectRatio: 2.5,
        itemBuilder: (context, index) {
          final item = filteredItems[index];
          return Container(
            height: 100, // Mobile only
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(item, style: TextStyle(color: Colors.orange.withOpacity(0.8), fontSize: 16)),
            ),
          );
        },
      ),
    );
  }
}
