/// =============================================================================
/// KALKULATOR FARAID - SISTEM PERHITUNGAN WARIS ISLAM LENGKAP
/// =============================================================================
/// Referensi Utama:
/// - Al-Quran: QS. An-Nisa ayat 11, 12, 176
/// - Hadits: HR. Bukhari, Muslim, Abu Dawud, Tirmidzi
/// - Kitab: Fiqh Mawaris (Ilmu Faraidh)
/// =============================================================================

import '../model/ahli_waris.dart';

/// =============================================================================
/// BAGIAN 1: DZAWIL FURUDH - 15+ KATEGORI AHLI WARIS DENGAN BAGIAN TETAP
/// =============================================================================
/// 
/// Dzawil Furudh adalah ahli waris yang mendapat bagian tetap (fardh) dari harta
/// warisan. Ada 15 kategori utama:
/// 
/// 1. Suami (الزوج) - 1/2 atau 1/4
/// 2. Istri (الزوجة) - 1/4 atau 1/8
/// 3. Ayah (الأب) - 1/6 + sisa, atau 1/6, atau sisa saja
/// 4. Ibu (الأم) - 1/6 atau 1/3 atau 1/3 sisa (Gharrawain)
/// 5. Kakek Shahih (الجد الصحيح) - seperti ayah jika ayah tidak ada
/// 6. Nenek Shahihah (الجدة الصحيحة) - 1/6
/// 7. Anak Perempuan (البنت) - 1/2 atau 2/3 atau ashabah
/// 8. Cucu Perempuan dari Anak Laki (بنت الابن) - 1/2 atau 2/3 atau 1/6 atau ashabah
/// 9. Saudara Perempuan Sekandung (الأخت الشقيقة) - 1/2 atau 2/3 atau ashabah
/// 10. Saudara Perempuan Seayah (الأخت لأب) - 1/2 atau 2/3 atau 1/6 atau ashabah
/// 11. Saudara Laki-laki Seibu (الأخ لأم) - 1/6 atau 1/3
/// 12. Saudara Perempuan Seibu (الأخت لأم) - 1/6 atau 1/3
/// 13. Anak Laki-laki (الابن) - ashabah bi nafsihi
/// 14. Cucu Laki-laki dari Anak Laki (ابن الابن) - ashabah bi nafsihi
/// 15. Saudara Laki-laki Sekandung (الأخ الشقيق) - ashabah bi nafsihi
/// 16+ Saudara Laki-laki Seayah, Paman, Keponakan, Sepupu, dll

/// =============================================================================
/// BAGIAN 2: URUTAN ASHABAH - 12 TINGKAT
/// =============================================================================
/// 
/// Ashabah adalah ahli waris yang menerima sisa harta setelah Dzawil Furudh.
/// Urutan prioritas (dari tertinggi):
/// 
/// 1. Anak Laki-laki (الابن)
/// 2. Cucu Laki-laki dari Anak Laki-laki (ابن الابن) dan seterusnya ke bawah
/// 3. Ayah (الأب)
/// 4. Kakek Shahih (الجد الصحيح) dan seterusnya ke atas
/// 5. Saudara Laki-laki Sekandung (الأخ الشقيق)
/// 6. Saudara Laki-laki Seayah (الأخ لأب)
/// 7. Anak Laki-laki dari Saudara Laki-laki Sekandung (ابن الأخ الشقيق)
/// 8. Anak Laki-laki dari Saudara Laki-laki Seayah (ابن الأخ لأب)
/// 9. Paman Sekandung (العم الشقيق)
/// 10. Paman Seayah (العم لأب)
/// 11. Anak Laki-laki Paman Sekandung (ابن العم الشقيق)
/// 12. Anak Laki-laki Paman Seayah (ابن العم لأب)

/// =============================================================================
/// BAGIAN 3: DZAWIL ARHAM
/// =============================================================================
/// 
/// Dzawil Arham adalah kerabat yang mewarisi jika tidak ada Dzawil Furudh 
/// dan Ashabah. Contoh:
/// - Cucu dari anak perempuan
/// - Anak perempuan dari saudara
/// - Paman dari pihak ibu
/// - Bibi (saudara perempuan ayah/ibu)
/// - dll

