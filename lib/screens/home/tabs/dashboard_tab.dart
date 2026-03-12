// lib/screens/home/tabs/dashboard_tab.dart

import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/core/constants/app_strings.dart';
import 'package:sunu_task/models/task.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/providers/task_provider.dart';
import 'package:sunu_task/widgets/cards/project_card.dart';

class DashboardTab extends StatelessWidget {
  final AuthProvider authProvider;
  final ProjectProvider projectProvider;
  final TaskProvider taskProvider;
  final VoidCallback? onNavigateToProjects;
  final VoidCallback? onNavigateToTasks;

  const DashboardTab({
    super.key,
    required this.authProvider,
    required this.projectProvider,
    required this.taskProvider,
    this.onNavigateToProjects,
    this.onNavigateToTasks,
  });

  String _getGreeting() {
    final int hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Bonjour';
    if (hour >= 12 && hour < 18) return 'Bon apres-midi';
    return 'Bonsoir';
  }

  Future<void> _onRefresh() async {
    final userId = authProvider.currentUser?.id;
    if (userId == null) return;
    await projectProvider.loadProjects(userId);
    for (final project in projectProvider.projects) {
      await taskProvider.loadTasks(project.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        authProvider,
        projectProvider,
        taskProvider,
      ]),
      builder: (context, _) {
        final user = authProvider.currentUser;
        final firstName = (user?.name ?? '').split(' ').first;
        final stats = taskProvider.taskCountByStatus;
        final projects = projectProvider.projects;
        final recentProjects = projects.take(3).toList();
        final allTasks = taskProvider.allTasks;

        return RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeBanner(firstName),
                const SizedBox(height: 24),

                _buildSectionTitle('Apercu'),
                const SizedBox(height: 12),
                _buildOverviewRow(
                  projectCount: projects.length,
                  taskCount: allTasks.length,
                ),
                const SizedBox(height: 16),

                _buildSectionTitle('Taches par statut'),
                const SizedBox(height: 12),
                _buildStatusStatsRow(stats),
                const SizedBox(height: 28),

                // ── Titre + bouton "Voir tout" ─────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionTitle('Projets recents'),
                    // "Voir tout" via Visibility
                    Visibility(
                      visible: projects.isNotEmpty,
                      child: TextButton(
                        onPressed: onNavigateToProjects,
                        child: const Text(
                          'Voir tout',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // ── Loader via Visibility ──────────────────────────────
                Visibility(
                  visible: projectProvider.isLoading,
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(
                        valueColor:
                        AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ),
                  ),
                ),

                // ── Etat vide via Visibility ───────────────────────────
                Visibility(
                  visible: !projectProvider.isLoading && projects.isEmpty,
                  child: _buildEmptyProjects(),
                ),

                // ── Liste projets recents via Visibility ───────────────
                Visibility(
                  visible:
                  !projectProvider.isLoading && projects.isNotEmpty,
                  child: Column(
                    children: recentProjects.map((project) {
                      final count = taskProvider.allTasks
                          .where((t) => t.projectId == project.id)
                          .length;
                      return ProjectCard(
                        project: project,
                        taskCount: count,
                        onTap: onNavigateToProjects,
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeBanner(String firstName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_getGreeting()}, $firstName !',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppStrings.appSlogan,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildOverviewRow({
    required int projectCount,
    required int taskCount,
  }) {
    return Row(
      children: [
        Expanded(
          child: _OverviewCard(
            icon: Icons.folder_rounded,
            label: AppStrings.projects,
            count: projectCount,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _OverviewCard(
            icon: Icons.checklist_rounded,
            label: AppStrings.tasks,
            count: taskCount,
            color: AppColors.info,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusStatsRow(Map<TaskStatus, int> stats) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: AppStrings.statusTodo,
            count: stats[TaskStatus.todo] ?? 0,
            color: AppColors.statusTodo,
            icon: Icons.radio_button_unchecked_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: AppStrings.statusInProgress,
            count: stats[TaskStatus.inProgress] ?? 0,
            color: AppColors.statusInProgress,
            icon: Icons.timelapse_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: AppStrings.statusDone,
            count: stats[TaskStatus.done] ?? 0,
            color: AppColors.statusDone,
            icon: Icons.check_circle_outline_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyProjects() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(Icons.folder_open_rounded,
              size: 48, color: AppColors.textDisable),
          SizedBox(height: 12),
          Text(
            AppStrings.noProjects,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              fontSize: 15,
            ),
          ),
          SizedBox(height: 6),
          Text(
            AppStrings.noProjectsDesc,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  const _OverviewCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$count',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color)),
              Text(label,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text('$count',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color)),
          const SizedBox(height: 4),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500),
              maxLines: 2),
        ],
      ),
    );
  }
}