package com.elvan.noolachu.data.business

import com.elvan.noolachu.core.mode.AppMode
import com.elvan.noolachu.data.model.PorulTharavuru
import com.elvan.noolachu.data.model.VaangunarTharavuru

interface BusinessDatabaseHelper {
    fun loadAllMerchants(mode: AppMode): List<VaangunarTharavuru>
    fun saveMerchant(mode: AppMode, merchant: VaangunarTharavuru): Long
    fun deleteMerchant(mode: AppMode, id: Long): Boolean

    fun loadAllItems(mode: AppMode): List<PorulTharavuru>
    fun saveItem(mode: AppMode, item: PorulTharavuru): Long
    fun deleteItem(mode: AppMode, id: Long): Boolean
}

expect fun getBusinessDatabaseHelper(): BusinessDatabaseHelper
