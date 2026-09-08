package com.elvan.noolachu.data.business

import com.elvan.noolachu.core.mode.AppMode
import com.elvan.noolachu.data.model.PattiyalTharavuru
import com.elvan.noolachu.data.model.PatrugalTharavuru
import com.elvan.noolachu.data.model.PorulTharavuru
import com.elvan.noolachu.data.model.VaangunarTharavuru

interface BusinessDatabaseHelper {
    fun loadAllMerchants(mode: AppMode): List<VaangunarTharavuru>
    fun saveMerchant(mode: AppMode, merchant: VaangunarTharavuru): Long
    fun deleteMerchant(mode: AppMode, id: Long): Boolean
    fun loadDeletedMerchants(mode: AppMode): List<VaangunarTharavuru>
    fun restoreMerchant(mode: AppMode, id: Long): Boolean
    fun permanentDeleteMerchant(mode: AppMode, id: Long): Boolean
    fun purgeExpiredMerchants(mode: AppMode, days: Int = 30): Int

    fun loadAllItems(mode: AppMode): List<PorulTharavuru>
    fun saveItem(mode: AppMode, item: PorulTharavuru): Long
    fun deleteItem(mode: AppMode, id: Long): Boolean
    fun loadDeletedItems(mode: AppMode): List<PorulTharavuru>
    fun restoreItem(mode: AppMode, id: Long): Boolean
    fun permanentDeleteItem(mode: AppMode, id: Long): Boolean
    fun purgeExpiredItems(mode: AppMode, days: Int = 30): Int

    fun loadAllInvoices(mode: AppMode): List<PattiyalTharavuru>
    fun saveInvoice(mode: AppMode, invoice: PattiyalTharavuru): Long
    fun deleteInvoice(mode: AppMode, id: Long): Boolean

    fun loadAllReceipts(mode: AppMode): List<PatrugalTharavuru>
    fun saveReceipt(mode: AppMode, receipt: PatrugalTharavuru): Long
    fun deleteReceipt(mode: AppMode, id: Long): Boolean
}

expect fun getBusinessDatabaseHelper(): BusinessDatabaseHelper
