import 'package:wallet/wallet.dart';

class Peminjaman {
  final int id;
  final String namaAlat;
  final String kodePeminjam; // hash NIM dalam hex
  final String wallet;
  final DateTime waktuPinjam;
  final DateTime? waktuKembali;

  Peminjaman({
    required this.id,
    required this.namaAlat,
    required this.kodePeminjam,
    required this.wallet,
    required this.waktuPinjam,
    this.waktuKembali,
  });

  bool get masihDipinjam => waktuKembali == null;

  // Urutan hasil ambilData:
  // [0] namaAlat, [1] kodePeminjam, [2] wallet, [3] waktuPinjam, [4] waktuKembali
  factory Peminjaman.fromResult(int id, List<dynamic> r) {
    DateTime dariDetik(BigInt detik) =>
        DateTime.fromMillisecondsSinceEpoch(detik.toInt() * 1000);

    final kode = (r[1] as List<int>)
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
    final kembali = r[4] as BigInt;

    return Peminjaman(
      id: id,
      namaAlat: r[0] as String,
      kodePeminjam: '0x$kode',
      wallet: (r[2] as EthereumAddress).eip55With0x,
      waktuPinjam: dariDetik(r[3] as BigInt),
      waktuKembali: kembali == BigInt.zero ? null : dariDetik(kembali),
    );
  }
}
