<?php
/**
 * API Endpoint: Update Profil Pengguna
 * Method: POST
 * Parameters: id_pengguna, nik, nama_lengkap, tahun_lahir, tempat_lahir, alamat
 * 
 * Mengupdate data profil pengguna di database
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
error_log("📥 [PROFIL-UPDATE] Request diterima");

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
$nik = isset($_POST['nik']) ? trim($_POST['nik']) : '';
$nama_lengkap = isset($_POST['nama_lengkap']) ? trim($_POST['nama_lengkap']) : '';
$tahun_lahir = isset($_POST['tahun_lahir']) ? trim($_POST['tahun_lahir']) : '';
$tempat_lahir = isset($_POST['tempat_lahir']) ? trim($_POST['tempat_lahir']) : '';
$alamat = isset($_POST['alamat']) ? trim($_POST['alamat']) : '';

error_log("📥 [PROFIL-UPDATE] ID Pengguna: " . $id_pengguna);
error_log("📥 [PROFIL-UPDATE] NIK: " . $nik);
error_log("📥 [PROFIL-UPDATE] Nama: " . $nama_lengkap);
error_log("📥 [PROFIL-UPDATE] Tahun Lahir: " . $tahun_lahir);
error_log("📥 [PROFIL-UPDATE] Tempat Lahir: " . $tempat_lahir);
error_log("📥 [PROFIL-UPDATE] Alamat: " . substr($alamat, 0, 50) . "...");

// Validasi parameter wajib
$errors = [];

if ($id_pengguna <= 0) {
    $errors[] = 'ID pengguna tidak valid';
}

if (empty($nik)) {
    $errors[] = 'NIK tidak boleh kosong';
} elseif (strlen($nik) !== 16) {
    $errors[] = 'NIK harus 16 digit';
} elseif (!ctype_digit($nik)) {
    $errors[] = 'NIK harus berupa angka';
}

if (empty($nama_lengkap)) {
    $errors[] = 'Nama lengkap tidak boleh kosong';
} elseif (strlen($nama_lengkap) < 3) {
    $errors[] = 'Nama lengkap minimal 3 karakter';
}

if (empty($tahun_lahir)) {
    $errors[] = 'Tahun lahir tidak boleh kosong';
} elseif (strlen($tahun_lahir) !== 4 || !ctype_digit($tahun_lahir)) {
    $errors[] = 'Tahun lahir harus 4 digit angka';
} else {
    $tahun = intval($tahun_lahir);
    $tahun_sekarang = date('Y');
    if ($tahun < 1900 || $tahun > $tahun_sekarang) {
        $errors[] = "Tahun lahir harus antara 1900-$tahun_sekarang";
    }
}

if (empty($tempat_lahir)) {
    $errors[] = 'Tempat lahir tidak boleh kosong';
}

if (empty($alamat)) {
    $errors[] = 'Alamat tidak boleh kosong';
} elseif (strlen($alamat) < 10) {
    $errors[] = 'Alamat minimal 10 karakter';
}

if (!empty($errors)) {
    error_log("🔴 [PROFIL-UPDATE] Validasi gagal: " . implode(', ', $errors));
    echo json_encode([
        'sukses' => false,
        'pesan' => implode('. ', $errors)
    ]);
    exit();
}

try {
    // Cek apakah pengguna ada
    $check_stmt = $conn->prepare("SELECT id FROM pengguna WHERE id = ?");
    $check_stmt->bind_param("i", $id_pengguna);
    $check_stmt->execute();
    $check_result = $check_stmt->get_result();
    
    if ($check_result->num_rows === 0) {
        error_log("🔴 [PROFIL-UPDATE] Pengguna tidak ditemukan: " . $id_pengguna);
        echo json_encode([
            'sukses' => false,
            'pesan' => 'Pengguna tidak ditemukan'
        ]);
        $check_stmt->close();
        exit();
    }
    $check_stmt->close();
    
    // Cek apakah NIK sudah digunakan oleh pengguna lain
    $nik_stmt = $conn->prepare("SELECT id FROM pengguna WHERE nik = ? AND id != ?");
    $nik_stmt->bind_param("si", $nik, $id_pengguna);
    $nik_stmt->execute();
    $nik_result = $nik_stmt->get_result();
    
    if ($nik_result->num_rows > 0) {
        error_log("🔴 [PROFIL-UPDATE] NIK sudah digunakan: " . $nik);
        echo json_encode([
            'sukses' => false,
            'pesan' => 'NIK sudah digunakan oleh pengguna lain'
        ]);
        $nik_stmt->close();
        exit();
    }
    $nik_stmt->close();
    
    // Update profil
    $update_stmt = $conn->prepare("
        UPDATE pengguna 
        SET 
            nik = ?,
            nama_lengkap = ?,
            tahun_lahir = ?,
            tempat_lahir = ?,
            alamat = ?,
            tanggal_update = NOW()
        WHERE id = ?
    ");
    
    $update_stmt->bind_param(
        "sssssi",
        $nik,
        $nama_lengkap,
        $tahun_lahir,
        $tempat_lahir,
        $alamat,
        $id_pengguna
    );
    
    if ($update_stmt->execute()) {
        if ($update_stmt->affected_rows > 0) {
            error_log("🟢 [PROFIL-UPDATE] Profil berhasil diperbarui untuk ID: " . $id_pengguna);
            
            echo json_encode([
                'sukses' => true,
                'pesan' => 'Profil berhasil diperbarui',
                'data' => [
                    'id' => $id_pengguna,
                    'nik' => $nik,
                    'nama_lengkap' => $nama_lengkap,
                    'tahun_lahir' => $tahun_lahir,
                    'tempat_lahir' => $tempat_lahir,
                    'alamat' => $alamat
                ]
            ]);
        } else {
            error_log("⚠️ [PROFIL-UPDATE] Tidak ada perubahan data untuk ID: " . $id_pengguna);
            
            echo json_encode([
                'sukses' => true,
                'pesan' => 'Tidak ada perubahan data',
                'data' => [
                    'id' => $id_pengguna,
                    'nik' => $nik,
                    'nama_lengkap' => $nama_lengkap,
                    'tahun_lahir' => $tahun_lahir,
                    'tempat_lahir' => $tempat_lahir,
                    'alamat' => $alamat
                ]
            ]);
        }
    } else {
        error_log("🔴 [PROFIL-UPDATE] Gagal update: " . $update_stmt->error);
        echo json_encode([
            'sukses' => false,
            'pesan' => 'Gagal memperbarui profil: ' . $update_stmt->error
        ]);
    }
    
    $update_stmt->close();
    
} catch (Exception $e) {
    error_log("🔴 [PROFIL-UPDATE] Error: " . $e->getMessage());
    echo json_encode([
        'sukses' => false,
        'pesan' => 'Terjadi kesalahan server: ' . $e->getMessage()
    ]);
}

$conn->close();
?>
