import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/app_colors.dart';
import '../model/supplier_model.dart';

/// Add/Edit Supplier Modal
/// Modal dialog for adding or editing supplier information
class AddSupplierModal extends StatefulWidget {
  final Supplier? supplier; // null for add, existing for edit
  final Function(Supplier) onSave;

  const AddSupplierModal({super.key, this.supplier, required this.onSave});

  /// Show the modal
  static Future<Supplier?> show(BuildContext context, [Supplier? supplier]) {
    return showDialog<Supplier>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddSupplierModal(
        supplier: supplier,
        onSave: (s) => Navigator.of(context).pop(s),
      ),
    );
  }

  @override
  State<AddSupplierModal> createState() => _AddSupplierModalState();
}

class _AddSupplierModalState extends State<AddSupplierModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  String _category = 'عام';

  final List<String> _categories = [
    'عام',
    'مواد خام معدنية',
    'مواد بلاستيكية',
    'ألمنيوم',
    'مواد كيميائية',
    'أخشاب',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.supplier?.name ?? '');
    _phoneController = TextEditingController(
      text: widget.supplier?.phone ?? '',
    );
    _emailController = TextEditingController(
      text: widget.supplier?.email ?? '',
    );
    _addressController = TextEditingController(
      text: widget.supplier?.address ?? '',
    );
    _cityController = TextEditingController(text: widget.supplier?.city ?? '');
    _category = widget.supplier?.category ?? 'عام';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final supplier = Supplier(
        id: widget.supplier?.id ?? 0,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        category: _category,
        totalPurchases: widget.supplier?.totalPurchases ?? 0.0,
        totalPaid: widget.supplier?.totalPaid ?? 0.0,
        amountOwed: widget.supplier?.amountOwed ?? 0.0,
        isActive: widget.supplier?.isActive ?? true,
        createdAt: widget.supplier?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      widget.onSave(supplier);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.supplier != null;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 700),
        decoration: BoxDecoration(
          color: AppColors.glassDark,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 30,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.glassBackground,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                border: Border(
                  bottom: BorderSide(color: AppColors.glassBorder),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.amber,
                          AppColors.amber.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      LucideIcons.truck,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing ? 'تعديل المورد' : 'إضافة مورد جديد',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          isEditing
                              ? 'تحديث بيانات المورد'
                              : 'أدخل بيانات المورد الجديد',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(LucideIcons.x, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),

            // Form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Name
                      _buildTextField(
                        controller: _nameController,
                        label: 'اسم المورد',
                        icon: LucideIcons.building,
                        validator: (v) => v?.isEmpty == true
                            ? 'الرجاء إدخال اسم المورد'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Category
                      _buildDropdown(
                        label: 'تصنيف المواد',
                        value: _category,
                        items: _categories,
                        icon: LucideIcons.tag,
                        onChanged: (v) => setState(() => _category = v!),
                      ),
                      const SizedBox(height: 16),

                      // Phone
                      _buildTextField(
                        controller: _phoneController,
                        label: 'رقم الهاتف',
                        icon: LucideIcons.phone,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),

                      // Email
                      _buildTextField(
                        controller: _emailController,
                        label: 'البريد الإلكتروني',
                        icon: LucideIcons.mail,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      // City
                      _buildTextField(
                        controller: _cityController,
                        label: 'المدينة',
                        icon: LucideIcons.mapPin,
                      ),
                      const SizedBox(height: 16),

                      // Address
                      _buildTextField(
                        controller: _addressController,
                        label: 'العنوان',
                        icon: LucideIcons.home,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.glassBackground,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
                border: Border(top: BorderSide(color: AppColors.glassBorder)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: AppColors.glassBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'إلغاء',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _submit,
                      icon: Icon(
                        isEditing ? LucideIcons.save : LucideIcons.plus,
                      ),
                      label: Text(isEditing ? 'حفظ التعديلات' : 'إضافة المورد'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.amber,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textMuted),
        prefixIcon: Icon(icon, color: AppColors.amber),
        filled: true,
        fillColor: AppColors.glassBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.amber),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textMuted),
        prefixIcon: Icon(icon, color: AppColors.amber),
        filled: true,
        fillColor: AppColors.glassBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.amber),
        ),
      ),
      dropdownColor: AppColors.glassDark,
      style: const TextStyle(color: AppColors.textPrimary),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
    );
  }
}
