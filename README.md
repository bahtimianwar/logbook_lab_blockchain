# Logbook Lab Blockchain

Aplikasi Flutter untuk mencatat peminjaman alat Lab IoT. Data peminjaman disimpan di smart contract pada jaringan uji **Ethereum Sepolia**, bukan di server atau database lokal.

Proyek ini adalah tugas mata kuliah **Pemrograman Mobile 2**, D4 Teknologi Rekayasa Komputer, Jurusan Teknologi Informasi, Politeknik Negeri Samarinda.

## Identitas Kelompok

| Komponen | Isi |
|---|---|
| Nama kelompok | `<isi nama kelompok>` |
| Anggota 1 | `<nama, NIM>` |
| Anggota 2 | `<nama, NIM>` |
| Anggota 3 | `<nama, NIM>` |
| Dosen pengampu | `<isi nama dosen>` |
| Studi kasus | Logbook peminjaman alat Lab IoT |

## Informasi Smart Contract

| Item | Nilai |
|---|---|
| Jaringan | Ethereum Sepolia (testnet) |
| Chain ID | `11155111` |
| Alamat kontrak | `0xcB141FD4c7F45b59be19F6f454672aab7aF8D696` |
| Etherscan | https://sepolia.etherscan.io/address/0xcB141FD4c7F45b59be19F6f454672aab7aF8D696 |
| Status | Terverifikasi di Etherscan |
| Compiler | Solidity 0.8.34 (commit 80d5c536), optimization nonaktif, runs 200 |
| Lisensi | MIT |
| Kode sumber | [`contracts/LogbookLab.sol`](contracts/LogbookLab.sol) |
| ABI | [`assets/abi/logbook_lab.json`](assets/abi/logbook_lab.json) |

### Data yang dicatat on-chain

| Field | Tipe | Keterangan |
|---|---|---|
| `namaAlat` | `string` | Nama alat yang dipinjam |
| `kodePeminjam` | `bytes32` | Hash NIM (SHA-256 dengan salt), bukan NIM asli |
| `wallet` | `address` | Alamat wallet pengirim transaksi |
| `waktuPinjam` | `uint256` | Waktu blok saat dipinjam (detik, UTC) |
| `waktuKembali` | `uint256` | Waktu blok saat dikembalikan, `0` berarti belum dikembalikan |

### Fungsi kontrak

| Fungsi | Jenis | Keterangan |
|---|---|---|
| `pinjamAlat(namaAlat, kodePeminjam)` | Tulis | Mencatat peminjaman. Ditolak jika nama kosong atau alat yang sama sedang dipinjam |
| `kembalikanAlat(id)` | Tulis | Mencatat pengembalian. Hanya wallet peminjam yang bisa, dan hanya sekali |
| `jumlahData()` | Baca | Jumlah seluruh catatan |
| `ambilData(id)` | Baca | Detail satu catatan |

Fungsi baca tidak membutuhkan gas dan tanda tangan. Fungsi tulis membutuhkan gas (Sepolia ETH) dan ditandatangani private key pemilik akun.

### Pengujian kontrak (Remix VM)

Kontrak diuji di Remix VM sebelum di-deploy ke Sepolia dengan skenario berikut:

1. Pinjam alat berhasil.
2. `jumlahData` dan `ambilData` mengembalikan data yang benar.
3. Pinjam alat yang sama saat masih dipinjam ditolak ("Alat sedang dipinjam").
4. Pinjam dengan nama alat kosong ditolak.
5. Pengembalian oleh akun lain ditolak ("Bukan peminjam").
6. Pengembalian oleh peminjam berhasil.
7. Pengembalian kedua kali ditolak ("Sudah dikembalikan").
8. Pengembalian dengan id yang tidak ada ditolak ("Data tidak ada").
9. Pinjam ulang alat yang sudah dikembalikan berhasil.

## Fitur Aplikasi

**Fitur minimum**

- Daftar peminjaman dibaca langsung dari kontrak, status dibedakan lewat warna dan label (dipinjam dan kembali).
- Form pinjam alat yang mengirim transaksi `pinjamAlat`.
- Tombol kembalikan yang mengirim transaksi `kembalikanAlat`.
- Indikator status transaksi: memproses, berhasil dengan hash transaksi, dan gagal dengan pesan error.
- Tombol refresh dan tarik untuk memuat ulang.
- Alamat kontrak, RPC URL, dan chain ID disimpan di satu berkas konfigurasi (`.env`).
- NIM tidak disimpan mentah di blockchain, hanya hash.

