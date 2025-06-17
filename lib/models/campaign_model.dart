import 'package:donation_app/utils/app_utils.dart';

class Campaign {
  final int id;
  final String judul;
  final String deskripsi;
  final String kategori;
  final double targetDonasi;
  final double totalTerkumpul;
  final DateTime tanggalBerakhir;
  final String? gambar;
  final String status;
  final String? laporanHtml;
  final DateTime createdAt;
  final DateTime updatedAt;

  Campaign({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.kategori,
    required this.targetDonasi,
    required this.totalTerkumpul,
    required this.tanggalBerakhir,
    this.gambar,
    required this.status,
    this.laporanHtml,
    required this.createdAt,
    required this.updatedAt,
  });

  double get progressPercent {
    if (targetDonasi == 0) return 0;
    return (totalTerkumpul / targetDonasi * 100).clamp(0, 100);
  }

  String get imageUrl {
    if (gambar == null || gambar!.isEmpty) return '';
    return 'http://10.0.2.2:8000/storage/$gambar'; // Adjust base URL as needed
  }

  bool get isActive => status == 'aktif';
  bool get isCompleted => status == 'selesai';

  // ✅ SAFE FORMATTING methods
  String get formattedTarget {
    return AppUtils.formatCurrency(targetDonasi);
  }

  String get formattedTotal {
    return AppUtils.formatCurrency(totalTerkumpul);
  }

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['id'] ?? 0,
      judul: json['judul'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      kategori: json['kategori'] ?? '',
      targetDonasi: double.tryParse(json['target_donasi'].toString()) ?? 0.0,
      totalTerkumpul: double.tryParse(json['total_terkumpul'].toString()) ?? 0.0,
      tanggalBerakhir: DateTime.tryParse(json['tanggal_berakhir']) ?? DateTime.now(),
      gambar: json['gambar'],
      status: json['status'] ?? 'aktif',
      laporanHtml: json['laporan_html'],
      createdAt: DateTime.tryParse(json['created_at']) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'deskripsi': deskripsi,
      'kategori': kategori,
      'target_donasi': targetDonasi,
      'total_terkumpul': totalTerkumpul,
      'tanggal_berakhir': tanggalBerakhir.toIso8601String(),
      'gambar': gambar,
      'status': status,
      'laporan_html': laporanHtml,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