/// Kelas utama untuk perhitungan Faraid
class KalkulatorFaraid {
  /// Urutan prioritas Ashabah (12 tingkat)
  static const List<HubunganWaris> urutanAshabah = [
    HubunganWaris.anakLaki,                        // 1. Anak laki-laki
    HubunganWaris.cucuLakiDariAnakLaki,            // 2. Cucu laki-laki dari anak laki
    HubunganWaris.ayah,                            // 3. Ayah
    HubunganWaris.kakek,                           // 4. Kakek shahih
    HubunganWaris.saudaraLakiSekandung,            // 5. Saudara laki sekandung
    HubunganWaris.saudaraLakiSeayah,               // 6. Saudara laki seayah
    HubunganWaris.keponakanLakiDariSaudaraSekandung, // 7. Keponakan dari sdr sekandung
    HubunganWaris.keponakanLakiDariSaudaraSeayah,  // 8. Keponakan dari sdr seayah
    HubunganWaris.pamanSekandung,                  // 9. Paman sekandung
    HubunganWaris.pamanSeayah,                     // 10. Paman seayah
    HubunganWaris.sepupuLakiDariPamanSekandung,    // 11. Sepupu dari paman sekandung
    HubunganWaris.sepupuLakiDariPamanSeayah,       // 12. Sepupu dari paman seayah
  ];

  /// Hitung pembagian warisan berdasarkan hukum Islam
  static HasilPerhitunganFaraid hitungWarisan({
    required List<AhliWaris> daftarAhliWaris,
    required double totalHarta,
    KewajibanPraWaris? kewajiban,
  }) {
    // 1. Kurangi kewajiban pra-waris
    final kewajibanFinal = kewajiban ?? KewajibanPraWaris();
    final hartaWaris = totalHarta - kewajibanFinal.total;

    if (hartaWaris <= 0) {
      return HasilPerhitunganFaraid(
        totalHarta: totalHarta,
        kewajiban: kewajibanFinal,
        hartaWaris: 0,
        pembagian: [],
        catatanKhusus: 'Harta tidak cukup untuk menutupi kewajiban',
      );
    }

    // 2. Analisis komposisi ahli waris
    final analisis = _analisisAhliWaris(daftarAhliWaris);
    
    // 3. Terapkan aturan hijab (penghalang)
    final ahliWarisAktif = _terapkanHijab(daftarAhliWaris, analisis);
    
    // 4. Hitung bagian Dzawil Furudh
    final pembagianFurudh = _hitungDzawilFurudh(ahliWarisAktif, analisis, hartaWaris);
    
    // 5. Hitung total bagian furudh
    double totalFurudh = pembagianFurudh.fold(0.0, (sum, h) => sum + h.bagianNominal);
    double sisaHarta = hartaWaris - totalFurudh;
    
    // 6. Hitung bagian Ashabah
    final pembagianAshabah = _hitungAshabah(ahliWarisAktif, analisis, sisaHarta, hartaWaris);
    
    // 7. Gabungkan hasil
    List<HasilBagianWaris> semuaPembagian = [...pembagianFurudh, ...pembagianAshabah];
    
    // 8. Cek Aul (jika total > 100%)
    double totalPersentase = semuaPembagian.fold(0.0, (sum, h) => sum + h.persentase);
    bool terjadiAul = totalPersentase > 100.0;
    
    if (terjadiAul) {
      semuaPembagian = _terapkanAul(semuaPembagian, hartaWaris);
    }
    
    // 9. Cek Radd (jika ada sisa dan tidak ada ashabah)
    double totalBagian = semuaPembagian.fold(0.0, (sum, h) => sum + h.bagianNominal);
    double sisaRadd = hartaWaris - totalBagian;
    bool terjadiRadd = sisaRadd > 0 && pembagianAshabah.isEmpty;
    
    if (terjadiRadd) {
      semuaPembagian = _terapkanRadd(semuaPembagian, sisaRadd, hartaWaris, analisis);
    }
    
    // 10. Cek kasus khusus Gharrawain
    bool kasusGharrawain = _cekGharrawain(analisis);
    
    return HasilPerhitunganFaraid(
      totalHarta: totalHarta,
      kewajiban: kewajibanFinal,
      hartaWaris: hartaWaris,
      pembagian: semuaPembagian,
      terjadiAul: terjadiAul,
      terjadiRadd: terjadiRadd,
      sisaRadd: terjadiRadd ? sisaRadd : null,
      kasusGharrawain: kasusGharrawain,
    );
  }

