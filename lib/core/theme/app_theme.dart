import 'package:flutter/material.dart';
import 'package:clerk_flutter/clerk_flutter.dart';

abstract final class AppTheme {
  static const red = Color(0xffe60023);
  static ThemeData build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final surface = dark ? const Color(0xff171717) : Colors.white;
    final ink = dark ? Colors.white : const Color(0xff171717);
    final grey = dark ? const Color(0xff2c2c2c) : const Color(0xfff1f1f1);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: surface,
      colorScheme: ColorScheme.fromSeed(seedColor: red, brightness: brightness)
          .copyWith(
            primary: red,
            surface: surface,
            onSurface: ink,
            surfaceContainerHighest: grey,
          ),
      extensions: [
        ClerkThemeExtension(
          colors: ClerkThemeColors(
            background: surface,
            altBackground: grey,
            borderSide: dark
                ? const Color(0xff444444)
                : const Color(0xffdddddd),
            text: ink,
            icon: ink,
            lightweightText: dark
                ? const Color(0xffaaaaaa)
                : const Color(0xff666666),
            error: red,
            accent: red,
          ),
        ),
      ],
      fontFamily: 'SF Pro Text',
      textTheme: ThemeData(
        brightness: brightness,
      ).textTheme.apply(bodyColor: ink, displayColor: ink),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: ink,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: ink.withValues(alpha: .08),
        space: 1,
      ),
      splashFactory: InkSparkle.splashFactory,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: red,
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          minimumSize: const Size(48, 50),
          side: BorderSide(color: ink.withValues(alpha: .16)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: grey,
        contentPadding: const EdgeInsets.all(18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: ink, width: 2),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: dark ? Colors.white : ink,
        contentTextStyle: TextStyle(color: dark ? Colors.black : Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
