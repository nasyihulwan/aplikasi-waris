/// =============================================================================
/// MODEL AHLI WARIS - SISTEM PERHITUNGAN WARIS ISLAM (FARAID)
/// =============================================================================
/// Referensi Utama:
/// - Al-Quran: QS. An-Nisa ayat 11, 12, 176
/// - Hadits: HR. Bukhari, Muslim, Abu Dawud, Tirmidzi
/// - Kitab: Fiqh Mawaris (Ilmu Faraidh)
/// =============================================================================

/// Enum untuk jenis hubungan ahli waris
enum HubunganWaris {
  // === PASANGAN ===
  suami,
  istri,

  // === ORANG TUA ===
  ayah,
  ibu,

  // === KAKEK/NENEK ===
  kakek, // dari pihak ayah
  nenek, // bisa dari ayah atau ibu

  // === ANAK ===
  anakLaki,
  anakPerempuan,

  // === CUCU (dari anak laki-laki) ===
  cucuLakiDariAnakLaki,
  cucuPerempuanDariAnakLaki,

  // === SAUDARA SEKANDUNG (seibu seayah) ===
  saudaraLakiSekandung,
  saudaraPerempuanSekandung,

  // === SAUDARA SEAYAH ===
  saudaraLakiSeayah,
  saudaraPerempuanSeayah,

  // === SAUDARA SEIBU ===
  saudaraLakiSeibu,
  saudaraPerempuanSeibu,

  // === KEPONAKAN (anak saudara laki-laki) ===
  keponakanLakiDariSaudaraSekandung,
  keponakanLakiDariSaudaraSeayah,

  // === PAMAN ===
  pamanSekandung, // saudara laki-laki ayah sekandung
  pamanSeayah, // saudara laki-laki ayah seayah

  // === SEPUPU (anak paman) ===
  sepupuLakiDariPamanSekandung,
  sepupuLakiDariPamanSeayah,
}

/// Extension untuk mendapatkan informasi hubungan waris
extension HubunganWarisExtension on HubunganWaris {
  /// Nama dalam Bahasa Indonesia
  String get namaIndonesia {
    switch (this) {
      case HubunganWaris.suami:
        return 'Suami';
      case HubunganWaris.istri:
        return 'Istri';
      case HubunganWaris.ayah:
        return 'Ayah';
      case HubunganWaris.ibu:
        return 'Ibu';
      case HubunganWaris.kakek:
        return 'Kakek';
      case HubunganWaris.nenek:
        return 'Nenek';
      case HubunganWaris.anakLaki:
        return 'Anak Laki-laki';
      case HubunganWaris.anakPerempuan:
        return 'Anak Perempuan';
      case HubunganWaris.cucuLakiDariAnakLaki:
        return 'Cucu Laki-laki (dari anak laki-laki)';
      case HubunganWaris.cucuPerempuanDariAnakLaki:
        return 'Cucu Perempuan (dari anak laki-laki)';
      case HubunganWaris.saudaraLakiSekandung:
        return 'Saudara Laki-laki Sekandung';
      case HubunganWaris.saudaraPerempuanSekandung:
        return 'Saudara Perempuan Sekandung';
      case HubunganWaris.saudaraLakiSeayah:
        return 'Saudara Laki-laki Seayah';
      case HubunganWaris.saudaraPerempuanSeayah:
        return 'Saudara Perempuan Seayah';
      case HubunganWaris.saudaraLakiSeibu:
        return 'Saudara Laki-laki Seibu';
      case HubunganWaris.saudaraPerempuanSeibu:
        return 'Saudara Perempuan Seibu';
      case HubunganWaris.keponakanLakiDariSaudaraSekandung:
        return 'Keponakan Laki-laki (dari saudara sekandung)';
      case HubunganWaris.keponakanLakiDariSaudaraSeayah:
        return 'Keponakan Laki-laki (dari saudara seayah)';
      case HubunganWaris.pamanSekandung:
        return 'Paman Sekandung';
      case HubunganWaris.pamanSeayah:
        return 'Paman Seayah';
      case HubunganWaris.sepupuLakiDariPamanSekandung:
        return 'Sepupu Laki-laki (dari paman sekandung)';
      case HubunganWaris.sepupuLakiDariPamanSeayah:
        return 'Sepupu Laki-laki (dari paman seayah)';
    }
  }

