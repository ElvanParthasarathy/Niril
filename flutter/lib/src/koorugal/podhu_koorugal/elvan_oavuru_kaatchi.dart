import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

/// Renders an image from either a file path or a base64-encoded string.
///
/// Detection logic:
/// - If the value contains `/` or `\`, it's treated as a file path → [Image.file]
/// - Otherwise, it's treated as a base64 string → [Image.memory]
class ElvanOavuruKaatchi extends StatelessWidget {
  const ElvanOavuruKaatchi({
    super.key,
    required this.value,
    this.height = 36,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.centerLeft,
  });

  /// The raw image value — either a file path or a base64-encoded string.
  final String value;
  final double height;
  final BoxFit fit;
  final Alignment alignment;

  bool get _isFilePath =>
      value.contains('/') || value.contains('\\') || value.startsWith('C:');

  @override
  Widget build(BuildContext context) {
    if (_isFilePath) {
      return Image.file(
        File(value),
        height: height,
        fit: fit,
        alignment: alignment,
        errorBuilder: (_, __, ___) => _errorIcon(),
      );
    }

    // Base64 decode
    try {
      final bytes = base64Decode(value);
      return Image.memory(
        bytes,
        height: height,
        fit: fit,
        alignment: alignment,
        errorBuilder: (_, __, ___) => _errorIcon(),
      );
    } catch (_) {
      return _errorIcon();
    }
  }

  Widget _errorIcon() {
    return SizedBox(
      height: height,
      child: const Icon(Icons.broken_image_outlined, size: 24, color: Colors.grey),
    );
  }
}
