import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../penyedia/penyedia_auth.dart';

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
        const SnackBar(
          content: Text('✅ Pendaftaran berhasil! Silakan login'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Pendaftaran gagal. Periksa kembali data Anda'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        obscureText: isPassword ? _sembunyiPassword : false,
        keyboardType: keyboardType ??
            (isNumber ? TextInputType.number : TextInputType.text),
        inputFormatters:
            isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
        maxLength: maxLength,
        validator: (v) {
          if (v == null || v.trim().isEmpty) return '$label wajib diisi';
          if (isEmail && !v.contains('@')) return 'Email tidak valid';
          if (isPassword && v.length < 6) return 'Password minimal 6 karakter';
          if (maxLength != null && v.trim().length != maxLength) {
            return '$label harus $maxLength karakter';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          counterText: '', // Hilangkan counter text
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _sembunyiPassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Akun Baru'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
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
                  color: const Color(0xFF00796B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF00796B)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Color(0xFF00796B), size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Data Pendaftar (Anda)',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00796B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Isi data diri Anda sebagai ahli waris',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              input(nama, 'Nama Lengkap Anda'),
              input(email, 'Email Anda',
                  isEmail: true, keyboardType: TextInputType.emailAddress),
              input(password, 'Password (min. 6 karakter)', isPassword: true),
              input(tempatLahir, 'Tempat Lahir Anda'),
              input(tahunLahir, 'Tahun Lahir Anda (YYYY)',
                  isNumber: true, maxLength: 4),
              input(alamat, 'Alamat Lengkap Anda',
                  keyboardType: TextInputType.multiline),
              input(nik, 'NIK Anda (16 digit)', isNumber: true, maxLength: 16),

              const SizedBox(height: 32),
              const Divider(thickness: 2),
              const SizedBox(height: 20),

              // Header untuk Data Pewaris
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person_outline, color: Colors.orange, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Data Pewaris (Yang Meninggal)',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[900],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Isi data orang yang meninggal dunia',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

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
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : daftar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00796B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Daftar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Info tambahan
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pastikan data yang Anda isi benar. NIK harus 16 digit angka.',
                        style: TextStyle(fontSize: 12, color: Colors.blue[900]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
