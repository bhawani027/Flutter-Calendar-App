import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  /// [base] rendered in a Devanagari-capable face, for Bikram Sambat text.
  ///
  /// The app's body font, ABeeZee, carries no Devanagari glyphs, so Nepali
  /// script would otherwise land on whatever each platform happens to fall back
  /// to — and on the ones with no Devanagari font at all, on empty boxes.
  /// Naming the face keeps the BS dates looking the same everywhere.
  static TextStyle nepali(TextStyle? base) =>
      GoogleFonts.notoSansDevanagari(textStyle: base);

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(seedColor: AppColors.seed);
    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      textTheme: GoogleFonts.aBeeZeeTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        centerTitle: true,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 20),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: const BeveledRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
        ),
      ),
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: Brightness.dark,
    );
    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      textTheme: GoogleFonts.aBeeZeeTextTheme(ThemeData.dark().textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surfaceContainerHigh,
        foregroundColor: colorScheme.onSurface,
        centerTitle: true,
      ),
    );
  }
}
