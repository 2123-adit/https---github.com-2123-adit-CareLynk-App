// lib/screens/campaign/campaign_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animate_do/animate_do.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/campaign_provider.dart';
import '../../providers/donation_provider.dart';
import '../../models/campaign_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_utils.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../donation/donation_screen.dart';

class CampaignDetailScreen extends StatefulWidget {
  final int campaignId;

  const CampaignDetailScreen({super.key, required this.campaignId});

  @override
  State<CampaignDetailScreen> createState() => _CampaignDetailScreenState();
}

class _CampaignDetailScreenState extends State<CampaignDetailScreen> {
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    
    // Inisialisasi WebViewController
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(true)
      ..setBackgroundColor(Colors.white);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final campaignProvider = Provider.of<CampaignProvider>(context, listen: false);
      campaignProvider.loadCampaignDetail(widget.campaignId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: Consumer<CampaignProvider>(
        builder: (context, campaignProvider, child) {
          if (campaignProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (campaignProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    campaignProvider.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => campaignProvider.loadCampaignDetail(widget.campaignId),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final campaign = campaignProvider.selectedCampaign;
          if (campaign == null) {
            return const Center(child: Text('Kampanye tidak ditemukan'));
          }

          return CustomScrollView(
            slivers: [
              // App Bar with Image
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: AppTheme.primaryColor,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      campaign.imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: campaign.imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[200],
                                child: const Center(child: CircularProgressIndicator()),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[200],
                                child: const Icon(Icons.image_not_supported_outlined, size: 50),
                              ),
                            )
                          : Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.image_outlined, size: 50),
                            ),
                      
                      // Gradient Overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                      
                      // Category Badge
                      Positioned(
                        bottom: 20,
                        left: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(campaign.kategori),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            campaign.kategori,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Progress
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                campaign.judul,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Progress Card
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: AppTheme.cardGradient,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Terkumpul',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Text(
                                              AppUtils.formatCurrency(campaign.totalTerkumpul),
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.successColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            const Text(
                                              'Target',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Text(
                                              AppUtils.formatCurrency(campaign.targetDonasi),
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    
                                    const SizedBox(height: 16),
                                    
                                    Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${campaign.progressPercent.toStringAsFixed(1)}% tercapai',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              'Berakhir: ${AppUtils.formatDate(campaign.tanggalBerakhir)}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                        
                                        const SizedBox(height: 8),
                                        
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: LinearProgressIndicator(
                                            value: campaign.progressPercent / 100,
                                            backgroundColor: Colors.grey[200],
                                            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.successColor),
                                            minHeight: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Description
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 200),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Deskripsi',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              
                              const SizedBox(height: 12),
                              
                              Text(
                                campaign.deskripsi,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Action Buttons - UPDATED SECTION
                      if (campaign.isActive) ...[
                        FadeInUp(
                          duration: const Duration(milliseconds: 600),
                          delay: const Duration(milliseconds: 300),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column( // ✅ Changed from Row to Column
                              children: [
                                // Donasi Button - Full width
                                SizedBox(
                                  width: double.infinity,
                                  child: CustomButton(
                                    text: 'Donasi Sekarang',
                                    icon: Icons.favorite,
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => DonationScreen(campaign: campaign),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                
                                // Laporan Button - Conditional and responsive
                                if (campaign.laporanHtml != null) ...[
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: CustomButton(
                                      text: 'Lihat Laporan Transparansi',
                                      icon: Icons.article_outlined,
                                      isOutlined: true,
                                      onPressed: () => _showReportDialog(context, campaign),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ] else ...[
                        // Campaign finished - same layout
                        FadeInUp(
                          duration: const Duration(milliseconds: 600),
                          delay: const Duration(milliseconds: 300),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.info_outline, color: Colors.grey[600]),
                                      const SizedBox(width: 12),
                                      Expanded( // ✅ Added Expanded
                                        child: Text(
                                          'Kampanye ini telah selesai',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                if (campaign.laporanHtml != null) ...[
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: CustomButton(
                                      text: 'Lihat Laporan Transparansi',
                                      icon: Icons.article_outlined,
                                      isOutlined: true,
                                      onPressed: () => _showReportDialog(context, campaign),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Pendidikan':
        return const Color(0xFF4FACFE);
      case 'Kesehatan':
        return const Color(0xFF43E97B);
      case 'Bencana':
        return const Color(0xFFF5576C);
      case 'Sosial':
        return const Color(0xFFF093FB);
      default:
        return AppTheme.primaryColor;
    }
  }

  // ✅ UPDATED: Responsive Report Dialog
  void _showReportDialog(BuildContext context, Campaign campaign) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.all(16), // ✅ Added padding
        child: Container(
          width: double.infinity, // ✅ Full width
          height: MediaQuery.of(context).size.height * 0.8,
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 32, // ✅ Max width
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded( // ✅ Added Expanded
                      child: Text(
                        'Laporan Transparansi',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: WebViewWidget(
                  controller: _webViewController
                    ..loadHtmlString(
                      campaign.laporanHtml!,
                      baseUrl: 'about:blank',
                    ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ✅ ALTERNATIVE: Report as separate screen
class LaporanScreen extends StatelessWidget {
  final Campaign campaign;

  const LaporanScreen({super.key, required this.campaign});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Transparansi'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: campaign.laporanHtml != null
          ? WebViewWidget(
              controller: WebViewController()
                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                ..loadHtmlString(
                  campaign.laporanHtml!,
                  baseUrl: 'about:blank',
                ),
            )
          : const Center(
              child: Text('Laporan tidak tersedia'),
            ),
    );
  }
}