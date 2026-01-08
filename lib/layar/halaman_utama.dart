import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../penyedia/penyedia_auth.dart';
import 'halaman_dashboard.dart';
import 'halaman_ahli_waris.dart';
import 'halaman_aset_harta.dart';
import 'halaman_hitung.dart';
import 'halaman_pengaturan.dart';
import 'halaman_login.dart';

/// Halaman Utama
/// Halaman utama aplikasi dengan navigasi bottom bar
class HalamanUtama extends StatefulWidget {
  const HalamanUtama({super.key});

  @override
  _HalamanUtamaState createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  int _indeksTerpilih = 0;

  final List<Widget> _halaman = [
    const HalamanDashboard(),
    const HalamanAhliWaris(),
    const HalamanAsetHarta(),
    const HalamanHitung(),
  ];

  final List<String> _judulHalaman = [
    'Dashboard',
    'Ahli Waris',
    'Aset Harta',
    'Perhitungan',
  ];

  @override
  void initState() {
    super.initState();
    print('🏠 [UTAMA] Halaman utama diinisialisasi');
  }

  /// Menampilkan dialog konfirmasi logout
  void _showLogoutConfirmation() {
    print('🏠 [UTAMA] Menampilkan dialog konfirmasi logout');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.logout,
                color: Color(0xFFC62828),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Konfirmasi Logout',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari aplikasi?',
          style: TextStyle(color: Color(0xFF424242)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              print('🏠 [UTAMA] Logout dibatalkan');
              Navigator.pop(context);
            },
            child: const Text(
              'Batal',
              style: TextStyle(color: Color(0xFF616161)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              print('🏠 [UTAMA] User melakukan logout');
              Navigator.pop(context);

              final penyediaAuth =
                  Provider.of<PenyediaAuth>(context, listen: false);
              await penyediaAuth.logout();

              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HalamanLogin()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('🏠 [UTAMA] Build halaman utama, indeks: $_indeksTerpilih');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _judulHalaman[_indeksTerpilih],
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF00695C),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              print('🏠 [UTAMA] Tombol notifikasi ditekan');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Fitur notifikasi akan segera hadir'),
                    ],
                  ),
                  backgroundColor: const Color(0xFF00695C),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.white,
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'profil',
                child: const ListTile(
                  leading: Icon(Icons.person, color: Color(0xFF00695C)),
                  title: Text(
                    'Profil',
                    style: TextStyle(color: Color(0xFF212121)),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
                onTap: () {
                  print('🏠 [UTAMA] Menu Profil ditekan');
                  Future.delayed(const Duration(milliseconds: 10), () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Fitur profil akan segera hadir'),
                          ],
                        ),
                        backgroundColor: const Color(0xFF00695C),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  });
                },
              ),
              PopupMenuItem<String>(
                value: 'pengaturan',
                child: const ListTile(
                  leading: Icon(Icons.settings, color: Color(0xFF00695C)),
                  title: Text(
                    'Pengaturan',
                    style: TextStyle(color: Color(0xFF212121)),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
                onTap: () {
                  print('🏠 [UTAMA] Menu Pengaturan ditekan');
                  Future.delayed(const Duration(milliseconds: 10), () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HalamanPengaturan(),
                      ),
                    );
                  });
                },
              ),
              PopupMenuItem<String>(
                value: 'bantuan',
                child: const ListTile(
                  leading: Icon(Icons.help_outline, color: Color(0xFF00695C)),
                  title: Text(
                    'Bantuan',
                    style: TextStyle(color: Color(0xFF212121)),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
                onTap: () {
                  print('🏠 [UTAMA] Menu Bantuan ditekan');
                  Future.delayed(const Duration(milliseconds: 10), () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Fitur bantuan akan segera hadir'),
                          ],
                        ),
                        backgroundColor: const Color(0xFF00695C),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  });
                },
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'keluar',
                child: const ListTile(
                  leading: Icon(Icons.logout, color: Color(0xFFC62828)),
                  title: Text(
                    'Keluar',
                    style: TextStyle(color: Color(0xFFC62828)),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
                onTap: () {
                  print('🏠 [UTAMA] Menu Keluar ditekan');
                  Future.delayed(const Duration(milliseconds: 10), () {
                    _showLogoutConfirmation();
                  });
                },
              ),
            ],
          ),
        ],
      ),
      body: _halaman[_indeksTerpilih],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _indeksTerpilih,
          onTap: (indeks) {
            print('🏠 [UTAMA] Tab ditekan: $indeks (${_judulHalaman[indeks]})');
            setState(() => _indeksTerpilih = indeks);
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF00695C),
          unselectedItemColor: const Color(0xFF757575),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'Ahli Waris',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              activeIcon: Icon(Icons.account_balance_wallet),
              label: 'Aset Harta',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calculate_outlined),
              activeIcon: Icon(Icons.calculate),
              label: 'Hitung',
            ),
          ],
        ),
      ),
    );
  }
}
