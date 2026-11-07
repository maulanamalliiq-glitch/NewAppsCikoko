import 'package:flutter/material.dart';
import 'premium_ui.dart';
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
            .where((account) =>
                !widget.bendaharaOnly ||
                account['role'] == 'bendahara_rt' ||
                account['role'] == 'bendahara_rw')
            .toList();
        if (!roles.containsKey(selectedRole)) {
          selectedRole = roles.containsKey('bendahara_rt')
              ? 'bendahara_rt'
              : (roles.isEmpty ? null : roles.keys.first);
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
          FilledButton(onPressed: load, child: const Text('Coba Lagi')),
        ]),
      ));
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(14,12,14,26),
      children: [
        CikokoPremiumHeader(
          title:widget.bendaharaOnly?'Manajemen Bendahara RT/RW':'Kelola Akun Petugas',
          subtitle:widget.bendaharaOnly
            ?'Kelola akun bendahara sesuai wilayah secara aman.'
            :'Tambah, cari, dan kelola akun petugas serta pegawai.',
          icon:Icons.manage_accounts_outlined,
          start:const Color(0xFF143D85),end:const Color(0xFF407FE0)),
        const SizedBox(height:14),
        if (widget.bendaharaOnly && roles.isEmpty)
          Card(child:Padding(
            padding:const EdgeInsets.all(14),
            child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
              Row(children:[
                Icon(Icons.warning_amber_rounded,color:Theme.of(context).colorScheme.error),
                const SizedBox(width:8),
                const Expanded(child:Text('Peran Bendahara belum aktif di server',
                  style:TextStyle(fontWeight:FontWeight.bold))),
              ]),
              const SizedBox(height:8),
              const Text('Server belum mengirim peran Bendahara RT/RW. '
                'Sinkronkan API cPanel dan daftar peran resmi, kemudian muat ulang. '
                'Pembuatan akun dinonaktifkan agar tidak membuat akun dengan peran yang salah.'),
              const SizedBox(height:8),
              OutlinedButton.icon(onPressed:load,icon:const Icon(Icons.refresh),
                label:const Text('Periksa ulang peran')),
            ]),
          )),

        const SizedBox(height: 12),
        Card(child: Column(children: [
          ListTile(
            title: const Text('Tambah Akun'),
            subtitle: Text(widget.bendaharaOnly
                ? 'Buat akun Bendahara RT atau Bendahara RW'
                : 'Petugas baru, termasuk Bendahara RT dan RW'),
            trailing: Icon(showForm ? Icons.expand_less : Icons.expand_more),
            onTap: () => setState(() => showForm = !showForm),
          ),
          if (showForm && roles.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
              child: Form(key: formKey, child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  field(name, 'Nama lengkap'),
                  field(username, 'Username', hint: 'Minimal 4 karakter'),
                  field(password, 'Password awal',
                      secret: true, hint: 'Minimal 8 karakter'),
                  DropdownButtonFormField<String>(
                    initialValue: selectedRole,
                    isExpanded: true,
                    decoration: decoration('Peran akun'),
                    items: roles.entries
                        .map((e) => DropdownMenuItem(
                              value: e.key,
                              child: Text(e.value, overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: busy ? null : (v) => setState(() => selectedRole = v),
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
                  const SizedBox(height: 4),
                  FilledButton.icon(
                    onPressed: busy ? null : create,
                    icon: busy
                        ? const SizedBox(height: 16, width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.person_add_alt_1),
                    label: Text(busy
                        ? 'Menyimpan...'
                        : (widget.bendaharaOnly
                            ? 'Buat Akun Bendahara'
                            : 'Buat Akun Petugas')),
                  ),
                ],
              )),
            ),
        ])),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: Text(
              widget.bendaharaOnly
                  ? 'Daftar Bendahara RT/RW'
                  : 'Daftar Akun Terdaftar',
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold))),
          IconButton(tooltip: 'Muat ulang', onPressed: load,
              icon: const Icon(Icons.refresh)),
        ]),
        const SizedBox(height: 8),
        TextField(
          key: const Key('admin_account_search'),
          decoration: const InputDecoration(
            labelText: 'Cari akun petugas',
            hintText: 'Nama atau username',
            prefixIcon: Icon(Icons.search_rounded),
          ),
          onChanged: (value) => setState(() => accountQuery = value.trim().toLowerCase()),
        ),
        const SizedBox(height: 10),
        if (!widget.bendaharaOnly)
          DropdownButtonFormField<String>(
            key: const Key('admin_account_role_filter'),
            initialValue: accountRoleFilter,
            isExpanded: true,
            decoration: decoration('Filter berdasarkan peran'),
            items: [
              const DropdownMenuItem(value: 'all', child: Text('Semua peran')),
              ...roles.entries.map((e) => DropdownMenuItem(
                value: e.key,
                child: Text(e.value, overflow: TextOverflow.ellipsis),
              )),
            ],
            onChanged: (value) => setState(() => accountRoleFilter = value ?? 'all'),
          ),
        const SizedBox(height: 12),
        const Text('Pilih akun untuk melihat informasi. Perubahan data akun '
            'hanya tersedia jika didukung API dan hak akses server.',
            style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
        const SizedBox(height: 8),
        if (accounts.isNotEmpty && !accounts.any((item) {
          final matchesText = accountQuery.isEmpty ||
              (item['name'] ?? '').toString().toLowerCase().contains(accountQuery) ||
              (item['username'] ?? '').toString().toLowerCase().contains(accountQuery);
          return matchesText && (widget.bendaharaOnly ||
              accountRoleFilter == 'all' || item['role'] == accountRoleFilter);
        }))
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Text('Tidak ada akun yang sesuai pencarian atau filter.'),
          ),
        if (accounts.isEmpty)
          Text(widget.bendaharaOnly
              ? 'Belum ada akun Bendahara RT/RW yang terdaftar.'
              : 'Belum ada akun petugas.'),
        for (final account in accounts.where((item) {
          final matchesText = accountQuery.isEmpty ||
              (item['name'] ?? '').toString().toLowerCase().contains(accountQuery) ||
              (item['username'] ?? '').toString().toLowerCase().contains(accountQuery);
          final matchesRole = widget.bendaharaOnly ||
              accountRoleFilter == 'all' || item['role'] == accountRoleFilter;
          return matchesText && matchesRole;
        }))
          Card(child: ListTile(
            dense: true,
            leading: Icon(account['active'] == true
                ? Icons.verified_user_outlined
                : Icons.person_off_outlined),
            title: Text(account['name']?.toString() ?? ''),
            subtitle: Text(
              '${account['username'] ?? ''} • '
              '${roles[account['role']] ?? account['role']}'
              '${(account['rt'] ?? '').toString().isNotEmpty ? ' • RT ${account['rt']}' : ''}'
              '${(account['rw'] ?? '').toString().isNotEmpty ? ' / RW ${account['rw']}' : ''}',
            ),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(account['active'] == true ? 'Aktif' : 'Nonaktif',
                  style: const TextStyle(fontSize: 11)),
              IconButton(
                tooltip: 'Hapus permanen akun',
                onPressed: busy ? null : () => deleteAccount(account),
                icon: const Icon(Icons.delete_outline_rounded,
                  color: Color(0xFFC13B49), size: 21)),
            ]),
          )),
        const CikokoPageSignature(),
      ],
    );
  }
}
