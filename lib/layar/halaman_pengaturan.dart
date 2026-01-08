import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../penyedia/penyedia_auth.dart';
import '../layanan/layanan_2fa.dart';
import 'halaman_setup_2fa.dart';
import 'halaman_login.dart';

/// Halaman Pengaturan
/// Menampilkan pengaturan akun termasuk manajemen 2FA
class HalamanPengaturan extends StatefulWidget {
  const HalamanPengaturan({super.key});

  @override
  State<HalamanPengaturan> createState() => _HalamanPengaturanState();
}

class _HalamanPengaturanState extends State<HalamanPengaturan> {
  bool _isLoading = false;
  bool _is2FAEnabled = false;

  @override
  void initState() {
    super.initState();
    print('⚙️ [PENGATURAN] Halaman pengaturan diinisialisasi');
    _loadSettings();
  }

  /// Memuat pengaturan dari provider
  Future<void> _loadSettings() async {
    print('⚙️ [PENGATURAN] Memuat pengaturan...');
    final penyediaAuth = Provider.of<PenyediaAuth>(context, listen: false);
    setState(() {
      _is2FAEnabled = penyediaAuth.twoFactorEnabled;
    });
    print('⚙️ [PENGATURAN] Status 2FA: $_is2FAEnabled');
  }

