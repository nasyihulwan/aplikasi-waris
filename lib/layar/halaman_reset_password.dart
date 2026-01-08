import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../penyedia/penyedia_auth.dart';
import '../layanan/layanan_2fa.dart';

/// Halaman Reset Password
/// Pengguna harus memiliki 2FA aktif untuk dapat mengganti password
class HalamanResetPassword extends StatefulWidget {
  const HalamanResetPassword({super.key});

  @override
  State<HalamanResetPassword> createState() => _HalamanResetPasswordState();
}

class _HalamanResetPasswordState extends State<HalamanResetPassword> {
  final _formKey = GlobalKey<FormState>();
  final _passwordLamaController = TextEditingController();
  final _passwordBaruController = TextEditingController();
  final _konfirmasiPasswordController = TextEditingController();
  final _kode2FAController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePasswordLama = true;
  bool _obscurePasswordBaru = true;
  bool _obscureKonfirmasi = true;
  bool _is2FAVerified = false;

  @override
  void initState() {
    super.initState();
    print('🔑 [RESET-PASSWORD] Halaman reset password diinisialisasi');
    _check2FAStatus();
  }

  @override
  void dispose() {
    _passwordLamaController.dispose();
    _passwordBaruController.dispose();
    _konfirmasiPasswordController.dispose();
    _kode2FAController.dispose();
    super.dispose();
  }

