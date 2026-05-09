import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  static const String baseUrl = "http://127.0.0.1:8000";

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      final loginResponse = await http.post(
        Uri.parse("$baseUrl/accounts/api/login/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": _emailController.text.trim(),
          "password": _passwordController.text.trim(),
        }),
      );

      final loginData = jsonDecode(loginResponse.body);

      if (loginResponse.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        final token = loginData["access"];
        await prefs.setString("access_token", token);

        final meResponse = await http.get(
          Uri.parse("$baseUrl/accounts/users/me/"),
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        );

        if (meResponse.statusCode == 200) {
          final meData = jsonDecode(utf8.decode(meResponse.bodyBytes));
          await prefs.setString("role", meData["role"]);
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          _showError("Хэрэглэгчийн мэдээлэл авахад алдаа гарлаа");
        }
      } else {
        _showError(loginData["detail"] ?? "Нэвтрэхэд алдаа гарлаа");
      }
    } catch (e) {
      _showError("Сервертэй холбогдоход алдаа гарлаа");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFF2D265B); // Зураг дээрх хөх өнгө
    final accentColor = const Color(0xFFFFB6B6); // Зураг дээрх ягаан өнгө

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              height: MediaQuery.of(context).size.height * 0.4,
              width: double.infinity,
              decoration: BoxDecoration(
                color: themeColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(80),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_note_rounded, size: 80, color: accentColor),
                  const SizedBox(height: 15),
                  const Text(
                    "Event System",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Нэвтрэх",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: themeColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Системд нэвтэрч үйл ажиллагаагаа эхлүүлнэ үү.",
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 40),
                  // Email Field
                  _buildInput(
                    controller: _emailController,
                    label: "Имэйл",
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 20),
                  // Password Field
                  _buildInput(
                    controller: _passwordController,
                    label: "Нууц үг",
                    icon: Icons.lock_open_rounded,
                    isPassword: true,
                  ),
                  const SizedBox(height: 40),
                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "НЭВТРЭХ",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/register_page'),
                      child: Text(
                        "Шинэ хэрэглэгч үү? Бүртгүүлэх",
                        style: TextStyle(color: themeColor, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF2D265B)),
        filled: true,
        fillColor: const Color(0xFFF3F3F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}