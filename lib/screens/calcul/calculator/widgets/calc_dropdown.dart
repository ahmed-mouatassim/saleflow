import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/calc_constants.dart';

/// ===== Premium Styled Dropdown Widget =====
/// A modern dropdown with Glassmorphism styling and animations
class CalcDropdown<T> extends StatefulWidget {
  final String label;
  final String hint;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?>? onChanged;
  final bool enabled;
  final IconData? prefixIcon;

  const CalcDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.items,
    required this.itemLabel,
    this.value,
    this.onChanged,
    this.enabled = true,
    this.prefixIcon,
  });

  @override
  State<CalcDropdown<T>> createState() => _CalcDropdownState<T>();
}

class _CalcDropdownState<T> extends State<CalcDropdown<T>> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: CalcTheme.primaryStart.withValues(alpha: 0.25),
                  blurRadius: 15,
                  spreadRadius: -2,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Focus(
        onFocusChange: (hasFocus) {
          setState(() {
            _isFocused = hasFocus;
          });
        },
        child: DropdownButtonFormField<T>(
          initialValue: widget.value,
          items: widget.items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                widget.itemLabel(item),
                style: TextStyle(
                  color: isDark
                      ? CalcTheme.textPrimaryDark
                      : CalcTheme.textPrimaryLight,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  fontFamily: 'Tajawal',
                ),
              ),
            );
          }).toList(),
          onChanged: widget.enabled
              ? (value) {
                  HapticFeedback.selectionClick();
                  widget.onChanged?.call(value);
                }
              : null,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon != null
                ? Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          CalcTheme.primaryStart.withValues(
                            alpha: _isFocused ? 0.2 : 0.1,
                          ),
                          CalcTheme.primaryEnd.withValues(
                            alpha: _isFocused ? 0.15 : 0.05,
                          ),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      widget.prefixIcon,
                      color: _isFocused
                          ? CalcTheme.primaryStart
                          : CalcTheme.textSecondaryDark,
                      size: 18,
                    ),
                  )
                : null,
            labelStyle: TextStyle(
              color: _isFocused
                  ? CalcTheme.primaryStart
                  : (isDark
                        ? CalcTheme.textSecondaryDark
                        : CalcTheme.textSecondaryLight),
              fontWeight: FontWeight.w500,
              fontFamily: 'Tajawal',
            ),
            hintStyle: TextStyle(
              color:
                  (isDark
                          ? CalcTheme.textSecondaryDark
                          : CalcTheme.textSecondaryLight)
                      .withValues(alpha: 0.5),
              fontFamily: 'Tajawal',
            ),
            filled: true,
            fillColor: isDark
                ? CalcTheme.cardDark.withValues(alpha: _isFocused ? 0.8 : 0.5)
                : CalcTheme.cardLight.withValues(
                    alpha: _isFocused ? 0.95 : 0.7,
                  ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: (isDark ? CalcTheme.primaryMid : CalcTheme.primaryStart)
                    .withValues(alpha: 0.15),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: CalcTheme.primaryStart, width: 2),
            ),
          ),
          dropdownColor: isDark
              ? CalcTheme.surfaceDark
              : CalcTheme.surfaceLight,
          icon: AnimatedRotation(
            turns: _isFocused ? 0.5 : 0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: CalcTheme.primaryStart.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: CalcTheme.primaryStart,
                size: 20,
              ),
            ),
          ),
          borderRadius: BorderRadius.circular(16),
          menuMaxHeight: 300,
          elevation: 8,
        ),
      ),
    );
  }
}
