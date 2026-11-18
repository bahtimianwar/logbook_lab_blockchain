import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/app_config.dart';
import '../services/blockchain_service.dart';

class SettingScreen extends StatefulWidget {
  final BlockchainService service;
  const SettingScreen({super.key, required this.service});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final _ctrl = TextEditingController();
  bool _sembunyi = true;
  bool _ingat = false;
  bool _proses = false;
  String? _error;

  String? _alamatSaldo;
  Future<double>? _saldo;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // Muat ulang saldo hanya kalau akun aktif berubah.
  void _siapkanSaldo() {
    final a = widget.service.alamat;
    if (a != _alamatSaldo) {
      _alamatSaldo = a;
      _saldo = a == null ? null : widget.service.saldoEth();
    }
  }

  Future<void> _salin(String teks, String label) async {
    await Clipboard.setData(ClipboardData(text: teks));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$label disalin')));
  }

  Future<void> _tempel() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) _ctrl.text = data!.text!.trim();
  }

  Future<void> _aktifkan() async {
    setState(() {
      _proses = true;
      _error = null;
    });
    try {
      await widget.service.login(_ctrl.text, ingat: _ingat);
      _ctrl.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Akun aktif. Cocokkan alamatnya dengan akun di MetaMask.',
            ),
          ),
        );
      }
    } on FormatException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Private key tidak valid.';
    }
    if (mounted) setState(() => _proses = false);
  }

  Future<void> _hapusAkun() async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Keluar dari akun ini?'),
        content: const Text(
          'Private key akan dihapus dari aplikasi (termasuk yang tersimpan di '
          'perangkat). Data di blockchain tidak terpengaruh. '
          'Anda bisa mengisi akun lain setelahnya.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (yakin == true) await widget.service.logout();
  }

  Widget _formAkun() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Belum ada akun aktif. Tempel private key akun MetaMask khusus '
            'tugas (jaringan Sepolia). Di MetaMask: titik tiga di samping '
            'akun, Detail akun, lalu Tampilkan kunci pribadi. Nama menu bisa '
            'sedikit berbeda antar versi.',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ctrl,
            obscureText: _sembunyi,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              labelText: 'Private key',
              border: const OutlineInputBorder(),
              errorText: _error,
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Tempel',
                    icon: const Icon(Icons.paste),
                    onPressed: _tempel,
                  ),
                  IconButton(
                    tooltip: _sembunyi ? 'Tampilkan' : 'Sembunyikan',
                    icon: Icon(
                      _sembunyi ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () => setState(() => _sembunyi = !_sembunyi),
                  ),
                ],
              ),
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Ingat akun di perangkat ini'),
            subtitle: const Text(
              'Mati: key hanya di memori dan hilang saat aplikasi ditutup. '
              'Nyala: disimpan terenkripsi di perangkat.',
            ),
            value: _ingat,
            onChanged: (v) => setState(() => _ingat = v),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _proses ? null : _aktifkan,
            icon: _proses
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.login),
            label: const Text('Aktifkan akun'),
          ),
          const SizedBox(height: 12),
          Card(
            color: Theme.of(context).colorScheme.tertiaryContainer,
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Peringatan: pakai akun khusus tugas yang hanya berisi Sepolia '
                'ETH. Jangan pernah memasukkan private key wallet pribadi yang '
                'berisi aset asli.',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _infoAkun() {
    final alamat = widget.service.alamat!;
    final urlAkun = '${AppConfig.explorerUrl}/address/$alamat';
    return [
      ListTile(
        leading: const Icon(Icons.account_circle),
        title: const Text('Akun aktif (alamat wallet)'),
        subtitle: Text(alamat),
        trailing: IconButton(
          icon: const Icon(Icons.copy),
          onPressed: () => _salin(alamat, 'Alamat wallet'),
        ),
      ),
      ListTile(
        leading: const Icon(Icons.savings),
        title: const Text('Saldo'),
        subtitle: FutureBuilder<double>(
          future: _saldo,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Text('Memuat...');
            }
            if (snap.hasError) return const Text('Gagal memuat saldo');
            return Text('${snap.data!.toStringAsFixed(4)} SepoliaETH');
          },
        ),
        trailing: IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => setState(() => _saldo = widget.service.saldoEth()),
        ),
      ),
      ListTile(
        leading: const Icon(Icons.open_in_new),
        title: const Text('Link Etherscan akun'),
        subtitle: Text(urlAkun),
        trailing: IconButton(
          icon: const Icon(Icons.copy),
          onPressed: () => _salin(urlAkun, 'Link Etherscan akun'),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: OutlinedButton.icon(
          onPressed: _hapusAkun,
          icon: const Icon(Icons.swap_horiz),
          label: const Text('Keluar / Ganti akun'),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final urlKontrak =
        '${AppConfig.explorerUrl}/address/${AppConfig.contractAddress}';

    return Scaffold(
      appBar: AppBar(title: const Text('Setting')),
      body: ListenableBuilder(
        listenable: widget.service,
        builder: (context, _) {
          _siapkanSaldo();
          return ListView(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Text(
                  'Akun',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              if (widget.service.sudahLogin) ..._infoAkun() else _formAkun(),
              const SizedBox(height: 8),
              const Divider(),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text(
                  'Jaringan dan kontrak',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.hub),
                title: const Text('Jaringan'),
                subtitle: Text(
                  'Ethereum Sepolia (chain ID ${AppConfig.chainId})',
                ),
              ),
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text('Alamat kontrak'),
                subtitle: Text(AppConfig.contractAddress),
                trailing: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () =>
                      _salin(AppConfig.contractAddress, 'Alamat kontrak'),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('Link Etherscan kontrak'),
                subtitle: Text(urlKontrak),
                trailing: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () => _salin(urlKontrak, 'Link Etherscan kontrak'),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.cloud),
                title: const Text('RPC endpoint'),
                subtitle: Text(Uri.parse(AppConfig.rpcUrl).host),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'Catatan keamanan: private key diisi pengguna di '
                      'aplikasi, tidak ada di kode maupun di APK, dan tidak '
                      'pernah ditampilkan kembali. Gunakan hanya wallet '
                      'khusus tugas berisi Sepolia ETH.',
                      style: TextStyle(fontSize: 12),
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
