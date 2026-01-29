import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/costs_constants.dart';

/// ===== Costs Provider =====
/// Manages all fixed costs that are shared across the app
/// Persists values to SharedPreferences
class CostsProvider extends ChangeNotifier {
  // ===== Sfifa Section =====
  double _ribbon36mmPrice = CostsConstants.defaultRibbon36mm;
  double _ribbon18mmPrice = CostsConstants.defaultRibbon18mm;
  double _ribbon3DPrice = CostsConstants.defaultRibbon3D;
  double _chainPrice = CostsConstants.defaultChainPrice;
  double _elasticPrice = CostsConstants.defaultElasticPrice;

  // ===== Packaging Section =====
  double _corners = CostsConstants.defaultCorners;
  double _tickets = CostsConstants.defaultTickets;
  double _largeFlyer = CostsConstants.defaultLargeFlyer;
  double _smallFlyer = CostsConstants.defaultSmallFlyer;
  double _plastic = CostsConstants.defaultPlastic;
  double _scotch = CostsConstants.defaultScotch;
  double _glue = CostsConstants.defaultGlue;
  double _adding = CostsConstants.defaultAdding;

  // ===== Monthly Costs Section =====
  double _rent = CostsConstants.defaultRent;
  double _employees = CostsConstants.defaultEmployees;
  double _diesel = CostsConstants.defaultDiesel;
  double _cnss = CostsConstants.defaultCnss;
  double _tva = CostsConstants.defaultTva;
  double _electricity = CostsConstants.defaultElectricity;
  double _phone = CostsConstants.defaultPhone;
  double _desktop = CostsConstants.defaultDesktop;
  double _machineFix = CostsConstants.defaultMachineFix;
  double _repairs = CostsConstants.defaultRepairs;
  int _production = CostsConstants.defaultProduction;

  // ===== Springs Section =====
  double _springValue = CostsConstants.defaultSpringValue;
  double _springSachetValue = CostsConstants.defaultSpringSachetValue;

  bool _isLoaded = false;

  // ========== GETTERS ==========

  double get ribbon36mmPrice => _ribbon36mmPrice;
  double get ribbon18mmPrice => _ribbon18mmPrice;
  double get ribbon3DPrice => _ribbon3DPrice;
  double get chainPrice => _chainPrice;
  double get elasticPrice => _elasticPrice;
  double get corners => _corners;
  double get tickets => _tickets;
  double get largeFlyer => _largeFlyer;
  double get smallFlyer => _smallFlyer;
  double get plastic => _plastic;
  double get scotch => _scotch;
  double get glue => _glue;
  double get adding => _adding;
  double get rent => _rent;
  double get employees => _employees;
  double get diesel => _diesel;
  double get cnss => _cnss;
  double get tva => _tva;
  double get electricity => _electricity;
  double get phone => _phone;
  double get desktop => _desktop;
  double get machineFix => _machineFix;
  double get repairs => _repairs;
  int get production => _production;
  double get springValue => _springValue;
  double get springSachetValue => _springSachetValue;
  bool get isLoaded => _isLoaded;

  /// إجمالي التكاليف الشهرية
  double get totalMonthlyCosts =>
      _rent +
      _employees +
      _diesel +
      _cnss +
      _tva +
      _electricity +
      _phone +
      _desktop +
      _machineFix +
      _repairs;

  /// التكلفة اليومية
  double get dailyCost => totalMonthlyCosts / 26;

  /// التكلفة لكل وحدة إنتاج
  double get costPerUnit => _production > 0 ? dailyCost / _production : 0;

  // ========== LOAD/SAVE ==========

