// lib/widgets/common/custom_button.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/**
 * Bouton personnalisé réutilisable avec deux variantes :
 * - ElevatedButton (isOutlined = false, par défaut)
 * - OutlinedButton (isOutlined = true)
 *
 * Supporte :
 * - État de chargement (isLoading) → affiche CircularProgressIndicator
 * - Icône optionnelle à gauche du texte via Visibility
 * - Largeur, hauteur et couleur personnalisables
 */
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final double? width;
  final double? height;
  final Color? color;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.width,
    this.height,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveColor = color ?? AppColors.primary;

    // Contenu : loader OU icône + texte
    // Visibility remplace if (icon != null)
    final Widget child = isLoading
        ? SizedBox(
      width: 22,
      height: 22,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(
          isOutlined ? effectiveColor : AppColors.white,
        ),
      ),
    )
        : Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icône via Visibility
        Visibility(
          visible: icon != null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon ?? Icons.check, size: 18),
              const SizedBox(width: 8),
            ],
          ),
        ),
        Text(text),
      ],
    );

    final VoidCallback? effectiveOnPressed =
    isLoading ? null : onPressed;

    if (isOutlined) {
      return SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: OutlinedButton(
          onPressed: effectiveOnPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: effectiveColor,
            disabledForegroundColor: AppColors.textDisable,
            minimumSize: Size(0, height ?? 50),
            side: BorderSide(
              color: isLoading || onPressed == null
                  ? AppColors.border
                  : effectiveColor,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: effectiveOnPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveColor,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.border,
          disabledForegroundColor: AppColors.textDisable,
          minimumSize: Size(0, height ?? 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
        ),
        child: child,
      ),
    );
  }
}