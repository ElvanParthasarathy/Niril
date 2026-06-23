import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ─────────────────────────────────────────────────────────────────────────────
// பட்டியல் தொகை கூறு — Totals Display Widget
// ─────────────────────────────────────────────────────────────────────────────
// Renders a Material3 card with labelled amount rows (subtotal, tax, discount,
// grand total, etc.). Amounts are formatted as Indian currency (₹1,23,456.00).
// The final row (typically the grand total) can be marked bold for emphasis.
// Used by both Silk and Coolie invoice editors.
// ─────────────────────────────────────────────────────────────────────────────

/// Indian currency formatter: ₹1,23,456.00
final _inrFormat = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 2,
);

/// A single row in the totals display.
///
/// [label] is the description text (e.g. "மொத்தம்"),
/// [amount] is the numeric value, [isBold] renders the row with emphasis,
/// and [color] allows overriding the amount text color.
class ThogaiRow {
  /// Description label for this total row.
  final String label;

  /// Numeric amount value.
  final double amount;

  /// Whether to render this row with bold / large styling (e.g. grand total).
  final bool isBold;

  /// Optional override color for the amount text.
  final Color? color;

  const ThogaiRow(
    this.label,
    this.amount, {
    this.isBold = false,
    this.color,
  });
}

/// Displays a list of [ThogaiRow]s as a totals card.
///
/// Each row shows [ThogaiRow.label] on the left and the formatted amount
/// on the right. Rows with [ThogaiRow.isBold] set are rendered larger
/// with a top divider for visual separation.
class PattiyalThogaiKooru extends StatelessWidget {
  /// The rows to display (subtotal, taxes, discount, total, etc.).
  final List<ThogaiRow> rows;

  const PattiyalThogaiKooru({
    super.key,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      color: colorScheme.surfaceContainerLowest,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < rows.length; i++) ...[
              // Divider before bold rows (except the first row).
              if (rows[i].isBold && i > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Divider(
                    height: 1,
                    color: colorScheme.outlineVariant,
                  ),
                ),
              _buildRow(context, rows[i]),
              // Spacing between regular rows.
              if (i < rows.length - 1 && !rows[i].isBold)
                const SizedBox(height: 6),
            ],
          ],
        ),
      ),
    );
  }

  /// Renders a single label–amount row.
  Widget _buildRow(BuildContext context, ThogaiRow row) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final labelStyle = row.isBold
        ? theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          )
        : theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          );

    final amountStyle = row.isBold
        ? theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: row.color ?? colorScheme.onSurface,
            letterSpacing: 0.3,
          )
        : theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: row.color ?? colorScheme.onSurface,
            letterSpacing: 0.2,
          );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: row.isBold ? 6 : 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              row.label,
              style: labelStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            _inrFormat.format(row.amount),
            style: amountStyle,
          ),
        ],
      ),
    );
  }
}
