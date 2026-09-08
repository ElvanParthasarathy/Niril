package com.elvan.noolachu.ui.navigation

import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.graphics.vector.PathParser
import androidx.compose.ui.unit.dp
import com.composables.icons.materialsymbols.MaterialSymbols as LibSymbols
import com.composables.icons.materialsymbols.rounded.*
import com.composables.icons.materialsymbols.roundedfilled.*

/**
 * MaterialSymbols — Google Material Symbols (new) Rounded icons.
 * Provides dynamic filled/outline support:
 * - Inactive navigation items and interactive edit actions use Rounded Outline.
 * - Active navigation items, settings categories, and entity badges use Rounded Filled.
 */
object MaterialSymbols {
    private fun symbol(name: String, pathData: String): ImageVector {
        return ImageVector.Builder(
            name = name,
            defaultWidth = 24.dp,
            defaultHeight = 24.dp,
            viewportWidth = 960f,
            viewportHeight = 960f
        ).addPath(
            fill = SolidColor(Color.Black),
            pathData = PathParser().parsePathString(pathData).toNodes()
        ).build()
    }

    object Rounded {
        // ── Navigation Dynamic Fill (Inactive = Outline, Active = Filled) ──
        val Home: ImageVector get() = LibSymbols.Rounded.Home
        val HomeFill: ImageVector get() = LibSymbols.RoundedFilled.Home
        val Description: ImageVector get() = LibSymbols.Rounded.Description
        val DescriptionFill: ImageVector get() = LibSymbols.RoundedFilled.Description
        val Notes: ImageVector get() = LibSymbols.Rounded.Receipt_long
        val NotesFill: ImageVector get() = LibSymbols.RoundedFilled.Receipt_long
        val Schedule: ImageVector get() = LibSymbols.Rounded.Schedule
        val ScheduleFill: ImageVector get() = LibSymbols.RoundedFilled.Schedule
        val Calendar: ImageVector get() = LibSymbols.Rounded.Calendar_month
        val CalendarFill: ImageVector get() = LibSymbols.RoundedFilled.Calendar_month
        val Notifications: ImageVector get() = LibSymbols.Rounded.Notifications
        val NotificationsFill: ImageVector get() = LibSymbols.RoundedFilled.Notifications
        val ReceiptLong: ImageVector get() = LibSymbols.Rounded.Receipt_long
        val ReceiptLongFill: ImageVector get() = LibSymbols.RoundedFilled.Receipt_long

