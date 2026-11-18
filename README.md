# Logbook Lab Blockchain

Aplikasi Flutter untuk mencatat peminjaman alat Lab IoT. Data peminjaman disimpan di smart contract pada jaringan uji **Ethereum Sepolia**, bukan di server atau database lokal.

Proyek ini adalah tugas mata kuliah **Pemrograman Mobile 2**, D4 Teknologi Rekayasa Komputer, Jurusan Teknologi Informasi, Politeknik Negeri Samarinda.

## Identitas Kelompok

| Komponen | Isi |
|---|---|
| Kelompok 3|
| Anggota 1 | `<Bahtimi Anwar, 246661033>` |
| Anggota 2 | `<Muhammad Romi Wardana, 246661040>` |
| Anggota 3 | `<Muhammad Hafidz Kurniawan, 246661051>` |
| Dosen pengampu | `<Fara Triadi>` |
| Studi kasus | Logbook peminjaman alat Lab IoT |
| Repositori | https://github.com/bahtimianwar/logbook_lab_blockchain |

## Informasi Smart Contract

| Item | Nilai |
|---|---|
| Jaringan | Ethereum Sepolia (testnet) |
| Chain ID | `11155111` |
| Alamat kontrak | `0xcB141FD4c7F45b59be19F6f454672aab7aF8D696` |
| Etherscan | https://sepolia.etherscan.io/address/0xcB141FD4c7F45b59be19F6f454672aab7aF8D696 |
| Status | Terverifikasi di Etherscan (Source Code Verified) |
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

Penyimpanan di kontrak: array `Peminjaman[] private daftar`, dan `mapping(bytes32 => bool) sedangDipinjam` dengan kunci `keccak256(bytes(namaAlat))` untuk mencegah satu alat dipinjam dua kali.

### Fungsi dan event kontrak

| Fungsi | Jenis | Keterangan |
|---|---|---|
| `pinjamAlat(namaAlat, kodePeminjam)` | Tulis | Mencatat peminjaman. Ditolak jika nama kosong atau alat yang sama sedang dipinjam |
| `kembalikanAlat(id)` | Tulis | Mencatat pengembalian. Hanya wallet peminjam yang bisa, dan hanya sekali |
| `jumlahData()` | Baca | Jumlah seluruh catatan |
| `ambilData(id)` | Baca | Detail satu catatan |

| Event | Parameter |
|---|---|
| `AlatDipinjam` | `id`, `namaAlat`, `wallet` |
| `AlatDikembalikan` | `id` |

Fungsi baca tidak membutuhkan gas dan tanda tangan. Fungsi tulis membutuhkan gas (Sepolia ETH) dan ditandatangani private key pemilik akun.

### Cara memeriksa kontrak dan transaksi di Etherscan

1. Buka tautan Etherscan kontrak di atas.
2. Tab **Contract** harus menampilkan tanda centang hijau (Source Code Verified) beserta kode `LogbookLab.sol`.
3. Tab **Transactions** menampilkan transaksi `pinjamAlat` dan `kembalikanAlat`. Buka salah satu transaksi untuk melihat:
   - **Status**: Success.
   - **From**: alamat wallet peminjam (sama dengan "Akun aktif" di menu Setting aplikasi).
   - **To**: alamat kontrak.
   - **Logs**: event `AlatDipinjam` atau `AlatDikembalikan`.
   - **Input Data**: berisi hash NIM, bukan NIM asli.
4. Di tab **Contract**, pilih **Read Contract**, lalu jalankan `jumlahData`. Nilainya sama dengan "Total catatan" di Beranda aplikasi.
5. Hash transaksi (66 karakter) pada dialog status transaksi di aplikasi sama dengan **Transaction Hash** di Etherscan.

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

Aplikasi memiliki tiga menu: **Beranda**, **Riwayat**, dan **Setting**. Tidak ada layar login. Membaca data tidak membutuhkan akun, sedangkan transaksi tulis membutuhkan private key yang diisi di Setting.

**Fitur minimum**

- Daftar peminjaman dibaca langsung dari kontrak, status dibedakan lewat warna dan label (dipinjam dan kembali).
- Form pinjam alat yang mengirim transaksi `pinjamAlat`. Alat yang sedang dipinjam dinonaktifkan, dan kolom NIM hanya menerima angka.
- Tombol kembalikan yang mengirim transaksi `kembalikanAlat`, hanya terlihat untuk wallet peminjam.
- Indikator status transaksi: memproses, berhasil dengan hash transaksi, dan gagal dengan pesan error.
- Tombol refresh dan tarik untuk memuat ulang.
- Alamat kontrak, RPC URL, dan chain ID disimpan di satu berkas konfigurasi (`.env`).
- NIM tidak disimpan mentah di blockchain, hanya hash.

