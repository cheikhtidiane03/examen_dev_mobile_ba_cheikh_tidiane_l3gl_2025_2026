// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/core/constants/app_strings.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/providers/task_provider.dart';
import 'package:sunu_task/screens/auth/login_screen.dart';
import 'package:sunu_task/screens/home/tabs/dashboard_tab.dart';
import 'package:sunu_task/screens/home/tabs/profile_tab.dart';
import 'package:sunu_task/screens/home/tabs/projects_tab.dart';
import 'package:sunu_task/screens/home/tabs/tasks_tab.dart';

class HomeScreen extends StatefulWidget {
  final AuthProvider authProvider;
  final ProjectProvider projectProvider;
  final TaskProvider taskProvider;

  const HomeScreen({
    super.key,
    required this.authProvider,
    required this.projectProvider,
    required this.taskProvider,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const List<String> _titles = [
    AppStrings.home,
    AppStrings.projects,
    AppStrings.tasks,
    AppStrings.profile,
  ];

  static const List<IconData> _icons = [
    Icons.dashboard_outlined,
    Icons.folder_outlined,
    Icons.checklist_outlined,
    Icons.person_outline_rounded,
  ];

  static const List<IconData> _iconsActive = [
    Icons.dashboard_rounded,
    Icons.folder_rounded,
    Icons.checklist_rounded,
    Icons.person_rounded,
  ];

  // FAB visible uniquement sur Dashboard (0) et Projets (1)
  bool get _showFab => _currentIndex == 0 || _currentIndex == 1;

  // ── Déconnexion ──────────────────────────────────────────────────────────

  Future<void> _handleLogout() async {
    // Fermer le Drawer si ouvert
    if (Navigator.canPop(context)) Navigator.pop(context);

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Deconnexion',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'Voulez-vous vraiment vous deconnecter ?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              AppStrings.cancel,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              AppStrings.logout,
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    await widget.authProvider.logout();
    widget.projectProvider.clearError();
    widget.taskProvider.clearTasks();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => LoginScreen(
          authProvider: widget.authProvider,
          projectProvider: widget.projectProvider,
          taskProvider: widget.taskProvider,
        ),
      ),
          (route) => false,
    );
  }

  void _navigateToTab(int index) {
    Navigator.pop(context); // Fermer le Drawer
    setState(() => _currentIndex = index);
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),

      // IndexedStack : garde tous les onglets en mémoire
      // → l'état (scroll, filtres) est préservé entre les changements
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardTab(
            authProvider: widget.authProvider,
            projectProvider: widget.projectProvider,
            taskProvider: widget.taskProvider,
            onNavigateToProjects: () => setState(() => _currentIndex = 1),
            onNavigateToTasks: () => setState(() => _currentIndex = 2),
          ),
          ProjectsTab(
            authProvider: widget.authProvider,
            projectProvider: widget.projectProvider,
            taskProvider: widget.taskProvider,
          ),
          TasksTab(
            taskProvider: widget.taskProvider,
            projectProvider: widget.projectProvider,
          ),
          ProfileTab(
            authProvider: widget.authProvider,
            projectProvider: widget.projectProvider,
            taskProvider: widget.taskProvider,
            onLogout: _handleLogout,
          ),
        ],
      ),

      bottomNavigationBar: _buildBottomNavBar(),
      floatingActionButton: _showFab ? _buildFab() : null,
    );
  }

  // ── AppBar ───────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: AppColors.border,
      leading: IconButton(
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
      ),
      title: Text(
        _titles[_currentIndex],
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: ListenableBuilder(
            listenable: widget.authProvider,
            builder: (context, _) {
              final name = widget.authProvider.currentUser?.name ?? '';
              final initial =
              name.isNotEmpty ? name[0].toUpperCase() : '?';
              return GestureDetector(
                onTap: () => _scaffoldKey.currentState?.openDrawer(),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor:
                  AppColors.primary.withValues(alpha: 0.15),
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 15,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Drawer ───────────────────────────────────────────────────────────────

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            _buildDrawerHeader(),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 8),
            _buildDrawerItem(0, _titles[0]),
            _buildDrawerItem(1, _titles[1]),
            _buildDrawerItem(2, _titles[2]),
            _buildDrawerItem(3, _titles[3]),
            const Spacer(),
            const Divider(color: AppColors.border, height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
              child: ListTile(
                onTap: _handleLogout,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                leading: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.error,
                  size: 22,
                ),
                title: const Text(
                  AppStrings.logout,
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return ListenableBuilder(
      listenable: widget.authProvider,
      builder: (context, _) {
        final user = widget.authProvider.currentUser;
        final name = user?.name ?? '';
        final email = user?.email ?? '';
        final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor:
                AppColors.primary.withValues(alpha: 0.15),
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDrawerItem(int index, String label) {
    final bool isActive = _currentIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        onTap: () => _navigateToTab(index),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: isActive
            ? AppColors.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        leading: Icon(
          isActive ? _iconsActive[index] : _icons[index],
          color:
          isActive ? AppColors.primary : AppColors.textSecondary,
          size: 22,
        ),
        title: Text(
          label,
          style: TextStyle(
            color:
            isActive ? AppColors.primary : AppColors.textSecondary,
            fontWeight:
            isActive ? FontWeight.w600 : FontWeight.normal,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  // ── BottomNavigationBar ───────────────────────────────────────────────────

  Widget _buildBottomNavBar() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border:
        Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        elevation: 0,
        items: List.generate(
          4,
              (i) => BottomNavigationBarItem(
            icon: Icon(_icons[i]),
            activeIcon: Icon(_iconsActive[i]),
            label: _titles[i],
          ),
        ),
      ),
    );
  }

  // ── FAB ───────────────────────────────────────────────────────────────────

  Widget _buildFab() {
    return FloatingActionButton.extended(
      onPressed: () {
        // Depuis Dashboard → aller sur l'onglet Projets
        if (_currentIndex == 0) setState(() => _currentIndex = 1);
        // TODO Partie 5 : ouvrir ProjectFormScreen
      },
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      elevation: 2,
      icon: const Icon(Icons.add_rounded, size: 22),
      label: const Text(
        AppStrings.newProject,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }
}