  /// Analisis komposisi ahli waris
  static _AnalisisAhliWaris _analisisAhliWaris(List<AhliWaris> daftar) {
    return _AnalisisAhliWaris(
      adaSuami: daftar.any((w) => w.hubungan == HubunganWaris.suami),
      adaIstri: daftar.any((w) => w.hubungan == HubunganWaris.istri),
      adaAyah: daftar.any((w) => w.hubungan == HubunganWaris.ayah),
      adaIbu: daftar.any((w) => w.hubungan == HubunganWaris.ibu),
      adaKakek: daftar.any((w) => w.hubungan == HubunganWaris.kakek),
      adaNenek: daftar.any((w) => w.hubungan == HubunganWaris.nenek),
      jumlahAnakLaki: daftar.where((w) => w.hubungan == HubunganWaris.anakLaki).length,
      jumlahAnakPerempuan: daftar.where((w) => w.hubungan == HubunganWaris.anakPerempuan).length,
      jumlahCucuLaki: daftar.where((w) => w.hubungan == HubunganWaris.cucuLakiDariAnakLaki).length,
      jumlahCucuPerempuan: daftar.where((w) => w.hubungan == HubunganWaris.cucuPerempuanDariAnakLaki).length,
      jumlahSaudaraLakiSekandung: daftar.where((w) => w.hubungan == HubunganWaris.saudaraLakiSekandung).length,
      jumlahSaudaraPerempuanSekandung: daftar.where((w) => w.hubungan == HubunganWaris.saudaraPerempuanSekandung).length,
      jumlahSaudaraLakiSeayah: daftar.where((w) => w.hubungan == HubunganWaris.saudaraLakiSeayah).length,
      jumlahSaudaraPerempuanSeayah: daftar.where((w) => w.hubungan == HubunganWaris.saudaraPerempuanSeayah).length,
      jumlahSaudaraLakiSeibu: daftar.where((w) => w.hubungan == HubunganWaris.saudaraLakiSeibu).length,
      jumlahSaudaraPerempuanSeibu: daftar.where((w) => w.hubungan == HubunganWaris.saudaraPerempuanSeibu).length,
      jumlahKeponakanSekandung: daftar.where((w) => w.hubungan == HubunganWaris.keponakanLakiDariSaudaraSekandung).length,
      jumlahKeponakanSeayah: daftar.where((w) => w.hubungan == HubunganWaris.keponakanLakiDariSaudaraSeayah).length,
      jumlahPamanSekandung: daftar.where((w) => w.hubungan == HubunganWaris.pamanSekandung).length,
      jumlahPamanSeayah: daftar.where((w) => w.hubungan == HubunganWaris.pamanSeayah).length,
      jumlahSepupuSekandung: daftar.where((w) => w.hubungan == HubunganWaris.sepupuLakiDariPamanSekandung).length,
      jumlahSepupuSeayah: daftar.where((w) => w.hubungan == HubunganWaris.sepupuLakiDariPamanSeayah).length,
    );
  }

