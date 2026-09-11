package com.elvan.noolachu.ui.screens.ulnuzhaivu.koorugal

import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import com.elvan.noolachu.ui.navigation.MaterialSymbols
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.delay

@Composable
fun AuthLayout(
    showBranding: Boolean = false,
    floatingActionButton: @Composable () -> Unit = {},
    content: @Composable ColumnScope.() -> Unit
) {
    val isDark = isSystemInDarkTheme()
    val bgColor = if (isDark) Color(0xFF0A0A0A) else Color(0xFFFAFAFA)
    val shapeColor = if (isDark) Color.White.copy(alpha = 0.03f) else Color(0xFFEAEAEA)

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(bgColor)
    ) {
        val infiniteTransition = rememberInfiniteTransition()
        
        // Top-right rotating rounded square
        val rotation by infiniteTransition.animateFloat(
            initialValue = 0f,
            targetValue = 360f,
            animationSpec = infiniteRepeatable(
                animation = tween(20000, easing = LinearEasing),
                repeatMode = RepeatMode.Restart
            )
        )
        Box(
            modifier = Modifier
                .offset(x = 100.dp, y = (-100).dp)
                .size(300.dp)
                .rotate(rotation)
                .background(shapeColor, RoundedCornerShape(60.dp))
                .align(Alignment.TopEnd)
        )

        // Bottom-left floating circle
        val floatY by infiniteTransition.animateFloat(
            initialValue = 0f,
            targetValue = 30f,
            animationSpec = infiniteRepeatable(
                animation = tween(4000, easing = FastOutSlowInEasing),
                repeatMode = RepeatMode.Reverse
            )
        )
        Box(
            modifier = Modifier
                .offset(x = (-50).dp, y = floatY.dp)
                .size(200.dp)
                .background(shapeColor, CircleShape)
                .align(Alignment.BottomStart)
        )

        // Top-left counter-rotating small square
        val counterRotation by infiniteTransition.animateFloat(
            initialValue = 360f,
            targetValue = 0f,
            animationSpec = infiniteRepeatable(
                animation = tween(15000, easing = LinearEasing),
                repeatMode = RepeatMode.Restart
            )
        )
        Box(
            modifier = Modifier
                .offset(x = (-20).dp, y = 100.dp)
                .size(100.dp)
                .rotate(counterRotation)
                .background(shapeColor, RoundedCornerShape(20.dp))
                .align(Alignment.TopStart)
        )

        // Center-right floating small circle
        val smallFloatY by infiniteTransition.animateFloat(
            initialValue = 0f,
            targetValue = -20f,
            animationSpec = infiniteRepeatable(
                animation = tween(3000, easing = FastOutSlowInEasing),
                repeatMode = RepeatMode.Reverse
            )
        )
        Box(
            modifier = Modifier
                .offset(x = 20.dp, y = smallFloatY.dp)
                .size(80.dp)
                .background(shapeColor, CircleShape)
                .align(Alignment.CenterEnd)
        )

        Box(
            modifier = Modifier.fillMaxSize(),
            contentAlignment = Alignment.Center
        ) {
            Column(
                modifier = Modifier
                    .widthIn(max = 480.dp)
                    .fillMaxWidth()
                    .padding(horizontal = 24.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                content()
            }
        }
        
        if (showBranding) {
            Text(
                text = "Elvan Parthasarathy",
                color = if (isDark) Color.White.copy(alpha = 0.5f) else Color.Black.copy(alpha = 0.5f),
                fontSize = 12.sp,
                modifier = Modifier
                    .align(Alignment.BottomCenter)
                    .padding(bottom = 24.dp)
            )
        }
        
        Box(
            modifier = Modifier
                .align(Alignment.BottomEnd)
                .padding(24.dp)
        ) {
            floatingActionButton()
        }
    }
}

@Composable
fun AuthAnimatedElement(
    delayIndex: Int,
    content: @Composable () -> Unit
) {
    var isVisible by remember { mutableStateOf(false) }
    
    LaunchedEffect(Unit) {
        delay(delayIndex * 100L)
        isVisible = true
    }

    val alpha by animateFloatAsState(
        targetValue = if (isVisible) 1f else 0f,
        animationSpec = tween(durationMillis = 800, easing = EaseOut)
    )
    
    val translateY by animateFloatAsState(
        targetValue = if (isVisible) 0f else 20f,
        animationSpec = tween(durationMillis = 800, easing = EaseOut)
    )

    Box(
        modifier = Modifier
            .alpha(alpha)
            .offset(y = translateY.dp)
            .fillMaxWidth()
    ) {
        content()
    }
}

@Composable
fun AuthHeader(title: String, subtitle: String) {
    AuthAnimatedElement(delayIndex = 1) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            modifier = Modifier.fillMaxWidth()
        ) {
            Text(
                text = title,
                fontSize = 28.sp,
                fontWeight = FontWeight.ExtraBold,
                letterSpacing = (-0.5).sp,
                color = MaterialTheme.colorScheme.onBackground
            )
            Spacer(modifier = Modifier.height(8.dp))
            Text(
                text = subtitle,
                fontSize = 16.sp,
                fontWeight = FontWeight.Normal,
                color = if (isSystemInDarkTheme()) Color.White.copy(alpha = 0.6f) else Color(0xFF666666)
            )
        }
    }
}

