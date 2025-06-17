import 'package:flutter/material.dart';
import '../utils/app_theme.dart';


class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 56,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: !isOutlined && backgroundColor == null ? AppTheme.primaryGradient : null,
        color: isOutlined ? Colors.transparent : backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: isOutlined ? Border.all(color: AppTheme.primaryColor, width: 2) : null,
        boxShadow: !isOutlined ? [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16), // ✅ Kurangi padding
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        textColor ?? (isOutlined ? AppTheme.primaryColor : Colors.white),
                      ),
                    ),
                  )
                else ...[
                  if (icon != null) ...[
                    Icon(
                      icon,
                      color: textColor ?? (isOutlined ? AppTheme.primaryColor : Colors.white),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible( // ✅ Tambah Flexible untuk text
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: 14, // ✅ Kurangi font size
                        fontWeight: FontWeight.w600,
                        color: textColor ?? (isOutlined ? AppTheme.primaryColor : Colors.white),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}