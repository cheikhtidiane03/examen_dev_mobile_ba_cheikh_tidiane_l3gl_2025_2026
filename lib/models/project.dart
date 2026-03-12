// lib/models/project.dart

import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';

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

  static List<Color> get predefinedColors => AppColors.projectColors;

  static Color get defaultColor => AppColors.projectDefaultColor;

  @override
  String toString() {
    return 'Project(id: $id, name: $name, userId: $userId)';
  }
}