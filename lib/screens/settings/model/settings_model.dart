/// Settings Model
/// Data classes for application settings
class AppSettings {
  final bool darkMode;
  final String language;
  final bool notifications;
  final bool soundEnabled;
  final String currency;
  final String dateFormat;
  final bool autoBackup;
  final int backupFrequencyDays;

  const AppSettings({
    this.darkMode = true,
    this.language = 'ar',
    this.notifications = true,
    this.soundEnabled = true,
    this.currency = 'MAD',
    this.dateFormat = 'dd/MM/yyyy',
    this.autoBackup = true,
    this.backupFrequencyDays = 7,
  });

  AppSettings copyWith({
    bool? darkMode,
    String? language,
    bool? notifications,
    bool? soundEnabled,
    String? currency,
    String? dateFormat,
    bool? autoBackup,
    int? backupFrequencyDays,
  }) {
    return AppSettings(
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
      notifications: notifications ?? this.notifications,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      currency: currency ?? this.currency,
      dateFormat: dateFormat ?? this.dateFormat,
      autoBackup: autoBackup ?? this.autoBackup,
      backupFrequencyDays: backupFrequencyDays ?? this.backupFrequencyDays,
    );
  }
}

/// Notification Model
class AppNotification {
  final int id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      message: message,
      type: type,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

enum NotificationType { info, warning, success, error }

/// User Profile Model
class UserProfile {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String avatarUrl;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final List<String> permissions;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.avatarUrl = '',
    required this.createdAt,
    required this.lastLoginAt,
    this.permissions = const [],
  });

  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? role,
    String? avatarUrl,
    List<String>? permissions,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
      permissions: permissions ?? this.permissions,
    );
  }
}

/// Role Model for Permissions Management
class UserRole {
  final int id;
  final String name;
  final String description;
  final List<String> permissions;
  final bool isSystem;

  const UserRole({
    required this.id,
    required this.name,
    required this.description,
    required this.permissions,
    this.isSystem = false,
  });

  UserRole copyWith({
    String? name,
    String? description,
    List<String>? permissions,
  }) {
    return UserRole(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      permissions: permissions ?? this.permissions,
      isSystem: isSystem,
    );
  }
}

/// Permission Definition
class Permission {
  final String id;
  final String name;
  final String description;
  final String category;

  const Permission({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
  });
}
