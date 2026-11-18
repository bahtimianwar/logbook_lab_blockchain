import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:wallet/wallet.dart';
import 'package:web3dart/web3dart.dart';

import '../config/app_config.dart';
import '../models/peminjaman.dart';

class BlockchainService extends ChangeNotifier {
  static const _kunciPenyimpanan = 'akun_private_key';
  final _storage = const FlutterSecureStorage();

  late final Web3Client _client;
  late final DeployedContract _contract;
  EthPrivateKey? _creds;

  bool get sudahLogin => _creds != null;

  /// Alamat wallet akun aktif (turunan dari private key), null kalau belum login.
  String? get alamat => _creds?.address.eip55With0x;

  EthPrivateKey get _akun {
    final c = _creds;
    if (c == null) throw StateError('Belum login');
    return c;
  }

  Future<void> init() async {
    _client = Web3Client(AppConfig.rpcUrl, http.Client());
    final abi = await rootBundle.loadString('assets/abi/logbook_lab.json');
    _contract = DeployedContract(
      ContractAbi.fromJson(abi, 'LogbookLab'),
      EthereumAddress.fromHex(AppConfig.contractAddress),
    );
  }

  // ===== AKUN =====

  /// Mengembalikan 64 karakter hex, atau null kalau formatnya salah.
  static String? _normalisasi(String input) {
    var h = input.trim();
    if (h.startsWith('0x') || h.startsWith('0X')) h = h.substring(2);
    return RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(h) ? h : null;
  }

  /// Masuk memakai private key dari MetaMask.
  Future<void> login(String privateKey, {bool ingat = false}) async {
    final hex = _normalisasi(privateKey);
    if (hex == null) {
      throw const FormatException(
        'Private key harus 64 karakter hex (boleh diawali 0x).',
      );
    }
    _creds = EthPrivateKey.fromHex(hex);

    try {
      if (ingat) {
        await _storage.write(key: _kunciPenyimpanan, value: hex);
      } else {
        await _storage.delete(key: _kunciPenyimpanan);
      }
    } catch (_) {
      // Penyimpanan aman tidak tersedia: tetap login, hanya di memori.
    }
    notifyListeners();
  }

  /// Dipanggil saat app dibuka, memulihkan akun yang sebelumnya diingat.
  Future<void> pulihAkun() async {
    try {
      final hex = await _storage.read(key: _kunciPenyimpanan);
      if (hex != null && _normalisasi(hex) != null) {
        _creds = EthPrivateKey.fromHex(hex);
        notifyListeners();
      }
    } catch (_) {
      // Abaikan, user tinggal login manual.
    }
  }

  Future<void> logout() async {
    _creds = null;
    try {
      await _storage.delete(key: _kunciPenyimpanan);
    } catch (_) {}
    notifyListeners();
  }

  // ===== BACA (gratis, tidak butuh akun) =====

  Future<List<Peminjaman>> ambilSemua() async {
    final jumlah = await _client.call(
      contract: _contract,
      function: _contract.function('jumlahData'),
      params: [],
    );
    final n = (jumlah[0] as BigInt).toInt();

    final hasil = <Peminjaman>[];
    for (var i = 0; i < n; i++) {
      final r = await _client.call(
        contract: _contract,
        function: _contract.function('ambilData'),
        params: [BigInt.from(i)],
      );
      hasil.add(Peminjaman.fromResult(i, r));
    }
    return hasil.reversed.toList(); // terbaru di atas
  }

  Future<double> saldoEth() async {
    final b = await _client.getBalance(_akun.address);
    return b.getValueInUnit(EtherUnit.ether);
  }

  // ===== TULIS (butuh gas, ditandatangani akun aktif) =====

  Future<String> pinjam(String namaAlat, String nim) {
    // NIM di-hash dulu, yang masuk blockchain hanya hash-nya.
    final digest = sha256.convert(utf8.encode('${AppConfig.nimSalt}$nim'));
    return _client.sendTransaction(
      _akun,
      Transaction.callContract(
        contract: _contract,
        function: _contract.function('pinjamAlat'),
        parameters: [namaAlat, Uint8List.fromList(digest.bytes)],
      ),
      chainId: AppConfig.chainId,
    );
  }

  Future<String> kembalikan(int id) {
    return _client.sendTransaction(
      _akun,
      Transaction.callContract(
        contract: _contract,
        function: _contract.function('kembalikanAlat'),
        parameters: [BigInt.from(id)],
      ),
      chainId: AppConfig.chainId,
    );
  }

  /// Menunggu transaksi masuk blok. true = sukses, false = reverted.
  Future<bool> tungguKonfirmasi(String txHash) async {
    for (var i = 0; i < 40; i++) {
      final receipt = await _client.getTransactionReceipt(txHash);
      if (receipt != null) return receipt.status ?? false;
      await Future.delayed(const Duration(seconds: 3));
    }
    throw Exception('Timeout menunggu konfirmasi transaksi');
  }
}
