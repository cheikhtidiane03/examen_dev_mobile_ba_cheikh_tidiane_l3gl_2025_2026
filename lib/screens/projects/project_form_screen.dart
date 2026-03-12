import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/core/constants/app_strings.dart';
import 'package:sunu_task/models/project.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/widgets/cards/project_card.dart';
import 'package:sunu_task/widgets/common/custom_button.dart';
import 'package:sunu_task/widgets/common/custom_text_field.dart';

class ProjectFormScreen extends StatefulWidget {
  final Project? project;
  final AuthProvider authProvider;
  final ProjectProvider projectProvider;

  const ProjectFormScreen({
    super.key,
    this.project,
    required this.authProvider,
    required this.projectProvider,
  });

  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late int _selectedColor;

  static List<int> get _projectColors => AppColors.projectColorValues;

  bool get _isEditing => widget.project != null;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.project?.name ?? '');
    _descController =
        TextEditingController(text: widget.project?.description ?? '');
    _selectedColor = widget.project?.color ?? _projectColors[0];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final String userId = widget.authProvider.currentUser!.id;

    if (_isEditing) {
      final Project updated = widget.project!.copyWith(
        name: _nameController.text.trim(),
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        color: _selectedColor,
        updatedAt: DateTime.now(),
      );
      await widget.projectProvider.updateProject(updated);
    } else {
      final Project newProject = Project(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        color: _selectedColor,
        userId: userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await widget.projectProvider.createProject(newProject);
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

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
          _isEditing ? AppStrings.editProject : AppStrings.newProject,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        onChanged: () => setState(() {}),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Apercu'),
              const SizedBox(height: 10),
              _buildPreview(),
              const SizedBox(height: 28),

              _buildSectionTitle(AppStrings.projectName),
              const SizedBox(height: 10),
              CustomTextField(
                controller: _nameController,
                label: AppStrings.projectName,
                hint: 'Ex: Application mobile',
                prefixIcon: Icons.folder_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppStrings.requiredField;
                  }
                  if (value.trim().length < 3) {
                    return 'Le nom doit contenir au moins 3 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              _buildSectionTitle(AppStrings.projectDescription),
              const SizedBox(height: 10),
              CustomTextField(
                controller: _descController,
                label: AppStrings.projectDescription,
                hint: 'Decrivez brievement ce projet...',
                prefixIcon: Icons.notes_rounded,
                maxLines: 4,
              ),
              const SizedBox(height: 24),

              _buildSectionTitle(AppStrings.projectColor),
              const SizedBox(height: 14),
              _buildColorPicker(),
              const SizedBox(height: 36),

              ListenableBuilder(
                listenable: widget.projectProvider,
                builder: (context, _) {
                  return CustomButton(
                    text: _isEditing ? AppStrings.save : AppStrings.add,
                    onPressed: _handleSubmit,
                    isLoading: widget.projectProvider.isLoading,
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

  Widget _buildPreview() {
    final Project previewProject = Project(
      id: 'preview',
      name: _nameController.text.trim().isEmpty
          ? 'Nom du projet'
          : _nameController.text.trim(),
      description: _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
      color: _selectedColor,
      userId: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: ProjectCard(project: previewProject, taskCount: 0),
    );
  }

  Widget _buildColorPicker() {
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: _projectColors.map((color) {
        final bool isSelected = _selectedColor == color;
        return GestureDetector(
          onTap: () => setState(() => _selectedColor = color),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Color(color),
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : Colors.transparent,
                width: 3,
              ),
              boxShadow: isSelected
                  ? [
                BoxShadow(
                  color: Color(color).withValues(alpha: 0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
                  : null,
            ),
            // Coche via Visibility
            child: Visibility(
              visible: isSelected,
              child: const Icon(Icons.check_rounded,
                  color: Colors.white, size: 22),
            ),
          ),
        );
      }).toList(),
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
}