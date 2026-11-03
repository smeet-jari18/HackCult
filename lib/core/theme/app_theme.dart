import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens from DESIGN.md / uiux.md (LiFE Mitra Gujarat).
class AppColors {
  AppColors._();

  static const primary = Color(0xFF1B5E20); // Deep Banyan Green
  static const primaryDark = Color(0xFF0F3D14);
  static const primaryLight = Color(0xFF2E9E4F); // Secondary Emerald
  static const primaryContainer = Color(0xFFACF4A4);
  static const primarySoft = Color(0xFFE8F5E9);
  static const secondary = Color(0xFFF5A623); // Sun Amber
  static const secondaryLight = Color(0xFFFFD54F);
  static const secondarySoft = Color(0xFFFEF3E2);
  static const tertiary = Color(0xFF2196F3); // Water Blue
  static const tertiarySoft = Color(0xFFE3F2FD);
  static const background = Color(0xFFF7FAF7); // DESIGN-3 canvas
  static const splashBackground = Color(0xFFF1FDEF);
  static const tint = Color(0xFFEDF3ED); // tinted fills / filter chips
  static const tintStrong = Color(0xFFE2ECE2);
  static const surfaceLow = Color(0xFFEBF7E9);
  static const surface = Color(0xFFFFFFFF);
  static const border = Color(0xFFE3EBE3); // hairline (≈ primary @ 6%)
  static const outline = Color(0xFF9DA89F);
  static const textPrimary = Color(0xFF162018);
  static const textSecondary = Color(0xFF55645A);
  static const textTertiary = Color(0xFF8A968E);
  static const success = Color(0xFF2E9E4F);
  static const warning = Color(0xFFD98200);
  static const warningSoft = Color(0xFFFEF3E2);
  static const error = Color(0xFFBA1A1A);
  static const errorSoft = Color(0xFFFFEBEE);
  static const noticeSoft = Color(0xFFEEF2FF);

  // Institutional flat utility: "gradients" are solid fills.
  static const heroGreen = LinearGradient(
    colors: [Color(0xFF1B5E20), Color(0xFF1B5E20)],
  );
  static const solarAmber = LinearGradient(
    colors: [Color(0xFFF9A825), Color(0xFFF9A825)],
  );

  /// Mission LiFE theme colours.
  static const themeEnergy = Color(0xFFF9A825);
  static const themeWater = Color(0xFF1565C0);
  static const themePlastic = Color(0xFF6A1B9A);
  static const themeFood = Color(0xFF8D6E63);
  static const themeWaste = Color(0xFF455A64);
  static const themeHealthy = Color(0xFF00897B);
  static const themeEwaste = Color(0xFF37474F);
}

class AppRadius {
  AppRadius._();
  static const card = 20.0;
  static const button = 999.0; // pill
  static const chip = 999.0; // pill
  static const input = 16.0;
  static const sheet = 28.0;
}

class AppSpacing {
  AppSpacing._();
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

class AppShadows {
  AppShadows._();
  /// Card: ultra-diffused double shadow (ambient green tint + detail).
  static const level1 = [
    BoxShadow(
        color: Color(0x0A1B5E20),
        blurRadius: 24,
        spreadRadius: -4,
        offset: Offset(0, 8)),
    BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 2)),
  ];
  /// Interactive / lifted.
  static const level2 = [
    BoxShadow(
        color: Color(0x141B5E20),
        blurRadius: 32,
        spreadRadius: -4,
        offset: Offset(0, 12)),
    BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 4)),
  ];
}

class AppTheme {
  AppTheme._();

