import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/state/search_state.dart';

class SilkItemsPage extends ConsumerWidget {
  const SilkItemsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(silkItemsSearchQueryProvider).toLowerCase();
    
    // Mock data generation
    final allItems = List.generate(50, (index) => 'Silk Items Page - Item $index');
    final filteredItems = query.isEmpty 
        ? allItems 
        : allItems.where((item) => item.toLowerCase().contains(query)).toList();

    return SliverPadding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 120),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = filteredItems[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              height: 100,
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(item, style: TextStyle(color: Colors.blue.withValues(alpha: 0.8), fontSize: 16)),
              ),
            );
          },
          childCount: filteredItems.length,
        ),
      ),
    );
  }
}
