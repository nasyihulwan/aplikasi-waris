import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../layanan/layanan_api.dart';
import 'penyedia_auth.dart';

// Navigator key untuk akses context
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class PenyediaWarisan extends ChangeNotifier {
  List<Map<String, dynamic>> _daftarAhliWaris = [];
  List<Map<String, dynamic>> _daftarAset = [];
  bool _sedangMemuat = false;
  String? _pesanError;

  // Getters
  List<Map<String, dynamic>> get daftarAhliWaris => _daftarAhliWaris;
  List<Map<String, dynamic>> get daftarAset => _daftarAset;
  bool get sedangMemuat => _sedangMemuat;
  String? get pesanError => _pesanError;

  // ========== AHLI WARIS ==========

  Future<void> muatAhliWaris(String nikPewaris) async {
    try {
      _sedangMemuat = true;
      _pesanError = null;
      notifyListeners();

      print('🟡 PENYEDIA WARISAN: Memuat ahli waris untuk NIK: $nikPewaris');

      final hasil = await LayananApi.ambilAhliWaris(nikPewaris);

      print('🟢 PENYEDIA WARISAN:  Hasil ambil ahli waris');
      print('✅ Sukses: ${hasil['sukses']}');

      if (hasil['sukses'] == true) {
        if (hasil['data'] != null) {
          _daftarAhliWaris = List<Map<String, dynamic>>.from(hasil['data']);
          print('📋 Jumlah ahli waris:  ${_daftarAhliWaris.length}');
        } else {
          _daftarAhliWaris = [];
        }
        _pesanError = null;
      } else {
        _pesanError = hasil['pesan'];
        _daftarAhliWaris = [];
      }
    } catch (e) {
      print('🔴 Error muat ahli waris: $e');
      _pesanError = 'Error: ${e.toString()}';
      _daftarAhliWaris = [];
    } finally {
      _sedangMemuat = false;
      notifyListeners();
    }
  }

  Future<bool> tambahAhliWaris({
    required BuildContext context,
    required String nikPewaris,
    required String namaLengkap,
    required String hubungan,
    required String jenisKelamin,
  }) async {
    try {
      _sedangMemuat = true;
      notifyListeners();

      print('🟡 PENYEDIA WARISAN:  Tambah ahli waris');
      print('📋 Nama:  $namaLengkap');

      // Dapatkan id_pengusul dari PenyediaAuth
      final penyediaAuth = Provider.of<PenyediaAuth>(context, listen: false);

      final hasil = await LayananApi.tambahAhliWaris(
        nikPewaris: nikPewaris,
        idPengusul: int.parse(penyediaAuth.idPengguna!),
        namaLengkap: namaLengkap,
        nik: '',
        email: '',
        hubungan: hubungan,
        jenisKelamin: jenisKelamin,
      );

      print('🟢 PENYEDIA WARISAN:  Hasil tambah ahli waris');
      print('✅ Sukses: ${hasil['sukses']}');
      print('📝 Pesan: ${hasil['pesan']}');

      if (hasil['sukses'] == true) {
        await muatAhliWaris(nikPewaris);
        _pesanError = null;
        return true;
      } else {
        _pesanError = hasil['pesan'];
        return false;
      }
    } catch (e) {
      print('🔴 Error tambah ahli waris: $e');
      _pesanError = 'Error: ${e.toString()}';
      return false;
    } finally {
      _sedangMemuat = false;
      notifyListeners();
    }
  }

  Future<bool> editAhliWaris({
    required String idAhliWaris,
    required String namaLengkap,
    required String hubungan,
    required String jenisKelamin,
    required String nikPewaris,
  }) async {
    try {
      _sedangMemuat = true;
      notifyListeners();

      print('🟡 PENYEDIA WARISAN: Edit ahli waris ID: $idAhliWaris');

      final hasil = await LayananApi.editAhliWaris(
        idAhliWaris: idAhliWaris,
        namaLengkap: namaLengkap,
        hubungan: hubungan,
        jenisKelamin: jenisKelamin,
      );

      print('🟢 PENYEDIA WARISAN: Hasil edit ahli waris');
      print('✅ Sukses: ${hasil['sukses']}');
      print('📝 Pesan:  ${hasil['pesan']}');

      if (hasil['sukses'] == true) {
        await muatAhliWaris(nikPewaris);
        _pesanError = null;
        return true;
      } else {
        _pesanError = hasil['pesan'];
        return false;
      }
    } catch (e) {
      print('🔴 Error edit ahli waris: $e');
      _pesanError = 'Error: ${e.toString()}';
      return false;
    } finally {
      _sedangMemuat = false;
      notifyListeners();
    }
  }

  Future<bool> hapusAhliWaris({
    required String idAhliWaris,
    required String nikPewaris,
  }) async {
    try {
      _sedangMemuat = true;
      notifyListeners();

      print('🟡 PENYEDIA WARISAN: Hapus ahli waris ID: $idAhliWaris');

      final hasil = await LayananApi.hapusAhliWaris(idAhliWaris);

      print('🟢 PENYEDIA WARISAN: Hasil hapus ahli waris');
      print('✅ Sukses: ${hasil['sukses']}');
      print('📝 Pesan: ${hasil['pesan']}');

      if (hasil['sukses'] == true) {
        await muatAhliWaris(nikPewaris);
        _pesanError = null;
        return true;
      } else {
        _pesanError = hasil['pesan'];
        return false;
      }
    } catch (e) {
      print('🔴 Error hapus ahli waris: $e');
      _pesanError = 'Error: ${e.toString()}';
      return false;
    } finally {
      _sedangMemuat = false;
      notifyListeners();
    }
  }

  Future<bool> verifikasiAhliWaris({
    required int idAhliWaris,
    required int idVerifikator,
    required String status,
    String? keterangan,
    required String nikPewaris,
  }) async {
    try {
      print('🟡 PENYEDIA WARISAN: Verifikasi ahli waris ID: $idAhliWaris');

      final hasil = await LayananApi.verifikasiAhliWaris(
        idAhliWaris: idAhliWaris,
        idVerifikator: idVerifikator,
        status: status,
        keterangan: keterangan,
      );

      print('🟢 PENYEDIA WARISAN: Hasil verifikasi ahli waris');
      print('✅ Sukses: ${hasil['sukses']}');
      print('📝 Pesan: ${hasil['pesan']}');

      if (hasil['sukses'] == true) {
        await muatAhliWaris(nikPewaris);
        _pesanError = null;
        return true;
      } else {
        _pesanError = hasil['pesan'];
        return false;
      }
    } catch (e) {
      print('🔴 Error verifikasi ahli waris: $e');
      _pesanError = 'Error: ${e.toString()}';
      return false;
    }
  }

  // ========== ASET ==========

  Future<void> muatAset(String nikPewaris) async {
    try {
      _sedangMemuat = true;
      _pesanError = null;
      notifyListeners();

      print('🟡 PENYEDIA WARISAN: Memuat aset untuk NIK: $nikPewaris');

      final hasil = await LayananApi.ambilAset(nikPewaris);

      print('🟢 PENYEDIA WARISAN:  Hasil ambil aset');
      print('✅ Sukses: ${hasil['sukses']}');

      if (hasil['sukses'] == true) {
        if (hasil['data'] != null) {
          _daftarAset = List<Map<String, dynamic>>.from(hasil['data']);
          print('📋 Jumlah aset: ${_daftarAset.length}');
        } else {
          _daftarAset = [];
        }
        _pesanError = null;
      } else {
        _pesanError = hasil['pesan'];
        _daftarAset = [];
      }
    } catch (e) {
      print('🔴 Error muat aset: $e');
      _pesanError = 'Error: ${e.toString()}';
      _daftarAset = [];
    } finally {
      _sedangMemuat = false;
      notifyListeners();
    }
  }

  Future<bool> tambahAset({
    required BuildContext context,
    required String nikPewaris,
    required String namaAset,
    required String jenisAset,
    required double nilai,
    String? keterangan,
    List<String>? filePaths,
  }) async {
    try {
      _sedangMemuat = true;
      notifyListeners();

      print('🟡 PENYEDIA WARISAN: Tambah aset');
      print('📋 Nama Aset: $namaAset');

      // Dapatkan id_pengusul dari PenyediaAuth
      final penyediaAuth = Provider.of<PenyediaAuth>(context, listen: false);

      final hasil = await LayananApi.tambahAset(
        nikPewaris: nikPewaris,
        idPengusul: int.parse(penyediaAuth.idPengguna!),
        namaAset: namaAset,
        jenisAset: jenisAset,
        nilai: nilai,
        lokasi: '',
        keterangan: keterangan,
        filePaths: filePaths,
      );

      print('🟢 PENYEDIA WARISAN: Hasil tambah aset');
      print('✅ Sukses: ${hasil['sukses']}');
      print('📝 Pesan: ${hasil['pesan']}');

      if (hasil['sukses'] == true) {
        await muatAset(nikPewaris);
        _pesanError = null;
        return true;
      } else {
        _pesanError = hasil['pesan'];
        return false;
      }
    } catch (e) {
      print('🔴 Error tambah aset: $e');
      _pesanError = 'Error: ${e.toString()}';
      return false;
    } finally {
      _sedangMemuat = false;
      notifyListeners();
    }
  }

  Future<bool> editAset({
    required String id,
    required String namaAset,
    required String jenisAset,
    required double nilai,
    String? keterangan,
    required String nikPewaris,
  }) async {
    try {
      _sedangMemuat = true;
      notifyListeners();

      print('🟡 PENYEDIA WARISAN: Edit aset ID: $id');

      final hasil = await LayananApi.editAset(
        id: id,
        namaAset: namaAset,
        jenisAset: jenisAset,
        nilai: nilai,
        lokasi: '',
        keterangan: keterangan,
      );

      print('🟢 PENYEDIA WARISAN:  Hasil edit aset');
      print('✅ Sukses: ${hasil['sukses']}');
      print('📝 Pesan: ${hasil['pesan']}');

      if (hasil['sukses'] == true) {
        await muatAset(nikPewaris);
        _pesanError = null;
        return true;
      } else {
        _pesanError = hasil['pesan'];
        return false;
      }
    } catch (e) {
      print('🔴 Error edit aset: $e');
      _pesanError = 'Error:  ${e.toString()}';
      return false;
    } finally {
      _sedangMemuat = false;
      notifyListeners();
    }
  }

  Future<bool> hapusAset({
    required String idAset,
    required String nikPewaris,
  }) async {
    try {
      _sedangMemuat = true;
      notifyListeners();

      print('🟡 PENYEDIA WARISAN: Hapus aset ID: $idAset');

      final hasil = await LayananApi.hapusAset(idAset);

      print('🟢 PENYEDIA WARISAN: Hasil hapus aset');
      print('✅ Sukses: ${hasil['sukses']}');
      print('📝 Pesan: ${hasil['pesan']}');

      if (hasil['sukses'] == true) {
        await muatAset(nikPewaris);
        _pesanError = null;
        return true;
      } else {
        _pesanError = hasil['pesan'];
        return false;
      }
    } catch (e) {
      print('🔴 Error hapus aset: $e');
      _pesanError = 'Error: ${e.toString()}';
      return false;
    } finally {
      _sedangMemuat = false;
      notifyListeners();
    }
  }

  Future<bool> verifikasiAset({
    required int idAset,
    required int idVerifikator,
    required String status,
    String? keterangan,
    required String nikPewaris,
  }) async {
    try {
      print('🟡 PENYEDIA WARISAN: Verifikasi aset ID: $idAset');

      final hasil = await LayananApi.verifikasiAset(
        idAset: idAset,
        idVerifikator: idVerifikator,
        status: status,
        keterangan: keterangan,
      );

      print('🟢 PENYEDIA WARISAN: Hasil verifikasi aset');
      print('✅ Sukses: ${hasil['sukses']}');
      print('📝 Pesan: ${hasil['pesan']}');

      if (hasil['sukses'] == true) {
        await muatAset(nikPewaris);
        _pesanError = null;
        return true;
      } else {
        _pesanError = hasil['pesan'];
        return false;
      }
    } catch (e) {
      print('🔴 Error verifikasi aset: $e');
      _pesanError = 'Error: ${e.toString()}';
      return false;
    }
  }

  // ========== RIWAYAT ==========

  Future<List<Map<String, dynamic>>> ambilRiwayat(String nikPewaris) async {
    // TODO: Implement actual API call
    return [];
  }

  // ========== RESET ==========

  void reset() {
    _daftarAhliWaris = [];
    _daftarAset = [];
    _sedangMemuat = false;
    _pesanError = null;
    notifyListeners();
  }
}
