import 'package:flutter/foundation.dart';

import '../models/peminjaman.dart';
import '../services/blockchain_service.dart';

/// Satu sumber data untuk semua menu, jadi Beranda dan Riwayat selalu sinkron.
class LogbookController extends ChangeNotifier {
  final BlockchainService service;

  LogbookController(this.service) {
    // Saat akun diganti, UI ikut menyegarkan penanda "Wallet saya".
    service.addListener(notifyListeners);
  }

  List<Peminjaman> data = [];
  bool loading = false;
  String? error;

  Set<String> get alatDipinjam =>
      data.where((p) => p.masihDipinjam).map((p) => p.namaAlat).toSet();

  bool milikSaya(Peminjaman p) =>
      service.alamat != null &&
      p.wallet.toLowerCase() == service.alamat!.toLowerCase();

  Future<void> muat() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      data = await service.ambilSemua();
    } catch (e) {
      error = e.toString();
    }
    loading = false;
    notifyListeners();
  }

  /// Jeda singkat karena node RPC kadang belum sinkron tepat setelah blok masuk.
  Future<void> muatSetelahTransaksi() async {
    await Future.delayed(const Duration(seconds: 2));
    await muat();
  }

  @override
  void dispose() {
    service.removeListener(notifyListeners);
    super.dispose();
  }
}
