import 'api.dart';
import 'surat_identifier.dart';

/// Fetch a document through the existing authenticated API without inventing
/// an ID. Older list responses can have AW reference but omit the numeric ID.
Future<Map<String, dynamic>> cikokoReadDocumentDetail(
  CikokoApi api, {
  required int id,
  required String kind,
  String reference = '',
}) async {
  var resolvedId = id;
  final exactReference = reference.trim();

  if (kind == 'waris' && resolvedId <= 0 && exactReference.isNotEmpty) {
    final listing = api.profile?['role'] == 'warga'
        ? 'history' : 'admin_reports';
    try {
      final response = await api.call(listing);
      final items = response['items'] is List
          ? List<dynamic>.from(response['items'] as List)
          : const <dynamic>[];
      final matches = items.whereType<Map>().map((row) =>
          Map<String, dynamic>.from(row)).where((row) =>
            cikokoWarisReference(row) == exactReference
            && cikokoDocumentKind(row) == 'waris').toList();
      if (matches.length == 1) {
        resolvedId = cikokoPositiveId(matches.first) ?? 0;
      }
    } on ApiError {
      // Fall back to a strict reference lookup on a compatible backend.
      // No unsafe attempt to guess an ID from a title or list index.
    }
  }

  return api.callWithParams('document_detail', {
    if (resolvedId > 0) 'id': '$resolvedId',
    'kind': kind,
    if (kind == 'waris' && exactReference.isNotEmpty)
      'reference': exactReference,
  });
}

/// A readable, non-sensitive explanation for the actual HTTP failure.
/// Never show raw SQL, HTML, server paths or another user's data.
String cikokoDocumentFailure(Object? error) {
  if (error is ApiError) {
    return switch (error.statusCode) {
      400 || 422 => 'Identitas pengajuan tidak valid. Muat ulang daftar pengajuan.',
      401 => 'Sesi masuk kedaluwarsa. Silakan masuk kembali.',
      403 => 'Akun ini tidak memiliki izin untuk membaca detail pengajuan.',
      404 => 'Detail pengajuan tidak ditemukan pada server. Periksa nomor dokumen.',
      500 || 502 || 503 || 504 =>
        'Server detail pengajuan sedang bermasalah (HTTP ${error.statusCode}). '
        'Daftar pengajuan belum tentu ikut bermasalah.',
      final int status =>
        'Server tidak dapat membuka detail pengajuan (HTTP $status).',
      null => cikokoFormalMessage(error),
    };
  }
  return cikokoFormalMessage(error);
}
