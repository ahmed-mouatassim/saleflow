import 'package:flutter/material.dart';
import '../model/settings_model.dart';
import '../data/settings_data.dart';
import '../../../core/loading_state.dart';

/// Settings Provider
/// State management for settings, profile, and permissions
class SettingsProvider extends ChangeNotifier with BaseProviderState {
  AppSettings _settings = SettingsData.defaultSettings;
  UserProfile _currentUser = SettingsData.currentUser;
  List<AppNotification> _notifications = [];
  List<UserRole> _roles = [];
  LoadingState _loadingState = LoadingState.initial;
  String? _errorMessage;
  bool _isSaving = false;

  // Selected items for editing
  UserRole? _selectedRole;

  SettingsProvider() {
    _initialize();
  }

  void _initialize() {
    _notifications = List.from(SettingsData.sampleNotifications);
    _roles = List.from(SettingsData.defaultRoles);
    _loadingState = LoadingState.success;
  }

  // Getters
  AppSettings get settings => _settings;
  UserProfile get currentUser => _currentUser;
  List<AppNotification> get notifications => _notifications;
  List<UserRole> get roles => _roles;
  UserRole? get selectedRole => _selectedRole;
  bool get isSaving => _isSaving;

  @override
  LoadingState get loadingState => _loadingState;

  @override
  String? get errorMessage => _errorMessage;

  /// Unread notifications count
  int get unreadNotificationsCount =>
      _notifications.where((n) => !n.isRead).length;

  /// Get permissions grouped by category
  Map<String, List<Permission>> get permissionsByCategory {
    final Map<String, List<Permission>> grouped = {};
    for (final permission in SettingsData.allPermissions) {
      grouped.putIfAbsent(permission.category, () => []).add(permission);
    }
    return grouped;
  }

  // Settings Actions
  void updateSettings(AppSettings newSettings) {
    _settings = newSettings;
    notifyListeners();
  }

  void toggleDarkMode() {
    _settings = _settings.copyWith(darkMode: !_settings.darkMode);
    notifyListeners();
  }

  void toggleNotifications() {
    _settings = _settings.copyWith(notifications: !_settings.notifications);
    notifyListeners();
  }

  void toggleSound() {
    _settings = _settings.copyWith(soundEnabled: !_settings.soundEnabled);
    notifyListeners();
  }

  void toggleAutoBackup() {
    _settings = _settings.copyWith(autoBackup: !_settings.autoBackup);
    notifyListeners();
  }

  void setLanguage(String language) {
    _settings = _settings.copyWith(language: language);
    notifyListeners();
  }

  void setCurrency(String currency) {
    _settings = _settings.copyWith(currency: currency);
    notifyListeners();
  }

  // Profile Actions
  Future<bool> updateProfile({
    String? name,
    String? email,
    String? phone,
  }) async {
    _isSaving = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 600));

    _currentUser = _currentUser.copyWith(
      name: name,
      email: email,
      phone: phone,
    );

    _isSaving = false;
    notifyListeners();
    return true;
  }

  // Notifications Actions
  void markNotificationAsRead(int id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllNotificationsAsRead() {
    _notifications = _notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
    notifyListeners();
  }

  void deleteNotification(int id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  void clearAllNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  // Roles & Permissions Actions
  void selectRole(UserRole? role) {
    _selectedRole = role;
    notifyListeners();
  }

  void clearRoleSelection() {
    _selectedRole = null;
    notifyListeners();
  }

  Future<bool> saveRole(UserRole role, BuildContext context) async {
    _isSaving = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    final index = _roles.indexWhere((r) => r.id == role.id);
    if (index != -1) {
      _roles[index] = role;
    } else {
      // New role
      final newRole = UserRole(
        id: DateTime.now().millisecondsSinceEpoch,
        name: role.name,
        description: role.description,
        permissions: role.permissions,
        isSystem: false,
      );
      _roles.add(newRole);
    }

    _selectedRole = null;
    _isSaving = false;
    notifyListeners();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ الدور بنجاح'),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    return true;
  }

  Future<bool> deleteRole(int roleId, BuildContext context) async {
    final role = _roles.firstWhere((r) => r.id == roleId);
    if (role.isSystem) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا يمكن حذف الأدوار الأساسية'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }

    _isSaving = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    _roles.removeWhere((r) => r.id == roleId);

    _isSaving = false;
    notifyListeners();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حذف الدور بنجاح'),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    return true;
  }

  /// Clear error state
  void clearError() {
    _errorMessage = null;
    if (_loadingState == LoadingState.error) {
      _loadingState = LoadingState.initial;
    }
    notifyListeners();
  }
}
