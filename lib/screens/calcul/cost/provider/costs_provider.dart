import 'package:flutter/material.dart';
import 'dart:async';
import '../services/cost_api_service.dart';
import '../constants/costs_constants.dart';

/// ===== Costs Provider =====
/// Manages all fixed costs that are shared across the app
/// Fetches values directly from API
class CostsProvider extends ChangeNotifier {
  // ===== Sfifa Section =====
  double _ribbon36mmPrice = CostsConstants.defaultRibbon36mm;
  double _ribbon18mmPrice = CostsConstants.defaultRibbon18mm;
  double _ribbon3DPrice = CostsConstants.defaultRibbon3D;
  double _chainPrice = CostsConstants.defaultChainPrice;
  double _elasticPrice = CostsConstants.defaultElasticPrice;
  double _threadPrice = CostsConstants.defaultThread; // New

  // ===== Packaging Section =====
  double _corners = CostsConstants.defaultCorners;
  double _tickets = CostsConstants.defaultTickets;
  double _plastic = CostsConstants.defaultPlastic;
  double _scotch = CostsConstants.defaultScotch; // New
  double _otherPackaging = CostsConstants.defaultOtherPackaging; // New

  // ===== Monthly Costs Section =====
  double _rent = CostsConstants.defaultRent;
  double _employees = CostsConstants.defaultEmployees;
  double _diesel = CostsConstants.defaultDiesel;
  double _electricity = CostsConstants.defaultElectricity;
  int _production = CostsConstants.defaultProduction;
  double _water = CostsConstants.defaultWater; // New
  double _internet = CostsConstants.defaultInternet; // New
  double _maintenance = CostsConstants.defaultMaintenance; // New
  double _transport = CostsConstants.defaultTransport; // New
  double _marketing = CostsConstants.defaultMarketing; // New
  double _otherMonthly = CostsConstants.defaultOtherMonthly; // New

  // ===== Springs Section =====
  double _springValue = CostsConstants.defaultSpringValue;
  double _springSachet = CostsConstants.defaultSpringSachet;

  // ===== Material Types Section =====
  Map<String, double> _spongeTypes = {};
  Map<String, double> _dressTypes = {};
  Map<String, double> _footerTypes = {};

  // Map to store IDs of loaded costs
  Map<String, int> _ids = {};

  bool _isLoaded = false;
  bool _isLoading = false;
  String? _error;

  // ========== GETTERS ==========

  double get ribbon36mmPrice => _ribbon36mmPrice;
  double get ribbon18mmPrice => _ribbon18mmPrice;
  double get ribbon3DPrice => _ribbon3DPrice;
  double get chainPrice => _chainPrice;
  double get elasticPrice => _elasticPrice;
  double get corners => _corners;
  double get tickets => _tickets;
  double get plastic => _plastic;
  double get rent => _rent;
  double get employees => _employees;
  double get diesel => _diesel;
  double get electricity => _electricity;
  // Alias if needed
  double get electrical => _electricity;
  int get production => _production;
  double get water => _water;
  double get internet => _internet;
  double get maintenance => _maintenance;
  double get transport => _transport;
  double get marketing => _marketing;
  double get otherMonthly => _otherMonthly;
  double get threadPrice => _threadPrice;
  double get scotch => _scotch;
  double get otherPackaging => _otherPackaging;
  double get springValue => _springValue;
  double get springSachet => _springSachet;
  Map<String, double> get spongeTypes => _spongeTypes;
  Map<String, double> get dressTypes => _dressTypes;
  Map<String, double> get footerTypes => _footerTypes;
  bool get isLoaded => _isLoaded;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// إجمالي التكاليف الشهرية
  double get totalMonthlyCosts =>
      _rent +
      _employees +
      _diesel +
      _electricity +
      _water +
      _internet +
      _maintenance +
      _transport +
      _marketing +
      _otherMonthly;

  /// التكلفة اليومية
  double get dailyCost => totalMonthlyCosts / 26;

  /// التكلفة لكل وحدة إنتاج
  double get costPerUnit => _production > 0 ? dailyCost / _production : 0;

  // ========== API INTEGRATION ==========

  /// Load costs from API (always fetches fresh data)
  Future<void> fetchCosts() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await CostsApiService.fetchCosts();

