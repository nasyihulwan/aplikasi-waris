import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../layanan/layanan_api.dart';
import '../layanan/layanan_2fa.dart';

/// Penyedia Autentikasi
/// Mengelola state autentikasi user termasuk login, logout, dan 2FA
class PenyediaAuth with ChangeNotifier {
  String? _idPengguna;
  String? _namaPengguna;
  String? _email;
  String? _nik;
  String? _tahunLahir;
  String? _tempatLahir;
  String? _alamat;
  String? _namaPewaris;
  String? _nikPewaris;
  String? _tahunLahirPewaris;
  String? _tempatLahirPewaris;
  bool _sudahLogin = false;
  String? _pesanError; // Untuk menyimpan pesan error

  // Two-Factor Authentication
  bool _twoFactorEnabled = false;
  bool _twoFactorVerified = false;
  bool _tanyakan2FA = true; // Flag untuk menanyakan 2FA

  // Secure storage untuk data sensitif
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  String? get idPengguna => _idPengguna;
  String? get namaPengguna => _namaPengguna;
  String? get email => _email;
  String? get nik => _nik;
  String? get tahunLahir => _tahunLahir;
  String? get tempatLahir => _tempatLahir;
  String? get alamat => _alamat;
  String? get namaPewaris => _namaPewaris;
  String? get nikPewaris => _nikPewaris;
  String? get tahunLahirPewaris => _tahunLahirPewaris;
  String? get tempatLahirPewaris => _tempatLahirPewaris;
  bool get sudahLogin => _sudahLogin;
  String? get pesanError => _pesanError;

  // Getters untuk 2FA
  bool get twoFactorEnabled => _twoFactorEnabled;
  bool get twoFactorVerified => _twoFactorVerified;
  bool get tanyakan2FA => _tanyakan2FA;

  // Flag untuk menandakan data sudah dimuat
  bool _sudahDimuat = false;
  bool get sudahDimuat => _sudahDimuat;

  // Konstruktor untuk load data dari storage
  PenyediaAuth() {
    print('👤 [PENYEDIA_AUTH] Inisialisasi PenyediaAuth');
    _muatDataPengguna();
  }

  /// Method untuk menunggu data selesai dimuat
  Future<void> tungguDataDimuat() async {
    // Tunggu sampai data dimuat (max 5 detik)
    int counter = 0;
    while (!_sudahDimuat && counter < 50) {
      await Future.delayed(const Duration(milliseconds: 100));
      counter++;
    }
    print(
        '👤 [PENYEDIA_AUTH] tungguDataDimuat selesai, sudahDimuat=$_sudahDimuat');
  }

