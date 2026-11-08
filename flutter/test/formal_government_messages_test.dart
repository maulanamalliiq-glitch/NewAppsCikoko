import 'package:flutter_test/flutter_test.dart';
import '../lib/api.dart';
import '../lib/document_reading.dart';

void main() {
  test('Technical service failures have a public message without internal details', () {
    for (final technical in [
      'Database tidak tersedia',
      'Server cPanel perlu migrasi API',
      'Endpoint tidak tersedia',
      'HTTP 503',
      'SQLSTATE[42S22]: Unknown column applicant_nik',
      'FormatException: Unexpected character',
      '<html>Service unavailable</html>',
    ]) {
      final message = cikokoFormalMessage(technical);
      expect(message, contains('Silakan coba kembali'));
      expect(message, isNot(contains(technical)));
    }
  });

  test('Useful validation and permission messages remain specific', () {
    for (final message in [
      'NIK wajib 16 angka',
      'Konfirmasi kata sandi tidak sesuai.',
      'Akun ini tidak memiliki izin untuk membaca detail pengajuan.',
    ]) {
      expect(cikokoFormalMessage(message), message);
    }
  });

  test('Document status remains actionable without HTTP codes', () {
    for (final code in [400, 401, 403, 404, 429, 500, 502, 503, 504]) {
      final message = cikokoDocumentFailure(ApiError('SQLSTATE private', statusCode: code));
      expect(message, isNot(matches(RegExp('HTTP|SQLSTATE|server|database', caseSensitive: false))));
      expect(message, isNotEmpty);
    }
  });
}
