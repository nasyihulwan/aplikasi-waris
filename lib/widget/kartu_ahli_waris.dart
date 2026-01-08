import 'package:flutter/material.dart';

class KartuAhliWaris extends StatelessWidget {
  final Map<String, dynamic> ahliWaris;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const KartuAhliWaris({
    Key? key,
    required this.ahliWaris,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: _dapatkanWarnaHubungan(ahliWaris['hubungan']),
          child: Icon(
            _dapatkanIkonHubungan(ahliWaris['hubungan']),
            color: Colors.white,
          ),
        ),
        title: Text(
          ahliWaris['nama_lengkap'] ?? 'Unknown',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              _dapatkanLabelHubungan(ahliWaris['hubungan']),
              style: TextStyle(color: Colors.grey[700]),
            ),
            SizedBox(height: 2),
            Text(
              'Jenis Kelamin: ${ahliWaris['jenis_kelamin'] ?? '-'}',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          icon: Icon(Icons.more_vert),
          itemBuilder: (context) => [
            if (onEdit != null)
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.edit, color: Colors.blue),
                  title: Text('Edit'),
                  contentPadding: EdgeInsets.zero,
                ),
                onTap: onEdit,
              ),
            if (onDelete != null)
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Hapus'),
                  contentPadding: EdgeInsets.zero,
                ),
                onTap: onDelete,
              ),
          ],
        ),
      ),
    );
  }

  IconData _dapatkanIkonHubungan(String? hubungan) {
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
      default:
        return Icons.people;
    }
  }

  Color _dapatkanWarnaHubungan(String? hubungan) {
    switch (hubungan) {
      case 'istri':
      case 'suami':
        return Colors.pink;
      case 'anak_laki':
        return Colors.blue;
      case 'anak_perempuan':
        return Colors.purple;
      case 'ayah':
      case 'ibu':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _dapatkanLabelHubungan(String? hubungan) {
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
        return 'Lainnya';
    }
  }
}
