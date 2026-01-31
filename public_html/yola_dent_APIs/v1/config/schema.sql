-- ============================================
-- YolaDent Database Schema
-- قاعدة بيانات يولا دنت
-- ============================================

-- Create database
CREATE
DATABASE IF NOT EXISTS yola_dent CHARACTER
SET
    utf8mb4
COLLATE utf8mb4_unicode_ci;

USE yola_dent;

-- ============================================
-- Users Table - جدول المستخدمين
-- ============================================
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE COMMENT 'Login username',
    password_hash VARCHAR(255) NOT NULL COMMENT 'Hashed password',
    email VARCHAR(255) NULL COMMENT 'Email address',
    display_name VARCHAR(255) NOT NULL COMMENT 'Display name',
    role ENUM (
        'admin',
        'manager',
        'pharmacist',
        'storekeeper',
        'accountant',
        'viewer'
    ) NOT NULL DEFAULT 'viewer' COMMENT 'User role',
    phone VARCHAR(50) NULL COMMENT 'Phone number',
    warehouse_ids JSON NULL COMMENT 'Allowed warehouse IDs',
    is_active TINYINT (1) NOT NULL DEFAULT 1 COMMENT 'User status',
    session_token VARCHAR(100) NULL COMMENT 'Current session token',
    last_login DATETIME NULL COMMENT 'Last login timestamp',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by INT NULL COMMENT 'Created by user ID',
    INDEX idx_username (username),
    INDEX idx_role (
        role
    ),
    INDEX idx_active (is_active),
    INDEX idx_token (session_token)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4
COLLATE = utf8mb4_unicode_ci;

-- ============================================
-- Products Table - جدول المنتجات
-- ============================================
CREATE TABLE IF NOT EXISTS products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    reference VARCHAR(50) NOT NULL UNIQUE COMMENT 'SKU code - prefix is supplier abbreviation',
    name VARCHAR(255) NOT NULL COMMENT 'Full product description',
    quantity INT NOT NULL DEFAULT 0 COMMENT 'Current available stock',
    min_stock INT NOT NULL DEFAULT 5 COMMENT 'Minimum stock alert threshold',
    purchase_price DECIMAL(10, 2) NOT NULL COMMENT 'Cost price (ثمن الشراء)',
    selling_price DECIMAL(10, 2) NOT NULL COMMENT 'Selling price (ثمن البيع)',
    margin_rate DECIMAL(5, 2) NOT NULL DEFAULT 0.20 COMMENT 'Profit margin rate',
    supplier_id VARCHAR(50) NULL COMMENT 'Reference to supplier',
    supplier_name VARCHAR(100) NULL COMMENT 'Supplier name',
    category VARCHAR(100) NULL COMMENT 'Product category',
    barcode VARCHAR(100) NULL COMMENT 'Product barcode',
    unit VARCHAR(50) NULL COMMENT 'Unit of measurement',
    image_path VARCHAR(255) NULL COMMENT 'Product image path',
    notes TEXT NULL COMMENT 'Additional notes',
    is_active TINYINT (1) NOT NULL DEFAULT 1 COMMENT 'Product status',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_reference (reference),
    INDEX idx_category (category),
    INDEX idx_supplier (supplier_name),
    INDEX idx_active (is_active),
    INDEX idx_low_stock (quantity, min_stock)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4
COLLATE = utf8mb4_unicode_ci;