        // ── Action & UI Controls (Line/Outline for clean buttons) ──
        // Neram's exact Chevron back button SVG path
        val ArrowBack: ImageVector by lazy {
            symbol("ArrowBack", "M390.13,480L680.3,770.17Q696.74,786.61 696.36,809Q695.98,831.39 679.3,848.07Q662.87,864.5 640.48,864.5Q618.09,864.5 601.65,848.07L297.24,544.65Q283.57,530.98 276.85,514.07Q270.13,497.15 270.13,480Q270.13,462.85 276.85,445.93Q283.57,429.02 297.24,415.35L601.65,111.17Q618.09,94.74 640.86,95Q663.63,95.26 680.3,111.93Q696.74,128.37 696.74,150.88Q696.74,173.39 680.3,189.83L390.13,480Z")
        }
        val ArrowForward: ImageVector get() = LibSymbols.Rounded.Arrow_forward
        val Close: ImageVector get() = LibSymbols.Rounded.Close
        val Cancel: ImageVector get() = LibSymbols.RoundedFilled.Cancel
        val Check: ImageVector get() = LibSymbols.Rounded.Check
        val Add: ImageVector get() = LibSymbols.Rounded.Add
        val Search: ImageVector get() = LibSymbols.Rounded.Search
        val ChevronRight: ImageVector get() = LibSymbols.Rounded.Keyboard_arrow_right
        val KeyboardArrowDown: ImageVector get() = LibSymbols.Rounded.Keyboard_arrow_down
        val MoreVert: ImageVector get() = LibSymbols.Rounded.More_vert
        val Edit: ImageVector get() = LibSymbols.Rounded.Edit
        val EditFill: ImageVector get() = LibSymbols.RoundedFilled.Edit
        val SwapHoriz: ImageVector get() = LibSymbols.Rounded.Swap_horiz
        val Handyman: ImageVector get() = LibSymbols.Rounded.Handyman
        val CalendarToday: ImageVector get() = LibSymbols.Rounded.Calendar_today
        val AddCircle: ImageVector get() = LibSymbols.Rounded.Add_circle
        val CheckCircleFill: ImageVector get() = LibSymbols.RoundedFilled.Check_circle
        val RadioButtonUnchecked: ImageVector get() = LibSymbols.Rounded.Radio_button_unchecked
        val CheckBox: ImageVector by lazy {
            symbol("CheckBox", "M200-120q-33 0-56.5-23.5T120-200v-560q0-33 23.5-56.5T200-840h560q33 0 56.5 23.5T840-760v560q0 33-23.5 56.5T760-120H200Zm0-80h560v-560H200v560Zm214-142 284-284-56-56-228 228-114-114-56 56 170 170Z")
        }
        val CheckBoxOutlineBlank: ImageVector by lazy {
            symbol("CheckBoxOutlineBlank", "M200-120q-33 0-56.5-23.5T120-200v-560q0-33 23.5-56.5T200-840h560q33 0 56.5 23.5T840-760v560q0 33-23.5 56.5T760-120H200Zm0-80h560v-560H200v560Z")
        }
        val Restore: ImageVector by lazy {
            symbol("Restore", "M480-80q-75 0-140.5-28.5t-114-77.5q-48.5-49-77-114.5T120-440h80q0 117 81.5 198.5T480-160q117 0 198.5-81.5T760-440q0-117-81.5-198.5T480-720h-6l62 62-56 58-160-160 160-160 56 58-62 62h6q75 0 140.5 28.5t114 77.5q48.5 49 77 114.5T840-440q0 75-28.5 140.5t-77.5 114q-49 48.5-114.5 77T480-80Z")
        }

        // ── Settings Categories & Badges (Filled / Solid as per old Flutter design) ──
        val BusinessCenter: ImageVector get() = LibSymbols.RoundedFilled.Business_center
        val Apartment: ImageVector get() = LibSymbols.RoundedFilled.Business_center
        val CurrencyRupee: ImageVector by lazy {
            symbol("CurrencyRupee", "M280-160v-80h164q38-16 62-49t26-79H280v-80h252q-11-46-45.5-73.5T402-550H280v-80h380v80h-94q25 18 41 45.5t21 58.5H680v80h-48q-4 69-45 119.5T478-240h-34v80H280Z")
        }
        val LocationOn: ImageVector get() = LibSymbols.RoundedFilled.Location_on
        val CreditCard: ImageVector get() = LibSymbols.RoundedFilled.Credit_card
        val Person: ImageVector get() = LibSymbols.RoundedFilled.Person
        val LightMode: ImageVector get() = LibSymbols.RoundedFilled.Light_mode
        val DarkMode: ImageVector get() = LibSymbols.RoundedFilled.Dark_mode
        val Translate: ImageVector get() = LibSymbols.RoundedFilled.Translate
        val Folder: ImageVector get() = LibSymbols.RoundedFilled.Folder
        val Lock: ImageVector get() = LibSymbols.RoundedFilled.Lock
        val Code: ImageVector get() = LibSymbols.RoundedFilled.Code
        val Info: ImageVector get() = LibSymbols.RoundedFilled.Info
        val AutoAwesome: ImageVector get() = LibSymbols.RoundedFilled.Auto_awesome
        val Palette: ImageVector get() = LibSymbols.RoundedFilled.Palette
        val Storage: ImageVector get() = LibSymbols.RoundedFilled.Storage
        val Inventory2: ImageVector get() = LibSymbols.RoundedFilled.Inventory_2
        val Email: ImageVector get() = LibSymbols.RoundedFilled.Mail
        val Delete: ImageVector get() = LibSymbols.RoundedFilled.Delete
        val DeleteForever: ImageVector get() = LibSymbols.RoundedFilled.Delete_forever
        val CloudUpload: ImageVector get() = LibSymbols.RoundedFilled.Cloud_upload
        val Backup: ImageVector get() = LibSymbols.RoundedFilled.Backup
        val Sync: ImageVector get() = LibSymbols.RoundedFilled.Sync
        val Logout: ImageVector get() = LibSymbols.RoundedFilled.Logout
        val Settings: ImageVector get() = LibSymbols.RoundedFilled.Settings
        val EventList: ImageVector get() = LibSymbols.RoundedFilled.List
        val BrokenImage: ImageVector get() = LibSymbols.Rounded.Broken_image
        val PhotoLibrary: ImageVector get() = LibSymbols.Rounded.Photo_library
        val FolderOpen: ImageVector get() = LibSymbols.Rounded.Folder_open
    }