      if (response.success && response.data != null) {
        final data = response.data!;

        // Save IDs
        _ids = data.ids;

        // Monthly costs - keys from DB
        _rent = data.getMonthly('defaultRent', data.getMonthly('rent', _rent));
        _employees = data.getMonthly(
          'defaultEmployees',
          data.getMonthly('employees', _employees),
        );
        _diesel = data.getMonthly(
          'defaultDiesel',
          data.getMonthly('diesel', _diesel),
        );
        _electricity = data.getMonthly(
          'defaultElectricity',
          data.getMonthly('electricity', _electricity),
        );
        _production = (data.getMonthly(
          'defaultProduction',
          data.getMonthly('production', _production.toDouble()),
        )).toInt();

        // Packaging costs
        _corners = data.getPackaging(
          'defaultCorners',
          data.getPackaging('corners', _corners),
        );
        _tickets = data.getPackaging(
          'defaultTickets',
          data.getPackaging('tickets', _tickets),
        );
        _plastic = data.getPackaging(
          'defaultPlastic',
          data.getPackaging('plastic', _plastic),
        );

        // Sfifa costs
        _ribbon36mmPrice = data.getSfifa(
          'defaultRibbon36mm',
          data.getSfifa('ribbon36mmPrice', _ribbon36mmPrice),
        );
        _ribbon18mmPrice = data.getSfifa(
          'defaultRibbon18mm',
          data.getSfifa('ribbon18mmPrice', _ribbon18mmPrice),
        );
        _ribbon3DPrice = data.getSfifa(
          'defaultRibbon3D',
          data.getSfifa('ribbon3DPrice', _ribbon3DPrice),
        );
        _chainPrice = data.getSfifa(
          'defaultChainPrice',
          data.getSfifa('chainPrice', _chainPrice),
        );
        _elasticPrice = data.getSfifa(
          'defaultElasticPrice',
          data.getSfifa('elasticPrice', _elasticPrice),
        );

        // Springs costs
        _springValue = data.getSprings(
          'روسول عادي',
          data.getSprings('defaultSpringValue', _springValue),
        );
        _springSachet = data.getSprings(
          'روسول ساشي',
          data.getSprings('defaultSpringSachet', _springSachet),
        );

        // New Monthly Fields
        _water = data.getMonthly(
          'defaultWater',
          data.getMonthly('water', _water),
        );
        _internet = data.getMonthly(
          'defaultInternet',
          data.getMonthly('internet', _internet),
        );
        _maintenance = data.getMonthly(
          'defaultMaintenance',
          data.getMonthly('maintenance', _maintenance),
        );
        _transport = data.getMonthly(
          'defaultTransport',
          data.getMonthly('transport', _transport),
        );
        _marketing = data.getMonthly(
          'defaultMarketing',
          data.getMonthly('marketing', _marketing),
        );
        _otherMonthly = data.getMonthly(
          'defaultOtherMonthly',
          data.getMonthly('otherMonthly', _otherMonthly),
        );

        // New Sfifa Fields
        _threadPrice = data.getSfifa(
          'defaultThread',
          data.getSfifa('thread', _threadPrice),
        );

        // New Packaging Fields
        _scotch = data.getPackaging(
          'defaultScotch',
          data.getPackaging('scotch', _scotch),
        );
        _otherPackaging = data.getPackaging(
          'defaultOtherPackaging',
          data.getPackaging('otherPackaging', _otherPackaging),
        );

        // Material Types
        _spongeTypes = Map.from(data.spongeTypes);
        _dressTypes = Map.from(data.dressTypes);
        _footerTypes = Map.from(data.footerTypes);

        _isLoaded = true;
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching costs: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Timers for debouncing API calls per field
  final Map<String, Timer> _debounceTimers = {};

  /// Update single cost in API with debounce
  Future<void> _updateCost(String name, String category, dynamic value) async {
    // Cancel previous timer for THIS specific field
    if (_debounceTimers[name]?.isActive ?? false) {
      _debounceTimers[name]!.cancel();
    }

    // Set new timer for this field
    _debounceTimers[name] = Timer(const Duration(milliseconds: 1000), () async {
      try {
        final int? id = _ids[name];
        await CostsApiService.updateCost(
          id: id,
          name: name,
          category: category,
          value: value,
        );
        _debounceTimers.remove(name);
      } catch (e) {
        debugPrint('Failed to update cost $name: $e');
      }
    });
  }

  @override
  void dispose() {
    for (var timer in _debounceTimers.values) {
      if (timer.isActive) timer.cancel();
    }
    _debounceTimers.clear();
    super.dispose();
  }

  // ========== SETTERS ==========

  void setRibbon36mmPrice(double value) {
    _ribbon36mmPrice = value;
    _updateCost('defaultRibbon36mm', 'sfifa', value);
    notifyListeners();
  }

  void setRibbon18mmPrice(double value) {
    _ribbon18mmPrice = value;
    _updateCost('defaultRibbon18mm', 'sfifa', value);
    notifyListeners();
  }

  void setRibbon3DPrice(double value) {
    _ribbon3DPrice = value;
    _updateCost('defaultRibbon3D', 'sfifa', value);
    notifyListeners();
  }

  void setChainPrice(double value) {
    _chainPrice = value;
    _updateCost('defaultChainPrice', 'sfifa', value);
    notifyListeners();
  }

  void setElasticPrice(double value) {
    _elasticPrice = value;
    _updateCost('defaultElasticPrice', 'sfifa', value);
    notifyListeners();
  }

  void setCorners(double value) {
    _corners = value;
    _updateCost('defaultCorners', 'Packaging Defaults', value);
    notifyListeners();
  }

  void setTickets(double value) {
    _tickets = value;
    _updateCost('defaultTickets', 'Packaging Defaults', value);
    notifyListeners();
  }

  void setPlastic(double value) {
    _plastic = value;
    _updateCost('defaultPlastic', 'Packaging Defaults', value);
    notifyListeners();
  }

  void setRent(double value) {
    _rent = value;
    _updateCost('defaultRent', 'Cost Defaults', value);
    notifyListeners();
  }

  void setEmployees(double value) {
    _employees = value;
    _updateCost('defaultEmployees', 'Cost Defaults', value);
    notifyListeners();
  }

  void setDiesel(double value) {
    _diesel = value;
    _updateCost('defaultDiesel', 'Cost Defaults', value);
    notifyListeners();
  }

  void setElectricity(double value) {
    _electricity = value;
    _updateCost('defaultElectricity', 'Cost Defaults', value);
    notifyListeners();
  }

  void setProduction(int value) {
    _production = value.clamp(1, 10000);
    _updateCost('defaultProduction', 'Cost Defaults', value.toDouble());
    notifyListeners();
  }

  void setSpringValue(double value) {
    _springValue = value;
    _updateCost('روسول عادي', 'spring', value);
    notifyListeners();
  }

  void setSpringSachet(double value) {
    _springSachet = value;
    _updateCost('روسول ساشي', 'spring', value);
    notifyListeners();
  }

  // New Setters
  void setWater(double value) {
    _water = value;
    _updateCost('defaultWater', 'Cost Defaults', value);
    notifyListeners();
  }

  void setInternet(double value) {
    _internet = value;
    _updateCost('defaultInternet', 'Cost Defaults', value);
    notifyListeners();
  }

  void setMaintenance(double value) {
    _maintenance = value;
    _updateCost('defaultMaintenance', 'Cost Defaults', value);
    notifyListeners();
  }

  void setTransport(double value) {
    _transport = value;
    _updateCost('defaultTransport', 'Cost Defaults', value);
    notifyListeners();
  }

  void setMarketing(double value) {
    _marketing = value;
    _updateCost('defaultMarketing', 'Cost Defaults', value);
    notifyListeners();
  }

  void setOtherMonthly(double value) {
    _otherMonthly = value;
    _updateCost('defaultOtherMonthly', 'Cost Defaults', value);
    notifyListeners();
  }

  void setScotch(double value) {
    _scotch = value;
    _updateCost('defaultScotch', 'Packaging Defaults', value);
    notifyListeners();
  }

  void setOtherPackaging(double value) {
    _otherPackaging = value;
    _updateCost('defaultOtherPackaging', 'Packaging Defaults', value);
    notifyListeners();
  }

  void setThreadPrice(double value) {
    _threadPrice = value;
    _updateCost('defaultThread', 'sfifa', value);
    notifyListeners();
  }

  // ========== MATERIAL TYPE SETTERS ==========

  /// Update sponge type price
  void setSpongeTypePrice(String name, double value) {
    _spongeTypes[name] = value;
    _updateCost(name, 'spongeTypes', value);
    notifyListeners();
  }

  /// Update dress type price
  void setDressTypePrice(String name, double value) {
    _dressTypes[name] = value;
    _updateCost(name, 'dressTypes', value);
    notifyListeners();
  }

  /// Update footer type price
  void setFooterTypePrice(String name, double value) {
    _footerTypes[name] = value;
    _updateCost(name, 'footerTypes', value);
    notifyListeners();
  }

  /// إعادة تعيين جميع القيم للافتراضية (محلياً فقط لأننا لا نريد مسح قاعدة البيانات)
  /// أو يمكن حذف هذه الدالة إذا كانت غير مطلوبة
  void resetToDefaults() {
    _ribbon36mmPrice = CostsConstants.defaultRibbon36mm;
    _ribbon18mmPrice = CostsConstants.defaultRibbon18mm;
    _ribbon3DPrice = CostsConstants.defaultRibbon3D;
    _chainPrice = CostsConstants.defaultChainPrice;
    _elasticPrice = CostsConstants.defaultElasticPrice;
    _corners = CostsConstants.defaultCorners;
    _tickets = CostsConstants.defaultTickets;
    _plastic = CostsConstants.defaultPlastic;
    _rent = CostsConstants.defaultRent;
    _employees = CostsConstants.defaultEmployees;
    _diesel = CostsConstants.defaultDiesel;
    _electricity = CostsConstants.defaultElectricity;
    _production = CostsConstants.defaultProduction;
    _springValue = CostsConstants.defaultSpringValue;
    _springSachet = CostsConstants.defaultSpringSachet;
    _water = CostsConstants.defaultWater;
    _internet = CostsConstants.defaultInternet;
    _maintenance = CostsConstants.defaultMaintenance;
    _transport = CostsConstants.defaultTransport;
    _marketing = CostsConstants.defaultMarketing;
    _otherMonthly = CostsConstants.defaultOtherMonthly;
    _scotch = CostsConstants.defaultScotch;
    _otherPackaging = CostsConstants.defaultOtherPackaging;
    _threadPrice = CostsConstants.defaultThread;

    notifyListeners();
  }
}
