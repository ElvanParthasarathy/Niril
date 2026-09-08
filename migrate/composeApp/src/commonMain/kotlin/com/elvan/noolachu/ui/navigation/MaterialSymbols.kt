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
            navSymbol("Create", "M213.59493670886076 43.14936708860759Q226.0 55.55443037974683 226.0 87.31139240506329V168.6886075949367Q226.0 200.44556962025317 213.59493670886076 212.8506329113924Q200.69367088607595 225.75189873417722 169.43291139240506 225.75189873417722H86.56708860759494Q55.30632911392405 225.75189873417722 42.40506329113924 212.8506329113924Q30.0 200.44556962025317 30.0 168.6886075949367V86.81518987341772Q30.0 55.55443037974683 42.40506329113924 43.14936708860759Q55.30632911392405 30.248101265822783 86.56708860759494 30.248101265822783H169.43291139240506Q200.69367088607595 30.248101265822783 213.59493670886076 43.14936708860759ZM209.1291139240506 84.33417721518987Q209.1291139240506 63.49367088607596 201.18987341772151 55.55443037974685Q193.2506329113924 47.615189873417734 172.41012658227848 47.615189873417734H84.08607594936709Q62.74936708860759 47.615189873417734 54.81012658227848 55.55443037974685Q46.870886075949365 63.49367088607596 46.870886075949365 84.33417721518987V171.66582278481013Q46.870886075949365 192.50632911392404 54.81012658227848 200.44556962025314Q62.74936708860759 208.38481012658227 83.58987341772152 208.38481012658227H172.41012658227848Q193.2506329113924 208.38481012658227 201.18987341772151 200.44556962025314Q209.1291139240506 192.50632911392404 209.1291139240506 171.66582278481013ZM128.24810126582278 184.56708860759494Q120.30886075949367 184.56708860759494 120.30886075949367 177.1240506329114V135.44303797468353H79.12405063291139Q75.6506329113924 135.44303797468353 73.41772151898735 133.21012658227846Q71.18481012658228 130.97721518987342 71.18481012658228 128.0Q71.18481012658228 125.02278481012658 73.41772151898735 122.78987341772151Q75.6506329113924 120.55696202531645 79.12405063291139 120.55696202531645H120.30886075949367V78.87594936708862Q120.30886075949367 70.9367088607595 128.24810126582278 70.9367088607595Q135.69113924050635 70.9367088607595 135.69113924050635 78.87594936708862V120.55696202531645H177.37215189873416Q184.81518987341772 120.55696202531645 184.81518987341772 128.0Q184.81518987341772 135.44303797468353 177.37215189873416 135.44303797468353H135.69113924050635V177.1240506329114Q135.69113924050635 184.56708860759494 128.24810126582278 184.56708860759494Z")
        }
        val CreateFill: ImageVector by lazy {
            navSymbol("CreateFill", "M226.0 87.2923076923077V168.7076923076923Q226.0 200.87179487179486 213.43589743589743 213.43589743589743Q200.87179487179486 226.0 168.7076923076923 226.0H87.29230769230769Q55.128205128205124 226.0 42.56410256410256 213.43589743589743Q30.0 200.87179487179486 30.0 168.7076923076923V87.2923076923077Q30.0 55.12820512820514 42.56410256410256 42.56410256410257Q55.128205128205124 30.0 87.29230769230769 30.0H168.7076923076923Q200.87179487179486 30.0 213.43589743589743 42.56410256410257Q226.0 55.12820512820514 226.0 87.2923076923077ZM136.54358974358973 182.77948717948718V136.54358974358973H182.77948717948718Q186.2974358974359 136.54358974358973 188.8102564102564 134.03076923076924Q191.3230769230769 131.5179487179487 191.3230769230769 128.0Q191.3230769230769 124.48205128205129 188.8102564102564 121.96923076923076Q186.2974358974359 119.45641025641025 182.77948717948718 119.45641025641025H136.54358974358973V73.22051282051282Q136.54358974358973 64.67692307692309 128.0 64.67692307692309Q124.48205128205129 64.67692307692309 121.96923076923076 67.1897435897436Q119.45641025641025 69.70256410256411 119.45641025641025 73.22051282051282V119.45641025641025H73.22051282051282Q69.70256410256411 119.45641025641025 67.18974358974359 121.96923076923076Q64.67692307692307 124.48205128205129 64.67692307692307 128.0Q64.67692307692307 131.5179487179487 67.18974358974359 134.03076923076924Q69.70256410256411 136.54358974358973 73.22051282051282 136.54358974358973H119.45641025641025V182.77948717948718Q119.45641025641025 186.2974358974359 121.96923076923076 188.81025641025641Q124.48205128205129 191.32307692307694 128.0 191.32307692307694Q131.5179487179487 191.32307692307694 134.03076923076924 188.81025641025641Q136.54358974358973 186.2974358974359 136.54358974358973 182.77948717948718Z")
        }

        // Tab 2: Products (Porul / Cube Box - CupertinoIcons.cube_box / cube_box_fill 0xF61B / 0xF61C)
        val Products: ImageVector by lazy {
            navSymbol("Products", "M49.89316239316239 184.11965811965814Q36.91025641025641 177.0 36.91025641025641 161.5042735042735V90.30769230769232Q36.91025641025641 76.90598290598291 48.217948717948715 70.62393162393164L111.45726495726495 34.606837606837615Q127.7905982905983 25.393162393162413 144.12393162393164 34.606837606837615L207.7820512820513 70.62393162393164Q219.0897435897436 76.90598290598291 219.0897435897436 90.30769230769232V161.5042735042735Q219.0897435897436 177.0 206.10683760683762 184.11965811965814L135.74786324786325 223.9059829059829Q127.7905982905983 228.0940170940171 120.25213675213675 223.9059829059829ZM170.0897435897436 96.17094017094018 196.47435897435898 81.51282051282053 137.84188034188034 48.008547008547026Q127.7905982905983 42.56410256410257 118.15811965811966 48.008547008547026L101.40598290598291 57.22222222222223ZM127.7905982905983 120.04273504273505 155.0128205128205 104.96581196581198 86.32905982905983 66.01709401709402 59.52564102564102 81.51282051282053ZM58.269230769230774 171.55555555555557 120.25213675213675 206.73504273504275V133.44444444444446L51.56837606837607 94.07692307692308V161.0854700854701Q51.56837606837607 167.7863247863248 58.269230769230774 171.55555555555557ZM197.73076923076923 171.55555555555557Q204.43162393162393 167.7863247863248 204.43162393162393 161.0854700854701V94.07692307692308L135.32905982905982 133.44444444444446V206.73504273504275Z")
        }
        val ProductsFill: ImageVector by lazy {
            navSymbol("ProductsFill", "M179.10300429184548 93.93133047210301 93.30042918454936 45.141630901287556 111.38626609442059 34.6266094420601Q118.95708154506437 30.0 127.78969957081544 30.0Q136.62231759656652 30.0 144.1931330472103 34.6266094420601L208.12446351931328 71.21888412017168Q211.48927038626607 73.32188841201719 212.75107296137338 74.58369098712447ZM127.78969957081544 122.95278969957083 43.248927038626604 74.58369098712447Q44.931330472103 73.32188841201719 47.87553648068669 71.21888412017168L81.10300429184548 52.29184549356225L166.48497854077254 101.08154506437769ZM134.09871244635193 226.0V133.4678111587983L218.6394849785408 85.09871244635194Q219.48068669527896 89.30472103004293 219.48068669527896 92.24892703862662V162.4892703862661Q219.48068669527896 178.05150214592277 206.44206008583689 185.20171673819743L135.78111587982832 225.1587982832618ZM121.90128755364806 226.0 120.21888412017167 225.1587982832618 49.557939914163086 185.20171673819743Q36.519313304721024 178.05150214592277 36.519313304721024 162.4892703862661V92.24892703862662Q36.519313304721024 89.30472103004293 37.36051502145922 85.09871244635194L121.90128755364806 133.4678111587983Z")
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
