import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import '../layanan/layanan_2fa.dart';
import 'halaman_utama.dart';

/// Halaman untuk setup Two-Factor Authentication (2FA)
/// Menampilkan QR Code untuk di-scan dengan Google Authenticator
/// dan field input untuk verifikasi kode OTP
class HalamanSetup2FA extends StatefulWidget {
  final int userId;
  final String? namaUser;
  final String? emailUser;

  const HalamanSetup2FA({
    super.key,
    required this.userId,
    this.namaUser,
    this.emailUser,
  });

  @override
  State<HalamanSetup2FA> createState() => _HalamanSetup2FAState();
}

class _HalamanSetup2FAState extends State<HalamanSetup2FA> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();

  bool _isLoadingQR = true;
  bool _isVerifying = false;
  String? _qrCodeBase64;
  String? _secretKey;
  String? _errorMessage;
  List<String>? _backupCodes;

  @override
  void initState() {
    super.initState();
    print(
        '🔐 [SETUP-2FA] Halaman setup 2FA diinisialisasi untuk user ${widget.userId}');
    _loadQRCode();
  }

  @override
  void dispose() {
    print('🔐 [SETUP-2FA] Halaman setup 2FA ditutup');
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  /// Memuat QR Code dari API
  Future<void> _loadQRCode() async {
    print('🔐 [SETUP-2FA] Memulai loading QR Code...');
    setState(() {
      _isLoadingQR = true;
      _errorMessage = null;
    });

    try {
      final result = await Layanan2FA.setup(widget.userId);
      print(
          '🔐 [SETUP-2FA] Response dari API setup: success=${result['success']}');

      if (result['success'] == true) {
        setState(() {
          _qrCodeBase64 = result['qr_code'];
          _secretKey = result['secret'];
          _isLoadingQR = false;
        });
        print('🟢 [SETUP-2FA] QR Code berhasil dimuat');
        print('🔐 [SETUP-2FA] Secret key tersedia: ${_secretKey != null}');

        // Auto focus ke input field setelah QR Code dimuat
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _pinFocusNode.requestFocus();
          }
        });
      } else {
        print('🔴 [SETUP-2FA] Gagal memuat QR Code: ${result['message']}');
        setState(() {
          _errorMessage = result['message'] ?? 'Gagal memuat QR Code';
          _isLoadingQR = false;
        });
      }
    } catch (e) {
      print('🔴 [SETUP-2FA] Exception saat loading QR Code: $e');
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoadingQR = false;
      });
    }
  }

  /// Verifikasi kode OTP dan aktifkan 2FA
  Future<void> _verifyAndActivate() async {
    final code = _pinController.text.trim();
    print(
        '🔐 [SETUP-2FA] Memulai verifikasi dengan kode: ${code.length} digit');

    // Validasi input
    if (code.length != 6) {
      print('🔴 [SETUP-2FA] Validasi gagal: kode bukan 6 digit');
      _showSnackBar('Masukkan kode 6 digit', isError: true);
      return;
    }

    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      print('🔴 [SETUP-2FA] Validasi gagal: kode bukan angka');
      _showSnackBar('Kode harus berupa angka', isError: true);
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      print('🔐 [SETUP-2FA] Mengirim kode verifikasi ke server...');
      final result = await Layanan2FA.verify(widget.userId, code);
      print('🔐 [SETUP-2FA] Response verifikasi: success=${result['success']}');

      if (result['success'] == true) {
        print('🟢 [SETUP-2FA] Verifikasi berhasil! Generating backup codes...');

        // Generate backup codes
        final backupResult =
            await Layanan2FA.generateBackupCodes(widget.userId);
        if (backupResult['success'] == true &&
            backupResult['backup_codes'] != null) {
          _backupCodes = List<String>.from(backupResult['backup_codes']);
          print(
              '🟢 [SETUP-2FA] ${_backupCodes!.length} backup codes berhasil dibuat');
        }

        // Tampilkan dialog sukses dengan backup codes
        if (mounted) {
          await _showSuccessDialog();
        }
      } else {
        print('🔴 [SETUP-2FA] Verifikasi gagal: ${result['message']}');
        setState(() {
          _errorMessage = result['message'] ?? 'Verifikasi gagal';
          _isVerifying = false;
        });
        _showSnackBar(_errorMessage!, isError: true);
        _pinController.clear();
        _pinFocusNode.requestFocus();
      }
    } catch (e) {
      print('🔴 [SETUP-2FA] Exception saat verifikasi: $e');
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isVerifying = false;
      });
      _showSnackBar(_errorMessage!, isError: true);
    }
  }

  /// Menampilkan dialog sukses
  Future<void> _showSuccessDialog() async {
    print('🔐 [SETUP-2FA] Menampilkan dialog sukses dengan backup codes');
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 64,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '2FA Berhasil Diaktifkan!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Akun Anda sekarang lebih aman dengan Two-Factor Authentication.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF424242),
                ),
                textAlign: TextAlign.center,
              ),

              // Backup codes section
              if (_backupCodes != null && _backupCodes!.isNotEmpty) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFF9800)),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: Color(0xFFE65100), size: 24),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'SIMPAN BACKUP CODES!',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFE65100),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Simpan kode-kode ini di tempat aman. Gunakan untuk login jika kehilangan akses ke Google Authenticator.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF424242),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: _backupCodes!
                              .map((code) => Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: Text(
                                      code,
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1B5E20),
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _copyAllBackupCodes,
                        icon: const Icon(Icons.copy, size: 18),
                        label: const Text('Salin Semua Kode'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF00695C),
                          side: const BorderSide(color: Color(0xFF00695C)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                print('🔐 [SETUP-2FA] User melanjutkan ke halaman utama');
                Navigator.of(context).pop(); // Tutup dialog
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HalamanUtama()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00695C),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Lanjutkan',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Salin semua backup codes ke clipboard
  void _copyAllBackupCodes() {
    if (_backupCodes != null) {
      final allCodes = _backupCodes!.join('\n');
      Clipboard.setData(ClipboardData(text: allCodes));
      print('🔐 [SETUP-2FA] Semua backup codes disalin ke clipboard');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Backup codes berhasil disalin!'),
            ],
          ),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  /// Menampilkan snackbar
  void _showSnackBar(String message, {bool isError = false}) {
    print('🔐 [SETUP-2FA] Menampilkan snackbar: $message (error: $isError)');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor:
            isError ? const Color(0xFFC62828) : const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Menyalin secret key ke clipboard
  void _copySecretKey() {
    if (_secretKey != null) {
      Clipboard.setData(ClipboardData(text: _secretKey!));
      print('🔐 [SETUP-2FA] Secret key disalin ke clipboard');
      _showSnackBar('Kode setup berhasil disalin ke clipboard');
    }
  }

  /// Decode base64 QR Code image
  Uint8List? _decodeQRCode() {
    if (_qrCodeBase64 == null) return null;

    try {
      // Hapus prefix "data:image/png;base64," jika ada
      String base64String = _qrCodeBase64!;
      if (base64String.contains(',')) {
        base64String = base64String.split(',').last;
      }
      return base64Decode(base64String);
    } catch (e) {
      print('Error decoding QR Code: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup 2FA'),
        backgroundColor: const Color(0xFF00695C),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2F1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF80CBC4)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00695C),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.security,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Two-Factor Authentication',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00695C),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Tambahkan lapisan keamanan ekstra',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF424242),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // QR Code Section
            if (_isLoadingQR)
              _buildLoadingQR()
            else if (_errorMessage != null && _qrCodeBase64 == null)
              _buildErrorQR()
            else
              _buildQRCode(),

            const SizedBox(height: 32),

            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF64B5F6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: const Color(0xFF1565C0)),
                      const SizedBox(width: 8),
                      Text(
                        'Cara Mengaktifkan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1565C0),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInstructionStep(
                    '1',
                    'Download Google Authenticator dari Play Store atau App Store',
                  ),
                  _buildInstructionStep(
                    '2',
                    'Buka aplikasi dan scan QR Code di atas',
                  ),
                  _buildInstructionStep(
                    '3',
                    'Masukkan kode 6 digit yang muncul di aplikasi',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // PIN Input
            const Text(
              'Masukkan Kode dari Authenticator',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 16),
            _buildPinInput(),

            const SizedBox(height: 24),

            // Verify Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    (_isVerifying || _isLoadingQR || _qrCodeBase64 == null)
                        ? null
                        : _verifyAndActivate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00695C),
                  disabledBackgroundColor: const Color(0xFFBDBDBD),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isVerifying
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Verifikasi & Aktifkan 2FA',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Skip button
            TextButton(
              onPressed: () {
                print('🔐 [SETUP-2FA] User melewati setup 2FA');
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HalamanUtama()),
                  (route) => false,
                );
              },
              child: const Text(
                'Lewati untuk sekarang',
                style: TextStyle(
                  color: Color(0xFF616161),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingQR() {
    return Container(
      height: 200,
      width: 200,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xFF00695C),
            ),
            SizedBox(height: 16),
            Text(
              'Memuat QR Code...',
              style: TextStyle(
                color: Color(0xFF616161),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorQR() {
    return Container(
      height: 200,
      width: 200,
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEF9A9A)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Color(0xFFC62828),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Gagal memuat QR Code',
              style: const TextStyle(
                color: Color(0xFFC62828),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _loadQRCode,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Coba Lagi'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF00695C),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRCode() {
    final qrBytes = _decodeQRCode();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: qrBytes != null
              ? Image.memory(
                  qrBytes,
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    print(
                        '🔴 [SETUP-2FA] Error menampilkan QR Code image: $error');
                    return Container(
                      width: 200,
                      height: 200,
                      color: const Color(0xFFF5F5F5),
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 48,
                          color: Color(0xFF757575),
                        ),
                      ),
                    );
                  },
                )
              : Container(
                  width: 200,
                  height: 200,
                  color: const Color(0xFFF5F5F5),
                  child: const Center(
                    child: Icon(
                      Icons.qr_code,
                      size: 48,
                      color: Color(0xFF757575),
                    ),
                  ),
                ),
        ),

        const SizedBox(height: 16),

        // Manual entry instructions
        if (_secretKey != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF81C784)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.smartphone, color: Color(0xFF2E7D32), size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tidak Bisa Scan QR Code?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Salin kode di bawah ini dan masukkan secara manual di Google Authenticator:',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF424242),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '1. Buka Google Authenticator\n2. Tap tombol + (tambah)\n3. Pilih "Enter a setup key"\n4. Masukkan nama akun dan kode berikut',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF616161),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF81C784)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.key, size: 18, color: Color(0xFF2E7D32)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SelectableText(
                          _secretKey!,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1B5E20),
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _copySecretKey,
                        icon: const Icon(Icons.copy, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        color: const Color(0xFF00695C),
                        tooltip: 'Salin kode setup',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFF1565C0),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Color(0xFF424242),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinInput() {
    final defaultPinTheme = PinTheme(
      width: 50,
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
        print('🔐 [SETUP-2FA] PIN input completed: ${pin.length} digit');
        // Auto verify when 6 digits entered
        if (!_isVerifying && !_isLoadingQR && _qrCodeBase64 != null) {
          _verifyAndActivate();
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Kode tidak boleh kosong';
        }
        if (value.length != 6) {
          return 'Kode harus 6 digit';
        }
        return null;
      },
    );
  }
}
