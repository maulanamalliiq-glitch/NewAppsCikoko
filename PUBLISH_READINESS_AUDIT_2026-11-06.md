# Cikoko SmartAPP — Hardcheck sebelum publikasi

Tanggal audit: 6 November 2026. Audit kode pada repository `NewAppsCikoko` dan backend `CikokoSmartAPPS`. Status **BELUM SIAP PUBLISH**.

## Pemeriksaan yang sudah dijalankan
- `flutter analyze` untuk semua berkas Dart, dan seluruh `flutter test` melalui GitHub Actions.
- Pemeriksaan lintas peran: jalur warga, admin, petugas, profil, pengajuan surat, progres dokumen, layanan terpadu, upload logo, pengelolaan akun, laporan.
- Pemeriksaan pemanggilan API Flutter terhadap action yang tersedia dalam berkas PHP backend.
- Pemeriksaan dark/light pada komponen yang dilaporkan pengguna.
- Pilihan EN/ID dihapus; aplikasi dipaksa Bahasa Indonesia, termasuk preferensi lama.

## Masalah yang masih memblokir rilis
1. **Backend surat RT/RW** belum memiliki action `rt_rw_list`, `rt_rw_submit`, `rt_rw_decide`, `rt_rw_reaffirm`, `rt_rw_officers`, `rt_rw_officer_assign`.
2. **Unggah tanda tangan/stempel petugas** memanggil `rt_rw_signer_status` dan `rt_rw_signer_upload`, belum ada di backend yang diperiksa.
3. **Alur LPJ/civic** memanggil `civic_catalog`, `civic_list`, `civic_submit`, `civic_detail`, `civic_pin_set`, `civic_review`, belum ada.
4. **Format surat waris** memanggil `waris_format`, belum ada pada backend yang diperiksa.
5. **Versi backend produksi** tidak dapat dikonfirmasi hanya dari repository. Kegagalan unggah logo atau detail pengajuan di HP dapat disebabkan file API pada cPanel tidak sinkron, konfigurasi PHP/upload, atau hak akses. `integrated_services_logo_upload` dan `document_detail` *ada di repository*, tetapi belum terbukti aktif pada hosting.
6. Pengujian otomatis tidak menjamin kontras seluruh halaman pada semua ukuran layar, koneksi lambat, semua hak akses, atau keberhasilan alur end-to-end. Perlu pengujian perangkat/staging.

## Perbaikan yang sudah dibuat dalam PR
- Tombol bahasa EN/ID dan pengaturan bahasa dihilangkan; semua teks yang memakai helper penerjemahan tetap Bahasa Indonesia.
- Warna teks app bar, profil, menu profil, katalog layanan, dan status surat publik mengikuti `Theme.of(context).colorScheme`.
- Error unggah logo dibedakan menurut timeout, koneksi, balasan API tidak valid, dan penolakan backend.
- Tambahan tes regresi dan workflow QA.

## Kriteria wajib sebelum APK boleh dipublikasikan
- Semua action di atas benar-benar tersedia di backend, lengkap dengan autentikasi, otorisasi RT/RW, isolasi data per akun, dan penyimpanan.
- Backend staging diuji dengan minimal dua akun warga, admin, Ketua RT, Ketua RW, dan petugas lain.
- Uji unggah logo JPG/PNG/WebP, status/detail surat, verifikasi RT ke RW, foto/TTD, dan pergantian akun pada satu perangkat.
- Semua tes Flutter lulus pada commit final; Android release ditandatangani dengan sertifikat produksi; instalasi dan pembaruan diuji.
- Backup database dan PHP sebelum deploy; lakukan rollback jika kontrak API atau izin gagal.
- Verifikasi privasi, kebijakan layanan, izin Android, dan persyaratan distribusi aplikasi sesuai kanal publikasi.

**Tidak ada jaminan nol kesalahan tanpa pengujian staging dan perangkat nyata.**
