// lib/utils/app_theme.dart - ULTIMATE FIX untuk Flutter 3.32.2
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF667EEA);
  static const Color secondaryColor = Color(0xFF764BA2);
  static const Color accentColor = Color(0xFF4FACFE);
  static const Color successColor = Color(0xFF43E97B);
  static const Color warningColor = Color(0xFFF093FB);
  static const Color errorColor = Color(0xFFF5576C);
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ✅ SOLUTION 1: Hapus cardTheme completely
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        surface: const Color(0xFFF8F9FF),
      ),
      
      scaffoldBackgroundColor: const Color(0xFFF8F9FF),
      
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData.light().textTheme,
      ),
      
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: GoogleFonts.poppins(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      
      // ✅ HAPUS CARDTHEME - Ini yang menyebabkan error
      // cardTheme: ... <- HAPUS BAGIAN INI
      
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}

// ✅ SOLUTION 2: Theme tanpa cardTheme sama sekali
class AppThemeSimple {
  static const Color primaryColor = Color(0xFF667EEA);
  static const Color secondaryColor = Color(0xFF764BA2);
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
      scaffoldBackgroundColor: const Color(0xFFF8F9FF),
      fontFamily: GoogleFonts.poppins().fontFamily,
      // TIDAK ADA cardTheme sama sekali
    );
  }
}

// ✅ SOLUTION 3: Custom Card Widget (RECOMMENDED)
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final VoidCallback? onTap;
  final double borderRadius;
  final List<BoxShadow>? boxShadow;

  const AppCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.color,
    this.onTap,
    this.borderRadius = 16,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final defaultShadow = [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ];

    Widget cardWidget = Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow ?? defaultShadow,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: cardWidget,
        ),
      );
    }

    return cardWidget;
  }
}

// ✅ SOLUTION 4: Extension untuk mudah styling
extension CardExtension on Widget {
  Widget toCard({
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    Color? color,
    VoidCallback? onTap,
    double borderRadius = 16,
  }) {
    return AppCard(
      margin: margin,
      padding: padding,
      color: color,
      onTap: onTap,
      borderRadius: borderRadius,
      child: this,
    );
  }
}

// ✅ CONTOH PENGGUNAAN CUSTOM CARD:
/*
// Ganti dari:
Card(
  child: Padding(
    padding: EdgeInsets.all(20),
    child: Text('Hello'),
  ),
)

// Menjadi:
AppCard(
  child: Text('Hello'),
)

// Atau menggunakan extension:
Text('Hello').toCard()

// Dengan styling:
AppCard(
  margin: EdgeInsets.all(16),
  color: Colors.blue[50],
  onTap: () => print('Tapped'),
  child: Column(
    children: [
      Text('Title'),
      Text('Content'),
    ],
  ),
)
*/