  /// Terapkan aturan hijab (penghalangan)
  static List<AhliWaris> _terapkanHijab(List<AhliWaris> daftar, _AnalisisAhliWaris analisis) {
    List<AhliWaris> hasil = [];
    
    for (var waris in daftar) {
      bool terhalang = false;
      String? alasan;
      
      switch (waris.hubungan) {
        // Kakek terhalang oleh Ayah
        case HubunganWaris.kakek:
          if (analisis.adaAyah) {
            terhalang = true;
            alasan = 'Terhalang oleh Ayah';
          }
          break;
          
        // Nenek terhalang oleh Ibu
        case HubunganWaris.nenek:
          if (analisis.adaIbu) {
            terhalang = true;
            alasan = 'Terhalang oleh Ibu';
          }
          break;
          
        // Cucu terhalang oleh Anak Laki-laki
        case HubunganWaris.cucuLakiDariAnakLaki:
        case HubunganWaris.cucuPerempuanDariAnakLaki:
          if (analisis.jumlahAnakLaki > 0) {
            terhalang = true;
            alasan = 'Terhalang oleh Anak Laki-laki';
          }
          break;
          
        // Saudara sekandung terhalang oleh Ayah, Anak Laki, Cucu Laki
        case HubunganWaris.saudaraLakiSekandung:
        case HubunganWaris.saudaraPerempuanSekandung:
          if (analisis.adaAyah || analisis.jumlahAnakLaki > 0 || analisis.jumlahCucuLaki > 0) {
            terhalang = true;
            alasan = analisis.adaAyah ? 'Terhalang oleh Ayah' : 'Terhalang oleh Anak/Cucu Laki-laki';
          }
          break;
          
        // Saudara seayah terhalang oleh Ayah, Anak Laki, Cucu Laki, Saudara Laki Sekandung
        case HubunganWaris.saudaraLakiSeayah:
        case HubunganWaris.saudaraPerempuanSeayah:
          if (analisis.adaAyah || analisis.jumlahAnakLaki > 0 || analisis.jumlahCucuLaki > 0) {
            terhalang = true;
            alasan = 'Terhalang oleh Ayah/Anak/Cucu Laki-laki';
          } else if (analisis.jumlahSaudaraLakiSekandung > 0) {
            terhalang = true;
            alasan = 'Terhalang oleh Saudara Laki-laki Sekandung';
          }
          break;
          
        // Saudara seibu terhalang oleh Ayah, Kakek, Far' Warits (anak/cucu)
        case HubunganWaris.saudaraLakiSeibu:
        case HubunganWaris.saudaraPerempuanSeibu:
          if (analisis.adaAyah || analisis.adaKakek || analisis.adaFarWarits) {
            terhalang = true;
            alasan = 'Terhalang oleh Ayah/Kakek/Anak/Cucu';
          }
          break;
          
        // Keponakan terhalang oleh Ayah, Kakek, Anak, Cucu, Saudara Laki
        case HubunganWaris.keponakanLakiDariSaudaraSekandung:
          if (analisis.adaAyah || analisis.adaKakek || analisis.adaFarWarits ||
              analisis.jumlahSaudaraLakiSekandung > 0 || analisis.jumlahSaudaraLakiSeayah > 0) {
            terhalang = true;
            alasan = 'Terhalang oleh ahli waris yang lebih dekat';
          }
          break;
          
        case HubunganWaris.keponakanLakiDariSaudaraSeayah:
          if (analisis.adaAyah || analisis.adaKakek || analisis.adaFarWarits ||
              analisis.jumlahSaudaraLakiSekandung > 0 || analisis.jumlahSaudaraLakiSeayah > 0 ||
              analisis.jumlahKeponakanSekandung > 0) {
            terhalang = true;
            alasan = 'Terhalang oleh ahli waris yang lebih dekat';
          }
          break;
          
        // Paman terhalang oleh banyak ahli waris
        case HubunganWaris.pamanSekandung:
          if (analisis.adaAyah || analisis.adaKakek || analisis.adaFarWarits ||
              analisis.jumlahSaudaraLakiSekandung > 0 || analisis.jumlahSaudaraLakiSeayah > 0 ||
              analisis.jumlahKeponakanSekandung > 0 || analisis.jumlahKeponakanSeayah > 0) {
            terhalang = true;
            alasan = 'Terhalang oleh ahli waris yang lebih dekat';
          }
          break;
          
        case HubunganWaris.pamanSeayah:
          if (analisis.adaAyah || analisis.adaKakek || analisis.adaFarWarits ||
              analisis.jumlahSaudaraLakiSekandung > 0 || analisis.jumlahSaudaraLakiSeayah > 0 ||
              analisis.jumlahKeponakanSekandung > 0 || analisis.jumlahKeponakanSeayah > 0 ||
              analisis.jumlahPamanSekandung > 0) {
            terhalang = true;
            alasan = 'Terhalang oleh ahli waris yang lebih dekat';
          }
          break;
          
        // Sepupu - paling banyak yang menghalangi
        case HubunganWaris.sepupuLakiDariPamanSekandung:
        case HubunganWaris.sepupuLakiDariPamanSeayah:
          if (analisis.adaAyah || analisis.adaKakek || analisis.adaFarWarits ||
              analisis.jumlahSaudaraLakiSekandung > 0 || analisis.jumlahSaudaraLakiSeayah > 0 ||
              analisis.jumlahKeponakanSekandung > 0 || analisis.jumlahKeponakanSeayah > 0 ||
              analisis.jumlahPamanSekandung > 0 || analisis.jumlahPamanSeayah > 0) {
            terhalang = true;
            alasan = 'Terhalang oleh ahli waris yang lebih dekat';
          }
          break;
          
        default:
          break;
      }
      
      if (!terhalang) {
        hasil.add(waris);
      }
    }
    
    return hasil;
  }

