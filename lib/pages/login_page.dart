import 'package:flutter/material.dart';
import '../components/ui_components.dart';
import '../database/database_helper.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();
  bool isHidden = true;
  void handleLogin() {
    if (username.text.isEmpty || password.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Harap isi semua field!")));
      return;
    }
    final valid = DatabaseHelper.validasiLogin(
      username.text.trim(),
      password.text,
    );

    if (valid) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Username atau password salah!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            UIComponents.header("Login"),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  UIComponents.inputField(
                    controller: username,
                    label: "Username",
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 15),
                  UIComponents.inputField(
                    controller: password,
                    label: "Password",
                    icon: Icons.lock,
                    isPassword: true,
                    obscureText: isHidden,
                    togglePassword: () {
                      setState(() {
                        isHidden = !isHidden;
                      });
                    },
                  ),
                  const SizedBox(height: 25),
                  UIComponents.primaryButton(
                    text: "Login",
                    onPressed: handleLogin,
                  ),
                  const SizedBox(height: 20),
                 
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
