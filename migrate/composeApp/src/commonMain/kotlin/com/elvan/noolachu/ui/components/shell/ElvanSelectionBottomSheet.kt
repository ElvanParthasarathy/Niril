package com.elvan.noolachu.ui.components.shell

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyListState
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.ScrollState
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawWithContent
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.elvan.noolachu.localization.tr
import com.elvan.noolachu.theme.ShellColors
import com.elvan.noolachu.theme.rememberShellColors
import com.elvan.noolachu.core.platform.ConfigureDialogWindow
import com.elvan.noolachu.ui.components.shell.maeladukkugal.*

/**
 * ElvanSelectionBottomSheet — Flutter-matching selection bottom sheet.
 * Replicates `showElvanSelectionBottomSheet` and `ElvanSelectionBottomSheet` in Flutter (`elvan_kizh_maeladukku.dart`).
 * Modular architecture using:
 * - `ElvanMaeladukkuThalaipu` (Header)
 * - `ElvanMaeladukkuThaedal` (Cupertino Search Pill)
 * - `ElvanMaeladukkuUrupadi` (List Item with Monochrome Checkmark)
 * - `ElvanMaeladukkuPudhiyaPothan` (Centered Add New Action)
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun <T> ElvanSelectionBottomSheet(
    title: String,
    items: List<T>,
    currentValue: T?,
    onSelected: (T) -> Unit,
    onDismissRequest: () -> Unit,
    modifier: Modifier = Modifier,
    colors: ShellColors = rememberShellColors(),
    itemLabelBuilder: (T) -> String,
    subtitleBuilder: ((T) -> String?)? = null,
    leadingBuilder: (@Composable (T) -> Unit)? = null,
    showSearch: Boolean = false,
    searchFilter: ((T, String) -> Boolean)? = null,
    onRequestAddNew: (() -> Unit)? = null,
    addNewLabel: String? = null
) {
    val isDark = colors.isDark
    val sheetBg = if (isDark) Color(0xFF111111) else Color.White
    var searchQuery by remember { mutableStateOf("") }

    val filteredItems = remember(items, searchQuery) {
        if (searchQuery.isBlank()) {
            items
        } else if (searchFilter != null) {
            items.filter { searchFilter(it, searchQuery) }
        } else {
            items.filter { item ->
                itemLabelBuilder(item).contains(searchQuery, ignoreCase = true) ||
                        (subtitleBuilder?.invoke(item)?.contains(searchQuery, ignoreCase = true) == true)
            }
        }
    }

    val content: @Composable () -> Unit = {
        ConfigureDialogWindow(isDark = isDark)
        BoxWithConstraints(modifier = Modifier.fillMaxWidth()) {
            // Dynamic max list height restricted to 65% of available sheet height (capped between 220.dp and 520.dp)
            val maxListHeight = (maxHeight * 0.65f).coerceIn(220.dp, 520.dp)

            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .navigationBarsPadding()
                    .imePadding()
            ) {
                // 1. Title matching Flutter's ElvanMaeladukkuThalaipu
                ElvanMaeladukkuThalaipu(
                    title = title,
                    colors = colors
                )

                // 2. Search pill if enabled matching Flutter's ElvanMaeladukkuThaedal
                if (showSearch) {
                    ElvanMaeladukkuThaedal(
                        value = searchQuery,
                        onValueChange = { searchQuery = it },
                        colors = colors
                    )
                }

                // 3. Dynamic Items list matching Flutter:
                // Small list (<= 25 items): dynamically wraps content using Column + verticalScroll
                // Large list (> 25 items): uses LazyColumn with recycling capped at maxListHeight
                val isSmallList = filteredItems.size <= 25

                if (isSmallList) {
                    val scrollState = rememberScrollState()
                    val isScrolling = scrollState.isScrollInProgress
                    val scrollbarAlpha by animateFloatAsState(
                        targetValue = if (isScrolling) 1f else 0f,
                        animationSpec = tween(durationMillis = 300),
                        label = "sheetScrollbarAlpha"
                    )
                    val scrollbarColor = if (isDark) Color.White.copy(alpha = 0.35f) else Color.Black.copy(alpha = 0.35f)

                    val canScrollMore by remember {
                        derivedStateOf { scrollState.value < scrollState.maxValue }
                    }
                    val canScrollBack by remember {
                        derivedStateOf { scrollState.value > 0 }
                    }

                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .heightIn(max = maxListHeight)
                    ) {
                        Column(
                            modifier = Modifier
                                .fillMaxWidth()
                                .verticalScroll(scrollState)
                                .drawScrollbar(
                                    scrollState = scrollState,
                                    color = scrollbarColor,
                                    alpha = scrollbarAlpha
                                )
                                .padding(top = 4.dp, bottom = if (onRequestAddNew != null) 8.dp else 24.dp)
                        ) {
                            filteredItems.forEach { item ->
                                val isSelected = item == currentValue
                                val subtitle = subtitleBuilder?.invoke(item)

                                ElvanMaeladukkuUrupadi(
                                    title = itemLabelBuilder(item),
                                    subtitle = subtitle,
                                    isSelected = isSelected,
                                    onTap = {
                                        onSelected(item)
                                        onDismissRequest()
                                    },
                                    leading = leadingBuilder?.let { { it(item) } },
                                    colors = colors
                                )
                            }
                        }

                        // Top Fade Mask (only when scrolled down)
                        val topFadeAlpha by animateFloatAsState(
                            targetValue = if (canScrollBack) 1f else 0f,
                            label = "sheetTopFadeAlpha"
                        )
                        if (topFadeAlpha > 0f) {
                            Box(
                                modifier = Modifier
                                    .align(Alignment.TopCenter)
                                    .fillMaxWidth()
                                    .height(24.dp)
                                    .graphicsLayer { alpha = topFadeAlpha }
                                    .background(
                                        Brush.verticalGradient(
                                            0.0f to sheetBg,
                                            0.35f to sheetBg.copy(alpha = 0.55f),
                                            0.7f to sheetBg.copy(alpha = 0.16f),
                                            1.0f to Color.Transparent
                                        )
                                    )
                            )
                        }

                        // Bottom Fade Mask (only when content overflows)
                        val bottomFadeAlpha by animateFloatAsState(
                            targetValue = if (canScrollMore) 1f else 0f,
                            label = "sheetBottomFadeAlpha"
                        )
                        if (bottomFadeAlpha > 0f) {
                            Box(
                                modifier = Modifier
                                    .align(Alignment.BottomCenter)
                                    .fillMaxWidth()
                                    .height(28.dp)
                                    .graphicsLayer { alpha = bottomFadeAlpha }
                                    .background(
                                        Brush.verticalGradient(
                                            0.0f to Color.Transparent,
                                            0.3f to sheetBg.copy(alpha = 0.16f),
                                            0.65f to sheetBg.copy(alpha = 0.55f),
                                            1.0f to sheetBg
                                        )
                                    )
                            )
                        }
                    }
                } else {
                    val listState = rememberLazyListState()
                    val isScrolling = listState.isScrollInProgress
                    val scrollbarAlpha by animateFloatAsState(
                        targetValue = if (isScrolling) 1f else 0f,
                        animationSpec = tween(durationMillis = 300),
                        label = "sheetLazyScrollbarAlpha"
                    )
                    val scrollbarColor = if (isDark) Color.White.copy(alpha = 0.35f) else Color.Black.copy(alpha = 0.35f)

                    val canScrollMore by remember {
                        derivedStateOf { listState.canScrollForward }
                    }
                    val canScrollBack by remember {
                        derivedStateOf { listState.firstVisibleItemIndex > 0 || listState.firstVisibleItemScrollOffset > 0 }
                    }

                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(maxListHeight)
                    ) {
                        LazyColumn(
                            state = listState,
                            modifier = Modifier
                                .fillMaxSize()
                                .drawVerticalScrollbar(
                                    listState = listState,
                                    color = scrollbarColor,
                                    alpha = scrollbarAlpha
                                ),
                            contentPadding = PaddingValues(top = 4.dp, bottom = if (onRequestAddNew != null) 8.dp else 24.dp)
                        ) {
                            items(filteredItems) { item ->
                                val isSelected = item == currentValue
                                val subtitle = subtitleBuilder?.invoke(item)

                                ElvanMaeladukkuUrupadi(
                                    title = itemLabelBuilder(item),
                                    subtitle = subtitle,
                                    isSelected = isSelected,
                                    onTap = {
                                        onSelected(item)
                                        onDismissRequest()
                                    },
                                    leading = leadingBuilder?.let { { it(item) } },
                                    colors = colors
                                )
                            }
                        }

                        // Top Fade Mask
                        val topFadeAlpha by animateFloatAsState(
                            targetValue = if (canScrollBack) 1f else 0f,
                            label = "sheetLazyTopFadeAlpha"
                        )
                        if (topFadeAlpha > 0f) {
                            Box(
                                modifier = Modifier
                                    .align(Alignment.TopCenter)
                                    .fillMaxWidth()
                                    .height(24.dp)
                                    .graphicsLayer { alpha = topFadeAlpha }
                                    .background(
                                        Brush.verticalGradient(
                                            0.0f to sheetBg,
                                            0.35f to sheetBg.copy(alpha = 0.55f),
                                            0.7f to sheetBg.copy(alpha = 0.16f),
                                            1.0f to Color.Transparent
                                        )
                                    )
                            )
                        }

                        // Bottom Fade Mask
                        val bottomFadeAlpha by animateFloatAsState(
                            targetValue = if (canScrollMore) 1f else 0f,
                            label = "sheetLazyBottomFadeAlpha"
                        )
                        if (bottomFadeAlpha > 0f) {
                            Box(
                                modifier = Modifier
                                    .align(Alignment.BottomCenter)
                                    .fillMaxWidth()
                                    .height(28.dp)
                                    .graphicsLayer { alpha = bottomFadeAlpha }
                                    .background(
                                        Brush.verticalGradient(
                                            0.0f to Color.Transparent,
                                            0.3f to sheetBg.copy(alpha = 0.16f),
                                            0.65f to sheetBg.copy(alpha = 0.55f),
                                            1.0f to sheetBg
                                        )
                                    )
                            )
                        }
                    }
                }

                // 4. Optional "+ Add New" button matching Flutter's ElvanMaeladukkuPudhiyaPothan
                if (onRequestAddNew != null) {
                    ElvanMaeladukkuPudhiyaPothan(
                        onTap = {
                            onDismissRequest()
                            onRequestAddNew()
                        },
                        label = addNewLabel ?: com.elvan.noolachu.localization.K.pudhiyaChaerkkai.tr(),
                        colors = colors
                    )
                } else {
                    Spacer(modifier = Modifier.height(4.dp))
                }
            }
        }
    }

    if (com.elvan.noolachu.core.platform.currentPlatform == com.elvan.noolachu.core.platform.PlatformType.DESKTOP) {
        androidx.compose.ui.window.Dialog(onDismissRequest = onDismissRequest) {
            Surface(
                shape = RoundedCornerShape(16.dp),
                color = sheetBg,
                shadowElevation = 8.dp,
                modifier = Modifier
                    .widthIn(max = 480.dp)
                    .fillMaxWidth()
                    .padding(16.dp)
            ) {
                content()
            }
        }
    } else {
        val sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)

        ModalBottomSheet(
            onDismissRequest = onDismissRequest,
            sheetState = sheetState,
            shape = RoundedCornerShape(topStart = 28.dp, topEnd = 28.dp),
            containerColor = sheetBg,
            scrimColor = Color.Black.copy(alpha = 0.45f),
            dragHandle = { BottomSheetDefaults.DragHandle() },
            modifier = modifier
        ) {
            content()
        }
    }
}

/**
 * Clean vertical scrollbar indicator along the right edge of LazyColumn.
 * Smoothly fades in while actively scrolling and auto-hides when resting.
 */
