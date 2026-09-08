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
}

/**
 * AppSvgs — Direct access mirroring Flutter's AppSvgs.
 */
object AppSvgs {
    val coolieMode: ImageVector get() = MaterialSymbols.Mode.Coolie
    val silkMode: ImageVector get() = MaterialSymbols.Mode.Silk
}
