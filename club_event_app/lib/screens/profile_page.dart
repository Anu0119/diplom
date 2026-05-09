import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserModel {
  final int id;
  final String username;
  final String email;
  final String phone;

  UserModel({required this.id, required this.username, required this.email, required this.phone});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
    );
  }
}

class ApiService {
  static Future<UserModel?> getMe() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");
    if (token == null) return null;
    try {
      final response = await http.get(
        Uri.parse("http://127.0.0.1:8000/accounts/users/me/"),
        headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
      );
      if (response.statusCode == 200) {
        return UserModel.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      }
    } catch (e) {
      debugPrint("Алдаа: $e");
    }
    return null;
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _showLogoutDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Гарах", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Та системээс гарахдаа итгэлтэй байна уу?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Болих")),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
              }
            },
            child: const Text("Гарах", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFF2D265B);
    final accentColor = const Color(0xFFFFB6B6);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text("Профайл", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: themeColor,
      ),
      body: FutureBuilder<UserModel?>(
        future: ApiService.getMe(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) return const Center(child: Text("Мэдээлэл олдсонгүй"));

          final user = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Profile Avatar
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: accentColor, width: 3)),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: themeColor,
                      child: Text(
                        user.username[0].toUpperCase(),
                        style: const TextStyle(fontSize: 45, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(user.username, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: themeColor)),
                const SizedBox(height: 30),
                
                // Info Cards
                _buildInfoCard(Icons.alternate_email, "Имэйл хаяг", user.email),
                _buildInfoCard(Icons.phone_iphone, "Утасны дугаар", user.phone),
                
                const SizedBox(height: 40),
                
                // Buttons
                _buildButton("Нууц үг солих", () {}, color: themeColor),
                const SizedBox(height: 15),
                _buildButton("Log out", () => _showLogoutDialog(context), isOutlined: true),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2D265B)),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onTap, {Color? color, bool isOutlined = false}) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined ? Colors.white : color,
          elevation: isOutlined ? 0 : 2,
          side: isOutlined ? const BorderSide(color: Colors.redAccent) : BorderSide.none,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isOutlined ? Colors.redAccent : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}