**Fitur tambahan**

- Filter riwayat: semua, dipinjam, kembali, dan wallet saya.
- Pencarian dan pengurutan riwayat.
- Ganti akun: private key diisi pengguna di menu Setting dan bisa diganti lewat Keluar atau Ganti akun, sehingga satu APK dapat dipakai banyak akun.
- Pilihan ingat akun di perangkat (disimpan terenkripsi dengan `flutter_secure_storage`).
- Katalog sekitar 35 alat berkategori dengan ikon dan pencarian saat meminjam.
- Lembar detail catatan, durasi pinjam, dan tautan ke Etherscan.
- Badge jumlah alat yang sedang dipinjam.
- Konfirmasi sebelum transaksi dan penanganan tombol Back di Android (kembali ke Beranda, dua kali di Beranda untuk keluar).
- Tema oranye dan putih.

## Teknologi dan Versi Paket

| Komponen | Versi |
|---|---|
| Flutter | `<3.47.1>` |
| Dart | `<3.13.1>` |
| web3dart | (`<3.0.3>`) |
| wallet | `<0.0.18>` |
| crypto | `<3.0.8>` |
| flutter_secure_storage | `<11.2.0>` |
| url_launcher | `<6.3.3>` |

Alat pendukung: Remix IDE, MetaMask, Alchemy (RPC Sepolia), Etherscan Sepolia.

Catatan: pada `web3dart` 3.x, tipe `EthereumAddress` dan `EthPrivateKey` berasal dari paket `wallet`, sehingga paket itu perlu diimpor terpisah. Properti alamat yang dipakai adalah `eip55With0x`.

## Cara Menjalankan

### Prasyarat

- Flutter SDK dan Android Studio atau VS Code.
- Emulator atau HP Android (aplikasi juga sudah diuji berjalan di Chrome).
- Akun MetaMask **khusus tugas** (bukan wallet pribadi) dengan saldo Sepolia ETH dari faucet.
- RPC URL Sepolia dari penyedia seperti Alchemy atau Infura (akun gratis). Setiap penjalankan memakai RPC URL milik sendiri.

### Langkah

1. Clone repositori.
   ```bash
   git clone https://github.com/bahtimianwar/logbook_lab_blockchain.git
   cd logbook_lab_blockchain
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
   NIM_SALT=<teks acak rahasia, sama untuk seluruh pengguna aplikasi ini>
   ```
4. Pasang dependensi dan jalankan.
   ```bash
   flutter pub get
   flutter run
   ```
5. Buka menu **Setting**, tempel private key akun MetaMask khusus tugas, lalu aktifkan. Alamat yang tampil harus sama dengan alamat di MetaMask, dan saldo Sepolia ETH akan terbaca.

Berkas `.env` terdaftar sebagai asset di `pubspec.yaml`, jadi harus sudah ada sebelum aplikasi dijalankan atau di-build. Private key **tidak** disimpan di `.env`. Berkas `.env` asli tidak ada di repositori, hanya `.env.example`.

### Membuat APK

```bash
flutter build apk --release
```

Hasilnya ada di `build/app/outputs/flutter-apk/app-release.apk`. Pastikan `AndroidManifest.xml` memuat izin `INTERNET`, dan `minSdk` bernilai minimal 23 (syarat `flutter_secure_storage`).

Untuk komputer dengan RAM kecil, build bisa gagal (crash). Beberapa cara yang dipakai:

- Menurunkan nilai `org.gradle.jvmargs` di `android/gradle.properties` dan menutup aplikasi lain.
- Membatasi arsitektur yang dibangun: `flutter build apk --release --target-platform android-arm64`.

Karena APK membawa isi `.env` sebagai asset, APK **tidak** di-commit ke repositori dan dibagikan lewat tautan terbatas (lihat bagian Luaran).

## Struktur Proyek

