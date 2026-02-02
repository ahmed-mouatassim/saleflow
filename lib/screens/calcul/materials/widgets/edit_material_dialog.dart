import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../calculator/constants/calc_constants.dart';
import '../models/material_item.dart';

/// ===== Edit Material Dialog =====
/// حوار تعديل سعر مادة
class EditMaterialDialog extends StatefulWidget {
  final MaterialItem item;
  final Future<bool> Function(MaterialItem item, double newPrice) onUpdate;

  const EditMaterialDialog({
    super.key,
    required this.item,
    required this.onUpdate,
  });

  @override
  State<EditMaterialDialog> createState() => _EditMaterialDialogState();

  static Future<bool?> show(
    BuildContext context, {
    required MaterialItem item,
    required Future<bool> Function(MaterialItem item, double newPrice) onUpdate,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => EditMaterialDialog(item: item, onUpdate: onUpdate),
    );
  }
}

class _EditMaterialDialogState extends State<EditMaterialDialog> {
  late TextEditingController _priceController;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.item.price.toStringAsFixed(
        widget.item.price == widget.item.price.roundToDouble() ? 0 : 2,
      ),
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    final newPrice = double.tryParse(_priceController.text) ?? 0;

    setState(() => _isLoading = true);

    try {
      final success = await widget.onUpdate(widget.item, newPrice);
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
                  CalcTheme.warning.withValues(alpha: 0.2),
                  CalcTheme.warning.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.edit_rounded, color: CalcTheme.warning, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'تعديل السعر',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.item.name,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    color: CalcTheme.primaryStart,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Current Price Display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'السعر الحالي',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '${widget.item.price.toStringAsFixed(widget.item.price == widget.item.price.roundToDouble() ? 0 : 2)} ${widget.item.unitLabel}',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // New Price Input
            TextFormField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
              autofocus: true,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Tajawal',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                labelText: 'السعر الجديد',
                labelStyle: const TextStyle(
                  color: Colors.white70,
                  fontFamily: 'Tajawal',
                ),
                suffixText: widget.item.unitLabel,
                suffixStyle: const TextStyle(
                  color: Colors.white54,
                  fontFamily: 'Tajawal',
                  fontSize: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.white24),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: CalcTheme.warning, width: 2),
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'الرجاء إدخال السعر';
                }
                final price = double.tryParse(value);
                if (price == null || price < 0) {
                  return 'الرجاء إدخال سعر صحيح';
                }
                return null;
              },
            ),

            // Info about last edit
            if (widget.item.editedBy != null || widget.item.date != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: CalcTheme.primaryStart.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 14,
                      color: CalcTheme.primaryStart,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'آخر تعديل: ${widget.item.editedBy ?? '-'} • ${widget.item.date ?? '-'}',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 11,
                          color: CalcTheme.primaryStart,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
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
          onPressed: _isLoading ? null : _handleUpdate,
          style: ElevatedButton.styleFrom(
            backgroundColor: CalcTheme.warning,
            foregroundColor: Colors.black,
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
                    color: Colors.black,
                  ),
                )
              : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.save_rounded, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'حفظ',
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
