// lib/screens/home/tabs/profile_tab.dart

import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/core/constants/app_strings.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/providers/task_provider.dart';

class ProfileTab extends StatelessWidget {
  final AuthProvider authProvider;
  final ProjectProvider projectProvider;
  final TaskProvider taskProvider;
  final VoidCallback onLogout;

  const ProfileTab({
    super.key,
    required this.authProvider,
    required this.projectProvider,
    required this.taskProvider,
    required this.onLogout,
  });

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
        if (user == null) return const SizedBox.shrink();

        final initial =
        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';

        // Formater la date d'inscription : JJ/MM/AAAA
        final date = user.createdAt;
        final joinDate =
            '${date.day.toString().padLeft(2, '0')}/'
            '${date.month.toString().padLeft(2, '0')}/'
            '${date.year}';

        // Statistiques personnelles
        final int projectCount = projectProvider.projects.length;
        final int totalTasks = taskProvider.allTasks.length;
        final int doneTasks = taskProvider.allTasks
            .where((t) =>
        t.status.name == 'done')
            .length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // ── Avatar ─────────────────────────────────────────────────
              CircleAvatar(
                radius: 52,
                backgroundColor:
                AppColors.primary.withValues(alpha: 0.15),
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ── Nom ───────────────────────────────────────────────────
              Text(
                user.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),

              // ── Email ─────────────────────────────────────────────────
              Text(
                user.email,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),

              // ── Date d'inscription ────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 13,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Membre depuis le $joinDate',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ── Statistiques personnelles ─────────────────────────────
              _buildSectionTitle('Mes statistiques'),
              const SizedBox(height: 12),
              _buildStatsGrid(
                projectCount: projectCount,
                totalTasks: totalTasks,
                doneTasks: doneTasks,
              ),
              const SizedBox(height: 32),

              // ── Informations du compte ────────────────────────────────
              _buildSectionTitle('Mon compte'),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      icon: Icons.person_outline_rounded,
                      label: AppStrings.name,
                      value: user.name,
                    ),
                    const Divider(
                      color: AppColors.border,
                      height: 1,
                      indent: 56,
                    ),
                    _buildInfoRow(
                      icon: Icons.email_outlined,
                      label: AppStrings.email,
                      value: user.email,
                    ),
                    const Divider(
                      color: AppColors.border,
                      height: 1,
                      indent: 56,
                    ),
                    _buildInfoRow(
                      icon: Icons.calendar_month_outlined,
                      label: 'Inscription',
                      value: joinDate,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // ── Bouton Déconnexion ─────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: onLogout,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(
                        color: AppColors.error, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.logout_rounded, size: 20),
                  label: const Text(
                    AppStrings.logout,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // ── Titre de section ──────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  // ── Grille de statistiques personnelles ──────────────────────────────────

  Widget _buildStatsGrid({
    required int projectCount,
    required int totalTasks,
    required int doneTasks,
  }) {
    return Row(
      children: [
        Expanded(
          child: _PersonalStatCard(
            icon: Icons.folder_rounded,
            label: AppStrings.projects,
            count: projectCount,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _PersonalStatCard(
            icon: Icons.checklist_rounded,
            label: 'Total taches',
            count: totalTasks,
            color: AppColors.statusInProgress,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _PersonalStatCard(
            icon: Icons.check_circle_rounded,
            label: 'Terminees',
            count: doneTasks,
            color: AppColors.statusDone,
          ),
        ),
      ],
    );
  }

  // ── Ligne d'information ───────────────────────────────────────────────────

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Carte de statistique personnelle ─────────────────────────────────────────

class _PersonalStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  const _PersonalStatCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}