import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/category_model.dart';
import '../data/services/hive_service.dart';

/// Provider that exposes the list of categories managed by [CategoryNotifier].
final categoryProvider =
    StateNotifierProvider<CategoryNotifier, List<CategoryModel>>(
  (ref) => CategoryNotifier(),
);

/// Manages category data stored in Hive.
class CategoryNotifier extends StateNotifier<List<CategoryModel>> {
  final Box<CategoryModel> _categoryBox = HiveService.categoriesBox;

  CategoryNotifier() : super([]) {
    // Load categories initially
    _loadCategories();

    // Rebuild state when Hive data changes
    _categoryBox.listenable().addListener(_loadCategories);
  }

  /// Loads all categories from the Hive box.
  void _loadCategories() {
    state = _categoryBox.values.toList();
  }

  /// Adds a new category.
  Future<void> addCategory(String name) async {
    final newCategory = CategoryModel(name: name);
    await _categoryBox.put(newCategory.id, newCategory);
    _loadCategories();
  }

  /// Updates an existing category.
  Future<void> updateCategory(CategoryModel updatedCategory) async {
    await _categoryBox.put(updatedCategory.id, updatedCategory);
    _loadCategories();
  }

  /// Deletes a category by ID.
  Future<void> deleteCategory(String id) async {
    await _categoryBox.delete(id);
    _loadCategories();
  }

  /// Retrieves a category by its ID.
  CategoryModel? getCategoryById(String id) {
    return _categoryBox.get(id);
  }

  @override
  void dispose() {
    _categoryBox.listenable().removeListener(_loadCategories);
    super.dispose();
  }
}
