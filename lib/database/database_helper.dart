import 'package:hive/hive.dart';

class DatabaseHelper {
  static final Box bukuBox = Hive.box('bukuBox');
  static final Box anggotaBox = Hive.box('anggotaBox');
  static final Box peminjamanBox = Hive.box('peminjamanBox');
  static final Box adminBox = Hive.box('adminBox');
  // CREATE
  static Future<void> tambahBuku({
    required String isbn,
    required String judul,
    required String penulis,
    required String penerbit,
    required String tahun,
    required String kategori,
    required int stok,
    required String rak,
  }) async {
    await bukuBox.add({
      'isbn': isbn,
      'judul': judul,
      'penulis': penulis,
      'penerbit': penerbit,
      'tahun': tahun,
      'kategori': kategori,
      'stok': stok,
      'rak': rak,
    });
  }

  // READ
  static List<Map<String, dynamic>> getAllBuku() {
    List<Map<String, dynamic>> data = [];

    for (int i = 0; i < bukuBox.length; i++) {
      final item = bukuBox.getAt(i);

      data.add({
        'key': i,
        'isbn': item['isbn'] ?? '',
        'judul': item['judul'] ?? '',
        'penulis': item['penulis'] ?? '',
        'penerbit': item['penerbit'] ?? '',
        'tahun': item['tahun'] ?? '',
        'kategori': item['kategori'] ?? '',
        'stok': item['stok'] ?? 0,
        'rak': item['rak'] ?? '',
      });
    }

    return data;
  }

  // UPDATE
  static Future<void> updateBuku({
    required int key,
    required String isbn,
    required String judul,
    required String penulis,
    required String penerbit,
    required String tahun,
    required String kategori,
    required int stok,
    required String rak,
  }) async {
    await bukuBox.putAt(key, {
      'isbn': isbn,
      'judul': judul,
      'penulis': penulis,
      'penerbit': penerbit,
      'tahun': tahun,
      'kategori': kategori,
      'stok': stok,
      'rak': rak,
    });
  }

  // DELETE
  static Future<void> deleteBuku(int key) async {
    await bukuBox.deleteAt(key);
  }

  static List<Map<String, dynamic>> cariBuku(String keyword) {
    final semua = getAllBuku();

    if (keyword.isEmpty) return semua;

    return semua.where((buku) {
      return buku['judul'].toString().toLowerCase().contains(
            keyword.toLowerCase(),
          ) ||
          buku['penulis'].toString().toLowerCase().contains(
            keyword.toLowerCase(),
          ) ||
          buku['isbn'].toString().toLowerCase().contains(keyword.toLowerCase());
    }).toList();
  }

  // DASHBOARD
  static int totalBuku() {
    return bukuBox.length;
  }

  static int totalStok() {
    int total = 0;

    for (int i = 0; i < bukuBox.length; i++) {
      final item = bukuBox.getAt(i);
      total += (item['stok'] ?? 0) as int;
    }

    return total;
  }

  static int totalAnggota() {
    return anggotaBox.length;
  }

  // 🆕 baru
  static int totalAnggotaAktif() {
    int total = 0;
    for (int i = 0; i < anggotaBox.length; i++) {
      if ((anggotaBox.getAt(i)['status'] ?? '') == 'Aktif') total++;
    }
    return total;
  }

  static int totalAnggotaNonaktif() {
    int total = 0;
    for (int i = 0; i < anggotaBox.length; i++) {
      if ((anggotaBox.getAt(i)['status'] ?? '') == 'Nonaktif') total++;
    }
    return total;
  }

  static Map<String, int> totalBukuPerKategori() {
    final Map<String, int> hasil = {};
    for (int i = 0; i < bukuBox.length; i++) {
      final kategori = (bukuBox.getAt(i)['kategori'] ?? '-').toString();
      hasil[kategori] = (hasil[kategori] ?? 0) + 1;
    }
    return hasil;
  }

  static int totalPinjam() => peminjamanBox.length;

  static int totalSedangDipinjam() {
    int total = 0;
    for (int i = 0; i < peminjamanBox.length; i++) {
      if ((peminjamanBox.getAt(i)['status'] ?? '') == 'Dipinjam') total++;
    }
    return total;
  }

  static int totalSudahKembali() {
    int total = 0;
    for (int i = 0; i < peminjamanBox.length; i++) {
      if ((peminjamanBox.getAt(i)['status'] ?? '') == 'Kembali') total++;
    }
    return total;
  }

  static Future<void> tambahAnggota({
    required String idAnggota,
    required String nomorAnggota,
    required String nama,
    required String jenisKelamin,
    required String alamat,
    required String noHp,
    required String email,
    required String instansi,
    required String tanggalDaftar,
    required String status,
  }) async {
    await anggotaBox.add({
      'idAnggota': idAnggota,
      'nomorAnggota': nomorAnggota,
      'nama': nama,
      'jenisKelamin': jenisKelamin,
      'alamat': alamat,
      'noHp': noHp,
      'email': email,
      'instansi': instansi,
      'tanggalDaftar': tanggalDaftar,
      'status': status,
    });
  }

