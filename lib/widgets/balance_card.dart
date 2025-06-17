import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../utils/app_theme.dart';
import '../utils/app_utils.dart';

class BalanceCard extends StatelessWidget {
  final double balance;
  final VoidCallback? onTopupTap;

  const BalanceCard({
    super.key,
    required this.balance,
    this.onTopupTap,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.3),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Saldo Anda',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: onTopupTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Top Up',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // ✅ FIX: Responsive text dengan Flexible
            Flexible(
              child: Text(
                AppUtils.formatCurrency(balance),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis, // ✅ Tambah ellipsis
                maxLines: 1, // ✅ Batasi 1 baris
              ),
            ),
            
            const SizedBox(height: 16),
            
            // ✅ FIX: Container info dengan Flexible
            Container(
              width: double.infinity, // ✅ Full width
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start, // ✅ Align ke atas
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.white70,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  // ✅ FIX: Expanded untuk menghindari overflow
                  Expanded(
                    child: Text(
                      'Saldo akan otomatis bertambah setelah top-up diverifikasi',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.3, // ✅ Line spacing
                      ),
                      maxLines: 2, // ✅ Maksimal 2 baris
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ ALTERNATIVE: Balance Card dengan layout yang lebih compact
class BalanceCardCompact extends StatelessWidget {
  final double balance;
  final VoidCallback? onTopupTap;

  const BalanceCardCompact({
    super.key,
    required this.balance,
    this.onTopupTap,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20), // ✅ Kurangi padding
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.3),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded( // ✅ Tambah Expanded
                  child: Text(
                    'Saldo Anda',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8), // ✅ Spacing
                GestureDetector(
                  onTap: onTopupTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Text(
                      '+ Top Up',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // ✅ Balance dengan auto-resize
            LayoutBuilder(
              builder: (context, constraints) {
                return Text(
                  AppUtils.formatCurrency(balance),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: constraints.maxWidth < 300 ? 24 : 28, // ✅ Responsive font
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                );
              },
            ),
            
            const SizedBox(height: 12),
            
            // ✅ Info text yang lebih pendek
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Saldo bertambah otomatis setelah verifikasi admin',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  height: 1.2,
                ),
                textAlign: TextAlign.center, // ✅ Center text
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ SIMPLE VERSION: Minimal overflow risk
class BalanceCardSimple extends StatelessWidget {
  final double balance;
  final VoidCallback? onTopupTap;

  const BalanceCardSimple({
    super.key,
    required this.balance,
    this.onTopupTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // ✅ Minimal size
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Saldo Anda',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (onTopupTap != null)
                  TextButton(
                    onPressed: onTopupTap,
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      minimumSize: const Size(80, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text(
                      'Top Up',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Text(
              AppUtils.formatCurrency(balance),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}