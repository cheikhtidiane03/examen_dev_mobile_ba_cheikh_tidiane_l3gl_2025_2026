import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../services/storage_service.dart';

/**
 * AuthProvider - Gère l'authentification et la session utilisateur
 */
class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;

  /// true si un utilisateur est connecté
  bool get isAuthenticated => _currentUser != null;

  bool get isLoading => _isLoading;
  String? get error => _error;

  /**
   * Charge l'utilisateur courant depuis le stockage
   * À appeler au démarrage (dans SplashScreen après AppProvider.init())
   */
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    _currentUser = StorageService.instance.getCurrentUser();

    _isLoading = false;
    notifyListeners();
  }

  /**
   * Connecte un utilisateur avec son email et son mot de passe
   * Retourne true si succès, false sinon
   *
   * Logique en 6 étapes :
   * 1. Mettre isLoading = true, effacer l'erreur
   * 2. Récupérer tous les utilisateurs
   * 3. Chercher l'utilisateur correspondant
   * 4. Si trouvé : sauvegarder la session, retourner true
   * 5. Si non trouvé : mettre un message d'erreur, retourner false
   * 6. Dans tous les cas : remettre isLoading = false
   */
  Future<bool> login(String email, String password) async {
    // Étape 1
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final List<User> users = StorageService.instance.getUsers();

      User? found;
      for (final User u in users) {
        if (u.email.toLowerCase() == email.trim().toLowerCase() &&
            u.password == password) {
          found = u;
          break;
        }
      }

      if (found != null) {
        await StorageService.instance.saveCurrentUser(found);
        _currentUser = found;
        return true;
      } else {
        _error = 'Email ou mot de passe incorrect.';
        return false;
      }
    } catch (e) {
      _error = 'Une erreur est survenue. Veuillez réessayer.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /**
   * Inscrit un nouvel utilisateur
   * Retourne true si succès, false sinon
   *
   * Logique :
   * 1. Vérifier qu'aucun compte n'existe avec cet email
   * 2. Créer l'utilisateur avec un UUID unique
   * 3. Sauvegarder dans la liste des utilisateurs
   * 4. Définir comme utilisateur courant (connexion automatique)
   */
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final List<User> users = StorageService.instance.getUsers();
      final bool emailExists = users.any(
            (u) => u.email.toLowerCase() == email.trim().toLowerCase(),
      );

      if (emailExists) {
        _error = 'Un compte existe déjà avec cet email.';
        return false;
      }

      final User newUser = User(
        id: const Uuid().v4(),
        name: name.trim(),
        email: email.trim().toLowerCase(),
        password: password,
        createdAt: DateTime.now(),
      );

      await StorageService.instance.addUser(newUser);

      await StorageService.instance.saveCurrentUser(newUser);
      _currentUser = newUser;
      return true;
    } catch (e) {
      _error = 'Une erreur est survenue. Veuillez réessayer.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /**
   * Déconnecte l'utilisateur courant
   */
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await StorageService.instance.removeCurrentUser();
    _currentUser = null;
    _error = null;

    _isLoading = false;
    notifyListeners();
  }

  /**
   * Met à jour le profil de l'utilisateur connecté
   */
  Future<void> updateProfile({String? name, String? email}) async {
    if (_currentUser == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (email != null &&
          email.trim().toLowerCase() != _currentUser!.email.toLowerCase()) {
        final List<User> users = StorageService.instance.getUsers();
        final bool emailTaken = users.any(
              (u) =>
          u.email.toLowerCase() == email.trim().toLowerCase() &&
              u.id != _currentUser!.id,
        );
        if (emailTaken) {
          _error = 'Cet email est déjà utilisé par un autre compte.';
          return;
        }
      }

      final User updated = _currentUser!.copyWith(
        name: name?.trim() ?? _currentUser!.name,
        email: email?.trim().toLowerCase() ?? _currentUser!.email,
      );

      await StorageService.instance.updateUser(updated);
      await StorageService.instance.saveCurrentUser(updated);
      _currentUser = updated;
    } catch (e) {
      _error = 'Impossible de mettre à jour le profil.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /**
   * Efface le message d'erreur courant
   */
  void clearError() {
    _error = null;
    notifyListeners();
  }
}