// lib/screens/tasks/task_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/core/constants/app_strings.dart';
import 'package:sunu_task/models/task.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/providers/task_provider.dart';
import 'package:sunu_task/screens/tasks/task_form_screen.dart';

/// Ecran de detail complet d'une tache.
/// Permet de voir toutes les informations et de changer
/// rapidement le statut sans passer par le formulaire d'edition.
class TaskDetailScreen extends StatefulWidget {
  final Task task;
  final AuthProvider authProvider;
  final TaskProvider taskProvider;
  final ProjectProvider projectProvider;

  const TaskDetailScreen({
    super.key,
    required this.task,
    required this.authProvider,
    required this.taskProvider,
    required this.projectProvider,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  // Copie locale de la tache (mise a jour apres edition)
  late Task _task;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  // ── Navigation vers le formulaire d'edition ───────────────────────────────

  Future<void> _goToEdit() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TaskFormScreen(
          task: _task,
          projectId: _task.projectId,
          authProvider: widget.authProvider,
          taskProvider: widget.taskProvider,
        ),
      ),
    );

    if (result == true && mounted) {
      // Recuperer la tache mise a jour depuis le provider
      final updated = widget.taskProvider.allTasks
          .where((t) => t.id == _task.id)
          .firstOrNull;
      if (updated != null) {
        setState(() => _task = updated);
      } else {
        // La tache a ete supprimee depuis le formulaire
        Navigator.pop(context, true);
      }
    }
  }

  // ── Suppression de la tache ───────────────────────────────────────────────

  Future<void> _confirmDelete() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          AppStrings.deleteTask,
          style: TextStyle(
              fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        content: Text(
          'Supprimer "${_task.title}" ? Cette action est irreversible.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.cancel,
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(AppStrings.delete,
                style: TextStyle(
                    color: AppColors.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;
    await widget.taskProvider.deleteTask(_task.id);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  // ── Changement rapide de statut ───────────────────────────────────────────

  Future<void> _changeStatus(TaskStatus newStatus) async {
    await widget.taskProvider.updateTaskStatus(_task.id, newStatus);
    if (!mounted) return;
    // Mettre a jour la copie locale
    setState(() {
      _task = _task.copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: AppColors.border,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textPrimary),
        ),
        title: const Text(
          'Detail de la tache',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          // Bouton modifier
          IconButton(
            onPressed: _goToEdit,
            icon: const Icon(Icons.edit_outlined,
                color: AppColors.textPrimary),
            tooltip: AppStrings.edit,
          ),
          // Bouton supprimer
          IconButton(
            onPressed: _confirmDelete,
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.error),
            tooltip: AppStrings.delete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Titre ──────────────────────────────────────────────────
            _buildTitleSection(),
            const SizedBox(height: 24),

            // ── Changement rapide de statut ────────────────────────────
            _buildSectionTitle('Changer le statut'),
            const SizedBox(height: 12),
            _buildStatusSelector(),
            const SizedBox(height: 24),

            // ── Indicateur de priorite ─────────────────────────────────
            _buildInfoCard(),
            const SizedBox(height: 24),

            // ── Description ────────────────────────────────────────────
            if (_task.description != null &&
                _task.description!.isNotEmpty) ...[
              //_buildSectionTitle(AppStrings.description),
              const SizedBox(height: 12),
              _buildDescriptionCard(),
              const SizedBox(height: 24),
            ],

            // ── Date d'echeance ────────────────────────────────────────
            if (_task.dueDate != null) ...[
              //_buildSectionTitle(AppStrings.dueDate),
              const SizedBox(height: 12),
              _buildDueDateCard(),
              const SizedBox(height: 24),
            ],

            // ── Dates systeme ──────────────────────────────────────────
            _buildSectionTitle('Informations'),
            const SizedBox(height: 12),
            _buildSystemDates(),
          ],
        ),
      ),
    );
  }

  // ── Section titre ─────────────────────────────────────────────────────────

  Widget _buildTitleSection() {
    final Color priorityColor = _priorityColor(_task.priority);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        // Barre de priorite a gauche
        gradient: LinearGradient(
          colors: [
            priorityColor.withValues(alpha: 0.08),
            AppColors.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.topRight,
          stops: const [0.0, 0.3],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barre de priorite
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: priorityColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _task.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _task.status == TaskStatus.done
                        ? AppColors.textDisable
                        : AppColors.textPrimary,
                    decoration: _task.status == TaskStatus.done
                        ? TextDecoration.lineThrough
                        : null,
                    decorationColor: AppColors.textDisable,
                  ),
                ),
                const SizedBox(height: 10),
                // Badge statut actuel
                _StatusBadge(status: _task.status),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Selecteur de statut (changement rapide) ───────────────────────────────

  Widget _buildStatusSelector() {
    return Row(
      children: TaskStatus.values.map((status) {
        final bool isCurrent = _task.status == status;
        final Color color = _statusColor(status);
        final String label = _statusLabel(status);
        final IconData icon = _statusIcon(status);

        return Expanded(
          child: GestureDetector(
            onTap: isCurrent ? null : () => _changeStatus(status),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                right: status != TaskStatus.done ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(
                  vertical: 14, horizontal: 6),
              decoration: BoxDecoration(
                color: isCurrent
                    ? color.withValues(alpha: 0.15)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCurrent ? color : AppColors.border,
                  width: isCurrent ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(icon,
                      color: isCurrent
                          ? color
                          : AppColors.textSecondary,
                      size: 22),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isCurrent
                          ? FontWeight.w700
                          : FontWeight.normal,
                      color: isCurrent
                          ? color
                          : AppColors.textSecondary,
                    ),
                    maxLines: 2,
                  ),
                  if (isCurrent) ...[
                    const SizedBox(height: 4),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                          color: color, shape: BoxShape.circle),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Carte d'informations (priorite) ──────────────────────────────────────

  Widget _buildInfoCard() {
    final Color priorityColor = _priorityColor(_task.priority);
    final String priorityLabel = _priorityLabel(_task.priority);
    final IconData priorityIcon = _priorityIcon(_task.priority);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Icone priorite
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: priorityColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(priorityIcon, color: priorityColor, size: 24),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Priorite',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                priorityLabel,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: priorityColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Carte de description ──────────────────────────────────────────────────

  Widget _buildDescriptionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        _task.description!,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
          height: 1.6,
        ),
      ),
    );
  }

  // ── Carte date d'echeance ─────────────────────────────────────────────────

  Widget _buildDueDateCard() {
    final bool overdue = _task.isOverdue;
    final Color color =
    overdue ? AppColors.error : AppColors.textSecondary;
    final date = _task.dueDate!;
    final formatted =
        '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: overdue
            ? AppColors.error.withValues(alpha: 0.05)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: overdue
              ? AppColors.error.withValues(alpha: 0.3)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            overdue
                ? Icons.warning_amber_rounded
                : Icons.calendar_today_outlined,
            color: color,
            size: 22,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                overdue ? 'En retard' : 'Echeance',
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                formatted,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Dates systeme ─────────────────────────────────────────────────────────

  Widget _buildSystemDates() {
    final createdFormatted = _formatDate(_task.createdAt);
    final updatedFormatted = _formatDate(_task.updatedAt);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.add_circle_outline_rounded,
            label: 'Cree le',
            value: createdFormatted,
          ),
          const Divider(
              color: AppColors.border, height: 1, indent: 54),
          _buildInfoRow(
            icon: Icons.update_rounded,
            label: 'Modifie le',
            value: updatedFormatted,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  )),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  )),
            ],
          ),
        ],
      ),
    );
  }

  // ── Titre de section ──────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';

  Color _statusColor(TaskStatus s) {
    switch (s) {
      case TaskStatus.todo:       return AppColors.statusTodo;
      case TaskStatus.inProgress: return AppColors.statusInProgress;
      case TaskStatus.done:       return AppColors.statusDone;
    }
  }

  String _statusLabel(TaskStatus s) {
    switch (s) {
      case TaskStatus.todo:       return AppStrings.statusTodo;
      case TaskStatus.inProgress: return AppStrings.statusInProgress;
      case TaskStatus.done:       return AppStrings.statusDone;
    }
  }

  IconData _statusIcon(TaskStatus s) {
    switch (s) {
      case TaskStatus.todo:       return Icons.radio_button_unchecked_rounded;
      case TaskStatus.inProgress: return Icons.timelapse_rounded;
      case TaskStatus.done:       return Icons.check_circle_outline_rounded;
    }
  }

  Color _priorityColor(TaskPriority p) {
    switch (p) {
      case TaskPriority.high:   return AppColors.priorityHigh;
      case TaskPriority.medium: return AppColors.priorityMedium;
      case TaskPriority.low:    return AppColors.priorityLow;
    }
  }

  String _priorityLabel(TaskPriority p) {
    switch (p) {
      case TaskPriority.high:   return AppStrings.priorityHigh;
      case TaskPriority.medium: return AppStrings.priorityMedium;
      case TaskPriority.low:    return AppStrings.priorityLow;
    }
  }

  IconData _priorityIcon(TaskPriority p) {
    switch (p) {
      case TaskPriority.high:   return Icons.keyboard_double_arrow_up_rounded;
      case TaskPriority.medium: return Icons.remove_rounded;
      case TaskPriority.low:    return Icons.keyboard_double_arrow_down_rounded;
    }
  }
}

// ── Badge de statut ───────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final TaskStatus status;
  const _StatusBadge({required this.status});

  Color get _color {
    switch (status) {
      case TaskStatus.todo:       return AppColors.statusTodo;
      case TaskStatus.inProgress: return AppColors.statusInProgress;
      case TaskStatus.done:       return AppColors.statusDone;
    }
  }

  String get _label {
    switch (status) {
      case TaskStatus.todo:       return AppStrings.statusTodo;
      case TaskStatus.inProgress: return AppStrings.statusInProgress;
      case TaskStatus.done:       return AppStrings.statusDone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.35)),
      ),
      child: Text(
        _label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _color,
        ),
      ),
    );
  }
}