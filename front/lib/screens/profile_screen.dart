import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'EditProfileScreen.dart';
import 'EditSchoolScreen.dart';
import 'notification_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  // Эмуляторын IP-г kIsWeb-ээр шалгаж тохируулах
  String get imgBase => kIsWeb ? "http://127.0.0.1:8000" : "http://10.0.2.2:8000";

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await _apiService.getMe();
      if (mounted) {
        setState(() {
          _userData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _fullAvatarUrl(String? avatarUrl) {
    if (avatarUrl == null || avatarUrl.isEmpty) {
      return "https://ui-avatars.com/api/?name=${_userData?['username'] ?? 'User'}&background=random";
    }
    return avatarUrl.startsWith('http') ? avatarUrl : "$imgBase$avatarUrl";
  }

  @override
  Widget build(BuildContext context) {
    String name = _userData?['first_name'] ?? _userData?['username'] ?? "Зочин";

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text("Миний профайл", 
          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.textSecondary),
            onPressed: _loadUserProfile,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : RefreshIndicator(
              onRefresh: _loadUserProfile,
              color: AppTheme.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildHeader(name),
                    const SizedBox(height: 30),
                    _buildStatsSection(),
                    const SizedBox(height: 30),
                    _buildMenuSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader(String name) {
    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            if (_userData != null) {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfileScreen(userData: _userData!)),
              );
              if (result == true) _loadUserProfile();
            }
          },
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.primaryGradient,
                ),
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: AppTheme.surfaceLight,
                  backgroundImage: NetworkImage(_fullAvatarUrl(_userData?['avatar'])),
                ),
              ),
              Positioned(
                bottom: 5,
                right: 5,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.bgDark, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(name, 
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textPrimary, fontFamily: 'Nunito')),
        const SizedBox(height: 4),
        Text(_userData?['school_name'] ?? "Сургууль тодорхойгүй", 
          style: const TextStyle(color: AppTheme.textSecondary, fontFamily: 'Nunito')),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem("12", "Эвент"),
          _statItem("5", "Клуб"),
          _statItem("3", "Пост"),
        ],
      ),
    );
  }

  Widget _statItem(String val, String label) => Column(
    children: [
      Text(val, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.primary, fontFamily: 'Nunito')),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontFamily: 'Nunito', fontWeight: FontWeight.w600)),
    ],
  );

  Widget _buildMenuSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(.05)),
      ),
      child: Column(
        children: [
          _menuItem(Icons.calendar_month_rounded, "Миний эвентүүд", AppTheme.primary, () {}),
          _divider(),
          _menuItem(Icons.notifications_active_rounded, "Мэдэгдэл", Colors.orangeAccent, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen()));
          }),
          if (_userData?['role'] == 'school_admin') ...[
            _divider(),
            _menuItem(Icons.admin_panel_settings_rounded, "Сургуулийн мэдээлэл засах", Colors.blueAccent, () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditSchoolScreen(userData: _userData!)),
              );
              if (result == true) _loadUserProfile();
            }),
          ],
          _divider(),
          _menuItem(Icons.logout_rounded, "Гарах", AppTheme.danger, () async {
            bool? confirm = await _showLogoutDialog();
            if (confirm == true) {
              await _apiService.logout();
              if (mounted) Navigator.pushReplacementNamed(context, '/login');
            }
          }),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, Color color, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, 
        style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, color: color == AppTheme.danger ? AppTheme.danger : AppTheme.textPrimary, fontSize: 15)),
      trailing: Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted, size: 20),
    );
  }

  Widget _divider() => Divider(height: 1, color: Colors.white.withOpacity(0.05), indent: 50, endIndent: 20);

  Future<bool?> _showLogoutDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Системээс гарах уу?", style: TextStyle(color: AppTheme.textPrimary, fontFamily: 'Nunito')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Үгүй", style: TextStyle(color: AppTheme.textMuted))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Тийм", style: TextStyle(color: AppTheme.danger))),
        ],
      ),
    );
  }
}