**Fitur tambahan**

- Filter riwayat: semua, dipinjam, kembali, dan wallet saya.
- Pencarian dan pengurutan riwayat.
- Ganti akun: private key diisi pengguna di menu Setting, sehingga satu APK dapat dipakai banyak akun.
- Pilihan ingat akun di perangkat (disimpan terenkripsi dengan `flutter_secure_storage`).
- Katalog alat berkategori dengan pencarian saat meminjam.
- Detail catatan, durasi pinjam, dan tautan ke Etherscan.
- Konfirmasi sebelum transaksi dan penanganan tombol Back di Android.

## Teknologi dan Versi Paket

| Komponen | Versi |
|---|---|
| Flutter | `<isi dari flutter --version>` |
| Dart | `<isi dari flutter --version>` |
| web3dart | `<isi dari pubspec.yaml>` |
| wallet | `<isi dari pubspec.yaml>` |
| http | `<isi dari pubspec.yaml>` |
| flutter_dotenv | `<isi dari pubspec.yaml>` |
| crypto | `<isi dari pubspec.yaml>` |
| flutter_secure_storage | `<isi dari pubspec.yaml>` |
| url_launcher | `<isi dari pubspec.yaml>` |

Alat pendukung: Remix IDE, MetaMask, Alchemy (RPC Sepolia), Etherscan Sepolia.

Catatan: pada `web3dart` 3.x, tipe `EthereumAddress` dan `EthPrivateKey` berasal dari paket `wallet`, sehingga paket itu perlu diimpor terpisah.

## Cara Menjalankan

### Prasyarat

- Flutter SDK dan Android Studio atau VS Code.
- Emulator atau HP Android.
- Akun MetaMask **khusus tugas** (bukan wallet pribadi) dengan saldo Sepolia ETH dari faucet.
- RPC URL Sepolia dari penyedia seperti Alchemy atau Infura (akun gratis).

### Langkah

1. Clone repositori.
   ```bash
   git clone <url-repositori>
   cd <nama-folder>
   ```
2. Buat berkas `.env` dari contoh.
   ```bash
   cp .env.example .env
   ```
   Di Windows PowerShell: `Copy-Item .env.example .env`
3. Isi `.env`:
   ```
   RPC_URL=<RPC URL Sepolia milik Anda>
   CHAIN_ID=11155111
   CONTRACT_ADDRESS=0xcB141FD4c7F45b59be19F6f454672aab7aF8D696
   NIM_SALT=<teks acak rahasia, sama untuk seluruh anggota kelompok>
   ```
4. Pasang dependensi dan jalankan.
   ```bash
   flutter pub get
   flutter run
   ```
5. Buka menu **Setting**, tempel private key akun MetaMask khusus tugas, lalu aktifkan. Alamat yang tampil harus sama dengan alamat di MetaMask.

Berkas `.env` terdaftar sebagai asset di `pubspec.yaml`, jadi harus sudah ada sebelum aplikasi dijalankan atau di-build. Private key **tidak** disimpan di `.env`.

### Membuat APK

```bash
flutter build apk --release
```

Hasilnya ada di `build/app/outputs/flutter-apk/app-release.apk`. Pastikan `AndroidManifest.xml` memuat izin `INTERNET`, dan `minSdk` bernilai minimal 23 (syarat `flutter_secure_storage`).

## Struktur Proyek

```
contracts/LogbookLab.sol        kode smart contract
assets/abi/logbook_lab.json     ABI kontrak
lib/
  config/                       konfigurasi (.env) dan daftar alat
  models/                       model data Peminjaman
  services/                     seluruh kode web3dart (baca dan tulis kontrak)
  state/                        state aplikasi (LogbookController)
  theme/                        tema oranye dan putih
  utils/                        format tanggal, durasi, dan pembuka tautan
  widgets/                      kartu, detail, dialog status transaksi
  screens/                      Beranda, Pinjam, Riwayat, Setting
  main.dart
.env.example                    contoh konfigurasi tanpa data rahasia
```

## Cara Kerja Singkat

