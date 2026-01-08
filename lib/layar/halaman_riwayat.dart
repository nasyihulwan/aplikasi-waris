import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../penyedia/penyedia_auth.dart';
import '../penyedia/penyedia_warisan.dart';

class HalamanRiwayat extends StatefulWidget {
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
            ? Center(child: CircularProgressIndicator())
            : _daftarRiwayat.isEmpty
                ? _buatTampilanKosong()
                : ListView.builder(
                    padding: EdgeInsets.all(16),
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
    return Center(
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
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _tampilkanDetailRiwayat(riwayat),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFF00796B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.receipt_long,
                      color: Color(0xFF00796B),
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Perhitungan #$id',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          _formatTanggal(tanggalParsed),
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey,
                  ),
                ],
              ),
              Divider(height: 24),
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
                    style: TextStyle(
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.all(20),
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
              SizedBox(height: 20),
              Text(
                'Detail Perhitungan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF004D40),
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF00796B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Harta Warisan: ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatRupiah(totalHarta),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00796B),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Pembagian Per Ahli Waris:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              ...pembagian.map((item) {
                final itemMap = item as Map<String, dynamic>;
                final String nama = itemMap['nama']?.toString() ?? 'Unknown';
                final double bagian =
                    double.tryParse(itemMap['bagian'].toString()) ?? 0.0;
                final String keterangan =
                    itemMap['keterangan']?.toString() ?? '';

                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(16),
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
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Text(
                            _formatRupiah(bagian),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF00796B),
                            ),
                          ),
                        ],
                      ),
                      if (keterangan.isNotEmpty) ...[
                        SizedBox(height: 8),
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
              }).toList(),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Tutup'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF00796B),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
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