  /// Hitung bagian Dzawil Furudh (15+ kategori)
  static List<HasilBagianWaris> _hitungDzawilFurudh(
    List<AhliWaris> ahliWaris,
    _AnalisisAhliWaris analisis,
    double hartaWaris,
  ) {
    List<HasilBagianWaris> hasil = [];
    
    for (var waris in ahliWaris) {
      Pecahan? bagian;
      String keterangan = '';
      String dalil = '';
      String penjelasan = '';
      
      switch (waris.hubungan) {
        // === 1. SUAMI ===
        case HubunganWaris.suami:
          if (analisis.adaFarWarits) {
            bagian = Pecahan.seperempat; // 1/4
            keterangan = '1/4 (ada anak/cucu)';
            dalil = 'QS. An-Nisa: 12';
            penjelasan = 'Suami mendapat 1/4 jika pewaris memiliki anak atau cucu dari anak laki-laki';
          } else {
            bagian = Pecahan.setengah; // 1/2
            keterangan = '1/2 (tidak ada anak/cucu)';
            dalil = 'QS. An-Nisa: 12';
            penjelasan = 'Suami mendapat 1/2 jika pewaris tidak memiliki anak atau cucu';
          }
          break;
          
        // === 2. ISTRI ===
        case HubunganWaris.istri:
          if (analisis.adaFarWarits) {
            bagian = Pecahan.seperdelapan; // 1/8
            keterangan = '1/8 (ada anak/cucu)';
            dalil = 'QS. An-Nisa: 12';
            penjelasan = 'Istri mendapat 1/8 jika pewaris memiliki anak atau cucu dari anak laki-laki';
          } else {
            bagian = Pecahan.seperempat; // 1/4
            keterangan = '1/4 (tidak ada anak/cucu)';
            dalil = 'QS. An-Nisa: 12';
            penjelasan = 'Istri mendapat 1/4 jika pewaris tidak memiliki anak atau cucu';
          }
          break;
          
        // === 3. AYAH ===
        case HubunganWaris.ayah:
          if (analisis.adaFarWarits) {
            bagian = Pecahan.seperenam; // 1/6
            keterangan = '1/6 (ada anak/cucu)';
            dalil = 'QS. An-Nisa: 11';
            penjelasan = 'Ayah mendapat 1/6 jika pewaris memiliki anak atau cucu, sisanya sebagai ashabah';
          }
          // Jika tidak ada far' warits, ayah sebagai ashabah (diproses di bagian ashabah)
          break;
          
        // === 4. IBU ===
        case HubunganWaris.ibu:
          if (analisis.adaFarWarits || analisis.jumlahSaudaraSeibu >= 2 || analisis.jumlahSaudaraSekandung >= 2) {
            bagian = Pecahan.seperenam; // 1/6
            keterangan = '1/6 (ada anak/cucu atau 2+ saudara)';
            dalil = 'QS. An-Nisa: 11';
            penjelasan = 'Ibu mendapat 1/6 jika pewaris memiliki anak, cucu, atau 2 saudara atau lebih';
          } else {
            // Cek kasus Gharrawain
            if (_cekGharrawain(analisis)) {
              // Ibu dapat 1/3 dari sisa setelah suami/istri
              bagian = Pecahan.sepertiga;
              keterangan = '1/3 sisa (kasus Gharrawain)';
              dalil = 'Ijma Sahabat';
              penjelasan = 'Kasus Gharrawain: Ibu mendapat 1/3 dari sisa setelah bagian suami/istri';
            } else {
              bagian = Pecahan.sepertiga; // 1/3
              keterangan = '1/3 (tidak ada anak/cucu dan kurang dari 2 saudara)';
              dalil = 'QS. An-Nisa: 11';
              penjelasan = 'Ibu mendapat 1/3 jika tidak ada anak, cucu, dan kurang dari 2 saudara';
            }
          }
          break;
          
        // === 5. KAKEK (jika tidak ada Ayah) ===
        case HubunganWaris.kakek:
          if (analisis.adaFarWarits) {
            bagian = Pecahan.seperenam; // 1/6
            keterangan = '1/6 (ada anak/cucu, menggantikan ayah)';
            dalil = 'Ijma Ulama';
            penjelasan = 'Kakek menggantikan posisi ayah jika ayah tidak ada, mendapat 1/6 jika ada far\' warits';
          }
          break;
          
        // === 6. NENEK ===
        case HubunganWaris.nenek:
          bagian = Pecahan.seperenam; // 1/6
          keterangan = '1/6';
          dalil = 'HR. Abu Dawud, Tirmidzi';
          penjelasan = 'Nenek mendapat 1/6, dibagi rata jika lebih dari satu';
          break;
          
        // === 7. ANAK PEREMPUAN ===
        case HubunganWaris.anakPerempuan:
          if (analisis.jumlahAnakLaki == 0) {
            if (analisis.jumlahAnakPerempuan == 1) {
              bagian = Pecahan.setengah; // 1/2
              keterangan = '1/2 (anak perempuan tunggal)';
              dalil = 'QS. An-Nisa: 11';
              penjelasan = 'Anak perempuan tunggal mendapat 1/2';
            } else {
              bagian = Pecahan.duaPerTiga; // 2/3 dibagi bersama
              keterangan = '2/3 dibagi bersama';
              dalil = 'QS. An-Nisa: 11';
              penjelasan = '2 anak perempuan atau lebih mendapat 2/3 dibagi rata';
            }
          }
          // Jika ada anak laki-laki, menjadi ashabah bil ghair
          break;
          
        // === 8. CUCU PEREMPUAN DARI ANAK LAKI ===
        case HubunganWaris.cucuPerempuanDariAnakLaki:
          if (analisis.jumlahAnakLaki == 0 && analisis.jumlahCucuLaki == 0) {
            if (analisis.jumlahAnakPerempuan == 0) {
              if (analisis.jumlahCucuPerempuan == 1) {
                bagian = Pecahan.setengah;
                keterangan = '1/2 (cucu perempuan tunggal)';
              } else {
                bagian = Pecahan.duaPerTiga;
                keterangan = '2/3 dibagi bersama';
              }
            } else if (analisis.jumlahAnakPerempuan == 1) {
              bagian = Pecahan.seperenam; // 1/6 penyempurna 2/3
              keterangan = '1/6 (penyempurna 2/3)';
            }
            dalil = 'HR. Bukhari';
            penjelasan = 'Cucu perempuan mendapat bagian sebagai pengganti anak perempuan';
          }
          break;
          
        // === 9. SAUDARA PEREMPUAN SEKANDUNG ===
        case HubunganWaris.saudaraPerempuanSekandung:
          if (!analisis.adaFarWarits && !analisis.adaAyah && !analisis.adaKakek) {
            if (analisis.jumlahSaudaraLakiSekandung == 0) {
              if (analisis.jumlahSaudaraPerempuanSekandung == 1) {
                bagian = Pecahan.setengah;
                keterangan = '1/2 (saudara perempuan sekandung tunggal)';
              } else {
                bagian = Pecahan.duaPerTiga;
                keterangan = '2/3 dibagi bersama';
              }
              dalil = 'QS. An-Nisa: 176';
              penjelasan = 'Saudara perempuan sekandung mendapat bagian seperti anak perempuan jika tidak ada far\' warits';
            }
          }
          break;
          
        // === 10. SAUDARA PEREMPUAN SEAYAH ===
        case HubunganWaris.saudaraPerempuanSeayah:
          if (!analisis.adaFarWarits && !analisis.adaAyah && !analisis.adaKakek &&
              analisis.jumlahSaudaraLakiSekandung == 0) {
            if (analisis.jumlahSaudaraPerempuanSekandung == 0 && analisis.jumlahSaudaraLakiSeayah == 0) {
              if (analisis.jumlahSaudaraPerempuanSeayah == 1) {
                bagian = Pecahan.setengah;
                keterangan = '1/2 (saudara perempuan seayah tunggal)';
              } else {
                bagian = Pecahan.duaPerTiga;
                keterangan = '2/3 dibagi bersama';
              }
            } else if (analisis.jumlahSaudaraPerempuanSekandung == 1) {
              bagian = Pecahan.seperenam;
              keterangan = '1/6 (penyempurna 2/3)';
            }
            dalil = 'Qiyas pada anak perempuan';
            penjelasan = 'Saudara perempuan seayah mendapat bagian seperti saudara sekandung jika tidak ada';
          }
          break;
          
        // === 11 & 12. SAUDARA SEIBU (LAKI & PEREMPUAN) ===
        case HubunganWaris.saudaraLakiSeibu:
        case HubunganWaris.saudaraPerempuanSeibu:
          if (!analisis.adaFarWarits && !analisis.adaAyah && !analisis.adaKakek) {
            if (analisis.jumlahSaudaraSeibu == 1) {
              bagian = Pecahan.seperenam;
              keterangan = '1/6 (saudara seibu tunggal)';
            } else {
              bagian = Pecahan.sepertiga;
              keterangan = '1/3 dibagi rata';
            }
            dalil = 'QS. An-Nisa: 12';
            penjelasan = 'Saudara seibu mendapat bagian sama rata tanpa memandang jenis kelamin';
          }
          break;
          
        default:
          // Ahli waris lain akan diproses sebagai ashabah
          break;
      }
      
      if (bagian != null) {
        double nominal = hartaWaris * bagian.desimal;
        double persentase = bagian.desimal * 100;
        
        // Untuk bagian yang dibagi (seperti 2/3 untuk beberapa anak perempuan)
        if (waris.hubungan == HubunganWaris.anakPerempuan && 
            analisis.jumlahAnakPerempuan > 1 && analisis.jumlahAnakLaki == 0) {
          nominal = nominal / analisis.jumlahAnakPerempuan;
          persentase = persentase / analisis.jumlahAnakPerempuan;
        }
        
        hasil.add(HasilBagianWaris(
          ahliWaris: waris,
          bagianNominal: nominal,
          bagianPecahan: bagian,
          persentase: persentase,
          keterangan: keterangan,
          dalil: dalil,
          penjelasan: penjelasan,
        ));
      }
    }
    
    return hasil;
  }