    /**
     * Mode icons copied 1:1 from Flutter's `AppSvgs` (`seyali_oaviyangal.dart`).
     */
    object Mode {
        val Coolie: ImageVector by lazy {
            ImageVector.Builder(
                name = "CoolieMode",
                defaultWidth = 32.dp,
                defaultHeight = 32.dp,
                viewportWidth = 256f,
                viewportHeight = 256f
            ).addPath(
                fill = SolidColor(Color.White),
                pathData = PathParser().parsePathString(
                    "M128.09,57.38a36,36,0,0,1,55.17-27.82,4,4,0,0,1-.56,7A52.06,52.06,0,0,0,152,84c0,1.17,0,2.34.12,3.49a4,4,0,0,1-6,3.76A36,36,0,0,1,128.09,57.38ZM240,160.61a24.47,24.47,0,0,1-13.6,22l-.44.2-38.83,16.54a6.94,6.94,0,0,1-1.19.4l-64,16A7.93,7.93,0,0,1,120,216H16A16,16,0,0,1,0,200V160a16,16,0,0,1,16-16H44.69l22.62-22.63A31.82,31.82,0,0,1,89.94,112H140a28,28,0,0,1,27.25,34.45l41.84-9.62A24.61,24.61,0,0,1,240,160.61Zm-16,0a8.61,8.61,0,0,0-10.87-8.3l-.31.08-67,15.41a8.32,8.32,0,0,1-1.79.2H112a8,8,0,0,1,0-16h28a12,12,0,0,0,0-24H89.94a15.86,15.86,0,0,0-11.31,4.69L56,155.31V200h63l62.43-15.61,38-16.18A8.56,8.56,0,0,0,224,160.61ZM168,84a36,36,0,1,0,36-36A36,36,0,0,0,168,84Z"
                ).toNodes()
            ).build()
        }

        val Silk: ImageVector by lazy {
            ImageVector.Builder(
                name = "SilkMode",
                defaultWidth = 32.dp,
                defaultHeight = 32.dp,
                viewportWidth = 256f,
                viewportHeight = 256f
            ).addPath(
                fill = SolidColor(Color.White),
                pathData = PathParser().parsePathString(
                    "M28,128a8,8,0,0,1,0-16H56a8,8,0,0,0,0-16H40a24,24,0,0,1,0-48,8,8,0,0,1,16,0h8a8,8,0,0,1,0,16H40a8,8,0,0,0,0,16H56a24,24,0,0,1,0,48,8,8,0,0,1-16,0ZM224,48H96a8,8,0,0,0,0,16H216V96H104a8,8,0,0,0,0,16h56v32H80a8,8,0,0,0,0,16h80v32H40V152a8,8,0,0,0-16,0v40a16,16,0,0,0,16,16H216a16,16,0,0,0,16-16V56A8,8,0,0,0,224,48Z"
                ).toNodes()
            ).build()
        }
    }

