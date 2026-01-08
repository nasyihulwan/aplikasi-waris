import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../penyedia/penyedia_auth.dart';
import '../tema/tema_aplikasi.dart';
import 'halaman_daftar.dart';
import 'halaman_utama.dart';
import 'halaman_setup_2fa.dart';
import 'halaman_verifikasi_2fa.dart';

/// Halaman Login
/// Halaman untuk login user ke aplikasi
class HalamanLogin extends StatefulWidget {
  const HalamanLogin({super.key});

  @override
  _HalamanLoginState createState() => _HalamanLoginState();
}

class _HalamanLoginState extends State<HalamanLogin> {
  final _kunciForm = GlobalKey<FormState>();
  final _pengendaliEmail = TextEditingController();
  final _pengendaliPassword = TextEditingController();
  bool _sembunyiPassword = true;
  bool _sedangMemuat = false;

  @override
  void initState() {
    super.initState();
    print('🔑 [LOGIN] Halaman login diinisialisasi');
  }

  @override
  void dispose() {
    print('🔑 [LOGIN] Halaman login di-dispose');
    _pengendaliEmail.dispose();
    _pengendaliPassword.dispose();
    super.dispose();
  }

  Future<void> _prosesLogin() async {
    if (_kunciForm.currentState!.validate()) {
      print('🔑 [LOGIN] Validasi form berhasil, memulai proses login...');
      print('🔑 [LOGIN] Email: ${_pengendaliEmail.text}');

      setState(() => _sedangMemuat = true);

      final penyediaAuth = Provider.of<PenyediaAuth>(context, listen: false);
      final berhasil = await penyediaAuth.login(
        _pengendaliEmail.text,
        _pengendaliPassword.text,
      );

      setState(() => _sedangMemuat = false);

      print('🔑 [LOGIN] Hasil login: berhasil=$berhasil');

      if (berhasil) {
        // Cek apakah perlu verifikasi 2FA
        print('🔑 [LOGIN] Cek status 2FA...');
        print(
            '🔑 [LOGIN] perluVerifikasi2FA: ${penyediaAuth.perluVerifikasi2FA()}');
        print('🔑 [LOGIN] perluPrompt2FA: ${penyediaAuth.perluPrompt2FA()}');

        if (penyediaAuth.perluVerifikasi2FA()) {
          print('🔑 [LOGIN] Navigate ke halaman verifikasi 2FA');
          // Navigate ke halaman verifikasi 2FA
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => HalamanVerifikasi2FA(
                  userId: int.parse(penyediaAuth.idPengguna!),
                  namaUser: penyediaAuth.namaPengguna,
                  emailUser: penyediaAuth.email,
                ),
              ),
            );
          }
        } else if (penyediaAuth.perluPrompt2FA()) {
          print('🔑 [LOGIN] Tampilkan dialog prompt setup 2FA');
          // Tampilkan dialog untuk setup 2FA
          if (mounted) {
            _tampilkanDialog2FA(penyediaAuth);
          }
        } else {
          print('🔑 [LOGIN] Navigate langsung ke halaman utama');
          // Langsung ke halaman utama
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HalamanUtama()),
            );
          }
        }
      } else {
        print('🔴 [LOGIN] Login gagal: ${penyediaAuth.pesanError}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                      penyediaAuth.pesanError ?? 'Email atau password salah',
                      style: GoogleFonts.poppins()),
                ),
              ],
            ),
            backgroundColor: TemaAplikasi.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } else {
      print('🔴 [LOGIN] Validasi form gagal');
    }
  }

  /// Menampilkan dialog untuk setup 2FA
  void _tampilkanDialog2FA(PenyediaAuth penyediaAuth) {
    bool jgTanyaLagi = false;
    print('🔑 [LOGIN] Menampilkan dialog prompt 2FA');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: TemaAplikasi.gradientPrimaryLinear,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.security,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Aktifkan 2FA?',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: TemaAplikasi.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tambahkan lapisan keamanan ekstra untuk akun Anda dengan Two-Factor Authentication.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: TemaAplikasi.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: TemaAplikasi.infoLightBox,
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: TemaAplikasi.info, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Gunakan Google Authenticator untuk kode verifikasi.',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: TemaAplikasi.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: jgTanyaLagi,
                      onChanged: (value) {
                        setDialogState(() {
                          jgTanyaLagi = value ?? false;
                        });
                      },
                      activeColor: TemaAplikasi.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Jangan tanya lagi',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: TemaAplikasi.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                print('🔑 [LOGIN] User memilih "Nanti Saja" untuk 2FA');
                Navigator.of(context).pop();
                if (jgTanyaLagi) {
                  print('🔑 [LOGIN] Set tanyakan 2FA = false');
                  await penyediaAuth.setTanyakan2FA(false);
                }
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const HalamanUtama()),
                );
              },
              child: Text(
                'Nanti Saja',
                style: GoogleFonts.poppins(color: TemaAplikasi.textTertiary),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                print('🔑 [LOGIN] User memilih "Ya, Aktifkan" untuk 2FA');
                Navigator.of(context).pop();
                if (jgTanyaLagi) {
                  print('🔑 [LOGIN] Set tanyakan 2FA = false');
                  await penyediaAuth.setTanyakan2FA(false);
                }
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => HalamanSetup2FA(
                      userId: int.parse(penyediaAuth.idPengguna!),
                      namaUser: penyediaAuth.namaPengguna,
                      emailUser: penyediaAuth.email,
                    ),
                  ),
                );
              },
              style: TemaAplikasi.primaryButton,
              child: Text(
                'Ya, Aktifkan',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('🔑 [LOGIN] Build halaman login');

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: TemaAplikasi.gradientPrimaryLinear,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo dengan animasi
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Selamat Datang',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Masuk ke akun Anda',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 40),
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
                    child: Form(
                      key: _kunciForm,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _pengendaliEmail,
                            keyboardType: TextInputType.emailAddress,
                            style: GoogleFonts.poppins(),
                            decoration: TemaAplikasi.inputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icons.email_outlined,
                            ),
                            validator: (nilai) {
                              if (nilai == null || nilai.isEmpty) {
                                return 'Email harus diisi';
                              }
                              if (!nilai.contains('@')) {
                                return 'Email tidak valid';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _pengendaliPassword,
                            obscureText: _sembunyiPassword,
                            style: GoogleFonts.poppins(),
                            decoration: TemaAplikasi.inputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icons.lock_outline,
                            ).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _sembunyiPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: TemaAplikasi.textTertiary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _sembunyiPassword = !_sembunyiPassword;
                                  });
                                },
                              ),
                            ),
                            validator: (nilai) {
                              if (nilai == null || nilai.isEmpty) {
                                return 'Password harus diisi';
                              }
                              if (nilai.length < 6) {
                                return 'Password minimal 6 karakter';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _sedangMemuat ? null : _prosesLogin,
                              style: TemaAplikasi.primaryButton,
                              child: _sedangMemuat
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Masuk',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Belum punya akun? ',
                                style: GoogleFonts.poppins(
                                  color: TemaAplikasi.textSecondary,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  print(
                                      '🔑 [LOGIN] Navigate ke halaman daftar');
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const HalamanDaftar(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Daftar Sekarang',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    color: TemaAplikasi.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