```
contracts/LogbookLab.sol        kode smart contract
assets/abi/logbook_lab.json     ABI kontrak
lib/
  config/                       app_config.dart (baca .env), daftar_alat.dart (katalog alat)
  models/                       peminjaman.dart (model data Peminjaman)
  services/                     blockchain_service.dart (seluruh kode web3dart: baca dan tulis kontrak)
  state/                        logbook_controller.dart (state aplikasi)
  theme/                        app_theme.dart (tema oranye dan putih)
  utils/                        format.dart (tanggal dan durasi), buka_url.dart
  widgets/                      peminjaman_card, detail_sheet, muat_state, tx_status_dialog
  screens/                      main_shell, home, pinjam, riwayat, setting
  main.dart
.env.example                    contoh konfigurasi tanpa data rahasia
```

## Cara Kerja Singkat

1. Aplikasi terhubung ke Sepolia lewat **RPC endpoint** menggunakan `web3dart`.
2. **ABI** memberi tahu `web3dart` cara memanggil fungsi kontrak.
3. Membaca data memakai `call` (gratis, tanpa tanda tangan).
4. Menulis data memakai `sendTransaction`: transaksi ditandatangani private key akun aktif, dikirim ke jaringan, lalu aplikasi menunggu konfirmasi masuk blok.
5. NIM dihitung menjadi `SHA-256(NIM_SALT + NIM)` di aplikasi, dan hanya hash-nya yang dikirim ke kontrak.

## Pengujian Aplikasi

Yang sudah diuji dan berhasil:

- Aplikasi berjalan di Chrome dan `flutter analyze` bersih tanpa error.
- Pinjam dan kembalikan berhasil terkirim di Sepolia, dan hasilnya terlihat di Etherscan.
- Pengujian dengan dua akun berbeda: tombol Kembalikan hanya muncul untuk wallet peminjam, dan filter "Wallet saya" menampilkan data yang benar.
- Build APK release berhasil (dibangun di laptop anggota lain karena RAM laptop utama kecil). Hasil tes APK di HP: `<isi hasil tes APK di HP>`.

## Keamanan

- Hanya testnet Sepolia. Tidak ada mainnet dan tidak ada pembelian kripto.
- Gunakan akun MetaMask baru khusus tugas yang hanya berisi Sepolia ETH.
- `.env` masuk `.gitignore` dan tidak pernah di-commit. Repositori hanya memuat `.env.example`.
- Private key tidak ada di kode maupun di APK. Pengguna mengisinya sendiri di aplikasi, dan opsi "ingat akun" menyimpannya terenkripsi di perangkat.
- API key RPC tidak ditulis di README maupun di repositori.
- Data on-chain bersifat publik dan permanen, sehingga NIM tidak disimpan mentah.

### Keterbatasan

- **Private key diketik di aplikasi.** Ini lebih baik daripada ditanam di APK, tetapi tetap sensitif. Solusi yang lebih aman adalah WalletConnect/Reown, sehingga private key tidak pernah berada di aplikasi. Fitur itu belum diimplementasikan.
- **`NIM_SALT` ikut terbundel di APK** karena `.env` menjadi asset. Hash NIM masih dapat ditebak dengan brute force oleh pihak yang membongkar APK. Ini perlindungan tingkat dasar untuk keperluan tugas.
- **Nama alat membedakan huruf besar dan kecil**, dan satu nama hanya bisa dipinjam satu orang pada satu waktu. Unit alat yang sama perlu diberi nama berbeda.
- **Pembacaan data berulang**: aplikasi memanggil `ambilData` sekali per catatan, sehingga melambat jika catatan sangat banyak.
- **Durasi pinjam** dihitung dengan jam perangkat, sehingga bisa meleset jika jam perangkat tidak akurat.
- Kontrak tidak dapat diubah setelah di-deploy, dan belum ada fitur membatalkan atau mengedit catatan.
- Aplikasi belum mendengarkan event kontrak secara langsung. Pembaruan data lewat refresh dan tarik.

## Kendala dan Solusi

