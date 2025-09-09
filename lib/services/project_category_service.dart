import 'package:flutter/material.dart';
import 'local_database_service.dart';
import 'auth_service.dart';

class ProjectCategoryItem {
  final String id;
  final String name;
  final IconData? icon;
  final Color? color;

  ProjectCategoryItem({
    required this.id,
    required this.name,
    this.icon,
    this.color,
  });

  factory ProjectCategoryItem.fromMap(Map<String, dynamic> map) {
    final codePoint = map['icon_codepoint'] as int?;
    final colorHex = map['color_hex'] as String?;
    return ProjectCategoryItem(
      id: map['id'] as String,
      name: map['name'] as String,
      icon: codePoint != null
          ? IconData(codePoint, fontFamily: 'MaterialIcons')
          : null,
      color: colorHex != null ? _colorFromHex(colorHex) : null,
    );
  }

  static String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0')}';
  }

  static Color _colorFromHex(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  Map<String, dynamic> toDbMap() {
    return {
      'name': name,
      'icon_codepoint': icon?.codePoint,
      'color_hex': color != null ? _colorToHex(color!) : null,
    };
  }
}

class ProjectCategoryService {
  static final LocalDatabaseService _db = LocalDatabaseService.instance;
  static String? get _userId => AuthService.currentUser?["id"];

  static Future<List<ProjectCategoryItem>> getProjectCategories() async {
    if (_userId == null) throw Exception('User not authenticated');
    final rows = await _db.getProjectCategories(_userId!);
    return rows.map(ProjectCategoryItem.fromMap).toList();
  }

  static Future<String> addProjectCategory({
    required String name,
    IconData? icon,
    Color? color,
  }) async {
    if (_userId == null) throw Exception('User not authenticated');
    final id = await _db.createProjectCategory(_userId!, {
      'name': name.trim(),
      'icon_codepoint': icon?.codePoint,
      'color_hex': color != null ? ProjectCategoryItem._colorToHex(color) : null,
    });
    return id;
  }

  static Future<void> updateProjectCategory({
    required String id,
    required String name,
    IconData? icon,
    Color? color,
  }) async {
    if (_userId == null) throw Exception('User not authenticated');
    await _db.updateProjectCategory(id, {
      'name': name.trim(),
      'icon_codepoint': icon?.codePoint,
      'color_hex': color != null ? ProjectCategoryItem._colorToHex(color) : null,
    });
  }

  static Future<void> deleteProjectCategory(String id) async {
    if (_userId == null) throw Exception('User not authenticated');
    await _db.deleteProjectCategory(id);
  }
}