    /**
     * Custom Phosphor Navigation Bar SVG Icons matching Flutter 1:1.
     */
    object CustomNav {
        private fun navSymbol(name: String, pathData: String): ImageVector {
            return ImageVector.Builder(
                name = name,
                defaultWidth = 32.dp,
                defaultHeight = 32.dp,
                viewportWidth = 256f,
                viewportHeight = 256f
            ).addPath(
                fill = SolidColor(Color.Black),
                pathData = PathParser().parsePathString(pathData).toNodes()
            ).build()
        }

        // Tab 0: Home (Mugappu)
        val Home: ImageVector by lazy {
            navSymbol("Home", "M219.31,108.68l-80-80a16,16,0,0,0-22.62,0l-80,80A15.87,15.87,0,0,0,32,120v96a8,8,0,0,0,8,8h64a8,8,0,0,0,8-8V160h32v56a8,8,0,0,0,8,8h64a8,8,0,0,0,8-8V120A15.87,15.87,0,0,0,219.31,108.68ZM208,208H160V152a8,8,0,0,0-8-8H104a8,8,0,0,0-8,8v56H48V120l80-80,80,80Z")
        }
        val HomeFill: ImageVector by lazy {
            navSymbol("HomeFill", "M224,120v96a8,8,0,0,1-8,8H160a8,8,0,0,1-8-8V164a4,4,0,0,0-4-4H108a4,4,0,0,0-4,4v52a8,8,0,0,1-8,8H40a8,8,0,0,1-8-8V120a16,16,0,0,1,4.69-11.31l80-80a16,16,0,0,1,22.62,0l80,80A16,16,0,0,1,224,120Z")
        }

