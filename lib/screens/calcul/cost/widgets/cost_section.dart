import 'package:flutter/material.dart';
import '../../calculator/widgets/section_title.dart';

/// ===== Cost Section Widget =====
/// Reusable section container for cost groups
class CostSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const CostSection({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title: title, icon: icon),
          ...children,
        ],
      ),
    );
  }
}
