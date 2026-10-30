import 'package:flutter/material.dart';
import '../components/ui_components.dart';
import '../database/database_helper.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final username = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  bool hidePass = true;
  bool hideConfirm = true;

  void handleRegister() async {
    if (username.text.isEmpty ||
        email.text.isEmpty ||
        phone.text.isEmpty ||
        password.text.isEmpty ||
        confirmPassword.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua field wajib diisi!")),
      );
      return;
    }

    if (password.text != confirmPassword.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password tidak sama!")),
      );
      return;
    }

    if (DatabaseHelper.isUsernameExist(username.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Username sudah terdaftar!")),
      );
      return;
    }

    await DatabaseHelper.tambahAdmin(
      username: username.text.trim(),
      email: email.text.trim(),
      noHp: phone.text.trim(),
      password: password.text,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Registrasi berhasil! Silakan login.")),
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    username.dispose();
    email.dispose();
    phone.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            UIComponents.header("Register"),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Username
                  UIComponents.inputField(
                    controller: username,
                    label: "Username",
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 15),

                  // Email
                  UIComponents.inputField(
                    controller: email,
                    label: "Email",
                    icon: Icons.email,
                  ),
                  const SizedBox(height: 15),

                  // No HP
                  UIComponents.inputField(
                    controller: phone,
                    label: "No HP",
                    icon: Icons.phone,
                  ),
                  const SizedBox(height: 15),

                  // Password
                  UIComponents.inputField(
                    controller: password,
                    label: "Password",
                    icon: Icons.lock,
                    isPassword: true,
                    obscureText: hidePass,
                    togglePassword: () {
                      setState(() {
                        hidePass = !hidePass;
                      });
                    },
                  ),
                  const SizedBox(height: 15),

                  // Konfirmasi Password
                  UIComponents.inputField(
                    controller: confirmPassword,
                    label: "Konfirmasi Password",
                    icon: Icons.lock_outline,
                    isPassword: true,
                    obscureText: hideConfirm,
                    togglePassword: () {
                      setState(() {
                        hideConfirm = !hideConfirm;
                      });
                    },
                  ),
                  const SizedBox(height: 25),

                  // Tombol Register
                  UIComponents.primaryButton(
                    text: "Register",
                    onPressed: handleRegister,
                  ),
                  const SizedBox(height: 20),

                  // Link ke Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Sudah punya akun? "),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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