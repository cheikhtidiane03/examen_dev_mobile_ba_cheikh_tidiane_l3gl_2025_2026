import 'package:flutter/foundation.dart';
import '../models/Project.dart';
import '../services/storage_service.dart';

/**
 * ProjectProvider - Gère la collection de projets de l'utilisateur
 */
class ProjectProvider extends ChangeNotifier {

  List<Project> _projects = [];
  Project? _selectedProject;
  bool _isLoading = false;
  String? _error;

  List<Project> get projects => List.unmodifiable(_projects);
  Project? get selectedProject => _selectedProject;
  int get projectCount => _projects.length;
  bool get isLoading => _isLoading;
  String? get error => _error;


  /**
   * Charge tous les projets de l'utilisateur connecté
   * getProjectsByUser() est SYNCHRONE dans StorageService
   */
  Future<void> loadProjects(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _projects = StorageService.instance.getProjectsByUser(userId);
      _projects.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      _error = 'Impossible de charger les projets.';
      _projects = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /**
   * Crée un nouveau projet et l'ajoute à la liste locale
   */
  Future<void> createProject(Project project) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await StorageService.instance.addProject(project);
      _projects.insert(0, project);
    } catch (e) {
      _error = 'Impossible de créer le projet.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /**
   * Met à jour un projet existant
   */
  Future<void> updateProject(Project project) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await StorageService.instance.updateProject(project);

      final int index = _projects.indexWhere((p) => p.id == project.id);
      if (index != -1) {
        _projects[index] = project;
      }

      if (_selectedProject?.id == project.id) {
        _selectedProject = project;
      }
    } catch (e) {
      _error = 'Impossible de modifier le projet.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /**
   * Supprime un projet et ses tâches (cascade gérée dans StorageService)
   */
  Future<void> deleteProject(String projectId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await StorageService.instance.deleteProject(projectId);
      _projects.removeWhere((p) => p.id == projectId);

      if (_selectedProject?.id == projectId) {
        _selectedProject = null;
      }
    } catch (e) {
      _error = 'Impossible de supprimer le projet.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /**
   * Sélectionne (ou désélectionne) un projet
   * Utilisé pour la navigation vers ProjectDetailScreen
   */
  void selectProject(Project? project) {
    _selectedProject = project;
    notifyListeners();
  }

  /**
   * Efface le message d'erreur courant
   */
  void clearError() {
    _error = null;
    notifyListeners();
  }
}