@Composable
fun AuthInput(
    value: String,
    onValueChange: (String) -> Unit,
    label: String,
    isPassword: Boolean = false,
    errorText: String? = null,
    helperText: String? = null
) {
    AuthAnimatedElement(delayIndex = 2) {
        Column(modifier = Modifier.fillMaxWidth()) {
            Text(
                text = label,
                fontSize = 14.sp,
                fontWeight = FontWeight.Medium,
                letterSpacing = 0.5.sp,
                modifier = Modifier.padding(start = 20.dp, bottom = 8.dp),
                color = MaterialTheme.colorScheme.onBackground
            )
            
            var passwordVisible by remember { mutableStateOf(false) }
            val isDark = isSystemInDarkTheme()
            val bgColor = if (isDark) Color(0xFF1E1E1E) else Color.White
            val elevation = if (isDark) 0.dp else 4.dp
            
            TextField(
                value = value,
                onValueChange = onValueChange,
                modifier = Modifier
                    .fillMaxWidth()
                    .shadow(elevation, RoundedCornerShape(50.dp))
                    .clip(RoundedCornerShape(50.dp)),
                colors = TextFieldDefaults.colors(
                    focusedContainerColor = bgColor,
                    unfocusedContainerColor = bgColor,
                    focusedIndicatorColor = Color.Transparent,
                    unfocusedIndicatorColor = Color.Transparent,
                    cursorColor = MaterialTheme.colorScheme.primary
                ),
                visualTransformation = if (isPassword && !passwordVisible) PasswordVisualTransformation() else VisualTransformation.None,
                trailingIcon = if (isPassword) {
                    {
                        IconButton(onClick = { passwordVisible = !passwordVisible }) {
                            Icon(
                                imageVector = if (passwordVisible) MaterialSymbols.Rounded.Visibility else MaterialSymbols.Rounded.VisibilityOff,
                                contentDescription = null,
                                tint = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)
                            )
                        }
                    }
                } else null,
                singleLine = true
            )
            
            if (errorText != null) {
                Text(
                    text = errorText,
                    color = MaterialTheme.colorScheme.error,
                    fontSize = 12.sp,
                    modifier = Modifier.padding(start = 20.dp, top = 4.dp)
                )
            } else if (helperText != null) {
                Text(
                    text = helperText,
                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f),
                    fontSize = 12.sp,
                    modifier = Modifier.padding(start = 20.dp, top = 4.dp)
                )
            }
        }
    }
}

@Composable
fun AuthButton(
    text: String,
    onClick: () -> Unit,
    loading: Boolean = false,
    disabled: Boolean = false
) {
    AuthAnimatedElement(delayIndex = 3) {
        val isDark = isSystemInDarkTheme()
        val bgColor = if (isDark) Color.White else Color.Black
        val contentColor = if (isDark) Color.Black else Color.White
        
        Button(
            onClick = onClick,
            enabled = !loading && !disabled,
            modifier = Modifier
                .fillMaxWidth()
                .height(54.dp),
            shape = RoundedCornerShape(50.dp),
            colors = ButtonDefaults.buttonColors(
                containerColor = bgColor,
                contentColor = contentColor,
                disabledContainerColor = bgColor.copy(alpha = 0.6f),
                disabledContentColor = contentColor.copy(alpha = 0.6f)
            )
        ) {
            if (loading) {
                CircularProgressIndicator(
                    modifier = Modifier.size(24.dp),
                    color = contentColor,
                    strokeWidth = 2.dp
                )
            } else {
                Text(
                    text = text,
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Bold
                )
            }
        }
    }
}

@Composable
fun AuthBackButton(onClick: () -> Unit) {
    Box(
        modifier = Modifier
            .padding(bottom = 24.dp)
            .size(48.dp)
            .background(MaterialTheme.colorScheme.onSurface.copy(alpha = 0.08f), CircleShape)
            .clickable(onClick = onClick),
        contentAlignment = Alignment.Center
    ) {
        Icon(
            imageVector = MaterialSymbols.Rounded.ArrowBack,
            contentDescription = null,
            tint = MaterialTheme.colorScheme.onSurface
        )
    }
}

@Composable
fun LanguageTile(
    name: String,
    isSelected: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Box(
        modifier = modifier
            .fillMaxWidth()
            .height(56.dp)
            .clip(RoundedCornerShape(16.dp))
            .background(
                if (isSelected) MaterialTheme.colorScheme.primaryContainer 
                else MaterialTheme.colorScheme.surfaceVariant
            )
            .clickable { onClick() }
            .padding(horizontal = 20.dp),
        contentAlignment = Alignment.CenterStart
    ) {
        Text(
            text = name,
            style = MaterialTheme.typography.titleMedium,
            fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Medium,
            color = if (isSelected) MaterialTheme.colorScheme.onPrimaryContainer 
                    else MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

