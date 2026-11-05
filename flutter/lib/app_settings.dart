import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Satu bahasa untuk semua pengguna hingga semua fitur siap diterjemahkan.
abstract final class CikokoSettings {
  static const _storage=FlutterSecureStorage();
  static final themeMode=ValueNotifier<ThemeMode>(ThemeMode.light);

  // Kompatibilitas dengan komponen yang sebelumnya memanggil lokalisasi.
  // Seluruh layar memakai bahasa Indonesia, tanpa toggle EN/ID.
  static String tr(String indonesia,String english)=>indonesia;
  static String label(String source)=>source;

  static Future<void> restore()async{
    try{
      themeMode.value=await _storage.read(key:'cikoko_theme')=='dark'
        ?ThemeMode.dark:ThemeMode.light;
      await _storage.delete(key:'cikoko_language');
    }catch(_){}
  }
  static Future<void> toggleTheme()async{
    themeMode.value=themeMode.value==ThemeMode.dark?ThemeMode.light:ThemeMode.dark;
    try{
      await _storage.write(key:'cikoko_theme',
        value:themeMode.value==ThemeMode.dark?'dark':'light');
    }catch(_){}
  }
}