-- ============================================
-- Stock Transactions Table - جدول حركات المخزون
-- ============================================
CREATE TABLE IF NOT EXISTS stock_transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    type ENUM (
        'entry',
        'exit',
        'adjustment',
        'transfer',
        'return_in',
        'return_out',
        'sale',
        'purchase',
        'receive',
        'dispense',
        'expired',
        'damaged'
    ) NOT NULL,
    quantity INT NOT NULL,
    quantity_before INT NULL,
    quantity_after INT NULL,
    unit_price DECIMAL(10, 2) NULL,
    total_amount DECIMAL(10, 2) NULL,
    warehouse_id VARCHAR(50) NULL COMMENT 'Source warehouse',
    to_warehouse_id VARCHAR(50) NULL COMMENT 'Destination warehouse for transfers',
    reference_id VARCHAR(50) NULL COMMENT 'Related order/invoice ID',
    reason VARCHAR(255) NULL COMMENT 'Reason for transaction',
    document_id VARCHAR(50) NULL,
    document_number VARCHAR(50) NULL,
    supplier_id VARCHAR(50) NULL,
    supplier_name VARCHAR(100) NULL,
    customer_id VARCHAR(50) NULL,
    customer_name VARCHAR(100) NULL,
    performed_by VARCHAR(100) NULL COMMENT 'User who performed the transaction',
    approved_by VARCHAR(100) NULL COMMENT 'User who approved the transaction',
    requires_approval TINYINT (1) NOT NULL DEFAULT 0 COMMENT 'Transaction requires approval',
    is_approved TINYINT (1) NOT NULL DEFAULT 1 COMMENT 'Transaction approved status',
    notes TEXT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE,
    INDEX idx_product (product_id),
    INDEX idx_type (
        type
    ),
    INDEX idx_date (created_at),
    INDEX idx_warehouse (warehouse_id),
    INDEX idx_approval (
        requires_approval,
        is_approved
    )
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4
COLLATE = utf8mb4_unicode_ci;