        // Tab 1: Create (Uruvaakku / Plus App - CupertinoIcons.plus_app / plus_app_fill 0xF775 / 0xF776)
        val Create: ImageVector by lazy {
            navSymbol("Create", "M232.81012658227849 24.101265822784796Q248.0 39.29113924050631 248.0 78.17721518987341V177.82278481012656Q248.0 216.70886075949366 232.81012658227849 231.89873417721518Q217.0126582278481 247.69620253164555 178.73417721518987 247.69620253164555H77.26582278481013Q38.9873417721519 247.69620253164555 23.18987341772152 231.89873417721518Q8.0 216.70886075949366 8.0 177.82278481012656V77.56962025316454Q8.0 39.29113924050631 23.18987341772152 24.101265822784796Q38.9873417721519 8.303797468354418 77.26582278481013 8.303797468354418H178.73417721518987Q217.0126582278481 8.303797468354418 232.81012658227849 24.101265822784796ZM227.34177215189874 74.53164556962025Q227.34177215189874 49.01265822784808 217.62025316455697 39.29113924050631Q207.8987341772152 29.569620253164544 182.37974683544303 29.569620253164544H74.22784810126582Q48.10126582278481 29.569620253164544 38.379746835443036 39.29113924050631Q28.658227848101266 49.01265822784808 28.658227848101266 74.53164556962025V181.46835443037975Q28.658227848101266 206.9873417721519 38.379746835443036 216.70886075949366Q48.10126582278481 226.43037974683543 73.62025316455697 226.43037974683543H182.37974683544303Q207.8987341772152 226.43037974683543 217.62025316455697 216.70886075949366Q227.34177215189874 206.9873417721519 227.34177215189874 181.46835443037975ZM128.30379746835445 197.26582278481013Q118.58227848101266 197.26582278481013 118.58227848101266 188.15189873417722V137.1139240506329H68.15189873417722Q63.89873417721519 137.1139240506329 61.164556962025316 134.37974683544303Q58.43037974683544 131.64556962025316 58.43037974683544 128.0Q58.43037974683544 124.35443037974683 61.164556962025316 121.62025316455696Q63.89873417721519 118.88607594936708 68.15189873417722 118.88607594936708H118.58227848101266V67.84810126582278Q118.58227848101266 58.12658227848101 128.30379746835445 58.12658227848101Q137.41772151898735 58.12658227848101 137.41772151898735 67.84810126582278V118.88607594936708H188.45569620253164Q197.56962025316457 118.88607594936708 197.56962025316457 128.0Q197.56962025316457 137.1139240506329 188.45569620253164 137.1139240506329H137.41772151898735V188.15189873417722Q137.41772151898735 197.26582278481013 128.30379746835445 197.26582278481013Z")
        }
        val CreateFill: ImageVector by lazy {
            navSymbol("CreateFill", "M248.0 78.15384615384616V177.84615384615387Q248.0 217.23076923076923 232.61538461538464 232.6153846153846Q217.23076923076925 248.0 177.84615384615387 248.0H78.15384615384616Q38.769230769230774 248.0 23.384615384615387 232.6153846153846Q8.0 217.23076923076923 8.0 177.84615384615387V78.15384615384616Q8.0 38.769230769230774 23.384615384615387 23.384615384615387Q38.769230769230774 8.0 78.15384615384616 8.0H177.84615384615387Q217.23076923076925 8.0 232.61538461538464 23.384615384615387Q248.0 38.769230769230774 248.0 78.15384615384616ZM138.46153846153848 195.0769230769231V138.46153846153845H195.0769230769231Q199.3846153846154 138.46153846153845 202.46153846153845 135.3846153846154Q205.53846153846155 132.30769230769232 205.53846153846155 128.0Q205.53846153846155 123.6923076923077 202.46153846153845 120.61538461538461Q199.3846153846154 117.53846153846155 195.0769230769231 117.53846153846155H138.46153846153848V60.923076923076906Q138.46153846153848 50.46153846153845 128.0 50.46153846153845Q123.6923076923077 50.46153846153845 120.61538461538461 53.53846153846153Q117.53846153846155 56.61538461538461 117.53846153846155 60.923076923076906V117.53846153846155H60.92307692307693Q56.61538461538462 117.53846153846155 53.53846153846155 120.61538461538461Q50.46153846153847 123.6923076923077 50.46153846153847 128.0Q50.46153846153847 132.30769230769232 53.53846153846155 135.3846153846154Q56.61538461538462 138.46153846153845 60.92307692307693 138.46153846153845H117.53846153846155V195.0769230769231Q117.53846153846155 199.3846153846154 120.61538461538461 202.46153846153845Q123.6923076923077 205.53846153846155 128.0 205.53846153846155Q132.30769230769232 205.53846153846155 135.38461538461542 202.46153846153845Q138.46153846153848 199.3846153846154 138.46153846153848 195.0769230769231Z")
        }

