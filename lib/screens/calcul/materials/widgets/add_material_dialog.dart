import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../calculator/constants/calc_constants.dart';
import '../materials_management_screen.dart';

/// ===== Add Material Dialog =====
/// حوار إضافة مادة جديدة - يدعم جميع الأنواع
class AddMaterialDialog extends StatefulWidget {
  final String? preSelectedType;
  final int currentTabIndex;
  final List<MaterialTypeConfig> materialTypes;
  final Future<bool> Function(String name, String type, double price) onAdd;

  const AddMaterialDialog({
    super.key,
    this.preSelectedType,
    required this.currentTabIndex,
    required this.materialTypes,
    required this.onAdd,
  });

  @override
  State<AddMaterialDialog> createState() => _AddMaterialDialogState();

  static Future<bool?> show(
    BuildContext context, {
    String? preSelectedType,
    required int currentTabIndex,
    required List<MaterialTypeConfig> materialTypes,
    required Future<bool> Function(String name, String type, double price)
    onAdd,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AddMaterialDialog(
        preSelectedType: preSelectedType,
        currentTabIndex: currentTabIndex,
        materialTypes: materialTypes,
        onAdd: onAdd,
      ),
    );
  }
}

class _AddMaterialDialogState extends State<AddMaterialDialog> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late String _selectedType;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.preSelectedType ?? _getTypeFromIndex();
  }

  String _getTypeFromIndex() {
    if (widget.currentTabIndex >= 0 &&
        widget.currentTabIndex < widget.materialTypes.length) {
      return widget.materialTypes[widget.currentTabIndex].type;
    }
    return widget.materialTypes.first.type;
  }

  MaterialTypeConfig get _currentConfig {
    return widget.materialTypes.firstWhere(
      (c) => c.type == _selectedType,
      orElse: () => widget.materialTypes.first,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _handleAdd() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text) ?? 0;

    setState(() => _isLoading = true);

    try {
      final success = await widget.onAdd(name, _selectedType, price);
      if (mounted) {
        Navigator.pop(context, success);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  CalcTheme.success.withValues(alpha: 0.2),
                  CalcTheme.success.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.add_rounded, color: CalcTheme.success, size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'إضافة عنصر جديد',
              style: TextStyle(
                fontFamily: 'Tajawal',
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Type Selector
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                dropdownColor: const Color(0xFF2D3748),
                decoration: InputDecoration(
                  labelText: 'نوع العنصر',
                  labelStyle: const TextStyle(
                    color: Colors.white70,
                    fontFamily: 'Tajawal',
                  ),
                  prefixIcon: Icon(
                    _currentConfig.icon,
                    color: _currentConfig.color,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: CalcTheme.primaryStart),
                  ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                ),
                items: widget.materialTypes.map((config) {
                  return DropdownMenuItem(
                    value: config.type,
                    child: Row(
                      children: [
                        Icon(config.icon, size: 20, color: config.color),
                        const SizedBox(width: 8),
                        Text(
                          config.arabicName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedType = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Name Input
              TextFormField(
                controller: _nameController,
                textDirection: TextDirection.ltr,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Tajawal',
                ),
                decoration: InputDecoration(
                  labelText: 'اسم العنصر',
                  labelStyle: const TextStyle(
                    color: Colors.white70,
                    fontFamily: 'Tajawal',
                  ),
                  hintText: 'مثال: D22, ST300G...',
                  hintStyle: const TextStyle(color: Colors.white30),
                  prefixIcon: const Icon(
                    Icons.label_rounded,
                    color: Colors.white54,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: CalcTheme.primaryStart),
                  ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الرجاء إدخال اسم العنصر';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Price Input
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                ],
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Tajawal',
                  fontSize: 18,
                ),
                decoration: InputDecoration(
                  labelText: 'السعر / القيمة',
                  labelStyle: const TextStyle(
                    color: Colors.white70,
                    fontFamily: 'Tajawal',
                  ),
                  hintText: '0.00',
                  hintStyle: const TextStyle(color: Colors.white30),
                  prefixIcon: const Icon(
                    Icons.attach_money_rounded,
                    color: Colors.white54,
                  ),
                  suffixText: _currentConfig.unit,
                  suffixStyle: const TextStyle(
                    color: Colors.white54,
                    fontFamily: 'Tajawal',
                    fontSize: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: CalcTheme.primaryStart),
                  ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الرجاء إدخال القيمة';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price < 0) {
                    return 'الرجاء إدخال قيمة صحيحة';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context, false),
          child: const Text(
            'إلغاء',
            style: TextStyle(color: Colors.white54, fontFamily: 'Tajawal'),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleAdd,
          style: ElevatedButton.styleFrom(
            backgroundColor: CalcTheme.success,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'إضافة',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
