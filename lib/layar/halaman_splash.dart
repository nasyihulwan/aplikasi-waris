import 'package:flutter/material.dart';
import 'dart:async';
import 'halaman_login.dart';

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

    Timer(const Duration(seconds: 3), () {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HalamanLogin()));
    });
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
