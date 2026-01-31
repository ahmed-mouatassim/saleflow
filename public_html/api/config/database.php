<?php
/**
 * ================================================
 * Database Configuration - MySQL
 * ================================================
 * Purpose: Database connection management
 * Generated: 2025-01-09
 * ================================================
 */

// Database credentials - CONFIGURE THESE
define('DB_HOST', 'localhost');
define('DB_NAME', 'contacts_db');
define('DB_USER', 'root');
define('DB_PASS', '');
define('DB_CHARSET', 'utf8mb4');

// Connection variable
$conn = null;

try {
    // Create PDO connection
    $dsn = "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=" . DB_CHARSET;
    
    $options = [
        PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES   => false,
        PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES " . DB_CHARSET
    ];
    
    $conn = new PDO($dsn, DB_USER, DB_PASS, $options);
    
} catch (PDOException $e) {
    // Log error (in production, don't expose details)
    error_log("Database Connection Error: " . $e->getMessage());
    
    // Return generic error
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => 'Database connection failed',
        'timestamp' => date('Y-m-d H:i:s')
    ]);
    exit;
}

/**
 * Helper function to execute SELECT queries and return JSON
 */
function executeQuery($conn, $sql, $params = []) {
    try {
        $stmt = $conn->prepare($sql);
        $stmt->execute($params);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    } catch (PDOException $e) {
        throw new Exception("Query execution failed: " . $e->getMessage());
    }
}

/**
 * Helper function to execute INSERT/UPDATE/DELETE
 */
function executeNonQuery($conn, $sql, $params = []) {
    try {
        $stmt = $conn->prepare($sql);
        $stmt->execute($params);
        return [
            'affected_rows' => $stmt->rowCount(),
            'last_insert_id' => $conn->lastInsertId()
        ];
    } catch (PDOException $e) {
        throw new Exception("Query execution failed: " . $e->getMessage());
    }
}

/**
 * Helper function to sanitize input
 */
function sanitizeInput($data) {
    if (is_array($data)) {
        return array_map('sanitizeInput', $data);
    }
    return htmlspecialchars(strip_tags(trim($data)), ENT_QUOTES, 'UTF-8');
}
?>