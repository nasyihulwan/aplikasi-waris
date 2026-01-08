import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../layanan/layanan_api.dart';

class PenyediaAuth with ChangeNotifier {
  String? _idPengguna;
  String? _namaPengguna;
  String? _email;
  String? _namaPewaris;
  String? _nikPewaris;
  String? _tahunLahirPewaris;
  String? _tempatLahirPewaris;
  bool _sudahLogin = false;
  String? _pesanError; // Untuk menyimpan pesan error

  String? get idPengguna => _idPengguna;
  String? get namaPengguna => _namaPengguna;
  String? get email => _email;
  String? get namaPewaris => _namaPewaris;
  String? get nikPewaris => _nikPewaris;
  String? get tahunLahirPewaris => _tahunLahirPewaris;
  String? get tempatLahirPewaris => _tempatLahirPewaris;
  bool get sudahLogin => _sudahLogin;
  String? get pesanError => _pesanError;

  // Konstruktor untuk load data dari storage
  PenyediaAuth() {
    _muatDataPengguna();
  }

  Future<void> _muatDataPengguna() async {
    final prefs = await SharedPreferences.getInstance();
    _idPengguna = prefs.getString('id_pengguna');
    _namaPengguna = prefs.getString('nama_pengguna');
    _email = prefs.getString('email');
    _namaPewaris = prefs.getString('nama_pewaris');
    _nikPewaris = prefs.getString('nik_pewaris');
    _tahunLahirPewaris = prefs.getString('tahun_lahir_pewaris');
    _tempatLahirPewaris = prefs.getString('tempat_lahir_pewaris');
    _sudahLogin = prefs.getBool('sudah_login') ?? false;
    notifyListeners();
  }

  Future<bool> daftar({
    required String namaLengkap,
    required String email,
    required String password,
    required String tahunLahir,
    required String tempatLahir,
    required String alamat,
    required String nik,
    required String namaPewaris,
    required String tahunLahirPewaris,
    required String tempatLahirPewaris,
    required String nikPewaris,
  }) async {
    try {
      print('🟡 PENYEDIA AUTH: Memulai proses daftar');
      print('📧 Email: $email');
      print('👤 Nama: $namaLengkap');
      print('🆔 NIK: $nik (${nik.length} digit)');
      print('🆔 NIK Pewaris: $nikPewaris (${nikPewaris.length} digit)');

      // Validasi di sisi client juga
      if (nik.length != 16) {
        _pesanError = 'NIK harus 16 digit';
        print('❌ VALIDASI GAGAL: $_pesanError');
        notifyListeners();
        return false;
      }

      if (nikPewaris.length != 16) {
        _pesanError = 'NIK Pewaris harus 16 digit';
        print('❌ VALIDASI GAGAL: $_pesanError');
        notifyListeners();
        return false;
      }

      if (password.length < 6) {
        _pesanError = 'Password minimal 6 karakter';
        print('❌ VALIDASI GAGAL: $_pesanError');
        notifyListeners();
        return false;
      }

      final hasil = await LayananApi.daftar(
        namaLengkap: namaLengkap,
        email: email,
        password: password,
        tahunLahir: tahunLahir,
        tempatLahir: tempatLahir,
        alamat: alamat,
        nik: nik,
        namaPewaris: namaPewaris,
        tahunLahirPewaris: tahunLahirPewaris,
        tempatLahirPewaris: tempatLahirPewaris,
        nikPewaris: nikPewaris,
      );

      print('🟢 PENYEDIA AUTH: Hasil API diterima');
      print('✅ Sukses: ${hasil['sukses']}');
      print('📝 Pesan: ${hasil['pesan']}');

      if (hasil['sukses'] == true) {
        print('🟢 PENYEDIA AUTH: Pendaftaran berhasil!');
        _pesanError = null;

        // Simpan data jika ada
        if (hasil.containsKey('id_pengguna')) {
          _idPengguna = hasil['id_pengguna'].toString();
          _namaPengguna = namaLengkap;
          _email = email;
          _namaPewaris = namaPewaris;
          _nikPewaris = nikPewaris;
          _tahunLahirPewaris = tahunLahirPewaris;
          _tempatLahirPewaris = tempatLahirPewaris;

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('id_pengguna', _idPengguna!);
          await prefs.setString('nama_pengguna', _namaPengguna!);
          await prefs.setString('email', _email!);
          await prefs.setString('nama_pewaris', _namaPewaris!);
          await prefs.setString('nik_pewaris', _nikPewaris!);
          await prefs.setString('tahun_lahir_pewaris', _tahunLahirPewaris!);
          await prefs.setString('tempat_lahir_pewaris', _tempatLahirPewaris!);

          print('💾 Data berhasil disimpan ke SharedPreferences');
        }

        notifyListeners();
        return true;
      } else {
        _pesanError = hasil['pesan'] ?? 'Pendaftaran gagal';
        print('❌ PENYEDIA AUTH: Pendaftaran gagal - $_pesanError');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _pesanError = 'Error: ${e.toString()}';
      print('🔴 PENYEDIA AUTH ERROR: $e');
      print('Stack trace: ${StackTrace.current}');
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      print('🟡 PENYEDIA AUTH: Memulai proses login');
      print('📧 Email: $email');

      final hasil = await LayananApi.login(email, password);

      print('🟢 PENYEDIA AUTH: Hasil login diterima');
      print('✅ Sukses: ${hasil['sukses']}');

      if (hasil['sukses'] == true) {
        _idPengguna = hasil['id_pengguna'].toString();
        _namaPengguna = hasil['nama_pengguna'];
        _email = email;
        _namaPewaris = hasil['nama_pewaris'];
        _nikPewaris = hasil['nik_pewaris'];
        _tahunLahirPewaris = hasil['tahun_lahir_pewaris'];
        _tempatLahirPewaris = hasil['tempat_lahir_pewaris'];
        _sudahLogin = true;
        _pesanError = null;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('id_pengguna', _idPengguna!);
        await prefs.setString('nama_pengguna', _namaPengguna!);
        await prefs.setString('email', _email!);
        await prefs.setString('nama_pewaris', _namaPewaris!);
        await prefs.setString('nik_pewaris', _nikPewaris!);
        await prefs.setString('tahun_lahir_pewaris', _tahunLahirPewaris!);
        await prefs.setString('tempat_lahir_pewaris', _tempatLahirPewaris!);
        await prefs.setBool('sudah_login', true);

        print('💾 Data login berhasil disimpan');
        notifyListeners();
        return true;
      } else {
        _pesanError = hasil['pesan'] ?? 'Login gagal';
        print('❌ Login gagal: $_pesanError');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _pesanError = 'Error: ${e.toString()}';
      print('🔴 Error login: $e');
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _idPengguna = null;
    _namaPengguna = null;
    _email = null;
    _namaPewaris = null;
    _nikPewaris = null;
    _tahunLahirPewaris = null;
    _tempatLahirPewaris = null;
    _sudahLogin = false;
    _pesanError = null;

    notifyListeners();
  }
}
