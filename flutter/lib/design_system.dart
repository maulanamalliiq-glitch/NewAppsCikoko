import 'package:flutter/material.dart';
import 'premium_ui.dart';

/// Shared premium minimalist design system for every Material page.
/// This layer changes appearance only; routes, APIs and permissions remain intact.
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

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: royal,
      brightness: Brightness.light,
      primary: royal,
      secondary: gold,
      surface: Colors.white,
      onSurface: ink,
    );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: const BorderSide(color: outline, width: .7),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      primaryColor: royal,
      scaffoldBackgroundColor: canvas,
      splashFactory: InkRipple.splashFactory,
      visualDensity: VisualDensity.compact,
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
      }),
      appBarTheme: const AppBarTheme(
        backgroundColor: canvas,
        foregroundColor: navy,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 17, fontWeight: FontWeight.w600, color: navy,
          letterSpacing: -.35,
        ),
        iconTheme: IconThemeData(color: navy),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 5),
        shape: shape,
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        labelStyle: const TextStyle(fontSize: 12.5, color: muted),
        floatingLabelStyle: const TextStyle(fontSize: 12, color: royal),
        prefixIconColor: royal,
        suffixIconColor: royal,
        hintStyle: const TextStyle(color: muted, fontSize: 13.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: royal, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: royal,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 45),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: royal,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: .05),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: royal,
          minimumSize: const Size(0, 48),
          side: const BorderSide(color: outline),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: const Color(0xFFE6F0FF),
        side: const BorderSide(color: outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        labelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11.5, color: ink),
      ),
      listTileTheme: const ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
        iconColor: royal,
        textColor: ink,
        dense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 2),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: navy),
      ),
      dividerTheme: const DividerThemeData(color: outline, thickness: .8),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: royal),
      tabBarTheme: const TabBarThemeData(
        labelColor: royal,
        unselectedLabelColor: muted,
        indicatorColor: royal,
        dividerColor: outline,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: royal,
        unselectedItemColor: muted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: const Color(0xFFE6F0FF),
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
          fontSize: 11,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w600 : FontWeight.w400,
          color: states.contains(WidgetState.selected) ? royal : muted,
        )),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: royal, foregroundColor: Colors.white, elevation: 2,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: navy, letterSpacing: -.45),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: navy, letterSpacing: -.3),
        titleMedium: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600, color: navy),
        bodyLarge: TextStyle(fontSize: 14, color: ink, height: 1.4),
        bodyMedium: TextStyle(fontSize: 13, color: ink, height: 1.4),
        bodySmall: TextStyle(fontSize: 12, color: muted, height: 1.4),
      ),
    );
  }

  static ThemeData get dark {
    final scheme=ColorScheme.fromSeed(
      seedColor:royal,brightness:Brightness.dark,
      surface:const Color(0xFF152238),
    );
    return ThemeData(
      useMaterial3:true,
      brightness:Brightness.dark,
      colorScheme:scheme,
      scaffoldBackgroundColor:const Color(0xFF091425),
      appBarTheme:const AppBarTheme(
        backgroundColor:Color(0xFF111E31),
        foregroundColor:Colors.white,
        surfaceTintColor:Colors.transparent,
      ),
      cardTheme:CardThemeData(
        color:const Color(0xFF19283E),
        elevation:0,
        shape:RoundedRectangleBorder(
          borderRadius:BorderRadius.circular(radius),
          side:const BorderSide(color:Color(0xFF2C3D54))),
      ),
      navigationBarTheme:NavigationBarThemeData(
        backgroundColor:const Color(0xFF111E31),
        indicatorColor:const Color(0xFF284A76),
      ),
      inputDecorationTheme:InputDecorationTheme(
        filled:true,fillColor:const Color(0xFF1A2D44),
        border:OutlineInputBorder(borderRadius:BorderRadius.circular(14)),
      ),
    );
  }

}

class CikokoCopyrightFooter extends StatelessWidget {
 const CikokoCopyrightFooter({super.key});
 @override Widget build(BuildContext context) => Container(
  width: double.infinity,
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
  decoration: const BoxDecoration(
   color: Colors.white,
   border: Border(top: BorderSide(color: CikokoDesign.outline, width: .7)),
  ),
  child: const Text('Copyright © Cikoko Smart',
   textAlign: TextAlign.center,
   style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w400,
    letterSpacing: .2, color: CikokoDesign.muted)),
 );
}
