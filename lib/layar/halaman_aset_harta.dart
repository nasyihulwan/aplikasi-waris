import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../penyedia/penyedia_auth.dart';
import '../penyedia/penyedia_warisan.dart';

class HalamanAsetHarta extends StatefulWidget {
  const HalamanAsetHarta({super.key});

  @override
  _HalamanAsetHartaState createState() => _HalamanAsetHartaState();
}

class _HalamanAsetHartaState extends State<HalamanAsetHarta> {
  @override
  void initState() {
    super.initState();
    _muatData();
  }

  Future<void> _muatData() async {
    final penyediaAuth = Provider.of<PenyediaAuth>(context, listen: false);
    final penyediaWarisan = Provider.of<PenyediaWarisan>(
      context,
      listen: false,
    );
    if (penyediaAuth.nikPewaris != null) {
      await penyediaWarisan.muatAset(penyediaAuth.nikPewaris!);
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
            : penyediaWarisan.daftarAset.isEmpty
                ? _buatTampilanKosong()
                : Column(
                    children: [
                      _buatRingkasanAset(penyediaWarisan.daftarAset),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: penyediaWarisan.daftarAset.length,
                          itemBuilder: (context, index) {
                            final aset = penyediaWarisan.daftarAset[index];
                            return _buatKartuAset(aset);
                          },
                        ),
                      ),
                    ],
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _tampilkanDialogTambahAset(context),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Aset'),
        backgroundColor: const Color(0xFF00796B),
      ),
    );
  }

  Widget _buatTampilanKosong() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 100,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Belum ada aset harta',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Klik tombol + untuk menambah',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buatRingkasanAset(List<Map<String, dynamic>> daftarAset) {
    double totalDisetujui = 0;
    // ignore: unused_local_variable
    double totalMenunggu = 0;
    int jumlahDisetujui = 0;
    int jumlahMenunggu = 0;
    int jumlahDitolak = 0;

    for (var aset in daftarAset) {
      final nilai = double.tryParse(aset['nilai'].toString()) ?? 0.0;
      final status = aset['status_verifikasi'] ?? 'menunggu';

      if (status == 'disetujui') {
        totalDisetujui += nilai;
        jumlahDisetujui++;
      } else if (status == 'menunggu') {
        totalMenunggu += nilai;
        jumlahMenunggu++;
      } else if (status == 'ditolak') {
        jumlahDitolak++;
      }
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF004D40), Color(0xFF00796B)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Total Nilai Aset Disetujui',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            _formatRupiah(totalDisetujui),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white30),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buatItemStatistik(
                'Disetujui',
                jumlahDisetujui.toString(),
                Colors.green,
              ),
              _buatItemStatistik(
                'Menunggu',
                jumlahMenunggu.toString(),
                Colors.orange,
              ),
              _buatItemStatistik(
                'Ditolak',
                jumlahDitolak.toString(),
                Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buatItemStatistik(String label, String nilai, Color warna) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            nilai,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buatKartuAset(Map<String, dynamic> aset) {
    final status = aset['status_verifikasi'] ?? 'menunggu';
    Color warnaStatus;
    String labelStatus;

    switch (status) {
      case 'disetujui':
        warnaStatus = Colors.green;
        labelStatus = 'Disetujui';
        break;
      case 'ditolak':
        warnaStatus = Colors.red;
        labelStatus = 'Ditolak';
        break;
      default:
        warnaStatus = Colors.orange;
        labelStatus = 'Menunggu Verifikasi';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _tampilkanDetailAset(context, aset),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00796B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _dapatkanIkonJenisAset(aset['jenis_aset']),
                      color: const Color(0xFF00796B),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          aset['nama_aset'] ?? 'Unknown',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _dapatkanLabelJenisAset(aset['jenis_aset']),
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  // ✅ TAMBAHAN: PopupMenu untuk Edit & Hapus
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _tampilkanDialogEditAset(context, aset);
                      } else if (value == 'hapus') {
                        _konfirmasiHapusAset(context, aset);
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
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: warnaStatus.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      labelStatus,
                      style: TextStyle(
                        color: warnaStatus,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nilai Aset',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatRupiah(
                            double.tryParse(aset['nilai'].toString()) ?? 0.0),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF00796B),
                        ),
                      ),
                    ],
                  ),
                  if (status == 'menunggu')
                    ElevatedButton.icon(
                      onPressed: () =>
                          _tampilkanDialogVerifikasi(context, aset),
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('Verifikasi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                ],
              ),
              if (aset['keterangan'] != null &&
                  aset['keterangan'].toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    aset['keterangan'],
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                'Diusulkan oleh: ${aset['nama_pengusul'] ?? 'Unknown'}',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatRupiah(double angka) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(angka);
  }

  IconData _dapatkanIkonJenisAset(String? jenis) {
    switch (jenis) {
      case 'tanah':
        return Icons.terrain;
      case 'rumah':
        return Icons.home;
      case 'kendaraan':
        return Icons.directions_car;
      case 'tabungan':
        return Icons.account_balance;
      case 'emas':
        return Icons.diamond;
      case 'saham':
        return Icons.show_chart;
      default:
        return Icons.category;
    }
  }

  String _dapatkanLabelJenisAset(String? jenis) {
    switch (jenis) {
      case 'tanah':
        return 'Tanah';
      case 'rumah':
        return 'Rumah';
      case 'kendaraan':
        return 'Kendaraan';
      case 'tabungan':
        return 'Tabungan';
      case 'emas':
        return 'Emas/Perhiasan';
      case 'saham':
        return 'Saham/Investasi';
      default:
        return 'Lainnya';
    }
  }

  // ========== DIALOG TAMBAH ASET ==========
  void _tampilkanDialogTambahAset(BuildContext context) {
    final pengendaliNama = TextEditingController();
    final pengendaliNilai = TextEditingController();
    final pengendaliKeterangan = TextEditingController();
    String? jenisAsetTerpilih;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Tambah Aset Harta'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: pengendaliNama,
                  decoration: const InputDecoration(
                    labelText: 'Nama Aset',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Jenis Aset',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: jenisAsetTerpilih,
                  items: const [
                    DropdownMenuItem(value: 'tanah', child: Text('Tanah')),
                    DropdownMenuItem(value: 'rumah', child: Text('Rumah')),
                    DropdownMenuItem(
                        value: 'kendaraan', child: Text('Kendaraan')),
                    DropdownMenuItem(
                        value: 'tabungan', child: Text('Tabungan')),
                    DropdownMenuItem(
                        value: 'emas', child: Text('Emas/Perhiasan')),
                    DropdownMenuItem(
                        value: 'saham', child: Text('Saham/Investasi')),
                    DropdownMenuItem(value: 'lainnya', child: Text('Lainnya')),
                  ],
                  onChanged: (nilai) {
                    setState(() => jenisAsetTerpilih = nilai);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: pengendaliNilai,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Nilai Aset (Rp)',
                    border: OutlineInputBorder(),
                    prefixText: 'Rp ',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: pengendaliKeterangan,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Keterangan (Opsional)',
                    border: OutlineInputBorder(),
                  ),
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
                    jenisAsetTerpilih == null ||
                    pengendaliNilai.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Semua field harus diisi')),
                  );
                  return;
                }

                final penyediaAuth =
                    Provider.of<PenyediaAuth>(context, listen: false);
                final penyediaWarisan =
                    Provider.of<PenyediaWarisan>(context, listen: false);

                final berhasil = await penyediaWarisan.tambahAset(
                  context: context,
                  nikPewaris: penyediaAuth.nikPewaris!,
                  namaAset: pengendaliNama.text,
                  jenisAset: jenisAsetTerpilih!,
                  nilai: double.parse(pengendaliNilai.text),
                  keterangan: pengendaliKeterangan.text.isEmpty
                      ? null
                      : pengendaliKeterangan.text,
                );

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      berhasil
                          ? 'Aset berhasil ditambahkan'
                          : 'Gagal menambahkan aset',
                    ),
                    backgroundColor: berhasil ? Colors.green : Colors.red,
                  ),
                );
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  // ========== DIALOG DETAIL ASET ==========
  void _tampilkanDetailAset(BuildContext context, Map<String, dynamic> aset) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(aset['nama_aset'] ?? 'Detail Aset'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buatBarisDetail(
                  'Jenis', _dapatkanLabelJenisAset(aset['jenis_aset'])),
              _buatBarisDetail(
                  'Nilai',
                  _formatRupiah(
                      double.tryParse(aset['nilai'].toString()) ?? 0.0)),
              _buatBarisDetail(
                  'Status', aset['status_verifikasi'] ?? 'menunggu'),
              _buatBarisDetail(
                  'Diusulkan oleh', aset['nama_pengusul'] ?? 'Unknown'),
              if (aset['keterangan'] != null &&
                  aset['keterangan'].toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Keterangan:  ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(aset['keterangan']),
                    ],
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          if (aset['status_verifikasi'] == 'menunggu')
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _tampilkanDialogVerifikasi(context, aset);
              },
              child: const Text('Verifikasi'),
            ),
        ],
      ),
    );
  }

  Widget _buatBarisDetail(String label, String nilai) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Text(':  '),
          Expanded(child: Text(nilai)),
        ],
      ),
    );
  }

  // ========== DIALOG VERIFIKASI ==========
  void _tampilkanDialogVerifikasi(
    BuildContext context,
    Map<String, dynamic> aset,
  ) {
    final pengendaliCatatan = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verifikasi Aset'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Apakah Anda menyetujui aset "${aset['nama_aset']}"?'),
            const SizedBox(height: 16),
            TextField(
              controller: pengendaliCatatan,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Catatan (Opsional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _prosesVerifikasi(
                  context, aset, false, pengendaliCatatan.text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Tolak'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _prosesVerifikasi(
                  context, aset, true, pengendaliCatatan.text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Setuju'),
          ),
        ],
      ),
    );
  }

  // ========== PROSES VERIFIKASI ==========
  Future<void> _prosesVerifikasi(
    BuildContext context,
    Map<String, dynamic> aset,
    bool disetujui,
    String catatan,
  ) async {
    final penyediaAuth = Provider.of<PenyediaAuth>(context, listen: false);
    final penyediaWarisan =
        Provider.of<PenyediaWarisan>(context, listen: false);

    final berhasil = await penyediaWarisan.verifikasiAset(
      idAset: int.parse(aset['id'].toString()),
      idVerifikator: int.parse(penyediaAuth.idPengguna!),
      status: disetujui ? 'disetujui' : 'ditolak',
      keterangan: catatan.isEmpty ? null : catatan,
      nikPewaris: penyediaAuth.nikPewaris!,
    );

    Navigator.pop(context);

    if (berhasil) {
      await penyediaWarisan.muatAset(penyediaAuth.nikPewaris!);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          berhasil ? 'Verifikasi berhasil' : 'Gagal verifikasi',
        ),
        backgroundColor: berhasil ? Colors.green : Colors.red,
      ),
    );
  }

  // ========== ✅ DIALOG EDIT ASET (BARU) ==========
  void _tampilkanDialogEditAset(
      BuildContext context, Map<String, dynamic> aset) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur edit akan segera ditambahkan'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  // ========== ✅ KONFIRMASI HAPUS ASET (BARU) ==========
  void _konfirmasiHapusAset(BuildContext context, Map<String, dynamic> aset) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Aset'),
        content: Text(
            'Apakah Anda yakin ingin menghapus aset "${aset['nama_aset']}"?'),
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

              final berhasil = await penyediaWarisan.hapusAset(
                idAset: aset['id'].toString(),
                nikPewaris: penyediaAuth.nikPewaris!,
              );

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(berhasil
                      ? 'Aset berhasil dihapus'
                      : 'Gagal menghapus aset'),
                  backgroundColor: berhasil ? Colors.green : Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
