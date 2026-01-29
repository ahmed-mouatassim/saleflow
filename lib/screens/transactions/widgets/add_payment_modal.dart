import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/app_colors.dart';
import '../../../shared/widgets/glass_container.dart';
import '../model/transaction_model.dart';

/// Add Payment Modal
/// Modal dialog for registering a new payment
class AddPaymentModal extends StatefulWidget {
  final Function(Transaction) onSave;
  final VoidCallback onCancel;

  const AddPaymentModal({
    super.key,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<AddPaymentModal> createState() => _AddPaymentModalState();

  /// Show the modal as a dialog
  static Future<Transaction?> show(BuildContext context) async {
    return showDialog<Transaction>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: AddPaymentModal(
          onSave: (transaction) => Navigator.pop(context, transaction),
          onCancel: () => Navigator.pop(context),
        ),
      ),
    );
  }
}

class _AddPaymentModalState extends State<AddPaymentModal> {
  final _formKey = GlobalKey<FormState>();
  final _clientController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  String _paymentMethod = 'نقداً';

  final List<String> _paymentMethods = [
    'نقداً',
    'شيك',
    'تحويل بنكي',
    'بطاقة ائتمان',
  ];

  @override
  void dispose() {
    _clientController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final amount = double.tryParse(_amountController.text) ?? 0;
      final transaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch,
        reference:
            'PAY-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        clientId: 1,
        clientName: _clientController.text.trim(),
        date: DateTime.now(),
        amount: amount,
        amountPaid: amount,
        amountRemaining: 0,
        paymentMethod: _paymentMethod,
        createdAt: DateTime.now(),
      );
      widget.onSave(transaction);
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.emerald.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              LucideIcons.dollarSign,
                              size: 24,
                              color: AppColors.emerald,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            'تسجيل دفعة جديدة',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
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
                    controller: _clientController,
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
                    controller: _amountController,
                    label: 'المبلغ (د.م)',
                    icon: LucideIcons.dollarSign,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى إدخال المبلغ';
                      }
                      if (double.tryParse(value) == null) {
                        return 'يرجى إدخال مبلغ صحيح';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Payment Method Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.glassBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: DropdownButtonFormField<String>(
                      initialValue: _paymentMethod,
                      decoration: InputDecoration(
                        labelText: 'طريقة الدفع',
                        prefixIcon: Icon(LucideIcons.creditCard, size: 20),
                        border: InputBorder.none,
                      ),
                      dropdownColor: AppColors.glassDark,
                      borderRadius: BorderRadius.circular(16),
                      items: _paymentMethods.map((method) {
                        return DropdownMenuItem(
                          value: method,
                          child: Text(method),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _paymentMethod = value);
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _notesController,
                    label: 'ملاحظات (اختياري)',
                    icon: LucideIcons.fileText,
                    maxLines: 2,
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
                          label: const Text('تسجيل الدفعة'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.emerald,
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
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
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
          borderSide: BorderSide(color: AppColors.emerald, width: 2),
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
