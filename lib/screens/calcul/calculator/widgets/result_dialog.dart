import 'package:flutter/material.dart';
import '../constants/calc_constants.dart';
import '../models/calculation_result.dart';

/// ===== Result Dialog Widget =====
/// A beautiful dialog showing calculation results
class ResultDialog extends StatelessWidget {
  final CalculationResult result;

  const ResultDialog({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: isDark ? CalcTheme.surfaceDark : CalcTheme.surfaceLight,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: CalcTheme.primaryStart.withValues(alpha: 0.3),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with gradient
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: CalcTheme.primaryGradient,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.calculate_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'نتيجة الحساب',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                        Text(
                          'التفاصيل الكاملة للأسعار',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Price breakdown
                    _buildPriceRow(
                      'سعر الفوتر',
                      result.footerPrice,
                      Icons.grid_view_rounded,
                      isDark,
                    ),
                    _buildPriceRow(
                      'سعر الروسول',
                      result.springsPrice,
                      Icons.waves_rounded,
                      isDark,
                    ),
                    _buildPriceRow(
                      'سعر الثوب',
                      result.dressPrice,
                      Icons.texture_rounded,
                      isDark,
                    ),
                    _buildPriceRow(
                      'سعر السفيفة',
                      result.sfifaPrice,
                      Icons.linear_scale_rounded,
                      isDark,
                    ),
                    _buildPriceRow(
                      'سعر التغليف',
                      result.packagingPrice,
                      Icons.inventory_2_rounded,
                      isDark,
                    ),
                    _buildPriceRow(
                      'التكاليف',
                      result.costPrice,
                      Icons.account_balance_wallet_rounded,
                      isDark,
                    ),
                    _buildPriceRow(
                      'سعر الإسفنج',
                      result.spongePrice,
                      Icons.layers_rounded,
                      isDark,
                    ),

                    const SizedBox(height: 16),
                    Divider(
                      color: (isDark ? Colors.white : Colors.black).withValues(
                        alpha: 0.1,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Final Total
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: CalcTheme.successGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.monetization_on_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'المجموع النهائي',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${result.finalPrice.ceil()} DH',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: CalcTheme.primaryStart,
                    backgroundColor: CalcTheme.primaryStart.withValues(
                      alpha: 0.1,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'موافق',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    double value,
    IconData icon,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: CalcTheme.primaryStart.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: CalcTheme.primaryStart, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isDark
                    ? CalcTheme.textSecondaryDark
                    : CalcTheme.textSecondaryLight,
                fontSize: 14,
                fontFamily: 'Tajawal',
              ),
            ),
          ),
          Text(
            '${value.toStringAsFixed(2)} DH',
            style: TextStyle(
              color: isDark
                  ? CalcTheme.textPrimaryDark
                  : CalcTheme.textPrimaryLight,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }
}
