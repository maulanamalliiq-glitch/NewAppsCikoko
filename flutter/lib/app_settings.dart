import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Preferences shared by every role. The choice survives app restarts.
abstract final class CikokoSettings {
  static const _storage = FlutterSecureStorage();
  static final themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);
  static final language = ValueNotifier<String>('id');

  static bool get isEnglish => language.value == 'en';
  static String tr(String indonesia, String english) =>
      isEnglish ? english : indonesia;

  static Future<void> restore() async {
    try {
      themeMode.value = await _storage.read(key: 'cikoko_theme') == 'dark'
          ? ThemeMode.dark : ThemeMode.light;
      language.value = await _storage.read(key: 'cikoko_language') == 'en'
          ? 'en' : 'id';
    } catch (_) {
      // A locked credential store should never prevent starting the app.
    }
  }

  static Future<void> toggleTheme() async {
    themeMode.value = themeMode.value == ThemeMode.dark
        ? ThemeMode.light : ThemeMode.dark;
    try {
      await _storage.write(key: 'cikoko_theme',
        value: themeMode.value == ThemeMode.dark ? 'dark' : 'light');
    } catch (_) {}
  }

  static Future<void> toggleLanguage() async {
    language.value = isEnglish ? 'id' : 'en';
    try {
      await _storage.write(key: 'cikoko_language', value: language.value);
    } catch (_) {}
  }
}
