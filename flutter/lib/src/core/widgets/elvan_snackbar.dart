import 'package:flutter/material.dart';

class ElvanSnackbar {
  /// Shows a standard floating snackbar with the given message.
  static void show(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final screenWidth = MediaQuery.of(context).size.width;
    final snackBarWidth = 400.0;
    final lateralMargin =
        screenWidth > snackBarWidth ? (screenWidth - snackBarWidth) / 2 : 16.0;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: 24.0,
          left: lateralMargin,
          right: lateralMargin,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
      ),
    );
  }
}
