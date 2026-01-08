import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../penyedia/penyedia_auth.dart';
import '../tema/tema_aplikasi.dart';

class HalamanDaftar extends StatefulWidget {
  const HalamanDaftar({super.key});

  @override
  State<HalamanDaftar> createState() => _HalamanDaftarState();
}

class _HalamanDaftarState extends State<HalamanDaftar> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _sembunyiPassword = true; // Untuk toggle show/hide password

  // Data Pendaftar (Ahli Waris)
  final nama = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final tahunLahir = TextEditingController();
  final tempatLahir = TextEditingController();
  final alamat = TextEditingController();
  final nik = TextEditingController();

  // Data Pewaris (Orang yang Meninggal)
  final namaPewaris = TextEditingController();
  final tahunLahirPewaris = TextEditingController();
  final tempatLahirPewaris = TextEditingController();
  final nikPewaris = TextEditingController();

  @override
  void dispose() {
    // Bersihkan controller
    nama.dispose();
    email.dispose();
    password.dispose();
    tahunLahir.dispose();
    tempatLahir.dispose();
    alamat.dispose();
    nik.dispose();
    namaPewaris.dispose();
    tahunLahirPewaris.dispose();
    tempatLahirPewaris.dispose();
    nikPewaris.dispose();
    super.dispose();
  }

  Future<void> daftar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final auth = context.read<PenyediaAuth>();
    final sukses = await auth.daftar(
      namaLengkap: nama.text.trim(),
      email: email.text.trim(),
      password: password.text,
      tahunLahir: tahunLahir.text.trim(),
      tempatLahir: tempatLahir.text.trim(),
      alamat: alamat.text.trim(),
      nik: nik.text.trim(),
      namaPewaris: namaPewaris.text.trim(),
      tahunLahirPewaris: tahunLahirPewaris.text.trim(),
      tempatLahirPewaris: tempatLahirPewaris.text.trim(),
      nikPewaris: nikPewaris.text.trim(),
    );

    setState(() => _loading = false);

    if (sukses) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 8),
              Text('Pendaftaran berhasil! Silakan login',
                  style: GoogleFonts.poppins()),
            ],
          ),
          backgroundColor: TemaAplikasi.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Pendaftaran gagal. Periksa kembali data Anda',
                    style: GoogleFonts.poppins()),
              ),
            ],
          ),
          backgroundColor: TemaAplikasi.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget input(
    TextEditingController c,
    String label, {
    bool isEmail = false,
    bool isPassword = false,
    bool isNumber = false,
    int? maxLength,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: c,
        obscureText: isPassword ? _sembunyiPassword : false,
        keyboardType: keyboardType ??
            (isNumber ? TextInputType.number : TextInputType.text),
        inputFormatters:
            isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
        maxLength: maxLength,
        style: GoogleFonts.poppins(),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return '$label wajib diisi';
          if (isEmail && !v.contains('@')) return 'Email tidak valid';
          if (isPassword && v.length < 6) return 'Password minimal 6 karakter';
          if (maxLength != null && v.trim().length != maxLength) {
            return '$label harus $maxLength karakter';
          }
          return null;
        },
        decoration: TemaAplikasi.inputDecoration(
          labelText: label,
          prefixIcon: _getIconForField(label, isEmail, isPassword),
        ).copyWith(
          counterText: '',
          suffixIcon: isPassword
              ? IconButton(
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
                )
              : null,
        ),
      ),
    );
  }

  IconData _getIconForField(String label, bool isEmail, bool isPassword) {
    if (isEmail) return Icons.email_outlined;
    if (isPassword) return Icons.lock_outline;
    if (label.toLowerCase().contains('nama')) return Icons.person_outline;
    if (label.toLowerCase().contains('tahun'))
      return Icons.calendar_today_outlined;
    if (label.toLowerCase().contains('tempat')) return Icons.place_outlined;
    if (label.toLowerCase().contains('alamat')) return Icons.home_outlined;
    if (label.toLowerCase().contains('nik')) return Icons.badge_outlined;
    return Icons.edit_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header dengan gradient
          Container(
            decoration: BoxDecoration(
              gradient: TemaAplikasi.gradientPrimaryLinear,
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 20, 20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon:
                          const Icon(Icons.arrow_back_ios, color: Colors.white),
                    ),
                    Expanded(
                      child: Text(
                        'Daftar Akun Baru',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header untuk Data Pendaftar
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            TemaAplikasi.primary.withOpacity(0.1),
                            TemaAplikasi.primaryDark.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: TemaAplikasi.primary.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: TemaAplikasi.gradientPrimaryLinear,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.person,
                                color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Data Pendaftar (Anda)',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: TemaAplikasi.primaryDark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Isi data diri Anda sebagai ahli waris',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: TemaAplikasi.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    input(nama, 'Nama Lengkap Anda'),
                    input(email, 'Email Anda',
                        isEmail: true,
                        keyboardType: TextInputType.emailAddress),
                    input(password, 'Password (min. 6 karakter)',
                        isPassword: true),
                    input(tempatLahir, 'Tempat Lahir Anda'),
                    input(tahunLahir, 'Tahun Lahir Anda (YYYY)',
                        isNumber: true, maxLength: 4),
                    input(alamat, 'Alamat Lengkap Anda',
                        keyboardType: TextInputType.multiline),
                    input(nik, 'NIK Anda (16 digit)',
                        isNumber: true, maxLength: 16),

                    const SizedBox(height: 24),

                    // Divider dengan style
                    Row(
                      children: [
                        Expanded(
                            child: Container(
                                height: 1, color: TemaAplikasi.divider)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Icon(Icons.arrow_downward,
                              color: TemaAplikasi.textTertiary, size: 20),
                        ),
                        Expanded(
                            child: Container(
                                height: 1, color: TemaAplikasi.divider)),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Header untuk Data Pewaris
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            TemaAplikasi.warning.withOpacity(0.15),
                            TemaAplikasi.warning.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: TemaAplikasi.warning.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: TemaAplikasi.warning,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.person_outline,
                                color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Data Pewaris (Yang Meninggal)',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFE65100),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Isi data orang yang meninggal dunia',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: TemaAplikasi.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    input(namaPewaris, 'Nama Lengkap Pewaris'),
                    input(tempatLahirPewaris, 'Tempat Lahir Pewaris'),
                    input(tahunLahirPewaris, 'Tahun Lahir Pewaris (YYYY)',
                        isNumber: true, maxLength: 4),
                    input(nikPewaris, 'NIK Pewaris (16 digit)',
                        isNumber: true, maxLength: 16),

                    const SizedBox(height: 24),

                    // Tombol Daftar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : daftar,
                        style: TemaAplikasi.primaryButton,
                        child: _loading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Daftar Sekarang',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Info tambahan
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: TemaAplikasi.infoLightBox,
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: TemaAplikasi.info, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Pastikan data yang Anda isi benar. NIK harus 16 digit angka.',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: TemaAplikasi.info,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
