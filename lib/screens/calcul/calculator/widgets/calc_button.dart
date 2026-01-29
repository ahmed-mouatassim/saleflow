import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/calc_constants.dart';

/// ===== Primary Button Widget =====
/// A gradient button with haptic feedback and animations
class CalcButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final LinearGradient? gradient;

  const CalcButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.gradient,
  });

  @override
  State<CalcButton> createState() => _CalcButtonState();
}

class _CalcButtonState extends State<CalcButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  void _handleTap() {
    if (widget.onPressed != null && !widget.isLoading) {
      HapticFeedback.lightImpact();
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient = widget.gradient ?? CalcTheme.primaryGradient;

    if (widget.isOutlined) {
      return _buildOutlinedButton(isDark);
    }

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: widget.isLoading ? null : gradient,
                color: widget.isLoading
                    ? CalcTheme.textSecondaryDark.withValues(alpha: 0.3)
                    : null,
                borderRadius: BorderRadius.circular(16),
                boxShadow: widget.isLoading
                    ? null
                    : [
                        BoxShadow(
                          color: CalcTheme.primaryStart.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
              ),
              child: Center(
                child: widget.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(widget.icon, color: Colors.white, size: 22),
                            const SizedBox(width: 10),
                          ],
                          Text(
                            widget.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOutlinedButton(bool isDark) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: CalcTheme.primaryStart, width: 2),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        color: CalcTheme.primaryStart,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                    ],
                    Text(
                      widget.label,
                      style: const TextStyle(
                        color: CalcTheme.primaryStart,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// ===== Icon Button with Animation =====
class CalcIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? backgroundColor;
  final double size;
  final String? tooltip;

  const CalcIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.backgroundColor,
    this.size = 44,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color:
            backgroundColor ??
            (isDark ? CalcTheme.cardDark : CalcTheme.cardLight).withValues(
              alpha: 0.5,
            ),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            if (onPressed != null) {
              HapticFeedback.lightImpact();
              onPressed!();
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(
              icon,
              color: color ?? CalcTheme.primaryStart,
              size: size * 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
