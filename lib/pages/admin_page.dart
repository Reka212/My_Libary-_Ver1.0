import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../database/database_helper.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final Box adminBox = Hive.box('adminBox');

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController noHpController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  bool hidePassword = true;
  List<Map<String, dynamic>> adminList = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() {
    adminList = DatabaseHelper.cariAdmin(searchController.text);
    setState(() {});
  }

  //===============================
  // TAMBAH ADMIN
  //===============================
  Future<void> tambahAdmin() async {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Username dan password wajib diisi!")),
      );
      return;
    }

    if (DatabaseHelper.isUsernameExist(usernameController.text.trim())) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Username sudah dipakai!")));
      return;
    }

    await DatabaseHelper.tambahAdmin(
      username: usernameController.text.trim(),
      email: emailController.text.trim(),
      noHp: noHpController.text.trim(),
      password: passwordController.text,
    );

    loadData();

    if (!mounted) return;
    Navigator.pop(context);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Admin berhasil ditambahkan")));
  }

  //===============================
  // EDIT ADMIN
  //===============================
  Future<void> simpanEditAdmin(int key) async {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Username dan password wajib diisi!")),
      );
      return;
    }

    if (DatabaseHelper.isUsernameExist(
      usernameController.text.trim(),
      kecualiKey: key,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Username sudah dipakai admin lain!")),
      );
      return;
    }

    await DatabaseHelper.updateAdmin(
      key: key,
      username: usernameController.text.trim(),
      email: emailController.text.trim(),
      noHp: noHpController.text.trim(),
      password: passwordController.text,
    );

    loadData();

    if (!mounted) return;
    Navigator.pop(context);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Admin berhasil diperbarui")));
  }

  //===============================
  // HAPUS ADMIN
  //===============================
  Future<void> hapusAdmin(int key) async {
    // Jangan biarkan admin terakhir terhapus, supaya tidak ada yang
    // terkunci tidak bisa login sama sekali.
    if (DatabaseHelper.totalAdmin() <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tidak bisa menghapus admin terakhir!")),
      );
      return;
    }

    await DatabaseHelper.deleteAdmin(key);
    loadData();
  }

  void bukaFormTambah() {
    usernameController.clear();
    emailController.clear();
    noHpController.clear();
    passwordController.clear();
    hidePassword = true;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Tambah Admin"),
          content: _formFields(setDialogState),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(onPressed: tambahAdmin, child: const Text("Simpan")),
          ],
        ),
      ),
    );
  }

  void bukaFormEdit(Map<String, dynamic> admin) {
    usernameController.text = admin['username'] ?? '';
    emailController.text = admin['email'] ?? '';
    noHpController.text = admin['noHp'] ?? '';
    passwordController.text = admin['password'] ?? '';
    hidePassword = true;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Edit Admin"),
          content: _formFields(setDialogState),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () => simpanEditAdmin(admin['key']),
              child: const Text("Update"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _formFields(void Function(void Function()) setDialogState) {
    return SingleChildScrollView(
      child: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: noHpController,
              decoration: const InputDecoration(
                labelText: 'No HP',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: hidePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    hidePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setDialogState(() {
                      hidePassword = !hidePassword;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Admin'),
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
                labelText: "Cari Admin",
                hintText: "Masukkan username atau email",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                loadData();
              },
            ),
          ),
          Expanded(
            child: adminList.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada data admin',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: adminList.length,
                    itemBuilder: (context, index) {
                      final admin = adminList[index];

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Icon(
                              Icons.admin_panel_settings,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            admin['username'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text("${admin['email']}\n${admin['noHp']}"),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.orange,
                                ),
                                onPressed: () => bukaFormEdit(admin),
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
                                      content: Text(
                                        "Hapus admin '${admin['username']}' ?",
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
                                            hapusAdmin(admin['key']);
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
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: bukaFormTambah,
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    noHpController.dispose();
    passwordController.dispose();
    searchController.dispose();
    super.dispose();
  }
}
