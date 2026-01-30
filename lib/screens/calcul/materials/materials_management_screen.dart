import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../calculator/provider/calc_data_provider.dart';
import '../calculator/constants/calc_constants.dart';
import '../calculator/service/calc_api_service.dart';

/// ===== Materials Management Screen =====
/// شاشة إدارة المواد (الإسفنج، الثوب، الفوتر)
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CalcDataProvider>(
      builder: (context, dataProvider, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF1A1A2E),
          appBar: AppBar(
            title: const Text(
              'إدارة المواد والأسعار',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
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
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: CalcTheme.primaryStart,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              labelStyle: const TextStyle(
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.bold,
              ),
              tabs: const [
                Tab(
                  text: 'الإسفنج',
                  icon: Icon(Icons.layers_rounded, size: 20),
                ),
                Tab(text: 'الثوب', icon: Icon(Icons.texture_rounded, size: 20)),
                Tab(
                  text: 'الفوتر',
                  icon: Icon(Icons.grid_view_rounded, size: 20),
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // Sponge Types Tab
              _buildMaterialsTab(
                dataProvider: dataProvider,
                type: 'sponge',
                title: 'أنواع الإسفنج',
                subtitle: 'أسعار الإسفنج لكل نوع (درهم/كيلو)',
                icon: Icons.layers_rounded,
                items: dataProvider.spongeTypes.entries
                    .map(
                      (e) => MaterialItem(
                        name: e.key,
                        price: e.value.toDouble(),
                        type: 'sponge',
                      ),
                    )
                    .toList(),
              ),

              // Dress Types Tab
              _buildMaterialsTab(
                dataProvider: dataProvider,
                type: 'dress',
                title: 'أنواع الثوب',
                subtitle: 'أسعار الثوب لكل نوع (درهم/متر)',
                icon: Icons.texture_rounded,
                items: dataProvider.dressTypes.entries
                    .map(
                      (e) => MaterialItem(
                        name: e.key,
                        price: e.value,
                        type: 'dress',
                      ),
                    )
                    .toList(),
              ),

              // Footer Types Tab
              _buildMaterialsTab(
                dataProvider: dataProvider,
                type: 'footer',
                title: 'أنواع الفوتر',
                subtitle: 'أسعار الفوتر لكل نوع (درهم/وحدة)',
                icon: Icons.grid_view_rounded,
                items: dataProvider.footerTypes.entries
                    .map(
                      (e) => MaterialItem(
                        name: e.key,
                        price: e.value,
                        type: 'footer',
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddMaterialDialog(dataProvider),
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'إضافة مادة جديدة',
              style: TextStyle(fontFamily: 'Tajawal'),
            ),
            backgroundColor: CalcTheme.primaryStart,
          ),
        );
      },
    );
  }

  Widget _buildMaterialsTab({
    required CalcDataProvider dataProvider,
    required String type,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<MaterialItem> items,
  }) {
    if (dataProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: CalcTheme.primaryStart),
      );
    }

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.white24),
            const SizedBox(height: 16),
            Text(
              'لا توجد $title',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white54,
                fontFamily: 'Tajawal',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () =>
                  _showAddMaterialDialog(dataProvider, preSelectedType: type),
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'إضافة',
                style: TextStyle(fontFamily: 'Tajawal'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: CalcTheme.primaryStart,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length + 1, // +1 for header
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CalcTheme.primaryStart.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: CalcTheme.primaryStart, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      Text(
                        subtitle,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: CalcTheme.success.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${items.length} نوع',
                    style: const TextStyle(
                      color: CalcTheme.success,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final item = items[index - 1];
        return _buildMaterialCard(dataProvider, item);
      },
    );
  }

  Widget _buildMaterialCard(CalcDataProvider dataProvider, MaterialItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          item.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Tajawal',
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          _getTypeLabel(item.type),
          style: const TextStyle(color: Colors.white54, fontFamily: 'Tajawal'),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Price
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [CalcTheme.primaryStart, CalcTheme.primaryEnd],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${item.price.toStringAsFixed(item.price == item.price.roundToDouble() ? 0 : 2)} درهم',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Edit button
            IconButton(
              icon: const Icon(Icons.edit_rounded, color: Colors.white70),
              onPressed: () => _showEditMaterialDialog(dataProvider, item),
            ),
            // Delete button
            IconButton(
              icon: const Icon(Icons.delete_rounded, color: Colors.redAccent),
              onPressed: () => _showDeleteConfirmation(dataProvider, item),
            ),
          ],
        ),
      ),
    );
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'sponge':
        return 'إسفنج';
      case 'dress':
        return 'ثوب';
      case 'footer':
        return 'فوتر';
      default:
        return type;
    }
  }

  Future<void> _refreshData(CalcDataProvider dataProvider) async {
    setState(() => _isLoading = true);
    await dataProvider.refresh();
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            dataProvider.hasError
                ? dataProvider.errorMessage ?? 'فشل في تحديث البيانات'
                : 'تم تحديث البيانات بنجاح',
            style: const TextStyle(fontFamily: 'Tajawal'),
          ),
          backgroundColor: dataProvider.hasError
              ? Colors.red
              : CalcTheme.success,
        ),
      );
    }
  }

  void _showAddMaterialDialog(
    CalcDataProvider dataProvider, {
    String? preSelectedType,
  }) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    String selectedType = preSelectedType ?? _getCurrentTabType();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: CalcTheme.primaryStart.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: CalcTheme.primaryStart,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'إضافة مادة جديدة',
                style: TextStyle(fontFamily: 'Tajawal', color: Colors.white),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Type selector
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  dropdownColor: const Color(0xFF2D3748),
                  decoration: InputDecoration(
                    labelText: 'نوع المادة',
                    labelStyle: const TextStyle(
                      color: Colors.white70,
                      fontFamily: 'Tajawal',
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'sponge',
                      child: Text(
                        'إسفنج',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'dress',
                      child: Text(
                        'ثوب',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'footer',
                      child: Text(
                        'فوتر',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) =>
                      setDialogState(() => selectedType = value!),
                ),
                const SizedBox(height: 16),
                // Name field
                TextField(
                  controller: nameController,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Tajawal',
                  ),
                  decoration: InputDecoration(
                    labelText: 'اسم المادة',
                    labelStyle: const TextStyle(
                      color: Colors.white70,
                      fontFamily: 'Tajawal',
                    ),
                    hintText: 'مثال: إسفنج H25',
                    hintStyle: const TextStyle(color: Colors.white30),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Price field
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Tajawal',
                  ),
                  decoration: InputDecoration(
                    labelText: 'السعر (درهم)',
                    labelStyle: const TextStyle(
                      color: Colors.white70,
                      fontFamily: 'Tajawal',
                    ),
                    hintText: '0.00',
                    hintStyle: const TextStyle(color: Colors.white30),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                    suffixText: 'درهم',
                    suffixStyle: const TextStyle(color: Colors.white54),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'إلغاء',
                style: TextStyle(color: Colors.white54, fontFamily: 'Tajawal'),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final price = double.tryParse(priceController.text) ?? 0;

                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('الرجاء إدخال اسم المادة')),
                  );
                  return;
                }

                Navigator.pop(context);
                await _addMaterial(dataProvider, name, selectedType, price);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CalcTheme.primaryStart,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'إضافة',
                style: TextStyle(fontFamily: 'Tajawal', color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditMaterialDialog(
    CalcDataProvider dataProvider,
    MaterialItem item,
  ) {
    final priceController = TextEditingController(text: item.price.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.edit_rounded, color: Colors.amber),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'تعديل ${item.name}',
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  color: Colors.white,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: TextField(
          controller: priceController,
          keyboardType: TextInputType.number,
          autofocus: true,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Tajawal',
            fontSize: 18,
          ),
          decoration: InputDecoration(
            labelText: 'السعر الجديد (درهم)',
            labelStyle: const TextStyle(
              color: Colors.white70,
              fontFamily: 'Tajawal',
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white24),
            ),
            suffixText: 'درهم',
            suffixStyle: const TextStyle(color: Colors.white54),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'إلغاء',
              style: TextStyle(color: Colors.white54, fontFamily: 'Tajawal'),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final price = double.tryParse(priceController.text) ?? 0;
              Navigator.pop(context);
              await _updateMaterial(dataProvider, item, price);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'حفظ',
              style: TextStyle(fontFamily: 'Tajawal', color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    CalcDataProvider dataProvider,
    MaterialItem item,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.delete_rounded, color: Colors.red),
            ),
            const SizedBox(width: 12),
            const Text(
              'تأكيد الحذف',
              style: TextStyle(fontFamily: 'Tajawal', color: Colors.white),
            ),
          ],
        ),
        content: Text(
          'هل تريد حذف "${item.name}"؟\nلا يمكن التراجع عن هذا الإجراء.',
          style: const TextStyle(fontFamily: 'Tajawal', color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'إلغاء',
              style: TextStyle(color: Colors.white54, fontFamily: 'Tajawal'),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteMaterial(dataProvider, item);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'حذف',
              style: TextStyle(fontFamily: 'Tajawal', color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _getCurrentTabType() {
    switch (_tabController.index) {
      case 0:
        return 'sponge';
      case 1:
        return 'dress';
      case 2:
        return 'footer';
      default:
        return 'sponge';
    }
  }

  Future<void> _addMaterial(
    CalcDataProvider dataProvider,
    String name,
    String type,
    double price,
  ) async {
    setState(() => _isLoading = true);

    try {
      final response = await CalcApiService.createProduct(
        name: name,
        type: type,
        price: price,
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (response.success) {
          await dataProvider.refresh();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'تمت إضافة المادة بنجاح',
                style: TextStyle(fontFamily: 'Tajawal'),
              ),
              backgroundColor: CalcTheme.success,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response.message ?? 'فشل في إضافة المادة',
                style: const TextStyle(fontFamily: 'Tajawal'),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'خطأ: $e',
              style: const TextStyle(fontFamily: 'Tajawal'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateMaterial(
    CalcDataProvider dataProvider,
    MaterialItem item,
    double newPrice,
  ) async {
    setState(() => _isLoading = true);

    try {
      final response = await CalcApiService.updateProduct(
        name: item.name,
        type: item.type,
        price: newPrice,
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (response.success) {
          await dataProvider.refresh();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'تم تحديث السعر بنجاح',
                style: TextStyle(fontFamily: 'Tajawal'),
              ),
              backgroundColor: CalcTheme.success,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response.message ?? 'فشل في تحديث السعر',
                style: const TextStyle(fontFamily: 'Tajawal'),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'خطأ: $e',
              style: const TextStyle(fontFamily: 'Tajawal'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteMaterial(
    CalcDataProvider dataProvider,
    MaterialItem item,
  ) async {
    setState(() => _isLoading = true);

    try {
      final response = await CalcApiService.deleteProduct(
        name: item.name,
        type: item.type,
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (response.success) {
          await dataProvider.refresh();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'تم حذف المادة بنجاح',
                style: TextStyle(fontFamily: 'Tajawal'),
              ),
              backgroundColor: CalcTheme.success,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response.message ?? 'فشل في حذف المادة',
                style: const TextStyle(fontFamily: 'Tajawal'),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'خطأ: $e',
              style: const TextStyle(fontFamily: 'Tajawal'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// Material Item Model
class MaterialItem {
  final String name;
  final double price;
  final String type;
  final int? id;

  MaterialItem({
    required this.name,
    required this.price,
    required this.type,
    this.id,
  });
}
