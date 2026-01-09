import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class LayananApi {
  static const String baseUrl = 'http://172.20.10.7/aplikasi_waris/backend_php';

  // ========== PRIVATE POST METHOD ==========

  static Future<Map<String, dynamic>> _post(
      String endpoint, Map<String, dynamic> body) async {
    try {
      final Map<String, String> stringBody = {};
      body.forEach((key, value) {
        stringBody[key] = value.toString();
      });

      final uri = Uri.parse('$baseUrl/$endpoint');
      print('🟡 API POST:  $uri');
      print('🟡 BODY: $stringBody');

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
          .timeout(const Duration(seconds: 30));

      print('🟢 STATUS: ${response.statusCode}');
      print('🟢 RESPONSE: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final decoded = json.decode(response.body);
          print('📦 DECODED: $decoded');
          return decoded;
        } catch (e) {
          print('🔴 JSON DECODE ERROR: $e');
          return {
            'sukses': false,
            'pesan': 'Error parsing response: ${e.toString()}'
          };
        }
      } else {
        print('🔴 HTTP ERROR: ${response.statusCode}');
        return {
          'sukses': false,
          'pesan': 'Server error: ${response.statusCode}'
        };
      }
    } on TimeoutException {
      print('🔴 TIMEOUT! ');
      return {'sukses': false, 'pesan': 'Koneksi timeout.  Cek jaringan Anda'};
    } on http.ClientException catch (e) {
      print('🔴 CLIENT EXCEPTION: $e');
      return {
        'sukses': false,
        'pesan': 'Gagal terhubung ke server. Pastikan XAMPP jalan dan IP benar.'
      };
    } catch (e) {
      print('🔴 EXCEPTION:  $e');
      return {'sukses': false, 'pesan': 'Error: ${e.toString()}'};
    }
  }

  // ========== PRIVATE POST JSON METHOD ==========

  static Future<Map<String, dynamic>> _postJson(
      String endpoint, Map<String, dynamic> body) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint');
      print('🟡 API POST JSON: $uri');
      print('🟡 BODY: $body');

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 30));

      print('🟢 STATUS: ${response.statusCode}');
      print('🟢 RESPONSE: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final decoded = json.decode(response.body);
          print('📦 DECODED: $decoded');
          return decoded;
        } catch (e) {
          print('🔴 JSON DECODE ERROR: $e');
          return {
            'sukses': false,
            'pesan': 'Error parsing response: ${e.toString()}'
          };
        }
      } else {
        print('🔴 HTTP ERROR: ${response.statusCode}');
        return {
          'sukses': false,
          'pesan': 'Server error: ${response.statusCode}'
        };
      }
    } on TimeoutException {
      print('🔴 TIMEOUT!');
      return {'sukses': false, 'pesan': 'Koneksi timeout. Cek jaringan Anda'};
    } on http.ClientException catch (e) {
      print('🔴 CLIENT EXCEPTION: $e');
      return {
        'sukses': false,
        'pesan': 'Gagal terhubung ke server. Pastikan Laragon jalan.'
      };
    } catch (e) {
      print('🔴 EXCEPTION: $e');
      return {'sukses': false, 'pesan': 'Error: ${e.toString()}'};
    }
  }

  // ========== AUTHENTICATION ==========

  static Future<Map<String, dynamic>> daftar({
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
  }) {
    return _post('daftar.php', {
      'nama_lengkap': namaLengkap,
      'email': email,
      'password': password,
      'tahun_lahir': tahunLahir,
      'tempat_lahir': tempatLahir,
      'alamat': alamat,
      'nik': nik,
      'nama_pewaris': namaPewaris,
      'tahun_lahir_pewaris': tahunLahirPewaris,
      'tempat_lahir_pewaris': tempatLahirPewaris,
      'nik_pewaris': nikPewaris,
    });
  }

  static Future<Map<String, dynamic>> login(String email, String password) {
    return _post('login.php', {'email': email, 'password': password});
  }

  // ========== AHLI WARIS - CRUD ==========

  static Future<Map<String, dynamic>> tambahAhliWaris({
    required String nikPewaris,
    required int idPengusul,
    required String namaLengkap,
    required String nik,
    required String email,
    required String hubungan,
    required String jenisKelamin,
  }) {
    return _post('ahli_waris_tambah.php', {
      'nik_pewaris': nikPewaris,
      'id_pengusul': idPengusul.toString(),
      'nama_lengkap': namaLengkap,
      'nik': nik,
      'email': email,
      'hubungan': hubungan,
      'jenis_kelamin': jenisKelamin,
    });
  }

  static Future<Map<String, dynamic>> ambilAhliWaris(String nikPewaris) {
    return _post('ahli_waris_ambil.php', {'nik_pewaris': nikPewaris});
  }

  static Future<Map<String, dynamic>> editAhliWaris({
    required String idAhliWaris,
    required String namaLengkap,
    required String hubungan,
    required String jenisKelamin,
  }) {
    return _post('ahli_waris_edit.php', {
      'id': idAhliWaris,
      'nama_lengkap': namaLengkap,
      'hubungan': hubungan,
      'jenis_kelamin': jenisKelamin,
    });
  }

  static Future<Map<String, dynamic>> hapusAhliWaris(String id) {
    return _post('ahli_waris_hapus.php', {'id': id});
  }

  // ========== AHLI WARIS - VERIFIKASI ==========

  static Future<Map<String, dynamic>> verifikasiAhliWaris({
    required int idAhliWaris,
    required int idVerifikator,
    required String status,
    String? keterangan,
  }) {
    return _post('ahli_waris_verifikasi.php', {
      'id_ahli_waris': idAhliWaris.toString(),
      'id_verifikator': idVerifikator.toString(),
      'status': status,
      if (keterangan != null && keterangan.isNotEmpty) 'keterangan': keterangan,
    });
  }

  // ========== ASET - CRUD ==========

  static Future<Map<String, dynamic>> tambahAset({
    required String nikPewaris,
    required int idPengusul,
    required String namaAset,
    required String jenisAset,
    required double nilai,
    String? lokasi,
    String? keterangan,
    List<String>? filePaths,
  }) {
    return _post('aset_tambah.php', {
      'nik_pewaris': nikPewaris,
      'id_pengusul': idPengusul.toString(),
      'nama_aset': namaAset,
      'jenis_aset': jenisAset,
      'nilai': nilai.toString(),
      if (lokasi != null && lokasi.isNotEmpty) 'lokasi': lokasi,
      if (keterangan != null && keterangan.isNotEmpty) 'keterangan': keterangan,
    });
  }

  static Future<Map<String, dynamic>> ambilAset(String nikPewaris) {
    return _post('aset_ambil.php', {'nik_pewaris': nikPewaris});
  }

  static Future<Map<String, dynamic>> editAset({
    required String id,
    required String namaAset,
    required String jenisAset,
    required double nilai,
    String? lokasi,
    String? keterangan,
  }) {
    return _postJson('aset_edit.php', {
      'id': int.tryParse(id) ?? id,
      'nama_aset': namaAset,
      'jenis_aset': jenisAset,
      'nilai': nilai,
      'keterangan': keterangan ?? '',
    });
  }

  static Future<Map<String, dynamic>> hapusAset(String id) {
    return _post('aset_hapus.php', {'id': id});
  }

  // ========== ASET - VERIFIKASI ==========

  static Future<Map<String, dynamic>> verifikasiAset({
    required int idAset,
    required int idVerifikator,
    required String status,
    String? keterangan,
  }) {
    return _post('verifikasi_aset.php', {
      'id_aset': idAset.toString(),
      'id_verifikator': idVerifikator.toString(),
      'status': status,
      if (keterangan != null && keterangan.isNotEmpty) 'keterangan': keterangan,
    });
  }

  // ========== RIWAYAT PERHITUNGAN ==========

  static Future<Map<String, dynamic>> simpanPerhitungan(
      String nikPewaris, Map<String, dynamic> hasil) {
    return _post('riwayat_simpan.php', {
      'nik_pewaris': nikPewaris,
      'data_perhitungan': json.encode(hasil),
    });
  }

  static Future<Map<String, dynamic>> ambilRiwayat(String nikPewaris) {
    return _post('riwayat_ambil.php', {'nik_pewaris': nikPewaris});
  }

  // ========== PROFIL PENGGUNA ==========

  /// Mengambil data profil pengguna berdasarkan ID
  static Future<Map<String, dynamic>> ambilProfil(int idPengguna) {
    return _postJson('profil_ambil.php', {'user_id': idPengguna});
  }

  /// Update profil pengguna
  static Future<Map<String, dynamic>> updateProfil({
    required int idPengguna,
    required String nik,
    required String namaLengkap,
    required String tahunLahir,
    required String tempatLahir,
    required String alamat,
  }) {
    return _postJson('profil_update.php', {
      'user_id': idPengguna,
      'nik': nik,
      'nama_lengkap': namaLengkap,
      'tahun_lahir': tahunLahir,
      'tempat_lahir': tempatLahir,
      'alamat': alamat,
    });
  }
}