  static List<Map<String, dynamic>> getAllAnggota() {
    List<Map<String, dynamic>> data = [];

    for (int i = 0; i < anggotaBox.length; i++) {
      final item = anggotaBox.getAt(i);

      data.add({
        'key': i,
        'idAnggota': item['idAnggota'] ?? '',
        'nomorAnggota': item['nomorAnggota'] ?? '',
        'nama': item['nama'] ?? '',
        'jenisKelamin': item['jenisKelamin'] ?? '',
        'alamat': item['alamat'] ?? '',
        'noHp': item['noHp'] ?? '',
        'email': item['email'] ?? '',
        'instansi': item['instansi'] ?? '',
        'tanggalDaftar': item['tanggalDaftar'] ?? '',
        'status': item['status'] ?? '',
      });
    }

    return data;
  }

  static Future<void> updateAnggota({
    required int key,
    required String idAnggota,
    required String nomorAnggota,
    required String nama,
    required String jenisKelamin,
    required String alamat,
    required String noHp,
    required String email,
    required String instansi,
    required String tanggalDaftar,
    required String status,
  }) async {
    await anggotaBox.putAt(key, {
      'idAnggota': idAnggota,
      'nomorAnggota': nomorAnggota,
      'nama': nama,
      'jenisKelamin': jenisKelamin,
      'alamat': alamat,
      'noHp': noHp,
      'email': email,
      'instansi': instansi,
      'tanggalDaftar': tanggalDaftar,
      'status': status,
    });
  }

  static Future<void> deleteAnggota(int key) async {
    await anggotaBox.deleteAt(key);
  }

  static List<Map<String, dynamic>> cariAnggota(String keyword) {
    final semua = getAllAnggota();

    if (keyword.isEmpty) return semua;

    return semua.where((anggota) {
      return anggota['nama'].toString().toLowerCase().contains(
            keyword.toLowerCase(),
          ) ||
          anggota['nomorAnggota'].toString().toLowerCase().contains(
            keyword.toLowerCase(),
          );
    }).toList();
  }
  // =========================
  // PEMINJAMAN
  // =========================

  // CREATE
  static Future<void> tambahPinjam({
    required String idPinjam,
    required String nomorAnggota,
    required String namaAnggota,
    required String isbn,
    required String judulBuku,
    required String tanggalPinjam,
    required String tanggalKembali,
    required String status,
  }) async {
    try {
      await peminjamanBox.add({
        'idPinjam': idPinjam,
        'nomorAnggota': nomorAnggota,
        'namaAnggota': namaAnggota,
        'isbn': isbn,
        'judulBuku': judulBuku,
        'tanggalPinjam': tanggalPinjam,
        'tanggalKembali': tanggalKembali,
        'status': status,
      });
    } catch (e) {
      throw Exception("Gagal menyimpan data peminjaman: $e");
    }
  }

  // READ
  static List<Map<String, dynamic>> getAllPinjam() {
    List<Map<String, dynamic>> data = [];
    for (int i = 0; i < peminjamanBox.length; i++) {
      final item = peminjamanBox.getAt(i);
      final hiveKey = peminjamanBox.keyAt(i); // key asli, bukan index urutan
      data.add({
        'key': hiveKey,
        'idPinjam': item['idPinjam'] ?? '',
        'nomorAnggota': item['nomorAnggota'] ?? '',
        'namaAnggota': item['namaAnggota'] ?? '',
        'isbn': item['isbn'] ?? '',
        'judulBuku': item['judulBuku'] ?? '',
        'tanggalPinjam': item['tanggalPinjam'] ?? '',
        'tanggalKembali': item['tanggalKembali'] ?? '',
        'status': item['status'] ?? '',
      });
    }

    return data;
  }

  // UPDATE
  static Future<void> updatePinjam({
    required dynamic key, // Hive key asli, bukan index
    required String idPinjam,
    required String nomorAnggota,
    required String namaAnggota,
    required String isbn,
    required String judulBuku,
    required String tanggalPinjam,
    required String tanggalKembali,
    required String status,
  }) async {
    try {
      await peminjamanBox.put(key, {
        'idPinjam': idPinjam,
        'nomorAnggota': nomorAnggota,
        'namaAnggota': namaAnggota,
        'isbn': isbn,
        'judulBuku': judulBuku,
        'tanggalPinjam': tanggalPinjam,
        'tanggalKembali': tanggalKembali,
        'status': status,
      });
    } catch (e) {
      throw Exception("Gagal memperbarui data peminjaman: $e");
    }
  }

