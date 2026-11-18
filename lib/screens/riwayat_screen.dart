import 'package:flutter/material.dart';

import '../models/peminjaman.dart';
import '../state/logbook_controller.dart';
import '../widgets/muat_state.dart';
import '../widgets/peminjaman_card.dart';

enum FilterRiwayat { semua, dipinjam, kembali, milikSaya }

class RiwayatScreen extends StatefulWidget {
  final LogbookController controller;
  const RiwayatScreen({super.key, required this.controller});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  FilterRiwayat _filter = FilterRiwayat.semua;
  bool _terbaru = true;
  final _cari = TextEditingController();
  String _kata = '';

  static const _label = {
    FilterRiwayat.semua: 'Semua',
    FilterRiwayat.dipinjam: 'Dipinjam',
    FilterRiwayat.kembali: 'Kembali',
    FilterRiwayat.milikSaya: 'Wallet saya',
  };

  @override
  void dispose() {
    _cari.dispose();
    super.dispose();
  }

  List<Peminjaman> _terapkan(List<Peminjaman> d) {
    Iterable<Peminjaman> hasil = d;
    switch (_filter) {
      case FilterRiwayat.semua:
        break;
      case FilterRiwayat.dipinjam:
        hasil = hasil.where((p) => p.masihDipinjam);
        break;
      case FilterRiwayat.kembali:
        hasil = hasil.where((p) => !p.masihDipinjam);
        break;
      case FilterRiwayat.milikSaya:
        hasil = hasil.where(widget.controller.milikSaya);
        break;
    }

    final k = _kata.trim().toLowerCase();
    if (k.isNotEmpty) {
      final idCari = k.replaceAll('#', '');
      hasil = hasil.where(
        (p) =>
            p.namaAlat.toLowerCase().contains(k) ||
            p.wallet.toLowerCase().contains(k) ||
            p.id.toString() == idCari,
      );
    }

    final list = hasil.toList();
    return _terbaru ? list : list.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat ulang',
            onPressed: widget.controller.muat,
          ),
        ],
      ),
      body: MuatState(
        controller: widget.controller,
        builder: (context) {
          final tampil = _terapkan(widget.controller.data);
          final adaPenyaring =
              _filter != FilterRiwayat.semua || _kata.trim().isNotEmpty;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                child: TextField(
                  controller: _cari,
                  onChanged: (v) => setState(() => _kata = v),
                  decoration: InputDecoration(
                    hintText: 'Cari nama alat, wallet, atau nomor',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _kata.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _cari.clear();
                              setState(() => _kata = '');
                            },
                          ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(28)),
                    ),
                    isDense: true,
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: FilterRiwayat.values
                      .map(
                        (f) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(_label[f]!),
                            selected: _filter == f,
                            onSelected: (_) => setState(() => _filter = f),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text('${tampil.length} catatan'),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => setState(() => _terbaru = !_terbaru),
                      icon: const Icon(Icons.swap_vert),
                      label: Text(_terbaru ? 'Terbaru' : 'Terlama'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: widget.controller.muat,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    children: tampil.isEmpty
                        ? [
                            const SizedBox(height: 80),
                            Icon(
                              adaPenyaring
                                  ? Icons.search_off
                                  : Icons.inbox_outlined,
                              size: 56,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(height: 8),
                            Center(
                              child: Text(
                                adaPenyaring
                                    ? 'Tidak ada hasil untuk pencarian atau filter ini'
                                    : 'Belum ada data peminjaman',
                              ),
                            ),
                          ]
                        : tampil
                              .map(
                                (p) => PeminjamanCard(
                                  p: p,
                                  milikSaya: widget.controller.milikSaya(p),
                                ),
                              )
                              .toList(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
