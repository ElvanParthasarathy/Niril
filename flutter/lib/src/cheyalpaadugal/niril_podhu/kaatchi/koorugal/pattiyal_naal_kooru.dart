import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:elvan_niril/src/koorugal/ulleedugal/elvan_thiruthi_marabu.dart';

// ─────────────────────────────────────────────────────────────────────────────
// பட்டியல் நாள் கூறு — Date Picker Widget
// ─────────────────────────────────────────────────────────────────────────────
// Tappable Material3 container showing the selected date in DD/MM/YYYY format.
// Opens the system date picker on tap and returns the chosen date via callback.
// Used by both Silk and Coolie invoice editors for invoice date selection.
// ─────────────────────────────────────────────────────────────────────────────

/// Date display formatter: 24/06/2026
final _dateFormat = DateFormat('dd/MM/yyyy');

/// A tappable date display chip that opens [showDatePicker] on tap.
///
/// Renders the [selectedDate] in DD/MM/YYYY format inside a Material3
/// outlined container with a calendar icon. When a new date is picked,
/// fires [onDateChanged] with the result.
class PattiyalNaalKooru extends StatelessWidget {
  /// The currently selected date.
  final DateTime selectedDate;

  /// Callback fired when the user picks a new date.
  final ValueChanged<DateTime> onDateChanged;

  /// Optional label displayed above the date text.
  final String? label;

  const PattiyalNaalKooru({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
    this.label,
  });

  Future<void> _openDatePicker(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;

    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: colorScheme,
            datePickerTheme: DatePickerThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Text(
              label!,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
                fontWeight: FontWeight.w400,
                fontSize: 12,
                letterSpacing: 0.3,
              ),
            ),
          ),

        // Tappable date container
        InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: () => _openDatePicker(context),
          child: InputDecorator(
            decoration: const InputDecoration(
              isDense: true,
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: ElvanThiruthiMarabu.iconSize,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Text(
                  _dateFormat.format(selectedDate),
                  style: TextStyle(
                    fontSize: ElvanThiruthiMarabu.fontSize,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.arrow_drop_down_rounded,
                  size: ElvanThiruthiMarabu.iconSize,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
