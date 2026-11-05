import 'package:flutter_test/flutter_test.dart';
import 'package:cikoko/profile_status.dart';

void main() {
  test('RT/RW require valid two-digit areas with no 00 or 100', () {
    for (final item in ['01', '1', '05', '99']) {
      expect(cikokoValidRtRw(item), isTrue);
    }
    for (final item in ['', '00', '0', '100', '1a', null]) {
      expect(cikokoValidRtRw(item), isFalse);
    }
  });

  test('normalization allows comparing server and editor values', () {
    expect(cikokoNormalizeRtRw('2'), '02');
    expect(cikokoNormalizeRtRw('02'), '02');
  });

  test('profile completion updates immediately after RT/RW persistence', () {
    final stored = <String, dynamic>{
      'name': 'Budi', 'phone': '081234567890',
      'email': 'budi@example.test', 'address': 'Cikoko',
      'nik': '1234567890123456',
    };
    expect(cikokoProfileIsComplete(stored, isResident: true), isFalse);
    stored['rt'] = '02';
    stored['rw'] = '05';
    expect(cikokoProfileIsComplete(stored, isResident: true), isTrue);
  });

  test('role staff does not require resident RT/RW', () {
    final staff = <String, dynamic>{
      'name': 'Petugas', 'phone': '081234567890',
      'email': 'petugas@example.test', 'address': 'Cikoko',
      'nik': '1234567890123456',
    };
    expect(cikokoProfileIsComplete(staff, isResident: false), isTrue);
  });
}
