import 'package:flutter/material.dart';

import '../models/sponge_layer.dart';
import '../models/calculation_result.dart';
import '../../cost/provider/costs_provider.dart';
import 'calc_data_provider.dart';

/// ===== Calculator Provider =====
/// Manages all state and business logic for the calculator
/// Uses CostsProvider for fixed costs and CalcDataProvider for dynamic data
class CalculatorProvider extends ChangeNotifier {
  final CostsProvider costsProvider;
  final CalcDataProvider dataProvider;

  CalculatorProvider({required this.costsProvider, required this.dataProvider});

  // ===== Basic Dimensions =====
  double _height = 0;
  double _width = 0;

  final TextEditingController heightController = TextEditingController();
  final TextEditingController widthController = TextEditingController();

  @override
  void dispose() {
    heightController.dispose();
    widthController.dispose();
    super.dispose();
  }

  // ===== Sponge Layers =====
  final List<SpongeLayer> _spongeLayers = [];

  // ===== Footer Section =====
  String? _selectedFooterType;
  double _footerCoefficient = 0;
  double _footerLayerCount = 0;

  // ===== Dress Section =====
  String? _selectedDressType;
  double _dressPrice = 0;

  // ===== Sfifa Counts (variable per calculation) =====
  // ===== Sfifa Counts (variable per calculation) =====
  int _sfifaNum1 = 3;
  int _sfifaNum2 = 2;
  int _sfifaNum3 = 2;
  int _numChain = 2;
  int _numElastic = 0;

  // ===== Toggle States =====
  bool _isFooterEnabled = true;
  bool _isSfifaEnabled = true;
  bool _isSpringEnabled = true;

  // ===== Spring Type =====
  String _springType = 'normal'; // 'normal' or 'sachet'

  // ===== Validation State =====
  final List<String> _validationErrors = [];
  CalculationResult? _lastResult;
  bool _isCalculating = false;
  double _profitMargin = 0; // % Percentage

  // ========== GETTERS ==========

  double get height => _height;
  double get width => _width;
  List<SpongeLayer> get spongeLayers => List.unmodifiable(_spongeLayers);
  String? get selectedFooterType => _selectedFooterType;
  double get footerCoefficient => _footerCoefficient;
  double get footerLayerCount => _footerLayerCount;
  String? get selectedDressType => _selectedDressType;
  double get dressPrice => _dressPrice;
  int get sfifaNum1 => _sfifaNum1;
  int get sfifaNum2 => _sfifaNum2;
  int get sfifaNum3 => _sfifaNum3;
  int get numChain => _numChain;
  int get numElastic => _numElastic;
  bool get isFooterEnabled => _isFooterEnabled;
  bool get isSfifaEnabled => _isSfifaEnabled;
  bool get isSpringEnabled => _isSpringEnabled;
  String get springType => _springType;
  List<String> get validationErrors => List.unmodifiable(_validationErrors);
  CalculationResult? get lastResult => _lastResult;
  bool get isCalculating => _isCalculating;
  double get profitMargin => _profitMargin;
  bool get hasErrors => _validationErrors.isNotEmpty;

  // ========== SETTERS ==========

  void setHeight(double value) {
    _height = value;
    final currentTextValue = double.tryParse(heightController.text) ?? 0;
    if ((currentTextValue - value).abs() > 0.001) {
      heightController.text = value == 0 ? '' : value.toString();
    }
    notifyListeners();
  }

  void setWidth(double value) {
    _width = value;
    final currentTextValue = double.tryParse(widthController.text) ?? 0;
    if ((currentTextValue - value).abs() > 0.001) {
      widthController.text = value == 0 ? '' : value.toString();
    }
    notifyListeners();
  }

  // ===== Sponge Layer Management =====

  void addSpongeLayer() {
    _spongeLayers.add(SpongeLayer());
    notifyListeners();
  }

  void removeSpongeLayer(int index) {
    if (index >= 0 && index < _spongeLayers.length) {
      _spongeLayers.removeAt(index);
      notifyListeners();
    }
  }

  void updateSpongeLayer(
    int index, {
    String? type,
    double? layerCount,
    double? height,
    double? width,
    double? length,
  }) {
    if (index >= 0 && index < _spongeLayers.length) {
      final layer = _spongeLayers[index];
      if (type != null) {
        layer.selectedType = type;
        layer.coefficient = dataProvider.spongeTypes[type]?.toDouble();
      }
      if (layerCount != null) layer.layerCount = layerCount;
      if (height != null) layer.height = height;
      if (width != null) layer.width = width;
      if (length != null) layer.length = length;
      notifyListeners();
    }
  }

