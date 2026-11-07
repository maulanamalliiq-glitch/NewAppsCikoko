import 'package:flutter/material.dart';

/// One display-only filter for the existing authenticated staff API results.
/// Never changes the staff's permissions or makes another account visible.
bool cikokoAccountMatches(
  Map<String, dynamic> account,
  String query,
  String roleFilter,
) {
  final text = query.trim().toLowerCase();
  final name = (account['name'] ?? '').toString().toLowerCase();
  final username = (account['username'] ?? '').toString().toLowerCase();
  final role = (account['role'] ?? '').toString();
  final matchesText = text.isEmpty ||
      name.contains(text) || username.contains(text);
  if (!matchesText) return false;
  switch (roleFilter) {
    case 'all':
      return true;
    case 'ketua':
      return role == 'rt' || role == 'rw';
    case 'bendahara':
      return role == 'bendahara_rt' || role == 'bendahara_rw';
    default:
      return role == roleFilter;
  }
}

class CikokoAccountSummary extends StatelessWidget {
  final List<Map<String, dynamic>> accounts;
  const CikokoAccountSummary({super.key, required this.accounts});

  @override
  Widget build(BuildContext context) {
    final active = accounts.where((a) => a['active'] == true).length;
    final treasurers = accounts.where((a) =>
      a['role'] == 'bendahara_rt' || a['role'] == 'bendahara_rw').length;
    final items = <({String label, int count, IconData icon, Color accent})>[
      (label: 'Total Akun', count: accounts.length,
        icon: Icons.groups_rounded, accent: const Color(0xFF156BCE)),
      (label: 'Aktif', count: active,
        icon: Icons.verified_rounded, accent: const Color(0xFF0B9D71)),
      (label: 'Bendahara', count: treasurers,
        icon: Icons.account_balance_wallet_outlined, accent: const Color(0xFFEB930F)),
    ];
    final scheme = Theme.of(context).colorScheme;
    return Row(children: [
      for (var i = 0; i < items.length; i++) ...[
        if (i > 0) const SizedBox(width: 8),
        Expanded(child: Container(
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 11),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Column(children: [
            Icon(items[i].icon, color: items[i].accent, size: 23),
            const SizedBox(height: 6),
            Text('${items[i].count}', style: TextStyle(
              fontSize: 19, fontWeight: FontWeight.w800, color: scheme.onSurface)),
            const SizedBox(height: 2),
            Text(items[i].label, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10,
                color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
          ]),
        )),
      ],
    ]);
  }
}

/// Mockup-style staff card, with a confirmation step handled by the parent.
class CikokoOfficerAccountCard extends StatelessWidget {
  final Map<String, dynamic> account;
  final String roleLabel;
  final VoidCallback? onDelete;
  const CikokoOfficerAccountCard({
    super.key,
    required this.account,
    required this.roleLabel,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final active = account['active'] == true;
    final name = (account['name'] ?? '').toString().trim();
    final words = name.split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty).take(2).toList();
    final initials = words.isEmpty ? 'P'
        : words.map((w) => w.substring(0, 1).toUpperCase()).join();
    final rt = (account['rt'] ?? '').toString().trim();
    final rw = (account['rw'] ?? '').toString().trim();
    final wilayah = [
      if (rt.isNotEmpty) 'RT $rt',
      if (rw.isNotEmpty) 'RW $rw',
    ].join(' / ');
    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 5, 12),
        child: Row(children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFDDEBFF),
            child: Text(initials, style: const TextStyle(
              color: Color(0xFF10519D), fontSize: 14,
              fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 11),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name.isEmpty ? 'Petugas' : name,
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(color: colors.onSurface,
                  fontSize: 13.3, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(roleLabel, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(color: colors.primary,
                  fontSize: 11, fontWeight: FontWeight.w700)),
              if (wilayah.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(wilayah, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.onSurfaceVariant, fontSize: 10.5)),
              ],
              const SizedBox(height: 3),
              Text((account['username'] ?? '').toString(),
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 10)),
            ],
          )),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
            decoration: BoxDecoration(
              color: active ? const Color(0xFFDAF5E6) : const Color(0xFFE8EDF4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(active ? 'Aktif' : 'Nonaktif',
              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800,
                color: active ? const Color(0xFF0B7751) : const Color(0xFF465366))),
          ),
          PopupMenuButton<String>(
            tooltip: 'Opsi akun',
            icon: Icon(Icons.more_vert_rounded, color: colors.onSurfaceVariant),
            enabled: onDelete != null,
            onSelected: (value) { if (value == 'delete') onDelete?.call(); },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'delete',
                child: Row(children: [
                  Icon(Icons.delete_outline_rounded, color: Color(0xFFC33A4A)),
                  SizedBox(width: 8),
                  Text('Hapus akun'),
                ])),
            ],
          ),
        ]),
      ),
    );
  }
}