  /// Nama dalam Bahasa Arab
  String get namaArab {
    switch (this) {
      case HubunganWaris.suami:
        return 'الزوج';
      case HubunganWaris.istri:
        return 'الزوجة';
      case HubunganWaris.ayah:
        return 'الأب';
      case HubunganWaris.ibu:
        return 'الأم';
      case HubunganWaris.kakek:
        return 'الجد';
      case HubunganWaris.nenek:
        return 'الجدة';
      case HubunganWaris.anakLaki:
        return 'الابن';
      case HubunganWaris.anakPerempuan:
        return 'البنت';
      case HubunganWaris.cucuLakiDariAnakLaki:
        return 'ابن الابن';
      case HubunganWaris.cucuPerempuanDariAnakLaki:
        return 'بنت الابن';
      case HubunganWaris.saudaraLakiSekandung:
        return 'الأخ الشقيق';
      case HubunganWaris.saudaraPerempuanSekandung:
        return 'الأخت الشقيقة';
      case HubunganWaris.saudaraLakiSeayah:
        return 'الأخ لأب';
      case HubunganWaris.saudaraPerempuanSeayah:
        return 'الأخت لأب';
      case HubunganWaris.saudaraLakiSeibu:
        return 'الأخ لأم';
      case HubunganWaris.saudaraPerempuanSeibu:
        return 'الأخت لأم';
      case HubunganWaris.keponakanLakiDariSaudaraSekandung:
        return 'ابن الأخ الشقيق';
      case HubunganWaris.keponakanLakiDariSaudaraSeayah:
        return 'ابن الأخ لأب';
      case HubunganWaris.pamanSekandung:
        return 'العم الشقيق';
      case HubunganWaris.pamanSeayah:
        return 'العم لأب';
      case HubunganWaris.sepupuLakiDariPamanSekandung:
        return 'ابن العم الشقيق';
      case HubunganWaris.sepupuLakiDariPamanSeayah:
        return 'ابن العم لأب';
    }
  }

  /// Apakah laki-laki
  bool get isLakiLaki {
    return [
      HubunganWaris.suami,
      HubunganWaris.ayah,
      HubunganWaris.kakek,
      HubunganWaris.anakLaki,
      HubunganWaris.cucuLakiDariAnakLaki,
      HubunganWaris.saudaraLakiSekandung,
      HubunganWaris.saudaraLakiSeayah,
      HubunganWaris.saudaraLakiSeibu,
      HubunganWaris.keponakanLakiDariSaudaraSekandung,
      HubunganWaris.keponakanLakiDariSaudaraSeayah,
      HubunganWaris.pamanSekandung,
      HubunganWaris.pamanSeayah,
      HubunganWaris.sepupuLakiDariPamanSekandung,
      HubunganWaris.sepupuLakiDariPamanSeayah,
    ].contains(this);
  }

  /// Kategori ahli waris
  KategoriAhliWaris get kategori {
    switch (this) {
      // Dzawil Furudh murni
      case HubunganWaris.suami:
      case HubunganWaris.istri:
      case HubunganWaris.ibu:
      case HubunganWaris.nenek:
      case HubunganWaris.saudaraLakiSeibu:
      case HubunganWaris.saudaraPerempuanSeibu:
        return KategoriAhliWaris.dzawilFurudh;

      // Ashabah bi nafsihi (laki-laki murni)
      case HubunganWaris.anakLaki:
      case HubunganWaris.cucuLakiDariAnakLaki:
      case HubunganWaris.ayah:
      case HubunganWaris.kakek:
      case HubunganWaris.saudaraLakiSekandung:
      case HubunganWaris.saudaraLakiSeayah:
      case HubunganWaris.keponakanLakiDariSaudaraSekandung:
      case HubunganWaris.keponakanLakiDariSaudaraSeayah:
      case HubunganWaris.pamanSekandung:
      case HubunganWaris.pamanSeayah:
      case HubunganWaris.sepupuLakiDariPamanSekandung:
      case HubunganWaris.sepupuLakiDariPamanSeayah:
        return KategoriAhliWaris.ashabah;

      // Dzawil Furudh + bisa jadi Ashabah
      case HubunganWaris.anakPerempuan:
      case HubunganWaris.cucuPerempuanDariAnakLaki:
      case HubunganWaris.saudaraPerempuanSekandung:
      case HubunganWaris.saudaraPerempuanSeayah:
        return KategoriAhliWaris.dzawilFurudhDanAshabah;
    }
  }
}

/// Kategori ahli waris
enum KategoriAhliWaris {
  /// Ahli waris dengan bagian tetap (fardh)
  dzawilFurudh,

