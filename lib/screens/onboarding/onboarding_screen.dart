// lib/screens/onboarding/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/core/constants/app_strings.dart';
import 'package:sunu_task/providers/app_provider.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/providers/task_provider.dart';
import 'package:sunu_task/screens/auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final AppProvider appProvider;
  final AuthProvider authProvider;
  final ProjectProvider projectProvider;
  final TaskProvider taskProvider;

  const OnboardingScreen({
    super.key,
    required this.appProvider,
    required this.authProvider,
    required this.projectProvider,
    required this.taskProvider,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Données des 3 pages d'onboarding (depuis AppStrings)
  static const List<_PageData> _pages = [
    _PageData(
      icon: Icons.task_alt_rounded,
      title: AppStrings.onboardingTitle1,
      description: AppStrings.onboardingDesc1,
    ),
    _PageData(
      icon: Icons.group_outlined,
      title: AppStrings.onboardingTitle2,
      description: AppStrings.onboardingDesc2,
    ),
    _PageData(
      icon: Icons.calendar_month_outlined,
      title: AppStrings.onboardingTitle3,
      description: AppStrings.onboardingDesc3,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _isLastPage => _currentPage == _pages.length - 1;

  // ── Navigation entre pages ───────────────────────────────────────────────

  void _onNextPressed() {
    if (_isLastPage) {
      _goToLogin(); // Dernière page → "Commencer"
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onPreviousPressed() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  // ── Terminer l'onboarding et aller au LoginScreen ────────────────────────

  Future<void> _goToLogin() async {
    // Marquer l'onboarding comme terminé dans SharedPreferences
    await widget.appProvider.completeOnboarding();

    if (!mounted) return;

    // Bouton "Commencer" → naviguer vers LoginScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LoginScreen(
          authProvider: widget.authProvider,
          projectProvider: widget.projectProvider,
          taskProvider: widget.taskProvider,
        ),
      ),
    );
  }

  // ── Interface ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Bouton Passer (haut droite) ──────────────────────────────
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 12, 16, 0),
                child: TextButton(
                  onPressed: _goToLogin,
                  child: Text(
                    AppStrings.skip,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            // ── PageView (les 3 pages) ────────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _pages.length,
                itemBuilder: (_, index) => _buildPage(_pages[index]),
              ),
            ),

            // ── Bas : indicateurs + boutons ──────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  // Points de progression
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                          (index) => _buildDot(index),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Boutons Précédent / Suivant (ou Commencer)
                  Row(
                    children: [
                      // Bouton Précédent (caché sur la 1ère page)
                      if (_currentPage > 0) ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _onPreviousPressed,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              minimumSize: const Size(0, 52),
                              side: const BorderSide(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              AppStrings.previous,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],

                      // Bouton Suivant / Commencer
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _onNextPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            minimumSize: const Size(0, 52),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            // "Commencer" sur la dernière page, "Suivant" sinon
                            _isLastPage
                                ? AppStrings.getStarted
                                : AppStrings.next,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Page individuelle ────────────────────────────────────────────────────

  Widget _buildPage(_PageData page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icône dans un cercle coloré
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 75,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 48),

          Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            page.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ── Point de progression ─────────────────────────────────────────────────

  Widget _buildDot(int index) {
    final bool isActive = index == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 28 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.border,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// Modèle interne pour les données de chaque page
class _PageData {
  final IconData icon;
  final String title;
  final String description;

  const _PageData({
    required this.icon,
    required this.title,
    required this.description,
  });
}