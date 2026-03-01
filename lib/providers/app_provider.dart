// lib/providers/app_provider.dart

import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';

/**
 * AppProvider - Gère l'état global de l'application
 * Responsable : onboarding et initialisation
 */
class AppProvider extends ChangeNotifier {
  // ── Propriétés privées ──────────────────────────────────────────────────────
  bool _isOnboardingComplete = false;
  bool _isInitialized = false;
  bool _isLoading = false;

  // ── Getters publics ─────────────────────────────────────────────────────────
  bool get isOnboardingComplete => _isOnboardingComplete;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;

  // ── Méthodes ────────────────────────────────────────────────────────────────

  /**
   * Initialise l'état depuis StorageService
   * À appeler une fois au démarrage (dans SplashScreen)
   */
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    // isOnboardingComplete est un getter SYNCHRONE dans StorageService
    _isOnboardingComplete = StorageService.instance.isOnboardingComplete;

    _isLoading = false;
    _isInitialized = true;
    notifyListeners();
  }

  /**
   * Marque l'onboarding comme terminé
   * Appelé quand l'utilisateur clique "Commencer" dans OnboardingScreen
   */
  Future<void> completeOnboarding() async {
    await StorageService.instance.setOnboardingComplete(true);
    _isOnboardingComplete = true;
    notifyListeners();
  }

  /**
   * Réinitialise l'onboarding (utile pour les tests)
   */
  Future<void> resetOnboarding() async {
    await StorageService.instance.setOnboardingComplete(false);
    _isOnboardingComplete = false;
    notifyListeners();
  }
}