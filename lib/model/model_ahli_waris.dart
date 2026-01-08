class ModelAhliWaris {
  final String id;
  final String nikPewaris;
  final String namaLengkap;
  final String hubungan;
  final String jenisKelamin;
  final DateTime tanggalDibuat;

  ModelAhliWaris({
    required this.id,
    required this.nikPewaris,
    required this.namaLengkap,
    required this.hubungan,
    required this.jenisKelamin,
    required this.tanggalDibuat,
  });

  // Factory constructor untuk membuat object dari JSON
  factory ModelAhliWaris.dariJson(Map<String, dynamic> json) {
    return ModelAhliWaris(
      id: json['id'].toString(),
      nikPewaris: json['nik_pewaris'] ?? '',
      namaLengkap: json['nama_lengkap'] ?? '',
      hubungan: json['hubungan'] ?? '',
      jenisKelamin: json['jenis_kelamin'] ?? '',
      tanggalDibuat:
          DateTime.parse(json['tanggal_dibuat'] ?? DateTime.now().toString()),
    );
  }

  // Method untuk convert object ke JSON
  Map<String, dynamic> keJson() {
    return {
      'id': id,
      'nik_pewaris': nikPewaris,
      'nama_lengkap': namaLengkap,
      'hubungan': hubungan,
      'jenis_kelamin': jenisKelamin,
      'tanggal_dibuat': tanggalDibuat.toIso8601String(),
    };
  }

  // Method untuk mendapatkan label hubungan dalam bahasa Indonesia
  String dapatkanLabelHubungan() {
    switch (hubungan) {
      case 'istri':
        return 'Istri';
      case 'suami':
        return 'Suami';
      case 'anak_laki':
        return 'Anak Laki-laki';
      case 'anak_perempuan':
        return 'Anak Perempuan';
      case 'ayah':
        return 'Ayah';
      case 'ibu':
        return 'Ibu';
      case 'saudara_laki':
        return 'Saudara Laki-laki';
      case 'saudara_perempuan':
        return 'Saudara Perempuan';
      default:
        return 'Lainnya';
    }
  }

  // Copy with method untuk immutability
  ModelAhliWaris salin({
    String? id,
    String? nikPewaris,
    String? namaLengkap,
    String? hubungan,
    String? jenisKelamin,
    DateTime? tanggalDibuat,
  }) {
    return ModelAhliWaris(
      id: id ?? this.id,
      nikPewaris: nikPewaris ?? this.nikPewaris,
      namaLengkap: namaLengkap ?? this.namaLengkap,
      hubungan: hubungan ?? this.hubungan,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      tanggalDibuat: tanggalDibuat ?? this.tanggalDibuat,
    );
  }

  @override
  String toString() {
    return 'ModelAhliWaris(id: $id, nama: $namaLengkap, hubungan: $hubungan)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ModelAhliWaris && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
