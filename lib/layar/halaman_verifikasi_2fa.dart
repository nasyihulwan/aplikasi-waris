import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import '../layanan/layanan_2fa.dart';
import '../penyedia/penyedia_auth.dart';
import '../tema/tema_aplikasi.dart';
import 'halaman_utama.dart';

/// Halaman untuk verifikasi Two-Factor Authentication saat login
/// Ditampilkan setelah user berhasil login dengan email/password
/// dan memiliki 2FA yang sudah aktif
class HalamanVerifikasi2FA extends StatefulWidget {
  final int userId;
  final String? namaUser;
  final String? emailUser;

  const HalamanVerifikasi2FA({
    super.key,
    required this.userId,
    this.namaUser,
    this.emailUser,
  });

  @override
  State<HalamanVerifikasi2FA> createState() => _HalamanVerifikasi2FAState();
}

class _HalamanVerifikasi2FAState extends State<HalamanVerifikasi2FA> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();

  bool _isVerifying = false;
  String? _errorMessage;
  int _retryCount = 0;
  static const int _maxRetries = 5;

  @override
  void initState() {
    super.initState();
    print(
        '🔐 [VERIFY-2FA] Halaman verifikasi 2FA diinisialisasi untuk user ${widget.userId}');
    print('🔐 [VERIFY-2FA] Email user: ${widget.emailUser}');
    // Auto focus ke input field
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _pinFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    print('🔐 [VERIFY-2FA] Halaman verifikasi 2FA ditutup');
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  /// Verifikasi kode OTP
  Future<void> _verifyCode() async {
    final code = _pinController.text.trim();
    print(
        '🔐 [VERIFY-2FA] Memulai verifikasi dengan kode: ${code.length} digit');
    print('🔐 [VERIFY-2FA] Percobaan ke-${_retryCount + 1} dari $_maxRetries');

    // Cek max retries
    if (_retryCount >= _maxRetries) {
      print('🔴 [VERIFY-2FA] Max retry tercapai ($_maxRetries)');
      _showSnackBar(
        'Terlalu banyak percobaan. Silakan coba lagi nanti.',
        isError: true,
      );
      return;
    }

    // Validasi input
    if (code.length != 6) {
      print('🔴 [VERIFY-2FA] Validasi gagal: kode bukan 6 digit');
      _showSnackBar('Masukkan kode 6 digit', isError: true);
      return;
    }

    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      print('🔴 [VERIFY-2FA] Validasi gagal: kode bukan angka');
      _showSnackBar('Kode harus berupa angka', isError: true);
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      print('🔐 [VERIFY-2FA] Mengirim kode ke server...');
      final result = await Layanan2FA.validate(widget.userId, code);
      print('🔐 [VERIFY-2FA] Response: valid=${result['valid']}');

      if (result['valid'] == true) {
        print(
            '🟢 [VERIFY-2FA] Verifikasi berhasil! Navigasi ke halaman utama...');
        // Simpan session dan navigasi ke home
        if (mounted) {
          final penyediaAuth =
              Provider.of<PenyediaAuth>(context, listen: false);
          await penyediaAuth.set2FAVerified(true);

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HalamanUtama()),
            (route) => false,
          );
        }
      } else {
        print('🔴 [VERIFY-2FA] Verifikasi gagal: ${result['message']}');
        setState(() {
          _retryCount++;
          _errorMessage = result['message'] ?? 'Kode salah atau expired';
          _isVerifying = false;
        });
        _showSnackBar(_errorMessage!, isError: true);
        _pinController.clear();
        _pinFocusNode.requestFocus();
      }
    } catch (e) {
      print('🔴 [VERIFY-2FA] Exception saat verifikasi: $e');
      setState(() {
        _retryCount++;
        _errorMessage = 'Error: ${e.toString()}';
        _isVerifying = false;
      });
      _showSnackBar(_errorMessage!, isError: true);
    }
  }

  /// Menampilkan snackbar
  void _showSnackBar(String message, {bool isError = false}) {
    print('🔐 [VERIFY-2FA] Menampilkan snackbar: $message (error: $isError)');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message, style: GoogleFonts.poppins())),
          ],
        ),
        backgroundColor: isError ? TemaAplikasi.error : TemaAplikasi.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Kembali ke halaman login
  void _backToLogin() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Batalkan Login?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(
          'Anda akan kembali ke halaman login. Lanjutkan?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Tidak',
                style: GoogleFonts.poppins(color: TemaAplikasi.textTertiary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Kembali ke login
            },
            style: TemaAplikasi.dangerButton,
            child: Text(
              'Ya, Batalkan',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: TemaAplikasi.gradientPrimaryLinear,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Icon & Title
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.security,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Verifikasi 2FA',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.emailUser ?? 'Verifikasi akun Anda',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),

                const SizedBox(height: 48),

                // Card for verification
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Info kode berubah setiap 30 detik (tanpa countdown)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: TemaAplikasi.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.info_outline,
                                color: TemaAplikasi.success, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Kode berganti setiap 30 detik',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: TemaAplikasi.success,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Instructions
                      Text(
                        'Masukkan kode 6 digit dari\nGoogle Authenticator',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: TemaAplikasi.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 24),

                      // PIN Input
                      _buildPinInput(),

                      // Error message
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: TemaAplikasi.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: TemaAplikasi.error.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: TemaAplikasi.error,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: GoogleFonts.poppins(
                                    color: TemaAplikasi.error,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Retry counter
                      if (_retryCount > 0) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Percobaan: $_retryCount / $_maxRetries',
                          style: GoogleFonts.poppins(
                            color: _retryCount >= _maxRetries - 1
                                ? TemaAplikasi.error
                                : TemaAplikasi.textTertiary,
                            fontSize: 12,
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Verify Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              (_isVerifying || _retryCount >= _maxRetries)
                                  ? null
                                  : _verifyCode,
                          style: TemaAplikasi.primaryButton,
                          child: _isVerifying
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Verifikasi',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Try again button
                      if (_errorMessage != null && _retryCount < _maxRetries)
                        TextButton.icon(
                          onPressed: () {
                            print(
                                '🔐 [VERIFY-2FA] User menekan tombol coba lagi');
                            setState(() {
                              _errorMessage = null;
                            });
                            _pinController.clear();
                            _pinFocusNode.requestFocus();
                          },
                          icon: const Icon(Icons.refresh, size: 18),
                          label:
                              Text('Coba lagi', style: GoogleFonts.poppins()),
                          style: TextButton.styleFrom(
                            foregroundColor: TemaAplikasi.primary,
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Help link
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.help_outline,
                        color: Colors.white.withOpacity(0.9),
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tidak bisa akses authenticator?',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          print('🔐 [VERIFY-2FA] User membuka opsi pemulihan');
                          _showRecoveryOptions();
                        },
                        child: Text(
                          'Lihat opsi pemulihan',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Back to login
                TextButton.icon(
                  onPressed: _backToLogin,
                  icon: Icon(Icons.arrow_back,
                      color: Colors.white.withOpacity(0.9)),
                  label: Text(
                    'Kembali ke Login',
                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPinInput() {
    final defaultPinTheme = PinTheme(
      width: 48,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Color(0xFF00695C),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBDBDBD)),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00695C), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00695C).withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2F1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00695C)),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC62828)),
      ),
    );

    return Pinput(
      length: 6,
      controller: _pinController,
      focusNode: _pinFocusNode,
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: focusedPinTheme,
      submittedPinTheme: submittedPinTheme,
      errorPinTheme: errorPinTheme,
      pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
      showCursor: true,
      cursor: Container(
        width: 2,
        height: 24,
        decoration: BoxDecoration(
          color: const Color(0xFF00695C),
          borderRadius: BorderRadius.circular(1),
        ),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onCompleted: (pin) {
        print('🔐 [VERIFY-2FA] PIN input completed: ${pin.length} digit');
        // Auto verify when 6 digits entered
        if (!_isVerifying && _retryCount < _maxRetries) {
          _verifyCode();
        }
      },
    );
  }

  void _showRecoveryOptions() {
    print('🔐 [VERIFY-2FA] Menampilkan modal opsi pemulihan');
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFBDBDBD),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Icon(
              Icons.help_outline,
              size: 48,
              color: Color(0xFF00695C),
            ),
            const SizedBox(height: 16),
            const Text(
              'Opsi Pemulihan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 24),
            _buildRecoveryOption(
              icon: Icons.vpn_key,
              title: 'Gunakan Backup Code',
              subtitle: 'Masukkan kode backup yang disimpan saat setup',
              onTap: () {
                Navigator.pop(context);
                _showBackupCodeDialog();
              },
            ),
            const SizedBox(height: 12),
            _buildRecoveryOption(
              icon: Icons.support_agent,
              title: 'Hubungi Support',
              subtitle: 'Minta bantuan tim support untuk reset 2FA',
              onTap: () {
                Navigator.pop(context);
                _showSnackBar(
                  'Silakan hubungi support@aplikasiwarisan.com',
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Menampilkan dialog input backup code
  void _showBackupCodeDialog() {
    final backupCodeController = TextEditingController();
    bool isValidating = false;
    String? errorText;

    print('🔐 [VERIFY-2FA] Menampilkan dialog backup code');

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
                  color: const Color(0xFFE0F2F1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.vpn_key,
                  color: Color(0xFF00695C),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Backup Code',
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
                'Masukkan salah satu backup code yang Anda simpan saat mengaktifkan 2FA.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF424242),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: backupCodeController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'Backup Code',
                  labelStyle: const TextStyle(color: Color(0xFF616161)),
                  hintText: 'Contoh: ABCD1234',
                  hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                  errorText: errorText,
                  prefixIcon: const Icon(Icons.key, color: Color(0xFF00695C)),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
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
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 16,
                  letterSpacing: 2,
                  color: Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Backup code hanya bisa digunakan sekali.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFFE65100),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isValidating
                  ? null
                  : () {
                      print('🔐 [VERIFY-2FA] Dialog backup code dibatalkan');
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
                      final code = backupCodeController.text.trim();
                      print(
                          '🔐 [VERIFY-2FA] Validasi backup code: ${code.length} karakter');

                      if (code.isEmpty) {
                        setDialogState(() {
                          errorText = 'Backup code tidak boleh kosong';
                        });
                        return;
                      }

                      setDialogState(() {
                        isValidating = true;
                        errorText = null;
                      });

                      try {
                        print(
                            '🔐 [VERIFY-2FA] Mengirim backup code ke server...');
                        final result = await Layanan2FA.validateBackupCode(
                            widget.userId, code);
                        print(
                            '🔐 [VERIFY-2FA] Response backup code: valid=${result['valid']}');

                        if (result['valid'] == true) {
                          print(
                              '🟢 [VERIFY-2FA] Backup code valid! Navigasi ke halaman utama...');
                          Navigator.pop(dialogContext);

                          if (mounted) {
                            final penyediaAuth = Provider.of<PenyediaAuth>(
                                context,
                                listen: false);
                            await penyediaAuth.set2FAVerified(true);

                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (_) => const HalamanUtama()),
                              (route) => false,
                            );
                          }
                        } else {
                          print(
                              '🔴 [VERIFY-2FA] Backup code invalid: ${result['message']}');
                          setDialogState(() {
                            isValidating = false;
                            errorText =
                                result['message'] ?? 'Backup code tidak valid';
                          });
                        }
                      } catch (e) {
                        print(
                            '🔴 [VERIFY-2FA] Exception validasi backup code: $e');
                        setDialogState(() {
                          isValidating = false;
                          errorText = 'Terjadi kesalahan: ${e.toString()}';
                        });
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00695C),
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
                      'Verifikasi',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecoveryOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2F1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF00695C),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF616161),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF9E9E9E),
            ),
          ],
        ),
      ),
    );
  }
}
