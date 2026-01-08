import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../penyedia/penyedia_auth.dart';
import '../tema/tema_aplikasi.dart';

/// Halaman Edit Profil
/// Menampilkan dan mengedit informasi profil pengguna
/// Field yang dapat diedit: nik, nama_lengkap, tahun_lahir, tempat_lahir, alamat
class HalamanEditProfil extends StatefulWidget {
  const HalamanEditProfil({super.key});

  @override
  State<HalamanEditProfil> createState() => _HalamanEditProfilState();
}

class _HalamanEditProfilState extends State<HalamanEditProfil> {
  final _formKey = GlobalKey<FormState>();
  final _nikController = TextEditingController();
  final _namaController = TextEditingController();
  final _tahunLahirController = TextEditingController();
  final _tempatLahirController = TextEditingController();
  final _alamatController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasChanges = false;
  String? _errorMessage;

  // Original values untuk deteksi perubahan
  String _originalNik = '';
  String _originalNama = '';
  String _originalTahunLahir = '';
  String _originalTempatLahir = '';
  String _originalAlamat = '';

  @override
  void initState() {
    super.initState();
    print('👤 [EDIT-PROFIL] Halaman edit profil diinisialisasi');
    _loadUserData();
  }

  @override
  void dispose() {
    _nikController.dispose();
    _namaController.dispose();
    _tahunLahirController.dispose();
    _tempatLahirController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  /// Memuat data pengguna dari database
  Future<void> _loadUserData() async {
    print('👤 [EDIT-PROFIL] Memuat data pengguna dari database...');

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final penyediaAuth = Provider.of<PenyediaAuth>(context, listen: false);
      final hasil = await penyediaAuth.ambilProfil();

      if (hasil['sukses'] == true) {
        final data = hasil['data'];
        print('👤 [EDIT-PROFIL] Data profil diterima: $data');

        // Set nilai ke controller
        _nikController.text = data['nik']?.toString() ?? '';
        _namaController.text = data['nama_lengkap']?.toString() ?? '';
        _tahunLahirController.text = data['tahun_lahir']?.toString() ?? '';
        _tempatLahirController.text = data['tempat_lahir']?.toString() ?? '';
        _alamatController.text = data['alamat']?.toString() ?? '';

        // Simpan nilai original
        _originalNik = _nikController.text;
        _originalNama = _namaController.text;
        _originalTahunLahir = _tahunLahirController.text;
        _originalTempatLahir = _tempatLahirController.text;
        _originalAlamat = _alamatController.text;

        print('👤 [EDIT-PROFIL] NIK: ${_nikController.text}');
        print('👤 [EDIT-PROFIL] Nama: ${_namaController.text}');
        print('👤 [EDIT-PROFIL] Tahun Lahir: ${_tahunLahirController.text}');
        print('👤 [EDIT-PROFIL] Tempat Lahir: ${_tempatLahirController.text}');
        print('👤 [EDIT-PROFIL] Alamat: ${_alamatController.text}');

        // Tambahkan listener untuk mendeteksi perubahan
        _nikController.addListener(_onDataChanged);
        _namaController.addListener(_onDataChanged);
        _tahunLahirController.addListener(_onDataChanged);
        _tempatLahirController.addListener(_onDataChanged);
        _alamatController.addListener(_onDataChanged);
      } else {
        print('🔴 [EDIT-PROFIL] Gagal memuat profil: ${hasil['pesan']}');
        setState(() {
          _errorMessage = hasil['pesan'] ?? 'Gagal memuat data profil';
        });
      }
    } catch (e) {
      print('🔴 [EDIT-PROFIL] Error memuat profil: $e');
      setState(() {
        _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onDataChanged() {
    final hasChanges = _nikController.text != _originalNik ||
        _namaController.text != _originalNama ||
        _tahunLahirController.text != _originalTahunLahir ||
        _tempatLahirController.text != _originalTempatLahir ||
        _alamatController.text != _originalAlamat;

    if (hasChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  /// Menyimpan perubahan profil
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    print('👤 [EDIT-PROFIL] Menyimpan perubahan profil...');
    print('👤 [EDIT-PROFIL] NIK baru: ${_nikController.text}');
    print('👤 [EDIT-PROFIL] Nama baru: ${_namaController.text}');
    print('👤 [EDIT-PROFIL] Tahun Lahir baru: ${_tahunLahirController.text}');
    print('👤 [EDIT-PROFIL] Tempat Lahir baru: ${_tempatLahirController.text}');
    print('👤 [EDIT-PROFIL] Alamat baru: ${_alamatController.text}');

    try {
      final penyediaAuth = Provider.of<PenyediaAuth>(context, listen: false);

      final hasil = await penyediaAuth.updateProfil(
        nik: _nikController.text.trim(),
        namaLengkap: _namaController.text.trim(),
        tahunLahir: _tahunLahirController.text.trim(),
        tempatLahir: _tempatLahirController.text.trim(),
        alamat: _alamatController.text.trim(),
      );

      if (hasil['sukses'] == true) {
        print('🟢 [EDIT-PROFIL] Profil berhasil disimpan');

        // Update nilai original
        _originalNik = _nikController.text;
        _originalNama = _namaController.text;
        _originalTahunLahir = _tahunLahirController.text;
        _originalTempatLahir = _tempatLahirController.text;
        _originalAlamat = _alamatController.text;

        _showSnackBar('Profil berhasil diperbarui', isSuccess: true);

        setState(() {
          _hasChanges = false;
        });
      } else {
        print('🔴 [EDIT-PROFIL] Gagal menyimpan profil: ${hasil['pesan']}');
        _showSnackBar(hasil['pesan'] ?? 'Gagal menyimpan profil',
            isError: true);
      }
    } catch (e) {
      print('🔴 [EDIT-PROFIL] Error menyimpan profil: $e');
      _showSnackBar('Gagal menyimpan profil: ${e.toString()}', isError: true);
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _showSnackBar(String message,
      {bool isSuccess = false, bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess
                  ? Icons.check_circle
                  : isError
                      ? Icons.error
                      : Icons.info_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: isSuccess
            ? TemaAplikasi.success
            : isError
                ? TemaAplikasi.error
                : TemaAplikasi.info,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Konfirmasi keluar tanpa menyimpan
  Future<bool> _onWillPop() async {
    if (!_hasChanges) {
      return true;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: TemaAplikasi.warningLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: TemaAplikasi.warning,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Perubahan Belum Disimpan',
                style: TemaAplikasi.titleLarge,
              ),
            ),
          ],
        ),
        content: Text(
          'Anda memiliki perubahan yang belum disimpan. Yakin ingin keluar?',
          style: TemaAplikasi.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: TextStyle(color: TemaAplikasi.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: TemaAplikasi.dangerButton,
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  InputDecoration _buildInputDecoration({
    required String labelText,
    required String hintText,
    required IconData icon,
  }) {
    return TemaAplikasi.inputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    print('👤 [EDIT-PROFIL] Build halaman edit profil');

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF00695C),
                Color(0xFF00897B),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Custom AppBar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () async {
                          if (await _onWillPop()) {
                            Navigator.pop(context);
                          }
                        },
                      ),
                      Expanded(
                        child: Text(
                          'Edit Profil',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 48), // Balance the back button
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: _isLoading
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Memuat data profil...',
                                style: TemaAplikasi.bodyWhite,
                              ),
                            ],
                          ),
                        )
                      : _errorMessage != null
                          ? _buildErrorView()
                          : _buildFormView(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 56,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _errorMessage!,
              style: TemaAplikasi.bodyWhite,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadUserData,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: TemaAplikasi.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),

          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.person,
              size: 56,
              color: TemaAplikasi.primary,
            ),
          ),

          const SizedBox(height: 24),

          // Form Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: TemaAplikasi.primarySurface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.edit_note,
                          color: TemaAplikasi.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informasi Profil',
                              style: TemaAplikasi.headingSmall,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Perbarui informasi sesuai KTP',
                              style: TemaAplikasi.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // NIK
                  TextFormField(
                    controller: _nikController,
                    keyboardType: TextInputType.number,
                    maxLength: 16,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(16),
                    ],
                    decoration: _buildInputDecoration(
                      labelText: 'NIK (Nomor Induk Kependudukan)',
                      hintText: 'Masukkan 16 digit NIK',
                      icon: Icons.badge_outlined,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'NIK tidak boleh kosong';
                      }
                      if (value.length != 16) {
                        return 'NIK harus 16 digit';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Nama Lengkap
                  TextFormField(
                    controller: _namaController,
                    textCapitalization: TextCapitalization.words,
                    decoration: _buildInputDecoration(
                      labelText: 'Nama Lengkap',
                      hintText: 'Masukkan nama lengkap sesuai KTP',
                      icon: Icons.person_outline,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama lengkap tidak boleh kosong';
                      }
                      if (value.length < 3) {
                        return 'Nama minimal 3 karakter';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Tempat Lahir
                  TextFormField(
                    controller: _tempatLahirController,
                    textCapitalization: TextCapitalization.words,
                    decoration: _buildInputDecoration(
                      labelText: 'Tempat Lahir',
                      hintText: 'Masukkan kota/kabupaten tempat lahir',
                      icon: Icons.location_city_outlined,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Tempat lahir tidak boleh kosong';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Tahun Lahir
                  TextFormField(
                    controller: _tahunLahirController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    decoration: _buildInputDecoration(
                      labelText: 'Tahun Lahir',
                      hintText: 'Contoh: 1990',
                      icon: Icons.cake_outlined,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Tahun lahir tidak boleh kosong';
                      }
                      if (value.length != 4) {
                        return 'Tahun lahir harus 4 digit';
                      }
                      final tahun = int.tryParse(value);
                      if (tahun == null) {
                        return 'Format tahun tidak valid';
                      }
                      final tahunSekarang = DateTime.now().year;
                      if (tahun < 1900 || tahun > tahunSekarang) {
                        return 'Tahun lahir harus antara 1900-$tahunSekarang';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Alamat
                  TextFormField(
                    controller: _alamatController,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 3,
                    decoration: _buildInputDecoration(
                      labelText: 'Alamat',
                      hintText: 'Masukkan alamat lengkap sesuai KTP',
                      icon: Icons.home_outlined,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Alamat tidak boleh kosong';
                      }
                      if (value.length < 10) {
                        return 'Alamat terlalu pendek, minimal 10 karakter';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 28),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed:
                          _isSaving || !_hasChanges ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TemaAplikasi.primary,
                        disabledBackgroundColor: TemaAplikasi.divider,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: _hasChanges ? 4 : 0,
                        shadowColor: TemaAplikasi.primary.withOpacity(0.4),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              'Simpan Perubahan',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Info text
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.white.withOpacity(0.9),
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Data profil akan disimpan ke database server. Pastikan data sesuai dengan KTP Anda.',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
