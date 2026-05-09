import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // 1. Backend-ээс хэрэглэгчийн мэдээлэл татах
  Future<void> _loadUserProfile() async {
    try {
      final data = await _apiService.getMe();
      setState(() {
        _userData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Профайл ачаалахад алдаа гарлаа: $e");
    }
  }

  // 2. Системээс гарах функц
  Future<void> _logout() async {
    await _apiService.logout();
    if (mounted) {
      // Login хуудас руу буцаах (main.dart-д тодорхойлсон route-ээр)
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Өгөгдлийн сан дээр first_name хоосон бол username-ийг харуулна
    String name = _userData?['first_name'] != null && _userData!['first_name'].toString().isNotEmpty
        ? _userData!['first_name']
        : (_userData?['username'] ?? "Уншиж байна...");

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Профайл", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.settings, color: Colors.black), onPressed: () {}),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF3F37C9)))
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildAvatarSection(name),
                  const SizedBox(height: 30),
                  _buildStatsSection(),
                  const SizedBox(height: 20),
                  _buildMenuSection(),
                ],
              ),
            ),
    );
  }

  // Профайлын зураг болон нэр
  Widget _buildAvatarSection(String name) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              const CircleAvatar(
                radius: 55,
                backgroundImage: NetworkImage("https://via.placeholder.com/150"),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  // ЗАСВАР: BoxShape.circle болгож засав
                  decoration: const BoxDecoration(
                    color: Color(0xFF3F37C9),
                    shape: BoxShape.circle, 
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const Text("Оюутан", style: TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  // Статистик хэсэг
  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem("12", "Бүртгүүлсэн"),
          _statItem("5", "Идэвхтэй клуб"),
          _statItem("3", "Нийтлэл"),
        ],
      ),
    );
  }

  // Цэсүүд
  Widget _buildMenuSection() {
    return Column(
      children: [
        _menuItem(Icons.calendar_month_outlined, "Миний эвентүүд"),
        _menuItem(Icons.groups_outlined, "Миний клубүүд"),
        _menuItem(Icons.bookmark_border, "Хадгалсан"),
        _menuItem(Icons.logout, "Гарах", isLast: true, onTap: _logout),
      ],
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF3F37C9))),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _menuItem(IconData icon, String title, {bool isLast = false, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: isLast ? Colors.red : Colors.black87),
      title: Text(title, style: TextStyle(color: isLast ? Colors.red : Colors.black87)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap ?? () {},
    );
  }
}