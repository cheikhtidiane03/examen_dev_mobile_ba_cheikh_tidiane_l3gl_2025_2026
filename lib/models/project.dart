// lib/models/project.dart

import 'package:flutter/material.dart';

/**
 * Les modeles sont immutables(final) pour éviter les
 * modifications et faciliter la gestion d'etat
 */
class Project {

  final String id;

  final String userId;

  final String name;

  final String? description;

  final int color;

  final DateTime createdAt;

  final DateTime updatedAt;

  Project({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.color,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /**
   * Retourne la couleur Flutter depuis la valeur int stockée
   */
  Color get projectColor => Color(color);

  /**
   * Crée une copie du projet avec des champs modifiés
   */
  Project copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    int? color,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /**
   * Convertir le projet en Map pour la serialisation
   */
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /**
   * Créer un projet à l'aide du constructeur factory depuis un Map
   */
  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] as String,
      userId: map['userId'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      color: map['color'] as int,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  /**
   * Les 8 couleurs proposées dans le sélecteur du formulaire projet
   */
  static const List<Color> predefinedColors = [
    Color(0xFF6C63FF), // Violet  (couleur principale)
    Color(0xFF4CAF50), // Vert
    Color(0xFF2196F3), // Bleu
    Color(0xFFFF9800), // Orange
    Color(0xFFE91E63), // Rose
    Color(0xFF00BCD4), // Cyan
    Color(0xFFFF5722), // Rouge-orangé
    Color(0xFF9C27B0), // Mauve
  ];

  /// Couleur par défaut lors de la création d'un projet
  static Color get defaultColor => predefinedColors.first;

  @override
  String toString() {
    return 'Project(id: $id, name: $name, userId: $userId)';
  }
}