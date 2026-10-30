import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'package:intl/intl.dart';

class AnggotaPage extends StatefulWidget {
  const AnggotaPage({super.key});

  @override
  State<AnggotaPage> createState() => _AnggotaPageState();
}

class _AnggotaPageState extends State<AnggotaPage> {
  final TextEditingController idAnggotaController = TextEditingController();
  final TextEditingController nomorAnggotaController = TextEditingController();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController jenisKelaminController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();
  final TextEditingController noHpController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController instansiController = TextEditingController();
  final TextEditingController tanggalDaftarController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final TextEditingController statusController = TextEditingController(
    text: 'Aktif',
  );

  List<Map<String, dynamic>> anggotaList = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() {
    anggotaList = DatabaseHelper.cariAnggota(searchController.text);

    setState(() {});
  }

  Future<void> tambahAnggota() async {
    await DatabaseHelper.tambahAnggota(
      idAnggota: idAnggotaController.text,
      nomorAnggota: nomorAnggotaController.text,
      nama: namaController.text,
      jenisKelamin: jenisKelaminController.text,
      alamat: alamatController.text,
      noHp: noHpController.text,
      email: emailController.text,
      instansi: instansiController.text,
      tanggalDaftar: tanggalDaftarController.text,
      status: statusController.text,
    );

    loadData();
    Navigator.pop(context);
  }

