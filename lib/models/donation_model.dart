import 'package:donation_app/models/campaign_model.dart';

class Donation {
  final int id;
  final int userId;
  final int campaignId;
  final double nominal;
  final bool isAnonymous;        // ✅ TAMBAH
  final String? donorName;       // ✅ TAMBAH
  final String? message;         // ✅ TAMBAH
  final DateTime createdAt;
  final DateTime updatedAt;
  final Campaign? campaign;

  Donation({
    required this.id,
    required this.userId,
    required this.campaignId,
    required this.nominal,
    this.isAnonymous = false,    // ✅ TAMBAH
    this.donorName,              // ✅ TAMBAH
    this.message,                // ✅ TAMBAH
    required this.createdAt,
    required this.updatedAt,
    this.campaign,
  });

  // ✅ TAMBAH getter untuk display name
  String get displayName {
    if (isAnonymous) return 'Anonim';
    return donorName ?? 'Donatur';
  }

  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      campaignId: json['campaign_id'] ?? 0,
      nominal: double.tryParse(json['nominal'].toString()) ?? 0.0,
      isAnonymous: json['is_anonymous'] ?? false,    // ✅ TAMBAH
      donorName: json['donor_name'],                 // ✅ TAMBAH
      message: json['message'],                      // ✅ TAMBAH
      createdAt: DateTime.tryParse(json['created_at']) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']) ?? DateTime.now(),
      campaign: json['campaign'] != null ? Campaign.fromJson(json['campaign']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'campaign_id': campaignId,
      'nominal': nominal,
      'is_anonymous': isAnonymous,     // ✅ TAMBAH
      'donor_name': donorName,         // ✅ TAMBAH
      'message': message,              // ✅ TAMBAH
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'campaign': campaign?.toJson(),
    };
  }
}