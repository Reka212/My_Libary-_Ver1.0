import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class PinjamPage extends StatefulWidget {
  const PinjamPage({super.key});

  @override
  State<PinjamPage> createState() => _PinjamPageState();
}

class _PinjamPageState extends State<PinjamPage> {
  final TextEditingController idPinjamController = TextEditingController();
  final TextEditingController nomorAnggotaController = TextEditingController();
  final TextEditingController namaAnggotaController = TextEditingController();
  final TextEditingController isbnController = TextEditingController();
  final TextEditingController judulBukuController = TextEditingController();
  final TextEditingController tanggalPinjamController = TextEditingController();
  final TextEditingController tanggalKembaliController =
      TextEditingController();
  final TextEditingController statusController = TextEditingController(
    text: "Dipinjam",
  );
  
  List<Map<String, dynamic>> bukuList = [];
  bool isSaving = false;
  List<Map<String, dynamic>> pinjamList = [];
  Map<String, dynamic>? selectedAnggota;
  Map<String, dynamic>? selectedBuku;
  List<Map<String, dynamic>> anggotaList = [];
  
  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() {
    pinjamList = DatabaseHelper.getAllPinjam();
    anggotaList = DatabaseHelper.getAllAnggota();
    bukuList = DatabaseHelper.getAllBuku();
    setState(() {});
  }

  void Function(VoidCallback fn)? _dialogSetState;

  void _setSaving(bool value) {
    isSaving = value;
    if (_dialogSetState != null) {
      _dialogSetState!(() {});
    } else {
      setState(() {});
    }
  }

  bool isEditSaving = false; // guard anti double-submit khusus dialog Edit
  void Function(VoidCallback fn)? _editDialogSetState;

  void _setEditSaving(bool value) {
    isEditSaving = value;
    if (_editDialogSetState != null) {
      _editDialogSetState!(() {});
    } else {
      setState(() {});
    }
  }

