import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
  home: Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              filled: true,
              fillColor: Colors.grey[200],
            ),
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 20),
          InputDecorator(
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              filled: true,
              fillColor: Colors.grey[200],
            ),
            child: Row(
              children: [
                Icon(Icons.payment, size: 14),
                const SizedBox(width: 8),
                Text('Some text', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
));
