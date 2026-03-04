// lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/core/constants/app_strings.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/providers/task_provider.dart';
import 'package:sunu_task/screens/auth/register_screen.dart';
import 'package:sunu_task/screens/home/home_screen.dart';
import 'package:sunu_task/widgets/common/custom_button.dart';
import 'package:sunu_task/widgets/common/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  final AuthProvider authProvider;
  final ProjectProvider projectProvider;
  final TaskProvider taskProvider;

  const LoginScreen({
    super.key,
    required this.authProvider,
    required this.projectProvider,
    required this.taskProvider,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Clé pour déclencher la validation du formulaire
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers pour lire les valeurs des champs
  final TextEditingController _emailController    = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    // IMPORTANT : libérer la mémoire des controllers
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Logique de connexion ─────────────────────────────────────────────────

  Future<void> _handleLogin() async {
    // 1. Valider tous les champs — arrêter si une erreur existe
    if (!_formKey.currentState!.validate()) return;

    // 2. Appeler AuthProvider.login()
    final bool success = await widget.authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    // Vérifier que le widget est encore monté après l'await
    if (!mounted) return;

    if (success) {
      // 3a. Charger les projets de l'utilisateur connecté
      await widget.projectProvider.loadProjects(
        widget.authProvider.currentUser!.id,
      );
      if (!mounted) return;

      // 3b. Naviguer vers HomeScreen en supprimant toute la pile
      // pushAndRemoveUntil → l'utilisateur ne peut pas revenir en arrière
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            authProvider: widget.authProvider,
            projectProvider: widget.projectProvider,
            taskProvider: widget.taskProvider,
          ),
        ),
            (route) => false, // Supprimer TOUS les écrans précédents
      );
    } else {
      // 3c. Afficher l'erreur dans un SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.authProvider.error ?? AppStrings.error,
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  // ── Interface ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),

                // ── Logo ─────────────────────────────────────────────────
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.task_alt,
                      size: 44,
                      color: AppColors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                // ── Titre ────────────────────────────────────────────────
                Text(
                  AppStrings.login,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Connectez-vous à votre compte',
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 36),

                // ── Champ Email ──────────────────────────────────────────
                CustomTextField(
                  label: AppStrings.email,
                  controller: _emailController,
                  hint: 'exemple@email.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppStrings.emailRequired;
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return AppStrings.invalidEmail;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ── Champ Mot de passe ───────────────────────────────────
                CustomTextField(
                  label: AppStrings.password,
                  controller: _passwordController,
                  prefixIcon: Icons.lock_outline,
                  obscureText: true, // Active le toggle œil automatiquement
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.passwordRequired;
                    }
                    if (value.length < 6) {
                      return AppStrings.passwordTooShort;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // ── Bouton Se connecter (avec état loading) ──────────────
                // ListenableBuilder se reconstruit quand authProvider change
                // (isLoading passe à true/false pendant la requête)
                ListenableBuilder(
                  listenable: widget.authProvider,
                  builder: (context, _) {
                    return CustomButton(
                      text: AppStrings.login,
                      isLoading: widget.authProvider.isLoading,
                      onPressed: _handleLogin,
                    );
                  },
                ),
                const SizedBox(height: 24),

                // ── Lien inscription ─────────────────────────────────────
                // "Pas de compte ? S'inscrire"
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${AppStrings.noAccount} ',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Effacer l'erreur avant de naviguer
                        widget.authProvider.clearError();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RegisterScreen(
                              authProvider: widget.authProvider,
                              projectProvider: widget.projectProvider,
                              taskProvider: widget.taskProvider,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        AppStrings.register,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}