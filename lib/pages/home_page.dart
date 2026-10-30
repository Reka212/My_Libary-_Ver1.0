import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'login_page.dart';
import 'buku_page.dart';
import 'anggota_page.dart';
import 'pinjam_page.dart';
import 'laporan_page.dart';
import 'admin_page.dart';
import '../database/database_helper.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      body: Column(
        children: [
          // 🔥 HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 60,
              left: 20,
              right: 20,
              bottom: 30,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Dashboard",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Selamat datang 👋",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),

                // 🔓 Logout
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 🔥 STATISTIK (live, auto-update setiap ada perubahan data)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AnimatedBuilder(
              animation: Listenable.merge([
                DatabaseHelper.bukuBox.listenable() ,
                DatabaseHelper.anggotaBox.listenable(),
                DatabaseHelper.peminjamanBox.listenable(),
              ]),
              builder: (context, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    statCard(
                      "Buku",
                      DatabaseHelper.totalBuku().toString(),
                      Icons.book,
                    ),
                    statCard(
                      "Anggota",
                      DatabaseHelper.totalAnggota().toString(),
                      Icons.people,
                    ),
                    statCard(
                      "Pinjam",
                      DatabaseHelper.totalPinjam().toString(),
                      Icons.swap_horiz,
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // 🔥 MENU GRID
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                menuCard(context, "Buku", Icons.book, const BukuPage()),
                menuCard(context, "Anggota", Icons.people, const AnggotaPage()),
                menuCard(context, "Peminjaman", Icons.swap_horiz, const PinjamPage()),
                menuCard(context, "Laporan", Icons.bar_chart, const LaporanPage()),
                menuCard(context, "Admin", Icons.admin_panel_settings, const AdminPage()),
               
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 MENU CARD
  Widget menuCard(BuildContext context, String title, IconData icon, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 35, color: Colors.green),
            const SizedBox(height: 10),
            Text(title),
          ],
        ),
      ),
    );
  }

  // 🔹 STAT CARD
  Widget statCard(String title, String value, IconData icon) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.green),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
