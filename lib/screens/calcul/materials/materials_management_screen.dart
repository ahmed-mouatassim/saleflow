import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../calculator/constants/calc_constants.dart';
import '../calculator/provider/calc_data_provider.dart';
import 'models/material_item.dart';
import 'widgets/material_card.dart';
import 'widgets/add_material_dialog.dart';
import 'widgets/edit_material_dialog.dart';
import 'widgets/delete_material_dialog.dart';
import 'service/materials_api_service.dart';

/// ===== Materials Management Screen =====
/// شاشة إدارة جميع المواد والأسعار من الـ API
/// تدعم عمليات CRUD كاملة مع واجهة مستخدم حديثة
class MaterialsManagementScreen extends StatefulWidget {
  const MaterialsManagementScreen({super.key});

  @override
  State<MaterialsManagementScreen> createState() =>
      _MaterialsManagementScreenState();
}

class _MaterialsManagementScreenState extends State<MaterialsManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  bool _isSaving = false;

  // All material types from API
  static const List<MaterialTypeConfig> _materialTypes = [
    MaterialTypeConfig(
      type: 'spongeTypes',
      arabicName: 'الإسفنج',
      icon: Icons.layers_rounded,
      color: CalcTheme.primaryStart,
      unit: 'درهم/طن',
    ),
    MaterialTypeConfig(
      type: 'dressTypes',
      arabicName: 'الثوب',
      icon: Icons.texture_rounded,
      color: CalcTheme.warning,
      unit: 'درهم/متر',
    ),
    MaterialTypeConfig(
      type: 'footerTypes',
      arabicName: 'الفوتر',
      icon: Icons.grid_view_rounded,
      color: CalcTheme.success,
      unit: 'درهم/وحدة',
    ),
    MaterialTypeConfig(
      type: 'sfifa',
      arabicName: 'السفيفة',
      icon: Icons.linear_scale_rounded,
      color: Color(0xFFE91E63),
      unit: 'درهم',
    ),
    MaterialTypeConfig(
      type: 'spring',
      arabicName: 'الروسول',
      icon: Icons.waves_rounded,
      color: Color(0xFF9C27B0),
      unit: 'درهم',
    ),
    MaterialTypeConfig(
      type: 'Packaging Defaults',
      arabicName: 'التغليف',
      icon: Icons.inventory_2_rounded,
      color: Color(0xFF00BCD4),
      unit: 'درهم',
    ),
    MaterialTypeConfig(
      type: 'Cost Defaults',
      arabicName: 'التكاليف',
      icon: Icons.monetization_on_rounded,
      color: Color(0xFFFF5722),
      unit: 'درهم',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _materialTypes.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ===== CRUD Operations =====

  Future<void> _refreshData(CalcDataProvider dataProvider) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await dataProvider.refresh();

      if (mounted) {
        _showSnackBar(
          dataProvider.hasError
              ? dataProvider.errorMessage ?? 'فشل في تحديث البيانات'
              : 'تم تحديث البيانات بنجاح',
          isError: dataProvider.hasError,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool> _handleAddMaterial(
    CalcDataProvider dataProvider,
    String name,
    String type,
    double price,
  ) async {
    // Check for duplicate
    if (_checkDuplicate(dataProvider, name, type)) {
      _showSnackBar('هذه المادة موجودة بالفعل!', isError: true);
      return false;
    }

    setState(() => _isSaving = true);

    try {
      final response = await MaterialsApiService.createMaterial(
        name: name,
        type: type,
        price: price,
        editedBy: 'app',
      );

      if (response.success) {
        await dataProvider.refresh();
        _showSnackBar('تمت إضافة المادة بنجاح ✓');
        return true;
      } else {
        _showSnackBar(response.message ?? 'فشل في إضافة المادة', isError: true);
        return false;
      }
    } catch (e) {
      _showSnackBar('حدث خطأ: $e', isError: true);
      return false;
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<bool> _handleUpdateMaterial(
    CalcDataProvider dataProvider,
    MaterialItem item,
    double newPrice,
  ) async {
    setState(() => _isSaving = true);

    try {
      final response = await MaterialsApiService.updateMaterial(
        id: item.id,
        name: item.name,
        type: item.type,
        price: newPrice,
        editedBy: 'app',
      );

      if (response.success) {
        await dataProvider.refresh();
        _showSnackBar('تم تحديث السعر بنجاح ✓');
        return true;
      } else {
        _showSnackBar(response.message ?? 'فشل في تحديث السعر', isError: true);
        return false;
      }
    } catch (e) {
      _showSnackBar('حدث خطأ: $e', isError: true);
      return false;
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<bool> _handleDeleteMaterial(
    CalcDataProvider dataProvider,
    MaterialItem item,
  ) async {
    setState(() => _isSaving = true);

    try {
      final response = await MaterialsApiService.deleteMaterial(
        id: item.id,
        name: item.name,
        type: item.type,
      );

      if (response.success) {
        await dataProvider.refresh();
        _showSnackBar('تم حذف المادة بنجاح ✓');
        return true;
      } else {
        _showSnackBar(response.message ?? 'فشل في حذف المادة', isError: true);
        return false;
      }
    } catch (e) {
      _showSnackBar('حدث خطأ: $e', isError: true);
      return false;
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  bool _checkDuplicate(
    CalcDataProvider dataProvider,
    String name,
    String type,
  ) {
    final items = _getItemsForType(dataProvider, type);
    return items.any((e) => e.name.toLowerCase() == name.toLowerCase());
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? CalcTheme.error : CalcTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  // ===== Dialog Handlers =====

  void _showAddDialog(
    CalcDataProvider dataProvider, {
    String? preSelectedType,
  }) {
    AddMaterialDialog.show(
      context,
      preSelectedType: preSelectedType,
      currentTabIndex: _tabController.index,
      materialTypes: _materialTypes,
      onAdd: (name, type, price) =>
          _handleAddMaterial(dataProvider, name, type, price),
    );
  }

  void _showEditDialog(CalcDataProvider dataProvider, MaterialItem item) {
    EditMaterialDialog.show(
      context,
      item: item,
      onUpdate: (item, newPrice) =>
          _handleUpdateMaterial(dataProvider, item, newPrice),
    );
  }

  void _showDeleteDialog(CalcDataProvider dataProvider, MaterialItem item) {
    DeleteMaterialDialog.show(
      context,
      item: item,
      onDelete: (item) => _handleDeleteMaterial(dataProvider, item),
    );
  }

  // ===== Get Items for Type =====
  List<MaterialItem> _getItemsForType(
    CalcDataProvider dataProvider,
    String type,
  ) {
    // 1. Preferred Method: Get from allProducts (Source: DB 'type' column)
    // This ensures items are categorized correctly by their trusted DB type,
    // not by guessing based on their name.
    if (dataProvider.allProducts.isNotEmpty) {
      final items = dataProvider.allProducts
          .where((p) => p.type == type)
          .map(
            (p) => MaterialItem(
              id: p.id,
              name: p.name,
              type: p.type,
              price: p.price,
              date: p.date.toIso8601String(),
              editedBy: p.editedBy,
            ),
          )
          .toList();

      // Return ONLY if we actually found something OR if we trust allProducts is loaded.
      // Since allProducts comes from the same API call as the maps, if it's not empty,
      // it contains ALL items. So even if 'items' is empty, it means "no items of this type".
      // We should return it to avoid falling back to the messy map logic.
      return items;
    }

    // 2. Fallback Method: Use legacy maps (less reliable, missing IDs)
    Map<String, dynamic> data;

    switch (type) {
      case 'spongeTypes':
        data = dataProvider.spongeTypes.map((k, v) => MapEntry(k, v));
        break;
      case 'dressTypes':
        data = dataProvider.dressTypes;
        break;
      case 'footerTypes':
        data = dataProvider.footerTypes;
        break;
      case 'sfifa':
        // Get sfifa items from API data
        data =
            dataProvider.apiData?.sfifaDefaults
                .map((k, v) => MapEntry(k, v))
                .cast<String, dynamic>() ??
            {};
        // Filter out spring items
        data.removeWhere(
          (k, v) =>
              k.toLowerCase().contains('spring') ||
              k.toLowerCase().contains('sachet') ||
              k.contains('روسول'),
        );
        break;
      case 'spring':
        // Get spring items from API data
        data = <String, dynamic>{};
        if (dataProvider.apiData?.sfifaDefaults != null) {
          dataProvider.apiData!.sfifaDefaults.forEach((k, v) {
            if (k.toLowerCase().contains('spring') ||
                k.toLowerCase().contains('sachet') ||
                k.contains('روسول')) {
              data[k] = v;
            }
          });
        }
        break;
      case 'Packaging Defaults':
        data =
            dataProvider.apiData?.packagingDefaults
                .map((k, v) => MapEntry(k, v))
                .cast<String, dynamic>() ??
            {};
        break;
      case 'Cost Defaults':
        data =
            dataProvider.apiData?.costDefaults
                .map((k, v) => MapEntry(k, v))
                .cast<String, dynamic>() ??
            {};
        break;
      default:
        data = {};
    }

    return data.entries.map((e) {
      return MaterialItem(
        name: e.key,
        type: type,
        price: (e.value as num).toDouble(),
      );
    }).toList();
  }

  // ===== Build Methods =====

  @override
  Widget build(BuildContext context) {
    return Consumer<CalcDataProvider>(
      builder: (context, dataProvider, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF1A1A2E),
          appBar: _buildAppBar(dataProvider),
          body: _buildBody(dataProvider),
          floatingActionButton: _buildFAB(dataProvider),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(CalcDataProvider dataProvider) {
    return AppBar(
      title: const Text(
        'إدارة المواد والأسعار',
        style: TextStyle(
          fontFamily: 'Tajawal',
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        // Refresh button
        IconButton(
          icon: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.refresh_rounded),
          onPressed: _isLoading ? null : () => _refreshData(dataProvider),
          tooltip: 'تحديث البيانات',
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        isScrollable: true, // ✅ Make tabs scrollable
        tabAlignment: TabAlignment.start,
        indicatorColor: CalcTheme.primaryStart,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white54,
        labelStyle: const TextStyle(
          fontFamily: 'Tajawal',
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        tabs: _materialTypes.map((config) {
          final count = _getItemsForType(dataProvider, config.type).length;
          return _buildTab(config.icon, config.arabicName, count, config.color);
        }).toList(),
      ),
    );
  }

  Widget _buildTab(IconData icon, String label, int count, Color color) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBody(CalcDataProvider dataProvider) {
    if (dataProvider.isLoading && !dataProvider.isLoaded) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: CalcTheme.primaryStart),
            SizedBox(height: 16),
            Text(
              'جاري تحميل البيانات...',
              style: TextStyle(fontFamily: 'Tajawal', color: Colors.white54),
            ),
          ],
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: _materialTypes.map((config) {
        final items = _getItemsForType(dataProvider, config.type);
        return _buildMaterialsTab(
          dataProvider: dataProvider,
          config: config,
          items: items,
        );
      }).toList(),
    );
  }

  Widget _buildMaterialsTab({
    required CalcDataProvider dataProvider,
    required MaterialTypeConfig config,
    required List<MaterialItem> items,
  }) {
    if (items.isEmpty) {
      return _buildEmptyState(dataProvider, config);
    }

    return RefreshIndicator(
      onRefresh: () => _refreshData(dataProvider),
      color: CalcTheme.primaryStart,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildSectionHeader(config, items.length);
          }

          final item = items[index - 1];
          return MaterialCard(
            item: item,
            isSaving: _isSaving,
            onEdit: () => _showEditDialog(dataProvider, item),
            onDelete: () => _showDeleteDialog(dataProvider, item),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(MaterialTypeConfig config, int count) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            config.color.withValues(alpha: 0.15),
            config.color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: config.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: config.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(config.icon, color: config.color, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أنواع ${config.arabicName}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Tajawal',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'أسعار ${config.arabicName} (${config.unit})',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white54,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: config.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.inventory_2_outlined, size: 16, color: config.color),
                const SizedBox(width: 6),
                Text(
                  '$count نوع',
                  style: TextStyle(
                    color: config.color,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Tajawal',
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    CalcDataProvider dataProvider,
    MaterialTypeConfig config,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: config.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              config.icon,
              size: 64,
              color: config.color.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'لا توجد أنواع ${config.arabicName}',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white54,
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'اضغط على الزر أدناه لإضافة نوع جديد',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white38,
              fontFamily: 'Tajawal',
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () =>
                _showAddDialog(dataProvider, preSelectedType: config.type),
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'إضافة نوع',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: config.color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB(CalcDataProvider dataProvider) {
    return FloatingActionButton.extended(
      onPressed: _isSaving ? null : () => _showAddDialog(dataProvider),
      icon: _isSaving
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.add_rounded),
      label: Text(
        _isSaving ? 'جاري الحفظ...' : 'إضافة جديد',
        style: const TextStyle(
          fontFamily: 'Tajawal',
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: CalcTheme.primaryStart,
      foregroundColor: Colors.white,
      elevation: 4,
    );
  }
}

/// Material type configuration
class MaterialTypeConfig {
  final String type;
  final String arabicName;
  final IconData icon;
  final Color color;
  final String unit;

  const MaterialTypeConfig({
    required this.type,
    required this.arabicName,
    required this.icon,
    required this.color,
    required this.unit,
  });
}
