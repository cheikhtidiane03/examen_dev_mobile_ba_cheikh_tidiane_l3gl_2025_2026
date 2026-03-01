// lib/providers/task_provider.dart

import 'package:flutter/foundation.dart';
import '../models/Task.dart';
import '../services/storage_service.dart';

/**
 * TaskProvider - Gère les tâches d'un projet avec filtrage et tri
 */
class TaskProvider extends ChangeNotifier {
  // ── Propriétés privées ──────────────────────────────────────────────────────
  List<Task> _tasks = [];
  TaskStatus? _statusFilter;
  TaskPriority? _priorityFilter;
  bool _isLoading = false;
  String? _error;

  // ── Getters publics ─────────────────────────────────────────────────────────

  /**
   * Retourne les tâches filtrées et triées selon les critères actifs
   * Tri : inProgress → todo → done, puis high → medium → low
   */
  List<Task> get tasks {
    List<Task> result = List<Task>.from(_tasks);

    // Appliquer le filtre par statut
    if (_statusFilter != null) {
      result = result.where((t) => t.status == _statusFilter).toList();
    }

    // Appliquer le filtre par priorité
    if (_priorityFilter != null) {
      result = result.where((t) => t.priority == _priorityFilter).toList();
    }

    // Tri par statut puis par priorité
    result.sort((a, b) {
      final int s = _statusOrder(a.status).compareTo(_statusOrder(b.status));
      if (s != 0) return s;
      return _priorityOrder(a.priority).compareTo(_priorityOrder(b.priority));
    });

    return result;
  }

  /// Toutes les tâches sans filtre (pour les statistiques)
  List<Task> get allTasks => List.unmodifiable(_tasks);

  /**
   * Compteur de tâches par statut (sans filtre, pour le Dashboard)
   * Retourne : { TaskStatus.todo: 3, TaskStatus.inProgress: 2, TaskStatus.done: 5 }
   */
  Map<TaskStatus, int> get taskCountByStatus {
    final Map<TaskStatus, int> counts = {
      TaskStatus.todo: 0,
      TaskStatus.inProgress: 0,
      TaskStatus.done: 0,
    };
    for (final Task t in _tasks) {
      counts[t.status] = (counts[t.status] ?? 0) + 1;
    }
    return counts;
  }

  TaskStatus? get statusFilter => _statusFilter;
  TaskPriority? get priorityFilter => _priorityFilter;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasActiveFilters => _statusFilter != null || _priorityFilter != null;

  // ── Méthodes CRUD ────────────────────────────────────────────────────────────

  /**
   * Charge les tâches d'un projet
   * getTasksByProject() est SYNCHRONE dans StorageService
   */
  Future<void> loadTasks(String projectId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tasks = StorageService.instance.getTasksByProject(projectId);
    } catch (e) {
      _error = 'Impossible de charger les tâches.';
      _tasks = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /**
   * Crée une nouvelle tâche
   */
  Future<void> createTask(Task task) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await StorageService.instance.addTask(task);
      _tasks.add(task);
    } catch (e) {
      _error = 'Impossible de créer la tâche.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /**
   * Met à jour une tâche existante
   */
  Future<void> updateTask(Task task) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await StorageService.instance.updateTask(task);
      final int index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
      }
    } catch (e) {
      _error = 'Impossible de modifier la tâche.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /**
   * Supprime une tâche
   */
  Future<void> deleteTask(String taskId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await StorageService.instance.deleteTask(taskId);
      _tasks.removeWhere((t) => t.id == taskId);
    } catch (e) {
      _error = 'Impossible de supprimer la tâche.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /**
   * Met à jour uniquement le statut d'une tâche
   * Utilisé pour le changement rapide depuis TaskDetailScreen
   */
  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    _error = null;

    try {
      final int index = _tasks.indexWhere((t) => t.id == taskId);
      if (index == -1) return;

      final Task updated = _tasks[index].copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
      await StorageService.instance.updateTask(updated);
      _tasks[index] = updated;
    } catch (e) {
      _error = 'Impossible de changer le statut.';
    } finally {
      notifyListeners();
    }
  }

  /**
   * Vide la liste des tâches (utilisé lors du changement de projet)
   */
  void clearTasks() {
    _tasks = [];
    _statusFilter = null;
    _priorityFilter = null;
    notifyListeners();
  }

  // ── Filtres ──────────────────────────────────────────────────────────────────

  /**
   * Filtre les tâches par statut (null = désactiver le filtre)
   */
  void setStatusFilter(TaskStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  /**
   * Filtre les tâches par priorité (null = désactiver le filtre)
   */
  void setPriorityFilter(TaskPriority? priority) {
    _priorityFilter = priority;
    notifyListeners();
  }

  /**
   * Réinitialise tous les filtres actifs
   */
  void clearFilters() {
    _statusFilter = null;
    _priorityFilter = null;
    notifyListeners();
  }

  /**
   * Efface le message d'erreur courant
   */
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ── Helpers de tri (valeur basse = affiché en premier) ───────────────────────

  int _statusOrder(TaskStatus status) {
    switch (status) {
      case TaskStatus.inProgress: return 0;
      case TaskStatus.todo:       return 1;
      case TaskStatus.done:       return 2;
    }
  }

  int _priorityOrder(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:   return 0;
      case TaskPriority.medium: return 1;
      case TaskPriority.low:    return 2;
    }
  }
}