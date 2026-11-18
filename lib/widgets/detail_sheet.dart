import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/app_config.dart';
import '../models/peminjaman.dart';
import '../utils/buka_url.dart';
import '../utils/format.dart';

Future<void> tampilkanDetail(
  BuildContext context,
  Peminjaman p,
  bool milikSaya,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _DetailSheet(p: p, milikSaya: milikSaya),
  );
}

class _DetailSheet extends StatelessWidget {
  final Peminjaman p;
  final bool milikSaya;

  const _DetailSheet({required this.p, required this.milikSaya});

  Widget _baris(String label, String nilai, {bool salin = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: SelectableText(nilai)),
          if (salin) _SalinButton(nilai),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final aktif = p.masihDipinjam;
    final durasi = aktif
        ? DateTime.now().difference(p.waktuPinjam)
        : p.waktuKembali!.difference(p.waktuPinjam);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '#${p.id} ${p.namaAlat}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  aktif ? Icons.schedule : Icons.check_circle,
                  color: aktif ? Colors.orange : Colors.green,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(aktif ? 'Masih dipinjam' : 'Sudah dikembalikan'),
                if (milikSaya) ...[
                  const SizedBox(width: 8),
                  const Chip(
                    label: Text('Wallet saya'),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ],
            ),
            const Divider(height: 24),
            _baris('Dipinjam', fmtWaktu(p.waktuPinjam)),
            _baris('Dikembalikan', aktif ? '-' : fmtWaktu(p.waktuKembali!)),
            _baris(aktif ? 'Sudah berjalan' : 'Durasi', fmtDurasi(durasi)),
            _baris('Wallet', p.wallet, salin: true),
            _baris('Kode peminjam', p.kodePeminjam, salin: true),
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Kode peminjam adalah hash NIM (SHA-256 dengan salt), '
                'bukan NIM asli.',
                style: TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              onPressed: () => bukaUrl(
                context,
                '${AppConfig.explorerUrl}/address/${p.wallet}',
              ),
              icon: const Icon(Icons.open_in_new),
              label: const Text('Lihat wallet di Etherscan'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => bukaUrl(
                context,
                '${AppConfig.explorerUrl}/address/${AppConfig.contractAddress}',
              ),
              icon: const Icon(Icons.description),
              label: const Text('Lihat kontrak di Etherscan'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SalinButton extends StatefulWidget {
  final String teks;
  const _SalinButton(this.teks);

  @override
  State<_SalinButton> createState() => _SalinButtonState();
}

class _SalinButtonState extends State<_SalinButton> {
  bool _ok = false;

  Future<void> _salin() async {
    await Clipboard.setData(ClipboardData(text: widget.teks));
    if (!mounted) return;
    setState(() => _ok = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) setState(() => _ok = false);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Salin',
      visualDensity: VisualDensity.compact,
      icon: Icon(_ok ? Icons.check : Icons.copy, size: 20),
      onPressed: _salin,
    );
  }
}
