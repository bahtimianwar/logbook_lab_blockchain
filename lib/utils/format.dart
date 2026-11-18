String fmtWaktu(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} '
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

String singkat(String s, [int depan = 8, int belakang = 4]) =>
    s.length <= depan + belakang
    ? s
    : '${s.substring(0, depan)}...${s.substring(s.length - belakang)}';

String fmtDurasi(Duration d) {
  if (d.inMinutes < 1) return 'kurang dari 1 menit';
  final hari = d.inDays;
  final jam = d.inHours % 24;
  final menit = d.inMinutes % 60;
  final bagian = <String>[];
  if (hari > 0) bagian.add('$hari hari');
  if (jam > 0) bagian.add('$jam jam');
  if (menit > 0 && hari == 0) bagian.add('$menit menit');
  return bagian.join(' ');
}