  Future<void> loadFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _ribbon36mmPrice =
          prefs.getDouble('ribbon36mmPrice') ??
          CostsConstants.defaultRibbon36mm;
      _ribbon18mmPrice =
          prefs.getDouble('ribbon18mmPrice') ??
          CostsConstants.defaultRibbon18mm;
      _ribbon3DPrice =
          prefs.getDouble('ribbon3DPrice') ?? CostsConstants.defaultRibbon3D;
      _chainPrice =
          prefs.getDouble('chainPrice') ?? CostsConstants.defaultChainPrice;
      _elasticPrice =
          prefs.getDouble('elasticPrice') ?? CostsConstants.defaultElasticPrice;
      _corners = prefs.getDouble('corners') ?? CostsConstants.defaultCorners;
      _tickets = prefs.getDouble('tickets') ?? CostsConstants.defaultTickets;
      _largeFlyer =
          prefs.getDouble('largeFlyer') ?? CostsConstants.defaultLargeFlyer;
      _smallFlyer =
          prefs.getDouble('smallFlyer') ?? CostsConstants.defaultSmallFlyer;
      _plastic = prefs.getDouble('plastic') ?? CostsConstants.defaultPlastic;
      _scotch = prefs.getDouble('scotch') ?? CostsConstants.defaultScotch;
      _glue = prefs.getDouble('glue') ?? CostsConstants.defaultGlue;
      _adding = prefs.getDouble('adding') ?? CostsConstants.defaultAdding;
      _rent = prefs.getDouble('rent') ?? CostsConstants.defaultRent;
      _employees =
          prefs.getDouble('employees') ?? CostsConstants.defaultEmployees;
      _diesel = prefs.getDouble('diesel') ?? CostsConstants.defaultDiesel;
      _cnss = prefs.getDouble('cnss') ?? CostsConstants.defaultCnss;
      _tva = prefs.getDouble('tva') ?? CostsConstants.defaultTva;
      _electricity =
          prefs.getDouble('electricity') ?? CostsConstants.defaultElectricity;
      _phone = prefs.getDouble('phone') ?? CostsConstants.defaultPhone;
      _desktop = prefs.getDouble('desktop') ?? CostsConstants.defaultDesktop;
      _machineFix =
          prefs.getDouble('machineFix') ?? CostsConstants.defaultMachineFix;
      _repairs = prefs.getDouble('repairs') ?? CostsConstants.defaultRepairs;
      _production =
          prefs.getInt('production') ?? CostsConstants.defaultProduction;
      _springValue =
          prefs.getDouble('springValue') ?? CostsConstants.defaultSpringValue;
      _springSachetValue =
          prefs.getDouble('springSachetValue') ??
          CostsConstants.defaultSpringSachetValue;
    } catch (e) {
      // SharedPreferences غير متوفرة - استخدام القيم الافتراضية
      debugPrint('SharedPreferences not available: $e');
    }

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _saveToPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setDouble('ribbon36mmPrice', _ribbon36mmPrice);
      await prefs.setDouble('ribbon18mmPrice', _ribbon18mmPrice);
      await prefs.setDouble('ribbon3DPrice', _ribbon3DPrice);
      await prefs.setDouble('chainPrice', _chainPrice);
      await prefs.setDouble('elasticPrice', _elasticPrice);
      await prefs.setDouble('corners', _corners);
      await prefs.setDouble('tickets', _tickets);
      await prefs.setDouble('largeFlyer', _largeFlyer);
      await prefs.setDouble('smallFlyer', _smallFlyer);
      await prefs.setDouble('plastic', _plastic);
      await prefs.setDouble('scotch', _scotch);
      await prefs.setDouble('glue', _glue);
      await prefs.setDouble('adding', _adding);
      await prefs.setDouble('rent', _rent);
      await prefs.setDouble('employees', _employees);
      await prefs.setDouble('diesel', _diesel);
      await prefs.setDouble('cnss', _cnss);
      await prefs.setDouble('tva', _tva);
      await prefs.setDouble('electricity', _electricity);
      await prefs.setDouble('phone', _phone);
      await prefs.setDouble('desktop', _desktop);
      await prefs.setDouble('machineFix', _machineFix);
      await prefs.setDouble('repairs', _repairs);
      await prefs.setInt('production', _production);
      await prefs.setDouble('springValue', _springValue);
      await prefs.setDouble('springSachetValue', _springSachetValue);
    } catch (e) {
      // تجاهل الأخطاء - القيم محفوظة في الذاكرة
      debugPrint('Failed to save preferences: $e');
    }
  }

  // ========== SETTERS ==========

  void setRibbon36mmPrice(double value) {
    _ribbon36mmPrice = value;
    _saveToPreferences();
    notifyListeners();
  }

  void setRibbon18mmPrice(double value) {
    _ribbon18mmPrice = value;
    _saveToPreferences();
    notifyListeners();
  }

  void setRibbon3DPrice(double value) {
    _ribbon3DPrice = value;
    _saveToPreferences();
    notifyListeners();
  }

  void setChainPrice(double value) {
    _chainPrice = value;
    _saveToPreferences();
    notifyListeners();
  }

  void setElasticPrice(double value) {
    _elasticPrice = value;
    _saveToPreferences();
    notifyListeners();
  }

  void setCorners(double value) {
    _corners = value;
    _saveToPreferences();
    notifyListeners();
  }

  void setTickets(double value) {
    _tickets = value;
    _saveToPreferences();
    notifyListeners();
  }

  void setLargeFlyer(double value) {
    _largeFlyer = value;
    _saveToPreferences();
    notifyListeners();
  }

  void setSmallFlyer(double value) {
    _smallFlyer = value;
    _saveToPreferences();
    notifyListeners();
  }

  void setPlastic(double value) {
    _plastic = value;
    _saveToPreferences();
    notifyListeners();
  }

  void setScotch(double value) {
    _scotch = value;
    _saveToPreferences();
    notifyListeners();
  }

  void setGlue(double value) {
    _glue = value;
    _saveToPreferences();
    notifyListeners();
  }

  void setAdding(double value) {
    _adding = value;
    _saveToPreferences();
    notifyListeners();
  }

  void setRent(double value) {
    _rent = value;
    _saveToPreferences();
    notifyListeners();
  }

  void setEmployees(double value) {
    _employees = value;
    _saveToPreferences();
    notifyListeners();
  }

  void setDiesel(double value) {
    _diesel = value;
    _saveToPreferences();
    notifyListeners();
  }

  void setCnss(double value) {
    _cnss = value;
    _saveToPreferences();
    notifyListeners();
  }

  void setTva(double value) {
    _tva = value;
    _saveToPreferences();
    notifyListeners();
  }

  void setElectricity(double value) {
    _electricity = value;
    _saveToPreferences();
    notifyListeners();
  }

  void setPhone(double value) {
    _phone = value;
    _saveToPreferences();
    notifyListeners();
  }

  void setDesktop(double value) {
    _desktop = value;
    _saveToPreferences();
    notifyListeners();
  }

  void setMachineFix(double value) {
    _machineFix = value;
    _saveToPreferences();
    notifyListeners();
  }

  void setRepairs(double value) {
    _repairs = value;
    _saveToPreferences();
    notifyListeners();
  }

  void setProduction(int value) {
    _production = value.clamp(1, 1000);
    _saveToPreferences();
    notifyListeners();
  }

  void setSpringValue(double value) {
    _springValue = value;
    _saveToPreferences();
    notifyListeners();
  }

  void setSpringSachetValue(double value) {
    _springSachetValue = value;
    _saveToPreferences();
    notifyListeners();
  }

  /// إعادة تعيين جميع القيم للافتراضية
  void resetToDefaults() {
    _ribbon36mmPrice = CostsConstants.defaultRibbon36mm;
    _ribbon18mmPrice = CostsConstants.defaultRibbon18mm;
    _ribbon3DPrice = CostsConstants.defaultRibbon3D;
    _chainPrice = CostsConstants.defaultChainPrice;
    _elasticPrice = CostsConstants.defaultElasticPrice;
    _corners = CostsConstants.defaultCorners;
    _tickets = CostsConstants.defaultTickets;
    _largeFlyer = CostsConstants.defaultLargeFlyer;
    _smallFlyer = CostsConstants.defaultSmallFlyer;
    _plastic = CostsConstants.defaultPlastic;
    _scotch = CostsConstants.defaultScotch;
    _glue = CostsConstants.defaultGlue;
    _adding = CostsConstants.defaultAdding;
    _rent = CostsConstants.defaultRent;
    _employees = CostsConstants.defaultEmployees;
    _diesel = CostsConstants.defaultDiesel;
    _cnss = CostsConstants.defaultCnss;
    _tva = CostsConstants.defaultTva;
    _electricity = CostsConstants.defaultElectricity;
    _phone = CostsConstants.defaultPhone;
    _desktop = CostsConstants.defaultDesktop;
    _machineFix = CostsConstants.defaultMachineFix;
    _repairs = CostsConstants.defaultRepairs;
    _production = CostsConstants.defaultProduction;
    _springValue = CostsConstants.defaultSpringValue;
    _springSachetValue = CostsConstants.defaultSpringSachetValue;
    _saveToPreferences();
    notifyListeners();
  }
}
