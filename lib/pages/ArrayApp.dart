import 'package:flutter/material.dart';

void main() {
  runApp(const ArrayApp());
}

class ArrayApp extends StatelessWidget {
  const ArrayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Belajar Array Flutter',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //================ ARRAY ===================
  List<String> buah = ["🍎 Apel", "🍌 Pisang", "🍇 Anggur", "🍊 Jeruk"];

  final TextEditingController controller = TextEditingController();

  int selectedIndex = -1;
  String hasilCari = "";
  //===============================
  // TAMBAH DATA
  //===============================
  void tambahData() {
    if (controller.text.isEmpty) return;

    setState(() {
      buah.add(controller.text);
      controller.clear();
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Data berhasil ditambahkan")));
  }

  //===============================
  // EDIT DATA
  //===============================
  void editData() {
    if (selectedIndex == -1) return;

    if (controller.text.isEmpty) return;

    setState(() {
      buah[selectedIndex] = controller.text;
      controller.clear();
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Data berhasil diubah")));
  }

  //===============================
  // HAPUS DATA
  //===============================
  void hapusData() {
    if (selectedIndex == -1) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Konfirmasi"),

          content: Text("Hapus ${buah[selectedIndex]} ?"),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Batal"),
            ),

            ElevatedButton(
              onPressed: () {
                setState(() {
                  buah.removeAt(selectedIndex);
                  selectedIndex = -1;
                });

                Navigator.pop(context);
              },
              child: const Text("Hapus"),
            ),
          ],
        );
      },
    );
  }

  //===============================
  // CARI DATA
  //===============================
  void cariData() {
    if (controller.text.isEmpty) return;

    int index = buah.indexOf(controller.text);

    setState(() {
      if (index != -1) {
        hasilCari = "Data ditemukan pada index $index";

        selectedIndex = index;
      } else {
        hasilCari = "Data tidak ditemukan.";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(seconds: 1),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: const Text(
                "Belajar Array",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //==================================================
            // CARD PENJELASAN
            //==================================================
            AnimatedOpacity(
              duration: const Duration(seconds: 1),
              opacity: 1,
              child: Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Apa itu Array?",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),

                      SizedBox(height: 10),

                      Text(
                        "Array (List pada Dart) adalah kumpulan data "
                        "yang disimpan dalam satu variabel.\n\n"
                        "Setiap data memiliki indeks.\n"
                        "Indeks selalu dimulai dari 0.",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Isi Array",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),

            const SizedBox(height: 10),

            //=========================================
            // MENAMPILKAN ARRAY
            //=========================================
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: buah.length,
              itemBuilder: (context, index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: selectedIndex == index
                        ? Colors.indigo.shade100
                        : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.indigo),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(child: Text(index.toString())),
                    title: Text(
                      buah[index],
                      style: const TextStyle(fontSize: 18),
                    ),
                    subtitle: Text("Index = $index"),
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            //=========================================
            // JUMLAH DATA
            //=========================================
            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Text(
                  "Jumlah Data : ${buah.length}",
                  key: ValueKey(buah.length),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: "Masukkan nama buah",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                prefixIcon: const Icon(Icons.edit),
              ),
            ),

            const SizedBox(height: 20),

            //=========================================
            // TOMBOL (AKAN DIFUNGSIKAN DI BAGIAN 2)
            //=========================================
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                    label: const Text("Tambah"),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.delete),
                    label: const Text("Hapus"),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.search),
                    label: const Text("Cari"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            Card(
              color: Colors.amber.shade100,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Text(
                  hasilCari.isEmpty
                      ? "Hasil pencarian akan muncul di sini."
                      : hasilCari,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Card(
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                  "Operasi Array yang akan dipelajari:\n\n"
                  "• add()\n"
                  "• removeAt()\n"
                  "• indexOf()\n"
                  "• length\n"
                  "• update data menggunakan index\n\n"
                  "Semua operasi tersebut akan dicoba pada aplikasi ini.",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Card(
              color: Colors.indigo.shade50,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Penjelasan Operasi Array",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),

                    SizedBox(height: 15),

                    Text("✔ add() : Menambahkan data ke array."),

                    SizedBox(height: 8),

                    Text(
                      "✔ removeAt(index) : Menghapus data berdasarkan indeks.",
                    ),

                    SizedBox(height: 8),

                    Text("✔ indexOf(data) : Mencari posisi suatu data."),

                    SizedBox(height: 8),

                    Text("✔ length : Menghitung jumlah elemen."),

                    SizedBox(height: 8),

                    Text("✔ array[index] : Mengakses atau mengubah isi array."),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            Center(
              child: Column(
                children: const [
                  Icon(Icons.school, size: 45, color: Colors.indigo),

                  SizedBox(height: 10),

                  Text(
                    "Media Pembelajaran Array\nFlutter & Dart",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