  static TextTheme _textTheme() {
    final heading = GoogleFonts.plusJakartaSansTextTheme();
    final body = GoogleFonts.plusJakartaSansTextTheme();
    return TextTheme(
      displayLarge: heading.displayLarge?.copyWith(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          height: 1.2,
          letterSpacing: -0.5,
          color: AppColors.textPrimary),
      displayMedium: heading.displayMedium?.copyWith(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          height: 1.2,
          letterSpacing: -0.3,
          color: AppColors.textPrimary),
      displaySmall: heading.displaySmall?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 1.25,
          color: AppColors.textPrimary),
      headlineMedium: heading.headlineMedium?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          height: 1.3,
          color: AppColors.textPrimary),
      headlineSmall: heading.headlineSmall?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
          height: 1.33,
          color: AppColors.textPrimary),
      titleLarge: heading.titleLarge?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 1.33,
          color: AppColors.textPrimary),
      titleMedium: heading.titleMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.4,
          color: AppColors.textPrimary),
      titleSmall: heading.titleSmall?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.4,
          color: AppColors.textPrimary),
      bodyLarge: body.bodyLarge
          ?.copyWith(fontSize: 16, height: 1.5, color: AppColors.textPrimary),
      bodyMedium: body.bodyMedium
          ?.copyWith(fontSize: 15, height: 1.5, color: AppColors.textPrimary),
      bodySmall: body.bodySmall?.copyWith(
          fontSize: 13, height: 1.4, color: AppColors.textSecondary),
      labelLarge: body.labelLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary),
      labelMedium: body.labelMedium?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
          color: AppColors.textSecondary),
      labelSmall: body.labelSmall?.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: AppColors.textSecondary),
    );
  }

  static ThemeData light() {
    final textTheme = _textTheme();
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.primary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.textPrimary,
      secondaryContainer: AppColors.secondarySoft,
      onSecondaryContainer: Color(0xFF694300),
      tertiary: AppColors.tertiary,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.tertiarySoft,
      onTertiaryContainer: Color(0xFF003A75),
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: AppColors.errorSoft,
      onErrorContainer: Color(0xFF93000A),
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: Color(0xFFE4F1E7),
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.border,
      outlineVariant: Color(0xFFF0F2F4),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: Color(0xFF293040),
      onInverseSurface: Color(0xFFEDF0FF),
      inversePrimary: Color(0xFF91D78A),
      surfaceTint: AppColors.primary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,
      splashFactory: InkRipple.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(64, 52),
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          backgroundColor: AppColors.surface,
          minimumSize: const Size(64, 52),
          side: const BorderSide(color: Color(0x261B5E20)),
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: textTheme.labelLarge,
          shape: const StadiumBorder(),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        isDense: true,
        hintStyle:
            textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary),
        labelStyle:
            textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: Color(0x1F1B5E20), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary,
        secondarySelectedColor: AppColors.primary,
        side: const BorderSide(color: AppColors.border),
        labelStyle:
            textTheme.labelMedium?.copyWith(color: AppColors.textPrimary),
        secondaryLabelStyle:
            textTheme.labelMedium?.copyWith(color: Colors.white),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        showCheckmark: false,
        checkmarkColor: Colors.white,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        height: 68,
        elevation: 0,
        indicatorColor: AppColors.primary,
        indicatorShape: const StadiumBorder(),
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelSmall?.copyWith(
            color: selected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
              color: selected ? Colors.white : AppColors.textSecondary,
              size: 24);
        }),
      ),
      dividerTheme: const DividerThemeData(
          color: AppColors.border, thickness: 1, space: 1),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
        ),
        showDragHandle: true,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.card)),
        titleTextStyle: textTheme.headlineSmall,
        contentTextStyle: textTheme.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? Colors.white
                : AppColors.textSecondary),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? AppColors.primaryLight
                : const Color(0xFFDDE5DD)),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: const CircleBorder(),
        side: const BorderSide(color: AppColors.outline, width: 1.5),
        fillColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? AppColors.primaryLight
                : Colors.transparent),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.border,
        thumbColor: AppColors.primary,
        overlayColor: Color(0x221B5E20),
        trackHeight: 4,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.all(Radius.circular(999)),
        linearTrackColor: AppColors.tintStrong,
        circularTrackColor: AppColors.border,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        labelStyle: textTheme.labelLarge,
        unselectedLabelStyle:
            textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
        dividerColor: AppColors.border,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.textSecondary,
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}
