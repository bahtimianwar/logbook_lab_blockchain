import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/daftar_alat.dart';
import '../models/peminjaman.dart';
import '../services/blockchain_service.dart';
import '../state/logbook_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/muat_state.dart';
import '../widgets/peminjaman_card.dart';
import '../widgets/tx_status_dialog.dart';
import 'pinjam_screen.dart';

class HomeScreen extends StatelessWidget {
  final LogbookController controller;
  final BlockchainService service;
  final VoidCallback onBukaSetting;

  const HomeScreen({
    super.key,
    required this.controller,
    required this.service,
    required this.onBukaSetting,
  });

  Future<void> _kembalikan(BuildContext context, Peminjaman p) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Kembalikan alat?'),
        content: Text(
          '${p.namaAlat} (#${p.id}) akan dicatat sebagai dikembalikan. '
          'Transaksi ini memerlukan gas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Kembalikan'),
          ),
        ],
      ),
    );
    if (yakin != true || !context.mounted) return;

    final ok = await tampilkanStatusTransaksi(
      context,
      judul: 'Mengembalikan ${p.namaAlat}',
      kirim: () => service.kembalikan(p.id),
      tunggu: service.tungguKonfirmasi,
    );
    if (ok) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${p.namaAlat} berhasil dikembalikan')),
        );
      }
      controller.muatSetelahTransaksi();
    }
  }

  void _bukaPinjam(BuildContext context, {String? alat}) {
    if (!service.sudahLogin) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Isi akun dulu di menu Setting (private key MetaMask).',
          ),
          action: SnackBarAction(label: 'Buka', onPressed: onBukaSetting),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PinjamScreen(
          controller: controller,
          service: service,
          alatAwal: alat,
        ),
      ),
    );
  }

  Widget _isi(BuildContext context) {
    final aktif = controller.data.where((p) => p.masihDipinjam).toList();
    final dipinjam = controller.alatDipinjam;
    final tersedia = daftarAlat
        .where((a) => !dipinjam.contains(a.nama))
        .toList();
    final tampilAlat = tersedia.length > 12
        ? tersedia.sublist(0, 12)
        : tersedia;

    return RefreshIndicator(
      color: AppTheme.oranye,
      onRefresh: controller.muat,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          Row(
            children: [
              Expanded(
                child: _Stat(
                  label: 'Dipinjam',
                  nilai: '${aktif.length}',
                  ikon: Icons.schedule,
                  warna: AppTheme.oranye,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Stat(
                  label: 'Tersedia',
                  nilai: '${tersedia.length}',
                  ikon: Icons.inventory_2_outlined,
                  warna: AppTheme.hijau,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Stat(
                  label: 'Total catatan',
                  nilai: '${controller.data.length}',
                  ikon: Icons.receipt_long,
                  warna: AppTheme.oranyeTua,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _Judul('Alat tersedia'),
          const SizedBox(height: 8),
          if (tampilAlat.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Semua alat sedang dipinjam.'),
            )
          else
            SizedBox(
              height: 104,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: tampilAlat.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, i) => _AlatChip(
                  alat: tampilAlat[i],
                  onTap: () => _bukaPinjam(context, alat: tampilAlat[i].nama),
                ),
              ),
            ),
          const SizedBox(height: 20),
          _Judul('Sedang dipinjam (${aktif.length})'),
          const SizedBox(height: 8),
          if (aktif.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 52,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  const Text('Tidak ada alat yang sedang dipinjam.'),
                ],
              ),
            )
          else
            ...aktif.map(
              (p) => PeminjamanCard(
                p: p,
                milikSaya: controller.milikSaya(p),
                onKembalikan: () => _kembalikan(context, p),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          icon: const Icon(Icons.add),
          label: const Text('Pinjam Alat'),
          onPressed: () => _bukaPinjam(context),
        ),
        body: Column(
          children: [
            ListenableBuilder(
              listenable: controller,
              builder: (context, _) => _Header(
                service: service,
                onRefresh: controller.muat,
                onBukaSetting: onBukaSetting,
              ),
            ),
            Expanded(
              child: MuatState(controller: controller, builder: _isi),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final BlockchainService service;
  final VoidCallback onRefresh;
  final VoidCallback onBukaSetting;

  const _Header({
    required this.service,
    required this.onRefresh,
    required this.onBukaSetting,
  });

  @override
  Widget build(BuildContext context) {
    final login = service.sudahLogin;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.paddingOf(context).top + 12,
        8,
        20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.oranye, AppTheme.oranyeTua],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Logbook Lab',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Peminjaman alat Lab IoT di blockchain Sepolia',
                      style: TextStyle(color: Colors.white70, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Muat ulang',
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 14),
          InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: login ? null : onBukaSetting,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    login ? Icons.account_circle : Icons.info_outline,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      login
                          ? 'Akun aktif: ${singkat(service.alamat!, 8, 6)}'
                          : 'Belum ada akun. Ketuk untuk mengisi di Setting',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String nilai;
  final IconData ikon;
  final Color warna;

  const _Stat({
    required this.label,
    required this.nilai,
    required this.ikon,
    required this.warna,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.garis),
      ),
      child: Column(
        children: [
          Icon(ikon, color: warna),
          const SizedBox(height: 6),
          Text(
            nilai,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: warna,
            ),
          ),
          Text(label, style: const TextStyle(fontSize: 11.5)),
        ],
      ),
    );
  }
}

class _Judul extends StatelessWidget {
  final String teks;
  const _Judul(this.teks);

  @override
  Widget build(BuildContext context) => Text(
    teks,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: AppTheme.teks,
    ),
  );
}

class _AlatChip extends StatelessWidget {
  final Alat alat;
  final VoidCallback onTap;

  const _AlatChip({required this.alat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.garis),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: SizedBox(
          width: 108,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.oranyeMuda,
                  child: Icon(alat.ikon, color: AppTheme.oranye, size: 20),
                ),
                const SizedBox(height: 6),
                Text(
                  alat.nama,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
