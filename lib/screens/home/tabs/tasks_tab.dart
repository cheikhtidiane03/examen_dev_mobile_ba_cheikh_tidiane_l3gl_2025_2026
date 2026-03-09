// lib/screens/home/tabs/tasks_tab.dart

import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/core/constants/app_strings.dart';
import 'package:sunu_task/models/task.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/providers/task_provider.dart';
import 'package:sunu_task/widgets/cards/task_card.dart';

class TasksTab extends StatelessWidget {
  final TaskProvider taskProvider;
  final ProjectProvider projectProvider;

  const TasksTab({
    super.key,
    required this.taskProvider,
    required this.projectProvider,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: taskProvider,
      builder: (context, _) {
        final tasks = taskProvider.tasks; // Filtre + tri automatiques

        return Column(
          children: [
            // Barre de filtres horizontale
            _buildFilterBar(),

            // Liste ou etat vide
            Expanded(
              child: tasks.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return TaskCard(
                    task: tasks[index],
                    onTap: () {
                      // TODO Partie 5 : TaskDetailScreen
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Barre de filtres ──────────────────────────────────────────────────────

  Widget _buildFilterBar() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const Text(
              'Filtrer :',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 10),

            // Tout (efface les filtres)
            _FilterChip(
              label: 'Tout',
              isActive: !taskProvider.hasActiveFilters,
              color: AppColors.textSecondary,
              onTap: taskProvider.clearFilters,
            ),
            const SizedBox(width: 6),

            // Filtres par statut
            _FilterChip(
              label: AppStrings.statusTodo,
              isActive: taskProvider.statusFilter == TaskStatus.todo,
              color: AppColors.statusTodo,
              onTap: () => taskProvider.setStatusFilter(
                taskProvider.statusFilter == TaskStatus.todo
                    ? null
                    : TaskStatus.todo,
              ),
            ),
            const SizedBox(width: 6),
            _FilterChip(
              label: AppStrings.statusInProgress,
              isActive:
              taskProvider.statusFilter == TaskStatus.inProgress,
              color: AppColors.statusInProgress,
              onTap: () => taskProvider.setStatusFilter(
                taskProvider.statusFilter == TaskStatus.inProgress
                    ? null
                    : TaskStatus.inProgress,
              ),
            ),
            const SizedBox(width: 6),
            _FilterChip(
              label: AppStrings.statusDone,
              isActive: taskProvider.statusFilter == TaskStatus.done,
              color: AppColors.statusDone,
              onTap: () => taskProvider.setStatusFilter(
                taskProvider.statusFilter == TaskStatus.done
                    ? null
                    : TaskStatus.done,
              ),
            ),

            // Séparateur vertical
            const SizedBox(width: 10),
            Container(width: 1, height: 22, color: AppColors.border),
            const SizedBox(width: 10),

            // Filtres par priorité
            _FilterChip(
              label: AppStrings.priorityHigh,
              isActive:
              taskProvider.priorityFilter == TaskPriority.high,
              color: AppColors.priorityHigh,
              onTap: () => taskProvider.setPriorityFilter(
                taskProvider.priorityFilter == TaskPriority.high
                    ? null
                    : TaskPriority.high,
              ),
            ),
            const SizedBox(width: 6),
            _FilterChip(
              label: AppStrings.priorityMedium,
              isActive:
              taskProvider.priorityFilter == TaskPriority.medium,
              color: AppColors.priorityMedium,
              onTap: () => taskProvider.setPriorityFilter(
                taskProvider.priorityFilter == TaskPriority.medium
                    ? null
                    : TaskPriority.medium,
              ),
            ),
            const SizedBox(width: 6),
            _FilterChip(
              label: AppStrings.priorityLow,
              isActive:
              taskProvider.priorityFilter == TaskPriority.low,
              color: AppColors.priorityLow,
              onTap: () => taskProvider.setPriorityFilter(
                taskProvider.priorityFilter == TaskPriority.low
                    ? null
                    : TaskPriority.low,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Etat vide ─────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    final bool hasFilters = taskProvider.hasActiveFilters;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.checklist_rounded,
                size: 50,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              hasFilters ? 'Aucun resultat' : AppStrings.noTasks,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters
                  ? 'Aucune tache ne correspond aux filtres actifs.'
                  : AppStrings.noTasksDesc,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            if (hasFilters) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: taskProvider.clearFilters,
                icon: const Icon(
                  Icons.filter_alt_off_outlined,
                  color: AppColors.primary,
                ),
                label: const Text(
                  'Effacer les filtres',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Chip de filtre animé ──────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? color.withValues(alpha: 0.15)
              : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? color : AppColors.border,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight:
            isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? color : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}