-- ============================================
-- Clients Table - جدول الزبناء
-- ============================================
CREATE TABLE IF NOT EXISTS clients (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE COMMENT 'Client code (CLI-0001)',
    name VARCHAR(255) NOT NULL COMMENT 'Client name',
    phone VARCHAR(50) NULL COMMENT 'Phone number',
    email VARCHAR(255) NULL COMMENT 'Email address',
    address TEXT NULL COMMENT 'Address',
    city VARCHAR(100) NULL COMMENT 'City',
    notes TEXT NULL COMMENT 'Additional notes',
    total_purchases DECIMAL(12, 2) NOT NULL DEFAULT 0 COMMENT 'Total purchases amount',
    total_paid DECIMAL(12, 2) NOT NULL DEFAULT 0 COMMENT 'Total paid amount',
    is_active TINYINT (1) NOT NULL DEFAULT 1 COMMENT 'Client status',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_code (code),
    INDEX idx_name (name),
    INDEX idx_city (city),
    INDEX idx_active (is_active)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4
COLLATE = utf8mb4_unicode_ci;

-- ============================================
-- Client Transactions Table - جدول حركات الزبناء
-- ============================================
CREATE TABLE IF NOT EXISTS client_transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    client_id INT NOT NULL,
    type ENUM (
        'purchase',
        'payment',
        'refund'
    ) NOT NULL COMMENT 'Transaction type',
    amount DECIMAL(12, 2) NOT NULL COMMENT 'Transaction amount',
    balance_before DECIMAL(12, 2) NULL COMMENT 'Balance before transaction',
    balance_after DECIMAL(12, 2) NULL COMMENT 'Balance after transaction',
    reference_id VARCHAR(50) NULL COMMENT 'Related order/invoice ID',
    invoice_number VARCHAR(50) NULL COMMENT 'Invoice number',
    notes TEXT NULL COMMENT 'Transaction notes',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (client_id) REFERENCES clients (id) ON DELETE CASCADE,
    INDEX idx_client (client_id),
    INDEX idx_type (
        type
    ),
    INDEX idx_date (created_at)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4
COLLATE = utf8mb4_unicode_ci;

-- ============================================
-- Suppliers Table - جدول الموردين
-- ============================================
CREATE TABLE IF NOT EXISTS suppliers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE COMMENT 'Supplier code (SUP-001)',
    name VARCHAR(255) NOT NULL COMMENT 'Supplier name',
    contact_person VARCHAR(255) NULL COMMENT 'Contact person name',
    phone VARCHAR(50) NULL COMMENT 'Phone number',
    email VARCHAR(255) NULL COMMENT 'Email address',
    address TEXT NULL COMMENT 'Address',
    payment_terms VARCHAR(100) NULL COMMENT 'Payment terms (e.g., Net 30)',
    delivery_days INT NULL COMMENT 'Average delivery days',
    credit_limit DECIMAL(12, 2) NULL DEFAULT 0 COMMENT 'Credit limit',
    current_balance DECIMAL(12, 2) NOT NULL DEFAULT 0 COMMENT 'Current outstanding balance',
    is_active TINYINT (1) NOT NULL DEFAULT 1 COMMENT 'Supplier status',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_code (code),
    INDEX idx_name (name),
    INDEX idx_active (is_active),
    INDEX idx_balance (current_balance)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4
COLLATE = utf8mb4_unicode_ci;

-- ============================================
-- Sales Orders Table - جدول طلبات البيع
-- ============================================
CREATE TABLE IF NOT EXISTS sales_orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_number VARCHAR(50) NOT NULL UNIQUE COMMENT 'Order number (SO-20260118-1234)',
    invoice_number VARCHAR(50) NULL COMMENT 'Invoice number',
    customer_id INT NULL COMMENT 'Customer ID reference',
    customer_name VARCHAR(255) NULL COMMENT 'Customer name',
    customer_phone VARCHAR(50) NULL COMMENT 'Customer phone',
    seller_id VARCHAR(50) NULL COMMENT 'Seller ID',
    seller_name VARCHAR(100) NULL COMMENT 'Seller name',
    status ENUM (
        'draft',
        'confirmed',
        'processing',
        'shipped',
        'delivered',
        'completed',
        'cancelled',
        'returned'
    ) NOT NULL DEFAULT 'draft',
    payment_method ENUM (
        'cash',
        'card',
        'check',
        'bankTransfer',
        'credit'
    ) NOT NULL DEFAULT 'cash',
    subtotal DECIMAL(12, 2) NOT NULL DEFAULT 0 COMMENT 'Subtotal before discount',
    discount DECIMAL(12, 2) NULL COMMENT 'Fixed discount amount',
    discount_percentage DECIMAL(5, 2) NULL COMMENT 'Discount percentage',
    total_amount DECIMAL(12, 2) NOT NULL DEFAULT 0 COMMENT 'Total after discount',
    paid_amount DECIMAL(12, 2) NOT NULL DEFAULT 0 COMMENT 'Amount paid',
    notes TEXT NULL COMMENT 'Order notes',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at DATETIME NULL COMMENT 'Completion date',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_order_number (order_number),
    INDEX idx_customer (customer_id),
    INDEX idx_status (status),
    INDEX idx_created (created_at),
    INDEX idx_seller (seller_id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4
COLLATE = utf8mb4_unicode_ci;

-- ============================================
-- Sales Order Items Table - جدول عناصر طلبات البيع
-- ============================================
CREATE TABLE IF NOT EXISTS sales_order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    product_reference VARCHAR(50) NOT NULL COMMENT 'Product SKU',
    product_name VARCHAR(255) NOT NULL COMMENT 'Product name at time of sale',
    quantity INT NOT NULL COMMENT 'Quantity sold',
    unit_price DECIMAL(10, 2) NOT NULL COMMENT 'Unit price at time of sale',
    purchase_price DECIMAL(10, 2) NOT NULL DEFAULT 0 COMMENT 'Purchase price for profit calc',
    discount DECIMAL(10, 2) NULL COMMENT 'Line discount amount',
    discount_percentage DECIMAL(5, 2) NULL COMMENT 'Line discount percentage',
    line_total DECIMAL(12, 2) NOT NULL COMMENT 'Line total after discount',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES sales_orders (id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products (id),
    INDEX idx_order (order_id),
    INDEX idx_product (product_id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4
COLLATE = utf8mb4_unicode_ci;

-- ============================================
-- Supply Orders Table - جدول طلبات التوريد
-- ============================================
CREATE TABLE IF NOT EXISTS supply_orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_number VARCHAR(50) NOT NULL UNIQUE COMMENT 'Order number (PO-20260118-1234)',
    supplier_id INT NULL COMMENT 'Supplier ID reference',
    supplier_name VARCHAR(255) NULL COMMENT 'Supplier name',
    status ENUM (
        'draft',
        'pending',
        'approved',
        'ordered',
        'partiallyReceived',
        'received',
        'cancelled'
    ) NOT NULL DEFAULT 'draft',
    notes TEXT NULL COMMENT 'Order notes',
    created_by VARCHAR(100) NULL COMMENT 'Created by user',
    total_amount DECIMAL(12, 2) NOT NULL DEFAULT 0 COMMENT 'Total order value',
    expected_delivery DATE NULL COMMENT 'Expected delivery date',
    received_at DATETIME NULL COMMENT 'Actual receive date',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_order_number (order_number),
    INDEX idx_supplier (supplier_id),
    INDEX idx_status (status),
    INDEX idx_created (created_at)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4
COLLATE = utf8mb4_unicode_ci;

-- ============================================
-- Supply Order Items Table - جدول عناصر طلبات التوريد
-- ============================================
CREATE TABLE IF NOT EXISTS supply_order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    product_reference VARCHAR(50) NOT NULL COMMENT 'Product SKU',
    product_name VARCHAR(255) NOT NULL COMMENT 'Product name at time of order',
    quantity_ordered INT NOT NULL COMMENT 'Quantity ordered',
    quantity_received INT NOT NULL DEFAULT 0 COMMENT 'Quantity received',
    unit_price DECIMAL(10, 2) NOT NULL COMMENT 'Unit price',
    line_total DECIMAL(12, 2) NOT NULL COMMENT 'Line total',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES supply_orders (id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products (id),
    INDEX idx_order (order_id),
    INDEX idx_product (product_id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4
COLLATE = utf8mb4_unicode_ci;

-- ============================================
-- Warehouses Table - جدول المستودعات
-- ============================================
CREATE TABLE IF NOT EXISTS warehouses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE COMMENT 'Warehouse code (WH-001)',
    name VARCHAR(255) NOT NULL COMMENT 'Warehouse name',
    address TEXT NULL COMMENT 'Warehouse address',
    phone VARCHAR(50) NULL COMMENT 'Phone number',
    email VARCHAR(255) NULL COMMENT 'Email address',
    manager_id VARCHAR(50) NULL COMMENT 'Manager ID',
    is_active TINYINT (1) NOT NULL DEFAULT 1 COMMENT 'Warehouse status',
    is_default TINYINT (1) NOT NULL DEFAULT 0 COMMENT 'Default warehouse flag',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_code (code),
    INDEX idx_name (name),
    INDEX idx_active (is_active),
    INDEX idx_default (is_default)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4
COLLATE = utf8mb4_unicode_ci;

-- ============================================
-- Sample Data - بيانات عينة للاختبار
-- ============================================
INSERT INTO
    products (
        reference,
        name,
        quantity,
        min_stock,
        purchase_price,
        selling_price,
        margin_rate,
        supplier_name,
        category,
        barcode
    )
VALUES (
        'BJL001',
        'Kit Zeta Plus',
        25,
        10,
        340.00,
        410.00,
        0.20,
        'Biojel',
        'Kits',
        '6111234567890'
    ),
    (
        'BJL002',
        'Ciment Verre Ionomère',
        3,
        5,
        95.00,
        125.00,
        0.30,
        'Biojel',
        'Cements',
        '6111234567891'
    ),
    (
        'BJL003',
        'Composite Fluide A2',
        18,
        8,
        120.00,
        150.00,
        0.25,
        'Biojel',
        'Composites',
        NULL
    ),
    (
        'BJL004',
        'Adhésif Universel',
        12,
        6,
        280.00,
        345.00,
        0.22,
        'Biojel',
        'Adhesives',
        NULL
    ),
    (
        'ARG001',
        'Composite A2 Syringe',
        8,
        5,
        180.00,
        225.00,
        0.25,
        'Argentis',
        'Composites',
        '6111234567892'
    ),
    (
        'ARG002',
        'Fraises Diamantées Pack',
        50,
        20,
        45.00,
        65.00,
        0.35,
        'Argentis',
        'Instruments',
        NULL
    ),
    (
        'ARG003',
        'Lime Endodontique K-File',
        0,
        15,
        35.00,
        50.00,
        0.40,
        'Argentis',
        'Endodontics',
        NULL
    ),
    (
        'ARG004',
        'Seringue Anesthésie',
        35,
        10,
        85.00,
        110.00,
        0.28,
        'Argentis',
        'Anesthesia',
        NULL
    ),
    (
        'DEN001',
        'Gants Latex Medium Box',
        100,
        30,
        25.00,
        35.00,
        0.40,
        'Dental Pro',
        'Consumables',
        '6111234567893'
    ),
    (
        'DEN002',
        'Masques Chirurgicaux 50pcs',
        80,
        25,
        15.00,
        25.00,
        0.45,
        'Dental Pro',
        'Consumables',
        NULL
    ),
    (
        'DEN003',
        'Coton Rouleau 500g',
        2,
        10,
        20.00,
        30.00,
        0.35,
        'Dental Pro',
        'Consumables',
        NULL
    ),
    (
        'DEN004',
        'Bavettes Jetables 100pcs',
        45,
        15,
        30.00,
        45.00,
        0.38,
        'Dental Pro',
        'Consumables',
        NULL
    ),
    (
        'ORT001',
        'Brackets Métalliques Set',
        20,
        8,
        450.00,
        530.00,
        0.18,
        'Ortho Supply',
        'Orthodontics',
        NULL
    ),
    (
        'ORT002',
        'Fil Orthodontique NiTi',
        15,
        5,
        120.00,
        150.00,
        0.25,
        'Ortho Supply',
        'Orthodontics',
        NULL
    ),
    (
        'IMP001',
        'Alginate Impression 500g',
        22,
        10,
        55.00,
        75.00,
        0.32,
        'Impress Dental',
        'Impressions',
        NULL
    );

-- ============================================
-- Sample Clients Data - بيانات الزبناء
-- ============================================
INSERT INTO
    clients (
        code,
        name,
        phone,
        email,
        address,
        city,
        total_purchases,
        total_paid,
        notes
    )
VALUES (
        'CLI-0001',
        'د. عصام المنصوري',
        '0661234567',
        'dr.issam@gmail.com',
        'شارع محمد الخامس، رقم 45',
        'الدار البيضاء',
        45000.00,
        35000.00,
        'طبيب أسنان - عيادة المنصوري'
    ),
    (
        'CLI-0002',
        'د. فاطمة الزهراء بنعلي',
        '0677889900',
        'dr.fatima@outlook.com',
        'زنقة الحرية، عمارة النخيل',
        'الرباط',
        78500.00,
        78500.00,
        'تدفع في الوقت - زبونة ممتازة'
    ),
    (
        'CLI-0003',
        'د. أحمد العلوي',
        '0699112233',
        NULL,
        'حي الورود، رقم 12',
        'فاس',
        32000.00,
        20000.00,
        'يحتاج متابعة للديون'
    ),
    (
        'CLI-0004',
        'عيادة الأمل لطب الأسنان',
        '0522334455',
        'clinique.amal@gmail.com',
        'شارع الزرقطوني، الطابق 3',
        'الدار البيضاء',
        125000.00,
        100000.00,
        'عيادة كبيرة - طلبات شهرية'
    ),
    (
        'CLI-0005',
        'د. محمد الإدريسي',
        '0655667788',
        NULL,
        'المركز التجاري، محل 22',
        'مراكش',
        15000.00,
        15000.00,
        NULL
    ),
    (
        'CLI-0006',
        'مختبر الصحة للأسنان',
        '0537445566',
        'lab.sante@yahoo.fr',
        'المنطقة الصناعية، رقم 78',
        'طنجة',
        89000.00,
        50000.00,
        'مختبر - يشتري بكميات كبيرة'
    );

-- Sample Client Transactions
INSERT INTO
    client_transactions (
        client_id,
        type,
        amount,
        balance_before,
        balance_after,
        invoice_number,
        notes
    )
VALUES (
        1,
        'purchase',
        15000.00,
        0,
        15000.00,
        'FAC-2601-0001',
        'طلبية شهر يناير'
    ),
    (
        1,
        'payment',
        10000.00,
        15000.00,
        5000.00,
        NULL,
        'دفعة نقدية'
    ),
    (
        1,
        'purchase',
        30000.00,
        5000.00,
        35000.00,
        'FAC-2601-0015',
        NULL
    ),
    (
        1,
        'payment',
        25000.00,
        35000.00,
        10000.00,
        NULL,
        'شيك رقم 123456'
    ),
    (
        4,
        'purchase',
        50000.00,
        0,
        50000.00,
        'FAC-2601-0020',
        'طلبية كبيرة'
    ),
    (
        4,
        'payment',
        25000.00,
        50000.00,
        25000.00,
        NULL,
        'دفعة أولى'
    ),
    (
        6,
        'purchase',
        89000.00,
        0,
        89000.00,
        'FAC-2601-0025',
        'طلبية مختبر'
    ),
    (
        6,
        'payment',
        50000.00,
        89000.00,
        39000.00,
        NULL,
        'تحويل بنكي'
    );

-- ============================================
-- Sample Suppliers Data - بيانات الموردين
-- ============================================
INSERT INTO
    suppliers (
        code,
        name,
        contact_person,
        phone,
        email,
        address,
        payment_terms,
        delivery_days,
        credit_limit,
        current_balance
    )
VALUES (
        'SUP-001',
        'Biojel',
        'أحمد بنجلون',
        '0522334455',
        'contact@biojel.ma',
        'الدار البيضاء - المنطقة الصناعية',
        'صافي 30 يوم',
        3,
        500000.00,
        75000.00
    ),
    (
        'SUP-002',
        'Argentis',
        'محمد العلوي',
        '0537445566',
        'sales@argentis.ma',
        'الرباط - أكدال',
        'صافي 15 يوم',
        5,
        300000.00,
        45000.00
    ),
    (
        'SUP-003',
        'Dental Pro',
        'فاطمة الزهراء',
        '0528556677',
        'info@dentalpro.ma',
        'مراكش - حي المسيرة',
        'صافي 45 يوم',
        7,
        800000.00,
        120000.00
    ),
    (
        'SUP-004',
        'Ortho Supply',
        'كريم الإدريسي',
        '0539667788',
        'orders@orthosupply.ma',
        'فاس - المنطقة الصناعية',
        'نقداً',
        1,
        0.00,
        0.00
    ),
    (
        'SUP-005',
        'Impress Dental',
        'سعيد المنصوري',
        '0535778899',
        'impress@dental.ma',
        'طنجة - ميناء طنجة',
        'صافي 30 يوم',
        4,
        400000.00,
        80000.00
    );

-- ============================================
-- Sample Warehouses Data - بيانات المستودعات
-- ============================================
INSERT INTO
    warehouses (
        code,
        name,
        address,
        phone,
        email,
        is_active,
        is_default
    )
VALUES (
        'WH-001',
        'المستودع الرئيسي',
        'الدار البيضاء - عين السبع',
        '0522112233',
        'main@yoladent.ma',
        1,
        1
    ),
    (
        'WH-002',
        'مستودع الرباط',
        'الرباط - أكدال',
        '0537223344',
        'rabat@yoladent.ma',
        1,
        0
    ),
    (
        'WH-003',
        'مستودع مراكش',
        'مراكش - جيليز',
        '0524334455',
        'marrakech@yoladent.ma',
        1,
        0
    );

-- ============================================
-- Sample Users Data - بيانات المستخدمين
-- Passwords are hashed using password_hash()
-- Default passwords for demo:
--   admin: admin123
--   manager: manager123
--   user: user123
-- ============================================
INSERT INTO
    users (
        username,
        password_hash,
        email,
        display_name,
        role,
        phone,
        warehouse_ids,
        is_active
    )
VALUES (
        'admin',
        '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
        'admin@yoladent.ma',
        'مدير النظام',
        'admin',
        '0661234567',
        '[]',
        1
    ),
    (
        'manager',
        '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
        'manager@yoladent.ma',
        'محمد المدير',
        'manager',
        '0662345678',
        '["1", "2"]',
        1
    ),
    (
        'pharmacist',
        '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
        'pharmacist@yoladent.ma',
        'أحمد الصيدلي',
        'pharmacist',
        '0663456789',
        '["1"]',
        1
    ),
    (
        'storekeeper',
        '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
        'store@yoladent.ma',
        'خالد أمين المستودع',
        'storekeeper',
        '0664567890',
        '["1", "2", "3"]',
        1
    ),
    (
        'accountant',
        '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
        'accountant@yoladent.ma',
        'فاطمة المحاسبة',
        'accountant',
        '0665678901',
        '[]',
        1
    );