  Future<void> tambahPinjam() async {
    if (isSaving) return; // cegah dobel tap / dobel submit

    // Validasi field wajib
    if (selectedAnggota == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih anggota terlebih dahulu.")),
      );
      return;
    }
    if (selectedBuku == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih buku terlebih dahulu.")),
      );
      return;
    }
    if (tanggalPinjamController.text.isEmpty ||
        tanggalKembaliController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tanggal pinjam dan tanggal kembali wajib diisi."),
        ),
      );
      return;
    }

    _setSaving(true);
    try {
      final keyBuku = DatabaseHelper.getKeyBukuByIsbn(isbnController.text);
      if (keyBuku == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Buku tidak ditemukan.")));
        return;
      }
      final buku = DatabaseHelper.getAllBuku()[keyBuku];
      final stok = (buku['stok'] ?? 0) as int;
      if (stok <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Buku sudah habis dipinjam."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await DatabaseHelper.kurangiStokBuku(keyBuku);
      await DatabaseHelper.tambahPinjam(
        idPinjam: idPinjamController.text,
        nomorAnggota: nomorAnggotaController.text,
        namaAnggota: namaAnggotaController.text,
        isbn: isbnController.text,
        judulBuku: judulBukuController.text,
        tanggalPinjam: tanggalPinjamController.text,
        tanggalKembali: tanggalKembaliController.text,
        status: statusController.text,
      );

      loadData();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Terjadi kesalahan: $e")));
      }
    } finally {
      _setSaving(false);
    }
  }

  void showTambahDialog() {
    idPinjamController.text = generateIdPinjam();
    selectedAnggota = null;
    selectedBuku = null;
    nomorAnggotaController.clear();
    namaAnggotaController.clear();
    isbnController.clear();
    judulBukuController.clear();
    tanggalPinjamController.clear();
    tanggalKembaliController.clear();

    statusController.text = "Dipinjam";

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            _dialogSetState = setDialogState;
            return AlertDialog(
              title: const Text("Peminjaman Buku"),

              content: SingleChildScrollView(
                child: SizedBox(
                  width: 500,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // =========================
                      // ID PEMINJAMAN
                      // =========================
                      TextField(
                        controller: idPinjamController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: "ID Peminjaman",
                          border: OutlineInputBorder(),
                          filled: true,
                          suffixIcon: Icon(Icons.lock_outline),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // =========================
                      // PILIH ANGGOTA
                      // =========================
                      DropdownButtonFormField<Map<String, dynamic>>(
                        initialValue: selectedAnggota,
                        decoration: const InputDecoration(
                          labelText: "Pilih Anggota",
                          border: OutlineInputBorder(),
                        ),
                        items: anggotaList.map((anggota) {
                          return DropdownMenuItem<Map<String, dynamic>>(
                            value: anggota,
                            child: Text(anggota['nama'].toString()),
                          );
                        }).toList(),

                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() {
                              selectedAnggota = value;
                              nomorAnggotaController.text =
                                  value['nomorAnggota'].toString();
                              namaAnggotaController.text = value['nama']
                                  .toString();
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 10),

                      // =========================
                      // INFORMASI ANGGOTA
                      // =========================
                      Card(
                        color: Colors.green.shade50,
                        child: ListTile(
                          leading: const Icon(
                            Icons.person,
                            color: Colors.green,
                          ),
                          title: Text(
                            namaAnggotaController.text.isEmpty
                                ? "-"
                                : namaAnggotaController.text,
                          ),
                          subtitle: Text(
                            "No Anggota : "
                            "${nomorAnggotaController.text.isEmpty ? "-" : nomorAnggotaController.text}",
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // =========================
                      // PILIH BUKU
                      // =========================
                      DropdownButtonFormField<Map<String, dynamic>>(
                        initialValue: selectedBuku,
                        decoration: const InputDecoration(
                          labelText: "Pilih Buku",
                          border: OutlineInputBorder(),
                        ),

                        items: bukuList.map((buku) {
                          final stok = (buku['stok'] ?? 0) as int;

                          return DropdownMenuItem<Map<String, dynamic>>(
                            value: buku,

                            // Stok 0 tidak dapat dipilih
                            enabled: stok > 0,

                            child: Text(
                              stok > 0
                                  ? "${buku['judul']} (Stok: $stok)"
                                  : "${buku['judul']} (HABIS)",
                            ),
                          );
                        }).toList(),

                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() {
                              selectedBuku = value;

                              // Otomatis isi ISBN
                              isbnController.text = value['isbn'].toString();

                              // Otomatis isi Judul Buku
                              judulBukuController.text = value['judul']
                                  .toString();
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 10),

                      // =========================
                      // INFORMASI BUKU
                      // =========================
                      Card(
                        color: Colors.blue.shade50,
                        child: ListTile(
                          leading: const Icon(Icons.book, color: Colors.blue),
                          title: Text(
                            judulBukuController.text.isEmpty
                                ? "-"
                                : judulBukuController.text,
                          ),
                          subtitle: Text(
                            "ISBN : "
                            "${isbnController.text.isEmpty ? "-" : isbnController.text}",
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // =========================
                      // TANGGAL PINJAM
                      // =========================
                      TextField(
                        controller: tanggalPinjamController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: "Tanggal Pinjam",
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        onTap: () {
                          pilihTanggal(tanggalPinjamController);
                        },
                      ),

                      const SizedBox(height: 10),

                      // =========================
                      // TANGGAL KEMBALI
                      // =========================
                      TextField(
                        controller: tanggalKembaliController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: "Tanggal Kembali",
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        onTap: () {
                          pilihTanggal(tanggalKembaliController);
                        },
                      ),

                      const SizedBox(height: 10),

                      // =========================
                      // STATUS
                      // =========================
                      DropdownButtonFormField<String>(
                        initialValue: statusController.text,
                        decoration: const InputDecoration(
                          labelText: "Status",
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: "Dipinjam",
                            child: Text("Dipinjam"),
                          ),
                          DropdownMenuItem(
                            value: "Kembali",
                            child: Text("Kembali"),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() {
                              statusController.text = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // =========================
              // BUTTON
              // =========================
              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () {
                          Navigator.pop(context);
                        },
                  child: const Text("Batal"),
                ),

                ElevatedButton(
                  onPressed: isSaving ? null : tambahPinjam,
                  child: isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Simpan"),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      _dialogSetState = null;
      isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Peminjaman Buku"),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: pinjamList.isEmpty
          ? const Center(
              child: Text(
                "Belum ada data peminjaman",
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: pinjamList.length,
              itemBuilder: (context, index) {
                final pinjam = pinjamList[index];

                return Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: const EdgeInsets.only(bottom: 15),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Judul Buku
                        Row(
                          children: [
                            const Icon(
                              Icons.menu_book,
                              color: Colors.green,
                              size: 30,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                pinjam['judulBuku'],
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        const Divider(),

                        Row(
                          children: [
                            const Icon(
                              Icons.confirmation_number,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 10),
                            Text("ID Pinjam : ${pinjam['idPinjam']}"),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            const Icon(Icons.person, color: Colors.orange),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text("Nama : ${pinjam['namaAnggota']}"),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            const Icon(Icons.badge, color: Colors.purple),
                            const SizedBox(width: 10),
                            Text("No Anggota : ${pinjam['nomorAnggota']}"),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            const Icon(Icons.qr_code, color: Colors.teal),
                            const SizedBox(width: 10),
                            Expanded(child: Text("ISBN : ${pinjam['isbn']}")),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 10),
                            Text("Pinjam : ${pinjam['tanggalPinjam']}"),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            const Icon(
                              Icons.event_available,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 10),
                            Text("Kembali : ${pinjam['tanggalKembali']}"),
                          ],
                        ),

                        const SizedBox(height: 15),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Chip(
                            avatar: Icon(
                              pinjam['status'] == "Dipinjam"
                                  ? Icons.book
                                  : Icons.check_circle,
                              color: Colors.white,
                              size: 18,
                            ),
                            label: Text(
                              pinjam['status'],
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: pinjam['status'] == "Dipinjam"
                                ? Colors.orange
                                : Colors.green,
                          ),
                        ),

                        const Divider(height: 25),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                editPinjam(pinjam);
                              },
                              icon: const Icon(Icons.edit),
                              label: const Text("Edit"),
                            ),

                            const SizedBox(width: 10),

                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                hapusPinjam(pinjam);
                              },
                              icon: const Icon(Icons.delete),
                              label: const Text("Hapus"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: showTambahDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    idPinjamController.dispose();
    nomorAnggotaController.dispose();
    namaAnggotaController.dispose();
    isbnController.dispose();
    judulBukuController.dispose();
    tanggalPinjamController.dispose();
    tanggalKembaliController.dispose();
    statusController.dispose();
    super.dispose();
  }

  Future<void> pilihTanggal(TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      controller.text =
          "${picked.day.toString().padLeft(2, '0')}-"
          "${picked.month.toString().padLeft(2, '0')}-"
          "${picked.year}";
    }
  }

  Future<void> hapusPinjam(Map<String, dynamic> pinjam) async {
    final statusMasihDipinjam = pinjam['status'] == "Dipinjam";

    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Peminjaman"),
        content: Text(
          statusMasihDipinjam
              ? "Data ini berstatus 'Dipinjam'. Menghapusnya akan "
                    "mengembalikan stok buku secara otomatis. Lanjutkan?"
              : "Apakah Anda yakin ingin menghapus data peminjaman ini?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (konfirmasi == true) {
      try {
        if (statusMasihDipinjam) {
          final keyBuku = DatabaseHelper.getKeyBukuByIsbn(
            pinjam['isbn'].toString(),
          );
          if (keyBuku != null) {
            await DatabaseHelper.tambahStokBuku(keyBuku);
          }
        }
        await DatabaseHelper.deletePinjam(pinjam['key']);
        loadData();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Gagal menghapus: $e")));
        }
      }
    }
  }

  void editPinjam(Map<String, dynamic> pinjam) {
  // =========================
  // ISI DATA LAMA
  // =========================
  idPinjamController.text = pinjam['idPinjam']?.toString() ?? '';
  nomorAnggotaController.text =
      pinjam['nomorAnggota']?.toString() ?? '';
  namaAnggotaController.text =
      pinjam['namaAnggota']?.toString() ?? '';
  isbnController.text = pinjam['isbn']?.toString() ?? '';
  judulBukuController.text =
      pinjam['judulBuku']?.toString() ?? '';
  tanggalPinjamController.text =
      pinjam['tanggalPinjam']?.toString() ?? '';
  tanggalKembaliController.text =
      pinjam['tanggalKembali']?.toString() ?? '';
  statusController.text =
      pinjam['status']?.toString() ?? 'Dipinjam';

  // =========================
  // CARI ANGGOTA LAMA
  // =========================
  selectedAnggota = null;

  for (var anggota in anggotaList) {
    if (anggota['nomorAnggota'].toString() ==
        pinjam['nomorAnggota'].toString()) {
      selectedAnggota = anggota;
      break;
    }
  }

  // =========================
  // CARI BUKU LAMA
  // =========================
  selectedBuku = null;

  for (var buku in bukuList) {
    if (buku['isbn'].toString() ==
        pinjam['isbn'].toString()) {
      selectedBuku = buku;
      break;
    }
  }

  showDialog(
    context: context,
    builder: (_) {
      return StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          _editDialogSetState = setDialogState;

          return AlertDialog(
            title: const Text("Edit Peminjaman Buku"),

            content: SingleChildScrollView(
              child: SizedBox(
                width: 500,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // =========================
                    // ID PEMINJAMAN
                    // =========================
                    TextField(
                      controller: idPinjamController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: "ID Peminjaman",
                        border: OutlineInputBorder(),
                        filled: true,
                        suffixIcon: Icon(Icons.lock_outline),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // =========================
                    // PILIH ANGGOTA
                    // =========================
                    DropdownButtonFormField<
                        Map<String, dynamic>>(
                      initialValue: selectedAnggota,
                      decoration: const InputDecoration(
                        labelText: "Pilih Anggota",
                        border: OutlineInputBorder(),
                      ),
                      items: anggotaList.map((anggota) {
                        return DropdownMenuItem<
                            Map<String, dynamic>>(
                          value: anggota,
                          child: Text(
                            anggota['nama'].toString(),
                          ),
                        );
                      }).toList(),
                      onChanged: isEditSaving
                          ? null
                          : (value) {
                              if (value != null) {
                                setDialogState(() {
                                  selectedAnggota = value;

                                  nomorAnggotaController.text =
                                      value['nomorAnggota']
                                          .toString();

                                  namaAnggotaController.text =
                                      value['nama'].toString();
                                });
                              }
                            },
                    ),

                    const SizedBox(height: 10),

                    // =========================
                    // INFORMASI ANGGOTA
                    // =========================
                    Card(
                      color: Colors.green.shade50,
                      child: ListTile(
                        leading: const Icon(
                          Icons.person,
                          color: Colors.green,
                        ),
                        title: Text(
                          namaAnggotaController.text.isEmpty
                              ? "-"
                              : namaAnggotaController.text,
                        ),
                        subtitle: Text(
                          "No Anggota : "
                          "${nomorAnggotaController.text.isEmpty ? "-" : nomorAnggotaController.text}",
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // =========================
                    // PILIH BUKU
                    // =========================
                    DropdownButtonFormField<
                        Map<String, dynamic>>(
                      initialValue: selectedBuku,
                      decoration: const InputDecoration(
                        labelText: "Pilih Buku",
                        border: OutlineInputBorder(),
                      ),
                      items: bukuList.map((buku) {
                        final stok =
                            int.tryParse(
                                  buku['stok']?.toString() ?? '0',
                                ) ??
                                0;

                        // Buku stok 0 tetap boleh dipilih
                        // jika itu adalah buku yang sedang
                        // dipinjam oleh data ini.
                        final bukuSedangDipinjam =
                            buku['isbn'].toString() ==
                                pinjam['isbn'].toString();

                        return DropdownMenuItem<
                            Map<String, dynamic>>(
                          value: buku,
                          enabled:
                              stok > 0 || bukuSedangDipinjam,
                          child: Text(
                            stok > 0
                                ? "${buku['judul']} (Stok: $stok)"
                                : "${buku['judul']} (HABIS)",
                          ),
                        );
                      }).toList(),
                      onChanged: isEditSaving
                          ? null
                          : (value) {
                              if (value != null) {
                                setDialogState(() {
                                  selectedBuku = value;

                                  isbnController.text =
                                      value['isbn'].toString();

                                  judulBukuController.text =
                                      value['judul'].toString();
                                });
                              }
                            },
                    ),

                    const SizedBox(height: 10),

                    // =========================
                    // INFORMASI BUKU
                    // =========================
                    Card(
                      color: Colors.blue.shade50,
                      child: ListTile(
                        leading: const Icon(
                          Icons.book,
                          color: Colors.blue,
                        ),
                        title: Text(
                          judulBukuController.text.isEmpty
                              ? "-"
                              : judulBukuController.text,
                        ),
                        subtitle: Text(
                          "ISBN : "
                          "${isbnController.text.isEmpty ? "-" : isbnController.text}",
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // =========================
                    // TANGGAL PINJAM
                    // =========================
                    TextField(
                      controller: tanggalPinjamController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: "Tanggal Pinjam",
                        border: OutlineInputBorder(),
                        suffixIcon:
                            Icon(Icons.calendar_today),
                      ),
                      onTap: isEditSaving
                          ? null
                          : () {
                              pilihTanggal(
                                tanggalPinjamController,
                              );
                            },
                    ),

                    const SizedBox(height: 10),

                    // =========================
                    // TANGGAL KEMBALI
                    // =========================
                    TextField(
                      controller: tanggalKembaliController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: "Tanggal Kembali",
                        border: OutlineInputBorder(),
                        suffixIcon:
                            Icon(Icons.calendar_today),
                      ),
                      onTap: isEditSaving
                          ? null
                          : () {
                              pilihTanggal(
                                tanggalKembaliController,
                              );
                            },
                    ),

                    const SizedBox(height: 10),

                    // =========================
                    // STATUS
                    // =========================
                    DropdownButtonFormField<String>(
                      initialValue: statusController.text,
                      decoration: const InputDecoration(
                        labelText: "Status",
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: "Dipinjam",
                          child: Text("Dipinjam"),
                        ),
                        DropdownMenuItem(
                          value: "Kembali",
                          child: Text("Kembali"),
                        ),
                      ],
                      onChanged: isEditSaving
                          ? null
                          : (value) {
                              if (value != null) {
                                setDialogState(() {
                                  statusController.text =
                                      value;
                                });
                              }
                            },
                    ),
                  ],
                ),
              ),
            ),

            // =========================
            // BUTTON
            // =========================
            actions: [
              TextButton(
                onPressed: isEditSaving
                    ? null
                    : () {
                        Navigator.pop(dialogContext);
                      },
                child: const Text("Batal"),
              ),

              ElevatedButton(
                onPressed: isEditSaving
                    ? null
                    : () async {
                        if (isEditSaving) return;

                        _setEditSaving(true);

                        try {
                          // =========================
                          // DATA LAMA & BARU
                          // =========================
                          final statusLama =
                              pinjam['status']?.toString() ??
                                  'Dipinjam';

                          final statusBaru =
                              statusController.text;

                          // Apakah buku yang dipilih berbeda
                          // dari buku yang tersimpan sebelumnya?
                          final bukuBerubah =
                              pinjam['isbn'].toString() !=
                                  isbnController.text;

                          // =========================
                          // VALIDASI
                          // =========================
                          if (selectedAnggota == null) {
                            throw Exception(
                              "Pilih anggota terlebih dahulu.",
                            );
                          }

                          if (selectedBuku == null) {
                            throw Exception(
                              "Pilih buku terlebih dahulu.",
                            );
                          }

                          if (tanggalPinjamController
                              .text.isEmpty) {
                            throw Exception(
                              "Tanggal pinjam wajib diisi.",
                            );
                          }

                          if (tanggalKembaliController
                              .text.isEmpty) {
                            throw Exception(
                              "Tanggal kembali wajib diisi.",
                            );
                          }

                          // ==================================================
                          // 1. DIPINJAM -> KEMBALI
                          // ==================================================
                          if (statusLama == "Dipinjam" &&
                              statusBaru == "Kembali") {
                            final keyBuku =
                                DatabaseHelper
                                    .getKeyBukuByIsbn(
                              pinjam['isbn'].toString(),
                            );

                            if (keyBuku != null) {
                              await DatabaseHelper
                                  .tambahStokBuku(
                                keyBuku,
                              );
                            }
                          }

                          // ==================================================
                          // 2. KEMBALI -> DIPINJAM
                          // ==================================================
                          else if (statusLama == "Kembali" &&
                              statusBaru == "Dipinjam") {
                            final keyBuku =
                                DatabaseHelper
                                    .getKeyBukuByIsbn(
                              isbnController.text,
                            );

                            if (keyBuku == null) {
                              throw Exception(
                                "Buku tidak ditemukan.",
                              );
                            }

                            final buku =
                                DatabaseHelper
                                    .getAllBuku()[keyBuku];

                            final stok =
                                int.tryParse(
                                      buku['stok']
                                              ?.toString() ??
                                          '0',
                                    ) ??
                                    0;

                            if (stok <= 0) {
                              throw Exception(
                                "Stok buku sudah habis.",
                              );
                            }

                            await DatabaseHelper
                                .kurangiStokBuku(
                              keyBuku,
                            );
                          }

                          // ==================================================
                          // 3. DIPINJAM -> DIPINJAM
                          //    TAPI BUKUNYA DIGANTI
                          // ==================================================
                          else if (statusLama == "Dipinjam" &&
                              statusBaru == "Dipinjam" &&
                              bukuBerubah) {
                            // ------------------------------------------
                            // Buku lama dikembalikan
                            // ------------------------------------------
                            final keyBukuLama =
                                DatabaseHelper
                                    .getKeyBukuByIsbn(
                              pinjam['isbn'].toString(),
                            );

                            if (keyBukuLama != null) {
                              await DatabaseHelper
                                  .tambahStokBuku(
                                keyBukuLama,
                              );
                            }

                            // ------------------------------------------
                            // Buku baru dikurangi
                            // ------------------------------------------
                            final keyBukuBaru =
                                DatabaseHelper
                                    .getKeyBukuByIsbn(
                              isbnController.text,
                            );

                            if (keyBukuBaru == null) {
                              throw Exception(
                                "Buku baru tidak ditemukan.",
                              );
                            }

                            final bukuBaru =
                                DatabaseHelper
                                    .getAllBuku()[keyBukuBaru];

                            final stokBaru =
                                int.tryParse(
                                      bukuBaru['stok']
                                              ?.toString() ??
                                          '0',
                                    ) ??
                                    0;

                            if (stokBaru <= 0) {
                              throw Exception(
                                "Stok buku baru sudah habis.",
                              );
                            }

                            await DatabaseHelper
                                .kurangiStokBuku(
                              keyBukuBaru,
                            );
                          }

                          // ==================================================
                          // UPDATE DATA PEMINJAMAN
                          // ==================================================
                          await DatabaseHelper.updatePinjam(
                            key: pinjam['key'],
                            idPinjam:
                                idPinjamController.text,
                            nomorAnggota:
                                nomorAnggotaController.text,
                            namaAnggota:
                                namaAnggotaController.text,
                            isbn: isbnController.text,
                            judulBuku:
                                judulBukuController.text,
                            tanggalPinjam:
                                tanggalPinjamController.text,
                            tanggalKembali:
                                tanggalKembaliController.text,
                            status: statusController.text,
                          );

                          // Refresh data
                          loadData();

                          if (mounted) {
                            Navigator.pop(dialogContext);
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Gagal memperbarui data: $e",
                                ),
                                backgroundColor:
                                    Colors.red,
                              ),
                            );
                          }
                        } finally {
                          _setEditSaving(false);
                        }
                      },
                child: isEditSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("Update"),
              ),
            ],
          );
        },
      );
    },
  ).then((_) {
    _editDialogSetState = null;
    isEditSaving = false;
  });
}

  String generateIdPinjam() {
    final now = DateTime.now();
    final tanggal =
        "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
    final prefix = "PJM-$tanggal-";

    int maxNomor = 0;
    for (final p in pinjamList) {
      final id = p['idPinjam'].toString();
      if (id.startsWith(prefix)) {
        final nomor = int.tryParse(id.substring(prefix.length)) ?? 0;
        if (nomor > maxNomor) maxNomor = nomor;
      }
    }

    final nomorBaru = (maxNomor + 1).toString().padLeft(3, '0');
    return "$prefix$nomorBaru";
  }
}
