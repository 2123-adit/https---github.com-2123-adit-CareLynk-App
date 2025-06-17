import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class AppUtils {
  // ✅ FIX: Currency formatter yang aman
  static String formatCurrency(double amount) {
    try {
      // Gunakan simple formatting tanpa locale
      return 'Rp ${NumberFormat('#,###', 'en_US').format(amount.round())}';
    } catch (e) {
      // Fallback jika ada error
      return 'Rp ${amount.round().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
    }
  }
  
  // ✅ ALTERNATIVE: Simple currency format
  static String formatCurrencySimple(double amount) {
    final formatter = NumberFormat.decimalPattern();
    return 'Rp ${formatter.format(amount.round())}';
  }
  
  // ✅ SAFE: Manual currency formatting
  static String formatCurrencyManual(double amount) {
    String number = amount.round().toString();
    String result = '';
    int count = 0;
    
    for (int i = number.length - 1; i >= 0; i--) {
      if (count == 3) {
        result = '.$result';
        count = 0;
      }
      result = number[i] + result;
      count++;
    }
    
    return 'Rp $result';
  }
  
  static String formatDate(DateTime date) {
    try {
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
  
  static String formatDateTime(DateTime date) {
    try {
      return DateFormat('dd MMM yyyy HH:mm').format(date);
    } catch (e) {
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
    }
  }
  
  static double parseStringToDouble(String value) {
    return double.tryParse(value.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
  }
  
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}