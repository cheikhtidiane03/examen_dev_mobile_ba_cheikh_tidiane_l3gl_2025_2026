// lib/screens/tasks/task_form_screen.dart

import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/core/constants/app_strings.dart';
import 'package:sunu_task/models/task.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/task_provider.dart';
import 'package:sunu_task/widgets/common/custom_button.dart';
import 'package:sunu_task/widgets/common/custom_text_field.dart';

/// Ecran de creation ET modification d'une tache.
///
/// Mode creation  : task == null   → bouton "Ajouter"
/// Mode modification : task != null → bouton "Enregistrer" + bouton supprimer
class TaskFormScreen extends StatefulWidget {
  final Task? task;
  final String projectId;
  final AuthProvider authProvider;
  final TaskProvider taskProvider;

  const TaskFormScreen({
    super.key,
    this.task,
    required this.projectId,
    required this.authProvider,
    required this.taskProvider,
  });

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descController;

  late TaskStatus _selectedStatus;
  late TaskPriority _selectedPriority;
  DateTime? _selectedDueDate;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.task?.title ?? '');
    _descController =
        TextEditingController(text: widget.task?.description ?? '');
    _selectedStatus = widget.task?.status ?? TaskStatus.todo;
    _selectedPriority = widget.task?.priority ?? TaskPriority.medium;
    _selectedDueDate = widget.task?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // ── Soumission ────────────────────────────────────────────────────────────

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isEditing) {
      final Task updated = widget.task!.copyWith(
        title: _titleController.text.trim(),
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        status: _selectedStatus,
        priority: _selectedPriority,
        dueDate: _selectedDueDate,
        updatedAt: DateTime.now(),
      );
      await widget.taskProvider.updateTask(updated);
    } else {
      final Task newTask = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        status: _selectedStatus,
        priority: _selectedPriority,
        projectId: widget.projectId,
        dueDate: _selectedDueDate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await widget.taskProvider.createTask(newTask);
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  // ── Suppression ───────────────────────────────────────────────────────────

  Future<void> _confirmDelete() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text(AppStrings.deleteTask,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
        content: const Text(
          'Supprimer cette tache ? Cette action est irreversible.',
          style: TextStyle(color: AppColors.textSecondary),
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
                    color: AppColors.error,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;
    await widget.taskProvider.deleteTask(widget.task!.id);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  // ── Date picker ───────────────────────────────────────────────────────────

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate:
      DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: AppColors.white,
            surface: AppColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDueDate = picked);
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
        title: Text(
          _isEditing ? AppStrings.editTask : AppStrings.newTask,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        // Bouton supprimer visible uniquement en mode modification
        actions: [
          if (_isEditing)
            IconButton(
              onPressed: _confirmDelete,
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.error),
              tooltip: AppStrings.delete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Titre ──────────────────────────────────────────────────
              _buildSectionTitle(AppStrings.taskTitle),
              const SizedBox(height: 10),
              CustomTextField(
                controller: _titleController,
                hint: 'Ex: Concevoir la maquette',
                prefixIcon: Icons.title_rounded,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppStrings.requiredField;
                  }
                  return null;
                }, label: '',
              ),
              const SizedBox(height: 20),

              // ── Description ────────────────────────────────────────────
              _buildSectionTitle(AppStrings.taskDescription),
              const SizedBox(height: 10),
              CustomTextField(
                controller: _descController,
                hint: 'Details de la tache...',
                prefixIcon: Icons.notes_rounded,
                maxLines: 3, label: '',
              ),
              const SizedBox(height: 24),

              // ── Selecteur de statut ────────────────────────────────────
              _buildSectionTitle(AppStrings.taskStatus),
              const SizedBox(height: 12),
              _buildStatusSelector(),
              const SizedBox(height: 24),

              // ── Selecteur de priorite ──────────────────────────────────
              _buildSectionTitle(AppStrings.taskPriority),
              const SizedBox(height: 12),
              _buildPrioritySelector(),
              const SizedBox(height: 24),

              // ── Date d'echeance ────────────────────────────────────────
              _buildSectionTitle(AppStrings.taskDueDate),
              const SizedBox(height: 12),
              _buildDatePicker(),
              const SizedBox(height: 36),

              // ── Bouton soumission ──────────────────────────────────────
              ListenableBuilder(
                listenable: widget.taskProvider,
                builder: (context, _) {
                  return CustomButton(
                    text: _isEditing
                        ? AppStrings.save
                        : AppStrings.add,
                    onPressed: _handleSubmit,
                    isLoading: widget.taskProvider.isLoading,
                    icon: _isEditing
                        ? Icons.check_rounded
                        : Icons.add_rounded,
                    width: double.infinity,
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── Selecteur de statut (3 conteneurs animes) ─────────────────────────────

  Widget _buildStatusSelector() {
    return Row(
      children: TaskStatus.values.map((status) {
        final bool isSelected = _selectedStatus == status;
        final Color color = _statusColor(status);
        final String label = _statusLabel(status);
        final IconData icon = _statusIcon(status);
        final bool isLast = status == TaskStatus.values.last;

        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedStatus = status),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: isLast ? 0 : 8),
              padding: const EdgeInsets.symmetric(
                  vertical: 14, horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.15)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? color : AppColors.border,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(icon,
                      color: isSelected
                          ? color
                          : AppColors.textSecondary,
                      size: 22),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.normal,
                      color: isSelected
                          ? color
                          : AppColors.textSecondary,
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Selecteur de priorite (3 conteneurs animes) ───────────────────────────

  Widget _buildPrioritySelector() {
    return Row(
      children: TaskPriority.values.map((priority) {
        final bool isSelected = _selectedPriority == priority;
        final Color color = _priorityColor(priority);
        final String label = _priorityLabel(priority);
        final IconData icon = _priorityIcon(priority);
        final bool isLast = priority == TaskPriority.values.last;

        return Expanded(
          child: GestureDetector(
            onTap: () =>
                setState(() => _selectedPriority = priority),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: isLast ? 0 : 8),
              padding: const EdgeInsets.symmetric(
                  vertical: 14, horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.15)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? color : AppColors.border,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(icon,
                      color: isSelected
                          ? color
                          : AppColors.textSecondary,
                      size: 22),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.normal,
                      color: isSelected
                          ? color
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Date picker ───────────────────────────────────────────────────────────

  Widget _buildDatePicker() {
    final bool hasDate = _selectedDueDate != null;
    final String dateText = hasDate
        ? '${_selectedDueDate!.day.toString().padLeft(2, '0')}/'
        '${_selectedDueDate!.month.toString().padLeft(2, '0')}/'
        '${_selectedDueDate!.year}'
        : 'Choisir une date';

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasDate
                      ? AppColors.primary
                      : AppColors.border,
                  width: hasDate ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 20,
                    color: hasDate
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    dateText,
                    style: TextStyle(
                      fontSize: 15,
                      color: hasDate
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (hasDate) ...[
          const SizedBox(width: 10),
          IconButton(
            onPressed: () =>
                setState(() => _selectedDueDate = null),
            icon: const Icon(Icons.close_rounded,
                color: AppColors.textSecondary),
            tooltip: 'Effacer la date',
          ),
        ],
      ],
    );
  }

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
      case TaskStatus.todo:
        return Icons.radio_button_unchecked_rounded;
      case TaskStatus.inProgress:
        return Icons.timelapse_rounded;
      case TaskStatus.done:
        return Icons.check_circle_outline_rounded;
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
      case TaskPriority.high:
        return Icons.keyboard_double_arrow_up_rounded;
      case TaskPriority.medium:
        return Icons.remove_rounded;
      case TaskPriority.low:
        return Icons.keyboard_double_arrow_down_rounded;
    }
  }
}