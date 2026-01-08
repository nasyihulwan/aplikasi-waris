import 'package:flutter/material.dart';
import 'halaman_dashboard.dart';
import 'halaman_ahli_waris.dart';
import 'halaman_aset_harta.dart';
import 'halaman_hitung.dart';

class HalamanUtama extends StatefulWidget {
  @override
  _HalamanUtamaState createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  int _indeksTerpilih = 0;

  final List<Widget> _halaman = [
    HalamanDashboard(),
    HalamanAhliWaris(),
    HalamanAsetHarta(),
    HalamanHitung(),
  ];

  final List<String> _judulHalaman = [
    'Dashboard',
    'Ahli Waris',
    'Aset Harta',
    'Perhitungan',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_judulHalaman[_indeksTerpilih]),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined),
            onPressed: () {
              // Tampilkan notifikasi
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Fitur notifikasi akan segera hadir')),
              );
            },
          ),
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Profil'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Pengaturan'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.help_outline),
                  title: Text('Bantuan'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('Keluar', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
                onTap: () {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/', (route) => false);
                },
              ),
            ],
          ),
        ],
      ),
      body: _halaman[_indeksTerpilih],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: BottomNavigationBar(
          currentIndex: _indeksTerpilih,
          onTap: (indeks) {
            setState(() => _indeksTerpilih = indeks);
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Color(0xFF00796B),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Ahli Waris',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet),
              label: 'Aset Harta',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calculate),
              label: 'Hitung',
            ),
          ],
        ),
      ),
    );
  }
}
