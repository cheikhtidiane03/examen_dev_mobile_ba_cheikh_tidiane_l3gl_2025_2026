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
 *
 * Utilisation simple :
 *   LoadingIndicator()
 *
 * Plein écran :
 *   LoadingIndicator(fullScreen: true)
 */
class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  /// Si true, occupe tout l'écran avec un fond semi-transparent
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
        if (fullScreen) ...[
          const SizedBox(height: 16),
          Text(
            AppStrings.loading,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );

    if (fullScreen) {
      return Container(
        color: Colors.black.withOpacity(0.4),
        child: Center(child: indicator),
      );
    }

    return Center(child: indicator);
  }
}