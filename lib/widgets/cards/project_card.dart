// lib/widgets/cards/project_card.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/project.dart';

/**
 * Carte affichant un projet dans une liste.
 *
 * Contient :
 * - Pastille de couleur du projet (fond teinté + cercle plein)
 * - Nom du projet et description
 * - Nombre de tâches
 * - Menu contextuel via PopupMenuButton (Modifier / Supprimer)
 * - Callback onTap pour la navigation
 *
 * Utilise AppColors pour toutes les couleurs
 * Utilise AppStrings pour tous les textes (edit, delete, tasks...)
 */
class ProjectCard extends StatelessWidget {
  final Project project;

  /// Nombre de tâches du projet (calculé dans le parent via TaskProvider)
  final int taskCount;

  /// Navigation vers ProjectDetailScreen
  final VoidCallback? onTap;

  /// Ouvre ProjectFormScreen en mode modification
  final VoidCallback? onEdit;

  /// Demande confirmation puis supprime
  final VoidCallback? onDelete;

  const ProjectCard({
    super.key,
    required this.project,
    this.taskCount = 0,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // ── Pastille de couleur ──────────────────────────────────────
              // project.projectColor utilise le getter Color(color) du modèle
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: project.projectColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: project.projectColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // ── Nom + description + compteur ─────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom du projet
                    Text(
                      project.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Description (seulement si non null et non vide)
                    if (project.description != null &&
                        project.description!.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        project.description!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    const SizedBox(height: 8),

                    // Compteur de tâches avec icône
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          // AppStrings.tasks = 'Taches'
                          // Pluriel manuel : 1 tâche / 5 tâches
                          '$taskCount ${taskCount > 1
                              ? AppStrings.tasks.toLowerCase()
                              : AppStrings.task.toLowerCase()}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Menu contextuel ──────────────────────────────────────────
              PopupMenuButton<String>(
                onSelected: (String value) {
                  if (value == 'edit') onEdit?.call();
                  if (value == 'delete') onDelete?.call();
                },
                icon: const Icon(
                  Icons.more_vert,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                itemBuilder: (BuildContext context) => [
                  // Option Modifier — AppStrings.edit = 'Modifier'
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          AppStrings.edit,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Option Supprimer — AppStrings.delete = 'Supprimer'
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          AppStrings.delete,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}