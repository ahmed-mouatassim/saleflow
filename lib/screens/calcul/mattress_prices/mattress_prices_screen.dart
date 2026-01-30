import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'models/tarif_model.dart';
import 'service/tarif_api_service.dart';
import 'constants/mattress_prices_theme.dart';
import '../calculator/provider/calculator_provider.dart';

/// شاشة جدول أسعار المراتب
/// تعرض جميع أنواع المراتب مع أسعارها من قاعدة البيانات
class MattressPricesScreen extends StatefulWidget {
  final bool isEmbedded;
  final VoidCallback? onSwitchToCalculator;

  const MattressPricesScreen({
    super.key,
    this.isEmbedded = false,
    this.onSwitchToCalculator,
  });

  @override
  State<MattressPricesScreen> createState() => _MattressPricesScreenState();
}

class _MattressPricesScreenState extends State<MattressPricesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // التحكم بالتمرير
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  final List<ScrollController> _rowScrollControllers = [];

  // الخلية المحددة
  String? _selectedCell;
  String? _hoveredCell;

  // البحث
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // حالة التحميل
  bool _isLoading = true;
  String? _errorMessage;
  List<TarifModel> _tarifData = [];

  // البيانات المجمعة
  List<String> _mattressNames = [];
  List<String> _sizes = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();

    // مزامنة التمرير الأفقي
    _horizontalScrollController.addListener(_syncHorizontalScroll);

    // تحميل البيانات من API
    _loadData();
  }

  /// تحميل البيانات من قاعدة البيانات
  Future<void> _loadData({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await TarifApiService.fetchTarifDetails(
      forceRefresh: forceRefresh,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (response.success && response.data != null) {
          _tarifData = response.data!;
          _extractMattressNamesAndSizes();
        } else {
          _errorMessage = response.message ?? 'فشل في تحميل البيانات';
        }
      });
    }
  }

  /// استخراج أسماء المراتب والمقاسات الفريدة
  void _extractMattressNamesAndSizes() {
    final names = <String>{};
    final sizes = <String>{};

    for (final tarif in _tarifData) {
      names.add(tarif.name);
      sizes.add(tarif.size);
    }

    _mattressNames = names.toList()..sort();

    // ترتيب المقاسات
    _sizes = sizes.toList()
      ..sort((a, b) {
        final aParts = a.split('/');
        final bParts = b.split('/');
        if (aParts.length != 2 || bParts.length != 2) return a.compareTo(b);
        final aLength = int.tryParse(aParts[0]) ?? 0;
        final bLength = int.tryParse(bParts[0]) ?? 0;
        if (aLength != bLength) return aLength.compareTo(bLength);
        final aWidth = int.tryParse(aParts[1]) ?? 0;
        final bWidth = int.tryParse(bParts[1]) ?? 0;
        return aWidth.compareTo(bWidth);
      });
  }

  /// الحصول على بيانات التعريفة لاسم ومقاس معين
  TarifModel? _getTarif(String name, String size) {
    final index = _tarifData.indexWhere(
      (t) => t.name == name && t.size == size,
    );
    if (index != -1) {
      return _tarifData[index];
    }
    return null;
  }

  /// الحصول على متحكم التمرير للصف بشكل آمن
  ScrollController _getRowScrollController(int index) {
    while (_rowScrollControllers.length <= index) {
      _rowScrollControllers.add(ScrollController());
    }
    return _rowScrollControllers[index];
  }

  void _syncHorizontalScroll() {
    for (var controller in _rowScrollControllers) {
      if (controller.hasClients &&
          controller.offset != _horizontalScrollController.offset) {
        controller.jumpTo(_horizontalScrollController.offset);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _horizontalScrollController.removeListener(_syncHorizontalScroll);
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    _searchController.dispose();
    for (var controller in _rowScrollControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MattressPricesTheme.backgroundDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: MattressPricesTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildHeader(),
                _buildSearchBar(),
                Expanded(child: _buildContent()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// بناء المحتوى (جدول أو رسالة خطأ أو تحميل)
  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_tarifData.isEmpty) {
      return _buildEmptyState();
    }

    return _buildPriceTable();
  }

  /// حالة التحميل
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              MattressPricesTheme.primaryStart,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'جاري تحميل البيانات...',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 16,
              color: MattressPricesTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// حالة الخطأ
  Widget _buildErrorState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: MattressPricesTheme.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'حدث خطأ',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 16,
                color: MattressPricesTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _loadData(forceRefresh: true),
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: MattressPricesTheme.primaryStart,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// حالة البيانات الفارغة
  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: MattressPricesTheme.surfaceDark,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.inbox_rounded,
              color: MattressPricesTheme.textSecondary,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'لا توجد بيانات متاحة',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 16,
                color: MattressPricesTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'يرجى إضافة بيانات إلى جدول tarif في قاعدة البيانات',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 14,
                color: MattressPricesTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _loadData(forceRefresh: true),
              icon: const Icon(Icons.refresh),
              label: const Text('تحديث'),
              style: ElevatedButton.styleFrom(
                backgroundColor: MattressPricesTheme.primaryStart,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// بناء الهيدر
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (!widget.isEmbedded) _buildBackButton(),
          if (!widget.isEmbedded) const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'جدول أسعار المراتب',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Tajawal',
                    color: MattressPricesTheme.textPrimary,
                    shadows: [
                      Shadow(
                        color: MattressPricesTheme.primaryStart.withValues(
                          alpha: 0.5,
                        ),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'اضغط على أي خلية لعرض التفاصيل',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Tajawal',
                    color: MattressPricesTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // زر التحديث
          _buildRefreshButton(),
          const SizedBox(width: 8),
          _buildInfoButton(),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pop(context);
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: MattressPricesTheme.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: MattressPricesTheme.cellBorder.withValues(alpha: 0.5),
          ),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: MattressPricesTheme.textPrimary,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildRefreshButton() {
    return GestureDetector(
      onTap: _isLoading ? null : () => _loadData(forceRefresh: true),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: MattressPricesTheme.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: MattressPricesTheme.cellBorder.withValues(alpha: 0.5),
          ),
        ),
        child: _isLoading
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(
                Icons.refresh_rounded,
                color: MattressPricesTheme.textPrimary,
                size: 22,
              ),
      ),
    );
  }

  Widget _buildInfoButton() {
    return GestureDetector(
      onTap: () => _showInfoDialog(),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: MattressPricesTheme.primaryGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: MattressPricesTheme.primaryStart.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.info_outline_rounded,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }

  /// بناء حقل البحث
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: MattressPricesTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: MattressPricesTheme.cellBorder.withValues(alpha: 0.5),
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(
          fontFamily: 'Tajawal',
          fontSize: 16,
          color: MattressPricesTheme.textPrimary,
        ),
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: 'بحث عن نوع المرتبة...',
          hintStyle: const TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 14,
            color: MattressPricesTheme.textMuted,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: MattressPricesTheme.textSecondary,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear_rounded,
                    color: MattressPricesTheme.textSecondary,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        onChanged: (value) {
          setState(() => _searchQuery = value.toLowerCase());
        },
      ),
    );
  }

  /// بناء جدول الأسعار
  Widget _buildPriceTable() {
    // تصفية المراتب حسب البحث
    final filteredNames = _searchQuery.isEmpty
        ? _mattressNames
        : _mattressNames
              .where((name) => name.toLowerCase().contains(_searchQuery))
              .toList();

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MattressPricesTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MattressPricesTheme.cellBorder.withValues(alpha: 0.3),
        ),
        boxShadow: [MattressPricesTheme.cardShadow],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildTableHeader(_sizes),
          Container(
            height: 1,
            color: MattressPricesTheme.primaryStart.withValues(alpha: 0.3),
          ),
          Expanded(
            child: Scrollbar(
              controller: _verticalScrollController,
              thumbVisibility: true,
              child: ListView.builder(
                controller: _verticalScrollController,
                itemCount: filteredNames.length,
                itemBuilder: (context, index) {
                  return _buildTableRow(filteredNames[index], _sizes, index);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// رأس الجدول
  Widget _buildTableHeader(List<String> sizes) {
    return Container(
      height: MattressTableDimensions.headerHeight,
      decoration: const BoxDecoration(
        gradient: MattressPricesTheme.headerGradient,
      ),
      child: Row(
        children: [
          Container(
            width: MattressTableDimensions.nameColumnWidth,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.centerRight,
            child: const Text(
              'نوع المرتبة',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
                color: MattressPricesTheme.headerText,
              ),
            ),
          ),
          Container(
            width: 1,
            color: MattressPricesTheme.primaryEnd.withValues(alpha: 0.5),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _horizontalScrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: sizes.map((size) {
                  return Container(
                    width: MattressTableDimensions.priceColumnWidth,
                    alignment: Alignment.center,
                    child: Text(
                      size,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Tajawal',
                        color: MattressPricesTheme.headerText,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// صف الجدول
  Widget _buildTableRow(String mattressName, List<String> sizes, int index) {
    final isEven = index % 2 == 0;

    return Container(
      height: MattressTableDimensions.rowHeight,
      decoration: BoxDecoration(
        color: isEven
            ? MattressPricesTheme.rowEven
            : MattressPricesTheme.rowOdd,
        border: Border(
          bottom: BorderSide(
            color: MattressPricesTheme.cellBorder.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: MattressTableDimensions.nameColumnWidth,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.centerRight,
            child: Text(
              mattressName,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: 'Tajawal',
                color: MattressPricesTheme.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            width: 1,
            color: MattressPricesTheme.cellBorder.withValues(alpha: 0.3),
          ),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollUpdateNotification) {
                  if (_horizontalScrollController.hasClients &&
                      _horizontalScrollController.offset !=
                          notification.metrics.pixels) {
                    _horizontalScrollController.jumpTo(
                      notification.metrics.pixels,
                    );
                  }
                  for (int i = 0; i < _rowScrollControllers.length; i++) {
                    if (i != index &&
                        _rowScrollControllers[i].hasClients &&
                        _rowScrollControllers[i].offset !=
                            notification.metrics.pixels) {
                      _rowScrollControllers[i].jumpTo(
                        notification.metrics.pixels,
                      );
                    }
                  }
                }
                return false;
              },
              child: SingleChildScrollView(
                controller: _getRowScrollController(index),
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: sizes.map((size) {
                    final tarif = _getTarif(mattressName, size);
                    final cellKey = '${mattressName}_$size';

                    return _buildPriceCell(
                      cellKey: cellKey,
                      tarif: tarif,
                      mattressName: mattressName,
                      size: size,
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// خلية السعر
  Widget _buildPriceCell({
    required String cellKey,
    required TarifModel? tarif,
    required String mattressName,
    required String size,
  }) {
    final isSelected = _selectedCell == cellKey;
    final isHovered = _hoveredCell == cellKey;
    final hasData = tarif != null;
    final price = tarif?.finalPrice.toInt() ?? 0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredCell = cellKey),
      onExit: (_) => setState(() => _hoveredCell = null),
      child: GestureDetector(
        onTap: hasData ? () => _onCellTap(tarif, mattressName, size) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: MattressTableDimensions.priceColumnWidth,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? MattressPricesTheme.cellSelected.withValues(alpha: 0.3)
                : isHovered
                ? MattressPricesTheme.cellHover.withValues(alpha: 0.3)
                : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: MattressPricesTheme.cellBorder.withValues(alpha: 0.2),
              ),
            ),
          ),
          child: Text(
            hasData ? price.toString() : '-',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontFamily: 'Tajawal',
              color: hasData
                  ? (isSelected
                        ? MattressPricesTheme.primaryEnd
                        : MattressPricesTheme.priceAvailable)
                  : MattressPricesTheme.textMuted,
            ),
          ),
        ),
      ),
    );
  }

  /// تأكيد الحذف
  Future<void> _confirmDelete(TarifModel tarif) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'تأكيد الحذف',
          style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.bold),
          textAlign: TextAlign.right,
        ),
        content: Text(
          'هل أنت متأكد من حذف تسعيرة "${tarif.name}" مقاس ${tarif.size}؟',
          style: const TextStyle(fontFamily: 'Tajawal'),
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Tajawal')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'حذف',
              style: TextStyle(fontFamily: 'Tajawal', color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context); // إغلاق BottomSheet إذا كان مفتوحاً
      }

      setState(() => _isLoading = true);

      try {
        final response = await TarifApiService.deleteTarif(tarif.id);

        if (mounted) {
          setState(() => _isLoading = false);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response.message ??
                    (response.success ? 'تم الحذف بنجاح' : 'فشل الحذف'),
                style: const TextStyle(fontFamily: 'Tajawal'),
              ),
              backgroundColor: response.success ? Colors.green : Colors.red,
            ),
          );

          if (response.success) {
            _loadData(forceRefresh: true);
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
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
  }

  /// عند النقر على خلية - عرض تفاصيل من قاعدة البيانات
  void _onCellTap(TarifModel tarif, String mattressName, String size) {
    HapticFeedback.lightImpact();

    setState(() {
      _selectedCell = '${mattressName}_$size';
    });

    // الحصول على CalculatorProvider
    final calcProvider = Provider.of<CalculatorProvider>(
      context,
      listen: false,
    );

    // عرض تفاصيل السعر من قاعدة البيانات
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: MattressPricesTheme.cardDark,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: MattressPricesTheme.cellBorder.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // المقبض
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: MattressPricesTheme.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // الهيدر
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: MattressPricesTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
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
                      Icons.bed_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mattressName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Tajawal',
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'المقاس: $size',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Tajawal',
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // السعر النهائي
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${tarif.finalPrice.toInt()} DH',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Tajawal',
                        color: MattressPricesTheme.primaryStart,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // تفاصيل الأسعار من قاعدة البيانات
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildPriceRow(
                      'الإسفنج',
                      tarif.spongePrice,
                      Icons.layers_rounded,
                    ),
                    _buildPriceRow(
                      'الروسول',
                      tarif.springsPrice,
                      Icons.linear_scale_rounded,
                    ),
                    _buildPriceRow(
                      'الثوب',
                      tarif.dressPrice,
                      Icons.texture_rounded,
                    ),
                    _buildPriceRow(
                      'السفيفة',
                      tarif.sfifaPrice,
                      Icons.format_line_spacing_rounded,
                    ),
                    _buildPriceRow(
                      'الفوتر',
                      tarif.footerPrice,
                      Icons.view_column_rounded,
                    ),
                    _buildPriceRow(
                      'التغليف',
                      tarif.packagingPrice,
                      Icons.inventory_2_rounded,
                    ),
                    _buildPriceRow(
                      'التكاليف',
                      tarif.costPrice,
                      Icons.receipt_long_rounded,
                    ),
                    if (tarif.profitPrice > 0)
                      _buildPriceRow(
                        'هامش الربح',
                        tarif.profitPrice,
                        Icons.trending_up_rounded,
                      ),
                    const Divider(
                      height: 32,
                      color: MattressPricesTheme.cellBorder,
                    ),
                    _buildPriceRow(
                      'السعر النهائي',
                      tarif.finalPrice,
                      Icons.attach_money_rounded,
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ),

            // أزرار الإجراءات
            const SizedBox(height: 16),
            Row(
              children: [
                // زر الموافقة
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // نسخ السعر
                      Clipboard.setData(
                        ClipboardData(
                          text: tarif.finalPrice.toInt().toString(),
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'تم نسخ السعر: ${tarif.finalPrice.toInt()} DH',
                            style: const TextStyle(fontFamily: 'Tajawal'),
                          ),
                          backgroundColor: MattressPricesTheme.primaryStart,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('موافقة', style: TextStyle(fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // زر التعديل
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // استخراج الأبعاد من المقاس
                      final sizeParts = size.split('/');
                      final height = double.tryParse(sizeParts[0]) ?? 190;
                      final width = double.tryParse(sizeParts[1]) ?? 90;

                      // تعيين القيم في CalculatorProvider
                      calcProvider.setHeight(height);
                      calcProvider.setWidth(width);
                      calcProvider.setDressType(mattressName);

                      // الانتقال إلى تبويب الحاسبة
                      if (widget.onSwitchToCalculator != null) {
                        widget.onSwitchToCalculator!();
                      }
                    },
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    label: const Text('تعديل', style: TextStyle(fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MattressPricesTheme.primaryStart,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // زر الحذف
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: () => _confirmDelete(tarif),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.withValues(alpha: 0.1),
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Colors.red.withValues(alpha: 0.3),
                        ),
                      ),
                      elevation: 0,
                    ),
                    child: const Icon(Icons.delete_outline_rounded, size: 22),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// بناء صف السعر
  Widget _buildPriceRow(
    String label,
    double value,
    IconData icon, {
    bool isTotal = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isTotal
            ? MattressPricesTheme.primaryStart.withValues(alpha: 0.15)
            : MattressPricesTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: isTotal
            ? Border.all(
                color: MattressPricesTheme.primaryStart.withValues(alpha: 0.5),
              )
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isTotal
                  ? MattressPricesTheme.primaryStart.withValues(alpha: 0.2)
                  : MattressPricesTheme.cardDark,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isTotal
                  ? MattressPricesTheme.primaryStart
                  : MattressPricesTheme.textSecondary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isTotal ? 16 : 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                fontFamily: 'Tajawal',
                color: MattressPricesTheme.textPrimary,
              ),
            ),
          ),
          Text(
            '${value.toStringAsFixed(2)} DH',
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              fontFamily: 'Tajawal',
              color: isTotal
                  ? MattressPricesTheme.primaryStart
                  : MattressPricesTheme.priceAvailable,
            ),
          ),
        ],
      ),
    );
  }

  /// عرض معلومات الاستخدام
  void _showInfoDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: MattressPricesTheme.cardDark,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: MattressPricesTheme.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'كيفية الاستخدام',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
                color: MattressPricesTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoItem(
              Icons.touch_app_rounded,
              'اضغط على أي خلية لعرض تفاصيل السعر',
            ),
            _buildInfoItem(
              Icons.search_rounded,
              'استخدم البحث للعثور على نوع المرتبة',
            ),
            _buildInfoItem(
              Icons.refresh_rounded,
              'اضغط على زر التحديث لجلب أحدث البيانات',
            ),
            _buildInfoItem(
              Icons.edit_rounded,
              'زر التعديل ينقلك إلى الحاسبة مع البيانات',
            ),
            _buildInfoItem(
              Icons.check_rounded,
              'زر الموافقة ينسخ السعر إلى الحافظة',
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: MattressPricesTheme.primaryStart.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: MattressPricesTheme.primaryStart,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Tajawal',
                color: MattressPricesTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
