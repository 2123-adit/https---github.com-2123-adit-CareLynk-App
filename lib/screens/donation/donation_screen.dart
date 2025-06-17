import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/auth_provider.dart';
import '../../providers/donation_provider.dart';
import '../../models/campaign_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_utils.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class DonationScreen extends StatefulWidget {
  final Campaign campaign;

  const DonationScreen({super.key, required this.campaign});

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nominalController = TextEditingController();
  final _donorNameController = TextEditingController();  // ✅ TAMBAH
  final _messageController = TextEditingController();    // ✅ TAMBAH
  
  final List<double> _quickAmounts = [10000, 25000, 50000, 100000, 250000, 500000];
  bool _isAnonymous = false;  // ✅ TAMBAH

  @override
  void initState() {
    super.initState();
    // ✅ Auto-fill nama user saat pertama kali
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      _donorNameController.text = authProvider.user!.name;
    }
  }

  @override
  void dispose() {
    _nominalController.dispose();
    _donorNameController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _setQuickAmount(double amount) {
    _nominalController.text = amount.toStringAsFixed(0);
  }

  Future<void> _donate() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final donationProvider = Provider.of<DonationProvider>(context, listen: false);
    
    final nominal = AppUtils.parseStringToDouble(_nominalController.text);
    
    // Check balance
    if (authProvider.user!.balance < nominal) {
      AppUtils.showSnackBar(
        context,
        'Saldo tidak mencukupi. Silakan lakukan top-up terlebih dahulu.',
        isError: true,
      );
      return;
    }

    // ✅ ENHANCED: Show confirmation dialog dengan data lengkap
    final confirmed = await _showConfirmationDialog(nominal, authProvider);
    if (confirmed != true) return;

    // ✅ ENHANCED: Donate dengan data tambahan
    final success = await donationProvider.makeDonation(
      campaignId: widget.campaign.id,
      nominal: nominal,
      isAnonymous: _isAnonymous,                           // ✅ TAMBAH
      donorName: _isAnonymous ? null : _donorNameController.text.trim(),  // ✅ TAMBAH
      message: _messageController.text.trim().isEmpty ? null : _messageController.text.trim(),  // ✅ TAMBAH
    );

    if (success && mounted) {
      // Update user balance locally
      authProvider.updateUserBalance(authProvider.user!.balance - nominal);
      
      // ✅ ENHANCED: Show success dialog dengan preview
      _showSuccessDialog(nominal);
    } else if (mounted) {
      AppUtils.showSnackBar(
        context,
        donationProvider.error ?? 'Donasi gagal. Silakan coba lagi.',
        isError: true,
      );
    }
  }

  Future<bool?> _showConfirmationDialog(double nominal, AuthProvider authProvider) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Donasi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kampanye: ${widget.campaign.judul}'),
            const SizedBox(height: 8),
            Text(
              'Nominal: ${AppUtils.formatCurrency(nominal)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Nama: ${_isAnonymous ? "Anonim" : _donorNameController.text.trim()}',
              style: TextStyle(
                color: _isAnonymous ? Colors.orange[700] : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (_messageController.text.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Pesan: "${_messageController.text.trim()}"',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Saldo setelah donasi: ${AppUtils.formatCurrency(authProvider.user!.balance - nominal)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Donasi'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(double nominal) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: AppTheme.successColor,
              size: 80,
            ),
            const SizedBox(height: 16),
            const Text(
              'Donasi Berhasil!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Terima kasih ${_isAnonymous ? "Anonim" : _donorNameController.text.trim()}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'telah berdonasi sebesar ${AppUtils.formatCurrency(nominal)}',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to campaign detail
            },
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        title: const Text('Donasi'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campaign Info
              FadeInDown(
                duration: const Duration(milliseconds: 600),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.campaign.judul,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.campaign.kategori,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Terkumpul',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              Text(
                                AppUtils.formatCurrency(widget.campaign.totalTerkumpul),
                                style: const TextStyle(
                                  fontSize: 16,
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
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              Text(
                                AppUtils.formatCurrency(widget.campaign.targetDonasi),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Balance Info
              FadeInLeft(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 200),
                child: Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.account_balance_wallet, color: Colors.white),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Saldo Anda',
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                              Text(
                                AppUtils.formatCurrency(authProvider.user?.balance ?? 0),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),

              // Quick Amount Selection
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 300),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pilih Nominal Donasi',
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
                        crossAxisCount: 3,
                        childAspectRatio: 2.5,
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
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryColor,
                                ),
                                textAlign: TextAlign.center,
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
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 400),
                child: CustomTextField(
                  controller: _nominalController,
                  label: 'Nominal Donasi',
                  hint: 'Masukkan nominal donasi',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.payments_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nominal tidak boleh kosong';
                    }
                    final amount = AppUtils.parseStringToDouble(value);
                    if (amount < 1000) {
                      return 'Nominal minimal Rp 1.000';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 20),

              // ✅ NEW: Anonymous Toggle
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 500),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.visibility_off, color: Colors.orange[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Donasi Anonim',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange[800],
                              ),
                            ),
                            Text(
                              'Nama Anda tidak akan ditampilkan di daftar donatur',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isAnonymous,
                        onChanged: (value) {
                          setState(() {
                            _isAnonymous = value;
                          });
                        },
                        activeColor: Colors.orange[700],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ✅ NEW: Donor Name (jika tidak anonim)
              if (!_isAnonymous) ...[
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 600),
                  child: CustomTextField(
                    controller: _donorNameController,
                    label: 'Nama Donatur',
                    hint: 'Nama yang akan ditampilkan',
                    prefixIcon: Icons.person_outline,
                    validator: (value) {
                      if (!_isAnonymous && (value == null || value.trim().isEmpty)) {
                        return 'Nama donatur tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // ✅ NEW: Message/Doa
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 700),
                child: CustomTextField(
                  controller: _messageController,
                  label: 'Pesan/Doa (Opsional)',
                  hint: 'Tulis pesan atau doa untuk kampanye ini...',
                  maxLines: 3,
                  prefixIcon: Icons.message_outlined,
                ),
              ),

              const SizedBox(height: 40),

              // Donate Button
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 800),
                child: Consumer<DonationProvider>(
                  builder: (context, donationProvider, child) {
                    return CustomButton(
                      text: 'Donasi Sekarang',
                      icon: Icons.favorite,
                      isLoading: donationProvider.isDonating,
                      onPressed: _donate,
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Info
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 900),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[600]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Donasi akan langsung dipotong dari saldo Anda dan tidak dapat dibatalkan.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[800],
                          ),
                        ),
                      ),
                    ],
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