private fun Modifier.drawVerticalScrollbar(
    listState: LazyListState,
    color: Color,
    alpha: Float,
    width: Dp = 3.dp,
    paddingEnd: Dp = 3.dp
): Modifier = drawWithContent {
    drawContent()
    val layoutInfo = listState.layoutInfo
    val totalItemsCount = layoutInfo.totalItemsCount
    val visibleItems = layoutInfo.visibleItemsInfo
    if (totalItemsCount > 0 && visibleItems.isNotEmpty() && alpha > 0.02f) {
        val firstVisible = visibleItems.first()
        val lastVisible = visibleItems.last()
        val visibleCount = lastVisible.index - firstVisible.index + 1
        if (visibleCount < totalItemsCount) {
            val viewHeight = size.height
            val thumbHeight = ((viewHeight * visibleCount) / totalItemsCount).coerceIn(24.dp.toPx(), viewHeight * 0.75f)
            val maxScrollIndex = (totalItemsCount - visibleCount).coerceAtLeast(1)
            val scrollProgress = (firstVisible.index.toFloat() / maxScrollIndex).coerceIn(0f, 1f)
            val scrollOffset = scrollProgress * (viewHeight - thumbHeight)
            drawRoundRect(
                color = color.copy(alpha = color.alpha * alpha),
                topLeft = Offset(size.width - width.toPx() - paddingEnd.toPx(), scrollOffset),
                size = Size(width.toPx(), thumbHeight),
                cornerRadius = CornerRadius(width.toPx() / 2, width.toPx() / 2)
            )
        }
    }
}

