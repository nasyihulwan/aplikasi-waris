import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../penyedia/penyedia_auth.dart';
import '../penyedia/penyedia_warisan.dart';
import '../tema/tema_aplikasi.dart';
import '../widget/komponen_umum.dart';
import 'halaman_pengaturan.dart';

class HalamanDashboard extends StatefulWidget {
  const HalamanDashboard({super.key});

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

    return Scaffold(
      backgroundColor: TemaAplikasi.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF00695C),
              Color(0xFF00897B),
            ],
            stops: [0.0, 0.35],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: [
              // Header dengan sambutan
              SliverToBoxAdapter(
                child: _buatHeader(penyediaAuth),
              ),

              // Konten utama
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Data Pewaris Card
                        _buatKartuDataPewaris(penyediaAuth),

                        const SizedBox(height: 8),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          child: Text(
                            'Menu Utama',
                            style: TemaAplikasi.headingSmall,
                          ),
                        ),

                        // Menu Grid
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.95,
                            children: [
                              KartuMenu(
                                judul: 'Ahli Waris',
                                subjudul:
                                    '${penyediaWarisan.daftarAhliWaris.length} Orang',
                                icon: Icons.people_outline,
                                warna: TemaAplikasi.menuBlue,
                              ),
                              KartuMenu(
                                judul: 'Aset Harta',
                                subjudul:
                                    '${penyediaWarisan.daftarAset.length} Aset',
                                icon: Icons.account_balance_wallet_outlined,
                                warna: TemaAplikasi.menuOrange,
                              ),
                              const KartuMenu(
                                judul: 'Perhitungan',
                                subjudul: 'Hitung Waris',
                                icon: Icons.calculate_outlined,
                                warna: TemaAplikasi.menuGreen,
                              ),
                              const KartuMenu(
                                judul: 'Riwayat',
                                subjudul: 'Lihat Riwayat',
                                icon: Icons.history,
                                warna: TemaAplikasi.menuPurple,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Statistik
                        _buatKartuStatistik(penyediaWarisan),

                        const SizedBox(height: 8),

                        // Tips & Info
                        const KartuTips(
                          judul: 'Tips Pembagian Warisan',
                          deskripsi:
                              'Pastikan semua ahli waris dan aset telah terdaftar sebelum melakukan perhitungan.',
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buatHeader(PenyediaAuth penyediaAuth) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assalamu\'alaikum,',
                      style: TemaAplikasi.bodyWhiteLight,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      penyediaAuth.namaPengguna ?? 'Pengguna',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HalamanPengaturan(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.settings_outlined,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: Colors.amber.shade300,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Kelola warisan dengan adil dan transparan',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buatKartuDataPewaris(PenyediaAuth penyediaAuth) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      padding: const EdgeInsets.all(20),
      decoration: TemaAplikasi.gradientCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Data Pewaris',
                style: TemaAplikasi.titleWhite,
              ),
            ],
          ),
          const SizedBox(height: 20),
          BarisInfo(
            label: 'Nama',
            nilai: penyediaAuth.namaPewaris ?? '-',
            isWhite: true,
          ),
          const SizedBox(height: 8),
          BarisInfo(
            label: 'TTL',
            nilai:
                '${penyediaAuth.tempatLahirPewaris ?? '-'}, ${penyediaAuth.tahunLahirPewaris ?? '-'}',
            isWhite: true,
          ),
          BarisInfo(
            label: 'NIK',
            nilai: penyediaAuth.nikPewaris ?? '-',
            isWhite: true,
          ),
        ],
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
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: TemaAplikasi.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: TemaAplikasi.primarySurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  size: 22,
                  color: TemaAplikasi.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Ringkasan',
                style: TemaAplikasi.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: KartuStatistik(
                  label: 'Total Ahli Waris',
                  nilai: '${penyediaWarisan.daftarAhliWaris.length}',
                  icon: Icons.people_outline,
                  warna: TemaAplikasi.menuBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: KartuStatistik(
                  label: 'Total Aset',
                  nilai: 'Rp ${_formatAngka(totalNilaiAset)}',
                  icon: Icons.account_balance_wallet_outlined,
                  warna: TemaAplikasi.menuGreen,
                ),
              ),
            ],
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
