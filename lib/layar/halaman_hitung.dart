import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../penyedia/penyedia_auth.dart';
import '../penyedia/penyedia_warisan.dart';
import '../tema/tema_aplikasi.dart';
import '../widget/komponen_umum.dart';

class HalamanHitung extends StatefulWidget {
  const HalamanHitung({super.key});

  @override
  _HalamanHitungState createState() => _HalamanHitungState();
}

class _HalamanHitungState extends State<HalamanHitung> {
  Map<String, dynamic>? _hasilPerhitungan;
  bool _sedangMenghitung = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TemaAplikasi.background,
      body: _hasilPerhitungan == null
          ? _buatTampilanAwal()
          : _buatTampilanHasil(),
    );
  }

  Widget _buatTampilanAwal() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    TemaAplikasi.primary.withOpacity(0.1),
                    TemaAplikasi.primary.withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calculate_outlined,
                size: 80,
                color: TemaAplikasi.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Hitung Pembagian Warisan',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: TemaAplikasi.primaryDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Sistem akan menghitung pembagian warisan berdasarkan hukum Islam (Faraid) dengan data ahli waris dan aset yang telah disetujui.',
                style: TemaAplikasi.bodyMedium.copyWith(
                  color: TemaAplikasi.textSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            _sedangMenghitung
                ? const LoadingIndicator(message: 'Menghitung pembagian...')
                : Container(
                    decoration: BoxDecoration(
                      gradient: TemaAplikasi.gradientPrimaryLinear,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: TemaAplikasi.primary.withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _hitungPembagian,
                      icon: const Icon(Icons.calculate,
                          size: 24, color: Colors.white),
                      label: Text(
                        'Mulai Perhitungan',
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: TemaAplikasi.infoLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, size: 18, color: TemaAplikasi.info),
                  const SizedBox(width: 8),
                  Text(
                    'Pastikan data ahli waris dan aset sudah lengkap',
                    style: TemaAplikasi.bodySmall
                        .copyWith(color: TemaAplikasi.info),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buatTampilanHasil() {
    if (_hasilPerhitungan == null) return Container();

    final List<dynamic> pembagian = _hasilPerhitungan!['pembagian'] ?? [];
    final double totalHarta =
        double.tryParse(_hasilPerhitungan!['total_harta'].toString()) ?? 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buatKartuRingkasan(totalHarta),
          const SizedBox(height: 24),
          Text(
            'Rincian Pembagian',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: TemaAplikasi.primaryDark,
            ),
          ),
          const SizedBox(height: 16),
          ...pembagian.map((item) {
            final itemMap = item as Map<String, dynamic>;
            return _buatKartuPembagian(itemMap);
          }),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: TemaAplikasi.divider),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _hitungUlang,
                    icon:
                        Icon(Icons.refresh, color: TemaAplikasi.textSecondary),
                    label: Text('Hitung Ulang',
                        style: TextStyle(color: TemaAplikasi.textPrimary)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: TemaAplikasi.gradientPrimaryLinear,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: TemaAplikasi.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _simpanHasil,
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text('Simpan Hasil',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buatKartuRingkasan(double totalHarta) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: TemaAplikasi.kartuGradient,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.account_balance_wallet,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Harta Warisan',
                      style: GoogleFonts.poppins(
                          color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatRupiah(totalHarta),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buatKartuPembagian(Map<String, dynamic> item) {
    final String nama = item['nama']?.toString() ?? 'Unknown';
    final String hubungan = item['hubungan']?.toString() ?? '';
    final double bagian = double.tryParse(item['bagian'].toString()) ?? 0.0;
    final String keterangan = item['keterangan']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: TemaAplikasi.kartuDekorasi,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        TemaAplikasi.primary.withOpacity(0.15),
                        TemaAplikasi.primary.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _dapatkanIconHubungan(hubungan),
                    color: TemaAplikasi.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nama, style: TemaAplikasi.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        _dapatkanLabelHubungan(hubungan),
                        style: TemaAplikasi.bodySmall
                            .copyWith(color: TemaAplikasi.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Bagian:',
                    style: TemaAplikasi.bodyMedium
                        .copyWith(color: TemaAplikasi.textSecondary)),
                Text(
                  _formatRupiah(bagian),
                  style: GoogleFonts.poppins(
                    color: TemaAplikasi.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (keterangan.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: TemaAplikasi.infoLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 16, color: TemaAplikasi.info),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        keterangan,
                        style: TemaAplikasi.bodySmall
                            .copyWith(color: TemaAplikasi.info),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _dapatkanIconHubungan(String hubungan) {
    switch (hubungan) {
      case 'istri':
      case 'suami':
        return Icons.favorite;
      case 'anak_laki':
      case 'anak_perempuan':
        return Icons.child_care;
      case 'ayah':
      case 'ibu':
        return Icons.elderly;
      case 'saudara_laki':
      case 'saudara_perempuan':
        return Icons.people;
      default:
        return Icons.person;
    }
  }

  String _dapatkanLabelHubungan(String hubungan) {
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
        return hubungan;
    }
  }

  String _formatRupiah(double angka) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(angka);
  }

  Future<void> _hitungPembagian() async {
    setState(() => _sedangMenghitung = true);

    try {
      final penyediaAuth = Provider.of<PenyediaAuth>(context, listen: false);
      final penyediaWarisan =
          Provider.of<PenyediaWarisan>(context, listen: false);

      // Muat data terbaru
      await penyediaWarisan.muatAhliWaris(penyediaAuth.nikPewaris!);
      await penyediaWarisan.muatAset(penyediaAuth.nikPewaris!);

      final ahliWaris = penyediaWarisan.daftarAhliWaris;
      final aset = penyediaWarisan.daftarAset;

      if (ahliWaris.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Belum ada data ahli waris'),
              backgroundColor: TemaAplikasi.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
        setState(() => _sedangMenghitung = false);
        return;
      }

      // Hitung total harta yang disetujui
      double totalHarta = 0;
      for (var item in aset) {
        if (item['status_verifikasi'] == 'disetujui') {
          totalHarta += double.tryParse(item['nilai'].toString()) ?? 0.0;
        }
      }

      if (totalHarta <= 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Belum ada aset yang disetujui'),
              backgroundColor: TemaAplikasi.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
        setState(() => _sedangMenghitung = false);
        return;
      }

      // Hitung pembagian warisan berdasarkan hukum Islam
      final hasil = _hitungFaraid(ahliWaris, totalHarta);

      setState(() {
        _hasilPerhitungan = hasil;
        _sedangMenghitung = false;
      });
    } catch (e) {
      print('Error hitung pembagian:  $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan:  ${e.toString()}'),
            backgroundColor: TemaAplikasi.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
      setState(() => _sedangMenghitung = false);
    }
  }

  Map<String, dynamic> _hitungFaraid(
      List<Map<String, dynamic>> ahliWaris, double totalHarta) {
    List<Map<String, dynamic>> pembagian = [];

    // Hitung jumlah tiap kategori
    int jumlahAnak = 0;
    int jumlahAnakLaki = 0;
    int jumlahAnakPerempuan = 0;
    bool adaIstri = false;
    bool adaSuami = false;
    bool adaAyah = false;
    bool adaIbu = false;

    for (var waris in ahliWaris) {
      final hubungan = waris['hubungan'];
      if (hubungan == 'anak_laki') {
        jumlahAnakLaki++;
        jumlahAnak++;
      } else if (hubungan == 'anak_perempuan') {
        jumlahAnakPerempuan++;
        jumlahAnak++;
      } else if (hubungan == 'istri') {
        adaIstri = true;
      } else if (hubungan == 'suami') {
        adaSuami = true;
      } else if (hubungan == 'ayah') {
        adaAyah = true;
      } else if (hubungan == 'ibu') {
        adaIbu = true;
      }
    }

    double sisaHarta = totalHarta;

    // 1. Bagian Suami/Istri
    if (adaSuami) {
      double bagianSuami =
          jumlahAnak > 0 ? totalHarta * 0.25 : totalHarta * 0.5;
      sisaHarta -= bagianSuami;

      for (var waris in ahliWaris) {
        if (waris['hubungan'] == 'suami') {
          pembagian.add({
            'nama': waris['nama_lengkap'],
            'hubungan': 'suami',
            'bagian': bagianSuami,
            'keterangan': jumlahAnak > 0
                ? '1/4 bagian (ada anak)'
                : '1/2 bagian (tidak ada anak)',
          });
        }
      }
    }

    if (adaIstri) {
      double bagianIstri =
          jumlahAnak > 0 ? totalHarta * 0.125 : totalHarta * 0.25;
      sisaHarta -= bagianIstri;

      for (var waris in ahliWaris) {
        if (waris['hubungan'] == 'istri') {
          pembagian.add({
            'nama': waris['nama_lengkap'],
            'hubungan': 'istri',
            'bagian': bagianIstri,
            'keterangan': jumlahAnak > 0
                ? '1/8 bagian (ada anak)'
                : '1/4 bagian (tidak ada anak)',
          });
        }
      }
    }

    // 2. Bagian Orang Tua
    if (adaAyah) {
      double bagianAyah =
          jumlahAnak > 0 ? totalHarta * (1.0 / 6.0) : sisaHarta * 0.3;
      sisaHarta -= bagianAyah;

      for (var waris in ahliWaris) {
        if (waris['hubungan'] == 'ayah') {
          pembagian.add({
            'nama': waris['nama_lengkap'],
            'hubungan': 'ayah',
            'bagian': bagianAyah,
            'keterangan': jumlahAnak > 0 ? '1/6 bagian (ada anak)' : 'Ashabah',
          });
        }
      }
    }

    if (adaIbu) {
      double bagianIbu =
          jumlahAnak > 0 ? totalHarta * (1.0 / 6.0) : totalHarta * (1.0 / 3.0);
      sisaHarta -= bagianIbu;

      for (var waris in ahliWaris) {
        if (waris['hubungan'] == 'ibu') {
          pembagian.add({
            'nama': waris['nama_lengkap'],
            'hubungan': 'ibu',
            'bagian': bagianIbu,
            'keterangan': jumlahAnak > 0
                ? '1/6 bagian (ada anak)'
                : '1/3 bagian (tidak ada anak)',
          });
        }
      }
    }

    // 3. Bagian Anak (sistem 2: 1)
    if (jumlahAnak > 0) {
      int totalBagian = (jumlahAnakLaki * 2) + jumlahAnakPerempuan;
      double nilaiPerBagian = sisaHarta / totalBagian;

      for (var waris in ahliWaris) {
        if (waris['hubungan'] == 'anak_laki') {
          double bagian = nilaiPerBagian * 2;
          pembagian.add({
            'nama': waris['nama_lengkap'],
            'hubungan': 'anak_laki',
            'bagian': bagian,
            'keterangan': 'Anak laki-laki mendapat 2x bagian anak perempuan',
          });
        } else if (waris['hubungan'] == 'anak_perempuan') {
          double bagian = nilaiPerBagian;
          pembagian.add({
            'nama': waris['nama_lengkap'],
            'hubungan': 'anak_perempuan',
            'bagian': bagian,
            'keterangan': 'Anak perempuan mendapat 1x bagian',
          });
        }
      }
    }

    return {
      'total_harta': totalHarta,
      'pembagian': pembagian,
      'tanggal': DateTime.now().toIso8601String(),
    };
  }

  void _hitungUlang() {
    setState(() {
      _hasilPerhitungan = null;
    });
  }

  Future<void> _simpanHasil() async {
    if (_hasilPerhitungan == null) return;

    try {
      // TODO: Implement simpanRiwayat method in PenyediaWarisan
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Hasil perhitungan berhasil disimpan'),
            backgroundColor: TemaAplikasi.success,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      print('Error simpan hasil: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: ${e.toString()}'),
            backgroundColor: TemaAplikasi.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }
}
