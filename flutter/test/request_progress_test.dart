import 'package:cikoko/api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() {
    final id = CikokoRequestProgress.begin();
    CikokoRequestProgress.finish(id, success: false);
  });

  test('Permintaan baru dimulai tanpa persentase kirim palsu', () {
    final id = CikokoRequestProgress.begin();
    expect(CikokoRequestProgress.value.value, 0);
    CikokoRequestProgress.finish(id, success: false);
    expect(CikokoRequestProgress.value.value, isNull);
  });

  test('Progress pengiriman dibatasi sampai server mengonfirmasi', () {
    final id = CikokoRequestProgress.begin();
    CikokoRequestProgress.update(id, .42);
    expect(CikokoRequestProgress.value.value, .42);
    CikokoRequestProgress.update(id, 1);
    expect(CikokoRequestProgress.value.value, .95);
    CikokoRequestProgress.finish(id, success: true);
    expect(CikokoRequestProgress.value.value, 1);
  });

  test('Kegagalan penyimpanan tidak ditampilkan sebagai sukses', () {
    final id = CikokoRequestProgress.begin();
    CikokoRequestProgress.update(id, .9);
    CikokoRequestProgress.finish(id, success: false);
    expect(CikokoRequestProgress.value.value, isNull);
  });

  test('Respons lama tidak boleh menimpa progres permintaan terbaru', () {
    final oldId = CikokoRequestProgress.begin();
    final currentId = CikokoRequestProgress.begin();
    CikokoRequestProgress.update(oldId, .8);
    expect(CikokoRequestProgress.value.value, 0);
    CikokoRequestProgress.finish(oldId, success: true);
    expect(CikokoRequestProgress.value.value, 0);
    CikokoRequestProgress.finish(currentId, success: false);
  });
}