| Kendala | Solusi |
|---|---|
| Menu Remix berubah (Injected Provider menjadi Browser extension) | Memilih opsi MetaMask Sepolia pada environment |
| Jaringan Sepolia tidak tampil di MetaMask | Mengaktifkan opsi jaringan uji di pengaturan MetaMask. Alamat akun sama di semua jaringan EVM |
| Sebagian faucet mensyaratkan saldo mainnet, tidak cocok untuk wallet baru | Memakai faucet lain yang tidak mensyaratkan saldo mainnet (`<isi nama faucet yang berhasil>`) |
| Verifikasi Etherscan gagal | Versi compiler, optimization, dan EVM version harus identik dengan saat kompilasi di Remix |
| `curl` di PowerShell adalah alias `Invoke-WebRequest` sehingga uji RPC gagal | Memakai `Invoke-RestMethod` untuk menguji RPC (hasil `0xaa36a7` = chain ID Sepolia) |
| `EthereumAddress` tidak dikenali pada `web3dart` 3.x | Menambahkan paket `wallet`, mengimpornya, dan memakai `eip55With0x` |
| Waktu blockchain dalam detik, `DateTime` Dart dalam milidetik, dan angka bertipe `BigInt` | Mengalikan dengan 1000 saat konversi dan mengonversi `BigInt` secara eksplisit |
| Alat dapat dipinjam ganda pada draf awal kontrak | `mapping` status pinjam di kontrak, dan alat yang sedang dipinjam dinonaktifkan di UI |
| Satu private key di `.env` membuat semua pengguna memakai satu wallet | Private key diisi pengguna di menu Setting, tidak lagi di `.env` |
| Berkas state terpotong sehingga muncul 15 error pada analyzer | Mengganti dengan berkas utuh, bukan potongan kode |
| Commit lokal belum terkirim ke remote (branch ahead 2 commit) | Melakukan push setelah memeriksa status dengan `git status` |
| Mode gelap kontrasnya buruk | Mode gelap dihapus, memakai satu tema oranye dan putih |
| Build APK crash karena RAM laptop kecil | Menurunkan `org.gradle.jvmargs`, menutup aplikasi lain, dan build di laptop anggota lain dengan target `android-arm64` |
| Repositori bersarang (folder `.git` di dalam folder proyek) tercatat sebagai submodule dan push ditolak | Menghapus pencatatan folder bersarang dari index (`git rm --cached`) atau mulai bersih dengan clone baru, tanpa `git push --force` |

## Pembagian Tugas

Pembagian berdasarkan penanggung jawab modul: menjalankan, menguji, memahami, dan menjelaskan modul tersebut.

| Anggota | Tanggung jawab |
|---|---|
| `<Bahtimi Anwar & Muhammad Romi Wardana>` | **Blockchain dan kontrak**: `LogbookLab.sol`, ABI, `models/peminjaman.dart`, `widgets/detail_sheet.dart`, `config/daftar_alat.dart`. Pengaturan MetaMask, faucet, deploy, verifikasi Etherscan, dan pengujian Remix VM | **Integrasi web3, logika aplikasi, dan rilis**: `app_config.dart`, `blockchain_service.dart`, `logbook_controller.dart`, `main.dart`, `tx_status_dialog.dart`, `muat_state.dart`, `setting_screen.dart`. Konfigurasi `.env`, keamanan repositori, Git, izin Android, dan build APK |
| `<Muhammad Hafidz Kurniawan>` | **Antarmuka dan dokumentasi**: `app_theme.dart`, `format.dart`, `buka_url.dart`, `peminjaman_card.dart`, `main_shell.dart`, `home_screen.dart`, `pinjam_screen.dart`, `riwayat_screen.dart`. Pengujian alur pengguna, skenario video demo, penyuntingan README dan laporan |

## Luaran

| Luaran | Tautan |
|---|---|
| Kontrak di Etherscan | https://sepolia.etherscan.io/address/0xcB141FD4c7F45b59be19F6f454672aab7aF8D696 |
| Repositori | https://github.com/bahtimianwar/logbook_lab_blockchain |
| APK | `https://drive.google.com/drive/folders/1XqnYr8ICbsa7prtBPJIECX52EBL-3Rcb?usp=sharing` |
| Video demo | `<https://youtu.be/Wdab8P2gnTw?si=V77ZRNtUJbUn5qUD>` |

## Sumber dan Kejujuran Akademik

Sumber yang dipelajari dan diadaptasi:

- Dokumentasi `web3dart` di pub.dev.
- Dokumentasi Solidity dan Remix IDE.
- Kerangka kontrak ChainTodo dari dokumen tugas sebagai acuan struktur. Kontrak `LogbookLab` ditulis ulang sesuai studi kasus logbook.
- Bantuan AI: asisten AI dipakai untuk membantu menyusun kerangka kontrak, kode Flutter, pencarian penyebab error, dan penyusunan dokumentasi. Seluruh kode dijalankan dan diuji sendiri oleh kelompok.

Seluruh anggota kelompok memahami dan mampu menjelaskan kode yang dikumpulkan.