/**
 * Clean vertical scrollbar indicator along the right edge of a scrollable Column.
 * Smoothly fades in while actively scrolling and auto-hides when resting.
 */
private fun Modifier.drawScrollbar(
    scrollState: ScrollState,
    color: Color,
    alpha: Float,
    width: Dp = 3.dp,
    paddingEnd: Dp = 3.dp
): Modifier = drawWithContent {
    drawContent()
    if (scrollState.maxValue > 0 && alpha > 0.02f) {
        val viewHeight = size.height
        val totalContentHeight = viewHeight + scrollState.maxValue
        val thumbHeight = ((viewHeight * viewHeight) / totalContentHeight).coerceIn(24.dp.toPx(), viewHeight * 0.75f)
        val scrollProgress = (scrollState.value.toFloat() / scrollState.maxValue.toFloat()).coerceIn(0f, 1f)
        val scrollOffset = scrollProgress * (viewHeight - thumbHeight)
        drawRoundRect(
            color = color.copy(alpha = color.alpha * alpha),
            topLeft = Offset(size.width - width.toPx() - paddingEnd.toPx(), scrollOffset),
            size = Size(width.toPx(), thumbHeight),
            cornerRadius = CornerRadius(width.toPx() / 2, width.toPx() / 2)
        )
    }
}