  /// Ahli waris penerima sisa (ashabah)
  ashabah,

  /// Bisa keduanya tergantung kondisi
  dzawilFurudhDanAshabah,

  /// Kerabat jauh (jika tidak ada Furudh & Ashabah)
  dzawilArham,
}

/// Jenis Ashabah
enum JenisAshabah {
  /// Ashabah karena diri sendiri (laki-laki)
  biNafsihi,

  /// Ashabah karena bersama laki-laki (perempuan + laki-laki)
  maAlGhair,

  /// Ashabah karena perempuan lain (saudara pr + anak pr)
  bilGhair,
}

/// Model untuk satu orang ahli waris
class AhliWaris {
  final String id;
  final String nama;
  final HubunganWaris hubungan;
  final String? jenisKelamin;

  AhliWaris({
    required this.id,
    required this.nama,
    required this.hubungan,
    this.jenisKelamin,
  });

  /// Buat dari Map (data dari API/database)
  factory AhliWaris.fromMap(Map<String, dynamic> map) {
    return AhliWaris(
      id: map['id']?.toString() ?? '',
      nama: map['nama_lengkap']?.toString() ?? '',
      hubungan: _parseHubungan(map['hubungan']?.toString() ?? ''),
      jenisKelamin: map['jenis_kelamin']?.toString(),
    );
  }

  /// Parse string hubungan ke enum
  static HubunganWaris _parseHubungan(String hubungan) {
    switch (hubungan.toLowerCase()) {
      case 'suami':
        return HubunganWaris.suami;
      case 'istri':
        return HubunganWaris.istri;
      case 'ayah':
        return HubunganWaris.ayah;
      case 'ibu':
        return HubunganWaris.ibu;
      case 'kakek':
        return HubunganWaris.kakek;
      case 'nenek':
        return HubunganWaris.nenek;
      case 'anak_laki':
        return HubunganWaris.anakLaki;
      case 'anak_perempuan':
        return HubunganWaris.anakPerempuan;
      case 'cucu_laki':
        return HubunganWaris.cucuLakiDariAnakLaki;
      case 'cucu_perempuan':
        return HubunganWaris.cucuPerempuanDariAnakLaki;
      case 'saudara_laki':
      case 'saudara_laki_sekandung':
        return HubunganWaris.saudaraLakiSekandung;
      case 'saudara_perempuan':
      case 'saudara_perempuan_sekandung':
        return HubunganWaris.saudaraPerempuanSekandung;
      case 'saudara_laki_seayah':
        return HubunganWaris.saudaraLakiSeayah;
      case 'saudara_perempuan_seayah':
        return HubunganWaris.saudaraPerempuanSeayah;
      case 'saudara_laki_seibu':
        return HubunganWaris.saudaraLakiSeibu;
      case 'saudara_perempuan_seibu':
        return HubunganWaris.saudaraPerempuanSeibu;
      case 'paman':
      case 'paman_sekandung':
        return HubunganWaris.pamanSekandung;
      case 'paman_seayah':
        return HubunganWaris.pamanSeayah;
      default:
        return HubunganWaris.saudaraLakiSekandung;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_lengkap': nama,
      'hubungan': hubungan.name,
      'jenis_kelamin': jenisKelamin,
    };
  }
}

/// Model untuk bagian pecahan (fraction)
class Pecahan {
  final int pembilang;
  final int penyebut;

  const Pecahan(this.pembilang, this.penyebut);

  /// Pecahan umum dalam faraid
  static const Pecahan setengah = Pecahan(1, 2);
  static const Pecahan sepertiga = Pecahan(1, 3);
  static const Pecahan seperempat = Pecahan(1, 4);
  static const Pecahan seperenam = Pecahan(1, 6);
  static const Pecahan seperdelapan = Pecahan(1, 8);
  static const Pecahan duaPerTiga = Pecahan(2, 3);
  static const Pecahan nol = Pecahan(0, 1);

  double get desimal => pembilang / penyebut;
  String get tampilan => '$pembilang/$penyebut';

  /// Sederhanakan pecahan
  Pecahan sederhanakan() {
    int gcd = _gcd(pembilang, penyebut);
    return Pecahan(pembilang ~/ gcd, penyebut ~/ gcd);
  }

  int _gcd(int a, int b) {
    while (b != 0) {
      int t = b;
      b = a % b;
      a = t;
    }
    return a;
  }

