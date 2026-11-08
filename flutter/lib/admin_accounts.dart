import 'package:flutter/material.dart';
import 'premium_ui.dart';
import 'staff_account_ui.dart';
import 'api.dart';

/// Hanya Admin Utama yang mendapat menu ini. Server tetap melakukan
/// verifikasi role=admin sebelum membaca atau membuat akun.
class AdminAccountsPage extends StatefulWidget {
  final CikokoApi api;
  /// Tampilan khusus Bendahara memakai API dan autentikasi Admin Utama
  /// yang sudah ada. Tidak mengubah login atau aturan server.
  final bool bendaharaOnly;
  const AdminAccountsPage({
    super.key,
    required this.api,
    this.bendaharaOnly = false,
  });

  @override
  State<AdminAccountsPage> createState() => _AdminAccountsPageState();
}

class _AdminAccountsPageState extends State<AdminAccountsPage> {
  final name = TextEditingController();
  final username = TextEditingController();
  final password = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final rt = TextEditingController();
  final rw = TextEditingController();
  final formKey = GlobalKey<FormState>();

  Map<String, String> roles = {};
  List<Map<String, dynamic>> accounts = [];
  String? selectedRole;
  String? error;
  bool busy = false;
  bool loading = true;
  bool showForm = false;
  String accountQuery = '';
  String accountRoleFilter = 'all';

