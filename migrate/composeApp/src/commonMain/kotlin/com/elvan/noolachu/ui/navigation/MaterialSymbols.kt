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

        // Tab 1: Create (Uruvaakku / Plus App)
        val Create: ImageVector by lazy {
            navSymbol("Create", "M208,32H48A16,16,0,0,0,32,48V208a16,16,0,0,0,16,16H208a16,16,0,0,0,16-16V48A16,16,0,0,0,208,32Zm0,176H48V48H208V208Zm-48-88a8,8,0,0,1-8,8H136v16a8,8,0,0,1-16,0V128H104a8,8,0,0,1,0-16h16V96a8,8,0,0,1,16,0v16h16A8,8,0,0,1,160,120Z")
        }
        val CreateFill: ImageVector by lazy {
            navSymbol("CreateFill", "M208,32H48A16,16,0,0,0,32,48V208a16,16,0,0,0,16,16H208a16,16,0,0,0,16-16V48A16,16,0,0,0,208,32ZM160,128H136v24a8,8,0,0,1-16,0V128H96a8,8,0,0,1,0-16h24V88a8,8,0,0,1,16,0v24h24a8,8,0,0,1,0,16Z")
        }

        // Tab 2: Products (Porul / Cube)
        val Products: ImageVector by lazy {
            navSymbol("Products", "M223.68,66.15,135.68,18a15.88,15.88,0,0,0-15.36,0l-88,48.17a16,16,0,0,0-8.32,14v95.64a16,16,0,0,0,8.32,14l88,48.17a15.88,15.88,0,0,0,15.36,0l88-48.17a16,16,0,0,0,8.32-14V80.18A16,16,0,0,0,223.68,66.15ZM128,32l80.36,44L128,120,47.64,76ZM40,90.18l80,43.81v87.83L40,178ZM136,221.82V134l80-43.81V178Z")
        }
        val ProductsFill: ImageVector by lazy {
            navSymbol("ProductsFill", "M223.68,66.15,135.68,18a15.88,15.88,0,0,0-15.36,0l-88,48.17a16,16,0,0,0-8.32,14v95.64a16,16,0,0,0,8.32,14l88,48.17a15.88,15.88,0,0,0,15.36,0l88-48.17a16,16,0,0,0,8.32-14V80.18A16,16,0,0,0,223.68,66.15ZM128,120,47.64,76,128,32l80.36,44Z")
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
