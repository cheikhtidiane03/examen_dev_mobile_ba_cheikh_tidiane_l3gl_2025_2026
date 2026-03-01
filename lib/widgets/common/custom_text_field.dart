// lib/widgets/common/custom_text_field.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

/**
 * Champ de texte personnalisé réutilisable.
 *
 * Supporte :
 * - Label flottant et texte d'aide (hint)
 * - Validation avec message d'erreur (AppStrings)
 * - Mode mot de passe (obscureText) avec toggle visibilité (icône œil)
 * - Icône de préfixe
 * - Type de clavier personnalisable
 * - Multiligne (maxLines > 1)
 * - État désactivé
 */
class CustomTextField extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final int maxLines;
  final bool enabled;
  final String? initialValue;
  final void Function(String)? onChanged;

  const CustomTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.maxLines = 1,
    this.enabled = true,
    this.initialValue,
    this.onChanged,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  /// État interne de la visibilité du mot de passe
  /// Initialisé à widget.obscureText dans initState()
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      initialValue: widget.initialValue,
      obscureText: _isObscured,
      keyboardType: widget.maxLines > 1
          ? TextInputType.multiline
          : widget.keyboardType,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      enabled: widget.enabled,
      onChanged: widget.onChanged,
      style: const TextStyle(
        fontSize: 15,
        color: AppColors.textPrimary,
      ),
      // Validation : utilise AppStrings pour les messages d'erreur
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        hintStyle: const TextStyle(
          color: AppColors.textDisable,
          fontSize: 14,
        ),
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
        // Icône de préfixe (optionnelle)
        prefixIcon: widget.prefixIcon != null
            ? Icon(
          widget.prefixIcon,
          color: AppColors.textSecondary,
          size: 20,
        )
            : null,
        // Icône œil uniquement pour les champs mot de passe
        suffixIcon: widget.obscureText
            ? IconButton(
          tooltip: _isObscured
              ? AppStrings.password   // "Mot de passe"
              : AppStrings.password,
          onPressed: () {
            setState(() {
              _isObscured = !_isObscured;
            });
          },
          icon: Icon(
            _isObscured
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: AppColors.textSecondary,
            size: 20,
          ),
        )
            : null,
        // ── Bordures selon l'état du champ ──────────────────────────
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.border,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
        filled: true,
        fillColor: widget.enabled
            ? AppColors.surface
            : AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        errorStyle: const TextStyle(
          color: AppColors.error,
          fontSize: 12,
        ),
      ),
    );
  }
}