  // ===== Footer Section =====

  void setFooterType(String? type) {
    _selectedFooterType = type;
    if (type != null && dataProvider.footerTypes.containsKey(type)) {
      _footerCoefficient = dataProvider.footerTypes[type]!;
    }
    notifyListeners();
  }

  void setFooterLayerCount(double value) {
    _footerLayerCount = value;
    notifyListeners();
  }

  // ===== Dress Section =====

  void setDressType(String? type) {
    _selectedDressType = type;
    if (type != null && dataProvider.dressTypes.containsKey(type)) {
      _dressPrice = dataProvider.dressTypes[type]!;
    }
    notifyListeners();
  }

  // ===== Sfifa Counts =====

  void setSfifaNum1(int value) {
    _sfifaNum1 = value;
    notifyListeners();
  }

  void setSfifaNum2(int value) {
    _sfifaNum2 = value;
    notifyListeners();
  }

  void setSfifaNum3(int value) {
    _sfifaNum3 = value;
    notifyListeners();
  }

  void setNumChain(int value) {
    _numChain = value;
    notifyListeners();
  }

  void setNumElastic(int value) {
    _numElastic = value;
    notifyListeners();
  }

  // ===== Toggle Controls =====

  void setFooterEnabled(bool value) {
    _isFooterEnabled = value;
    notifyListeners();
  }

  void setSfifaEnabled(bool value) {
    _isSfifaEnabled = value;
    notifyListeners();
  }

  void setSpringEnabled(bool value) {
    _isSpringEnabled = value;
    notifyListeners();
  }

  void setSpringType(String type) {
    _springType = type;
    notifyListeners();
  }

  void setProfitMargin(double value) {
    _profitMargin = value;
    notifyListeners();
  }

  // ========== VALIDATION ==========

  bool validate() {
    _validationErrors.clear();

    if (_height <= 0) {
      _validationErrors.add('الطول ديال المطلة خاصو يكون أكبر من 0');
    }
    if (_width <= 0) {
      _validationErrors.add('العرض ديال المطلة خاصو يكون أكبر من 0');
    }

    // Validate sponge layers
    for (int i = 0; i < _spongeLayers.length; i++) {
      final layer = _spongeLayers[i];
      if (layer.selectedType == null) {
        _validationErrors.add('نوع الإسفنج للطبقة ${i + 1} مطلوب');
      }
      if (layer.layerCount <= 0) {
        _validationErrors.add('عدد الطبقات ${i + 1} خاصو يكون أكبر من 0');
      }
      if (layer.length <= 0) {
        _validationErrors.add('سمك الإسفنج للطبقة ${i + 1} مطلوب');
      }
    }

    // Validate footer fields when enabled
    if (_isFooterEnabled) {
      if (_footerLayerCount <= 0) {
        _validationErrors.add('خانة عدد طبقات الفوتر فارغة');
      }
      if (_selectedFooterType == null) {
        _validationErrors.add('يجب اختيار نوع الفوتر');
      }
    }

    // Validate sfifa fields when enabled
    if (_isSfifaEnabled) {
      if (_sfifaNum1 <= 0 &&
          _sfifaNum2 <= 0 &&
          _sfifaNum3 <= 0 &&
          _numChain <= 0 &&
          _numElastic <= 0) {
        _validationErrors.add('خانات السفيفة فارغة، أضف قيمة واحدة على الأقل');
      }
    }

    // Validate dress type (Mandatory)
    if (_selectedDressType == null) {
      _validationErrors.add('يجب اختيار نوع الثوب');
    }

    // Validate production isn't zero (division by zero prevention)
    if (costsProvider.production <= 0) {
      _validationErrors.add('عدد الإنتاج خاصو يكون أكبر من 0');
    }

    notifyListeners();
    return _validationErrors.isEmpty;
  }

  // ========== CALCULATION ==========