  Future<void> _muatDataPengguna() async {
    print('👤 [PENYEDIA_AUTH] Memuat data pengguna dari storage...');

    final prefs = await SharedPreferences.getInstance();
    _idPengguna = prefs.getString('id_pengguna');
    _namaPengguna = prefs.getString('nama_pengguna');
    _email = prefs.getString('email');
    _nik = prefs.getString('nik');
    _tahunLahir = prefs.getString('tahun_lahir');
    _tempatLahir = prefs.getString('tempat_lahir');
    _alamat = prefs.getString('alamat');
    _namaPewaris = prefs.getString('nama_pewaris');
    _nikPewaris = prefs.getString('nik_pewaris');
    _tahunLahirPewaris = prefs.getString('tahun_lahir_pewaris');
    _tempatLahirPewaris = prefs.getString('tempat_lahir_pewaris');
    _sudahLogin = prefs.getBool('sudah_login') ?? false;
    _tanyakan2FA = prefs.getBool('tanyakan_2fa') ?? true;

    print('👤 [PENYEDIA_AUTH] Data SharedPreferences:');
    print('   - id_pengguna: $_idPengguna');
    print('   - nama_pengguna: $_namaPengguna');
    print('   - email: $_email');
    print('   - nik: $_nik');
    print('   - sudah_login: $_sudahLogin');
    print('   - tanyakan_2fa: $_tanyakan2FA');

    // Load 2FA status from secure storage
    try {
      final twoFactorEnabled = await _secureStorage.read(key: '2fa_enabled');
      final twoFactorVerified = await _secureStorage.read(key: '2fa_verified');
      _twoFactorEnabled = twoFactorEnabled == 'true';
      _twoFactorVerified = twoFactorVerified == 'true';

      print('👤 [PENYEDIA_AUTH] Data SecureStorage:');
      print('   - 2fa_enabled: $_twoFactorEnabled');
      print('   - 2fa_verified: $_twoFactorVerified');
    } catch (e) {
      print('🔴 [PENYEDIA_AUTH] Error loading 2FA status: $e');
    }

    _sudahDimuat = true;
    notifyListeners();
    print('🟢 [PENYEDIA_AUTH] Data pengguna berhasil dimuat');
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

        // Cek status 2FA dari response atau API
        await _cekStatus2FA();

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

  /// Cek status 2FA untuk user saat ini
  Future<void> _cekStatus2FA() async {
    if (_idPengguna == null) return;

    try {
      print('🔐 Mengecek status 2FA untuk user $_idPengguna');
      final result = await Layanan2FA.checkStatus(int.parse(_idPengguna!));

      if (result['two_factor_enabled'] == true) {
        _twoFactorEnabled = true;
        _twoFactorVerified = false; // Belum diverifikasi untuk sesi ini
        await _secureStorage.write(key: '2fa_enabled', value: 'true');
        print('🔐 2FA aktif untuk user ini');
      } else {
        _twoFactorEnabled = false;
        _twoFactorVerified = true; // Tidak perlu verifikasi
        await _secureStorage.write(key: '2fa_enabled', value: 'false');
        print('🔐 2FA tidak aktif untuk user ini');
      }
    } catch (e) {
      print('🔴 Error mengecek status 2FA: $e');
      // Default ke tidak aktif jika error
      _twoFactorEnabled = false;
      _twoFactorVerified = true;
    }
  }

  /// Set status 2FA verified (setelah user berhasil verifikasi OTP)
  Future<void> set2FAVerified(bool verified) async {
    print('👤 [PENYEDIA_AUTH] set2FAVerified dipanggil: verified=$verified');
    _twoFactorVerified = verified;
    await _secureStorage.write(key: '2fa_verified', value: verified.toString());
    print('🟢 [PENYEDIA_AUTH] 2FA verified status disimpan ke SecureStorage');
    notifyListeners();
  }

  /// Set 2FA enabled (setelah setup berhasil)
  Future<void> set2FAEnabled(bool enabled) async {
    print('👤 [PENYEDIA_AUTH] set2FAEnabled dipanggil: enabled=$enabled');
    _twoFactorEnabled = enabled;
    await _secureStorage.write(key: '2fa_enabled', value: enabled.toString());
    print('👤 [PENYEDIA_AUTH] 2FA enabled status disimpan ke SecureStorage');

    if (enabled) {
      _twoFactorVerified = true; // Langsung verified setelah setup
      await _secureStorage.write(key: '2fa_verified', value: 'true');
      print('🟢 [PENYEDIA_AUTH] 2FA diaktifkan dan langsung diverifikasi');
    } else {
      print('⚠️ [PENYEDIA_AUTH] 2FA dinonaktifkan');
    }
    notifyListeners();
  }

  /// Set preferensi "Jangan tanya lagi" untuk 2FA
  Future<void> setTanyakan2FA(bool tanyakan) async {
    print('👤 [PENYEDIA_AUTH] setTanyakan2FA dipanggil: tanyakan=$tanyakan');
    _tanyakan2FA = tanyakan;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tanyakan_2fa', tanyakan);
    print('🟢 [PENYEDIA_AUTH] Preferensi tanyakan 2FA disimpan');
    notifyListeners();
  }

  /// Cek apakah perlu redirect ke halaman verifikasi 2FA
  bool perluVerifikasi2FA() {
    final perlu = _twoFactorEnabled && !_twoFactorVerified;
    print(
        '👤 [PENYEDIA_AUTH] perluVerifikasi2FA: $perlu (enabled=$_twoFactorEnabled, verified=$_twoFactorVerified)');
    return perlu;
  }

  /// Cek apakah perlu menampilkan prompt setup 2FA
  bool perluPrompt2FA() {
    final perlu = !_twoFactorEnabled && _tanyakan2FA;
    print(
        '👤 [PENYEDIA_AUTH] perluPrompt2FA: $perlu (enabled=$_twoFactorEnabled, tanyakan=$_tanyakan2FA)');
    return perlu;
  }

  /// Ambil profil pengguna dari database
  Future<Map<String, dynamic>> ambilProfil() async {
    if (_idPengguna == null) {
      return {'sukses': false, 'pesan': 'ID Pengguna tidak ditemukan'};
    }

    print('👤 [PENYEDIA_AUTH] Mengambil profil dari server...');
    final hasil = await LayananApi.ambilProfil(int.parse(_idPengguna!));

    if (hasil['sukses'] == true) {
      print('🟢 [PENYEDIA_AUTH] Profil berhasil diambil');
    } else {
      print('🔴 [PENYEDIA_AUTH] Gagal mengambil profil: ${hasil['pesan']}');
    }

    return hasil;
  }

  /// Update profil pengguna
  Future<Map<String, dynamic>> updateProfil({
    required String nik,
    required String namaLengkap,
    required String tahunLahir,
    required String tempatLahir,
    required String alamat,
  }) async {
    if (_idPengguna == null) {
      return {'sukses': false, 'pesan': 'ID Pengguna tidak ditemukan'};
    }

    print('👤 [PENYEDIA_AUTH] Mengupdate profil...');
    print('   - nik: $nik');
    print('   - nama_lengkap: $namaLengkap');
    print('   - tahun_lahir: $tahunLahir');
    print('   - tempat_lahir: $tempatLahir');
    print('   - alamat: $alamat');

    final hasil = await LayananApi.updateProfil(
      idPengguna: int.parse(_idPengguna!),
      nik: nik,
      namaLengkap: namaLengkap,
      tahunLahir: tahunLahir,
      tempatLahir: tempatLahir,
      alamat: alamat,
    );

    if (hasil['sukses'] == true) {
      // Update local state
      _nik = nik;
      _namaPengguna = namaLengkap;
      _tahunLahir = tahunLahir;
      _tempatLahir = tempatLahir;
      _alamat = alamat;

      // Simpan ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('nik', nik);
      await prefs.setString('nama_pengguna', namaLengkap);
      await prefs.setString('tahun_lahir', tahunLahir);
      await prefs.setString('tempat_lahir', tempatLahir);
      await prefs.setString('alamat', alamat);

      print('🟢 [PENYEDIA_AUTH] Profil berhasil diupdate');
      notifyListeners();
    } else {
      print('🔴 [PENYEDIA_AUTH] Gagal update profil: ${hasil['pesan']}');
    }

    return hasil;
  }

  Future<void> logout() async {
    print('👤 [PENYEDIA_AUTH] Logout dipanggil');

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('👤 [PENYEDIA_AUTH] SharedPreferences dibersihkan');

    // Clear secure storage
    try {
      await _secureStorage.delete(key: '2fa_enabled');
      await _secureStorage.delete(key: '2fa_verified');
      print('👤 [PENYEDIA_AUTH] SecureStorage dibersihkan');
    } catch (e) {
      print('🔴 [PENYEDIA_AUTH] Error clearing secure storage: $e');
    }

    _idPengguna = null;
    _namaPengguna = null;
    _email = null;
    _nik = null;
    _tahunLahir = null;
    _tempatLahir = null;
    _alamat = null;
    _namaPewaris = null;
    _nikPewaris = null;
    _tahunLahirPewaris = null;
    _tempatLahirPewaris = null;
    _sudahLogin = false;
    _pesanError = null;
    _twoFactorEnabled = false;
    _twoFactorVerified = false;

    print('🟢 [PENYEDIA_AUTH] Logout berhasil, semua state direset');
    notifyListeners();
  }
}
