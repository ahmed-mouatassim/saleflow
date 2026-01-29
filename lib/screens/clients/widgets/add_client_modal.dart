import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/app_colors.dart';
import '../../../shared/widgets/glass_container.dart';
import '../model/client_model.dart';

/// Add Client Modal
/// Modal dialog for adding a new client
class AddClientModal extends StatefulWidget {
  final Function(Client) onSave;
  final VoidCallback onCancel;

  const AddClientModal({
    super.key,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<AddClientModal> createState() => _AddClientModalState();

  /// Show the modal as a dialog
  static Future<Client?> show(BuildContext context) async {
    return showDialog<Client>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: AddClientModal(
          onSave: (client) => Navigator.pop(context, client),
          onCancel: () => Navigator.pop(context),
        ),
      ),
    );
  }
}

class _AddClientModalState extends State<AddClientModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _limitController = TextEditingController(text: '0');
  bool _isActive = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final client = Client(
        id: DateTime.now().millisecondsSinceEpoch,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        limitPrice: double.tryParse(_limitController.text) ?? 0,
        totalAmount: 0,
        amountPaid: 0,
        amountRemaining: 0,
        isActive: _isActive,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      widget.onSave(client);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Center(
      child: SingleChildScrollView(
        child: Container(
          width: isMobile ? screenWidth * 0.95 : 500,
          margin: const EdgeInsets.all(16),
          child: GlassContainer(
            isDark: true,
            borderRadius: isMobile ? 28 : 40,
            padding: EdgeInsets.all(isMobile ? 24 : 32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                LucideIcons.userPlus,
                                size: 24,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Flexible(
                              child: Text(
                                'إضافة عميل جديد',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: widget.onCancel,
                        icon: const Icon(LucideIcons.x),
                        color: AppColors.textMuted,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Form Fields
                  _buildTextField(
                    controller: _nameController,
                    label: 'اسم العميل',
                    icon: LucideIcons.user,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى إدخال اسم العميل';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _phoneController,
                    label: 'رقم الهاتف',
                    icon: LucideIcons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى إدخال رقم الهاتف';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _addressController,
                    label: 'العنوان / المدينة',
                    icon: LucideIcons.mapPin,
                  ),

                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _limitController,
                    label: 'حد الائتمان (د.م)',
                    icon: LucideIcons.dollarSign,
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 24),

                  // Active Toggle
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.glassBackground,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.glassDark,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            LucideIcons.toggleLeft,
                            size: 20,
                            color: _isActive
                                ? AppColors.emerald
                                : AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'حالة العميل',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                _isActive ? 'نشط' : 'غير نشط',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _isActive
                                      ? AppColors.emerald
                                      : AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _isActive,
                          onChanged: (value) =>
                              setState(() => _isActive = value),
                          thumbColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.selected)) {
                              return AppColors.emerald;
                            }
                            return null;
                          }),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: widget.onCancel,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            side: BorderSide(color: AppColors.glassBorder),
                          ),
                          child: const Text('إلغاء'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _submit,
                          icon: const Icon(LucideIcons.check, size: 18),
                          label: const Text('حفظ العميل'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Icon(icon, size: 20),
        ),
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
          borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.red),
        ),
        filled: true,
        fillColor: AppColors.glassBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
    );
  }
}
