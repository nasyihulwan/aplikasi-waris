import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class KartuAset extends StatelessWidget {
  final Map<String, dynamic> aset;
  final VoidCallback? onTap;
  final VoidCallback? onVerifikasi;
  final VoidCallback? onDelete;

  const KartuAset({
    super.key,
    required this.aset,
    this.onTap,
    this.onVerifikasi,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
        onTap: onTap,
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
                        _formatRupiah((aset['nilai'] ?? 0).toDouble()),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF00796B),
                        ),
                      ),
                    ],
                  ),
                  if (status == 'menunggu' && onVerifikasi != null)
                    ElevatedButton.icon(
                      onPressed: onVerifikasi,
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
}