  /// Hitung bagian Ashabah (12 tingkat prioritas)
  static List<HasilBagianWaris> _hitungAshabah(
    List<AhliWaris> ahliWaris,
    _AnalisisAhliWaris analisis,
    double sisaHarta,
    double totalHarta,
  ) {
    List<HasilBagianWaris> hasil = [];
    
    if (sisaHarta <= 0) return hasil;
    
    // Cari ashabah bi nafsihi berdasarkan urutan prioritas
    HubunganWaris? ashabahTerpilih;
    List<AhliWaris> penerimaAshabah = [];
    
    for (var urutan in urutanAshabah) {
      var kandidat = ahliWaris.where((w) => w.hubungan == urutan).toList();
      if (kandidat.isNotEmpty) {
        ashabahTerpilih = urutan;
        penerimaAshabah = kandidat;
        break;
      }
    }
    
    // Proses Ashabah bil Ghair (perempuan yang menjadi ashabah karena ada laki-laki)
    if (analisis.jumlahAnakLaki > 0) {
      // Anak perempuan menjadi ashabah bil ghair
      var anakPerempuan = ahliWaris.where((w) => w.hubungan == HubunganWaris.anakPerempuan).toList();
      var anakLaki = ahliWaris.where((w) => w.hubungan == HubunganWaris.anakLaki).toList();
      
      if (anakPerempuan.isNotEmpty || anakLaki.isNotEmpty) {
        // Hitung dengan rasio 2:1
        int totalBagian = (analisis.jumlahAnakLaki * 2) + analisis.jumlahAnakPerempuan;
        double nilaiPerBagian = sisaHarta / totalBagian;
        
        for (var anak in anakLaki) {
          hasil.add(HasilBagianWaris(
            ahliWaris: anak,
            bagianNominal: nilaiPerBagian * 2,
            persentase: (nilaiPerBagian * 2 / totalHarta) * 100,
            keterangan: 'Ashabah bi nafsihi (2 bagian)',
            dalil: 'QS. An-Nisa: 11',
            penjelasan: 'Anak laki-laki sebagai ashabah mendapat 2x bagian anak perempuan',
            jenisAshabah: JenisAshabah.biNafsihi,
          ));
        }
        
        for (var anak in anakPerempuan) {
          hasil.add(HasilBagianWaris(
            ahliWaris: anak,
            bagianNominal: nilaiPerBagian,
            persentase: (nilaiPerBagian / totalHarta) * 100,
            keterangan: 'Ashabah bil ghair (1 bagian)',
            dalil: 'QS. An-Nisa: 11',
            penjelasan: 'Anak perempuan menjadi ashabah karena ada anak laki-laki',
            jenisAshabah: JenisAshabah.bilGhair,
          ));
        }
        
        return hasil;
      }
    }
    
    // Proses Ashabah ma\'al Ghair (saudara perempuan dengan anak perempuan)
    if (analisis.jumlahAnakPerempuan > 0 && analisis.jumlahAnakLaki == 0 &&
        (analisis.jumlahSaudaraPerempuanSekandung > 0 || analisis.jumlahSaudaraPerempuanSeayah > 0)) {
      var saudariSekandung = ahliWaris.where((w) => w.hubungan == HubunganWaris.saudaraPerempuanSekandung).toList();
      var saudariSeayah = ahliWaris.where((w) => w.hubungan == HubunganWaris.saudaraPerempuanSeayah).toList();
      
      List<AhliWaris> saudariAshabah = saudariSekandung.isNotEmpty ? saudariSekandung : saudariSeayah;
      
      if (saudariAshabah.isNotEmpty) {
        double bagianPerOrang = sisaHarta / saudariAshabah.length;
        
        for (var saudari in saudariAshabah) {
          hasil.add(HasilBagianWaris(
            ahliWaris: saudari,
            bagianNominal: bagianPerOrang,
            persentase: (bagianPerOrang / totalHarta) * 100,
            keterangan: 'Ashabah ma\'al ghair',
            dalil: 'HR. Bukhari',
            penjelasan: 'Saudari menjadi ashabah karena bersama anak perempuan',
            jenisAshabah: JenisAshabah.maAlGhair,
          ));
        }
        
        return hasil;
      }
    }
    
    // Proses Ashabah bi nafsihi biasa
    if (penerimaAshabah.isNotEmpty) {
      double bagianPerOrang = sisaHarta / penerimaAshabah.length;
      
      for (var waris in penerimaAshabah) {
        hasil.add(HasilBagianWaris(
          ahliWaris: waris,
          bagianNominal: bagianPerOrang,
          persentase: (bagianPerOrang / totalHarta) * 100,
          keterangan: 'Ashabah bi nafsihi',
          dalil: 'HR. Bukhari Muslim',
          penjelasan: '${waris.hubungan.namaIndonesia} sebagai ashabah menerima sisa harta',
          jenisAshabah: JenisAshabah.biNafsihi,
        ));
      }
    }
    
    return hasil;
  }

