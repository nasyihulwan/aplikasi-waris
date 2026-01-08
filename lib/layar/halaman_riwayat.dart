import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../penyedia/penyedia_auth.dart';
import '../penyedia/penyedia_warisan.dart';

class HalamanRiwayat extends StatefulWidget {
  const HalamanRiwayat({super.key});

  @override
  _HalamanRiwayatState createState() => _HalamanRiwayatState();
}

class _HalamanRiwayatState extends State<HalamanRiwayat> {
  List<Map<String, dynamic>> _daftarRiwayat = [];
  bool _sedangMemuat = false;

  @override
  void initState() {
    super.initState();
    _muatRiwayat();
  }

  Future<void> _muatRiwayat() async {
    setState(() => _sedangMemuat = true);

    try {
      final penyediaAuth = Provider.of<PenyediaAuth>(context, listen: false);
      final penyediaWarisan =
          Provider.of<PenyediaWarisan>(context, listen: false);

      final riwayat =
          await penyediaWarisan.ambilRiwayat(penyediaAuth.nikPewaris!);

      setState(() {
        _daftarRiwayat = riwayat;
        _sedangMemuat = false;
      });
    } catch (e) {
      print('Error muat riwayat: $e');
      setState(() => _sedangMemuat = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _muatRiwayat,
        child: _sedangMemuat
            ? const Center(child: CircularProgressIndicator())
            : _daftarRiwayat.isEmpty
                ? _buatTampilanKosong()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _daftarRiwayat.length,
                    itemBuilder: (context, index) {
                      final riwayat = _daftarRiwayat[index];
                      return _buatKartuRiwayat(riwayat);
                    },
                  ),
      ),
    );
  }

  Widget _buatTampilanKosong() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 100,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Belum ada riwayat perhitungan',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Lakukan perhitungan warisan terlebih dahulu',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buatKartuRiwayat(Map<String, dynamic> riwayat) {
    final double totalHarta =
        double.tryParse(riwayat['total_harta'].toString()) ?? 0.0;
    final String tanggal = riwayat['tanggal_dibuat']?.toString() ?? '';
    final int id = int.tryParse(riwayat['id'].toString()) ?? 0;

    DateTime? tanggalParsed;
    try {
      tanggalParsed = DateTime.parse(tanggal);
    } catch (e) {
      tanggalParsed = DateTime.now();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _tampilkanDetailRiwayat(riwayat),
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
                    child: const Icon(
                      Icons.receipt_long,
                      color: Color(0xFF00796B),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Perhitungan #$id',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTanggal(tanggalParsed),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.grey,
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Harta: ',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    _formatRupiah(totalHarta),
                    style: const TextStyle(
                      color: Color(0xFF00796B),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _tampilkanDetailRiwayat(Map<String, dynamic> riwayat) {
    final String dataPerhitunganJson =
        riwayat['data_perhitungan']?.toString() ?? '{}';
    Map<String, dynamic> dataPerhitungan = {};

    try {
      dataPerhitungan = json.decode(dataPerhitunganJson);
    } catch (e) {
      print('Error parse JSON: $e');
      dataPerhitungan = {};
    }

    final List<dynamic> pembagian = dataPerhitungan['pembagian'] ?? [];
    final double totalHarta =
        double.tryParse(dataPerhitungan['total_harta'].toString()) ?? 0.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Detail Perhitungan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF004D40),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF00796B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Harta Warisan: ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatRupiah(totalHarta),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00796B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Pembagian Per Ahli Waris:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...pembagian.map((item) {
                final itemMap = item as Map<String, dynamic>;
                final String nama = itemMap['nama']?.toString() ?? 'Unknown';
                final double bagian =
                    double.tryParse(itemMap['bagian'].toString()) ?? 0.0;
                final String keterangan =
                    itemMap['keterangan']?.toString() ?? '';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              nama,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Text(
                            _formatRupiah(bagian),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF00796B),
                            ),
                          ),
                        ],
                      ),
                      if (keterangan.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          keterangan,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00796B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Tutup'),
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

  String _formatTanggal(DateTime tanggal) {
    return DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(tanggal);
  }
}
