class Topup {
  final int id;
  final int userId;
  final double nominal;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Topup({
    required this.id,
    required this.userId,
    required this.nominal,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPending => status == 'menunggu_verifikasi';
  bool get isVerified => status == 'diverifikasi';
  bool get isRejected => status == 'ditolak';

  String get statusText {
    switch (status) {
      case 'menunggu_verifikasi':
        return 'Menunggu Verifikasi';
      case 'diverifikasi':
        return 'Diverifikasi';
      case 'ditolak':
        return 'Ditolak';
      default:
        return status;
    }
  }

  factory Topup.fromJson(Map<String, dynamic> json) {
    return Topup(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      nominal: double.tryParse(json['nominal'].toString()) ?? 0.0,
      status: json['status'] ?? 'menunggu_verifikasi',
      createdAt: DateTime.tryParse(json['created_at']) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'nominal': nominal,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}