  /// Terapkan Aul (pengurangan proporsional jika total > 100%)
  static List<HasilBagianWaris> _terapkanAul(List<HasilBagianWaris> pembagian, double hartaWaris) {
    double totalBagian = pembagian.fold(0.0, (sum, h) => sum + h.bagianNominal);
    double faktorAul = hartaWaris / totalBagian;
    
    return pembagian.map((h) {
      double bagianBaru = h.bagianNominal * faktorAul;
      return HasilBagianWaris(
        ahliWaris: h.ahliWaris,
        bagianNominal: bagianBaru,
        bagianPecahan: h.bagianPecahan,
        persentase: (bagianBaru / hartaWaris) * 100,
        keterangan: '${h.keterangan} (setelah Aul)',
        dalil: h.dalil,
        penjelasan: '${h.penjelasan}. Terjadi Aul: bagian dikurangi proporsional.',
        terhalang: h.terhalang,
        alasanTerhalang: h.alasanTerhalang,
        jenisAshabah: h.jenisAshabah,
      );
    }).toList();
  }

  /// Terapkan Radd (redistribusi sisa ke Dzawil Furudh kecuali suami/istri)
  static List<HasilBagianWaris> _terapkanRadd(
    List<HasilBagianWaris> pembagian,
    double sisaRadd,
    double hartaWaris,
    _AnalisisAhliWaris analisis,
  ) {
    // Radd tidak berlaku untuk suami/istri
    var penerimaRadd = pembagian.where((h) =>
      h.ahliWaris.hubungan != HubunganWaris.suami &&
      h.ahliWaris.hubungan != HubunganWaris.istri
    ).toList();
    
    if (penerimaRadd.isEmpty) return pembagian;
    
    double totalBagianRadd = penerimaRadd.fold(0.0, (sum, h) => sum + h.bagianNominal);
    
    return pembagian.map((h) {
      if (h.ahliWaris.hubungan == HubunganWaris.suami ||
          h.ahliWaris.hubungan == HubunganWaris.istri) {
        return h;
      }
      
      double proporsi = h.bagianNominal / totalBagianRadd;
      double tambahanRadd = sisaRadd * proporsi;
      double bagianBaru = h.bagianNominal + tambahanRadd;
      
      return HasilBagianWaris(
        ahliWaris: h.ahliWaris,
        bagianNominal: bagianBaru,
        bagianPecahan: h.bagianPecahan,
        persentase: (bagianBaru / hartaWaris) * 100,
        keterangan: '${h.keterangan} + Radd',
        dalil: h.dalil,
        penjelasan: '${h.penjelasan}. Mendapat tambahan dari Radd.',
        terhalang: h.terhalang,
        alasanTerhalang: h.alasanTerhalang,
        jenisAshabah: h.jenisAshabah,
      );
    }).toList();
  }

