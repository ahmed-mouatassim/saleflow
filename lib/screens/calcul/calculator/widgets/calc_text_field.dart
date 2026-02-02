import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/calc_constants.dart';

/// ===== Premium Styled Text Field Widget =====
/// A modern, reusable text field with Glassmorphism and glow effects
class CalcTextField extends StatefulWidget {
  final String label;
  final String hint;
  final String? initialValue;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final TextEditingController? controller;
  final String? suffix;
  final List<TextInputFormatter>? inputFormatters;

  const CalcTextField({
    super.key,
    required this.label,
    required this.hint,
    this.initialValue,
    this.keyboardType = const TextInputType.numberWithOptions(decimal: true),
    this.prefixIcon,
    this.onChanged,
    this.enabled = true,
    this.controller,
    this.suffix,
    this.inputFormatters,
  });

  @override
  State<CalcTextField> createState() => _CalcTextFieldState();
}

class _CalcTextFieldState extends State<CalcTextField> {
  bool _isFocused = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

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
      child: TextFormField(
        focusNode: _focusNode,
        controller: widget.controller,
        initialValue: widget.controller == null ? widget.initialValue : null,
        keyboardType: widget.keyboardType,
        enabled: widget.enabled,
        style: TextStyle(
          color: isDark
              ? CalcTheme.textPrimaryDark
              : CalcTheme.textPrimaryLight,
          fontWeight: FontWeight.w600,
          fontSize: 15,
          fontFamily: 'Tajawal',
        ),
        inputFormatters:
            widget.inputFormatters ??
            (widget.keyboardType == TextInputType.number ||
                    widget.keyboardType ==
                        const TextInputType.numberWithOptions(decimal: true)
                ? [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      final newString = newValue.text.replaceAll(',', '.');
                      return newValue.copyWith(
                        text: newString,
                        selection: newValue.selection,
                      );
                    }),
                  ]
                : null),
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          suffixText: widget.suffix,
          suffixStyle: const TextStyle(
            color: CalcTheme.textSecondaryDark,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
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
              : CalcTheme.cardLight.withValues(alpha: _isFocused ? 0.95 : 0.7),
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
            borderSide: const BorderSide(
              color: CalcTheme.primaryStart,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: CalcTheme.error, width: 1.5),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}
