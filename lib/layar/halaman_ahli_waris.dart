import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../penyedia/penyedia_auth.dart';
import '../penyedia/penyedia_warisan.dart';

class HalamanAhliWaris extends StatefulWidget {
  const HalamanAhliWaris({Key? key}) : super(key: key);

  @override
  _HalamanAhliWarisState createState() => _HalamanAhliWarisState();
}

class _HalamanAhliWarisState extends State<HalamanAhliWaris> {
  @override
  void initState() {
    super.initState();
    // Delay untuk memastikan context sudah siap
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
      body: RefreshIndicator(
        onRefresh: _muatData,
        child: penyediaWarisan.sedangMemuat
            ? const Center(child: CircularProgressIndicator())
            : penyediaWarisan.daftarAhliWaris.isEmpty
                ? _buatTampilanKosong()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
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
        label: const Text('Tambah Ahli Waris'),
        backgroundColor: const Color(0xFF00796B),
      ),
    );
  }

  Widget _buatTampilanKosong() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.people_outline,
            size: 100,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada ahli waris',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Klik tombol + untuk menambah',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buatKartuAhliWaris(Map<String, dynamic> ahliWaris) {
    final String nama = ahliWaris['nama_lengkap']?.toString() ?? 'Unknown';
    final String hubungan = ahliWaris['hubungan']?.toString() ?? '';
    final String jenisKelamin =
        ahliWaris['jenis_kelamin']?.toString() ?? 'laki-laki';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF00796B).withOpacity(0.1),
          radius: 28,
          child: Icon(
            _dapatkanIconHubungan(hubungan),
            color: const Color(0xFF00796B),
            size: 28,
          ),
        ),
        title: Text(
          nama,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(_dapatkanLabelHubungan(hubungan)),
            const SizedBox(height: 2),
            Text(
              jenisKelamin == 'laki-laki' ? 'Laki-laki' : 'Perempuan',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              _tampilkanDialogEditAhliWaris(context, ahliWaris);
            } else if (value == 'hapus') {
              _konfirmasiHapus(context, ahliWaris);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'hapus',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Hapus', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
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
          title: const Text('Tambah Ahli Waris'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: pengendaliNama,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Hubungan',
                    border: OutlineInputBorder(),
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
                  decoration: const InputDecoration(
                    labelText: 'Jenis Kelamin',
                    border: OutlineInputBorder(),
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
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (pengendaliNama.text.isEmpty ||
                    hubunganTerpilih == null ||
                    jenisKelaminTerpilih == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Semua field harus diisi')),
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
                      backgroundColor: berhasil ? Colors.green : Colors.red,
                    ),
                  );

                  if (berhasil) {
                    // Reload data
                    await _muatData();
                  }
                }
              },
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
          title: const Text('Edit Ahli Waris'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: pengendaliNama,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Hubungan',
                    border: OutlineInputBorder(),
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
                  decoration: const InputDecoration(
                    labelText: 'Jenis Kelamin',
                    border: OutlineInputBorder(),
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
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (pengendaliNama.text.isEmpty ||
                    hubunganTerpilih == null ||
                    jenisKelaminTerpilih == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Semua field harus diisi')),
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
                      backgroundColor: berhasil ? Colors.green : Colors.red,
                    ),
                  );

                  if (berhasil) {
                    // Live refresh setelah edit
                    await _muatData();
                  }
                }
              },
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
        title: const Text('Konfirmasi Hapus'),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${ahliWaris['nama_lengkap']}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
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
                    backgroundColor: berhasil ? Colors.green : Colors.red,
                  ),
                );

                if (berhasil) {
                  // Live refresh setelah hapus
                  await _muatData();
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