  /// Cek apakah terjadi kasus Gharrawain
  static bool _cekGharrawain(_AnalisisAhliWaris analisis) {
    // Gharrawain: Suami/Istri + Ayah + Ibu, tanpa anak dan tanpa 2+ saudara
    return (analisis.adaSuami || analisis.adaIstri) &&
           analisis.adaAyah &&
           analisis.adaIbu &&
           !analisis.adaFarWarits &&
           analisis.jumlahSaudaraSekandung < 2 &&
           analisis.jumlahSaudaraSeibu < 2;
  }
}

/// Kelas helper untuk analisis komposisi ahli waris
class _AnalisisAhliWaris {
  final bool adaSuami;
  final bool adaIstri;
  final bool adaAyah;
  final bool adaIbu;
  final bool adaKakek;
  final bool adaNenek;
  final int jumlahAnakLaki;
  final int jumlahAnakPerempuan;
  final int jumlahCucuLaki;
  final int jumlahCucuPerempuan;
  final int jumlahSaudaraLakiSekandung;
  final int jumlahSaudaraPerempuanSekandung;
  final int jumlahSaudaraLakiSeayah;
  final int jumlahSaudaraPerempuanSeayah;
  final int jumlahSaudaraLakiSeibu;
  final int jumlahSaudaraPerempuanSeibu;
  final int jumlahKeponakanSekandung;
  final int jumlahKeponakanSeayah;
  final int jumlahPamanSekandung;
  final int jumlahPamanSeayah;
  final int jumlahSepupuSekandung;
  final int jumlahSepupuSeayah;

  _AnalisisAhliWaris({
    required this.adaSuami,
    required this.adaIstri,
    required this.adaAyah,
    required this.adaIbu,
    required this.adaKakek,
    required this.adaNenek,
    required this.jumlahAnakLaki,
    required this.jumlahAnakPerempuan,
    required this.jumlahCucuLaki,
    required this.jumlahCucuPerempuan,
    required this.jumlahSaudaraLakiSekandung,
    required this.jumlahSaudaraPerempuanSekandung,
    required this.jumlahSaudaraLakiSeayah,
    required this.jumlahSaudaraPerempuanSeayah,
    required this.jumlahSaudaraLakiSeibu,
    required this.jumlahSaudaraPerempuanSeibu,
    required this.jumlahKeponakanSekandung,
    required this.jumlahKeponakanSeayah,
    required this.jumlahPamanSekandung,
    required this.jumlahPamanSeayah,
    required this.jumlahSepupuSekandung,
    required this.jumlahSepupuSeayah,
  });

  /// Ada Far' Warits (keturunan yang mewarisi)
  bool get adaFarWarits =>
      jumlahAnakLaki > 0 || jumlahAnakPerempuan > 0 ||
      jumlahCucuLaki > 0 || jumlahCucuPerempuan > 0;

  /// Total saudara sekandung
  int get jumlahSaudaraSekandung =>
      jumlahSaudaraLakiSekandung + jumlahSaudaraPerempuanSekandung;

  /// Total saudara seibu
  int get jumlahSaudaraSeibu =>
      jumlahSaudaraLakiSeibu + jumlahSaudaraPerempuanSeibu;
}
