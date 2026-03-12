// lib/widgets/common/loading_indicator.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

/**
 * Indicateur de chargement réutilisable.
 *
 * - Centré dans son parent par défaut
 * - Taille, couleur et épaisseur personnalisables
 * - Option fullScreen : overlay semi-transparent sur tout l'écran
 * - Texte "Chargement..." via Visibility (visible uniquement en fullScreen)
 */
class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;
  final bool fullScreen;

  const LoadingIndicator({
    super.key,
    this.size = 40,
    this.color,
    this.strokeWidth = 3,
    this.fullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final Widget indicator = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: strokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? AppColors.primary,
            ),
          ),
        ),
        // Texte visible uniquement en mode fullScreen via Visibility
        Visibility(
          visible: fullScreen,
          child: const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Text(
              AppStrings.loading,
              style: TextStyle(
                color: AppColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );

    // Overlay fullScreen via Visibility
    return Visibility(
      visible: fullScreen,
      replacement: Center(child: indicator),
      child: Container(
        color: Colors.black.withValues(alpha: 0.4),
        child: Center(child: indicator),
      ),
    );
  }
}