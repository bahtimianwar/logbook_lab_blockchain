import 'package:flutter/material.dart';

import '../config/daftar_alat.dart';
import '../models/peminjaman.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import 'detail_sheet.dart';

// Supaya file lain yang mengimpor card ini tetap bisa memakai fmtWaktu dan singkat.
export '../utils/format.dart';

class PeminjamanCard extends StatelessWidget {
  final Peminjaman p;
  final bool milikSaya;
  final VoidCallback? onKembalikan;

  const PeminjamanCard({
    super.key,
    required this.p,
    required this.milikSaya,
    this.onKembalikan,
  });

  Widget _info(IconData ikon, String teks) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(ikon, size: 15, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Expanded(child: Text(teks, style: const TextStyle(fontSize: 12.5))),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final aktif = p.masihDipinjam;
    final warna = aktif ? AppTheme.oranye : AppTheme.hijau;
    final latar = aktif ? AppTheme.oranyeMuda : AppTheme.hijauMuda;

    final durasi = aktif
        ? 'Sudah dipinjam ${fmtDurasi(DateTime.now().difference(p.waktuPinjam))}'
        : 'Durasi pinjam ${fmtDurasi(p.waktuKembali!.difference(p.waktuPinjam))}';

    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: aktif ? AppTheme.oranye.withAlpha(110) : AppTheme.garis,
        ),
      ),
      child: InkWell(
        onTap: () => tampilkanDetail(context, p, milikSaya),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: latar,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(ikonUntuk(p.namaAlat), color: warna),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.namaAlat,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          milikSaya ? '#${p.id}  •  Wallet saya' : '#${p.id}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: latar,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      aktif ? 'Dipinjam' : 'Kembali',
                      style: TextStyle(
                        color: aktif ? AppTheme.oranyeTua : AppTheme.hijau,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _info(Icons.event, 'Dipinjam ${fmtWaktu(p.waktuPinjam)}'),
              if (!aktif)
                _info(
                  Icons.assignment_turned_in,
                  'Kembali ${fmtWaktu(p.waktuKembali!)}',
                ),
              _info(Icons.timer_outlined, durasi),
              _info(Icons.account_balance_wallet_outlined, singkat(p.wallet)),
              if (aktif && milikSaya && onKembalikan != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: onKembalikan,
                    icon: const Icon(Icons.assignment_return),
                    label: const Text('Kembalikan'),
                  ),
                ),
              if (aktif && !milikSaya)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    'Hanya wallet peminjam yang bisa mengembalikan alat ini.',
                    style: TextStyle(fontSize: 11.5),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
