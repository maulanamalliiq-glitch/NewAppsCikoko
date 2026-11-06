import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Preferences shared by every role. The choice survives app restarts.
abstract final class CikokoSettings {
  static const _storage = FlutterSecureStorage();
  static final themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);
  static final language = ValueNotifier<String>('id');

  static bool get isEnglish => false;
  static String tr(String indonesia, String english) =>
      isEnglish ? english : indonesia;

  /// Common navigation/service labels, without altering route identifiers.
  static const englishLabels=<String,String>{
    'Beranda':'Home',
    'Berita':'News',
    'Inovasi':'Innovation',
    'Profil':'Profile',
    'Notifikasi':'Notifications',
    'Layanan Online':'Online Services',
    'Layanan Masyarakat':'Community Services',
    'Menu Cepat':'Quick Access',
    'Lihat Semua':'View All',
    'Aktivitas Terbaru':'Recent Activity',
    'Layanan Cepat':'Quick Services',
    'Layanan':'Services',
    'Kirim Laporan':'Submit Report',
    'Info & Berita':'Info & News',
    'Agenda':'Agenda',
    'Cek Status':'Check Status',
    'Wilayah':'Area',
    'Bantuan':'Help',
    'Petugas & Wilayah':'Officers & Area',
    'Laporan Wilayah':'Area Reports',
    'Surat & Ahli Waris':'Letters & Inheritance',
    'Berita & Informasi':'News & Information',
    'Komunikasi':'Communication',
    'Layanan & Lainnya':'Services & More',
    'Hubungi Kami':'Contact Us',
    'Surat Pengantar RT/RW':'RT/RW Reference Letter',
    'Surat Ahli Waris':'Inheritance Letter',
    'Laporan Jumantik':'Mosquito Monitoring',
    'Berita & Kegiatan':'News & Activities',
    'Pengumuman':'Announcements',
    'Galeri':'Gallery',
    'Riwayat':'History',
    'Identitas Akun':'Account Identity',
    'Informasi Akun':'Account Information',
    'Pengaturan profil':'Profile Settings',
    'Ganti foto profil':'Change Profile Picture',
    'Tema tampilan':'Appearance',
    'Bahasa aplikasi':'App Language',
    'Informasi pribadi':'Personal Information',
    'Keluar':'Sign Out',
    'Login / Daftar Warga':'Login / Register',
    'Hak Akses Role':'Role Permissions',
    'Kelola Akun Petugas':'Manage Staff Accounts',
    'Manajemen Pengguna':'User Management',
    'Daftar Laporan':'Report List',
    'Manajemen Layanan':'Manage Services',
    'Layanan Administrasi':'Administrative Services',
    'Pusat Pengelolaan Cikoko':'Cikoko Management Center',
    'Penanganan Laporan':'Report Handling',
  };
  static String label(String source) =>
      isEnglish ? (englishLabels[source] ?? source) : source;

  static Future<void> restore() async {
    try {
      themeMode.value = await _storage.read(key: 'cikoko_theme') == 'dark'
          ? ThemeMode.dark : ThemeMode.light;
      language.value = 'id';
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
    language.value = 'id';
    try {
      await _storage.write(key: 'cikoko_language', value: language.value);
    } catch (_) {}
  }
}
