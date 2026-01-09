import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

/// Service class untuk Two-Factor Authentication (2FA)
/// Menangani komunikasi dengan backend PHP untuk fitur 2FA
class Layanan2FA {
  // Base URL untuk API 2FA
  // Development: localhost
  // Production: ganti dengan URL server
  static const String baseUrl = 'http://localhost/aplikasi_waris/auth/2fa.php';

  // Timeout untuk request API
  static const Duration _timeout = Duration(seconds: 30);

  /// Private method untuk melakukan POST request
  static Future<Map<String, dynamic>> _post(
    String action,
    Map<String, dynamic> body,
  ) async {
    try {
      final Map<String, String> stringBody = {};
      body.forEach((key, value) {
        stringBody[key] = value.toString();
      });

      final uri = Uri.parse('$baseUrl?action=$action');
      print('🔐 2FA API POST: $uri');
      print('🔐 2FA BODY: $stringBody');

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded',
              'Accept': 'application/json',
            },
            body: stringBody,
            encoding: Encoding.getByName('utf-8'),
          )
          .timeout(_timeout);

      print('🔐 2FA STATUS: ${response.statusCode}');
      print('🔐 2FA RESPONSE: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final decoded = json.decode(response.body);
          print('🔐 2FA DECODED: $decoded');
          return decoded;
        } catch (e) {
          print('🔴 2FA JSON DECODE ERROR: $e');
          return {
            'success': false,
            'message': 'Error parsing response: ${e.toString()}'
          };
        }
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        print('🔴 2FA CLIENT ERROR: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Request error: ${response.statusCode}'
        };
      } else if (response.statusCode >= 500) {
        print('🔴 2FA SERVER ERROR: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}'
        };
      } else {
        return {
          'success': false,
          'message': 'Unexpected status: ${response.statusCode}'
        };
      }
    } on TimeoutException {
      print('🔴 2FA TIMEOUT!');
      return {
        'success': false,
        'message': 'Koneksi timeout. Periksa jaringan Anda.'
      };
    } on http.ClientException catch (e) {
      print('🔴 2FA CLIENT EXCEPTION: $e');
      return {
        'success': false,
        'message': 'Gagal terhubung ke server. Pastikan server berjalan.'
      };
    } catch (e) {
      print('🔴 2FA EXCEPTION: $e');
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  /// Private method untuk melakukan GET request
  static Future<Map<String, dynamic>> _get(
    String action,
    Map<String, String> queryParams,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl?action=$action').replace(
        queryParameters: {'action': action, ...queryParams},
      );
      print('🔐 2FA API GET: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(_timeout);

      print('🔐 2FA STATUS: ${response.statusCode}');
      print('🔐 2FA RESPONSE: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final decoded = json.decode(response.body);
          print('🔐 2FA DECODED: $decoded');
          return decoded;
        } catch (e) {
          print('🔴 2FA JSON DECODE ERROR: $e');
          return {
            'success': false,
            'message': 'Error parsing response: ${e.toString()}'
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}'
        };
      }
    } on TimeoutException {
      print('🔴 2FA TIMEOUT!');
      return {
        'success': false,
        'message': 'Koneksi timeout. Periksa jaringan Anda.'
      };
    } on http.ClientException catch (e) {
      print('🔴 2FA CLIENT EXCEPTION: $e');
      return {
        'success': false,
        'message': 'Gagal terhubung ke server. Pastikan server berjalan.'
      };
    } catch (e) {
      print('🔴 2FA EXCEPTION: $e');
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  /// Setup 2FA untuk user
  /// Menghasilkan QR Code dan secret key
  ///
  /// [userId] - ID pengguna yang akan mengaktifkan 2FA
  ///
  /// Returns:
  /// - success: bool
  /// - secret: String (secret key untuk backup)
  /// - qr_code: String (base64 encoded QR Code image)
  /// - user: Map (informasi user)
  static Future<Map<String, dynamic>> setup(int userId) async {
    print('🔐 2FA: Memulai setup untuk user $userId');
    return _post('setup', {'user_id': userId});
  }

  /// Verifikasi dan aktifkan 2FA
  /// Dipanggil setelah user scan QR Code dan memasukkan kode OTP
  ///
  /// [userId] - ID pengguna
  /// [code] - Kode 6 digit dari Google Authenticator
  ///
  /// Returns:
  /// - success: bool
  /// - message: String
  static Future<Map<String, dynamic>> verify(int userId, String code) async {
    print('🔐 2FA: Memverifikasi kode untuk user $userId');

    // Validasi input
    if (code.isEmpty) {
      return {'success': false, 'message': 'Kode tidak boleh kosong'};
    }
    if (code.length != 6) {
      return {'success': false, 'message': 'Kode harus 6 digit'};
    }
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      return {'success': false, 'message': 'Kode harus berupa angka'};
    }

    return _post('verify', {
      'user_id': userId,
      'code': code,
    });
  }

  /// Validasi kode OTP saat login
  /// Dipanggil setelah user berhasil login dengan email/password
  ///
  /// [userId] - ID pengguna
  /// [code] - Kode 6 digit dari Google Authenticator
  ///
  /// Returns:
  /// - valid: bool
  /// - message: String
  static Future<Map<String, dynamic>> validate(int userId, String code) async {
    print('🔐 2FA: Memvalidasi kode login untuk user $userId');

    // Validasi input
    if (code.isEmpty) {
      return {'valid': false, 'message': 'Kode tidak boleh kosong'};
    }
    if (code.length != 6) {
      return {'valid': false, 'message': 'Kode harus 6 digit'};
    }
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      return {'valid': false, 'message': 'Kode harus berupa angka'};
    }

    return _post('validate', {
      'user_id': userId,
      'code': code,
    });
  }

  /// Cek status 2FA user
  /// Untuk mengetahui apakah user sudah mengaktifkan 2FA
  ///
  /// [userId] - ID pengguna
  ///
  /// Returns:
  /// - two_factor_enabled: bool
  static Future<Map<String, dynamic>> checkStatus(int userId) async {
    print('🔐 2FA: Mengecek status untuk user $userId');
    return _get('status', {'user_id': userId.toString()});
  }

  /// Nonaktifkan 2FA
  /// Dipanggil ketika user ingin menonaktifkan 2FA
  ///
  /// [userId] - ID pengguna
  /// [code] - Kode 6 digit untuk konfirmasi
  ///
  /// Returns:
  /// - success: bool
  /// - message: String
  static Future<Map<String, dynamic>> disable(int userId, String code) async {
    print('🔐 [2FA-DISABLE] Memulai proses nonaktifkan 2FA untuk user $userId');
    print('🔐 [2FA-DISABLE] Kode verifikasi diterima: ${code.length} digit');

    // Validasi input
    if (code.isEmpty) {
      print('🔴 [2FA-DISABLE] GAGAL: Kode kosong');
      return {'success': false, 'message': 'Kode tidak boleh kosong'};
    }
    if (code.length != 6) {
      print(
          '🔴 [2FA-DISABLE] GAGAL: Kode bukan 6 digit (${code.length} digit)');
      return {'success': false, 'message': 'Kode harus 6 digit'};
    }
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      print('🔴 [2FA-DISABLE] GAGAL: Kode bukan angka');
      return {'success': false, 'message': 'Kode harus berupa angka'};
    }

    print(
        '🔐 [2FA-DISABLE] Validasi lokal berhasil, mengirim request ke server...');
    final result = await _post('disable', {
      'user_id': userId,
      'code': code,
    });

    if (result['success'] == true) {
      print(
          '🟢 [2FA-DISABLE] SUKSES: 2FA berhasil dinonaktifkan untuk user $userId');
    } else {
      print('🔴 [2FA-DISABLE] GAGAL dari server: ${result['message']}');
    }

    return result;
  }

  /// Validasi backup code untuk pemulihan akun
  /// Digunakan ketika user tidak bisa akses authenticator
  ///
  /// [userId] - ID pengguna
  /// [backupCode] - Kode backup 8 karakter
  ///
  /// Returns:
  /// - valid: bool
  /// - message: String
  static Future<Map<String, dynamic>> validateBackupCode(
    int userId,
    String backupCode,
  ) async {
    print('🔐 [2FA-BACKUP] Memulai validasi backup code untuk user $userId');
    print('🔐 [2FA-BACKUP] Panjang backup code: ${backupCode.length} karakter');

    // Validasi input
    if (backupCode.isEmpty) {
      print('🔴 [2FA-BACKUP] GAGAL: Backup code kosong');
      return {'valid': false, 'message': 'Backup code tidak boleh kosong'};
    }

    // Backup code biasanya 8 karakter alfanumerik
    final cleanCode =
        backupCode.replaceAll('-', '').replaceAll(' ', '').toUpperCase();
    print('🔐 [2FA-BACKUP] Backup code setelah dibersihkan: $cleanCode');

    if (cleanCode.length != 8) {
      print(
          '🔴 [2FA-BACKUP] GAGAL: Panjang backup code tidak valid (${cleanCode.length} karakter)');
      return {'valid': false, 'message': 'Backup code harus 8 karakter'};
    }

    if (!RegExp(r'^[A-Z0-9]{8}$').hasMatch(cleanCode)) {
      print('🔴 [2FA-BACKUP] GAGAL: Format backup code tidak valid');
      return {
        'valid': false,
        'message': 'Backup code hanya boleh huruf dan angka'
      };
    }

    print(
        '🔐 [2FA-BACKUP] Validasi lokal berhasil, mengirim request ke server...');
    final result = await _post('validate_backup', {
      'user_id': userId,
      'backup_code': cleanCode,
    });

    if (result['valid'] == true) {
      print('🟢 [2FA-BACKUP] SUKSES: Backup code valid untuk user $userId');
    } else {
      print('🔴 [2FA-BACKUP] GAGAL dari server: ${result['message']}');
    }

    return result;
  }

  /// Generate backup codes untuk user
  /// Dipanggil setelah setup 2FA berhasil
  ///
  /// [userId] - ID pengguna
  ///
  /// Returns:
  /// - success: bool
  /// - backup_codes: List<String> (array of backup codes)
  static Future<Map<String, dynamic>> generateBackupCodes(int userId) async {
    print('🔐 [2FA-BACKUP] Memulai generate backup codes untuk user $userId');

    final result = await _post('generate_backup', {'user_id': userId});

    if (result['success'] == true) {
      final codes = result['backup_codes'];
      print(
          '🟢 [2FA-BACKUP] SUKSES: ${codes?.length ?? 0} backup codes berhasil dibuat');
    } else {
      print(
          '🔴 [2FA-BACKUP] GAGAL generate backup codes: ${result['message']}');
    }

    return result;
  }

  /// Get existing backup codes untuk user (masked)
  /// Untuk menampilkan backup codes yang sudah ada
  ///
  /// [userId] - ID pengguna
  ///
  /// Returns:
  /// - success: bool
  /// - backup_codes: List<String>
  /// - used_codes: int (jumlah code yang sudah digunakan)
  static Future<Map<String, dynamic>> getBackupCodes(int userId) async {
    print('🔐 [2FA-BACKUP] Mengambil daftar backup codes untuk user $userId');

    final result =
        await _get('get_backup_codes', {'user_id': userId.toString()});

    if (result['success'] == true) {
      print('🟢 [2FA-BACKUP] SUKSES: Backup codes berhasil diambil');
    } else {
      print(
          '🔴 [2FA-BACKUP] GAGAL mengambil backup codes: ${result['message']}');
    }

    return result;
  }
}