  bool get needsRt => selectedRole == 'rt' || selectedRole == 'bendahara_rt';
  bool get needsRw => needsRt ||
      selectedRole == 'rw' ||
      selectedRole == 'bendahara_rw' ||
      selectedRole == 'lmk';

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    for (final controller in [name, username, password, phone, email, rt, rw]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> load() async {
    try {
      final res = await widget.api.call('accounts_list');
      if (!mounted) return;
      final roleMap = Map<String, dynamic>.from(res['roles'] as Map? ?? {});
      setState(() {
        roles = roleMap.map((k, v) => MapEntry(k, v.toString()))
          ..remove('admin')
          ..remove('warga');
        if (widget.bendaharaOnly) {
          // Pilihan dibatasi untuk dua peran resmi yang benar-benar
          // dikembalikan server; jangan pernah membuat role lokal palsu.
          roles.removeWhere((key, _) =>
              key != 'bendahara_rt' && key != 'bendahara_rw');
        }
        accounts = (res['items'] as List? ?? [])
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            // The API may include citizen accounts, but this page manages
            // staff only. Keep resident accounts untouched and out of view.
            .where((account) => account['role'] != 'warga' &&
                account['role'] != 'admin')
            .where((account) =>
                !widget.bendaharaOnly ||
                account['role'] == 'bendahara_rt' ||
                account['role'] == 'bendahara_rw')
            .toList();
        if (!roles.containsKey(selectedRole)) {
          selectedRole = roles.isEmpty ? null : roles.keys.first;
        }
        loading = false;
        error = null;
      });
    } catch (e) {
      if (mounted) setState(() { loading = false; error = '$e'; });
    }
  }

  String? nonEmpty(String? value) =>
      (value ?? '').trim().isEmpty ? 'Wajib diisi' : null;

  Future<void> create() async {
    if (busy || selectedRole == null || !roles.containsKey(selectedRole)) return;
    if (widget.bendaharaOnly &&
        selectedRole != 'bendahara_rt' &&
        selectedRole != 'bendahara_rw') return;
    if (!formKey.currentState!.validate()) return;
    setState(() => busy = true);
    try {
      await widget.api.call('accounts_create', body: {
        'name': name.text.trim(),
        'username': username.text.trim(),
        'password': password.text,
        'role': selectedRole,
        'phone': phone.text.trim(),
        'email': email.text.trim(),
        'rt': needsRt ? rt.text.trim() : '',
        'rw': needsRw ? rw.text.trim() : '',
      });
      if (!mounted) return;
      name.clear();
      username.clear();
      password.clear();
      phone.clear();
      email.clear();
      rt.clear();
      rw.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Akun petugas berhasil dibuat.')));
      await load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat akun: $e')));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> deleteAccount(Map<String, dynamic> account) async {
    if (busy) return;
    final id = (account['id'] ?? '').toString();
    final username = (account['username'] ?? '').toString();
    if (id.isEmpty || username.isEmpty || account['role'] == 'admin' ||
        account['role'] == 'warga') return;
    final confirm = TextEditingController();
    try {
      final approved = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Hapus akun permanen?'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Akun $username akan dihapus permanen. Riwayat laporan tetap disimpan.'),
            const SizedBox(height: 12),
            TextField(controller: confirm,
              decoration: const InputDecoration(labelText: 'Ketik username akun')),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal')),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: confirm,
              builder: (_, value, __) => FilledButton(
                onPressed: value.text.trim() == username
                    ? () => Navigator.pop(dialogContext, true) : null,
                style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
                child: const Text('Hapus Permanen')),
            ),
          ],
        ),
      );
      if (approved != true || !mounted) return;
      setState(() => busy = true);
      try {
        await widget.api.call('accounts_delete',
          body: {'id': id, 'confirm_username': username});
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Akun berhasil dihapus permanen.')));
        await load();
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus akun: $e')));
      } finally {
        if (mounted) setState(() => busy = false);
      }
    } finally {
      confirm.dispose();
    }
  }

  InputDecoration decoration(String label, {String? hint}) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        isDense: true,
      );

  Widget field(TextEditingController controller, String label,
      {String? hint, bool required = true, bool secret = false,
      TextInputType? keyboard}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        obscureText: secret,
        keyboardType: keyboard,
        decoration: decoration(label, hint: hint),
        validator: required ? nonEmpty : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (error != null) {
      return Center(child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Gagal membuka Kelola Akun: $error', textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: load,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Coba Lagi'),
          ),
        ]),
      ));
    }

    final scheme = Theme.of(context).colorScheme;
    final visibleAccounts = accounts.where((account) =>
      cikokoAccountMatches(account, accountQuery, accountRoleFilter)).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 28),
      children: [
        const CikokoPremiumHeader(
          title: 'Kelola Akun Petugas',
          subtitle: 'Kelola Ketua RT/RW, Bendahara dan petugas dalam satu tempat.',
          icon: Icons.manage_accounts_outlined,
          start: Color(0xFF07346E),
          end: Color(0xFF267FDF),
        ),
        const SizedBox(height: 14),
        CikokoAccountSummary(accounts: accounts),
        const SizedBox(height: 14),
        Card(
          margin: EdgeInsets.zero,
          child: Column(children: [
            ListTile(
              key: const Key('add_staff_toggle'),
              leading: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.person_add_alt_1_rounded, color: scheme.primary),
              ),
              title: const Text('Tambah Akun Petugas',
                style: TextStyle(fontWeight: FontWeight.w800)),
              subtitle: const Text('Ketua RT/RW, Bendahara, ASN dan petugas lainnya'),
              trailing: Icon(showForm
                ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded),
              onTap: () => setState(() => showForm = !showForm),
            ),
            if (showForm && roles.isEmpty)
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text('Pilihan jabatan belum tersedia. '
                  'Silakan muat ulang sebelum membuat akun.'),
              ),
            if (showForm && roles.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 16),
                child: Form(key: formKey, child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    field(name, 'Nama lengkap'),
                    field(username, 'Nama Pengguna', hint: 'Minimal 4 karakter'),
                    field(password, 'Kata Sandi Awal',
                      secret: true, hint: 'Minimal 8 karakter'),
                    DropdownButtonFormField<String>(
                      key: ValueKey('new_account_role_$selectedRole'),
                      initialValue: selectedRole,
                      isExpanded: true,
                      decoration: decoration('Peran akun'),
                      items: roles.entries.map((entry) => DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value, overflow: TextOverflow.ellipsis),
                      )).toList(),
                      onChanged: busy ? null
                        : (value) => setState(() => selectedRole = value),
                    ),
                    const SizedBox(height: 12),
                    if (needsRt) field(rt, 'RT', hint: 'Contoh: 001',
                      keyboard: TextInputType.number),
                    if (needsRw) field(rw, 'RW', hint: 'Contoh: 001',
                      keyboard: TextInputType.number),
                    field(phone, 'Nomor telepon (opsional)', required: false,
                      keyboard: TextInputType.phone),
                    field(email, 'Email (opsional)', required: false,
                      keyboard: TextInputType.emailAddress),
                    FilledButton.icon(
                      onPressed: busy ? null : create,
                      icon: busy
                        ? const SizedBox(width: 17, height: 17,
                          child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.person_add_alt_1_rounded),
                      label: Text(busy ? 'Menyimpan...' : 'Buat Akun Petugas'),
                    ),
                  ],
                )),
              ),
          ]),
        ),
        const SizedBox(height: 19),
        Row(children: [
          Expanded(child: Text('Daftar Akun Terdaftar',
            style: TextStyle(color: scheme.onSurface,
              fontSize: 16, fontWeight: FontWeight.w800))),
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: load,
            icon: Icon(Icons.refresh_rounded, color: scheme.primary),
          ),
        ]),
        const SizedBox(height: 8),
        TextField(
          key: const Key('admin_account_search'),
          onChanged: (value) => setState(
            () => accountQuery = value.trim().toLowerCase()),
          decoration: const InputDecoration(
            hintText: 'Cari nama atau username...',
            prefixIcon: Icon(Icons.search_rounded),
          ),
        ),
        const SizedBox(height: 11),
        if (!widget.bendaharaOnly)
          Wrap(spacing: 8, runSpacing: 7, children: [
            ChoiceChip(
              key: const Key('filter_all'),
              label: const Text('Semua'),
              selected: accountRoleFilter == 'all',
              onSelected: (_) => setState(() => accountRoleFilter = 'all'),
            ),
            if (roles.containsKey('rt') || roles.containsKey('rw'))
              ChoiceChip(
                key: const Key('filter_ketua'),
                label: const Text('Ketua RT/RW'),
                selected: accountRoleFilter == 'ketua',
                onSelected: (_) => setState(() => accountRoleFilter = 'ketua'),
              ),
            if (roles.containsKey('bendahara_rt') || roles.containsKey('bendahara_rw'))
              ChoiceChip(
                key: const Key('filter_bendahara'),
                label: const Text('Bendahara'),
                selected: accountRoleFilter == 'bendahara',
                onSelected: (_) => setState(() => accountRoleFilter = 'bendahara'),
              ),
          ]),
        if (!widget.bendaharaOnly && roles.isNotEmpty) ...[
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            key: ValueKey('admin_account_role_filter_$accountRoleFilter'),
            initialValue: roles.containsKey(accountRoleFilter)
              ? accountRoleFilter : 'all',
            isExpanded: true,
            decoration: decoration('Pilih peran spesifik'),
            items: [
              const DropdownMenuItem(
                value: 'all', child: Text('Semua peran')),
              ...roles.entries.map((entry) => DropdownMenuItem(
                value: entry.key,
                child: Text(entry.value, overflow: TextOverflow.ellipsis),
              )),
            ],
            onChanged: (value) =>
              setState(() => accountRoleFilter = value ?? 'all'),
          ),
        ],
        const SizedBox(height: 13),
        Text(
          '${visibleAccounts.length} akun ditampilkan',
          style: TextStyle(color: scheme.onSurfaceVariant,
            fontSize: 11.5, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        if (visibleAccounts.isEmpty)
          Card(child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(children: [
              Icon(Icons.person_search_outlined, size: 34, color: scheme.primary),
              const SizedBox(height: 8),
              Text(accounts.isEmpty
                ? 'Belum ada akun petugas.'
                : 'Tidak ada akun sesuai pencarian atau filter.',
                textAlign: TextAlign.center,
                style: TextStyle(color: scheme.onSurfaceVariant)),
            ]),
          )),
        for (final account in visibleAccounts)
          CikokoOfficerAccountCard(
            account: account,
            roleLabel: roles[(account['role'] ?? '').toString()]
              ?? (account['role'] ?? '').toString(),
            onDelete: busy ? null : () => deleteAccount(account),
          ),
        const SizedBox(height: 12),
        Text(
          'Perubahan data akun dilakukan sesuai kewenangan pengelola.',
          style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 11),
        ),
        const SizedBox(height: 18),
        const CikokoPageSignature(),
      ],
    );
  }
}
