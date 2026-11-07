import 'package:flutter/material.dart';
import 'premium_ui.dart';

/// The single, role-independent Cikoko SmartAPP visual language.
/// All pages inherit these tokens; no routes, API contracts or permissions.
abstract final class CikokoDesign {
  static const navy = CikokoPalette.navy;
  static const royal = CikokoPalette.blue;
  static const gold = CikokoPalette.gold;
  static const canvas = Color(0xFFF5F8FF);
  static const ink = Color(0xFF243650);
  static const muted = CikokoPalette.muted;
  static const outline = CikokoPalette.border;
  static const radius = 17.0;
  static const softBlue = CikokoPalette.sky;
  static const success = Color(0xFF148A55);
  static const warning = Color(0xFFE39B21);
  static const danger = Color(0xFFC43C4B);

  static const _darkCanvas = Color(0xFF091425);
  static const _darkSurface = Color(0xFF16243A);
  static const _darkField = Color(0xFF1B2D45);
  static const _darkBorder = Color(0xFF35475E);
  static const _darkInk = Color(0xFFF1F6FF);
  static const _darkMuted = Color(0xFFB5C6DE);

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final surface = dark ? _darkSurface : Colors.white;
    final canvasColor = dark ? _darkCanvas : canvas;
    final text = dark ? _darkInk : ink;
    final subtle = dark ? _darkMuted : const Color(0xFF53647D);
    final border = dark ? _darkBorder : outline;
    final primary = dark ? const Color(0xFF80BBFF) : royal;
    final action = dark ? const Color(0xFF246FD2) : royal;
    final actionInk = Colors.white;
    final field = dark ? _darkField : Colors.white;
    final softSelection = dark ? const Color(0xFF254769)
        : const Color(0xFFE6F0FF);

    final scheme = ColorScheme.fromSeed(
      seedColor: royal,
      brightness: brightness,
      primary: primary,
      secondary: gold,
      surface: surface,
      onSurface: text,
    ).copyWith(
      onSurfaceVariant: subtle,
      outline: border,
      outlineVariant: border,
      onPrimary: dark ? const Color(0xFF092241) : Colors.white,
    );

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: BorderSide(color: border, width: .7),
    );
    OutlineInputBorder inputBorder(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color, width: width),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      primaryColor: primary,
      scaffoldBackgroundColor: canvasColor,
      canvasColor: canvasColor,
      splashFactory: InkRipple.splashFactory,
      visualDensity: VisualDensity.compact,
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
      }),
      appBarTheme: AppBarTheme(
        backgroundColor: dark ? const Color(0xFF111E31) : canvas,
        foregroundColor: dark ? Colors.white : navy,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 17, fontWeight: FontWeight.w700,
          color: dark ? Colors.white : navy, letterSpacing: -.35,
        ),
        iconTheme: IconThemeData(color: dark ? Colors.white : navy),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(color: text, fontSize: 18,
          fontWeight: FontWeight.w800),
        contentTextStyle: TextStyle(color: text, fontSize: 13.5, height: 1.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: canvasColor,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(19))),
      ),
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 5),
        shape: shape,
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: field,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 13),
        labelStyle: TextStyle(fontSize: 12.5, color: subtle),
        floatingLabelStyle: TextStyle(fontSize: 12, color: primary),
        prefixIconColor: primary,
        suffixIconColor: primary,
        hintStyle: TextStyle(color: subtle, fontSize: 13.2),
        helperStyle: TextStyle(color: subtle, fontSize: 10.5),
        border: inputBorder(border),
        enabledBorder: inputBorder(border),
        focusedBorder: inputBorder(primary, 1.5),
        errorBorder: inputBorder(danger),
        focusedErrorBorder: inputBorder(danger, 1.5),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: action,
          foregroundColor: actionInk,
          minimumSize: const Size(0, 46),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: action,
          foregroundColor: actionInk,
          minimumSize: const Size(0, 48),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700, letterSpacing: .05),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(0, 46),
          side: BorderSide(color: border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: softSelection,
        disabledColor: canvasColor,
        side: BorderSide(color: border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
        labelStyle: TextStyle(fontWeight: FontWeight.w600,
          fontSize: 11.5, color: text),
        secondaryLabelStyle: TextStyle(fontWeight: FontWeight.w700,
          fontSize: 11.5, color: text),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14)),
        iconColor: primary,
        textColor: text,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15, vertical: 3),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: primary),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: .75),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: primary),
      tabBarTheme: TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: subtle,
        indicatorColor: primary,
        dividerColor: border,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: subtle,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: softSelection,
        elevation: 0,
        height: 70,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(color: states.contains(WidgetState.selected)
            ? primary : subtle, size: 22)),
        labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
          fontSize: 10.5,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w800 : FontWeight.w500,
          color: states.contains(WidgetState.selected) ? primary : subtle,
        )),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: action,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: dark ? const Color(0xFF294360) : navy,
        contentTextStyle: const TextStyle(
          color: Colors.white, fontSize: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14)),
      ),
      textTheme: TextTheme(
        headlineSmall: TextStyle(
          fontSize: 22, fontWeight: FontWeight.w800,
          color: text, letterSpacing: -.45),
        titleLarge: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w700,
          color: text, letterSpacing: -.3),
        titleMedium: TextStyle(
          fontSize: 15.5, fontWeight: FontWeight.w700, color: text),
        bodyLarge: TextStyle(fontSize: 14, color: text, height: 1.4),
        bodyMedium: TextStyle(fontSize: 13, color: text, height: 1.4),
        bodySmall: TextStyle(fontSize: 12, color: subtle, height: 1.4),
      ),
    );
  }
}

class CikokoCopyrightFooter extends StatelessWidget {
  const CikokoCopyrightFooter({super.key});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border(top: BorderSide(
        color: Theme.of(context).colorScheme.outlineVariant, width: .7)),
    ),
    child: Text('Copyright © Cikoko Smart',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w400,
        letterSpacing: .2,
        color: Theme.of(context).colorScheme.onSurfaceVariant)),
  );
}