  Future<void> pilihTanggal() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      tanggalDaftarController.text = DateFormat(
        'dd-MM-yyyy',
      ).format(pickedDate);
    }
  }

  void showTambahDialog() {
    idAnggotaController.clear();
    nomorAnggotaController.clear();
    namaController.clear();
    jenisKelaminController.clear();
    alamatController.clear();
    noHpController.clear();
    emailController.clear();
    instansiController.clear();
    tanggalDaftarController.clear();
    statusController.text = "Aktif";

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Tambah Anggota"),

        content: SingleChildScrollView(
          child: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: idAnggotaController,
                  decoration: const InputDecoration(
                    labelText: "ID Anggota",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: nomorAnggotaController,
                  decoration: const InputDecoration(
                    labelText: "Nomor Anggota",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: namaController,
                  decoration: const InputDecoration(
                    labelText: "Nama Lengkap",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: jenisKelaminController.text.isEmpty
                      ? null
                      : jenisKelaminController.text,
                  decoration: const InputDecoration(
                    labelText: "Jenis Kelamin",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: "Laki-laki",
                      child: Text("Laki-laki"),
                    ),
                    DropdownMenuItem(
                      value: "Perempuan",
                      child: Text("Perempuan"),
                    ),
                  ],
                  onChanged: (value) {
                    jenisKelaminController.text = value!;
                  },
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: alamatController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: "Alamat",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: noHpController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: "No HP",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: instansiController,
                  decoration: const InputDecoration(
                    labelText: "Instansi",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: tanggalDaftarController,
                  readOnly: true,
                  onTap: pilihTanggal,
                  decoration: const InputDecoration(
                    labelText: "Tanggal Daftar",
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                ),

                const SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  initialValue: statusController.text,
                  decoration: const InputDecoration(
                    labelText: "Status",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: "Aktif", child: Text("Aktif")),
                    DropdownMenuItem(
                      value: "Nonaktif",
                      child: Text("Nonaktif"),
                    ),
                  ],
                  onChanged: (value) {
                    statusController.text = value!;
                  },
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
            child: const Text("Batal"),
          ),

          ElevatedButton(onPressed: tambahAnggota, child: const Text("Simpan")),
        ],
      ),
    );
  }

  Future<void> editAnggota(int key) async {
    await DatabaseHelper.updateAnggota(
      key: key,
      idAnggota: idAnggotaController.text,
      nomorAnggota: nomorAnggotaController.text,
      nama: namaController.text,
      jenisKelamin: jenisKelaminController.text,
      alamat: alamatController.text,
      noHp: noHpController.text,
      email: emailController.text,
      instansi: instansiController.text,
      tanggalDaftar: tanggalDaftarController.text,
      status: statusController.text,
    );

    loadData();
    Navigator.pop(context);
  }

  void showEditDialog(Map<String, dynamic> anggota) {
    // isi controller dari data lama
    idAnggotaController.text = anggota['idAnggota'];
    nomorAnggotaController.text = anggota['nomorAnggota'];
    namaController.text = anggota['nama'];
    jenisKelaminController.text = anggota['jenisKelamin'];
    alamatController.text = anggota['alamat'];
    noHpController.text = anggota['noHp'];
    emailController.text = anggota['email'];
    instansiController.text = anggota['instansi'];
    tanggalDaftarController.text = anggota['tanggalDaftar'];
    statusController.text = anggota['status'];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Anggota"),

        content: SingleChildScrollView(
          child: SizedBox(
            width: 500,

            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                TextField(
                  controller: idAnggotaController,
                  decoration: const InputDecoration(
                    labelText: "ID Anggota",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: nomorAnggotaController,
                  decoration: const InputDecoration(
                    labelText: "Nomor Anggota",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: namaController,
                  decoration: const InputDecoration(
                    labelText: "Nama Lengkap",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: jenisKelaminController.text.isEmpty
                      ? null
                      : jenisKelaminController.text,
                  decoration: const InputDecoration(
                    labelText: "Jenis Kelamin",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: "Laki-laki",
                      child: Text("Laki-laki"),
                    ),
                    DropdownMenuItem(
                      value: "Perempuan",
                      child: Text("Perempuan"),
                    ),
                  ],
                  onChanged: (value) {
                    jenisKelaminController.text = value!;
                  },
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: alamatController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: "Alamat",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: noHpController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: "No HP",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: instansiController,
                  decoration: const InputDecoration(
                    labelText: "Instansi",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: tanggalDaftarController,
                  readOnly: true,
                  onTap: pilihTanggal,
                  decoration: const InputDecoration(
                    labelText: "Tanggal Daftar",
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                ),

                const SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  initialValue: statusController.text,
                  decoration: const InputDecoration(
                    labelText: "Status",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: "Aktif", child: Text("Aktif")),
                    DropdownMenuItem(
                      value: "Nonaktif",
                      child: Text("Nonaktif"),
                    ),
                  ],
                  onChanged: (value) {
                    statusController.text = value!;
                  },
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
            child: const Text("Batal"),
          ),

          ElevatedButton(
            onPressed: () {
              editAnggota(anggota['key']);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  Future<void> hapusAnggota(int key) async {
    await DatabaseHelper.deleteAnggota(key);

    loadData();
  }

  void konfirmasiHapus(int key, String nama) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Hapus Anggota"),
          content: Text("Apakah Anda yakin ingin menghapus anggota\n\n$nama ?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Batal"),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await hapusAnggota(key);

                Navigator.pop(context);
              },
              child: const Text("Hapus"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        title: const Text("Data Anggota"),
        ),
     body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: "Cari Anggota",
                hintText: "Masukkan nama atau nomor anggota",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                loadData();
              },
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: anggotaList.length,
              itemBuilder: (context, index) {
                final anggota = anggotaList[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: ListTile(
                    title: Text(anggota['nama']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("No Anggota : ${anggota['nomorAnggota']}"),
                        Text("No HP : ${anggota['noHp']}"),
                        Text("Status : ${anggota['status']}"),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () {
                            showEditDialog(anggota);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            konfirmasiHapus(anggota['key'], anggota['nama']);
                          },
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
    idAnggotaController.dispose();
    nomorAnggotaController.dispose();
    namaController.dispose();
    jenisKelaminController.dispose();
    alamatController.dispose();
    noHpController.dispose();
    emailController.dispose();
    instansiController.dispose();
    tanggalDaftarController.dispose();
    statusController.dispose();
    searchController.dispose();
    super.dispose();
  }
}
