import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'database/database_helper.dart';
import 'pages/login_page.dart';

void main() async {
  // Wajib dipanggil sebelum pakai plugin apa pun (termasuk Hive) di main()
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Hive untuk Flutter (otomatis cari folder penyimpanan device)
  await Hive.initFlutter();

  // =========================
  // BUKA SEMUA BOX
  // =========================
  await Hive.openBox('bukuBox');
  await Hive.openBox('anggotaBox');
  await Hive.openBox('peminjamanBox');
  await Hive.openBox('adminBox'); // 🆕 WAJIB — ini yang menyebabkan HiveError kamu

  // =========================
  // SEED DATA AWAL
  // =========================
  // Supaya ada 1 akun admin default (username: admin, password: 123)
  // kalau adminBox masih kosong (pertama kali app dijalankan)
  await DatabaseHelper.seedAdminDefault();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sistem Perpustakaan',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
      ),
      home: const LoginPage(),
    );
  }
}