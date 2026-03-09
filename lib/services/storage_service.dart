// lib/services/storage_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/project.dart';
import '../models/task.dart';

/**
 * Pattern Singleton:
 * Pour avoir une seule instance
 */
class StorageService {
  //===== Singleton ==========
  static StorageService? _instance;

  static StorageService get instance {
    _instance ??= StorageService._();
    return _instance!;
  }

  StorageService._();

  //===== SharedPreferences ==========
  late SharedPreferences _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  // ======== Cles de Stockage =========
  static const String _keyOnboardingComplete = 'onboarding_complete';
  static const String _keyCurrentUser        = 'current_user';
  static const String _keyUsers              = 'users';
  static const String _keyProjects           = 'projects';
  static const String _keyTasks              = 'tasks';

  // ================= ONBOARDING =================

  bool get isOnboardingComplete {
    return _prefs.getBool(_keyOnboardingComplete) ?? false;
  }

  Future<void> setOnboardingComplete(bool value) async {
    await _prefs.setBool(_keyOnboardingComplete, value);
  }

  // ================= USER SESSION =================

  /**
   * Sauvegarde l'utilisateur connecté (session active)
   */
  Future<void> saveCurrentUser(User user) async {
    await _prefs.setString(_keyCurrentUser, jsonEncode(user.toMap()));
  }

  /**
   * Récupère l'utilisateur connecté, ou null si aucune session
   */
  User? getCurrentUser() {
    final String? json = _prefs.getString(_keyCurrentUser);
    if (json == null) return null;
    return User.fromMap(jsonDecode(json) as Map<String, dynamic>);
  }

  /**
   * Supprime la session (déconnexion)
   */
  Future<void> removeCurrentUser() async {
    await _prefs.remove(_keyCurrentUser);
  }

  // ================= USERS (tous les comptes) =================

  /**
   * Récupère tous les utilisateurs enregistrés
   */
  List<User> getUsers() {
    final String? json = _prefs.getString(_keyUsers);
    if (json == null) return [];
    final List<dynamic> list = jsonDecode(json) as List<dynamic>;
    return list.map((e) => User.fromMap(e as Map<String, dynamic>)).toList();
  }

  /**
   * Ajoute un nouvel utilisateur à la liste
   */
  Future<void> addUser(User user) async {
    final List<User> users = getUsers();
    users.add(user);
    await _prefs.setString(
      _keyUsers,
      jsonEncode(users.map((u) => u.toMap()).toList()),
    );
  }

  /**
   * Met à jour un utilisateur existant
   */
  Future<void> updateUser(User user) async {
    final List<User> users = getUsers();
    final int index = users.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      users[index] = user;
      await _prefs.setString(
        _keyUsers,
        jsonEncode(users.map((u) => u.toMap()).toList()),
      );
    }
  }

  // ================= PROJECTS =================

  /**
   * Récupère les projets d'un utilisateur spécifique
   */
  List<Project> getProjectsByUser(String userId) {
    final List<Project> all = _getAllProjects();
    return all.where((p) => p.userId == userId).toList();
  }

  List<Project> _getAllProjects() {
    final String? json = _prefs.getString(_keyProjects);
    if (json == null) return [];
    final List<dynamic> list = jsonDecode(json) as List<dynamic>;
    return list.map((e) => Project.fromMap(e as Map<String, dynamic>)).toList();
  }

  /**
   * Ajoute un nouveau projet
   */
  Future<void> addProject(Project project) async {
    final List<Project> projects = _getAllProjects();
    projects.add(project);
    await _saveAllProjects(projects);
  }

  /**
   * Met à jour un projet existant
   */
  Future<void> updateProject(Project project) async {
    final List<Project> projects = _getAllProjects();
    final int index = projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      projects[index] = project;
      await _saveAllProjects(projects);
    }
  }

  /**
   * Supprime un projet + toutes ses tâches (cascade)
   */
  Future<void> deleteProject(String projectId) async {
    final List<Project> projects = _getAllProjects();
    projects.removeWhere((p) => p.id == projectId);
    await _saveAllProjects(projects);
    await deleteTasksByProject(projectId);
  }

  Future<void> _saveAllProjects(List<Project> projects) async {
    await _prefs.setString(
      _keyProjects,
      jsonEncode(projects.map((p) => p.toMap()).toList()),
    );
  }

  // ================= TASKS =================

  /**
   * Récupère les tâches d'un projet
   */
  List<Task> getTasksByProject(String projectId) {
    final List<Task> all = _getAllTasks();
    return all.where((t) => t.projectId == projectId).toList();
  }

  List<Task> _getAllTasks() {
    final String? json = _prefs.getString(_keyTasks);
    if (json == null) return [];
    final List<dynamic> list = jsonDecode(json) as List<dynamic>;
    return list.map((e) => Task.fromMap(e as Map<String, dynamic>)).toList();
  }

  /**
   * Ajoute une nouvelle tâche
   */
  Future<void> addTask(Task task) async {
    final List<Task> tasks = _getAllTasks();
    tasks.add(task);
    await _saveAllTasks(tasks);
  }

  /**
   * Met à jour une tâche existante
   */
  Future<void> updateTask(Task task) async {
    final List<Task> tasks = _getAllTasks();
    final int index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      tasks[index] = task;
      await _saveAllTasks(tasks);
    }
  }

  /**
   * Supprime une tâche
   */
  Future<void> deleteTask(String taskId) async {
    final List<Task> tasks = _getAllTasks();
    tasks.removeWhere((t) => t.id == taskId);
    await _saveAllTasks(tasks);
  }

  /**
   * Supprime toutes les tâches d'un projet (appelé par deleteProject)
   */
  Future<void> deleteTasksByProject(String projectId) async {
    final List<Task> tasks = _getAllTasks();
    tasks.removeWhere((t) => t.projectId == projectId);
    await _saveAllTasks(tasks);
  }

  Future<void> _saveAllTasks(List<Task> tasks) async {
    await _prefs.setString(
      _keyTasks,
      jsonEncode(tasks.map((t) => t.toMap()).toList()),
    );
  }

  // ================= ANCIENNES MÉTHODES (compatibilité) =================

  Future<void> saveUser(String userJson) async {
    await _prefs.setString(_keyCurrentUser, userJson);
  }

  String? getUser() {
    return _prefs.getString(_keyCurrentUser);
  }

  Future<void> removeUser() async {
    await _prefs.remove(_keyCurrentUser);
  }
}