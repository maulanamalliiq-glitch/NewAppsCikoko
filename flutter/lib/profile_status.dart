/// Validation shared by the edit form and the profile status card.
bool cikokoValidRtRw(Object? value) {
  final text = (value ?? '').toString().trim();
  if (!RegExp(r'^\d{1,2}$').hasMatch(text)) return false;
  final parsed = int.tryParse(text);
  return parsed != null && parsed >= 1 && parsed <= 99;
}

String cikokoNormalizeRtRw(Object? value) {
  if (!cikokoValidRtRw(value)) return '';
  return int.parse(value.toString().trim()).toString().padLeft(2, '0');
}

bool cikokoProfileIsComplete(
  Map<String, dynamic> user, {
  required bool isResident,
}) {
  for (final field in ['name', 'phone', 'email', 'address', 'nik']) {
    if ((user[field] ?? '').toString().trim().isEmpty) return false;
  }
  return !isResident ||
      (cikokoValidRtRw(user['rt']) && cikokoValidRtRw(user['rw']));
}

 
/// Display only. Full identity remains accessible to the owner's protected
/// edit flow and is never altered in requests sent to the server.
String cikokoMaskedNik(Object? value) {
  final raw = (value ?? '').toString().trim();
  if (raw.isEmpty) return 'Belum diisi';
  final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.length < 8) return '••••';
  return '${digits.substring(0, 4)}••••••••${digits.substring(digits.length - 4)}';
}
