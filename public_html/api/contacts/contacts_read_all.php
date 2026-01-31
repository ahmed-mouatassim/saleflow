<?php
/**
 * ================================================
 * API: Contacts - Read All
 * ================================================
 * Purpose: Fetch all contacts with pagination
 * Method: GET
 * Authentication: Optional
 * 
 * Request Parameters:
 * - page (int): Page number (default: 1)
 * - page_size (int): Records per page (default: 20)
 * 
 * Response Format:
 * {
 *   "success": true,
 *   "data": [...],
 *   "pagination": {...},
 *   "timestamp": "2025-01-09 12:00:00"
 * }
 * 
 * Generated: 2025-01-09
 * Source: contacts.dart
 * ================================================
 */

// Headers
header('Content-Type: application/json; charset=UTF-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Include database connection
require_once __DIR__ . '/../config/database.php';

// Validate HTTP method
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode([
        'success' => false,
        'error' => 'Method not allowed. Use GET',
        'received_method' => $_SERVER['REQUEST_METHOD']
    ]);
    exit;
}

try {
    // ===== PARAMETER EXTRACTION =====
    $page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
    $page_size = isset($_GET['page_size']) ? (int)$_GET['page_size'] : 20;
    
    // ===== PARAMETER VALIDATION =====
    if ($page < 1) $page = 1;
    if ($page_size < 1 || $page_size > 100) $page_size = 20;
    
    $offset = ($page - 1) * $page_size;
    
    // ===== SQL QUERY EXECUTION =====
    $query = "
        SELECT 
            contact_id,
            name,
            company,
            phone_number,
            email,
            role,
            positioned,
            image_url,
            created_at,
            updated_at
        FROM contacts
        WHERE is_active = 1
        ORDER BY created_at DESC
        LIMIT :limit OFFSET :offset
    ";
    
    $stmt = $conn->prepare($query);
    $stmt->bindValue(':limit', $page_size, PDO::PARAM_INT);
    $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
    $stmt->execute();
    
    $contacts = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Get total count
    $count_query = "SELECT COUNT(*) AS total FROM contacts WHERE is_active = 1";
    $count_stmt = $conn->query($count_query);
    $total_records = $count_stmt->fetch(PDO::FETCH_ASSOC)['total'];
    $total_pages = ceil($total_records / $page_size);
    
    // ===== RESPONSE =====
    http_response_code(200);
    echo json_encode([
        'success' => true,
        'data' => $contacts,
        'pagination' => [
            'current_page' => $page,
            'page_size' => $page_size,
            'total_records' => (int)$total_records,
            'total_pages' => (int)$total_pages,
            'has_next' => $page < $total_pages,
            'has_previous' => $page > 1
        ],
        'timestamp' => date('Y-m-d H:i:s')
    ], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
    
} catch (Exception $e) {
    // Error handling
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage(),
        'timestamp' => date('Y-m-d H:i:s')
    ], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
    
} finally {
    // Clean up
    $conn = null;
}
?>