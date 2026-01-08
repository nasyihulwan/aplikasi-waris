<?php
/**
 * API Endpoint: Ambil Profil Pengguna
 * Method: POST
 * Parameters: id_pengguna
 * 
 * Mengambil data profil pengguna dari database berdasarkan ID
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Handle preflight request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once 'koneksi.php';

// Log request
error_log("📥 [PROFIL-AMBIL] Request diterima");

// Validasi method
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode([
        'sukses' => false,
        'pesan' => 'Method tidak diizinkan. Gunakan POST.'
    ]);
    exit();
}

// Ambil parameter
$id_pengguna = isset($_POST['id_pengguna']) ? intval($_POST['id_pengguna']) : 0;

error_log("📥 [PROFIL-AMBIL] ID Pengguna: " . $id_pengguna);

// Validasi parameter
if ($id_pengguna <= 0) {
    echo json_encode([
        'sukses' => false,
        'pesan' => 'ID pengguna tidak valid'
    ]);
    exit();
}

try {
    // Query untuk mengambil data profil
    $stmt = $conn->prepare("
        SELECT 
            id,
            nik,
            nik_pewaris,
            nama_lengkap,
            email,
            tahun_lahir,
            tempat_lahir,
            alamat,
            tanggal_dibuat,
            tanggal_update,
            two_factor_enabled
        FROM pengguna 
        WHERE id = ?
    ");
    
    $stmt->bind_param("i", $id_pengguna);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows === 0) {
        error_log("🔴 [PROFIL-AMBIL] Pengguna tidak ditemukan: " . $id_pengguna);
        echo json_encode([
            'sukses' => false,
            'pesan' => 'Pengguna tidak ditemukan'
        ]);
        exit();
    }
    
    $pengguna = $result->fetch_assoc();
    
    error_log("🟢 [PROFIL-AMBIL] Data profil berhasil diambil untuk ID: " . $id_pengguna);
    error_log("📤 [PROFIL-AMBIL] NIK: " . ($pengguna['nik'] ?? 'null'));
    error_log("📤 [PROFIL-AMBIL] Nama: " . ($pengguna['nama_lengkap'] ?? 'null'));
    
    echo json_encode([
        'sukses' => true,
        'pesan' => 'Data profil berhasil diambil',
        'data' => [
            'id' => $pengguna['id'],
            'nik' => $pengguna['nik'] ?? '',
            'nik_pewaris' => $pengguna['nik_pewaris'] ?? '',
            'nama_lengkap' => $pengguna['nama_lengkap'] ?? '',
            'email' => $pengguna['email'] ?? '',
            'tahun_lahir' => $pengguna['tahun_lahir'] ?? '',
            'tempat_lahir' => $pengguna['tempat_lahir'] ?? '',
            'alamat' => $pengguna['alamat'] ?? '',
            'tanggal_dibuat' => $pengguna['tanggal_dibuat'],
            'tanggal_update' => $pengguna['tanggal_update'],
            'two_factor_enabled' => (bool)$pengguna['two_factor_enabled']
        ]
    ]);
    
    $stmt->close();
    
} catch (Exception $e) {
    error_log("🔴 [PROFIL-AMBIL] Error: " . $e->getMessage());
    echo json_encode([
        'sukses' => false,
        'pesan' => 'Terjadi kesalahan server: ' . $e->getMessage()
    ]);
}

$conn->close();
?>
