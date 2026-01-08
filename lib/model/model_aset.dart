class ModelAset {
  final String id;
  final String nikPewaris;
  final String idPengusul;
  final String namaPengusul;
  final String namaAset;
  final String jenisAset;
  final double nilai;
  final String? keterangan;
  final String? file1;
  final String? file2;
  final String? file3;
  final String statusVerifikasi;
  final int jumlahVerifikasi;
  final int jumlahPenolakan;
  final DateTime tanggalDibuat;
  final DateTime tanggalUpdate;

  ModelAset({
    required this.id,
    required this.nikPewaris,
    required this.idPengusul,
    required this.namaPengusul,
    required this.namaAset,
    required this.jenisAset,
    required this.nilai,
    this.keterangan,
    this.file1,
    this.file2,
    this.file3,
    required this.statusVerifikasi,
    required this.jumlahVerifikasi,
    required this.jumlahPenolakan,
    required this.tanggalDibuat,
    required this.tanggalUpdate,
  });

  // Factory constructor untuk membuat object dari JSON
  factory ModelAset.dariJson(Map<String, dynamic> json) {
    return ModelAset(
      id: json['id'].toString(),
      nikPewaris: json['nik_pewaris'] ?? '',
      idPengusul: json['id_pengusul'].toString(),
      namaPengusul: json['nama_pengusul'] ?? 'Unknown',
      namaAset: json['nama_aset'] ?? '',
      jenisAset: json['jenis_aset'] ?? '',
      nilai: double.parse(json['nilai'].toString()),
      keterangan: json['keterangan'],
      file1: json['file_1'],
      file2: json['file_2'],
      file3: json['file_3'],
      statusVerifikasi: json['status_verifikasi'] ?? 'menunggu',
      jumlahVerifikasi: int.parse(json['jumlah_verifikasi']?.toString() ?? '0'),
      jumlahPenolakan: int.parse(json['jumlah_penolakan']?.toString() ?? '0'),
      tanggalDibuat:
          DateTime.parse(json['tanggal_dibuat'] ?? DateTime.now().toString()),
      tanggalUpdate:
          DateTime.parse(json['tanggal_update'] ?? DateTime.now().toString()),
    );
  }

  // Method untuk convert object ke JSON
  Map<String, dynamic> keJson() {
    return {
      'id': id,
      'nik_pewaris': nikPewaris,
      'id_pengusul': idPengusul,
      'nama_pengusul': namaPengusul,
      'nama_aset': namaAset,
      'jenis_aset': jenisAset,
      'nilai': nilai,
      'keterangan': keterangan,
      'file_1': file1,
      'file_2': file2,
      'file_3': file3,
      'status_verifikasi': statusVerifikasi,
      'jumlah_verifikasi': jumlahVerifikasi,
      'jumlah_penolakan': jumlahPenolakan,
      'tanggal_dibuat': tanggalDibuat.toIso8601String(),
      'tanggal_update': tanggalUpdate.toIso8601String(),
    };
  }

  // Method untuk mendapatkan label jenis aset
  String dapatkanLabelJenisAset() {
    switch (jenisAset) {
      case 'tanah':
        return 'Tanah';
      case 'rumah':
        return 'Rumah';
      case 'kendaraan':
        return 'Kendaraan';
      case 'tabungan':
        return 'Tabungan';
      case 'emas':
        return 'Emas/Perhiasan';
      case 'saham':
        return 'Saham/Investasi';
      default:
        return 'Lainnya';
    }
  }

  // Method untuk mendapatkan label status
  String dapatkanLabelStatus() {
    switch (statusVerifikasi) {
      case 'disetujui':
        return 'Disetujui';
      case 'ditolak':
        return 'Ditolak';
      default:
        return 'Menunggu Verifikasi';
    }
  }

  // Method untuk cek apakah sudah disetujui
  bool get sudahDisetujui => statusVerifikasi == 'disetujui';

  // Method untuk cek apakah ditolak
  bool get ditolak => statusVerifikasi == 'ditolak';

  // Method untuk cek apakah menunggu
  bool get menunggu => statusVerifikasi == 'menunggu';

  // Method untuk mendapatkan daftar file yang ada
  List<String> dapatkanDaftarFile() {
    List<String> files = [];
    if (file1 != null && file1!.isNotEmpty) files.add(file1!);
    if (file2 != null && file2!.isNotEmpty) files.add(file2!);
    if (file3 != null && file3!.isNotEmpty) files.add(file3!);
    return files;
  }

  // Copy with method untuk immutability
  ModelAset salin({
    String? id,
    String? nikPewaris,
    String? idPengusul,
    String? namaPengusul,
    String? namaAset,
    String? jenisAset,
    double? nilai,
    String? keterangan,
    String? file1,
    String? file2,
    String? file3,
    String? statusVerifikasi,
    int? jumlahVerifikasi,
    int? jumlahPenolakan,
    DateTime? tanggalDibuat,
    DateTime? tanggalUpdate,
  }) {
    return ModelAset(
      id: id ?? this.id,
      nikPewaris: nikPewaris ?? this.nikPewaris,
      idPengusul: idPengusul ?? this.idPengusul,
      namaPengusul: namaPengusul ?? this.namaPengusul,
      namaAset: namaAset ?? this.namaAset,
      jenisAset: jenisAset ?? this.jenisAset,
      nilai: nilai ?? this.nilai,
      keterangan: keterangan ?? this.keterangan,
      file1: file1 ?? this.file1,
      file2: file2 ?? this.file2,
      file3: file3 ?? this.file3,
      statusVerifikasi: statusVerifikasi ?? this.statusVerifikasi,
      jumlahVerifikasi: jumlahVerifikasi ?? this.jumlahVerifikasi,
      jumlahPenolakan: jumlahPenolakan ?? this.jumlahPenolakan,
      tanggalDibuat: tanggalDibuat ?? this.tanggalDibuat,
      tanggalUpdate: tanggalUpdate ?? this.tanggalUpdate,
    );
  }

  @override
  String toString() {
    return 'ModelAset(id: $id, nama: $namaAset, nilai: $nilai, status: $statusVerifikasi)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ModelAset && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
