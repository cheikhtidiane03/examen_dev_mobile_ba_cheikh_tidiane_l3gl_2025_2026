// lib/screens/home/tabs/projects_tab.dart

import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/core/constants/app_strings.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/providers/task_provider.dart';
import 'package:sunu_task/screens/projects/project_detail_screen.dart';
import 'package:sunu_task/screens/projects/project_form_screen.dart';
import 'package:sunu_task/widgets/cards/project_card.dart';

class ProjectsTab extends StatelessWidget {
  final AuthProvider authProvider;
  final ProjectProvider projectProvider;
  final TaskProvider taskProvider;

  const ProjectsTab({
    super.key,
    required this.authProvider,
    required this.projectProvider,
    required this.taskProvider,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([projectProvider, taskProvider]),
      builder: (context, _) {
        // Loader via Visibility
        return Visibility(
          visible: projectProvider.isLoading,
          replacement: _buildContent(context),
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    final projects = projectProvider.projects;

    // Etat vide via Visibility
    return Visibility(
      visible: projects.isEmpty,
      replacement: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: projects.length,
        itemBuilder: (context, index) {
          final project = projects[index];
          final taskCount = taskProvider.allTasks
              .where((t) => t.projectId == project.id)
              .length;
          return ProjectCard(
            project: project,
            taskCount: taskCount,
            onTap: () => _goToDetail(context, project),
            onEdit: () => _goToEdit(context, project),
            onDelete: () =>
                _confirmDelete(context, project.id, project.name),
          );
        },
      ),
      child: _buildEmptyState(context),
    );
  }

  void _goToDetail(BuildContext context, project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProjectDetailScreen(
          project: project,
          authProvider: authProvider,
          projectProvider: projectProvider,
          taskProvider: taskProvider,
        ),
      ),
    );
  }

  void _goToEdit(BuildContext context, project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProjectFormScreen(
          project: project,
          authProvider: authProvider,
          projectProvider: projectProvider,
        ),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context,
      String projectId,
      String projectName,
      ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text(AppStrings.deleteProject,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
        content: Text(
          'Supprimer "$projectName" ?\nCette action supprimera aussi toutes ses taches.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.cancel,
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              projectProvider.deleteProject(projectId);
            },
            child: const Text(AppStrings.delete,
                style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
              child: const Icon(Icons.folder_open_rounded,
                  size: 50, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            const Text(AppStrings.noProjects,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            const Text(AppStrings.noProjectsDesc,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProjectFormScreen(
                    authProvider: authProvider,
                    projectProvider: projectProvider,
                  ),
                ),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text(AppStrings.newProject),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}