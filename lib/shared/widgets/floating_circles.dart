import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

/// Floating Circles Background Widget
/// Creates animated gradient circles for a premium visual effect
/// Matches the React FloatingCircles component
class FloatingCircles extends StatefulWidget {
  const FloatingCircles({super.key});

  @override
  State<FloatingCircles> createState() => _FloatingCirclesState();
}

class _FloatingCirclesState extends State<FloatingCircles>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _bounceController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation controller
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Bounce animation controller
    _bounceController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: -20, end: 20).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          // Blue circle - Top Left
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Positioned(
                top: -60,
                left: -30,
                child: Opacity(
                  opacity: _pulseAnimation.value * 0.2,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primaryBlue.withValues(alpha: 0.3),
                          AppColors.primaryBlue.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Purple circle - Bottom Right
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Positioned(
                bottom: -80,
                right: -40,
                child: Opacity(
                  opacity: _pulseAnimation.value * 0.2,
                  child: Container(
                    width: 380,
                    height: 380,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primaryPurple.withValues(alpha: 0.3),
                          AppColors.primaryPurple.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Pink circle - Center Right (Bouncing)
          AnimatedBuilder(
            animation: _bounceAnimation,
            builder: (context, child) {
              return Positioned(
                top:
                    MediaQuery.of(context).size.height * 0.4 +
                    _bounceAnimation.value,
                right: 50,
                child: Opacity(
                  opacity: 0.1,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.pink.withValues(alpha: 0.3),
                          AppColors.pink.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Indigo circle - Bottom Left
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.2,
            left: 60,
            child: Opacity(
              opacity: 0.15,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryIndigo.withValues(alpha: 0.3),
                      AppColors.primaryIndigo.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