  CalculationResult? calculate() {
    if (!validate()) {
      return null;
    }

    _isCalculating = true;
    notifyListeners();

    try {
      // {1} Footer Calculation (skip if disabled)
      double footerPrice = 0;
      if (_isFooterEnabled) {
        final footerSize = _height * _width;
        footerPrice = footerSize * _footerCoefficient * _footerLayerCount;
      }

      // {2} Springs Calculation (skip if disabled)
      double springsPrice = 0;
      if (_isSpringEnabled) {
        final springSizeCalcOne = (_height - 0.10) * 12;
        final springSizeCalcTow = (_width - 0.10) * 9;
        final countOfSprings = springSizeCalcOne * springSizeCalcTow;
        // Updated: Only use springValue (sachet removed)
        final springUnitPrice = costsProvider.springValue;
        springsPrice = countOfSprings * springUnitPrice;
      }

      // {3} Dress Calculation
      final x1 = _width * 3;
      final x2 = (_width + _height) * 2;
      const x3 = 2 / 0.30;
      final x4 = x2 / x3;
      final x5 = x1 + x4;
      final x6 = x5 + (8 / 100) * x5;
      final dressCalcPrice = x6 * _dressPrice + 4;

      // {4} Sfifa Calculation - using costs from CostsProvider (skip if disabled)
      double sfifaPrice = 0;
      if (_isSfifaEnabled) {
        final countOfRibos1 = costsProvider.ribbon36mmPrice * _sfifaNum1;
        final countOfRibos2 = costsProvider.ribbon18mmPrice * _sfifaNum2;
        final countOfRibos3 = costsProvider.ribbon3DPrice * _sfifaNum3;

        final y1 = _width + _height;
        final y2 = y1 * 2;
        final y3 = y2 * countOfRibos1;
        final y4 = y2 * countOfRibos2;
        final y5 = y2 * countOfRibos3;
        final chain = costsProvider.chainPrice * _numChain;
        final elastic = costsProvider.elasticPrice * _numElastic;
        sfifaPrice = y3 + y4 + y5 + chain + elastic;
      }

      // {5} Packaging Calculation - using costs from CostsProvider
      final z1 = costsProvider.corners * 4;
      final z2 = costsProvider.tickets * 1;
      final z5 = costsProvider.plastic * 1;
      // Removed: bigFlyer, smallFlyer, scotch, adding, glue
      final packagingPrice = z1 + z2 + z5;

      // {6} Cost Calculation - using costs from CostsProvider
      final costPrice = costsProvider.costPerUnit;

      // {7} Sponge Calculation - using basic dimensions
      double spongePrice = 0;
      for (final layer in _spongeLayers) {
        if (layer.coefficient != null && layer.layerCount > 0) {
          // استخدام الأبعاد الأساسية (الطول والعرض) مع سمك الإسفنج
          final sizeOfLayer = _height * _width * layer.length;
          spongePrice += (sizeOfLayer * layer.coefficient!) * layer.layerCount;
        }
      }

      // Total Calculation
      final totalBeforeProfit =
          footerPrice +
          springsPrice +
          dressCalcPrice +
          sfifaPrice +
          packagingPrice +
          costPrice +
          spongePrice;

      final profitAmount = totalBeforeProfit * (_profitMargin / 100);
      final finalPrice = totalBeforeProfit + profitAmount;

      _lastResult = CalculationResult(
        footerPrice: footerPrice,
        springsPrice: springsPrice,
        dressPrice: dressCalcPrice,
        sfifaPrice: sfifaPrice,
        packagingPrice: packagingPrice,
        costPrice: costPrice,
        spongePrice: spongePrice,
        profitMargin: _profitMargin,
        profitAmount: profitAmount,
        finalPrice: finalPrice,
      );

      _isCalculating = false;
      notifyListeners();
      return _lastResult;
    } catch (e) {
      _validationErrors.add('حدث خطأ في الحساب: $e');
      _isCalculating = false;
      notifyListeners();
      return null;
    }
  }

  // ===== Reset All Values =====

  void reset() {
    _height = 0;
    _width = 0;
    _spongeLayers.clear();
    _selectedFooterType = null;
    _footerCoefficient = dataProvider.footerTypes.isNotEmpty
        ? dataProvider.footerTypes.values.first
        : 0;
    _footerLayerCount = 0;
    _selectedDressType = null;
    _dressPrice = 0;
    _sfifaNum1 = 3;
    _sfifaNum2 = 2;
    _sfifaNum3 = 2;
    _numChain = 2;
    _numElastic = 0;
    _isFooterEnabled = true;
    _isSfifaEnabled = true;
    _isSpringEnabled = true;
    _springType = 'normal';
    _validationErrors.clear();
    _lastResult = null;
    _isCalculating = false;
    _profitMargin = 0;
    notifyListeners();
  }
}
