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
 * - Description (si présente) via Visibility
 * - Badge de statut coloré
 * - Chip de priorité
 * - Date d'échéance via Visibility (rouge si isOverdue)
 */
class TaskCard extends StatelessWidget {
  final Task task;
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
          child: Row(
            children: [
              // ── Barre de priorité ─────────────────────────────────────────
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

              // ── Contenu ───────────────────────────────────────────────────
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
                                color: task.status == TaskStatus.done
                                    ? AppColors.textDisable
                                    : AppColors.textPrimary,
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

                      // Ligne 2 : Description via Visibility
                      Visibility(
                        visible: task.description != null &&
                            task.description!.isNotEmpty,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            task.description ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Ligne 3 : Priorité + Date d'échéance
                      Row(
                        children: [
                          _PriorityChip(priority: task.priority),
                          const Spacer(),
                          // Date d'échéance via Visibility
                          Visibility(
                            visible: task.dueDate != null,
                            child: _DueDateChip(task: task),
                          ),
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

  Color _priorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:   return AppColors.priorityHigh;
      case TaskPriority.medium: return AppColors.priorityMedium;
      case TaskPriority.low:    return AppColors.priorityLow;
    }
  }
}

// ── Badge de statut ───────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final TaskStatus status;
  const _StatusBadge({required this.status});

  String get _label {
    switch (status) {
      case TaskStatus.todo:       return AppStrings.statusTodo;
      case TaskStatus.inProgress: return AppStrings.statusInProgress;
      case TaskStatus.done:       return AppStrings.statusDone;
    }
  }

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
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.35)),
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

// ── Chip de priorité ─────────────────────────────────────────────────────────

class _PriorityChip extends StatelessWidget {
  final TaskPriority priority;
  const _PriorityChip({required this.priority});

  String get _label {
    switch (priority) {
      case TaskPriority.high:   return AppStrings.priorityHigh;
      case TaskPriority.medium: return AppStrings.priorityMedium;
      case TaskPriority.low:    return AppStrings.priorityLow;
    }
  }

  IconData get _icon {
    switch (priority) {
      case TaskPriority.high:   return Icons.keyboard_double_arrow_up;
      case TaskPriority.medium: return Icons.remove;
      case TaskPriority.low:    return Icons.keyboard_double_arrow_down;
    }
  }

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

// ── Date d'échéance ───────────────────────────────────────────────────────────

class _DueDateChip extends StatelessWidget {
  final Task task;
  const _DueDateChip({required this.task});

  @override
  Widget build(BuildContext context) {
    final bool overdue = task.isOverdue;
    final Color color =
    overdue ? AppColors.error : AppColors.textSecondary;
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