import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../penyedia/penyedia_auth.dart';
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
                      penyediaAuth.pesanError ?? 'Email atau password salah'),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFC62828),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
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
                  'Aktifkan 2FA?',
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
                'Tambahkan lapisan keamanan ekstra untuk akun Anda dengan Two-Factor Authentication.',
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
                    Icon(Icons.info_outline,
                        color: Color(0xFF1565C0), size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Gunakan Google Authenticator untuk kode verifikasi.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF1565C0),
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
                      activeColor: const Color(0xFF00695C),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Jangan tanya lagi',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF424242),
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
              child: const Text(
                'Nanti Saja',
                style: TextStyle(color: Color(0xFF616161)),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00695C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Ya, Aktifkan',
                style: TextStyle(color: Colors.white),
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
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF00695C), Color(0xFF004D40)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.account_balance,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Selamat Datang',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Masuk ke akun Anda',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x40000000),
                          blurRadius: 10,
                          offset: Offset(0, 4),
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
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle:
                                  const TextStyle(color: Color(0xFF616161)),
                              prefixIcon: const Icon(Icons.email,
                                  color: Color(0xFF00695C)),
                              filled: true,
                              fillColor: const Color(0xFFF5F5F5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFF00695C), width: 2),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Color(0xFFC62828)),
                              ),
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
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle:
                                  const TextStyle(color: Color(0xFF616161)),
                              prefixIcon: const Icon(Icons.lock,
                                  color: Color(0xFF00695C)),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _sembunyiPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: const Color(0xFF757575),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _sembunyiPassword = !_sembunyiPassword;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF5F5F5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFF00695C), width: 2),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Color(0xFFC62828)),
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
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00695C),
                                disabledBackgroundColor:
                                    const Color(0xFFBDBDBD),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _sedangMemuat
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Masuk',
                                      style: TextStyle(
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
                              const Text(
                                'Belum punya akun? ',
                                style: TextStyle(color: Color(0xFF616161)),
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
                                child: const Text(
                                  'Daftar Sekarang',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF00695C),
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
