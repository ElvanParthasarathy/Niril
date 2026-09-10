package com.elvan.noolachu.data.model

import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import com.elvan.noolachu.localization.K
import com.elvan.noolachu.localization.tr

/**
 * Type-safe payment mode enum with localized display names.
 * Stored as lowercase string in DB (e.g. 'cash', 'upi', 'bank_transfer', 'cheque', 'card').
 */
enum class SeluthiVagai(
    val storedValue: String,
    val needsReference: Boolean
) {
    VANGI_MAATRAM("bank_transfer", true), // Bank Transfer — வங்கி மாற்றம்
    UPI("upi", true),                    // UPI
    PANAM("cash", false),                // Cash — காசு / பணம்
    KAASOALAI("cheque", true),           // Cheque — காசோலை
    ATTAI("card", true);                 // Card — அட்டை

    @Composable
    fun label(): String {
        return when (this) {
            PANAM -> K.kaasu.tr()
            UPI -> "UPI"
            VANGI_MAATRAM -> K.vangiParimaatram.tr()
            KAASOALAI -> K.kaasoalai.tr()
            ATTAI -> K.attai.tr()
        }
    }

    fun badgeColor(isDark: Boolean): Color {
        return when (this) {
            PANAM -> if (isDark) Color(0xFF81C784) else Color(0xFF388E3C)
            UPI -> if (isDark) Color(0xFFCE93D8) else Color(0xFF7B1FA2)
            VANGI_MAATRAM -> if (isDark) Color(0xFF90CAF9) else Color(0xFF1976D2)
            KAASOALAI -> if (isDark) Color(0xFFFFCC80) else Color(0xFFF57C00)
            ATTAI -> if (isDark) Color(0xFF80CBC4) else Color(0xFF00796B)
        }
    }

    companion object {
        fun fromStored(value: String?): SeluthiVagai {
            if (value.isNullOrBlank()) return PANAM
            return when (value.trim().lowercase()) {
                "bank_transfer", "vangimaatram", "vangi_maatram" -> VANGI_MAATRAM
                "upi" -> UPI
                "cash", "panam", "roakkam" -> PANAM
                "cheque", "kaasoalai" -> KAASOALAI
                "card", "attai" -> ATTAI
                else -> PANAM
            }
        }

        @Composable
        fun allOptions(): List<Pair<String, String>> = listOf(
            PANAM.name to PANAM.label(),
            UPI.name to UPI.label(),
            VANGI_MAATRAM.name to VANGI_MAATRAM.label(),
            KAASOALAI.name to KAASOALAI.label(),
            ATTAI.name to ATTAI.label()
        )
    }
}
