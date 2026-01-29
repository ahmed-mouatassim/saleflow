import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'provider/costs_provider.dart';
import 'constants/costs_constants.dart';
import 'widgets/summary_card.dart';
import 'widgets/cost_section.dart';
import '../calculator/widgets/calc_text_field.dart';

/// ===== Costs Screen =====
/// شاشة إعدادات التكاليف الثابتة
class CostsScreen extends StatefulWidget {
  final bool isEmbedded;

  const CostsScreen({super.key, this.isEmbedded = false});

  @override
  State<CostsScreen> createState() => _CostsScreenState();
}

class _CostsScreenState extends State<CostsScreen> {
  // مفتاح لإعادة بناء المحتوى عند إعادة التعيين
  int _resetKey = 0;

  void _onReset() {
    setState(() {
      _resetKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CostsProvider>(
      builder: (context, costs, child) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: const BoxDecoration(
              gradient: CostsTheme.backgroundGradient,
            ),
            child: SafeArea(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Header
                  if (!widget.isEmbedded)
                    SliverToBoxAdapter(child: _buildHeader(context)),

                  // Content - مفتاح يتغير عند إعادة التعيين
                  SliverToBoxAdapter(
                    key: ValueKey(_resetKey),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Summary Card
                          SummaryCard(
                            totalMonthlyCosts: costs.totalMonthlyCosts,
                            dailyCost: costs.dailyCost,
                            costPerUnit: costs.costPerUnit,
                          ),

                          const SizedBox(height: 24),

                          // Monthly Costs Section
                          _buildMonthlyCostsSection(costs),

                          // Packaging Section
                          _buildPackagingSection(costs),

                          // Sfifa Section
                          _buildSfifaSection(costs),

                          // Springs Section
                          _buildSpringsSection(costs),

                          const SizedBox(height: 24),

                          // Reset Button
                          _buildResetButton(context, costs),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // زر الرجوع
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // العنوان
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إعدادات التكاليف',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Tajawal',
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'التكاليف الثابتة المشتركة في الحسابات',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Tajawal',
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyCostsSection(CostsProvider costs) {
    return CostSection(
      title: 'التكاليف الشهرية',
      icon: Icons.account_balance_wallet_rounded,
      children: [
        Row(
          children: [
            Expanded(
              child: CalcTextField(
                label: 'الكراء',
                hint: 'مبلغ الكراء',
                initialValue: costs.rent.toString(),
                prefixIcon: Icons.home_rounded,
                onChanged: (value) {
                  costs.setRent(double.tryParse(value) ?? 0);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CalcTextField(
                label: 'الموظفين',
                hint: 'رواتب الموظفين',
                initialValue: costs.employees.toString(),
                prefixIcon: Icons.people_rounded,
                onChanged: (value) {
                  costs.setEmployees(double.tryParse(value) ?? 0);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CalcTextField(
                label: 'الديزل',
                hint: 'تكلفة الديزل',
                initialValue: costs.diesel.toString(),
                prefixIcon: Icons.local_gas_station_rounded,
                onChanged: (value) {
                  costs.setDiesel(double.tryParse(value) ?? 0);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CalcTextField(
                label: 'CNSS',
                hint: 'الضمان الاجتماعي',
                initialValue: costs.cnss.toString(),
                prefixIcon: Icons.security_rounded,
                onChanged: (value) {
                  costs.setCnss(double.tryParse(value) ?? 0);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CalcTextField(
                label: 'TVA',
                hint: 'الضريبة',
                initialValue: costs.tva.toString(),
                prefixIcon: Icons.receipt_long_rounded,
                onChanged: (value) {
                  costs.setTva(double.tryParse(value) ?? 0);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CalcTextField(
                label: 'الكهرباء',
                hint: 'فاتورة الكهرباء',
                initialValue: costs.electricity.toString(),
                prefixIcon: Icons.electric_bolt_rounded,
                onChanged: (value) {
                  costs.setElectricity(double.tryParse(value) ?? 0);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CalcTextField(
                label: 'الهاتف',
                hint: 'فاتورة الهاتف',
                initialValue: costs.phone.toString(),
                prefixIcon: Icons.phone_rounded,
                onChanged: (value) {
                  costs.setPhone(double.tryParse(value) ?? 0);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CalcTextField(
                label: 'المكتب',
                hint: 'مصاريف المكتب',
                initialValue: costs.desktop.toString(),
                prefixIcon: Icons.desktop_windows_rounded,
                onChanged: (value) {
                  costs.setDesktop(double.tryParse(value) ?? 0);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CalcTextField(
                label: 'صيانة الآلات',
                hint: 'تكلفة الصيانة',
                initialValue: costs.machineFix.toString(),
                prefixIcon: Icons.build_rounded,
                onChanged: (value) {
                  costs.setMachineFix(double.tryParse(value) ?? 0);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CalcTextField(
                label: 'الإصلاحات',
                hint: 'مصاريف الإصلاح',
                initialValue: costs.repairs.toString(),
                prefixIcon: Icons.handyman_rounded,
                onChanged: (value) {
                  costs.setRepairs(double.tryParse(value) ?? 0);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        CalcTextField(
          label: 'الإنتاج اليومي',
          hint: 'عدد الوحدات المنتجة يومياً',
          initialValue: costs.production.toString(),
          prefixIcon: Icons.factory_rounded,
          onChanged: (value) {
            costs.setProduction(int.tryParse(value) ?? 1);
          },
        ),
      ],
    );
  }

  Widget _buildPackagingSection(CostsProvider costs) {
    return CostSection(
      title: 'التغليف',
      icon: Icons.inventory_2_rounded,
      children: [
        Row(
          children: [
            Expanded(
              child: CalcTextField(
                label: 'الزوايا',
                hint: 'سعر الوحدة',
                initialValue: costs.corners.toString(),
                onChanged: (value) {
                  costs.setCorners(double.tryParse(value) ?? 0);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CalcTextField(
                label: 'التذاكر',
                hint: 'سعر الوحدة',
                initialValue: costs.tickets.toString(),
                onChanged: (value) {
                  costs.setTickets(double.tryParse(value) ?? 0);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CalcTextField(
                label: 'الطبقة الكبيرة',
                hint: 'سعر الوحدة',
                initialValue: costs.largeFlyer.toString(),
                onChanged: (value) {
                  costs.setLargeFlyer(double.tryParse(value) ?? 0);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CalcTextField(
                label: 'الطبقة الصغيرة',
                hint: 'سعر الوحدة',
                initialValue: costs.smallFlyer.toString(),
                onChanged: (value) {
                  costs.setSmallFlyer(double.tryParse(value) ?? 0);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CalcTextField(
                label: 'البلاستيك',
                hint: 'سعر الوحدة',
                initialValue: costs.plastic.toString(),
                onChanged: (value) {
                  costs.setPlastic(double.tryParse(value) ?? 0);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CalcTextField(
                label: 'السكوتش',
                hint: 'سعر الوحدة',
                initialValue: costs.scotch.toString(),
                onChanged: (value) {
                  costs.setScotch(double.tryParse(value) ?? 0);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CalcTextField(
                label: 'الغراء',
                hint: 'سعر الوحدة',
                initialValue: costs.glue.toString(),
                onChanged: (value) {
                  costs.setGlue(double.tryParse(value) ?? 0);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CalcTextField(
                label: 'الإضافات',
                hint: 'مصاريف إضافية',
                initialValue: costs.adding.toString(),
                onChanged: (value) {
                  costs.setAdding(double.tryParse(value) ?? 0);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSfifaSection(CostsProvider costs) {
    return CostSection(
      title: 'السفيفة',
      icon: Icons.linear_scale_rounded,
      children: [
        Row(
          children: [
            Expanded(
              child: CalcTextField(
                label: 'شريط 36mm',
                hint: 'سعر المتر',
                initialValue: costs.ribbon36mmPrice.toString(),
                onChanged: (value) {
                  costs.setRibbon36mmPrice(double.tryParse(value) ?? 0);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CalcTextField(
                label: 'شريط 18mm',
                hint: 'سعر المتر',
                initialValue: costs.ribbon18mmPrice.toString(),
                onChanged: (value) {
                  costs.setRibbon18mmPrice(double.tryParse(value) ?? 0);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CalcTextField(
                label: 'شريط 3D',
                hint: 'سعر المتر',
                initialValue: costs.ribbon3DPrice.toString(),
                onChanged: (value) {
                  costs.setRibbon3DPrice(double.tryParse(value) ?? 0);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CalcTextField(
                label: 'السلسلة',
                hint: 'سعر السلسلة',
                initialValue: costs.chainPrice.toString(),
                onChanged: (value) {
                  costs.setChainPrice(double.tryParse(value) ?? 0);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CalcTextField(
                label: 'المطاط',
                hint: 'سعر المتر',
                initialValue: costs.elasticPrice.toString(),
                onChanged: (value) {
                  costs.setElasticPrice(double.tryParse(value) ?? 0);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSpringsSection(CostsProvider costs) {
    return CostSection(
      title: 'الروسول',
      icon: Icons.waves_rounded,
      children: [
        Row(
          children: [
            Expanded(
              child: CalcTextField(
                label: 'روسول عادي',
                hint: 'سعر الوحدة',
                initialValue: costs.springValue.toString(),
                prefixIcon: Icons.attach_money_rounded,
                onChanged: (value) {
                  costs.setSpringValue(
                    double.tryParse(value) ?? CostsConstants.defaultSpringValue,
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CalcTextField(
                label: 'روسول En Sachet',
                hint: 'سعر الوحدة',
                initialValue: costs.springSachetValue.toString(),
                prefixIcon: Icons.attach_money_rounded,
                onChanged: (value) {
                  costs.setSpringSachetValue(
                    double.tryParse(value) ??
                        CostsConstants.defaultSpringSachetValue,
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResetButton(BuildContext context, CostsProvider costs) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(Icons.refresh_rounded, color: Colors.orange, size: 28),
                SizedBox(width: 12),
                Text(
                  'إعادة تعيين',
                  style: TextStyle(fontFamily: 'Tajawal', color: Colors.white),
                ),
              ],
            ),
            content: const Text(
              'هل تريد إعادة تعيين جميع التكاليف إلى القيم الافتراضية؟',
              style: TextStyle(fontFamily: 'Tajawal', color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'إلغاء',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    color: Colors.white54,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  costs.resetToDefaults();
                  Navigator.pop(context);
                  _onReset(); // إعادة بناء الواجهة بالقيم الجديدة
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'إعادة تعيين',
                  style: TextStyle(fontFamily: 'Tajawal', color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orange, width: 2),
          color: Colors.orange.withValues(alpha: 0.1),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.refresh_rounded, color: Colors.orange, size: 24),
            SizedBox(width: 12),
            Text(
              'إعادة تعيين للافتراضي',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