  static Future<void> deletePinjam(dynamic key) async {
    try {
      await peminjamanBox.delete(key);
    } catch (e) {
      throw Exception("Gagal menghapus data peminjaman: $e");
    }
  }

  // SEARCH
  static List<Map<String, dynamic>> cariPinjam(String keyword) {
    final semua = getAllPinjam();

    if (keyword.isEmpty) return semua;

    return semua.where((pinjam) {
      return pinjam['namaAnggota'].toString().toLowerCase().contains(
            keyword.toLowerCase(),
          ) ||
          pinjam['judulBuku'].toString().toLowerCase().contains(
            keyword.toLowerCase(),
          ) ||
          pinjam['idPinjam'].toString().toLowerCase().contains(
            keyword.toLowerCase(),
          );
    }).toList();
  }

  static Future<void> kurangiStokBuku(int key) async {
    final buku = bukuBox.getAt(key);
    if (buku == null) return;
    final stokSekarang = (buku['stok'] ?? 0) as int;
    if (stokSekarang > 0) {
      try {
        await bukuBox.putAt(key, {
          'isbn': buku['isbn'] ?? '',
          'judul': buku['judul'] ?? '',
          'penulis': buku['penulis'] ?? '',
          'penerbit': buku['penerbit'] ?? '',
          'tahun': buku['tahun'] ?? '',
          'kategori': buku['kategori'] ?? '',
          'stok': stokSekarang - 1,
          'rak': buku['rak'] ?? '',
        });
      } catch (e) {
        throw Exception("Gagal mengurangi stok buku: $e");
      }
    }
  }

  static Future<void> tambahStokBuku(int key) async {
    final buku = bukuBox.getAt(key);
    if (buku == null) return;
    final stokSekarang = (buku['stok'] ?? 0) as int;
    try {
      await bukuBox.putAt(key, {
        'isbn': buku['isbn'] ?? '',
        'judul': buku['judul'] ?? '',
        'penulis': buku['penulis'] ?? '',
        'penerbit': buku['penerbit'] ?? '',
        'tahun': buku['tahun'] ?? '',
        'kategori': buku['kategori'] ?? '',
        'stok': stokSekarang + 1,
        'rak': buku['rak'] ?? '',
      });
    } catch (e) {
      throw Exception("Gagal menambah stok buku: $e");
    }
  }

  static int? getKeyBukuByIsbn(String isbn) {
    for (int i = 0; i < bukuBox.length; i++) {
      final buku = bukuBox.getAt(i);

      if (buku['isbn'].toString() == isbn.toString()) {
        return i;
      }
    }

    return null;
  }

  static Future<void> tambahAdmin({
    required String username,
    required String email,
    required String noHp,
    required String password,
  }) async {
    await adminBox.add({
      'username': username,
      'email': email,
      'noHp': noHp,
      'password': password,
    });
  }

  static List<Map<String, dynamic>> getAllAdmin() {
    List<Map<String, dynamic>> data = [];

    for (int i = 0; i < adminBox.length; i++) {
      final item = adminBox.getAt(i);

      data.add({
        'key': i,
        'username': item['username'] ?? '',
        'email': item['email'] ?? '',
        'noHp': item['noHp'] ?? '',
        'password': item['password'] ?? '',
      });
    }

    return data;
  }

  static Future<void> updateAdmin({
    required int key,
    required String username,
    required String email,
    required String noHp,
    required String password,
  }) async {
    await adminBox.putAt(key, {
      'username': username,
      'email': email,
      'noHp': noHp,
      'password': password,
    });
  }

  static Future<void> deleteAdmin(int key) async {
    await adminBox.deleteAt(key);
  }

  static bool isUsernameExist(String username, {int? kecualiKey}) {
    for (int i = 0; i < adminBox.length; i++) {
      if (kecualiKey != null && i == kecualiKey) continue;
      if (adminBox.getAt(i)['username'].toString().toLowerCase() ==
          username.toLowerCase()) {
        return true;
      }
    }
    return false;
  }

  static bool validasiLogin(String username, String password) {
    for (int i = 0; i < adminBox.length; i++) {
      final item = adminBox.getAt(i);
      if (item['username'] == username && item['password'] == password) {
        return true;
      }
    }
    return false;
  }

  static List<Map<String, dynamic>> cariAdmin(String keyword) {
    final semua = getAllAdmin();

    if (keyword.isEmpty) return semua;

    return semua.where((admin) {
      return admin['username'].toString().toLowerCase().contains(
            keyword.toLowerCase(),
          ) ||
          admin['email'].toString().toLowerCase().contains(
            keyword.toLowerCase(),
          );
    }).toList();
  }

  static int totalAdmin() => adminBox.length;

  static Future<void> seedAdminDefault() async {
    if (adminBox.isEmpty) {
      await adminBox.add({
        'username': 'admin',
        'email': '-',
        'noHp': '-',
        'password': '123',
      });
    }
  }
}
