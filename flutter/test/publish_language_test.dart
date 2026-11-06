import 'package:flutter_test/flutter_test.dart';
import 'package:cikoko/app_settings.dart';

void main() {
  test('Indonesian is the only supported language until full localization', () {
    CikokoSettings.language.value = 'en'; // Legacy stored preference.
    expect(CikokoSettings.isEnglish, isFalse);
    expect(CikokoSettings.tr('Beranda', 'Home'), 'Beranda');
    expect(CikokoSettings.label('Pengaturan profil'), 'Pengaturan profil');
    CikokoSettings.language.value = 'id';
  });
}
