import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../penyedia/penyedia_auth.dart';
import 'halaman_login.dart';
import 'halaman_utama.dart';
import 'halaman_verifikasi_2fa.dart';

class HalamanSplash extends StatefulWidget {
  const HalamanSplash({super.key});

  @override
  _HalamanSplashState createState() => _HalamanSplashState();
}

class _HalamanSplashState extends State<HalamanSplash>
    with SingleTickerProviderStateMixin {
  late AnimationController _pengendaliAnimasi;
  late Animation<double> _animasiFade;

  @override
  void initState() {
    super.initState();

    _pengendaliAnimasi = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animasiFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_pengendaliAnimasi);

    _pengendaliAnimasi.forward();

    // Cek session setelah animasi selesai
    Timer(const Duration(seconds: 3), () {
      _cekSessionDanNavigasi();
    });
  }

  /// Cek apakah user sudah login sebelumnya
  Future<void> _cekSessionDanNavigasi() async {
    final penyediaAuth = Provider.of<PenyediaAuth>(context, listen: false);

    // Tunggu data selesai dimuat dari storage
    print('🔍 [SPLASH] Menunggu data dimuat...');
    await penyediaAuth.tungguDataDimuat();

    print('🔍 [SPLASH] Mengecek session...');
    print('   - sudahLogin: ${penyediaAuth.sudahLogin}');
    print('   - email: ${penyediaAuth.email}');
    print('   - 2FA enabled: ${penyediaAuth.twoFactorEnabled}');

    if (!mounted) return;

    if (penyediaAuth.sudahLogin && penyediaAuth.email != null) {
      print('🟢 [SPLASH] User sudah login sebelumnya');

      // Cek apakah perlu verifikasi 2FA
      if (penyediaAuth.twoFactorEnabled) {
        print('🔐 [SPLASH] 2FA aktif, redirect ke verifikasi 2FA');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => HalamanVerifikasi2FA(
              userId: int.parse(penyediaAuth.idPengguna!),
              namaUser: penyediaAuth.namaPengguna,
              emailUser: penyediaAuth.email,
            ),
          ),
        );
      } else {
        print('🏠 [SPLASH] Langsung ke halaman utama');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HalamanUtama()),
        );
      }
    } else {
      print('🔴 [SPLASH] User belum login, redirect ke halaman login');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HalamanLogin()),
      );
    }
  }

  @override
  void dispose() {
    _pengendaliAnimasi.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF00796B), Color(0xFF004D40)],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _animasiFade,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_balance, size: 120, color: Colors.white),
                SizedBox(height: 24),
                Text(
                  'Aplikasi Warisan',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Kelola Pembagian Warisan dengan Mudah',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