  /// Menampilkan dialog untuk enable 2FA
  void _showEnable2FADialog() {
    final penyediaAuth = Provider.of<PenyediaAuth>(context, listen: false);
    print('⚙️ [PENGATURAN] Menampilkan dialog enable 2FA');

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
                color: const Color(0xFFE0F2F1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.security,
                color: Color(0xFF00695C),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Aktifkan 2FA',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Two-Factor Authentication (2FA) akan menambahkan lapisan keamanan ekstra untuk akun Anda.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF424242),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF1565C0), size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Anda memerlukan Google Authenticator untuk fitur ini.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF1565C0)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(color: Color(0xFF616161)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              print('⚙️ [PENGATURAN] User memilih untuk mengaktifkan 2FA');
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HalamanSetup2FA(
                    userId: int.parse(penyediaAuth.idPengguna!),
                    namaUser: penyediaAuth.namaPengguna,
                    emailUser: penyediaAuth.email,
                  ),
                ),
              ).then((_) {
                // Refresh status setelah kembali
                _loadSettings();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00695C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Lanjutkan',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Menampilkan dialog untuk disable 2FA dengan validasi teks
  void _showDisable2FADialog() {
    final confirmTextController = TextEditingController();
    final codeController = TextEditingController();
    bool isValidating = false;
    String? textError;
    String? codeError;

    const String requiredText = 'Saya menghapus 2FA';

    print('⚙️ [PENGATURAN] Menampilkan dialog disable 2FA');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
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
                  Icons.warning_amber_rounded,
                  color: Color(0xFFC62828),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Nonaktifkan 2FA',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFC62828),
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFF9800)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning, color: Color(0xFFE65100), size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'PERINGATAN: Menonaktifkan 2FA akan mengurangi keamanan akun Anda!',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFE65100),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Untuk konfirmasi, ketik teks berikut:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF424242),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    requiredText,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFC62828),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmTextController,
                  decoration: InputDecoration(
                    labelText: 'Ketik teks konfirmasi',
                    labelStyle: const TextStyle(color: Color(0xFF616161)),
                    hintText: requiredText,
                    hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                    errorText: textError,
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFF00695C), width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFC62828)),
                    ),
                  ),
                  onChanged: (_) {
                    if (textError != null) {
                      setDialogState(() => textError = null);
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Masukkan kode 6 digit dari Google Authenticator:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF424242),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: codeController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    labelText: 'Kode 2FA',
                    labelStyle: const TextStyle(color: Color(0xFF616161)),
                    hintText: '000000',
                    hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                    errorText: codeError,
                    prefixIcon: const Icon(Icons.lock_outline,
                        color: Color(0xFF00695C)),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFF00695C), width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFC62828)),
                    ),
                  ),
                  onChanged: (_) {
                    if (codeError != null) {
                      setDialogState(() => codeError = null);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isValidating
                  ? null
                  : () {
                      print('⚙️ [PENGATURAN] Dialog disable 2FA dibatalkan');
                      Navigator.pop(dialogContext);
                    },
              child: Text(
                'Batal',
                style: TextStyle(
                  color: isValidating
                      ? const Color(0xFF9E9E9E)
                      : const Color(0xFF616161),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: isValidating
                  ? null
                  : () async {
                      final confirmText = confirmTextController.text.trim();
                      final code = codeController.text.trim();

                      print('⚙️ [PENGATURAN] Validasi input disable 2FA...');
                      print(
                          '⚙️ [PENGATURAN] Teks konfirmasi: "$confirmText" vs "$requiredText"');
                      print('⚙️ [PENGATURAN] Panjang kode: ${code.length}');

                      // Validasi teks konfirmasi
                      if (confirmText != requiredText) {
                        print('🔴 [PENGATURAN] Teks konfirmasi tidak cocok');
                        setDialogState(() {
                          textError =
                              'Teks tidak sesuai. Ketik persis: $requiredText';
                        });
                        return;
                      }

                      // Validasi kode
                      if (code.length != 6) {
                        print('🔴 [PENGATURAN] Kode bukan 6 digit');
                        setDialogState(() {
                          codeError = 'Kode harus 6 digit';
                        });
                        return;
                      }

                      if (!RegExp(r'^\d{6}$').hasMatch(code)) {
                        print('🔴 [PENGATURAN] Kode bukan angka');
                        setDialogState(() {
                          codeError = 'Kode harus berupa angka';
                        });
                        return;
                      }

                      setDialogState(() => isValidating = true);

                      try {
                        final penyediaAuth =
                            Provider.of<PenyediaAuth>(context, listen: false);
                        print(
                            '⚙️ [PENGATURAN] Mengirim request disable 2FA ke server...');

                        final result = await Layanan2FA.disable(
                          int.parse(penyediaAuth.idPengguna!),
                          code,
                        );

                        print(
                            '⚙️ [PENGATURAN] Response disable: success=${result['success']}');

                        if (result['success'] == true) {
                          print('🟢 [PENGATURAN] 2FA berhasil dinonaktifkan');
                          await penyediaAuth.set2FAEnabled(false);

                          Navigator.pop(dialogContext);

                          setState(() {
                            _is2FAEnabled = false;
                          });

                          _showSnackBar('2FA berhasil dinonaktifkan',
                              isSuccess: true);
                        } else {
                          print(
                              '🔴 [PENGATURAN] Gagal disable 2FA: ${result['message']}');
                          setDialogState(() {
                            isValidating = false;
                            codeError = result['message'] ?? 'Kode tidak valid';
                          });
                        }
                      } catch (e) {
                        print('🔴 [PENGATURAN] Exception disable 2FA: $e');
                        setDialogState(() {
                          isValidating = false;
                          codeError = 'Terjadi kesalahan: ${e.toString()}';
                        });
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC62828),
                disabledBackgroundColor: const Color(0xFFBDBDBD),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isValidating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Nonaktifkan',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Menampilkan snackbar
  void _showSnackBar(String message, {bool isSuccess = false}) {
    print('⚙️ [PENGATURAN] Menampilkan snackbar: $message');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.info_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor:
            isSuccess ? const Color(0xFF2E7D32) : const Color(0xFF00695C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Konfirmasi logout
  void _showLogoutConfirmation() {
    print('⚙️ [PENGATURAN] Menampilkan konfirmasi logout');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Konfirmasi Logout',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari aplikasi?',
          style: TextStyle(color: Color(0xFF424242)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(color: Color(0xFF616161)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              print('⚙️ [PENGATURAN] User melakukan logout');
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
    final penyediaAuth = Provider.of<PenyediaAuth>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: const Color(0xFF00695C),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF00695C),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User info header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: Color(0xFF00695C),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 36,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                penyediaAuth.namaPengguna ?? 'Pengguna',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                penyediaAuth.email ?? '-',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Keamanan Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Keamanan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF424242),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // 2FA Setting Card
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: _is2FAEnabled
                                        ? const Color(0xFFE8F5E9)
                                        : const Color(0xFFFFF3E0),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.security,
                                    color: _is2FAEnabled
                                        ? const Color(0xFF2E7D32)
                                        : const Color(0xFFE65100),
                                  ),
                                ),
                                title: const Text(
                                  'Two-Factor Authentication',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF212121),
                                  ),
                                ),
                                subtitle: Text(
                                  _is2FAEnabled
                                      ? 'Aktif - Akun Anda terlindungi'
                                      : 'Nonaktif - Aktifkan untuk keamanan ekstra',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _is2FAEnabled
                                        ? const Color(0xFF2E7D32)
                                        : const Color(0xFFE65100),
                                  ),
                                ),
                                trailing: Switch(
                                  value: _is2FAEnabled,
                                  onChanged: (value) {
                                    if (value) {
                                      _showEnable2FADialog();
                                    } else {
                                      _showDisable2FADialog();
                                    }
                                  },
                                  activeColor: const Color(0xFF00695C),
                                  activeTrackColor: const Color(0xFF80CBC4),
                                ),
                              ),
                              if (_is2FAEnabled) ...[
                                const Divider(height: 1),
                                ListTile(
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE0F2F1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.vpn_key,
                                      color: Color(0xFF00695C),
                                      size: 20,
                                    ),
                                  ),
                                  title: const Text(
                                    'Backup Codes',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF212121),
                                    ),
                                  ),
                                  subtitle: const Text(
                                    'Lihat atau generate backup codes baru',
                                    style: TextStyle(
                                        fontSize: 12, color: Color(0xFF616161)),
                                  ),
                                  trailing: const Icon(
                                    Icons.chevron_right,
                                    color: Color(0xFF9E9E9E),
                                  ),
                                  onTap: () {
                                    print(
                                        '⚙️ [PENGATURAN] Membuka halaman backup codes');
                                    _showSnackBar(
                                        'Fitur lihat backup codes akan segera hadir');
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Akun Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Akun',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF424242),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE3F2FD),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.person_outline,
                                    color: Color(0xFF1565C0),
                                  ),
                                ),
                                title: const Text(
                                  'Profil',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF212121),
                                  ),
                                ),
                                subtitle: const Text(
                                  'Ubah informasi profil',
                                  style: TextStyle(
                                      fontSize: 12, color: Color(0xFF616161)),
                                ),
                                trailing: const Icon(
                                  Icons.chevron_right,
                                  color: Color(0xFF9E9E9E),
                                ),
                                onTap: () {
                                  _showSnackBar(
                                      'Fitur profil akan segera hadir');
                                },
                              ),
                              const Divider(height: 1),
                              ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.lock_outline,
                                    color: Color(0xFF2E7D32),
                                  ),
                                ),
                                title: const Text(
                                  'Ubah Password',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF212121),
                                  ),
                                ),
                                subtitle: const Text(
                                  'Ganti password akun',
                                  style: TextStyle(
                                      fontSize: 12, color: Color(0xFF616161)),
                                ),
                                trailing: const Icon(
                                  Icons.chevron_right,
                                  color: Color(0xFF9E9E9E),
                                ),
                                onTap: () {
                                  _showSnackBar(
                                      'Fitur ubah password akan segera hadir');
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Logout Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _showLogoutConfirmation,
                        icon:
                            const Icon(Icons.logout, color: Color(0xFFC62828)),
                        label: const Text(
                          'Logout',
                          style: TextStyle(
                            color: Color(0xFFC62828),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Color(0xFFC62828)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // App Version
                  Center(
                    child: Text(
                      'Aplikasi Warisan v1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}
