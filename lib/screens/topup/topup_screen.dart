import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/auth_provider.dart';
import '../../providers/topup_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_utils.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class TopupScreen extends StatefulWidget {
  const TopupScreen({super.key});

  @override
  State<TopupScreen> createState() => _TopupScreenState();
}

class _TopupScreenState extends State<TopupScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nominalController = TextEditingController();
  final List<double> _quickAmounts = [50000, 100000, 250000, 500000, 1000000, 2000000];
  
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final topupProvider = Provider.of<TopupProvider>(context, listen: false);
      topupProvider.loadTopupHistory();
    });
  }

  @override
  void dispose() {
    _nominalController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _setQuickAmount(double amount) {
    _nominalController.text = amount.toStringAsFixed(0);
  }

  Future<void> _requestTopup() async {
    if (!_formKey.currentState!.validate()) return;

    final topupProvider = Provider.of<TopupProvider>(context, listen: false);
    final nominal = AppUtils.parseStringToDouble(_nominalController.text);

    final success = await topupProvider.requestTopup(nominal);

    if (success && mounted) {
      _nominalController.clear();
      AppUtils.showSnackBar(
        context,
        'Permintaan top-up berhasil dikirim. Menunggu verifikasi admin.',
      );
      _tabController.animateTo(1); // Switch to history tab
    } else if (mounted) {
      AppUtils.showSnackBar(
        context,
        topupProvider.error ?? 'Top-up gagal. Silakan coba lagi.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        title: const Text('Top Up Saldo'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(text: 'Top Up'),
            Tab(text: 'Riwayat'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTopupForm(),
          _buildTopupHistory(),
        ],
      ),
    );
  }

  Widget _buildTopupForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Info
            FadeInDown(
              duration: const Duration(milliseconds: 600),
              child: Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Saldo Saat Ini',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppUtils.formatCurrency(authProvider.user?.balance ?? 0),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            // Quick Amount Selection
            FadeInLeft(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilih Nominal Top Up',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _quickAmounts.length,
                    itemBuilder: (context, index) {
                      final amount = _quickAmounts[index];
                      return GestureDetector(
                        onTap: () => _setQuickAmount(amount),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              AppUtils.formatCurrency(amount),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Custom Amount Input
            FadeInRight(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 300),
              child: CustomTextField(
                controller: _nominalController,
                label: 'Nominal Top Up',
                hint: 'Masukkan nominal top up',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.account_balance_wallet_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nominal tidak boleh kosong';
                  }
                  final amount = AppUtils.parseStringToDouble(value);
                  if (amount < 10000) {
                    return 'Nominal minimal Rp 10.000';
                  }
                  return null;
                },
              ),
            ),

            const SizedBox(height: 40),

            // Top Up Button
            FadeInUp(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 400),
              child: Consumer<TopupProvider>(
                builder: (context, topupProvider, child) {
                  return CustomButton(
                    text: 'Kirim Permintaan Top Up',
                    icon: Icons.send,
                    isLoading: topupProvider.isProcessing,
                    onPressed: _requestTopup,
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Info
            FadeInUp(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 500),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange[600]),
                        const SizedBox(width: 8),
                        Text(
                          'Informasi Penting',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Permintaan top-up akan diverifikasi oleh admin\n'
                      '• Proses verifikasi memakan waktu 1-24 jam\n'
                      '• Saldo akan otomatis bertambah setelah diverifikasi\n'
                      '• Anda akan mendapat notifikasi setelah verifikasi',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange[700],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopupHistory() {
    return Consumer<TopupProvider>(
      builder: (context, topupProvider, child) {
        if (topupProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (topupProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 60, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  topupProvider.error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => topupProvider.loadTopupHistory(),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        if (topupProvider.topups.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 60, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Belum ada riwayat top-up',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => topupProvider.loadTopupHistory(),
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: topupProvider.topups.length,
            itemBuilder: (context, index) {
              final topup = topupProvider.topups[index];
              
              return FadeInUp(
                duration: Duration(milliseconds: 300 + (index * 100)),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _getStatusColor(topup.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Icon(
                          _getStatusIcon(topup.status),
                          color: _getStatusColor(topup.status),
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppUtils.formatCurrency(topup.nominal),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              topup.statusText,
                              style: TextStyle(
                                fontSize: 12,
                                color: _getStatusColor(topup.status),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppUtils.formatDateTime(topup.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'menunggu_verifikasi':
        return Colors.orange;
      case 'diverifikasi':
        return AppTheme.successColor;
      case 'ditolak':
        return AppTheme.errorColor;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'menunggu_verifikasi':
        return Icons.schedule;
      case 'diverifikasi':
        return Icons.check_circle;
      case 'ditolak':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }
}