  Pecahan operator +(Pecahan other) {
    int newPenyebut = _lcm(penyebut, other.penyebut);
    int newPembilang = (pembilang * (newPenyebut ~/ penyebut)) +
        (other.pembilang * (newPenyebut ~/ other.penyebut));
    return Pecahan(newPembilang, newPenyebut).sederhanakan();
  }

  int _lcm(int a, int b) => (a * b) ~/ _gcd(a, b);

  @override
  String toString() => tampilan;
}

/// Model hasil pembagian satu ahli waris
class HasilBagianWaris {
  final AhliWaris ahliWaris;
  final double bagianNominal;
  final Pecahan? bagianPecahan;
  final double persentase;
  final String keterangan;
  final String dalil;
  final String penjelasan;
  final bool terhalang; // hijab
  final String? alasanTerhalang;
  final JenisAshabah? jenisAshabah;

  HasilBagianWaris({
    required this.ahliWaris,
    required this.bagianNominal,
    this.bagianPecahan,
    required this.persentase,
    required this.keterangan,
    required this.dalil,
    required this.penjelasan,
    this.terhalang = false,
    this.alasanTerhalang,
    this.jenisAshabah,
  });

  Map<String, dynamic> toMap() {
    return {
      'nama': ahliWaris.nama,
      'hubungan': ahliWaris.hubungan.namaIndonesia,
      'hubungan_arab': ahliWaris.hubungan.namaArab,
      'bagian': bagianNominal,
      'bagian_pecahan': bagianPecahan?.tampilan,
      'persentase': persentase,
      'keterangan': keterangan,
      'dalil': dalil,
      'penjelasan': penjelasan,
      'terhalang': terhalang,
      'alasan_terhalang': alasanTerhalang,
      'jenis_ashabah': jenisAshabah?.name,
    };
  }
}

/// Model untuk kewajiban sebelum pembagian waris
class KewajibanPraWaris {
  final double biayaJenazah;
  final double utangPewaris;
  final double wasiat;

  KewajibanPraWaris({
    this.biayaJenazah = 0,
    this.utangPewaris = 0,
    this.wasiat = 0,
  });

  double get total => biayaJenazah + utangPewaris + wasiat;

  /// Validasi wasiat tidak lebih dari 1/3
  bool validasiWasiat(double totalHarta) {
    double sisaSetelahBiayaDanUtang = totalHarta - biayaJenazah - utangPewaris;
    double maksWasiat = sisaSetelahBiayaDanUtang / 3;
    return wasiat <= maksWasiat;
  }
}

/// Model hasil perhitungan lengkap
class HasilPerhitunganFaraid {
  final double totalHarta;
  final KewajibanPraWaris kewajiban;
  final double hartaWaris; // setelah dikurangi kewajiban
  final List<HasilBagianWaris> pembagian;
  final bool terjadiAul;
  final int? asalMasalahAwal;
  final int? asalMasalahAul;
  final bool terjadiRadd;
  final double? sisaRadd;
  final bool kasusGharrawain;
  final String? catatanKhusus;
  final DateTime tanggalHitung;

  HasilPerhitunganFaraid({
    required this.totalHarta,
    required this.kewajiban,
    required this.hartaWaris,
    required this.pembagian,
    this.terjadiAul = false,
    this.asalMasalahAwal,
    this.asalMasalahAul,
    this.terjadiRadd = false,
    this.sisaRadd,
    this.kasusGharrawain = false,
    this.catatanKhusus,
    DateTime? tanggal,
  }) : tanggalHitung = tanggal ?? DateTime.now();

  /// Total bagian yang dibagikan
  double get totalBagian =>
      pembagian.fold(0.0, (sum, item) => sum + item.bagianNominal);

  /// Total persentase
  double get totalPersentase =>
      pembagian.fold(0.0, (sum, item) => sum + item.persentase);

  Map<String, dynamic> toMap() {
    return {
      'total_harta': totalHarta,
      'biaya_jenazah': kewajiban.biayaJenazah,
      'utang_pewaris': kewajiban.utangPewaris,
      'wasiat': kewajiban.wasiat,
      'harta_waris': hartaWaris,
      'pembagian': pembagian.map((p) => p.toMap()).toList(),
      'terjadi_aul': terjadiAul,
      'asal_masalah_awal': asalMasalahAwal,
      'asal_masalah_aul': asalMasalahAul,
      'terjadi_radd': terjadiRadd,
      'sisa_radd': sisaRadd,
      'kasus_gharrawain': kasusGharrawain,
      'catatan_khusus': catatanKhusus,
      'tanggal': tanggalHitung.toIso8601String(),
    };
  }
}
