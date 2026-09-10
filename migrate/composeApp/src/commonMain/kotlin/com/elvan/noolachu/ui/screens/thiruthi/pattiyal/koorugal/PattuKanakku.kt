package com.elvan.noolachu.ui.screens.thiruthi.pattiyal.koorugal

import kotlin.math.round

/**
 * Single line item for Silk mode invoices.
 * Matches Flutter's `PattuUrupadi`.
 */
data class PattuUrupadi(
    val porulId: String? = null,
    val porulPeyar: String = "",
    val porulPeyarEn: String = "",
    val hsnKuriyeedu: String = "",
    val alavu: Double = 1.0,
    val alagu: String = "Nos",
    val vilai: Double = 0.0,
    val variVizhukkaadu: Double = 5.0,
    val thallupadi: Double = 0.0,
    val thallupadiVagai: String = "%",
    val mozhiMap: Map<String, String> = emptyMap()
) {
    val adippadaiThogai: Double get() = alavu * vilai

    val thallupadiThogai: Double
        get() = if (thallupadiVagai == "%") {
            adippadaiThogai * (thallupadi / 100.0)
        } else {
            thallupadi
        }

    val taxableAmount: Double get() = (adippadaiThogai - thallupadiThogai).coerceAtLeast(0.0)
    val rowTax: Double get() = taxableAmount * (variVizhukkaadu / 100.0)
    val rowTotal: Double get() = taxableAmount + rowTax
}

/**
 * Computed totals result for Silk mode invoices.
 * Matches Flutter's `PattuMothangal`.
 */
data class PattuMothangal(
    val adippadaiMothangal: Double = 0.0,
    val thallupadiMothangal: Double = 0.0,
    val cgst: Double = 0.0,
    val sgst: Double = 0.0,
    val igst: Double = 0.0,
    val variMothangal: Double = 0.0,
    val suttruOff: Double = 0.0,
    val mothaMothangal: Double = 0.0
)

/**
 * Silk invoice calculation engine.
 * Matches Flutter's `PattuKanakku` 1:1.
 */
object PattuKanakku {
    fun calculate(
        items: List<PattuUrupadi>,
        globalDiscountValue: Double = 0.0,
        globalDiscountType: String = "%",
        businessState: String = "",
        customerState: String = "",
        country: String = "India"
    ): PattuMothangal {
        var rawSubtotal = 0.0
        var itemDiscounts = 0.0

        for (item in items) {
            val amount = item.alavu * item.vilai
            val rawDiscount = item.thallupadi
            val discountAmount = if (item.thallupadiVagai == "%") {
                amount * (rawDiscount / 100.0)
            } else {
                rawDiscount
            }
            rawSubtotal += amount
            itemDiscounts += discountAmount
        }

        val afterItemDiscountSubtotal = (rawSubtotal - itemDiscounts).coerceAtLeast(0.0)

        val globalDiscountAmount = if (globalDiscountType == "%") {
            afterItemDiscountSubtotal * (globalDiscountValue / 100.0)
        } else {
            globalDiscountValue
        }

        val totalDiscount = itemDiscounts + globalDiscountAmount

        var taxTotal = 0.0

        for (item in items) {
            val amount = item.alavu * item.vilai
            val rawDiscount = item.thallupadi
            val itemDiscount = if (item.thallupadiVagai == "%") {
                amount * (rawDiscount / 100.0)
            } else {
                rawDiscount
            }

            val afterItemDiscount = (amount - itemDiscount).coerceAtLeast(0.0)

            val itemWeight = if (afterItemDiscountSubtotal > 0) {
                afterItemDiscount / afterItemDiscountSubtotal
            } else {
                0.0
            }
            val itemGlobalDiscount = globalDiscountAmount * itemWeight
            val taxableAmount = (afterItemDiscount - itemGlobalDiscount).coerceAtLeast(0.0)

            taxTotal += (taxableAmount * item.variVizhukkaadu) / 100.0
        }

        val isIndia = country.equals("india", ignoreCase = true) || country.equals("in", ignoreCase = true)
        val bState = businessState.trim().lowercase()
        val cState = customerState.trim().lowercase()
        val isInterstate = isIndia && bState.isNotEmpty() && cState.isNotEmpty() && bState != cState

        val cgst: Double
        val sgst: Double
        val igst: Double

        if (isInterstate) {
            cgst = 0.0
            sgst = 0.0
            igst = taxTotal
        } else {
            cgst = taxTotal / 2.0
            sgst = taxTotal / 2.0
            igst = 0.0
        }

        val exactTotal = (rawSubtotal - totalDiscount + taxTotal).coerceAtLeast(0.0)
        val roundedTotal = round(exactTotal)
        val suttruOff = roundedTotal - exactTotal

        return PattuMothangal(
            adippadaiMothangal = rawSubtotal,
            thallupadiMothangal = totalDiscount,
            cgst = cgst,
            sgst = sgst,
            igst = igst,
            variMothangal = taxTotal,
            suttruOff = suttruOff,
            mothaMothangal = roundedTotal
        )
    }
}
