import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'layar/halaman_splash.dart';
import 'penyedia/penyedia_auth.dart';
import 'penyedia/penyedia_warisan.dart';
import 'tema/tema_aplikasi.dart';

void main() {
  runApp(const AplikasiWarisan());
}

class AplikasiWarisan extends StatelessWidget {
  const AplikasiWarisan({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PenyediaAuth()),
        ChangeNotifierProvider(create: (_) => PenyediaWarisan()),
      ],
      child: MaterialApp(
        title: 'Aplikasi Warisan',
        debugShowCheckedModeBanner: false,
        theme: TemaAplikasi.lightTheme,
        home: const HalamanSplash(),
      ),
    );
  }
}
