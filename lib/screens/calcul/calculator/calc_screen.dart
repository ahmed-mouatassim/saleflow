import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'provider/calculator_provider.dart';
import 'provider/calc_data_provider.dart';
import 'constants/calc_constants.dart';
import 'widgets/calc_button.dart';
import 'widgets/calc_dropdown.dart';
import 'widgets/calc_text_field.dart';
import 'widgets/product_name_selector.dart';
import 'widgets/result_dialog.dart';
import 'widgets/section_title.dart';
import 'widgets/sponge_layer_card.dart';

/// ===== Calculator Screen =====
/// Modern price calculator with Glassmorphism design
/// Uses Provider for state management
class CalcScreen extends StatelessWidget {
  final bool isEmbedded;

  const CalcScreen({super.key, this.isEmbedded = false});

  @override
  Widget build(BuildContext context) {
    return _CalcScreenContent(isEmbedded: isEmbedded);
  }
}

class _CalcScreenContent extends StatelessWidget {
  final bool isEmbedded;

  const _CalcScreenContent({this.isEmbedded = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<CalculatorProvider>();
    // Watch CalcDataProvider to rebuild when API data loads (sponge/dress types)
    final dataProvider = context.watch<CalcDataProvider>();
    // Debug: Show loading state
    if (dataProvider.isLoading) {
      debugPrint('CalcScreen: Loading data from API...');
    }

    return Scaffold(
      backgroundColor: Colors.transparent, // Backed by home background
      body: Stack(
        children: [
          // Main content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ===== Content with rounded top corners =====
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.only(top: 0),
                  decoration: BoxDecoration(
                    color: isDark
                        ? CalcTheme.backgroundDark
                        : CalcTheme.backgroundLight,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // ===== Basic Dimensions Section =====
                        _buildBasicDimensionsSection(context, provider, isDark),

                        // ===== Sponge Layers Section =====
                        _buildSpongeLayersSection(context, provider, isDark),

                        // ===== Footer Section =====
                        _buildFooterSection(context, provider, isDark),

                        // ===== Dress Section =====
                        _buildDressSection(context, provider, isDark),

                        // ===== Springs Section =====
                        _buildSpringsSection(context, provider, isDark),

                        // ===== Sfifa Counts Section =====
                        _buildSfifaCountsSection(context, provider, isDark),

                        // ===== Validation Errors =====
                        if (provider.hasErrors)
                          _buildErrorsCard(provider, isDark),

                        // ===== Profit Section =====
                        _buildProfitSection(context, provider, isDark),

                        // ===== Calculate Button =====
                        const SizedBox(height: 24),
                        _buildCalculateButton(context, provider),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===== BASIC DIMENSIONS =====
  Widget _buildBasicDimensionsSection(
    BuildContext context,
    CalculatorProvider provider,
    bool isDark,
  ) {
    final dataProvider = context.watch<CalcDataProvider>();

    return Column(
      children: [
        const SectionTitle(
          title: 'الأبعاد الأساسية',
          icon: Icons.straighten_rounded,
        ),
        // Product Name Selector
        ProductNameSelector(
          productNames: dataProvider.uniqueProductNames,
          selectedName: provider.selectedProductName,
          isCustomName: provider.isCustomName,
          isLoading: dataProvider.isTarifLoading,
          onNameSelected: (name) {
            provider.setProductName(name);
          },
          onCustomNameEntered: (name) {
            provider.setCustomProductName(name);
          },
        ),
        const SizedBox(height: 16),
        // Height and Width Fields
        Row(
          children: [
            Expanded(
              child: CalcTextField(
                label: 'الطول (cm)',
                hint: 'أدخل الطول بالسنتيمتر',
                prefixIcon: Icons.straighten_rounded,
                controller: provider.heightController,
                onChanged: (value) {
                  provider.setHeight(double.tryParse(value) ?? 0);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CalcTextField(
                label: 'العرض (cm)',
                hint: 'أدخل العرض بالسنتيمتر',
                prefixIcon: Icons.swap_horiz_rounded,
                controller: provider.widthController,
                onChanged: (value) {
                  provider.setWidth(double.tryParse(value) ?? 0);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ===== SPONGE LAYERS =====
  Widget _buildSpongeLayersSection(
    BuildContext context,
    CalculatorProvider provider,
    bool isDark,
  ) {
    final dataProvider = context.watch<CalcDataProvider>();
    final spongeTypes = dataProvider.spongeTypes;
    final isLoading = dataProvider.isLoading;

    return Column(
      children: [
        const SectionTitle(title: 'طبقات الإسفنج', icon: Icons.layers_rounded),

        // Show loading indicator if no sponge types and is loading
        if (isLoading && spongeTypes.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: CalcTheme.primaryStart.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      CalcTheme.primaryStart,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'جاري تحميل أنواع الإسفنج...',
                  style: TextStyle(
                    color: isDark
                        ? CalcTheme.textSecondaryDark
                        : CalcTheme.textSecondaryLight,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
          )
        else if (spongeTypes.isEmpty && !isLoading)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: CalcTheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: CalcTheme.error.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: CalcTheme.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'لم يتم تحميل أنواع الإسفنج',
                  style: TextStyle(
                    color: CalcTheme.error.withValues(alpha: 0.8),
                    fontFamily: 'Tajawal',
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => dataProvider.refresh(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: CalcTheme.primaryStart,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'إعادة المحاولة',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Layer Cards
        ...provider.spongeLayers.asMap().entries.map((entry) {
          final index = entry.key;
          final layer = entry.value;

          return SpongeLayerCard(
            index: index,
            layer: layer,
            onTypeChanged: (type) {
              provider.updateSpongeLayer(index, type: type);
            },
            onLayerCountChanged: (count) {
              provider.updateSpongeLayer(index, layerCount: count);
            },
            onHeightChanged: (height) {
              provider.updateSpongeLayer(index, height: height);
            },
            onWidthChanged: (width) {
              provider.updateSpongeLayer(index, width: width);
            },
            onLengthChanged: (length) {
              provider.updateSpongeLayer(index, length: length);
            },
            onDelete: () => provider.removeSpongeLayer(index),
            spongeTypes: spongeTypes,
          );
        }),

        // Add Layer Button
        const SizedBox(height: 8),
        _buildAddLayerButton(context, provider),
      ],
    );
  }

  Widget _buildAddLayerButton(
    BuildContext context,
    CalculatorProvider provider,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        provider.addSpongeLayer();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: CalcTheme.success,
            width: 2,
            strokeAlign: BorderSide.strokeAlignCenter,
          ),
          color: CalcTheme.success.withValues(alpha: 0.05),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CalcTheme.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                color: CalcTheme.success,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'إضافة طبقة إسفنج',
              style: TextStyle(
                color: CalcTheme.success,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== FOOTER =====
  Widget _buildFooterSection(
    BuildContext context,
    CalculatorProvider provider,
    bool isDark,
  ) {
    final isEnabled = provider.isFooterEnabled;
    final dataProvider = context.watch<CalcDataProvider>();
    final footerTypes = dataProvider.footerTypes;

    return Column(
      children: [
        // Section Title with Toggle
        Padding(
          padding: const EdgeInsets.only(top: 28, bottom: 18),
          child: Row(
            children: [
              // Accent line
              Container(
                width: 5,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      isEnabled ? CalcTheme.primaryStart : Colors.grey,
                      isEnabled ? CalcTheme.primaryEnd : Colors.grey.shade400,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 14),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      (isEnabled ? CalcTheme.primaryStart : Colors.grey)
                          .withValues(alpha: 0.15),
                      (isEnabled ? CalcTheme.primaryEnd : Colors.grey)
                          .withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.grid_view_rounded,
                  color: isEnabled ? CalcTheme.primaryStart : Colors.grey,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'حساب الفوتر',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: isEnabled
                        ? (isDark
                              ? CalcTheme.textPrimaryDark
                              : CalcTheme.textPrimaryLight)
                        : Colors.grey,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ),
              // Toggle Switch
              Switch(
                value: isEnabled,
                onChanged: (value) => provider.setFooterEnabled(value),
                activeThumbColor: CalcTheme.primaryStart,
                activeTrackColor: CalcTheme.primaryStart.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
        // Input fields (dimmed when disabled)
        AnimatedOpacity(
          opacity: isEnabled ? 1.0 : 0.4,
          duration: const Duration(milliseconds: 200),
          child: IgnorePointer(
            ignoring: !isEnabled,
            child: Row(
              children: [
                Expanded(
                  child: CalcTextField(
                    label: 'عدد الطبقات',
                    hint: 'العدد',
                    prefixIcon: Icons.layers_rounded,
                    onChanged: (value) {
                      provider.setFooterLayerCount(double.tryParse(value) ?? 0);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CalcDropdown<String>(
                    label: 'النوع',
                    hint: 'اختر النوع',
                    value: provider.selectedFooterType,
                    items: footerTypes.keys.toList(),
                    itemLabel: (item) => item,
                    onChanged: (type) => provider.setFooterType(type),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ===== DRESS =====
  Widget _buildDressSection(
    BuildContext context,
    CalculatorProvider provider,
    bool isDark,
  ) {
    final dataProvider = context.watch<CalcDataProvider>();
    final dressTypes = dataProvider.dressTypes;
    final isLoading = dataProvider.isLoading;

    return Column(
      children: [
        const SectionTitle(title: 'حساب الثوب', icon: Icons.texture_rounded),
        if (isLoading && dressTypes.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CalcTheme.primaryStart.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      CalcTheme.primaryStart,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'جاري تحميل أنواع الثوب...',
                  style: TextStyle(
                    color: isDark
                        ? CalcTheme.textSecondaryDark
                        : CalcTheme.textSecondaryLight,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
          )
        else if (dressTypes.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CalcTheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: CalcTheme.error.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: CalcTheme.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'لم يتم تحميل أنواع الثوب',
                  style: TextStyle(
                    color: CalcTheme.error.withValues(alpha: 0.8),
                    fontFamily: 'Tajawal',
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => dataProvider.refresh(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: CalcTheme.primaryStart,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'إعادة المحاولة',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          CalcDropdown<String>(
            label: 'نوع الثوب',
            hint: 'اختر نوع الثوب',
            value: provider.selectedDressType,
            items: dressTypes.keys.toList(),
            itemLabel: (item) => item,
            onChanged: (type) => provider.setDressType(type),
          ),
      ],
    );
  }

  // ===== SPRINGS SECTION =====
  Widget _buildSpringsSection(
    BuildContext context,
    CalculatorProvider provider,
    bool isDark,
  ) {
    final isEnabled = provider.isSpringEnabled;

    return Column(
      children: [
        // Section Title with Toggle
        Padding(
          padding: const EdgeInsets.only(top: 28, bottom: 18),
          child: Row(
            children: [
              // Accent line
              Container(
                width: 5,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      isEnabled ? CalcTheme.primaryStart : Colors.grey,
                      isEnabled ? CalcTheme.primaryEnd : Colors.grey.shade400,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 14),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      (isEnabled ? CalcTheme.primaryStart : Colors.grey)
                          .withValues(alpha: 0.15),
                      (isEnabled ? CalcTheme.primaryEnd : Colors.grey)
                          .withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.waves_rounded,
                  color: isEnabled ? CalcTheme.primaryStart : Colors.grey,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'حساب الروسول',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: isEnabled
                        ? (isDark
                              ? CalcTheme.textPrimaryDark
                              : CalcTheme.textPrimaryLight)
                        : Colors.grey,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ),
              // Toggle Switch
              Switch(
                value: isEnabled,
                onChanged: (value) => provider.setSpringEnabled(value),
                activeThumbColor: CalcTheme.primaryStart,
                activeTrackColor: CalcTheme.primaryStart.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
        // Input fields (dimmed when disabled)
        AnimatedOpacity(
          opacity: isEnabled ? 1.0 : 0.4,
          duration: const Duration(milliseconds: 200),
          child: IgnorePointer(
            ignoring: !isEnabled,
            child: Builder(
              builder: (context) {
                // Get spring types from API (مثل الفوتر)
                final dataProvider = context.watch<CalcDataProvider>();
                final springTypes = dataProvider.springTypes;

                // If no items from API, show loading
                if (springTypes.isEmpty && dataProvider.isLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(
                        color: CalcTheme.primaryStart,
                      ),
                    ),
                  );
                }

                // If still empty, show message
                if (springTypes.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CalcTheme.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'لا توجد أنواع روسول - قم بإضافتها من إدارة المواد',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        color: CalcTheme.warning,
                      ),
                    ),
                  );
                }

                // Use names directly from API (like footer)
                return CalcDropdown<String>(
                  label: 'نوع الروسول',
                  hint: 'اختر نوع الروسول',
                  value: provider.selectedSpringType,
                  items: springTypes.keys.toList(),
                  itemLabel: (item) => item, // Use API name directly
                  onChanged: (type) => provider.setSpringType(type),
                );
              },
            ),
          ),
        ),

        // Show measurement field if sachet is selected
        if (isEnabled &&
            (provider.selectedSpringType?.toLowerCase().contains('sachet') ==
                    true ||
                provider.selectedSpringType?.contains('ساشي') == true))
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: CalcTextField(
              label: 'قياس الساشي (متر)',
              hint: '0.0',
              suffix: 'm',
              initialValue: provider.sachetSize > 0
                  ? provider.sachetSize.toString()
                  : '',
              prefixIcon: Icons.straighten_rounded,
              onChanged: (value) {
                provider.setSachetSize(double.tryParse(value) ?? 0);
              },
            ),
          ),
      ],
    );
  }

  // ===== SFIFA COUNTS =====
  Widget _buildSfifaCountsSection(
    BuildContext context,
    CalculatorProvider provider,
    bool isDark,
  ) {
    final isEnabled = provider.isSfifaEnabled;

    return Column(
      children: [
        // Section Title with Toggle
        Padding(
          padding: const EdgeInsets.only(top: 28, bottom: 18),
          child: Row(
            children: [
              // Accent line
              Container(
                width: 5,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      isEnabled ? CalcTheme.primaryStart : Colors.grey,
                      isEnabled ? CalcTheme.primaryEnd : Colors.grey.shade400,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 14),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      (isEnabled ? CalcTheme.primaryStart : Colors.grey)
                          .withValues(alpha: 0.15),
                      (isEnabled ? CalcTheme.primaryEnd : Colors.grey)
                          .withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.linear_scale_rounded,
                  color: isEnabled ? CalcTheme.primaryStart : Colors.grey,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'أعداد السفيفة',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: isEnabled
                        ? (isDark
                              ? CalcTheme.textPrimaryDark
                              : CalcTheme.textPrimaryLight)
                        : Colors.grey,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ),
              // Toggle Switch
              Switch(
                value: isEnabled,
                onChanged: (value) => provider.setSfifaEnabled(value),
                activeThumbColor: CalcTheme.primaryStart,
                activeTrackColor: CalcTheme.primaryStart.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
        // Input fields (dimmed when disabled)
        AnimatedOpacity(
          opacity: isEnabled ? 1.0 : 0.4,
          duration: const Duration(milliseconds: 200),
          child: IgnorePointer(
            ignoring: !isEnabled,
            child: Column(
              children: [
                // Sfifa counts
                Row(
                  children: [
                    Expanded(
                      child: CalcTextField(
                        label: 'شريط 36mm',
                        hint: 'العدد',
                        initialValue: provider.sfifaNum1.toString(),
                        onChanged: (value) {
                          provider.setSfifaNum1(int.tryParse(value) ?? 0);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CalcTextField(
                        label: 'شريط 18mm',
                        hint: 'العدد',
                        initialValue: provider.sfifaNum2.toString(),
                        onChanged: (value) {
                          provider.setSfifaNum2(int.tryParse(value) ?? 0);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CalcTextField(
                        label: 'شريط 3D',
                        hint: 'العدد',
                        initialValue: provider.sfifaNum3.toString(),
                        onChanged: (value) {
                          provider.setSfifaNum3(int.tryParse(value) ?? 0);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Chain and Elastic counts
                Row(
                  children: [
                    Expanded(
                      child: CalcTextField(
                        label: 'عدد السلاسل',
                        hint: 'العدد',
                        initialValue: provider.numChain.toString(),
                        onChanged: (value) {
                          provider.setNumChain(int.tryParse(value) ?? 0);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CalcTextField(
                        label: 'عدد المطاط',
                        hint: 'العدد',
                        initialValue: provider.numElastic.toString(),
                        onChanged: (value) {
                          provider.setNumElastic(int.tryParse(value) ?? 0);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ===== ERRORS CARD =====
  Widget _buildErrorsCard(CalculatorProvider provider, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CalcTheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CalcTheme.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: CalcTheme.error,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'تنبيهات',
                style: TextStyle(
                  color: CalcTheme.error,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Tajawal',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...provider.validationErrors.map(
            (error) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: CalcTheme.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      error,
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black87,
                        fontSize: 14,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== CALCULATE BUTTON =====
  Widget _buildCalculateButton(
    BuildContext context,
    CalculatorProvider provider,
  ) {
    return CalcButton(
      label: 'احسب السعر النهائي',
      icon: Icons.calculate_rounded,
      isLoading: provider.isCalculating,
      onPressed: () {
        HapticFeedback.mediumImpact();
        final result = provider.calculate();
        if (result != null) {
          final name = provider.selectedProductName ?? 'مرتبة مخصصة';
          // تحويل الأبعاد من متر إلى سنتيمتر للتخزين (الطول × 100)
          final heightCm = (provider.height * 100).round();
          final widthCm = (provider.width * 100).round();
          final size = '$heightCm/$widthCm';

          showDialog(
            context: context,
            builder: (context) => ResultDialog(
              result: result,
              mattressName: name,
              mattressSize: size,
              isEditMode: provider.isEditMode,
              tarifId: provider.tarifId,
            ),
          );
        }
      },
    );
  }

  // ===== PROFIT SECTION =====
  Widget _buildProfitSection(
    BuildContext context,
    CalculatorProvider provider,
    bool isDark,
  ) {
    final percentages = [
      25.0,
      30.0,
      35.0,
      40.0,
      45.0,
      50.0,
      60.0,
      70.0,
      80.0,
      90.0,
      100.0,
    ];

    return Column(
      children: [
        const SectionTitle(title: 'هامش الربح', icon: Icons.percent_rounded),
        CalcDropdown<double>(
          label: 'نصيب الربح',
          hint: 'اختر النسبة',
          value: percentages.contains(provider.profitMargin)
              ? provider.profitMargin
              : 0.0,
          items: percentages,
          itemLabel: (item) => '${item.toInt()}%',
          onChanged: (value) => provider.setProfitMargin(value ?? 0),
        ),
      ],
    );
  }
}
