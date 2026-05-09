import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool isStudent = true;
  bool isLoading = false;

  // Өнгөний тогтмол утгууд (Login хуудастай ижил)
  final Color themeColor = const Color(0xFF2D265B); // Гүн хөх
  final Color accentColor = const Color(0xFFFFB6B6); // Зөөлөн ягаан
  final Color inputFillColor = const Color(0xFFF3F3F9);

  String _selectedRole = 'student';
  final List<String> _roles = ['student', 'club_leader'];

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _schoolNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _adminEmailController = TextEditingController();

  final String baseUrl = "http://127.0.0.1:8000";

  Future<void> _handleRegister() async {
    setState(() => isLoading = true);

    String url = isStudent
        ? "$baseUrl/accounts/api/signup/"
        : "$baseUrl/accounts/api/schools/register/";

    Map<String, dynamic> body = isStudent
        ? {
            "username": _usernameController.text.trim(),
            "email": _emailController.text.trim(),
            "password": _passwordController.text,
            "school": 1,
            "role": _selectedRole,
            "phone": _phoneController.text.trim(),
          }
        : {
            "name": _schoolNameController.text.trim(),
            "address": _addressController.text.trim(),
            "admin_email": _adminEmailController.text.trim(),
            "role": "school_admin",
          };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 201 || response.statusCode == 200) {
        _showMessage(isStudent ? "Амжилттай бүртгэгдлээ!" : "Сургуулийн хүсэлт илгээгдлээ!", isError: false);
        if (mounted) Navigator.pop(context);
      } else {
        String error = "Мэдээлэл буруу байна";
        if (responseData is Map) {
          error = responseData.values.first is List
              ? responseData.values.first[0].toString()
              : responseData.values.first.toString();
        }
        _showMessage(error);
      }
    } catch (e) {
      _showMessage("Сервертэй холбогдож чадсангүй.");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showMessage(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: themeColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Дээд хэсгийн Header (Login-той ижил хэлбэр)
            Container(
              height: 180,
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
                  Icon(Icons.person_add_rounded, size: 60, color: accentColor),
                  const SizedBox(height: 10),
                  const Text(
                    "Бүртгүүлэх",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
              child: Column(
                children: [
                  // Оюутан / Сургууль сонгох Toggle
                  _buildToggleButtons(),
                  const SizedBox(height: 30),

                  if (isStudent) ...[
                    _buildTextField(_usernameController, "Хэрэглэгчийн нэр", Icons.person_outline),
                    _buildTextField(_emailController, "Имэйл хаяг", Icons.email_outlined),
                    _buildTextField(_passwordController, "Нууц үг", Icons.lock_outline, isPassword: true),
                    _buildRoleDropdown(),
                    _buildTextField(_phoneController, "Утасны дугаар", Icons.phone_android_outlined),
                  ] else ...[
                    _buildTextField(_schoolNameController, "Сургуулийн нэр", Icons.school_outlined),
                    _buildTextField(_addressController, "Хаяг байршил", Icons.location_on_outlined),
                    _buildTextField(_adminEmailController, "Сургуулийн и-мэйл", Icons.admin_panel_settings_outlined),
                  ],

                  const SizedBox(height: 25),
                  _buildRegisterButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: inputFillColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          _toggleBtn("Оюутан", isStudent, () => setState(() => isStudent = true)),
          _toggleBtn("Сургууль", !isStudent, () => setState(() => isStudent = false)),
        ],
      ),
    );
  }

  Widget _toggleBtn(String text, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            color: active ? themeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: active ? Colors.white : themeColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: inputFillColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedRole,
            isExpanded: true,
            icon: Icon(Icons.arrow_drop_down, color: themeColor),
            items: _roles.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value == 'student' ? "Оюутан" : "Клубын ахлагч",
                  style: TextStyle(color: themeColor, fontSize: 15),
                ),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() => _selectedRole = newValue!);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black38),
          prefixIcon: Icon(icon, color: themeColor, size: 22),
          filled: true,
          fillColor: inputFillColor,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: accentColor, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: themeColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 4,
        ),
        onPressed: isLoading ? null : _handleRegister,
        child: isLoading
            ? const SizedBox(height: 25, width: 25, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text(
                "БҮРТГҮҮЛЭХ",
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
      ),
    );
  }
}