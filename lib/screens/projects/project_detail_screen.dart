// lib/screens/projects/project_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/core/constants/app_strings.dart';
import 'package:sunu_task/models/project.dart';
import 'package:sunu_task/models/task.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/providers/task_provider.dart';
import 'package:sunu_task/screens/projects/project_form_screen.dart';
import 'package:sunu_task/screens/tasks/task_form_screen.dart';
import 'package:sunu_task/screens/tasks/task_detail_screen.dart';
import 'package:sunu_task/widgets/cards/task_card.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Project project;
  final AuthProvider authProvider;
  final ProjectProvider projectProvider;
  final TaskProvider taskProvider;

  const ProjectDetailScreen({
    super.key,
    required this.project,
    required this.authProvider,
    required this.projectProvider,
    required this.taskProvider,
  });

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  late Project _project;

  @override
  void initState() {
    super.initState();
    _project = widget.project;
    widget.taskProvider.loadTasks(_project.id);
  }

  Future<void> _goToEdit() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ProjectFormScreen(
          project: _project,
          authProvider: widget.authProvider,
          projectProvider: widget.projectProvider,
        ),
      ),
    );
    if (result == true && mounted) {
      final updated = widget.projectProvider.projects
          .where((p) => p.id == _project.id)
          .firstOrNull;
      if (updated != null) setState(() => _project = updated);
    }
  }

  Future<void> _confirmDelete() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text(AppStrings.deleteProject,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
        content: Text(
          'Supprimer "${_project.name}" ?\n'
              'Cette action supprimera aussi toutes ses taches.',
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
                    color: AppColors.error,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    await widget.projectProvider.deleteProject(_project.id);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> _goToAddTask() async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TaskFormScreen(
          projectId: _project.id,
          authProvider: widget.authProvider,
          taskProvider: widget.taskProvider,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListenableBuilder(
        listenable: widget.taskProvider,
        builder: (context, _) {
          final tasks = widget.taskProvider.tasks;
          final allTasks = widget.taskProvider.allTasks
              .where((t) => t.projectId == _project.id)
              .toList();

          final int todoCount = allTasks
              .where((t) => t.status == TaskStatus.todo)
              .length;
          final int inProgressCount = allTasks
              .where((t) => t.status == TaskStatus.inProgress)
              .length;
          final int doneCount = allTasks
              .where((t) => t.status == TaskStatus.done)
              .length;

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsSection(
                        todoCount, inProgressCount, doneCount),
                    _buildCreationDate(),
                    const Divider(
                        color: AppColors.border,
                        height: 1,
                        indent: 20,
                        endIndent: 20),
                    Padding(
                      padding:
                      const EdgeInsets.fromLTRB(20, 20, 20, 8),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${AppStrings.tasks} (${allTasks.length})',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (widget.taskProvider.isLoading)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                      AppColors.primary)),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              tasks.isEmpty
                  ? SliverFillRemaining(
                  child: _buildEmptyTasks())
                  : SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) => TaskCard(
                    task: tasks[index],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TaskDetailScreen(
                          task: tasks[index],
                          authProvider: widget.authProvider,
                          taskProvider: widget.taskProvider,
                          projectProvider: widget.projectProvider,
                        ),
                      ),
                    ),
                  ),
                  childCount: tasks.length,
                ),
              ),
              const SliverToBoxAdapter(
                  child: SizedBox(height: 100)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToAddTask,
        backgroundColor: _project.projectColor,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.add_rounded, size: 22),
        label: const Text(AppStrings.newTask,
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: _project.projectColor,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_rounded,
            color: Colors.white),
      ),
      actions: [
        IconButton(
          onPressed: _goToEdit,
          icon: const Icon(Icons.edit_outlined, color: Colors.white),
          tooltip: AppStrings.edit,
        ),
        IconButton(
          onPressed: _confirmDelete,
          icon: const Icon(Icons.delete_outline_rounded,
              color: Colors.white),
          tooltip: AppStrings.delete,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _project.projectColor,
                _project.projectColor.withValues(alpha: 0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _project.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (_project.description != null &&
                      _project.description!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      _project.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color:
                        Colors.white.withValues(alpha: 0.85),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(int todo, int inProgress, int done) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Wrap(
        spacing: 10,
        runSpacing: 8,
        children: [
          _StatChip(
              label: AppStrings.statusTodo,
              count: todo,
              color: AppColors.statusTodo),
          _StatChip(
              label: AppStrings.statusInProgress,
              count: inProgress,
              color: AppColors.statusInProgress),
          _StatChip(
              label: AppStrings.statusDone,
              count: done,
              color: AppColors.statusDone),
        ],
      ),
    );
  }

  Widget _buildCreationDate() {
    final date = _project.createdAt;
    final formatted =
        '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_outlined,
              size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text('Cree le $formatted',
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildEmptyTasks() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _project.projectColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.checklist_rounded,
                  size: 40, color: _project.projectColor),
            ),
            const SizedBox(height: 20),
            const Text(AppStrings.noTasks,
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            const Text(AppStrings.noTasksDesc,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5)),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _StatChip(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                  color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text('$count $label',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ],
      ),
    );
  }
}