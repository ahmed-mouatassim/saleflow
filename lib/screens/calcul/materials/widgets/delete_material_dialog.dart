import 'package:flutter/material.dart';
import '../../calculator/constants/calc_constants.dart';
import '../models/material_item.dart';

/// ===== Delete Material Dialog =====
/// حوار تأكيد حذف مادة
class DeleteMaterialDialog extends StatefulWidget {
  final MaterialItem item;
  final Future<bool> Function(MaterialItem item) onDelete;

  const DeleteMaterialDialog({
    super.key,
    required this.item,
    required this.onDelete,
  });

  @override
  State<DeleteMaterialDialog> createState() => _DeleteMaterialDialogState();

  static Future<bool?> show(
    BuildContext context, {
    required MaterialItem item,
    required Future<bool> Function(MaterialItem item) onDelete,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => DeleteMaterialDialog(item: item, onDelete: onDelete),
    );
  }
}

class _DeleteMaterialDialogState extends State<DeleteMaterialDialog> {
  bool _isLoading = false;

  Future<void> _handleDelete() async {
    setState(() => _isLoading = true);

    try {
      final success = await widget.onDelete(widget.item);
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
                  CalcTheme.error.withValues(alpha: 0.2),
                  CalcTheme.error.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.delete_rounded, color: CalcTheme.error, size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'تأكيد الحذف',
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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CalcTheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: CalcTheme.error.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getTypeIcon(widget.item.type),
                    color: Colors.white70,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.name,
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.item.typeLabel} • ${widget.item.price.toStringAsFixed(widget.item.price == widget.item.price.roundToDouble() ? 0 : 2)} ${widget.item.unitLabel}',
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 12,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Warning Text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.yellow.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.yellow.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 20,
                  color: Colors.yellow.shade600,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'سيتم حذف هذه المادة نهائياً من قاعدة البيانات.\nلا يمكن التراجع عن هذا الإجراء.',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 13,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
          onPressed: _isLoading ? null : _handleDelete,
          style: ElevatedButton.styleFrom(
            backgroundColor: CalcTheme.error,
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
                    Icon(Icons.delete_forever_rounded, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'حذف',
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

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'spongeTypes':
        return Icons.layers_rounded;
      case 'dressTypes':
        return Icons.texture_rounded;
      case 'footerTypes':
        return Icons.grid_view_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}
