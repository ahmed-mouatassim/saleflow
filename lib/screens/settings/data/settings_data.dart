import '../model/settings_model.dart';

/// Settings Data
/// Static data for settings and app configuration
class SettingsData {
  SettingsData._();

  /// Default app settings
  static const AppSettings defaultSettings = AppSettings();

  /// Current user profile
  static final UserProfile currentUser = UserProfile(
    id: 1,
    name: 'أنس الراجي',
    email: 'anas@saleflow.ma',
    phone: '+212 600 000 000',
    role: 'مدير النظام',
    createdAt: DateTime(2024, 1, 1),
    lastLoginAt: DateTime.now(),
    permissions: [
      'clients.view',
      'clients.create',
      'clients.edit',
      'clients.delete',
      'products.view',
      'products.create',
      'products.edit',
      'products.delete',
      'orders.view',
      'orders.create',
      'orders.edit',
      'orders.delete',
      'transactions.view',
      'transactions.create',
      'transactions.edit',
      'settings.view',
      'settings.edit',
      'users.manage',
      'roles.manage',
    ],
  );

  /// Sample notifications
  static final List<AppNotification> sampleNotifications = [
    AppNotification(
      id: 1,
      title: 'طلب جديد',
      message: 'تم استلام طلب جديد من العميل محمد أحمد',
      type: NotificationType.info,
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    AppNotification(
      id: 2,
      title: 'نقص في المخزون',
      message: 'المنتج "مفرش قطني 200x240" وصل للحد الأدنى',
      type: NotificationType.warning,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    AppNotification(
      id: 3,
      title: 'تحصيل ناجح',
      message: 'تم تحصيل 15,000 د.م من العميل أحمد بنعلي',
      type: NotificationType.success,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    AppNotification(
      id: 4,
      title: 'تجاوز الائتمان',
      message: 'العميل خالد المنصوري تجاوز حد الائتمان المسموح',
      type: NotificationType.error,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  /// Available permissions
  static const List<Permission> allPermissions = [
    // Clients permissions
    Permission(
      id: 'clients.view',
      name: 'عرض العملاء',
      description: 'إمكانية عرض قائمة العملاء وتفاصيلهم',
      category: 'العملاء',
    ),
    Permission(
      id: 'clients.create',
      name: 'إضافة عميل',
      description: 'إمكانية إضافة عملاء جدد',
      category: 'العملاء',
    ),
    Permission(
      id: 'clients.edit',
      name: 'تعديل العملاء',
      description: 'إمكانية تعديل بيانات العملاء',
      category: 'العملاء',
    ),
    Permission(
      id: 'clients.delete',
      name: 'حذف العملاء',
      description: 'إمكانية حذف العملاء من النظام',
      category: 'العملاء',
    ),
    // Products permissions
    Permission(
      id: 'products.view',
      name: 'عرض المنتجات',
      description: 'إمكانية عرض قائمة المنتجات والمخزون',
      category: 'المنتجات',
    ),
    Permission(
      id: 'products.create',
      name: 'إضافة منتج',
      description: 'إمكانية إضافة منتجات جديدة',
      category: 'المنتجات',
    ),
    Permission(
      id: 'products.edit',
      name: 'تعديل المنتجات',
      description: 'إمكانية تعديل بيانات المنتجات',
      category: 'المنتجات',
    ),
    Permission(
      id: 'products.delete',
      name: 'حذف المنتجات',
      description: 'إمكانية حذف المنتجات من النظام',
      category: 'المنتجات',
    ),
    // Orders permissions
    Permission(
      id: 'orders.view',
      name: 'عرض الطلبات',
      description: 'إمكانية عرض قائمة الطلبات والمبيعات',
      category: 'الطلبات',
    ),
    Permission(
      id: 'orders.create',
      name: 'إنشاء طلب',
      description: 'إمكانية إنشاء طلبات جديدة',
      category: 'الطلبات',
    ),
    Permission(
      id: 'orders.edit',
      name: 'تعديل الطلبات',
      description: 'إمكانية تعديل الطلبات الحالية',
      category: 'الطلبات',
    ),
    Permission(
      id: 'orders.delete',
      name: 'حذف الطلبات',
      description: 'إمكانية حذف أو إلغاء الطلبات',
      category: 'الطلبات',
    ),
    // Transactions permissions
    Permission(
      id: 'transactions.view',
      name: 'عرض المعاملات',
      description: 'إمكانية عرض المعاملات المالية',
      category: 'المعاملات',
    ),
    Permission(
      id: 'transactions.create',
      name: 'تسجيل دفعة',
      description: 'إمكانية تسجيل دفعات جديدة',
      category: 'المعاملات',
    ),
    Permission(
      id: 'transactions.edit',
      name: 'تعديل المعاملات',
      description: 'إمكانية تعديل المعاملات المالية',
      category: 'المعاملات',
    ),
    // Settings permissions
    Permission(
      id: 'settings.view',
      name: 'عرض الإعدادات',
      description: 'إمكانية عرض إعدادات النظام',
      category: 'النظام',
    ),
    Permission(
      id: 'settings.edit',
      name: 'تعديل الإعدادات',
      description: 'إمكانية تعديل إعدادات النظام',
      category: 'النظام',
    ),
    Permission(
      id: 'users.manage',
      name: 'إدارة المستخدمين',
      description: 'إمكانية إضافة وتعديل وحذف المستخدمين',
      category: 'النظام',
    ),
    Permission(
      id: 'roles.manage',
      name: 'إدارة الصلاحيات',
      description: 'إمكانية إنشاء وتعديل الأدوار والصلاحيات',
      category: 'النظام',
    ),
  ];

  /// Default roles
  static const List<UserRole> defaultRoles = [
    UserRole(
      id: 1,
      name: 'مدير النظام',
      description: 'صلاحيات كاملة على جميع أقسام النظام',
      permissions: [
        'clients.view',
        'clients.create',
        'clients.edit',
        'clients.delete',
        'products.view',
        'products.create',
        'products.edit',
        'products.delete',
        'orders.view',
        'orders.create',
        'orders.edit',
        'orders.delete',
        'transactions.view',
        'transactions.create',
        'transactions.edit',
        'settings.view',
        'settings.edit',
        'users.manage',
        'roles.manage',
      ],
      isSystem: true,
    ),
    UserRole(
      id: 2,
      name: 'مدير المبيعات',
      description: 'إدارة العملاء والطلبات والمعاملات',
      permissions: [
        'clients.view',
        'clients.create',
        'clients.edit',
        'products.view',
        'orders.view',
        'orders.create',
        'orders.edit',
        'transactions.view',
        'transactions.create',
      ],
      isSystem: true,
    ),
    UserRole(
      id: 3,
      name: 'موظف مبيعات',
      description: 'إنشاء الطلبات وتسجيل الدفعات',
      permissions: [
        'clients.view',
        'clients.create',
        'products.view',
        'orders.view',
        'orders.create',
        'transactions.view',
        'transactions.create',
      ],
      isSystem: false,
    ),
    UserRole(
      id: 4,
      name: 'أمين المخزون',
      description: 'إدارة المنتجات والمخزون',
      permissions: ['products.view', 'products.create', 'products.edit'],
      isSystem: false,
    ),
    UserRole(
      id: 5,
      name: 'محاسب',
      description: 'عرض المعاملات المالية والتقارير',
      permissions: [
        'clients.view',
        'orders.view',
        'transactions.view',
        'transactions.create',
        'transactions.edit',
      ],
      isSystem: false,
    ),
  ];
}
