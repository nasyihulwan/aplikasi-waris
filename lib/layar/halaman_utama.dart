import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../penyedia/penyedia_auth.dart';
import '../tema/tema_aplikasi.dart';
import 'halaman_dashboard.dart';
import 'halaman_ahli_waris.dart';
import 'halaman_aset_harta.dart';
import 'halaman_hitung.dart';
import 'halaman_pengaturan.dart';
import 'halaman_edit_profil.dart';
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
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: TemaAplikasi.errorLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.logout,
                color: TemaAplikasi.error,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Konfirmasi Logout',
              style: TemaAplikasi.titleLarge,
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar dari aplikasi?',
          style: TemaAplikasi.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () {
              print('🏠 [UTAMA] Logout dibatalkan');
              Navigator.pop(context);
            },
            child: Text(
              'Batal',
              style: TextStyle(color: TemaAplikasi.textSecondary),
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
            style: TemaAplikasi.dangerButton,
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('🏠 [UTAMA] Build halaman utama, indeks: $_indeksTerpilih');

    return Scaffold(
      appBar: _indeksTerpilih == 0
          ? null
          : AppBar(
              title: Text(
                _judulHalaman[_indeksTerpilih],
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              backgroundColor: TemaAplikasi.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              actions: [
                _buildPopupMenu(),
              ],
            ),
      body: _halaman[_indeksTerpilih],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                    0, Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
                _buildNavItem(
                    1, Icons.people_outline, Icons.people, 'Ahli Waris'),
                _buildNavItem(2, Icons.account_balance_wallet_outlined,
                    Icons.account_balance_wallet, 'Aset'),
                _buildNavItem(
                    3, Icons.calculate_outlined, Icons.calculate, 'Hitung'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _indeksTerpilih == index;
    return InkWell(
      onTap: () {
        print('🏠 [UTAMA] Tab ditekan: $index (${_judulHalaman[index]})');
        setState(() => _indeksTerpilih = index);
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20 : 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? TemaAplikasi.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected
                  ? TemaAplikasi.primary
                  : TemaAplikasi.textSecondary,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: TemaAplikasi.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPopupMenu() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white,
      elevation: 8,
      offset: const Offset(0, 50),
      itemBuilder: (context) => <PopupMenuEntry<String>>[
        _buildPopupMenuItem(
          value: 'profil',
          icon: Icons.person_outline,
          text: 'Edit Profil',
          color: TemaAplikasi.primary,
        ),
        _buildPopupMenuItem(
          value: 'pengaturan',
          icon: Icons.settings_outlined,
          text: 'Pengaturan',
          color: TemaAplikasi.primary,
        ),
        _buildPopupMenuItem(
          value: 'bantuan',
          icon: Icons.help_outline,
          text: 'Bantuan',
          color: TemaAplikasi.info,
        ),
        const PopupMenuDivider(),
        _buildPopupMenuItem(
          value: 'keluar',
          icon: Icons.logout,
          text: 'Keluar',
          color: TemaAplikasi.error,
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'profil':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HalamanEditProfil()),
            );
            break;
          case 'pengaturan':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HalamanPengaturan()),
            );
            break;
          case 'bantuan':
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.white),
                    const SizedBox(width: 8),
                    const Text('Fitur bantuan akan segera hadir'),
                  ],
                ),
                backgroundColor: TemaAplikasi.info,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
            break;
          case 'keluar':
            _showLogoutConfirmation();
            break;
        }
      },
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem({
    required String value,
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Text(
            text,
            style: GoogleFonts.poppins(
              color: value == 'keluar' ? color : TemaAplikasi.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
