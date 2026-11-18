import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/daftar_alat.dart';
import '../services/blockchain_service.dart';
import '../state/logbook_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/tx_status_dialog.dart';

class PinjamScreen extends StatefulWidget {
  final LogbookController controller;
  final BlockchainService service;
  final String? alatAwal;

  const PinjamScreen({
    super.key,
    required this.controller,
    required this.service,
    this.alatAwal,
  });

  @override
  State<PinjamScreen> createState() => _PinjamScreenState();
}

class _PinjamScreenState extends State<PinjamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nimCtrl = TextEditingController();
  final _cariCtrl = TextEditingController();
  String? _alat;
  String? _kategori; // null = semua
  String _kata = '';

  @override
  void initState() {
    super.initState();
    _alat = widget.alatAwal;
  }

  @override
  void dispose() {
    _nimCtrl.dispose();
    _cariCtrl.dispose();
    super.dispose();
  }

  List<Alat> _saring() {
    final k = _kata.trim().toLowerCase();
    return daftarAlat.where((a) {
      final cocokKategori = _kategori == null || a.kategori == _kategori;
      final cocokKata = k.isEmpty || a.nama.toLowerCase().contains(k);
      return cocokKategori && cocokKata;
    }).toList();
  }

  Future<void> _kirim() async {
    if (_alat == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Pilih alat dulu.')));
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    final alat = _alat!;
    final nim = _nimCtrl.text.trim();

    final yakin = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Pinjam alat ini?'),
        content: Text(
          '$alat akan dicatat atas nama wallet akun aktif. '
          'Transaksi ini memerlukan gas dan tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Pinjam'),
          ),
        ],
      ),
    );
    if (yakin != true || !mounted) return;

    final ok = await tampilkanStatusTransaksi(
      context,
      judul: 'Meminjam $alat',
      kirim: () => widget.service.pinjam(alat, nim),
      tunggu: widget.service.tungguKonfirmasi,
    );
    if (!ok || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger.showSnackBar(SnackBar(content: Text('$alat berhasil dipinjam')));
    widget.controller.muatSetelahTransaksi();
  }

  Widget _tile(Alat a, bool dipinjam) {
    final dipilih = _alat == a.nama;
    return Card(
      elevation: 0,
      color: dipinjam ? Colors.grey.shade100 : Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: dipilih ? AppTheme.oranye : AppTheme.garis,
          width: dipilih ? 2 : 1,
        ),
      ),
      child: ListTile(
        enabled: !dipinjam,
        onTap: () => setState(() => _alat = a.nama),
        leading: CircleAvatar(
          backgroundColor: AppTheme.oranyeMuda,
          child: Icon(a.ikon, color: AppTheme.oranye),
        ),
        title: Text(a.nama),
        subtitle: Text(dipinjam ? 'Sedang dipinjam' : a.kategori),
        trailing: dipilih
            ? const Icon(Icons.check_circle, color: AppTheme.oranye)
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pinjam Alat')),
      body: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          final dipinjam = widget.controller.alatDipinjam;
          final hasil = _saring();

          return Column(
            children: [
              Expanded(
                child: ListView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.all(16),
                  children: [
                    TextField(
                      controller: _cariCtrl,
                      onChanged: (v) => setState(() => _kata = v),
                      decoration: InputDecoration(
                        hintText: 'Cari alat',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _kata.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _cariCtrl.clear();
                                  setState(() => _kata = '');
                                },
                              ),
                        filled: true,
                        fillColor: Colors.white,
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: const BorderSide(color: AppTheme.garis),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: const BorderSide(color: AppTheme.garis),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: const Text('Semua'),
                              selected: _kategori == null,
                              onSelected: (_) =>
                                  setState(() => _kategori = null),
                            ),
                          ),
                          ...kategoriAlat.map(
                            (k) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(k),
                                selected: _kategori == k,
                                onSelected: (_) =>
                                    setState(() => _kategori = k),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (hasil.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(child: Text('Alat tidak ditemukan')),
                      )
                    else
                      ...hasil.map((a) => _tile(a, dipinjam.contains(a.nama))),
                  ],
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: SafeArea(
                  top: false,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _alat == null
                              ? 'Pilih alat di atas'
                              : 'Dipilih: $_alat',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nimCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            labelText: 'NIM peminjam',
                            helperText: 'Di-hash (SHA-256 + salt) sebelum dikirim. NIM asli tidak masuk blockchain.',
                            helperMaxLines: 2,
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          validator: (v) {
                            final t = (v ?? '').trim();
                            if (t.isEmpty) return 'NIM tidak boleh kosong';
                            if (t.length < 5) return 'NIM terlalu pendek';
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        FilledButton.icon(
                          onPressed: _kirim,
                          icon: const Icon(Icons.send),
                          label: const Text('Kirim transaksi'),
                        ),
                      ],
                    ),
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
