import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../database/database_helper.dart';

class BukuPage extends StatefulWidget {
  const BukuPage({super.key});

  @override
  State<BukuPage> createState() => _BukuPageState();
}

class _BukuPageState extends State<BukuPage> {
  final Box bukuBox = Hive.box('bukuBox');
  final TextEditingController judulController = TextEditingController();
  final TextEditingController penulisController = TextEditingController();
  final TextEditingController isbnController = TextEditingController();
  final TextEditingController penerbitController = TextEditingController();
  final TextEditingController tahunController = TextEditingController();
  final TextEditingController kategoriController = TextEditingController();
  final TextEditingController stokController = TextEditingController();
  final TextEditingController rakController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> bukuList = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() {
    bukuList = DatabaseHelper.cariBuku(searchController.text);
    setState(() {});
  }

  void tambahBuku() {
    print("Tambah buku ditekan");

    bukuBox.add({
      'isbn': isbnController.text,
      'judul': judulController.text,
      'penulis': penulisController.text,
      'penerbit': penerbitController.text,
      'tahun': tahunController.text,
      'kategori': kategoriController.text,
      'stok': int.tryParse(stokController.text) ?? 0,
      'rak': rakController.text,
    });

    print("Total data: ${bukuBox.length}");

    loadData();

    Navigator.pop(context);
  }

  void hapusBuku(int key) {
    bukuBox.deleteAt(key);

    loadData();
  }

  void editBuku(Map<String, dynamic> buku) {
    isbnController.text = buku['isbn'] ?? '';
    judulController.text = buku['judul'] ?? '';
    penulisController.text = buku['penulis'] ?? '';
    penerbitController.text = buku['penerbit'] ?? '';
    tahunController.text = buku['tahun'] ?? '';
    kategoriController.text = buku['kategori'] ?? '';
    stokController.text = buku['stok'].toString();
    rakController.text = buku['rak'] ?? '';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Buku'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: isbnController,
                  decoration: const InputDecoration(
                    labelText: 'ISBN',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: judulController,
                  decoration: const InputDecoration(
                    labelText: 'Judul Buku',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: penulisController,
                  decoration: const InputDecoration(
                    labelText: 'Penulis',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: penerbitController,
                  decoration: const InputDecoration(
                    labelText: 'Penerbit',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: tahunController,
                  decoration: const InputDecoration(
                    labelText: 'Tahun Terbit',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: kategoriController,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: stokController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Stok',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: rakController,
                  decoration: const InputDecoration(
                    labelText: 'Lokasi Rak',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              bukuBox.putAt(buku['key'], {
                'isbn': isbnController.text,
                'judul': judulController.text,
                'penulis': penulisController.text,
                'penerbit': penerbitController.text,
                'tahun': tahunController.text,
                'kategori': kategoriController.text,
                'stok': int.tryParse(stokController.text) ?? 0,
                'rak': rakController.text,
              });

              Navigator.pop(context);

              loadData();
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void showTambahDialog() {
    isbnController.clear();
    judulController.clear();
    penulisController.clear();
    penerbitController.clear();
    tahunController.clear();
    kategoriController.clear();
    stokController.clear();
    rakController.clear();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tambah Buku'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: isbnController,
                  decoration: const InputDecoration(
                    labelText: 'ISBN',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: judulController,
                  decoration: const InputDecoration(
                    labelText: 'Judul Buku',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: penulisController,
                  decoration: const InputDecoration(
                    labelText: 'Penulis',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: penerbitController,
                  decoration: const InputDecoration(
                    labelText: 'Penerbit',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: tahunController,
                  decoration: const InputDecoration(
                    labelText: 'Tahun Terbit',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: kategoriController,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: stokController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Stok',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: rakController,
                  decoration: const InputDecoration(
                    labelText: 'Lokasi Rak',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(onPressed: tambahBuku, child: const Text('Simpan')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Buku'),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: "Cari Buku",
                hintText: "Masukkan judul atau penulis buku",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                loadData();
              },
            ),
          ),

          Expanded(
            child: bukuList.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada data buku',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: bukuList.length,
                    itemBuilder: (context, index) {
                      final buku = bukuList[index];

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                buku['judul'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text("ISBN : ${buku['isbn']}"),
                              Text("Penulis : ${buku['penulis']}"),
                              Text("Penerbit : ${buku['penerbit']}"),
                              Text("Tahun : ${buku['tahun']}"),
                              Text("Kategori : ${buku['kategori']}"),
                              Text("Stok : ${buku['stok']}"),
                              Text("Rak : ${buku['rak']}"),

                              const Divider(),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.orange,
                                    ),
                                    onPressed: () {
                                      editBuku(buku);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: const Text("Konfirmasi"),
                                          content: const Text(
                                            "Hapus buku ini?",
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text("Batal"),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                hapusBuku(buku['key']);
                                                Navigator.pop(context);
                                              },
                                              child: const Text("Hapus"),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showTambahDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    isbnController.dispose();
    judulController.dispose();
    penulisController.dispose();
    penerbitController.dispose();
    tahunController.dispose();
    kategoriController.dispose();
    stokController.dispose();
    rakController.dispose();
    searchController.dispose();
    super.dispose();
  }
}
