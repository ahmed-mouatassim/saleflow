import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/calc_constants.dart';

/// ===== Product Name Selector Widget =====
/// A dropdown with option to add new product name
/// Features:
/// - Dropdown showing existing product names from API
/// - Option to add a new custom name
/// - Text field appears when "إضافة اسم جديد" is selected
class ProductNameSelector extends StatefulWidget {
  final List<String> productNames;
  final String? selectedName;
  final bool isCustomName;
  final bool isLoading;
  final ValueChanged<String?> onNameSelected;
  final ValueChanged<String> onCustomNameEntered;

  const ProductNameSelector({
    super.key,
    required this.productNames,
    this.selectedName,
    this.isCustomName = false,
    this.isLoading = false,
    required this.onNameSelected,
    required this.onCustomNameEntered,
  });

  @override
  State<ProductNameSelector> createState() => _ProductNameSelectorState();
}

class _ProductNameSelectorState extends State<ProductNameSelector> {
  final TextEditingController _customNameController = TextEditingController();
  bool _showCustomInput = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _showCustomInput = widget.isCustomName;
    if (widget.isCustomName && widget.selectedName != null) {
      _customNameController.text = widget.selectedName!;
    }
  }

  @override
  void didUpdateWidget(ProductNameSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCustomName != oldWidget.isCustomName) {
      _showCustomInput = widget.isCustomName;
    }
    if (widget.isCustomName && widget.selectedName != null) {
      if (_customNameController.text != widget.selectedName) {
        _customNameController.text = widget.selectedName!;
      }
    }
  }

  @override
  void dispose() {
    _customNameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(bottom: 8, right: 4),
          child: Row(
            children: [
              Icon(
                Icons.inventory_2_rounded,
                size: 16,
                color: CalcTheme.primaryStart,
              ),
              const SizedBox(width: 6),
              Text(
                'اسم المنتج',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? CalcTheme.textSecondaryDark
                      : CalcTheme.textSecondaryLight,
                  fontFamily: 'Tajawal',
                ),
              ),
            ],
          ),
        ),

        // Dropdown or Loading or Custom Input
        // Show custom input if:
        // 1. Explicitly showing custom input (_showCustomInput)
        // 2. Or selectedName exists but is not in the productNames list (custom name)
        if (widget.isLoading)
          _buildLoadingState(isDark)
        else if (_showCustomInput ||
            (widget.selectedName != null &&
                !widget.productNames.contains(widget.selectedName)))
          _buildCustomInput(isDark)
        else
          _buildDropdown(isDark),
      ],
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? CalcTheme.cardDark : CalcTheme.cardLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : CalcTheme.primaryStart.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(CalcTheme.primaryStart),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'جاري تحميل المنتجات...',
            style: TextStyle(
              color: isDark
                  ? CalcTheme.textSecondaryDark
                  : CalcTheme.textSecondaryLight,
              fontFamily: 'Tajawal',
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(bool isDark) {
    // Create items list with "Add New" option
    final items = <DropdownMenuItem<String>>[];

    // Add existing product names
    for (final name in widget.productNames) {
      items.add(
        DropdownMenuItem(
          value: name,
          child: Text(
            name,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 14,
              color: isDark
                  ? CalcTheme.textPrimaryDark
                  : CalcTheme.textPrimaryLight,
            ),
          ),
        ),
      );
    }

    // Add "Add New" option
    items.add(
      DropdownMenuItem(
        value: '__ADD_NEW__',
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: CalcTheme.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.add_rounded,
                size: 16,
                color: CalcTheme.success,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'إضافة اسم جديد',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 14,
                color: CalcTheme.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );

    // Only use selectedName if it exists in productNames, otherwise use null
    final validValue =
        widget.selectedName != null &&
            widget.productNames.contains(widget.selectedName)
        ? widget.selectedName
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? CalcTheme.cardDark : CalcTheme.cardLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: validValue != null
              ? CalcTheme.primaryStart.withValues(alpha: 0.5)
              : (isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : CalcTheme.primaryStart.withValues(alpha: 0.2)),
        ),
        boxShadow: validValue != null
            ? [
                BoxShadow(
                  color: CalcTheme.primaryStart.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: validValue,
          hint: Text(
            'اختر اسم المنتج',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 14,
              color: isDark
                  ? CalcTheme.textSecondaryDark
                  : CalcTheme.textSecondaryLight,
            ),
          ),
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: isDark
                ? CalcTheme.textSecondaryDark
                : CalcTheme.textSecondaryLight,
          ),
          dropdownColor: isDark ? CalcTheme.cardDark : CalcTheme.cardLight,
          borderRadius: BorderRadius.circular(14),
          items: items,
          onChanged: (value) {
            HapticFeedback.lightImpact();
            if (value == '__ADD_NEW__') {
              setState(() {
                _showCustomInput = true;
                _customNameController.clear();
              });
              // Focus the text field after switching
              Future.delayed(const Duration(milliseconds: 100), () {
                _focusNode.requestFocus();
              });
            } else {
              widget.onNameSelected(value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildCustomInput(bool isDark) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDark ? CalcTheme.cardDark : CalcTheme.cardLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: CalcTheme.success.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: CalcTheme.success.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _customNameController,
                  focusNode: _focusNode,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 14,
                    color: isDark
                        ? CalcTheme.textPrimaryDark
                        : CalcTheme.textPrimaryLight,
                  ),
                  decoration: InputDecoration(
                    hintText: 'أدخل اسم المنتج الجديد',
                    hintStyle: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 14,
                      color: isDark
                          ? CalcTheme.textSecondaryDark
                          : CalcTheme.textSecondaryLight,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onChanged: (value) {
                    widget.onCustomNameEntered(value);
                  },
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      widget.onCustomNameEntered(value.trim());
                    }
                  },
                ),
              ),
              // Cancel button
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _showCustomInput = false;
                    _customNameController.clear();
                  });
                  widget.onNameSelected(null);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    color: CalcTheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: CalcTheme.error,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
        // Back to dropdown button
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() {
              _showCustomInput = false;
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.arrow_back_rounded,
                size: 14,
                color: CalcTheme.primaryStart,
              ),
              const SizedBox(width: 4),
              Text(
                'العودة لقائمة المنتجات',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 12,
                  color: CalcTheme.primaryStart,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
