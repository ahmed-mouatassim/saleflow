import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/calc_constants.dart';
import '../models/sponge_layer.dart';
import 'calc_text_field.dart';
import 'calc_dropdown.dart';

/// ===== Premium Sponge Layer Card Widget =====
/// A beautiful card displaying one sponge layer with all its inputs
class SpongeLayerCard extends StatefulWidget {
  final int index;
  final SpongeLayer layer;
  final ValueChanged<String?> onTypeChanged;
  final ValueChanged<double> onLayerCountChanged;
  final ValueChanged<double> onHeightChanged;
  final ValueChanged<double> onWidthChanged;
  final ValueChanged<double> onLengthChanged;
  final VoidCallback onDelete;
  final Map<String, int> spongeTypes;

  const SpongeLayerCard({
    super.key,
    required this.index,
    required this.layer,
    required this.onTypeChanged,
    required this.onLayerCountChanged,
    required this.onHeightChanged,
    required this.onWidthChanged,
    required this.onLengthChanged,
    required this.onDelete,
    required this.spongeTypes,
  });

  @override
  State<SpongeLayerCard> createState() => _SpongeLayerCardState();
}

class _SpongeLayerCardState extends State<SpongeLayerCard> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Static glow value instead of animated (prevents Windows accessibility errors)
    const double glowAlpha = 0.2;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  CalcTheme.cardDark.withValues(alpha: 0.8),
                  CalcTheme.surfaceDark.withValues(alpha: 0.6),
                ]
              : [
                  CalcTheme.surfaceLight.withValues(alpha: 0.95),
                  CalcTheme.cardLight.withValues(alpha: 0.8),
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.layer.isValid
              ? CalcTheme.success.withValues(alpha: 0.4)
              : CalcTheme.primaryMid.withValues(alpha: glowAlpha),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color:
                (widget.layer.isValid
                        ? CalcTheme.success
                        : CalcTheme.primaryStart)
                    .withValues(alpha: widget.layer.isValid ? 0.15 : 0.1),
            blurRadius: 25,
            spreadRadius: -5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            // Header Row with Gradient Background
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    CalcTheme.primaryStart.withValues(
                      alpha: isDark ? 0.15 : 0.08,
                    ),
                    CalcTheme.primaryEnd.withValues(alpha: isDark ? 0.1 : 0.05),
                  ],
                ),
              ),
              child: Row(
                children: [
                  // Layer indicator with glow
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: CalcTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: CalcTheme.primaryStart.withValues(alpha: 0.4),
                          blurRadius: 12,
                          spreadRadius: -2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${widget.index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          shadows: [
                            Shadow(color: Colors.black26, blurRadius: 4),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'طبقة الإسفنج ${widget.index + 1}',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? CalcTheme.textPrimaryDark
                                : CalcTheme.textPrimaryLight,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                        if (widget.layer.selectedType != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.layer.selectedType!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: CalcTheme.accent,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Expand/Collapse Button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: CalcTheme.primaryStart.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: AnimatedRotation(
                          turns: _isExpanded ? 0 : 0.5,
                          duration: const Duration(milliseconds: 200),
                          child: const Icon(
                            Icons.keyboard_arrow_up_rounded,
                            color: CalcTheme.primaryStart,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Delete button with animation
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        widget.onDelete();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              CalcTheme.error.withValues(alpha: 0.15),
                              CalcTheme.error.withValues(alpha: 0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: CalcTheme.error.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: CalcTheme.error,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Expandable Content
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 250),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // First Row: Type and Layer Count
                    Row(
                      children: [
                        Expanded(
                          child: CalcDropdown<String>(
                            label: 'النوع',
                            hint: 'اختر النوع',
                            value: widget.layer.selectedType,
                            items: widget.spongeTypes.keys.toList(),
                            itemLabel: (item) => item,
                            onChanged: widget.onTypeChanged,
                            prefixIcon: Icons.category_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CalcTextField(
                            label: 'عدد الطبقات',
                            hint: 'العدد',
                            initialValue: widget.layer.layerCount > 0
                                ? widget.layer.layerCount.toString()
                                : '',
                            prefixIcon: Icons.layers_rounded,
                            onChanged: (value) {
                              final parsed = double.tryParse(value) ?? 0;
                              widget.onLayerCountChanged(parsed);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Second Row: Dimensions
                    Row(
                      children: [
                        Expanded(
                          child: CalcTextField(
                            label: 'الطول',
                            hint: '0',
                            suffix: 'cm',
                            initialValue: widget.layer.height > 0
                                ? (widget.layer.height * 100).toStringAsFixed(0)
                                : '',
                            prefixIcon: Icons.straighten_rounded,
                            onChanged: (value) {
                              final parsed = double.tryParse(value) ?? 0;
                              widget.onHeightChanged(parsed / 100.0);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CalcTextField(
                            label: 'العرض',
                            hint: '0',
                            suffix: 'cm',
                            initialValue: widget.layer.width > 0
                                ? (widget.layer.width * 100).toStringAsFixed(0)
                                : '',
                            prefixIcon: Icons.swap_horiz_rounded,
                            onChanged: (value) {
                              final parsed = double.tryParse(value) ?? 0;
                              widget.onWidthChanged(parsed / 100.0);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CalcTextField(
                            label: 'الارتفاع',
                            hint: '0',
                            suffix: 'cm',
                            initialValue: widget.layer.length > 0
                                ? (widget.layer.length * 100).toStringAsFixed(0)
                                : '',
                            prefixIcon: Icons.height_rounded,
                            onChanged: (value) {
                              final parsed = double.tryParse(value) ?? 0;
                              widget.onLengthChanged(parsed / 100.0);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              secondChild: const SizedBox.shrink(),
            ),

            // Price preview (if valid)
            if (widget.layer.isValid)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [
                      CalcTheme.success.withValues(alpha: isDark ? 0.2 : 0.12),
                      CalcTheme.success.withValues(alpha: isDark ? 0.1 : 0.06),
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: CalcTheme.success.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: CalcTheme.success,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'السعر التقديري:',
                      style: TextStyle(
                        color: isDark
                            ? CalcTheme.textSecondaryDark
                            : CalcTheme.textSecondaryLight,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: CalcTheme.successGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: CalcTheme.success.withValues(alpha: 0.3),
                            blurRadius: 8,
                            spreadRadius: -2,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '${widget.layer.price.toStringAsFixed(2)} DH',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          fontFamily: 'Tajawal',
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
}
