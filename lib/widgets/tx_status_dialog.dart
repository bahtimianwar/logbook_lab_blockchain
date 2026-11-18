import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/app_config.dart';
import '../utils/buka_url.dart';

/// Menjalankan alur: kirim, tunggu konfirmasi, berhasil atau gagal.
/// Mengembalikan true kalau transaksi sukses.
Future<bool> tampilkanStatusTransaksi(
  BuildContext context, {
  required String judul,
  required Future<String> Function() kirim,
  required Future<bool> Function(String hash) tunggu,
}) async {
  final hasil = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _TxDialog(judul: judul, kirim: kirim, tunggu: tunggu),
  );
  return hasil ?? false;
}

enum _Tahap { mengirim, menunggu, berhasil, gagal }

class _TxDialog extends StatefulWidget {
  final String judul;
  final Future<String> Function() kirim;
  final Future<bool> Function(String hash) tunggu;

  const _TxDialog({
    required this.judul,
    required this.kirim,
    required this.tunggu,
  });

  @override
  State<_TxDialog> createState() => _TxDialogState();
}

class _TxDialogState extends State<_TxDialog> {
  _Tahap _tahap = _Tahap.mengirim;
  String? _hash;
  String? _pesan;

  @override
  void initState() {
    super.initState();
    _jalankan();
  }

  Future<void> _jalankan() async {
    try {
      final h = await widget.kirim();
      if (!mounted) return;
      setState(() {
        _hash = h;
        _tahap = _Tahap.menunggu;
      });
      final ok = await widget.tunggu(h);
      if (!mounted) return;
      setState(() {
        _tahap = ok ? _Tahap.berhasil : _Tahap.gagal;
        if (!ok) _pesan = 'Transaksi ditolak oleh kontrak (reverted).';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _tahap = _Tahap.gagal;
        _pesan = _bersihkan(e);
      });
    }
  }

  String _bersihkan(Object e) {
    final s = e.toString();
    final m = RegExp(r'execution reverted:?\s*([^\n",}]*)').firstMatch(s);
    if (m != null && m.group(1)!.trim().isNotEmpty) return m.group(1)!.trim();
    if (s.contains('insufficient funds')) {
      return 'Saldo SepoliaETH tidak cukup untuk membayar gas.';
    }
    return s.length > 200 ? '${s.substring(0, 200)}...' : s;
  }

  Widget _baris() {
    switch (_tahap) {
      case _Tahap.mengirim:
        return _row(
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          'Memproses: mengirim transaksi ke jaringan...',
        );
      case _Tahap.menunggu:
        return _row(
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          'Memproses: menunggu transaksi masuk blok (bisa 10 sampai 30 detik)...',
        );
      case _Tahap.berhasil:
        return _row(
          const Icon(Icons.check_circle, color: Colors.green),
          'Berhasil. Transaksi sudah tercatat di blockchain.',
        );
      case _Tahap.gagal:
        return _row(
          const Icon(Icons.error, color: Colors.red),
          'Gagal: ${_pesan ?? 'terjadi kesalahan'}',
        );
    }
  }

  Widget _row(Widget ikon, String teks) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ikon,
      const SizedBox(width: 12),
      Expanded(child: Text(teks)),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final selesai = _tahap == _Tahap.berhasil || _tahap == _Tahap.gagal;
    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text(widget.judul),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _baris(),
            if (_hash != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Hash transaksi:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SelectableText(_hash!, style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () =>
                    bukaUrl(context, '${AppConfig.explorerUrl}/tx/$_hash'),
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text('Lihat di Etherscan'),
              ),
            ],
          ],
        ),
        actions: [
          if (_hash != null)
            TextButton(
              onPressed: () => Clipboard.setData(ClipboardData(text: _hash!)),
              child: const Text('Salin hash'),
            ),
          if (selesai)
            FilledButton(
              onPressed: () =>
                  Navigator.pop(context, _tahap == _Tahap.berhasil),
              child: const Text('Tutup'),
            ),
        ],
      ),
    );
  }
}