  /// Memeriksa status 2FA pengguna
  void _check2FAStatus() {
    final penyediaAuth = Provider.of<PenyediaAuth>(context, listen: false);
    final is2FAEnabled = penyediaAuth.twoFactorEnabled;
    print('🔑 [RESET-PASSWORD] Status 2FA: $is2FAEnabled');

    if (!is2FAEnabled) {
      print('🔴 [RESET-PASSWORD] 2FA tidak aktif, menampilkan peringatan');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _show2FARequiredDialog();
      });
    }
  }

  /// Menampilkan dialog 2FA diperlukan
  void _show2FARequiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.security,
                color: Color(0xFFE65100),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                '2FA Diperlukan',
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE65100)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Color(0xFFE65100), size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Anda harus mengaktifkan Two-Factor Authentication (2FA) terlebih dahulu untuk dapat mengganti password.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFFE65100),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Fitur ini memastikan keamanan akun Anda dengan memverifikasi identitas melalui 2FA sebelum mengizinkan perubahan password.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF424242),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B5E20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Kembali',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Verifikasi kode 2FA
  Future<void> _verify2FA() async {
    final kode = _kode2FAController.text.trim();

    if (kode.length != 6) {
      _showSnackBar('Kode 2FA harus 6 digit', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    print('🔑 [RESET-PASSWORD] Memverifikasi kode 2FA...');

    try {
      final penyediaAuth = Provider.of<PenyediaAuth>(context, listen: false);
      final result = await Layanan2FA.validate(
        int.parse(penyediaAuth.idPengguna!),
        kode,
      );

      if (result['success'] == true) {
        print('🟢 [RESET-PASSWORD] Kode 2FA valid');
        setState(() {
          _is2FAVerified = true;
        });
        _showSnackBar('Verifikasi 2FA berhasil', isSuccess: true);
      } else {
        print('🔴 [RESET-PASSWORD] Kode 2FA tidak valid');
        _showSnackBar(result['message'] ?? 'Kode tidak valid', isError: true);
      }
    } catch (e) {
      print('🔴 [RESET-PASSWORD] Error verifikasi 2FA: $e');
      _showSnackBar('Terjadi kesalahan: ${e.toString()}', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Mengganti password
  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_is2FAVerified) {
      _showSnackBar('Verifikasi 2FA terlebih dahulu', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    print('🔑 [RESET-PASSWORD] Memproses perubahan password...');

    try {
      // Simulasi API call - ganti dengan implementasi sebenarnya
      await Future.delayed(const Duration(seconds: 1));

      // TODO: Implementasi API untuk ubah password
      // final penyediaAuth = Provider.of<PenyediaAuth>(context, listen: false);
      // await penyediaAuth.changePassword(
      //   oldPassword: _passwordLamaController.text,
      //   newPassword: _passwordBaruController.text,
      // );

      print('🟢 [RESET-PASSWORD] Password berhasil diubah');

      _showSnackBar('Password berhasil diubah', isSuccess: true);

      // Reset form
      _passwordLamaController.clear();
      _passwordBaruController.clear();
      _konfirmasiPasswordController.clear();
      _kode2FAController.clear();
      setState(() {
        _is2FAVerified = false;
      });

      // Kembali ke halaman sebelumnya setelah delay
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    } catch (e) {
      print('🔴 [RESET-PASSWORD] Error mengubah password: $e');
      _showSnackBar('Gagal mengubah password: ${e.toString()}', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message,
      {bool isSuccess = false, bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess
                  ? Icons.check_circle
                  : isError
                      ? Icons.error
                      : Icons.info_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isSuccess
            ? const Color(0xFF2E7D32)
            : isError
                ? const Color(0xFFC62828)
                : const Color(0xFF1B5E20),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final penyediaAuth = Provider.of<PenyediaAuth>(context);
    final is2FAEnabled = penyediaAuth.twoFactorEnabled;

    print('🔑 [RESET-PASSWORD] Build halaman reset password');
    print(
        '🔑 [RESET-PASSWORD] 2FA Enabled: $is2FAEnabled, Verified: $_is2FAVerified');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ganti Password',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1B5E20),
              Color(0xFF2E7D32),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.lock_reset,
                      size: 40,
                      color: Color(0xFF1B5E20),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 2FA Verification Card (hanya tampil jika 2FA aktif tapi belum diverifikasi)
                  if (is2FAEnabled && !_is2FAVerified) ...[
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.security, color: Color(0xFF1B5E20)),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Verifikasi 2FA',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF212121),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Masukkan kode 6 digit dari Google Authenticator untuk melanjutkan',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF616161),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Input Kode 2FA
                          TextFormField(
                            controller: _kode2FAController,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            decoration: InputDecoration(
                              labelText: 'Kode 2FA',
                              labelStyle: const TextStyle(
                                color: Color(0xFF616161),
                                fontSize: 16,
                              ),
                              hintText: '000000',
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: Color(0xFF1B5E20),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF5F5F5),
                              counterText: '',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE0E0E0),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF1B5E20),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Verify Button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _verify2FA,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1B5E20),
                                disabledBackgroundColor:
                                    const Color(0xFFBDBDBD),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Verifikasi',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Password Change Card (hanya tampil setelah 2FA diverifikasi atau jika tidak ada 2FA)
                  if (_is2FAVerified || !is2FAEnabled)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Success indicator for 2FA
                          if (_is2FAVerified) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.check_circle,
                                      color: Color(0xFF2E7D32), size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Verifikasi 2FA berhasil',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF2E7D32),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          const Text(
                            'Password Baru',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF212121),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Masukkan password lama dan password baru',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF616161),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Password Lama
                          TextFormField(
                            controller: _passwordLamaController,
                            obscureText: _obscurePasswordLama,
                            decoration: InputDecoration(
                              labelText: 'Password Lama',
                              labelStyle: const TextStyle(
                                color: Color(0xFF616161),
                                fontSize: 16,
                              ),
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: Color(0xFF1B5E20),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePasswordLama
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: const Color(0xFF616161),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePasswordLama =
                                        !_obscurePasswordLama;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF5F5F5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE0E0E0),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF1B5E20),
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFC62828),
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password lama tidak boleh kosong';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // Password Baru
                          TextFormField(
                            controller: _passwordBaruController,
                            obscureText: _obscurePasswordBaru,
                            decoration: InputDecoration(
                              labelText: 'Password Baru',
                              labelStyle: const TextStyle(
                                color: Color(0xFF616161),
                                fontSize: 16,
                              ),
                              prefixIcon: const Icon(
                                Icons.lock_reset,
                                color: Color(0xFF1B5E20),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePasswordBaru
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: const Color(0xFF616161),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePasswordBaru =
                                        !_obscurePasswordBaru;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF5F5F5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE0E0E0),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF1B5E20),
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFC62828),
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password baru tidak boleh kosong';
                              }
                              if (value.length < 8) {
                                return 'Password minimal 8 karakter';
                              }
                              if (!RegExp(r'[A-Z]').hasMatch(value)) {
                                return 'Password harus mengandung huruf besar';
                              }
                              if (!RegExp(r'[a-z]').hasMatch(value)) {
                                return 'Password harus mengandung huruf kecil';
                              }
                              if (!RegExp(r'[0-9]').hasMatch(value)) {
                                return 'Password harus mengandung angka';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // Konfirmasi Password
                          TextFormField(
                            controller: _konfirmasiPasswordController,
                            obscureText: _obscureKonfirmasi,
                            decoration: InputDecoration(
                              labelText: 'Konfirmasi Password Baru',
                              labelStyle: const TextStyle(
                                color: Color(0xFF616161),
                                fontSize: 16,
                              ),
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: Color(0xFF1B5E20),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureKonfirmasi
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: const Color(0xFF616161),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureKonfirmasi = !_obscureKonfirmasi;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF5F5F5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE0E0E0),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF1B5E20),
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFC62828),
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Konfirmasi password tidak boleh kosong';
                              }
                              if (value != _passwordBaruController.text) {
                                return 'Password tidak cocok';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 32),

                          // Change Password Button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _changePassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1B5E20),
                                disabledBackgroundColor:
                                    const Color(0xFFBDBDBD),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Ganti Password',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Info text
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Password harus memenuhi kriteria:',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            SizedBox(width: 32),
                            Expanded(
                              child: Text(
                                '• Minimal 8 karakter\n• Mengandung huruf besar\n• Mengandung huruf kecil\n• Mengandung angka',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
