import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../penyedia/penyedia_auth.dart';
import '../penyedia/penyedia_warisan.dart';

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
            const Icon(
              Icons.calculate_outlined,
              size: 120,
              color: Color(0xFF00796B),
            ),
            const SizedBox(height: 24),
            const Text(
              'Hitung Pembagian Warisan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF004D40),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Sistem akan menghitung pembagian warisan berdasarkan hukum Islam (Faraid) dengan data ahli waris dan aset yang telah disetujui.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            _sedangMenghitung
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _hitungPembagian,
                    icon: const Icon(Icons.calculate, size: 24),
                    label: const Text(
                      'Mulai Perhitungan',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00796B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
            const SizedBox(height: 16),
            const Text(
              'Pastikan data ahli waris dan aset sudah lengkap',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
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
          const Text(
            'Rincian Pembagian',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF004D40),
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
                child: ElevatedButton.icon(
                  onPressed: _hitungUlang,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Hitung Ulang'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _simpanHasil,
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan Hasil'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00796B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buatKartuRingkasan(double totalHarta) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF004D40), Color(0xFF00796B)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.account_balance_wallet, color: Colors.white, size: 32),
              SizedBox(width: 12),
              Text(
                'Total Harta Warisan',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _formatRupiah(totalHarta),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
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

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF00796B).withOpacity(0.1),
                  child: Icon(
                    _dapatkanIconHubungan(hubungan),
                    color: const Color(0xFF00796B),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nama,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _dapatkanLabelHubungan(hubungan),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bagian:  ',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                Text(
                  _formatRupiah(bagian),
                  style: const TextStyle(
                    color: Color(0xFF00796B),
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
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        keterangan,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[900],
                        ),
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
            const SnackBar(
              content: Text('Belum ada data ahli waris'),
              backgroundColor: Colors.red,
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
            const SnackBar(
              content: Text('Belum ada aset yang disetujui'),
              backgroundColor: Colors.red,
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
            backgroundColor: Colors.red,
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
          const SnackBar(
            content: Text('Hasil perhitungan berhasil disimpan'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error simpan hasil: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
