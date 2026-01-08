import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../penyedia/penyedia_auth.dart';
import '../penyedia/penyedia_warisan.dart';
import '../tema/tema_aplikasi.dart';
import '../widget/komponen_umum.dart';

class HalamanAhliWaris extends StatefulWidget {
  const HalamanAhliWaris({super.key});

  @override
  _HalamanAhliWarisState createState() => _HalamanAhliWarisState();
}

class _HalamanAhliWarisState extends State<HalamanAhliWaris> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _muatData();
    });
  }

  Future<void> _muatData() async {
    final penyediaAuth = Provider.of<PenyediaAuth>(context, listen: false);
    final penyediaWarisan =
        Provider.of<PenyediaWarisan>(context, listen: false);

    if (penyediaAuth.nikPewaris != null) {
      print('🔄 Memuat ahli waris untuk NIK: ${penyediaAuth.nikPewaris}');
      await penyediaWarisan.muatAhliWaris(penyediaAuth.nikPewaris!);
      print('✅ Selesai memuat ahli waris');
      print('📊 Jumlah ahli waris: ${penyediaWarisan.daftarAhliWaris.length}');
    } else {
      print('❌ NIK Pewaris tidak ditemukan! ');
      print('📝 ID Pengguna: ${penyediaAuth.idPengguna}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final penyediaWarisan = Provider.of<PenyediaWarisan>(context);

    return Scaffold(
      backgroundColor: TemaAplikasi.background,
      body: RefreshIndicator(
        onRefresh: _muatData,
        color: TemaAplikasi.primary,
        child: penyediaWarisan.sedangMemuat
            ? const LoadingIndicator(message: 'Memuat data ahli waris...')
            : penyediaWarisan.daftarAhliWaris.isEmpty
                ? TampilanKosong(
                    icon: Icons.people_outline,
                    judul: 'Belum ada ahli waris',
                    deskripsi: 'Klik tombol di bawah untuk menambah ahli waris',
                    buttonText: 'Tambah Ahli Waris',
                    onButtonPressed: () =>
                        _tampilkanDialogTambahAhliWaris(context),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                    itemCount: penyediaWarisan.daftarAhliWaris.length,
                    itemBuilder: (context, index) {
                      final ahliWaris = penyediaWarisan.daftarAhliWaris[index];
                      return _buatKartuAhliWaris(ahliWaris);
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _tampilkanDialogTambahAhliWaris(context),
        icon: const Icon(Icons.add),
        label: Text(
          'Tambah',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        backgroundColor: TemaAplikasi.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }

  Widget _buatKartuAhliWaris(Map<String, dynamic> ahliWaris) {
    final String nama = ahliWaris['nama_lengkap']?.toString() ?? 'Unknown';
    final String hubungan = ahliWaris['hubungan']?.toString() ?? '';
    final String jenisKelamin =
        ahliWaris['jenis_kelamin']?.toString() ?? 'laki-laki';

    return KartuListItem(
      judul: nama,
      subjudul: _dapatkanLabelHubungan(hubungan),
      info: jenisKelamin == 'laki-laki' ? 'Laki-laki' : 'Perempuan',
      icon: _dapatkanIconHubungan(hubungan),
      warna: _dapatkanWarnaHubungan(hubungan),
      onEdit: () => _tampilkanDialogEditAhliWaris(context, ahliWaris),
      onDelete: () => _konfirmasiHapus(context, ahliWaris),
    );
  }

  IconData _dapatkanIconHubungan(String hubungan) {
    switch (hubungan) {
      case 'istri':
      case 'suami':
        return Icons.favorite;
      case 'anak_laki':
      case 'anak_perempuan':
        return Icons.child_care;
      case 'ayah':
      case 'ibu':
        return Icons.elderly;
      case 'saudara_laki':
      case 'saudara_perempuan':
        return Icons.people;
      default:
        return Icons.person;
    }
  }

  Color _dapatkanWarnaHubungan(String hubungan) {
    switch (hubungan) {
      case 'istri':
      case 'suami':
        return const Color(0xFFE91E63);
      case 'anak_laki':
      case 'anak_perempuan':
        return TemaAplikasi.menuBlue;
      case 'ayah':
      case 'ibu':
        return TemaAplikasi.menuOrange;
      case 'saudara_laki':
      case 'saudara_perempuan':
        return TemaAplikasi.menuPurple;
      default:
        return TemaAplikasi.primary;
    }
  }

  String _dapatkanLabelHubungan(String hubungan) {
    switch (hubungan) {
      case 'istri':
        return 'Istri';
      case 'suami':
        return 'Suami';
      case 'anak_laki':
        return 'Anak Laki-laki';
      case 'anak_perempuan':
        return 'Anak Perempuan';
      case 'ayah':
        return 'Ayah';
      case 'ibu':
        return 'Ibu';
      case 'saudara_laki':
        return 'Saudara Laki-laki';
      case 'saudara_perempuan':
        return 'Saudara Perempuan';
      default:
        return hubungan;
    }
  }

  // ========== DIALOG TAMBAH AHLI WARIS ==========
  void _tampilkanDialogTambahAhliWaris(BuildContext context) {
    final pengendaliNama = TextEditingController();
    String? hubunganTerpilih;
    String? jenisKelaminTerpilih;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: TemaAplikasi.primarySurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.person_add,
                  color: TemaAplikasi.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text('Tambah Ahli Waris', style: TemaAplikasi.titleLarge),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: pengendaliNama,
                  decoration: TemaAplikasi.inputDecoration(
                    labelText: 'Nama Lengkap',
                    prefixIcon: Icons.person_outline,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: TemaAplikasi.inputDecoration(
                    labelText: 'Hubungan',
                    prefixIcon: Icons.family_restroom,
                  ),
                  value: hubunganTerpilih,
                  items: const [
                    DropdownMenuItem(value: 'istri', child: Text('Istri')),
                    DropdownMenuItem(value: 'suami', child: Text('Suami')),
                    DropdownMenuItem(
                        value: 'anak_laki', child: Text('Anak Laki-laki')),
                    DropdownMenuItem(
                        value: 'anak_perempuan', child: Text('Anak Perempuan')),
                    DropdownMenuItem(value: 'ayah', child: Text('Ayah')),
                    DropdownMenuItem(value: 'ibu', child: Text('Ibu')),
                    DropdownMenuItem(
                        value: 'saudara_laki',
                        child: Text('Saudara Laki-laki')),
                    DropdownMenuItem(
                        value: 'saudara_perempuan',
                        child: Text('Saudara Perempuan')),
                  ],
                  onChanged: (nilai) {
                    setState(() => hubunganTerpilih = nilai);
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: TemaAplikasi.inputDecoration(
                    labelText: 'Jenis Kelamin',
                    prefixIcon: Icons.wc,
                  ),
                  value: jenisKelaminTerpilih,
                  items: const [
                    DropdownMenuItem(
                        value: 'laki-laki', child: Text('Laki-laki')),
                    DropdownMenuItem(
                        value: 'perempuan', child: Text('Perempuan')),
                  ],
                  onChanged: (nilai) {
                    setState(() => jenisKelaminTerpilih = nilai);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal',
                  style: TextStyle(color: TemaAplikasi.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (pengendaliNama.text.isEmpty ||
                    hubunganTerpilih == null ||
                    jenisKelaminTerpilih == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Semua field harus diisi'),
                      backgroundColor: TemaAplikasi.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                  return;
                }

                final penyediaAuth =
                    Provider.of<PenyediaAuth>(context, listen: false);
                final penyediaWarisan =
                    Provider.of<PenyediaWarisan>(context, listen: false);

                print('📝 Menambah ahli waris: ');
                print('   NIK Pewaris: ${penyediaAuth.nikPewaris}');
                print('   Nama:  ${pengendaliNama.text}');
                print('   Hubungan: $hubunganTerpilih');
                print('   Jenis Kelamin: $jenisKelaminTerpilih');

                final berhasil = await penyediaWarisan.tambahAhliWaris(
                  context: context,
                  nikPewaris: penyediaAuth.nikPewaris!,
                  namaLengkap: pengendaliNama.text,
                  hubungan: hubunganTerpilih!,
                  jenisKelamin: jenisKelaminTerpilih!,
                );

                Navigator.pop(context);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        berhasil
                            ? 'Ahli waris berhasil ditambahkan'
                            : 'Gagal menambahkan ahli waris',
                      ),
                      backgroundColor:
                          berhasil ? TemaAplikasi.success : TemaAplikasi.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );

                  if (berhasil) {
                    await _muatData();
                  }
                }
              },
              style: TemaAplikasi.primaryButton,
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  // ========== DIALOG EDIT AHLI WARIS ==========
  void _tampilkanDialogEditAhliWaris(
      BuildContext context, Map<String, dynamic> ahliWaris) {
    final pengendaliNama = TextEditingController(
      text: ahliWaris['nama_lengkap']?.toString() ?? '',
    );
    String? hubunganTerpilih = ahliWaris['hubungan']?.toString();
    String? jenisKelaminTerpilih = ahliWaris['jenis_kelamin']?.toString();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: TemaAplikasi.infoLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.edit,
                  color: TemaAplikasi.info,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text('Edit Ahli Waris', style: TemaAplikasi.titleLarge),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: pengendaliNama,
                  decoration: TemaAplikasi.inputDecoration(
                    labelText: 'Nama Lengkap',
                    prefixIcon: Icons.person_outline,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: TemaAplikasi.inputDecoration(
                    labelText: 'Hubungan',
                    prefixIcon: Icons.family_restroom,
                  ),
                  value: hubunganTerpilih,
                  items: const [
                    DropdownMenuItem(value: 'istri', child: Text('Istri')),
                    DropdownMenuItem(value: 'suami', child: Text('Suami')),
                    DropdownMenuItem(
                        value: 'anak_laki', child: Text('Anak Laki-laki')),
                    DropdownMenuItem(
                        value: 'anak_perempuan', child: Text('Anak Perempuan')),
                    DropdownMenuItem(value: 'ayah', child: Text('Ayah')),
                    DropdownMenuItem(value: 'ibu', child: Text('Ibu')),
                    DropdownMenuItem(
                        value: 'saudara_laki',
                        child: Text('Saudara Laki-laki')),
                    DropdownMenuItem(
                        value: 'saudara_perempuan',
                        child: Text('Saudara Perempuan')),
                  ],
                  onChanged: (nilai) {
                    setState(() => hubunganTerpilih = nilai);
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: TemaAplikasi.inputDecoration(
                    labelText: 'Jenis Kelamin',
                    prefixIcon: Icons.wc,
                  ),
                  value: jenisKelaminTerpilih,
                  items: const [
                    DropdownMenuItem(
                        value: 'laki-laki', child: Text('Laki-laki')),
                    DropdownMenuItem(
                        value: 'perempuan', child: Text('Perempuan')),
                  ],
                  onChanged: (nilai) {
                    setState(() => jenisKelaminTerpilih = nilai);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal',
                  style: TextStyle(color: TemaAplikasi.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (pengendaliNama.text.isEmpty ||
                    hubunganTerpilih == null ||
                    jenisKelaminTerpilih == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Semua field harus diisi'),
                      backgroundColor: TemaAplikasi.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                  return;
                }

                final penyediaAuth =
                    Provider.of<PenyediaAuth>(context, listen: false);
                final penyediaWarisan =
                    Provider.of<PenyediaWarisan>(context, listen: false);

                final berhasil = await penyediaWarisan.editAhliWaris(
                  idAhliWaris: ahliWaris['id'].toString(),
                  namaLengkap: pengendaliNama.text,
                  hubungan: hubunganTerpilih!,
                  jenisKelamin: jenisKelaminTerpilih!,
                  nikPewaris: penyediaAuth.nikPewaris!,
                );

                Navigator.pop(context);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        berhasil
                            ? 'Ahli waris berhasil diupdate'
                            : 'Gagal mengupdate ahli waris',
                      ),
                      backgroundColor:
                          berhasil ? TemaAplikasi.success : TemaAplikasi.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );

                  if (berhasil) {
                    await _muatData();
                  }
                }
              },
              style: TemaAplikasi.primaryButton,
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  // ========== KONFIRMASI HAPUS ==========
  void _konfirmasiHapus(BuildContext context, Map<String, dynamic> ahliWaris) {
    showDialog(
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
                color: TemaAplikasi.errorLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.delete_outline,
                color: TemaAplikasi.error,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text('Konfirmasi Hapus', style: TemaAplikasi.titleLarge),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${ahliWaris['nama_lengkap']}"?',
          style: TemaAplikasi.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal',
                style: TextStyle(color: TemaAplikasi.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              final penyediaAuth =
                  Provider.of<PenyediaAuth>(context, listen: false);
              final penyediaWarisan =
                  Provider.of<PenyediaWarisan>(context, listen: false);

              Navigator.pop(context);

              final berhasil = await penyediaWarisan.hapusAhliWaris(
                idAhliWaris: ahliWaris['id'].toString(),
                nikPewaris: penyediaAuth.nikPewaris!,
              );

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      berhasil
                          ? 'Ahli waris berhasil dihapus'
                          : 'Gagal menghapus ahli waris',
                    ),
                    backgroundColor:
                        berhasil ? TemaAplikasi.success : TemaAplikasi.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );

                if (berhasil) {
                  await _muatData();
                }
              }
            },
            style: TemaAplikasi.dangerButton,
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
