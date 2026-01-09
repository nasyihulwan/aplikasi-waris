import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../penyedia/penyedia_auth.dart';
import '../penyedia/penyedia_warisan.dart';
import '../tema/tema_aplikasi.dart';
import '../widget/komponen_umum.dart';

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
      backgroundColor: TemaAplikasi.background,
      body: RefreshIndicator(
        onRefresh: _muatData,
        color: TemaAplikasi.primary,
        child: penyediaWarisan.sedangMemuat
            ? const LoadingIndicator(message: 'Memuat aset harta...')
            : penyediaWarisan.daftarAset.isEmpty
                ? TampilanKosong(
                    icon: Icons.account_balance_wallet_outlined,
                    judul: 'Belum Ada Aset Harta',
                    deskripsi: 'Klik tombol + untuk menambah aset',
                    buttonText: 'Tambah Aset',
                    onButtonPressed: () => _tampilkanDialogTambahAset(context),
                  )
                : Column(
                    children: [
                      _buatRingkasanAset(penyediaWarisan.daftarAset),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
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
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: TemaAplikasi.gradientPrimaryLinear,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: TemaAplikasi.primary.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _tampilkanDialogTambahAset(context),
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text('Tambah Aset',
              style: GoogleFonts.poppins(
                  color: Colors.white, fontWeight: FontWeight.w600)),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buatRingkasanAset(List<Map<String, dynamic>> daftarAset) {
    double totalDisetujui = 0;
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
        jumlahMenunggu++;
      } else if (status == 'ditolak') {
        jumlahDitolak++;
      }
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: TemaAplikasi.kartuGradient,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.account_balance_wallet,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Aset Disetujui',
                      style: GoogleFonts.poppins(
                          color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatRupiah(totalDisetujui),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buatItemStatistik('Disetujui', jumlahDisetujui.toString(),
                    TemaAplikasi.success),
                Container(width: 1, height: 40, color: Colors.white24),
                _buatItemStatistik('Menunggu', jumlahMenunggu.toString(),
                    TemaAplikasi.warning),
                Container(width: 1, height: 40, color: Colors.white24),
                _buatItemStatistik(
                    'Ditolak', jumlahDitolak.toString(), TemaAplikasi.error),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buatItemStatistik(String label, String nilai, Color warna) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: warna.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              nilai,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _buatKartuAset(Map<String, dynamic> aset) {
    final status = aset['status_verifikasi'] ?? 'menunggu';
    Color warnaStatus;
    String labelStatus;

    switch (status) {
      case 'disetujui':
        warnaStatus = TemaAplikasi.success;
        labelStatus = 'Disetujui';
        break;
      case 'ditolak':
        warnaStatus = TemaAplikasi.error;
        labelStatus = 'Ditolak';
        break;
      default:
        warnaStatus = TemaAplikasi.warning;
        labelStatus = 'Menunggu Verifikasi';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: TemaAplikasi.kartuDekorasi,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _tampilkanDetailAset(context, aset),
          borderRadius: BorderRadius.circular(16),
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
                        gradient: LinearGradient(
                          colors: [
                            TemaAplikasi.primary.withOpacity(0.1),
                            TemaAplikasi.primary.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _dapatkanIkonJenisAset(aset['jenis_aset']),
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
                            aset['nama_aset'] ?? 'Unknown',
                            style: TemaAplikasi.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _dapatkanLabelJenisAset(aset['jenis_aset']),
                            style: TemaAplikasi.bodySmall
                                .copyWith(color: TemaAplikasi.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert,
                          color: TemaAplikasi.textSecondary),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _tampilkanDialogEditAset(context, aset);
                        } else if (value == 'hapus') {
                          _konfirmasiHapusAset(context, aset);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              const Icon(Icons.edit_outlined,
                                  size: 20, color: TemaAplikasi.info),
                              const SizedBox(width: 12),
                              Text('Edit', style: TemaAplikasi.bodyMedium),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'hapus',
                          child: Row(
                            children: [
                              const Icon(Icons.delete_outline,
                                  size: 20, color: TemaAplikasi.error),
                              const SizedBox(width: 12),
                              Text('Hapus',
                                  style: TemaAplikasi.bodyMedium
                                      .copyWith(color: TemaAplikasi.error)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                BadgeStatus(
                  text: labelStatus,
                  color: warnaStatus,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nilai Aset',
                          style: TemaAplikasi.bodySmall
                              .copyWith(color: TemaAplikasi.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatRupiah(
                              double.tryParse(aset['nilai'].toString()) ?? 0.0),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: TemaAplikasi.primary,
                          ),
                        ),
                      ],
                    ),
                    if (status == 'menunggu')
                      Builder(
                        builder: (context) {
                          final penyediaAuth =
                              Provider.of<PenyediaAuth>(context, listen: false);
                          final idPengusul =
                              aset['id_pengusul']?.toString() ?? '';
                          final idPengguna =
                              penyediaAuth.idPengguna?.toString() ?? '';
                          
                          // DEBUG - hapus setelah fix
                          print('🔴 TOMBOL VERIFIKASI CHECK:');
                          print('   aset id: ${aset['id']}');
                          print('   id_pengusul dari aset: "$idPengusul"');
                          print('   id_pengguna login: "$idPengguna"');
                          print('   sama? ${idPengusul == idPengguna}');
                          
                          // Jika aset milik sendiri, JANGAN tampilkan tombol
                          if (idPengusul == idPengguna) {
                            print('   ❌ TOMBOL DISEMBUNYIKAN (aset sendiri)');
                            return const SizedBox.shrink();
                          }
                          
                          print('   ✅ TOMBOL DITAMPILKAN (aset orang lain)');

                          return ElevatedButton.icon(
                            onPressed: () =>
                                _tampilkanDialogVerifikasi(context, aset),
                            icon: const Icon(
                              Icons.check_circle_outline,
                              size: 18,
                            ),
                            label: const Text('Verifikasi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: TemaAplikasi.warning,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                          );
                        },
                      ),
                  ],
                ),
                if (aset['keterangan'] != null &&
                    aset['keterangan'].toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      aset['keterangan'],
                      style: TemaAplikasi.bodySmall
                          .copyWith(color: TemaAplikasi.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person_outline,
                        size: 14, color: TemaAplikasi.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      'Diusulkan oleh: ${aset['nama_pengusul'] ?? 'Unknown'}',
                      style: TemaAplikasi.bodySmall.copyWith(
                        color: TemaAplikasi.textTertiary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: TemaAplikasi.primarySurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add_business,
                    color: TemaAplikasi.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Text('Tambah Aset Harta', style: TemaAplikasi.titleLarge),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: pengendaliNama,
                  decoration: TemaAplikasi.inputDecoration(
                    labelText: 'Nama Aset',
                    prefixIcon: Icons.business_center_outlined,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: TemaAplikasi.inputDecoration(
                    labelText: 'Jenis Aset',
                    prefixIcon: Icons.category_outlined,
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
                  decoration: TemaAplikasi.inputDecoration(
                    labelText: 'Nilai Aset (Rp)',
                    prefixIcon: Icons.attach_money,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: pengendaliKeterangan,
                  maxLines: 3,
                  decoration: TemaAplikasi.inputDecoration(
                    labelText: 'Keterangan (Opsional)',
                    prefixIcon: Icons.notes_outlined,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal',
                  style: TextStyle(color: TemaAplikasi.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (pengendaliNama.text.isEmpty ||
                    jenisAsetTerpilih == null ||
                    pengendaliNilai.text.isEmpty) {
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
                    content: Text(berhasil
                        ? 'Aset berhasil ditambahkan'
                        : 'Gagal menambahkan aset'),
                    backgroundColor:
                        berhasil ? TemaAplikasi.success : TemaAplikasi.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
              style: TemaAplikasi.primaryButton,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    TemaAplikasi.primary.withOpacity(0.1),
                    TemaAplikasi.primary.withOpacity(0.05)
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_dapatkanIkonJenisAset(aset['jenis_aset']),
                  color: TemaAplikasi.primary, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(aset['nama_aset'] ?? 'Detail Aset',
                  style: TemaAplikasi.titleLarge,
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
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
                      Text('Keterangan:',
                          style: TemaAplikasi.bodyMedium
                              .copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: TemaAplikasi.background,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(aset['keterangan'],
                            style: TemaAplikasi.bodyMedium),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup',
                style: TextStyle(color: TemaAplikasi.textSecondary)),
          ),
          if (aset['status_verifikasi'] == 'menunggu')
            Builder(
              builder: (ctx) {
                final penyediaAuth =
                    Provider.of<PenyediaAuth>(ctx, listen: false);
                final idPengusul = aset['id_pengusul']?.toString() ?? '';
                final idPengguna = penyediaAuth.idPengguna?.toString() ?? '';
                final bisaVerifikasi = idPengusul.isNotEmpty &&
                    idPengguna.isNotEmpty &&
                    idPengusul != idPengguna;

                // Tidak tampilkan tombol jika aset sendiri
                if (!bisaVerifikasi) {
                  return const SizedBox.shrink();
                }

                return ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _tampilkanDialogVerifikasi(context, aset);
                  },
                  style: TemaAplikasi.primaryButton,
                  child: const Text('Verifikasi'),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buatBarisDetail(String label, String nilai) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: TemaAplikasi.bodyMedium
                    .copyWith(color: TemaAplikasi.textSecondary)),
          ),
          const Text(': ', style: TextStyle(fontWeight: FontWeight.w500)),
          Expanded(
              child: Text(nilai,
                  style: TemaAplikasi.bodyMedium
                      .copyWith(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  // ========== DIALOG VERIFIKASI ==========
  void _tampilkanDialogVerifikasi(
      BuildContext context, Map<String, dynamic> aset) {
    final pengendaliCatatan = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: TemaAplikasi.warningLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.verified_user_outlined,
                  color: TemaAplikasi.warning, size: 24),
            ),
            const SizedBox(width: 12),
            Text('Verifikasi Aset', style: TemaAplikasi.titleLarge),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Apakah Anda menyetujui aset "${aset['nama_aset']}"?',
                style: TemaAplikasi.bodyMedium),
            const SizedBox(height: 16),
            TextField(
              controller: pengendaliCatatan,
              maxLines: 3,
              decoration: TemaAplikasi.inputDecoration(
                labelText: 'Catatan (Opsional)',
                prefixIcon: Icons.notes_outlined,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal',
                style: TextStyle(color: TemaAplikasi.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              await _prosesVerifikasi(
                  context, aset, false, pengendaliCatatan.text);
            },
            style: TemaAplikasi.dangerButton,
            child: const Text('Tolak'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _prosesVerifikasi(
                  context, aset, true, pengendaliCatatan.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TemaAplikasi.success,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
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
        content: Text(berhasil ? 'Verifikasi berhasil' : 'Gagal verifikasi'),
        backgroundColor: berhasil ? TemaAplikasi.success : TemaAplikasi.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ========== ✅ DIALOG EDIT ASET (BARU) ==========
  void _tampilkanDialogEditAset(
      BuildContext context, Map<String, dynamic> aset) {
    final pengendaliNama =
        TextEditingController(text: aset['nama_aset']?.toString() ?? '');
    final pengendaliNilai =
        TextEditingController(text: aset['nilai']?.toString() ?? '');
    final pengendaliKeterangan =
        TextEditingController(text: aset['keterangan']?.toString() ?? '');
    String? jenisAsetTerpilih = aset['jenis_aset']?.toString();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: TemaAplikasi.infoLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    const Icon(Icons.edit, color: TemaAplikasi.info, size: 24),
              ),
              const SizedBox(width: 12),
              Text('Edit Aset', style: TemaAplikasi.titleLarge),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: pengendaliNama,
                  decoration: TemaAplikasi.inputDecoration(
                    labelText: 'Nama Aset',
                    prefixIcon: Icons.business_center_outlined,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: TemaAplikasi.inputDecoration(
                    labelText: 'Jenis Aset',
                    prefixIcon: Icons.category_outlined,
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
                  decoration: TemaAplikasi.inputDecoration(
                    labelText: 'Nilai Aset (Rp)',
                    prefixIcon: Icons.attach_money,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: pengendaliKeterangan,
                  maxLines: 3,
                  decoration: TemaAplikasi.inputDecoration(
                    labelText: 'Keterangan (Opsional)',
                    prefixIcon: Icons.notes_outlined,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal',
                  style: TextStyle(color: TemaAplikasi.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (pengendaliNama.text.isEmpty ||
                    jenisAsetTerpilih == null ||
                    pengendaliNilai.text.isEmpty) {
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

                final berhasil = await penyediaWarisan.editAset(
                  id: aset['id'].toString(),
                  namaAset: pengendaliNama.text,
                  jenisAset: jenisAsetTerpilih!,
                  nilai: double.parse(pengendaliNilai.text),
                  keterangan: pengendaliKeterangan.text.isEmpty
                      ? null
                      : pengendaliKeterangan.text,
                  nikPewaris: penyediaAuth.nikPewaris!,
                );

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(berhasil
                        ? 'Aset berhasil diupdate'
                        : 'Gagal mengupdate aset'),
                    backgroundColor:
                        berhasil ? TemaAplikasi.success : TemaAplikasi.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
              style: TemaAplikasi.primaryButton,
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  // ========== ✅ KONFIRMASI HAPUS ASET (BARU) ==========
  void _konfirmasiHapusAset(BuildContext context, Map<String, dynamic> aset) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: TemaAplikasi.errorLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.delete_outline,
                  color: TemaAplikasi.error, size: 24),
            ),
            const SizedBox(width: 12),
            Text('Hapus Aset', style: TemaAplikasi.titleLarge),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus aset "${aset['nama_aset']}"?',
          style: TemaAplikasi.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal',
                style: TextStyle(color: TemaAplikasi.textSecondary)),
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
                  backgroundColor:
                      berhasil ? TemaAplikasi.success : TemaAplikasi.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            style: TemaAplikasi.dangerButton,
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
