import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../services/project_category_service.dart';

class ProjectCategorySettingsScreen extends StatefulWidget {
  const ProjectCategorySettingsScreen({super.key});

  @override
  State<ProjectCategorySettingsScreen> createState() => _ProjectCategorySettingsScreenState();
}

class _ProjectCategorySettingsScreenState extends State<ProjectCategorySettingsScreen> {
  bool _isLoading = true;
  List<ProjectCategoryItem> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final items = await ProjectCategoryService.getProjectCategories();
      setState(() {
        _categories = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load project categories: $e')),
        );
      }
    }
  }

  Future<void> _addCategory() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Project Category', style: GoogleFonts.poppins()),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Category name'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.poppins()),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: Text('Add', style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      try {
        await ProjectCategoryService.addProjectCategory(name: result);
        await _loadCategories();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Project category added')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add project category: $e')),
          );
        }
      }
    }
  }

  Future<void> _editCategory(ProjectCategoryItem item) async {
    final controller = TextEditingController(text: item.name);
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Project Category', style: GoogleFonts.poppins()),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Category name'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.poppins()),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: Text('Save', style: GoogleFonts.poppins()),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty && result != item.name) {
      try {
        await ProjectCategoryService.updateProjectCategory(
          id: item.id,
          name: result,
          icon: item.icon,
          color: item.color,
        );
        await _loadCategories();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Project category updated')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update project category: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteCategory(ProjectCategoryItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Project Category', style: GoogleFonts.poppins()),
        content: Text('Delete "${item.name}"? This will remove the category from all projects using it.', style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: GoogleFonts.poppins(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ProjectCategoryService.deleteProjectCategory(item.id);
        await _loadCategories();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Project category deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Project Categories',
          style: GoogleFonts.poppins(
            fontSize: AppConstants.textXLarge,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: false,
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.plus, color: AppColors.textPrimary, size: 18),
            onPressed: _addCategory,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _categories.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(FontAwesomeIcons.folderOpen, size: 48, color: AppColors.textSecondary),
                      const SizedBox(height: 16),
                      Text(
                        'No project categories yet',
                        style: GoogleFonts.poppins(
                          color: AppColors.textSecondary,
                          fontSize: AppConstants.textLarge,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add categories to organize your projects',
                        style: GoogleFonts.poppins(
                          color: AppColors.textSecondary,
                          fontSize: AppConstants.textMedium,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = _categories[index];
                    return ListTile(
                      leading: Icon(
                        item.icon ?? FontAwesomeIcons.folder,
                        color: item.color ?? AppColors.textPrimary,
                      ),
                      title: Text(item.name, style: GoogleFonts.poppins()),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(FontAwesomeIcons.edit, size: 16, color: AppColors.textSecondary),
                            onPressed: () => _editCategory(item),
                          ),
                          IconButton(
                            icon: const Icon(FontAwesomeIcons.trash, size: 16, color: AppColors.error),
                            onPressed: () => _deleteCategory(item),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}