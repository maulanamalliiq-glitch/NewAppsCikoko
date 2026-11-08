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

  final response = await api.callWithParams('document_detail', {
    if (resolvedId > 0) 'id': '$resolvedId',
    'kind': kind,
    if (kind == 'waris' && exactReference.isNotEmpty)
      'reference': exactReference,
  });
  return cikokoValidateDocumentPayload(response);
}

/// Validate the API shape before building widgets. HTTP 200 is not enough:
/// an outdated backend can return a partial JSON object that would otherwise
/// throw a TypeError inside the bottom-sheet FutureBuilder.
Map<String,dynamic> cikokoValidateDocumentPayload(
  Map<String,dynamic> response,
) {
  final detail = response['detail'];
  if(detail is! Map || detail.isEmpty) {
    throw ApiError('Respons detail pengajuan belum lengkap.',
      statusCode:502);
  }
  for(final key in const ['timeline','documents','corrections']) {
    final value=response[key];
    if(value != null && (value is! List ||
        value.any((entry)=>entry is! Map))) {
      throw ApiError('Format data $key tidak sesuai.',
        statusCode:502);
    }
  }
  final labels=response['labels'];
  if(labels != null && labels is! Map) {
    throw ApiError('Format label detail pengajuan tidak sesuai.',
      statusCode:502);
  }
  final children=detail['children'];
  if(children != null && (children is! List ||
      children.any((entry)=>entry is! Map))) {
    throw ApiError('Format data keluarga belum sesuai.',
      statusCode:502);
  }
  return response;
}

/// A readable, non-sensitive explanation for the actual HTTP failure.
/// Never show raw SQL, HTML, server paths or another user's data.
String cikokoDocumentFailure(Object? error) {
  if (error is ApiError) {
    return switch (error.statusCode) {
      400 || 422 => 'Identitas pengajuan tidak valid. Muat ulang daftar pengajuan.',
      401 => 'Sesi masuk kedaluwarsa. Silakan masuk kembali.',
      403 => 'Akun ini tidak memiliki izin untuk membaca detail pengajuan.',
      404 => 'Pengajuan tidak ditemukan. Silakan periksa nomor pengajuan.',
      500 || 502 || 503 || 504 =>
        'Rincian pengajuan belum dapat dimuat. Silakan coba kembali beberapa saat lagi.',
      429 => 'Permintaan sedang dibatasi. Silakan coba kembali beberapa saat lagi.',
      final int _ =>
        'Rincian pengajuan belum dapat dimuat. Silakan coba kembali atau hubungi petugas.',
      null => cikokoFormalMessage(error),
    };
  }
  return cikokoFormalMessage(error);
}
