# Cikoko SmartAPP — Full Super Premium Total Overhaul

Tanggal perubahan: 7 November 2026  
Sumber desain: mockup Super Premium yang disetujui (biru-putih, gold accent, light/dark).

## Cakupan implementasi

| Area aplikasi | Perubahan | Hasil |
|---|---|---|
| Login dan registrasi | Login-only gate, tata letak premium, tidak ada beranda tamu | Diimplementasikan |
| Beranda Warga | Identitas, cuaca API, layanan cepat, pencarian ke Menu, berita | Diimplementasikan |
| Beranda Admin dan Petugas | Hero premium, ringkasan surat publik dari API, aksi sesuai role | Diimplementasikan |
| Navigasi utama dan drawer | Orb Menu di tengah, kartu dan pilihan menu seragam | Diimplementasikan |
| Menu fitur | Grid adaptif dan pencarian berbasis role yang ada | Diimplementasikan |
| Permohonan RT/RW | Input, verifikasi tahap konfirmasi, progres, PDF asli | Dipertahankan dan diseragamkan |
| Ahli Waris | 6 kelompok formulir, upload tiap dokumen, dua saksi, data anak | Diimplementasikan |
| Detail dan koreksi dokumen | Pratinjau setiap foto dan penggantian foto | Diimplementasikan |
| Laporan umum | Kelompok lokasi, kegiatan, foto, dan konfirmasi | Diimplementasikan |
| LPJ RT/RW/LMK | Ringkasan keuangan dinamis dan persetujuan PIN sesuai API | Dipertahankan dan diseragamkan |
| Riwayat | Kartu status API, tampilan kosong dan penanganan error | Diimplementasikan |
| Notifikasi | Hanya `audience=personal` dan `recipient` cocok | Dipertahankan |
| Chat Warga/Admin | Tampilan bubble serta daftar percakapan | Diimplementasikan |
| Direktori layanan | Pencarian, kartu, logo, admin aktif/nonaktif dan HTTPS | Diimplementasikan |
| Publikasi berita | Foto per slot, preview dan ganti foto, validasi konten | Diimplementasikan |
| Inovasi & PPSU | Komponen premium, galeri detail dan riwayat | Diimplementasikan |
| Profil & Kelola Akun | Kelompok informasi dan NIK disamarkan di ringkasan | Diimplementasikan |
| Hak Akses Petugas | Nama izin manusiawi; kunci API tidak diubah | Dipertahankan |
| Persyaratan Ahli Waris | Daftar bernomor premium mengganti tabel lama | Diimplementasikan |

## Keamanan dan integritas

- **Tidak mengganti endpoint API PHP**, skema DB, header bearer, atau token di secure storage.
- **Tidak membuat data statistik contoh**. Ringkasan publik memakai `public_letter_status`; nilai tidak tersedia ditampilkan `—`.
- **Tidak membuka data warga lintas akun**. Notifikasi dan push tetap diperiksa terhadap akun saat ini; otorisasi utama tetap ditegakkan server.
- **Tidak menyatakan 100% aman tanpa audit backend/pentest**. Tes otomatis memeriksa regresi tampilan, peran, dan penyaringan data.
- **Tidak menambahkan Jakarta ID/SSO, reset password, atau bahasa Inggris semu** karena API/terjemahan lengkap belum tersedia.
- **Tidak membuat APK untuk setiap commit**. Workflow pada branch ini hanya menjalankan Flutter analyzer + widget/unit tests. Setelah lulus, satu merge ke `main` memicu proses build Android yang sudah disediakan repository.

## Kriteria keluar

- [x] Refactor visual besar masuk satu feature branch
- [x] Login tamu lama tidak dapat muncul di bawah layar Login
- [x] Komponen kartu, formulir, laporan, dan pengelolaan berbagi desain
- [x] Kontrol foto dengan pratinjau dan ganti foto
- [x] Tes baru ditambahkan untuk privacy mask, role scope, dan komponen UI
- [x] Flutter analyzer lulus pada commit final
- [x] Semua widget/unit tests lulus
- [ ] PR masuk `main` setelah QA
- [ ] Satu putaran APK + AAB final berhasil
- [ ] Uji manual di HP untuk tiap role dan variasi layar

## Bukti QA

- Flutter analyzer, unit/widget suite dan pemeriksaan kontrak API: **LULUS**.
- GitHub Actions: https://github.com/maulanamalliiq-glitch/NewAppsCikoko/actions/runs/42393752061
- Satu tes struktural lama tentang penempatan saksi diperbarui agar menguji komponen judul UI baru; syarat urutan kedua KTP saksi tetap dipertahankan.
- Belum menguji UI langsung di HP atau melakukan penetration test backend; kedua hal tersebut tidak boleh diklaim selesai.