1. Aplikasi terhubung ke Sepolia lewat **RPC endpoint** menggunakan `web3dart`.
2. **ABI** memberi tahu `web3dart` cara memanggil fungsi kontrak.
3. Membaca data memakai `call` (gratis, tanpa tanda tangan).
4. Menulis data memakai `sendTransaction`: transaksi ditandatangani private key akun aktif, dikirim ke jaringan, lalu aplikasi menunggu konfirmasi masuk blok.
5. NIM dihitung menjadi `SHA-256(NIM_SALT + NIM)` di aplikasi, dan hanya hash-nya yang dikirim ke kontrak.

## Keamanan

- Hanya testnet Sepolia. Tidak ada mainnet dan tidak ada pembelian kripto.
- Gunakan akun MetaMask baru khusus tugas yang hanya berisi Sepolia ETH.
- `.env` masuk `.gitignore` dan tidak pernah di-commit. Repositori hanya memuat `.env.example`.
- Private key tidak ada di kode maupun di APK. Pengguna mengisinya sendiri di aplikasi, dan opsi "ingat akun" menyimpannya terenkripsi di perangkat.
- Data on-chain bersifat publik dan permanen, sehingga NIM tidak disimpan mentah.

### Keterbatasan

- **Private key diketik di aplikasi.** Ini lebih baik daripada ditanam di APK, tetapi tetap sensitif. Solusi yang lebih aman adalah WalletConnect/Reown, sehingga private key tidak pernah berada di aplikasi. Fitur itu belum diimplementasikan.
- **`NIM_SALT` ikut terbundel di APK** karena `.env` menjadi asset. Hash NIM masih dapat ditebak dengan brute force oleh pihak yang membongkar APK. Ini perlindungan tingkat dasar untuk keperluan tugas.
- **Nama alat membedakan huruf besar dan kecil**, dan satu nama hanya bisa dipinjam satu orang pada satu waktu. Unit alat yang sama perlu diberi nama berbeda.
- **Pembacaan data berulang**: aplikasi memanggil `ambilData` sekali per catatan, sehingga melambat jika catatan sangat banyak.
- **Durasi pinjam** dihitung dengan jam perangkat, sehingga bisa meleset jika jam perangkat tidak akurat.
- Kontrak tidak dapat diubah setelah di-deploy, dan belum ada fitur membatalkan atau mengedit catatan.

## Kendala dan Solusi

| Kendala | Solusi |
|---|---|
| `EthereumAddress` tidak dikenali pada `web3dart` 3.x | Menambahkan paket `wallet` dan mengimpornya |
| Waktu blockchain dalam detik, `DateTime` Dart dalam milidetik | Mengalikan dengan 1000 saat konversi |
| Alat dapat dipinjam ganda | `mapping` status pinjam di kontrak, dan alat yang sedang dipinjam dinonaktifkan di UI |
| Nama menu Remix berubah (Injected Provider menjadi Browser extension) | Memilih opsi MetaMask Sepolia |
| `<tambahkan kendala lain yang dialami kelompok>` | `<solusinya>` |

## Pembagian Tugas

| Anggota | Tanggung jawab |
|---|---|
| `<nama>` | `<contoh: kontrak, deploy, verifikasi Etherscan>` |
| `<nama>` | `<contoh: service web3dart, halaman daftar dan riwayat>` |
| `<nama>` | `<contoh: form pinjam, dokumentasi, video demo>` |

## Luaran

| Luaran | Tautan |
|---|---|
| Kontrak di Etherscan | https://sepolia.etherscan.io/address/0xcB141FD4c7F45b59be19F6f454672aab7aF8D696 |
| APK | `<tautan atau lokasi berkas>` |
| Video demo | `<tautan YouTube unlisted atau Google Drive>` |
| Laporan | `<tautan atau lokasi berkas>` |

## Sumber dan Kejujuran Akademik

Sumber yang dipelajari dan diadaptasi:

- Video rujukan tugas: *Build a Blockchain dApp with Flutter and Dart on Ethereum* dan *Build Your First Blockchain Flutter App*. `<sebutkan bagian kode yang diadaptasi>`
- Dokumentasi `web3dart` di pub.dev.
- Dokumentasi Solidity dan Remix IDE.
- Kerangka kontrak ChainTodo dari dokumen tugas sebagai acuan struktur. Kontrak `LogbookLab` ditulis ulang sesuai studi kasus logbook.
- Bantuan AI: `<jelaskan jujur bagian apa yang dibantu AI, misalnya kerangka kontrak, kode Flutter, dan penyusunan dokumentasi>`

Seluruh anggota kelompok memahami dan mampu menjelaskan kode yang dikumpulkan.