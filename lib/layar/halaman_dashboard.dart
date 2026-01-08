import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../penyedia/penyedia_auth.dart';
import '../penyedia/penyedia_warisan.dart';

class HalamanDashboard extends StatefulWidget {
  @override
  State<HalamanDashboard> createState() => _HalamanDashboardState();
}

class _HalamanDashboardState extends State<HalamanDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final penyediaAuth = Provider.of<PenyediaAuth>(context, listen: false);
      final penyediaWarisan =
          Provider.of<PenyediaWarisan>(context, listen: false);

      if (penyediaAuth.nikPewaris != null) {
        penyediaWarisan.muatAhliWaris(penyediaAuth.nikPewaris!);
        penyediaWarisan.muatAset(penyediaAuth.nikPewaris!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final penyediaAuth = Provider.of<PenyediaAuth>(context);
    final penyediaWarisan = Provider.of<PenyediaWarisan>(context);

    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [Color(0xFF00796B), Color(0xFFF5F5F5)],
            stops: [0.0, 0.3],
          ),
        ),
        child: Column(
          children: [
            // Header dengan sambutan
            Container(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Assalamu\'alaikum,',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  SizedBox(height: 4),
                  Text(
                    penyediaAuth.namaPengguna ?? 'Pengguna',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '✨ Kelola warisan dengan adil dan transparan',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),

            // Konten utama
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Data Pewaris Card
                    _buatKartuDataPewaris(penyediaAuth),

                    SizedBox(height: 24),

                    Text(
                      'Menu Utama',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Menu Grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buatKartuMenu(
                          context,
                          'Ahli Waris',
                          Icons.people,
                          Colors.blue,
                          '${penyediaWarisan.daftarAhliWaris.length} Orang',
                          0,
                        ),
                        _buatKartuMenu(
                          context,
                          'Aset Harta',
                          Icons.account_balance_wallet,
                          Colors.orange,
                          '${penyediaWarisan.daftarAset.length} Aset',
                          1,
                        ),
                        _buatKartuMenu(
                          context,
                          'Perhitungan',
                          Icons.calculate,
                          Colors.green,
                          'Hitung Waris',
                          2,
                        ),
                        _buatKartuMenu(
                          context,
                          'Riwayat',
                          Icons.history,
                          Colors.purple,
                          '0 Riwayat',
                          3,
                        ),
                      ],
                    ),

                    SizedBox(height: 24),

                    // Statistik
                    _buatKartuStatistik(penyediaWarisan),

                    SizedBox(height: 24),

                    // Tips & Info
                    _buatKartuInfo(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buatKartuDataPewaris(PenyediaAuth penyediaAuth) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF004D40), Color(0xFF00796B)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outline, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Text(
                'Data Pewaris',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buatBarisPewaris('Nama', penyediaAuth.namaPewaris ?? '-'),
          SizedBox(height: 8),
          _buatBarisPewaris(
            'Tempat, Tanggal Lahir',
            '${penyediaAuth.tempatLahirPewaris ?? '-'}, ${penyediaAuth.tahunLahirPewaris ?? '-'}',
          ),
          SizedBox(height: 8),
          _buatBarisPewaris('NIK', penyediaAuth.nikPewaris ?? '-'),
        ],
      ),
    );
  }

  Widget _buatBarisPewaris(String label, String nilai) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
        Text(': ', style: TextStyle(color: Colors.white70)),
        Expanded(
          child: Text(
            nilai,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buatKartuMenu(
    BuildContext context,
    String judul,
    IconData ikon,
    Color warna,
    String subjudul,
    int indeks,
  ) {
    return InkWell(
      onTap: () {
        // Pindah ke halaman yang sesuai
        final scaffold = context.findAncestorStateOfType<State>();
        if (scaffold != null && scaffold.mounted) {
          // Logic untuk navigasi
        }
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: warna.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(ikon, size: 32, color: warna),
            ),
            SizedBox(height: 12),
            Text(
              judul,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              subjudul,
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buatKartuStatistik(PenyediaWarisan penyediaWarisan) {
    final totalNilaiAset = penyediaWarisan.daftarAset.fold<double>(
      0,
      (total, aset) {
        final nilaiStr = aset['nilai']?.toString() ?? '0';
        final nilai = double.tryParse(nilaiStr) ?? 0.0;
        return total + nilai;
      },
    );

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buatItemStatistik(
                'Total Ahli Waris',
                '${penyediaWarisan.daftarAhliWaris.length}',
                Icons.people,
                Colors.blue,
              ),
              _buatItemStatistik(
                'Total Aset',
                'Rp ${_formatAngka(totalNilaiAset)}',
                Icons.account_balance_wallet,
                Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buatItemStatistik(
    String label,
    String nilai,
    IconData ikon,
    Color warna,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: warna.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(ikon, color: warna, size: 24),
            SizedBox(height: 8),
            Text(
              nilai,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: warna,
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buatKartuInfo() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: Colors.amber.shade700, size: 28),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tips Pembagian Warisan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Pastikan semua ahli waris dan aset telah terdaftar sebelum melakukan perhitungan.',
                  style: TextStyle(fontSize: 12, color: Colors.amber.shade800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatAngka(double angka) {
    if (angka >= 1000000000) {
      return '${(angka / 1000000000).toStringAsFixed(1)}M';
    } else if (angka >= 1000000) {
      return '${(angka / 1000000).toStringAsFixed(1)}jt';
    } else if (angka >= 1000) {
      return '${(angka / 1000).toStringAsFixed(0)}rb';
    }
    return angka.toStringAsFixed(0);
  }
}
