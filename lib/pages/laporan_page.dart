import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../database/database_helper.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage>
    with SingleTickerProviderStateMixin {
  late final TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Laporan"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "Ringkasan"),
            Tab(text: "Buku"),
            Tab(text: "Anggota"),
            Tab(text: "Peminjaman"),
          ],
        ),
      ),
      // 🔥 Live: rebuild otomatis begitu ada perubahan data buku/anggota/pinjam
      body: AnimatedBuilder(
        animation: Listenable.merge([
          DatabaseHelper.bukuBox.listenable(),
          DatabaseHelper.anggotaBox.listenable(),
          DatabaseHelper.peminjamanBox.listenable(),
        ]),
        builder: (context, _) {
          return TabBarView(
            controller: tabController,
            children: [
              _ringkasanTab(),
              _bukuTab(),
              _anggotaTab(),
              _peminjamanTab(),
            ],
          );
        },
      ),
    );
  }

  //=========================================
  // TAB 1 : RINGKASAN
  //=========================================
  Widget _ringkasanTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          "Ringkasan Perpustakaan",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 12),
        laporanCard(
          "Total Buku",
          DatabaseHelper.totalBuku().toString(),
          Icons.book,
        ),
        laporanCard(
          "Total Stok Buku",
          DatabaseHelper.totalStok().toString(),
          Icons.inventory_2,
        ),
        laporanCard(
          "Total Anggota",
          DatabaseHelper.totalAnggota().toString(),
          Icons.people,
        ),
        laporanCard(
          "Anggota Aktif",
          DatabaseHelper.totalAnggotaAktif().toString(),
          Icons.person,
          color: Colors.green,
        ),
        laporanCard(
          "Anggota Nonaktif",
          DatabaseHelper.totalAnggotaNonaktif().toString(),
          Icons.person_off,
          color: Colors.grey,
        ),
        laporanCard(
          "Total Peminjaman",
          DatabaseHelper.totalPinjam().toString(),
          Icons.swap_horiz,
        ),
        laporanCard(
          "Sedang Dipinjam",
          DatabaseHelper.totalSedangDipinjam().toString(),
          Icons.hourglass_bottom,
          color: Colors.orange,
        ),
        laporanCard(
          "Sudah Dikembalikan",
          DatabaseHelper.totalSudahKembali().toString(),
          Icons.check_circle,
          color: Colors.green,
        ),
      ],
    );
  }

  // dipakai oleh _ringkasanTab()
  Widget laporanCard(
    String title,
    String total,
    IconData icon, {
    Color color = Colors.green,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        trailing: Text(
          total,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  //=========================================
  // TAB 2 : LAPORAN BUKU
  //=========================================
  Widget _bukuTab() {
    final bukuList = DatabaseHelper.getAllBuku();
    final perKategori = DatabaseHelper.totalBukuPerKategori();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          "${bukuList.length} judul buku • ${DatabaseHelper.totalStok()} total stok",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),

        // Ringkasan per kategori
        if (perKategori.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: perKategori.entries.map((e) {
              return Chip(
                avatar: const Icon(Icons.category, size: 16),
                label: Text("${e.key}: ${e.value}"),
                backgroundColor: Colors.green.shade50,
              );
            }).toList(),
          ),

        const SizedBox(height: 16),

        if (bukuList.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 40),
              child: Text("Belum ada data buku"),
            ),
          )
        else
          ...bukuList.map((buku) {
            final stok = (buku['stok'] ?? 0) as int;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      stok > 0 ? Colors.green.shade100 : Colors.red.shade100,
                  child: Icon(
                    Icons.menu_book,
                    color: stok > 0 ? Colors.green : Colors.red,
                  ),
                ),
                title: Text(
                  buku['judul'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "${buku['penulis']} • ${buku['kategori']} • Rak ${buku['rak']}",
                ),
                trailing: Text(
                  "Stok: $stok",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: stok > 0 ? Colors.green : Colors.red,
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  //=========================================
  // TAB 3 : LAPORAN ANGGOTA
  //=========================================
  Widget _anggotaTab() {
    final anggotaList = DatabaseHelper.getAllAnggota();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          "${anggotaList.length} anggota terdaftar "
          "(${DatabaseHelper.totalAnggotaAktif()} aktif, "
          "${DatabaseHelper.totalAnggotaNonaktif()} nonaktif)",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 16),

        if (anggotaList.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 40),
              child: Text("Belum ada data anggota"),
            ),
          )
        else
          ...anggotaList.map((anggota) {
            final aktif = anggota['status'] == 'Aktif';
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      aktif ? Colors.green.shade100 : Colors.grey.shade300,
                  child: Icon(
                    Icons.person,
                    color: aktif ? Colors.green : Colors.grey,
                  ),
                ),
                title: Text(
                  anggota['nama'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "No. ${anggota['nomorAnggota']} • ${anggota['instansi']}",
                ),
                trailing: Chip(
                  label: Text(
                    anggota['status'],
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: aktif ? Colors.green : Colors.grey,
                ),
              ),
            );
          }),
      ],
    );
  }

  //=========================================
  // TAB 4 : LAPORAN PEMINJAMAN
  //=========================================
  Widget _peminjamanTab() {
    final pinjamList = DatabaseHelper.getAllPinjam();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          "${pinjamList.length} transaksi • "
          "${DatabaseHelper.totalSedangDipinjam()} sedang dipinjam • "
          "${DatabaseHelper.totalSudahKembali()} sudah kembali",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 16),

        if (pinjamList.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 40),
              child: Text("Belum ada data peminjaman"),
            ),
          )
        else
          ...pinjamList.map((pinjam) {
            final dipinjam = pinjam['status'] == 'Dipinjam';
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      dipinjam ? Colors.orange.shade100 : Colors.green.shade100,
                  child: Icon(
                    Icons.swap_horiz,
                    color: dipinjam ? Colors.orange : Colors.green,
                  ),
                ),
                title: Text(
                  pinjam['judulBuku'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "${pinjam['namaAnggota']}\n"
                  "Pinjam: ${pinjam['tanggalPinjam']} • Kembali: ${pinjam['tanggalKembali']}",
                ),
                isThreeLine: true,
                trailing: Chip(
                  label: Text(
                    pinjam['status'],
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: dipinjam ? Colors.orange : Colors.green,
                ),
              ),
            );
          }),
      ],
    );
  }
}