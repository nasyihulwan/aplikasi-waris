import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import '../layanan/layanan_2fa.dart';
import '../penyedia/penyedia_auth.dart';
import '../layar/halaman_setup_2fa.dart';

/// Widget untuk menampilkan dan mengelola pengaturan 2FA
/// Dapat diintegrasikan ke halaman Settings atau Profile
class Pengaturan2FA extends StatefulWidget {
  const Pengaturan2FA({super.key});

  @override
  State<Pengaturan2FA> createState() => _Pengaturan2FAState();
}

class _Pengaturan2FAState extends State<Pengaturan2FA> {
  final bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<PenyediaAuth>(
      builder: (context, auth, _) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00796B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.security,
                      color: Color(0xFF00796B),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Two-Factor Authentication',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Keamanan ekstra untuk akun Anda',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),

              // Status 2FA
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        auth.twoFactorEnabled
                            ? Icons.check_circle
                            : Icons.cancel,
                        color:
                            auth.twoFactorEnabled ? Colors.green : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        auth.twoFactorEnabled ? '2FA Aktif' : '2FA Tidak Aktif',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: auth.twoFactorEnabled
                              ? Colors.green.shade700
                              : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF00796B),
                          ),
                        )
                      : Switch(
                          value: auth.twoFactorEnabled,
                          onChanged: (value) => _toggle2FA(auth, value),
                          activeThumbColor: const Color(0xFF00796B),
                        ),
                ],
              ),

              const SizedBox(height: 16),

              // Info box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: auth.twoFactorEnabled
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: auth.twoFactorEnabled
                        ? Colors.green.shade200
                        : Colors.orange.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      auth.twoFactorEnabled
                          ? Icons.verified_user
                          : Icons.warning,
                      color: auth.twoFactorEnabled
                          ? Colors.green.shade700
                          : Colors.orange.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        auth.twoFactorEnabled
                            ? 'Akun Anda dilindungi dengan autentikasi dua faktor menggunakan Google Authenticator.'
                            : 'Aktifkan 2FA untuk melindungi akun Anda dari akses tidak sah.',
                        style: TextStyle(
                          fontSize: 13,
                          color: auth.twoFactorEnabled
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Button untuk setup jika belum aktif
              if (!auth.twoFactorEnabled) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _setupTwoFactor(auth),
                    icon: const Icon(Icons.qr_code, size: 20),
                    label: const Text('Setup 2FA Sekarang'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00796B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// Toggle 2FA on/off
  void _toggle2FA(PenyediaAuth auth, bool enable) {
    if (enable) {
      _setupTwoFactor(auth);
    } else {
      _disableTwoFactor(auth);
    }
  }

  /// Navigate ke halaman setup 2FA
  void _setupTwoFactor(PenyediaAuth auth) {
    if (auth.idPengguna != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => HalamanSetup2FA(
            userId: int.parse(auth.idPengguna!),
            namaUser: auth.namaPengguna,
            emailUser: auth.email,
          ),
        ),
      );
    }
  }

  /// Nonaktifkan 2FA
  void _disableTwoFactor(PenyediaAuth auth) {
    showDialog(
      context: context,
      builder: (context) => _DialogNonaktifkan2FA(
        userId: int.parse(auth.idPengguna!),
        onSuccess: () async {
          await auth.set2FAEnabled(false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('2FA berhasil dinonaktifkan'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      ),
    );
  }
}

/// Dialog untuk konfirmasi nonaktifkan 2FA
class _DialogNonaktifkan2FA extends StatefulWidget {
  final int userId;
  final VoidCallback onSuccess;

  const _DialogNonaktifkan2FA({
    required this.userId,
    required this.onSuccess,
  });

  @override
  State<_DialogNonaktifkan2FA> createState() => _DialogNonaktifkan2FAState();
}

class _DialogNonaktifkan2FAState extends State<_DialogNonaktifkan2FA> {
  final TextEditingController _pinController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _konfirmasi() async {
    final code = _pinController.text.trim();

    if (code.length != 6) {
      setState(() {
        _errorMessage = 'Masukkan kode 6 digit';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await Layanan2FA.disable(widget.userId, code);

      if (result['success'] == true) {
        Navigator.of(context).pop();
        widget.onSuccess();
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Gagal menonaktifkan 2FA';
          _isLoading = false;
        });
        _pinController.clear();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 40,
      height: 48,
      textStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF00796B),
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
    );

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Text(
        'Nonaktifkan 2FA',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning,
                  color: Colors.orange.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Menonaktifkan 2FA akan mengurangi keamanan akun Anda.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Masukkan kode dari Authenticator untuk konfirmasi:',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          Pinput(
            length: 6,
            controller: _pinController,
            defaultPinTheme: defaultPinTheme,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onCompleted: (_) => _konfirmasi(),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _konfirmasi,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Nonaktifkan',
                  style: TextStyle(color: Colors.white),
                ),
        ),
      ],
    );
  }
}
