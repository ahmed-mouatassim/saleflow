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
  final int _resetKey = 0;

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

                          // Sponge Types Section
                          _buildSpongeTypesSection(costs),

                          // Dress Types Section
                          _buildDressTypesSection(costs),

                          // Footer Types Section
                          _buildFooterTypesSection(costs),

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
                label: 'الماء',
                hint: 'فاتورة الماء',
                initialValue: costs.water.toString(),
                prefixIcon: Icons.water_drop_rounded,
                onChanged: (value) {
                  costs.setWater(double.tryParse(value) ?? 0);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CalcTextField(
                label: 'الأنترنت',
                hint: 'اشتراك النت',
                initialValue: costs.internet.toString(),
                prefixIcon: Icons.wifi_rounded,
                onChanged: (value) {
                  costs.setInternet(double.tryParse(value) ?? 0);
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
                label: 'النقل',
                hint: 'مصاريف النقل',
                initialValue: costs.transport.toString(),
                prefixIcon: Icons.local_shipping_rounded,
                onChanged: (value) {
                  costs.setTransport(double.tryParse(value) ?? 0);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CalcTextField(
                label: 'التسويق',
                hint: 'إعلانات/تسويق',
                initialValue: costs.marketing.toString(),
                prefixIcon: Icons.campaign_rounded,
                onChanged: (value) {
                  costs.setMarketing(double.tryParse(value) ?? 0);
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
                label: 'الصيانة',
                hint: 'صيانة وإصلاح',
                initialValue: costs.maintenance.toString(),
                prefixIcon: Icons.build_rounded,
                onChanged: (value) {
                  costs.setMaintenance(double.tryParse(value) ?? 0);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CalcTextField(
                label: 'أخرى',
                hint: 'مصاريف متنوعة',
                initialValue: costs.otherMonthly.toString(),
                prefixIcon: Icons.more_horiz_rounded,
                onChanged: (value) {
                  costs.setOtherMonthly(double.tryParse(value) ?? 0);
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
                label: 'البلاستيك',
                hint: 'سعر الوحدة',
                initialValue: costs.plastic.toString(),
                onChanged: (value) {
                  costs.setPlastic(double.tryParse(value) ?? 0);
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
                label: 'السكوتش',
                hint: 'شريط لاصق',
                initialValue: costs.scotch.toString(),
                onChanged: (value) {
                  costs.setScotch(double.tryParse(value) ?? 0);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CalcTextField(
                label: 'أخرى',
                hint: 'تغليف آخر',
                initialValue: costs.otherPackaging.toString(),
                onChanged: (value) {
                  costs.setOtherPackaging(double.tryParse(value) ?? 0);
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
            const SizedBox(width: 12),
            Expanded(
              child: CalcTextField(
                label: 'الخيط',
                hint: 'سعر الخيط',
                initialValue: costs.threadPrice.toString(),
                onChanged: (value) {
                  costs.setThreadPrice(double.tryParse(value) ?? 0);
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
          ],
        ),
      ],
    );
  }

  Widget _buildSpongeTypesSection(CostsProvider costs) {
    if (costs.spongeTypes.isEmpty) return const SizedBox.shrink();

    final entries = costs.spongeTypes.entries.toList();
    final List<Widget> rows = [];

    // Build rows with 3 items each
    for (int i = 0; i < entries.length; i += 3) {
      final rowItems = entries.skip(i).take(3).toList();
      rows.add(
        Row(
          children: rowItems.asMap().entries.map((mapEntry) {
            final index = mapEntry.key;
            final entry = mapEntry.value;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: index < rowItems.length - 1 ? 8 : 0,
                ),
                child: CalcTextField(
                  label: entry.key,
                  hint: 'سعر الكيلو',
                  initialValue: entry.value.toString(),
                  onChanged: (value) {
                    costs.setSpongeTypePrice(
                      entry.key,
                      double.tryParse(value) ?? 0,
                    );
                  },
                ),
              ),
            );
          }).toList(),
        ),
      );
      if (i + 3 < entries.length) {
        rows.add(const SizedBox(height: 12));
      }
    }

    return CostSection(
      title: 'أنواع الإسفنج',
      icon: Icons.layers_rounded,
      children: rows,
    );
  }

  Widget _buildDressTypesSection(CostsProvider costs) {
    if (costs.dressTypes.isEmpty) return const SizedBox.shrink();

    final entries = costs.dressTypes.entries.toList();
    final List<Widget> rows = [];

    // Build rows with 3 items each
    for (int i = 0; i < entries.length; i += 3) {
      final rowItems = entries.skip(i).take(3).toList();
      rows.add(
        Row(
          children: rowItems.asMap().entries.map((mapEntry) {
            final index = mapEntry.key;
            final entry = mapEntry.value;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: index < rowItems.length - 1 ? 8 : 0,
                ),
                child: CalcTextField(
                  label: entry.key,
                  hint: 'سعر المتر',
                  initialValue: entry.value.toString(),
                  onChanged: (value) {
                    costs.setDressTypePrice(
                      entry.key,
                      double.tryParse(value) ?? 0,
                    );
                  },
                ),
              ),
            );
          }).toList(),
        ),
      );
      if (i + 3 < entries.length) {
        rows.add(const SizedBox(height: 12));
      }
    }

    return CostSection(
      title: 'أنواع الثوب',
      icon: Icons.texture_rounded,
      children: rows,
    );
  }

  Widget _buildFooterTypesSection(CostsProvider costs) {
    if (costs.footerTypes.isEmpty) return const SizedBox.shrink();

    final entries = costs.footerTypes.entries.toList();
    final List<Widget> rows = [];

    // Build rows with 3 items each
    for (int i = 0; i < entries.length; i += 3) {
      final rowItems = entries.skip(i).take(3).toList();
      rows.add(
        Row(
          children: rowItems.asMap().entries.map((mapEntry) {
            final index = mapEntry.key;
            final entry = mapEntry.value;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: index < rowItems.length - 1 ? 8 : 0,
                ),
                child: CalcTextField(
                  label: entry.key,
                  hint: 'سعر الوحدة',
                  initialValue: entry.value.toString(),
                  onChanged: (value) {
                    costs.setFooterTypePrice(
                      entry.key,
                      double.tryParse(value) ?? 0,
                    );
                  },
                ),
              ),
            );
          }).toList(),
        ),
      );
      if (i + 3 < entries.length) {
        rows.add(const SizedBox(height: 12));
      }
    }

    return CostSection(
      title: 'أنواع الفوتر',
      icon: Icons.grid_view_rounded,
      children: rows,
    );
  }
}
