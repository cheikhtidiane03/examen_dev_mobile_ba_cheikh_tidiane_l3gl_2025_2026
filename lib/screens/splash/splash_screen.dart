// lib/screens/splash/splash_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/core/constants/app_strings.dart';
import 'package:sunu_task/providers/app_provider.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/providers/task_provider.dart';
import 'package:sunu_task/screens/auth/login_screen.dart';
import 'package:sunu_task/screens/home/home_screen.dart';
import 'package:sunu_task/screens/onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  final AppProvider appProvider;
  final AuthProvider authProvider;
  final ProjectProvider projectProvider;
  final TaskProvider taskProvider;

  const SplashScreen({
    super.key,
    required this.appProvider,
    required this.authProvider,
    required this.projectProvider,
    required this.taskProvider,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;
  bool _showLogo = false;
  bool _showText = false;

  @override
  void initState() {
    super.initState();
    _startAnimations();
    _initAndNavigate();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ── Animations d'apparition ──────────────────────────────────────────────

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _showLogo = true);
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _showText = true);
    });
  }

  // ── Initialisation et navigation ─────────────────────────────────────────

  Future<void> _initAndNavigate() async {
    // Attendre au minimum 2.5 secondes pour afficher le splash
    await Future.wait([
      Future.delayed(const Duration(milliseconds: 2500)),
      _initProviders(), // En parallèle : initialiser les providers
    ]);

    if (!mounted) return;
    _navigateToNextScreen();
  }

  Future<void> _initProviders() async {
    // 1. AppProvider lit isOnboardingComplete depuis SharedPreferences
    await widget.appProvider.init();
    // 2. AuthProvider recharge la session utilisateur si elle existe
    await widget.authProvider.init();
  }

  void _navigateToNextScreen() {
    if (!mounted) return;

    Widget nextScreen;

    // ── Logique de redirection ───────────────────────────────────────────
    //
    // Cas 1 : Onboarding pas encore vu → OnboardingScreen
    // Cas 2 : Onboarding vu + utilisateur connecté → HomeScreen
    // Cas 3 : Onboarding vu + pas connecté → LoginScreen

    if (!widget.appProvider.isOnboardingComplete) {
      // L'utilisateur n'a jamais ouvert l'app → OnboardingScreen
      nextScreen = OnboardingScreen(
        appProvider: widget.appProvider,
        authProvider: widget.authProvider,
        projectProvider: widget.projectProvider,
        taskProvider: widget.taskProvider,
      );
    } else if (widget.authProvider.isAuthenticated) {
      // Session restaurée → HomeScreen directement
      // Charger les projets de l'utilisateur en arrière-plan
      widget.projectProvider.loadProjects(
        widget.authProvider.currentUser!.id,
      );
      nextScreen = HomeScreen(
        authProvider: widget.authProvider,
        projectProvider: widget.projectProvider,
        taskProvider: widget.taskProvider,
      );
    } else {
      // Onboarding vu mais pas connecté → LoginScreen
      nextScreen = LoginScreen(
        authProvider: widget.authProvider,
        projectProvider: widget.projectProvider,
        taskProvider: widget.taskProvider,
      );
    }

    // Navigation avec animation de fondu
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => nextScreen,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  // ── Interface ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLogo(),
            const SizedBox(height: 24),
            _buildAppName(),
            const SizedBox(height: 8),
            _buildAppSlogan(),
            const SizedBox(height: 48),
            _buildLoadingIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return AnimatedOpacity(
      opacity: _showLogo ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeIn,
      child: AnimatedScale(
        scale: _showLogo ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
        child: Container(
          width: 124,
          height: 124,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha(180),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            Icons.task_alt,
            size: 65,
            color: AppColors.white.withAlpha(200),
          ),
        ),
      ),
    );
  }

  Widget _buildAppName() {
    return AnimatedOpacity(
      opacity: _showText ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Text(
        AppStrings.appName,
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildAppSlogan() {
    return AnimatedOpacity(
      opacity: _showText ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Text(
        AppStrings.appSlogan,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return AnimatedOpacity(
      opacity: _showText ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );
  }
}