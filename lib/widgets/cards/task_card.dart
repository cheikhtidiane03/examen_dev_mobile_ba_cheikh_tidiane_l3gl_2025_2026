// lib/widgets/cards/task_card.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/task.dart';

/**
 * Carte affichant une tâche dans une liste.
 *
 * Contient :
 * - Barre de priorité colorée (côté gauche)
 * - Titre (barré + grisé si done)
 * - Description (si présente)
 * - Badge de statut coloré (AppColors.statusTodo/InProgress/Done)
 * - Chip de priorité (icône + couleur AppColors.priorityLow/Medium/High)
 * - Date d'échéance (rouge si task.isOverdue, sinon gris)
 * - Callback onTap pour la navigation
 *
 * Utilise AppColors pour toutes les couleurs
 * Utilise AppStrings pour tous les libellés de statut et priorité
 */
class TaskCard extends StatelessWidget {
  final Task task;

  /// Navigation vers TaskDetailScreen
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: IntrinsicHeight(
          // IntrinsicHeight force la barre colorée à prendre
          // la hauteur totale de la carte
          child: Row(
            children: [
              // ── Barre de priorité (côté gauche) ─────────────────────────
              Container(
                width: 5,
                decoration: BoxDecoration(
                  color: _priorityColor(task.priority),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                ),
              ),

              // ── Contenu principal ────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ligne 1 : Titre + Badge statut
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                // Grisé si tâche terminée
                                color: task.status == TaskStatus.done
                                    ? AppColors.textDisable
                                    : AppColors.textPrimary,
                                // Barré si tâche terminée
                                decoration: task.status == TaskStatus.done
                                    ? TextDecoration.lineThrough
                                    : null,
                                decorationColor: AppColors.textDisable,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _StatusBadge(status: task.status),
                        ],
                      ),

                      // Ligne 2 : Description (si présente)
                      if (task.description != null &&
                          task.description!.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Text(
                          task.description!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      const SizedBox(height: 10),

                      // Ligne 3 : Priorité + Date d'échéance
                      Row(
                        children: [
                          _PriorityChip(priority: task.priority),
                          const Spacer(),
                          // Afficher la date seulement si dueDate est définie
                          if (task.dueDate != null)
                            _DueDateChip(task: task),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Couleur de la barre latérale selon la priorité (AppColors)
  Color _priorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:   return AppColors.priorityHigh;
      case TaskPriority.medium: return AppColors.priorityMedium;
      case TaskPriority.low:    return AppColors.priorityLow;
    }
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Widget interne : Badge de statut
//  Utilise AppColors.statusTodo/InProgress/Done
//  Utilise AppStrings.statusTodo/InProgress/Done
// ════════════════════════════════════════════════════════════════════════════

class _StatusBadge extends StatelessWidget {
  final TaskStatus status;

  const _StatusBadge({required this.status});

  /// Libellé depuis AppStrings
  String get _label {
    switch (status) {
      case TaskStatus.todo:       return AppStrings.statusTodo;       // 'A faire'
      case TaskStatus.inProgress: return AppStrings.statusInProgress; // 'En cours'
      case TaskStatus.done:       return AppStrings.statusDone;       // 'Termine'
    }
  }

  /// Couleur depuis AppColors
  Color get _color {
    switch (status) {
      case TaskStatus.todo:       return AppColors.statusTodo;
      case TaskStatus.inProgress: return AppColors.statusInProgress;
      case TaskStatus.done:       return AppColors.statusDone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _color.withOpacity(0.35),
          width: 1,
        ),
      ),
      child: Text(
        _label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _color,
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Widget interne : Chip de priorité
//  Utilise AppColors.priorityHigh/Medium/Low
//  Utilise AppStrings.priorityHigh/Medium/Low
// ════════════════════════════════════════════════════════════════════════════

class _PriorityChip extends StatelessWidget {
  final TaskPriority priority;

  const _PriorityChip({required this.priority});

  /// Libellé depuis AppStrings
  String get _label {
    switch (priority) {
      case TaskPriority.high:   return AppStrings.priorityHigh;   // 'Haute'
      case TaskPriority.medium: return AppStrings.priorityMedium; // 'Moyenne'
      case TaskPriority.low:    return AppStrings.priorityLow;    // 'Basse'
    }
  }

  /// Icône selon la priorité
  IconData get _icon {
    switch (priority) {
      case TaskPriority.high:   return Icons.keyboard_double_arrow_up;
      case TaskPriority.medium: return Icons.remove;
      case TaskPriority.low:    return Icons.keyboard_double_arrow_down;
    }
  }

  /// Couleur depuis AppColors
  Color get _color {
    switch (priority) {
      case TaskPriority.high:   return AppColors.priorityHigh;
      case TaskPriority.medium: return AppColors.priorityMedium;
      case TaskPriority.low:    return AppColors.priorityLow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(_icon, size: 13, color: _color),
        const SizedBox(width: 4),
        Text(
          _label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: _color,
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Widget interne : Date d'échéance
//  Utilise task.isOverdue (getter du modèle Task)
//  Utilise AppColors.error si dépassée, AppColors.textSecondary sinon
// ════════════════════════════════════════════════════════════════════════════

class _DueDateChip extends StatelessWidget {
  final Task task;

  const _DueDateChip({required this.task});

  @override
  Widget build(BuildContext context) {
    // task.isOverdue : getter du modèle Task
    // Retourne true si dueDate est dépassée ET status != done
    final bool overdue = task.isOverdue;

    final Color color =
    overdue ? AppColors.error : AppColors.textSecondary;

    // Formatage JJ/MM/AAAA
    final DateTime date = task.dueDate!;
    final String formatted =
        '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          overdue
              ? Icons.warning_amber_rounded
              : Icons.calendar_today_outlined,
          size: 13,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          formatted,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}