import 'package:flutter/material.dart';
import '../models/material_item.dart';
import '../service/materials_api_service.dart';

/// ===== Materials Provider =====
/// Provider لإدارة حالة المواد مع دعم CRUD كامل
class MaterialsProvider extends ChangeNotifier {
  // ===== State =====
  Map<String, List<MaterialItem>> _materials = {
    'spongeTypes': [],
    'dressTypes': [],
    'footerTypes': [],
  };

  bool _isLoading = false;
  bool _isLoaded = false;
  String? _error;
  bool _isSaving = false;

  // ===== Getters =====
  List<MaterialItem> get spongeTypes => _materials['spongeTypes'] ?? [];
  List<MaterialItem> get dressTypes => _materials['dressTypes'] ?? [];
  List<MaterialItem> get footerTypes => _materials['footerTypes'] ?? [];

  bool get isLoading => _isLoading;
  bool get isLoaded => _isLoaded;
  bool get isSaving => _isSaving;
  String? get error => _error;
  bool get hasError => _error != null;

  /// Get total count of all materials
  int get totalCount =>
      spongeTypes.length + dressTypes.length + footerTypes.length;

  /// Get materials by type
  List<MaterialItem> getMaterialsByType(String type) {
    return _materials[type] ?? [];
  }

  // ===== API Operations =====

  /// Load all materials from API
  Future<void> loadMaterials({bool forceRefresh = false}) async {
    if (_isLoading) return;
    if (_isLoaded && !forceRefresh) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await MaterialsApiService.fetchMaterials();

      if (response.success && response.materials != null) {
        _materials = response.materials!;
        _isLoaded = true;
        _error = null;
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = 'حدث خطأ أثناء تحميل البيانات: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh materials (force reload)
  Future<void> refresh() async {
    await loadMaterials(forceRefresh: true);
  }

  /// Create a new material
  Future<MaterialsApiResponse> createMaterial({
    required String name,
    required String type,
    required double price,
    String editedBy = 'app',
  }) async {
    _isSaving = true;
    notifyListeners();

    try {
      final response = await MaterialsApiService.createMaterial(
        name: name,
        type: type,
        price: price,
        editedBy: editedBy,
      );

      if (response.success) {
        // Add to local list
        final newItem =
            response.createdItem ??
            MaterialItem(
              name: name,
              type: type,
              price: price,
              editedBy: editedBy,
            );

        if (_materials.containsKey(type)) {
          _materials[type]!.add(newItem);
        }
      }

      return response;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Update an existing material
  Future<MaterialsApiResponse> updateMaterial({
    required MaterialItem item,
    required double newPrice,
    String editedBy = 'app',
  }) async {
    _isSaving = true;
    notifyListeners();

    try {
      final response = await MaterialsApiService.updateMaterial(
        id: item.id,
        name: item.name,
        type: item.type,
        price: newPrice,
        editedBy: editedBy,
      );

      if (response.success) {
        // Update local list
        final list = _materials[item.type];
        if (list != null) {
          final index = list.indexWhere(
            (m) => m.name == item.name && m.type == item.type,
          );
          if (index != -1) {
            list[index] = item.copyWith(price: newPrice, editedBy: editedBy);
          }
        }
      }

      return response;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Delete a material
  Future<MaterialsApiResponse> deleteMaterial(MaterialItem item) async {
    _isSaving = true;
    notifyListeners();

    try {
      final response = await MaterialsApiService.deleteMaterial(
        id: item.id,
        name: item.name,
        type: item.type,
      );

      if (response.success) {
        // Remove from local list
        final list = _materials[item.type];
        if (list != null) {
          list.removeWhere((m) => m.name == item.name && m.type == item.type);
        }
      }

      return response;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Check if a material name already exists
  bool materialExists(String name, String type) {
    final list = _materials[type];
    if (list == null) return false;
    return list.any((m) => m.name.toLowerCase() == name.toLowerCase());
  }

  /// Clear all data
  void clear() {
    _materials = {'spongeTypes': [], 'dressTypes': [], 'footerTypes': []};
    _isLoaded = false;
    _error = null;
    notifyListeners();
  }
}