        // Tab 2: Products (Porul / Cube Box - CupertinoIcons.cube_box / cube_box_fill 0xF61B / 0xF61C)
        val Products: ImageVector by lazy {
            navSymbol("Products", "M32.358974358974365 196.71794871794873Q16.461538461538467 188.0 16.461538461538467 169.02564102564105V81.84615384615387Q16.461538461538467 65.43589743589746 30.307692307692314 57.74358974358978L107.74358974358974 13.641025641025664Q127.74358974358974 2.3589743589743932 147.74358974358972 13.641025641025664L225.69230769230768 57.74358974358978Q239.53846153846155 65.43589743589746 239.53846153846155 81.84615384615387V169.02564102564105Q239.53846153846155 188.0 223.64102564102564 196.71794871794873L137.4871794871795 245.43589743589743Q127.74358974358974 250.56410256410257 118.51282051282051 245.43589743589743ZM179.53846153846155 89.02564102564105 211.8461538461538 71.0769230769231 140.05128205128204 30.051282051282072Q127.74358974358974 23.384615384615415 115.94871794871794 30.051282051282072L95.43589743589743 41.33333333333337ZM127.74358974358974 118.25641025641028 161.0769230769231 99.79487179487181 76.97435897435898 52.102564102564116 44.15384615384616 71.0769230769231ZM42.61538461538462 181.33333333333334 118.51282051282051 224.4102564102564V134.66666666666669L34.410256410256416 86.46153846153848V168.51282051282053Q34.410256410256416 176.71794871794873 42.61538461538462 181.33333333333334ZM213.38461538461536 181.33333333333334Q221.5897435897436 176.71794871794873 221.5897435897436 168.51282051282053V86.46153846153848L136.97435897435895 134.66666666666669V224.4102564102564Z")
        }
        val ProductsFill: ImageVector by lazy {
            navSymbol("ProductsFill", "M190.57510729613733 86.28326180257511 85.5107296137339 26.540772532188868 107.65665236051503 13.665236051502177Q116.92703862660944 8.000000000000028 127.74248927038627 8.000000000000028Q138.5579399141631 8.000000000000028 147.8283261802575 13.665236051502177L226.11158798283262 58.47210300429185Q230.23175965665234 61.047210300429214 231.77682403433477 62.59227467811161ZM127.74248927038626 121.8197424892704 24.223175965665238 62.59227467811161Q26.283261802575108 61.047210300429214 29.888412017167383 58.47210300429185L70.57510729613733 35.296137339055804L175.1244635193133 95.03862660944208ZM135.46781115879827 248.0V134.6952789699571L238.9871244635193 75.4678111587983Q240.01716738197425 80.61802575107299 240.01716738197425 84.22317596566526V170.23175965665237Q240.01716738197425 189.2875536480687 224.05150214592274 198.04291845493563L137.52789699570815 246.96995708154506ZM120.53218884120172 248.0 118.47210300429184 246.96995708154506 31.948497854077253 198.04291845493563Q15.982832618025753 189.2875536480687 15.982832618025753 170.23175965665237V84.22317596566526Q15.982832618025753 80.61802575107299 17.01287553648069 75.4678111587983L120.53218884120172 134.6952789699571Z")
        }

        // Tab 3: Customers (Vaangunar / Users)
        val Customers: ImageVector by lazy {
            navSymbol("Customers", "M117.25,157.92a60,60,0,1,0-66.5,0A95.83,95.83,0,0,0,3.53,195.63a8,8,0,1,0,13.4,8.74,80,80,0,0,1,134.14,0,8,8,0,0,0,13.4-8.74A95.83,95.83,0,0,0,117.25,157.92ZM40,108a44,44,0,1,1,44,44A44.05,44.05,0,0,1,40,108Zm210.14,98.7a8,8,0,0,1-11.07-2.33A79.83,79.83,0,0,0,172,168a8,8,0,0,1,0-16,44,44,0,1,0-16.34-84.87,8,8,0,1,1-5.94-14.85,60,60,0,0,1,55.53,105.64,95.83,95.83,0,0,1,47.22,37.71A8,8,0,0,1,250.14,206.7Z")
        }
        val CustomersFill: ImageVector by lazy {
            navSymbol("CustomersFill", "M164.47,195.63a8,8,0,0,1-6.7,12.37H10.23a8,8,0,0,1-6.7-12.37,95.83,95.83,0,0,1,47.22-37.71,60,60,0,1,1,66.5,0A95.83,95.83,0,0,1,164.47,195.63Zm87.91-.15a95.87,95.87,0,0,0-47.13-37.56A60,60,0,0,0,144.7,54.59a4,4,0,0,0-1.33,6A75.83,75.83,0,0,1,147,150.53a4,4,0,0,0,1.07,5.53,112.32,112.32,0,0,1,29.85,30.83,23.92,23.92,0,0,1,3.65,16.47,4,4,0,0,0,3.95,4.64h60.3a8,8,0,0,0,7.73-5.93A8.22,8.22,0,0,0,252.38,195.48Z")
        }
    }
}

/**
 * AppSvgs — Direct access mirroring Flutter's AppSvgs.
 */
object AppSvgs {
    val coolieMode: ImageVector get() = MaterialSymbols.Mode.Coolie
    val silkMode: ImageVector get() = MaterialSymbols.Mode.Silk
}
