import 'package:flutter/material.dart';

/// ===== Summary Card Widget =====
/// Displays cost summary with total monthly, daily, and per unit costs
class SummaryCard extends StatelessWidget {
  final double totalMonthlyCosts;
  final double dailyCost;
  final double costPerUnit;

  const SummaryCard({
    super.key,
    required this.totalMonthlyCosts,
    required this.dailyCost,
    required this.costPerUnit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.analytics_rounded, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Text(
                'ملخص التكاليف',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Tajawal',
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'التكاليف الشهرية',
                  '${totalMonthlyCosts.toStringAsFixed(0)} درهم',
                  Icons.calendar_month_rounded,
                ),
              ),
              Container(width: 1, height: 60, color: Colors.white24),
              Expanded(
                child: _buildSummaryItem(
                  'التكلفة اليومية',
                  '${dailyCost.toStringAsFixed(2)} درهم',
                  Icons.today_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.inventory_2_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'التكلفة لكل وحدة: ${costPerUnit.toStringAsFixed(2)} درهم',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Tajawal',
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontFamily: 'Tajawal',
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Tajawal',
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
