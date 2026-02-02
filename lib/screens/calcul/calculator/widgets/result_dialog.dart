import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../constants/calc_constants.dart';
import '../models/calculation_result.dart';
import '../../mattress_prices/service/tarif_api_service.dart';

/// ===== Result Dialog Widget =====
/// A beautiful dialog showing calculation results
class ResultDialog extends StatefulWidget {
  final CalculationResult result;
  final String mattressName;
  final String mattressSize;
  final bool isEditMode;
  final int? tarifId;

  const ResultDialog({
    super.key,
    required this.result,
    required this.mattressName,
    required this.mattressSize,
    this.isEditMode = false,
    this.tarifId,
  });

  @override
  State<ResultDialog> createState() => _ResultDialogState();
}

class _ResultDialogState extends State<ResultDialog> {
  bool _isSaving = false;
  bool _isSharing = false;
  final GlobalKey _repaintBoundaryKey = GlobalKey();

  Future<void> _saveOrUpdateTarif(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _isSaving = true);

    try {
      TarifApiResponse response;

      // Check for existing tarif if not in edit mode
      int? targetId = widget.tarifId;
      bool performUpdate = widget.isEditMode && widget.tarifId != null;

      if (!performUpdate) {
        // Fetch existing data to check for duplicates
        final checkResponse = await TarifApiService.fetchTarifDetails();
        if (checkResponse.success && checkResponse.data != null) {
          try {
            final existing = checkResponse.data!.firstWhere(
              (t) =>
                  t.name == widget.mattressName &&
                  t.size == widget.mattressSize,
            );
            // Found existing record! Switch to update mode
            targetId = existing.id;
            performUpdate = true;
          } catch (_) {
            // No duplicate found, proceed with create
          }
        }
      }

      if (performUpdate && targetId != null) {
        // وضع التعديل (أو التحديث التلقائي)
        response = await TarifApiService.updateTarif(
          id: targetId,
          name: widget.mattressName,
          size: widget.mattressSize,
          spongePrice: widget.result.spongePrice,
          springsPrice: widget.result.springsPrice,
          dressPrice: widget.result.dressPrice,
          sfifaPrice: widget.result.sfifaPrice,
          packagingPrice: widget.result.packagingPrice,
          footerPrice: widget.result.footerPrice,
          costPrice: widget.result.costPrice,
          profitPrice: widget.result.profitAmount,
          finalPrice: widget.result.finalPrice,
        );
      } else {
        // وضع الإنشاء
        response = await TarifApiService.saveTarif(
          name: widget.mattressName,
          size: widget.mattressSize,
          spongePrice: widget.result.spongePrice,
          springsPrice: widget.result.springsPrice,
          dressPrice: widget.result.dressPrice,
          sfifaPrice: widget.result.sfifaPrice,
          packagingPrice: widget.result.packagingPrice,
          footerPrice: widget.result.footerPrice,
          costPrice: widget.result.costPrice,
          profitPrice: widget.result.profitAmount,
          finalPrice: widget.result.finalPrice,
        );
      }

      if (mounted) {
        setState(() => _isSaving = false);

        if (response.success) {
          navigator.pop();
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(
                performUpdate
                    ? 'تم تحديث التسعيرة الموجودة بنجاح'
                    : 'تم حفظ التسعيرة الجديدة بنجاح',
                style: const TextStyle(fontFamily: 'Tajawal'),
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(
                response.message ?? 'فشل الحفظ',
                style: const TextStyle(fontFamily: 'Tajawal'),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              'خطأ: $e',
              style: const TextStyle(fontFamily: 'Tajawal'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _shareAsImage(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    setState(() => _isSharing = true);

    try {
      // إنشاء صورة من النتائج
      final boundary =
          _repaintBoundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary == null) {
        throw Exception('لا يمكن إنشاء الصورة');
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // حفظ الصورة مؤقتاً
      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/tarif_${widget.mattressName}_${widget.mattressSize.replaceAll('/', 'x')}.png',
      );
      await file.writeAsBytes(pngBytes);

      // مشاركة الصورة
      await Share.shareXFiles(
        [XFile(file.path)],
        text:
            'تسعيرة ${widget.mattressName} - المقاس: ${widget.mattressSize}\nالسعر النهائي: ${widget.result.finalPrice.ceil()} DH',
      );

      if (mounted) {
        setState(() => _isSharing = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSharing = false);
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              'فشل المشاركة: $e',
              style: const TextStyle(fontFamily: 'Tajawal'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final result = widget.result;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: RepaintBoundary(
        key: _repaintBoundaryKey,
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

                      if (result.profitMargin > 0) ...[
                        const SizedBox(height: 8),
                        Container(
                          height: 1,
                          color: Colors.grey.withValues(alpha: 0.2),
                        ),
                        const SizedBox(height: 8),
                        _buildPriceRow(
                          'هامش الربح (${result.profitMargin.toInt()}%)',
                          result.profitAmount,
                          Icons.trending_up_rounded,
                          isDark,
                          color: CalcTheme.success,
                        ),
                      ],

                      const SizedBox(height: 16),
                      Divider(
                        color: (isDark ? Colors.white : Colors.black)
                            .withValues(alpha: 0.1),
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

              // Footer Buttons
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    // Share Button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isSharing
                            ? null
                            : () => _shareAsImage(context),
                        icon: _isSharing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.share_rounded, size: 18),
                        label: Text(
                          _isSharing ? 'جاري...' : 'مشاركة',
                          style: const TextStyle(fontFamily: 'Tajawal'),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Save/Edit Button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isSaving
                            ? null
                            : () => _saveOrUpdateTarif(context),
                        icon: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                widget.isEditMode
                                    ? Icons.edit_rounded
                                    : Icons.save_rounded,
                                size: 18,
                              ),
                        label: Text(
                          _isSaving
                              ? (widget.isEditMode ? 'تعديل...' : 'حفظ...')
                              : (widget.isEditMode ? 'تعديل' : 'حفظ'),
                          style: const TextStyle(fontFamily: 'Tajawal'),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CalcTheme.primaryStart,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    double value,
    IconData icon,
    bool isDark, {
    Color? color,
  }) {
    final finalColor = color ?? CalcTheme.primaryStart;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: finalColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: finalColor, size: 18),
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
