import 'package:flutter/material.dart';

import '../../thiraigal/amaippugal/pattu_mugavari_tharavu.dart';

/// Bottom sheet state picker for Place of Supply — reuses silkIndianStates data.
class MaanilaThervuMeladukku extends StatefulWidget {
  const MaanilaThervuMeladukku({
    super.key,
    required this.isDark,
    required this.onSelected,
  });

  final bool isDark;
  final void Function(String en, String ta) onSelected;

  @override
  State<MaanilaThervuMeladukku> createState() =>
      _MaanilaThervuMeladukkuState();
}

class _MaanilaThervuMeladukkuState extends State<MaanilaThervuMeladukku> {
  String _searchQuery = '';

  List<Map<String, String>> get _filtered {
    if (_searchQuery.isEmpty) return silkIndianStates;
    final q = _searchQuery.toLowerCase();
    return silkIndianStates.where((s) =>
        (s['en']?.toLowerCase().contains(q) ?? false) ||
        (s['ta']?.toLowerCase().contains(q) ?? false)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: widget.isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search state...',
                prefixIcon: const Icon(Icons.search, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                isDense: true,
              ),
              onChanged: (q) => setState(() => _searchQuery = q),
            ),
          ),
          Flexible(
            child: ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (ctx, i) {
                final item = _filtered[i];
                return ListTile(
                  title: Text(item['en'] ?? ''),
                  subtitle: Text(
                    item['ta'] ?? '',
                    style: TextStyle(
                      fontSize: 13,
                      color: widget.isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                  onTap: () => widget.onSelected(
                    item['en'] ?? '',
                    item['ta'] ?? '',
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
