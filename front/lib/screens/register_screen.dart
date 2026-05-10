import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String baseUrl = kIsWeb ? "http://127.0.0.1:8000/api" : "http://10.0.2.2:8000/api";

  final _uNameCtrl    = TextEditingController();
  final _uEmailCtrl   = TextEditingController();
  final _uPassCtrl    = TextEditingController();
  final _uPhoneCtrl   = TextEditingController();
  Uint8List? _avatarBytes;

  final _sNameCtrl    = TextEditingController();
  final _sEmailCtrl   = TextEditingController();
  final _sAddressCtrl = TextEditingController();
  final _sPassCtrl    = TextEditingController();

  bool _isLoading = false;
  bool _showPass  = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  Future<void> _pickImage() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) {
      final bytes = await file.readAsBytes();
      setState(() => _avatarBytes = bytes);
    }
  }

  void _handleStudentRegister() async {
    if (_uEmailCtrl.text.isEmpty || _uPassCtrl.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      var request = http.MultipartRequest("POST", Uri.parse("$baseUrl/accounts/signup/"));
      request.fields.addAll({
        "username": _uNameCtrl.text,
        "email": _uEmailCtrl.text,
        "password": _uPassCtrl.text,
        "phone": _uPhoneCtrl.text,
        "school": "1",
      });
      if (_avatarBytes != null) {
        request.files.add(http.MultipartFile.fromBytes('avatar', _avatarBytes!,
            filename: 'avatar.jpg', contentType: MediaType('image', 'jpeg')));
      }
      var streamed = await request.send();
      var res = await http.Response.fromStream(streamed);
      if (res.statusCode == 201 && mounted) {
        _showSnack("Амжилттай бүртгүүллээ! 🎉");
        Navigator.pop(context);
      } else {
        throw Exception(res.body);
      }
    } catch (e) {
      _showSnack("Алдаа: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleSchoolRegister() async {
    setState(() => _isLoading = true);
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/accounts/schools/register/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": _sNameCtrl.text, "admin_email": _sEmailCtrl.text,
            "address": _sAddressCtrl.text, "admin_password": _sPassCtrl.text}),
      );
      if (res.statusCode == 201) {
        _showSuccessDialog();
      } else {
        throw Exception(res.body);
      }
    } catch (e) {
      _showSnack("Алдаа: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('🎉 Хүсэлт илгээгдлээ', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
        content: const Text('Сургуулийн бүртгэл хүлээгдэж байна. Батлагдсаны дараа и-мэйл ирнэ.', style: TextStyle(fontFamily: 'Nunito', color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ойлголоо', style: TextStyle(color: AppTheme.primary, fontFamily: 'Nunito', fontWeight: FontWeight.w700)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Stack(children: [
        Positioned(top: -60, right: -60, child: _blob(180, AppTheme.primary.withOpacity(.12))),
        Positioned(bottom: -40, left: -40, child: _blob(140, AppTheme.secondary.withOpacity(.10))),
        SafeArea(
          child: Column(children: [
            // Custom header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
              child: Row(children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(child: Text('Бүртгүүлэх', textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 20, color: AppTheme.textPrimary))),
                const SizedBox(width: 48),
              ]),
            ),
            const SizedBox(height: 16),

            // Tab selector
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(.06)),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelStyle: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 14),
                unselectedLabelStyle: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w600, fontSize: 14),
                labelColor: Colors.white,
                unselectedLabelColor: AppTheme.textSecondary,
                tabs: const [Tab(text: 'Оюутан'), Tab(text: 'Сургууль')],
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildStudentForm(), _buildSchoolForm()],
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildStudentForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(children: [
        // Avatar picker
        GestureDetector(
          onTap: _pickImage,
          child: Stack(alignment: Alignment.bottomRight, children: [
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _avatarBytes == null ? AppTheme.primaryGradient : null,
                image: _avatarBytes != null ? DecorationImage(image: MemoryImage(_avatarBytes!), fit: BoxFit.cover) : null,
                border: Border.all(color: AppTheme.primary.withOpacity(.4), width: 2),
              ),
              child: _avatarBytes == null ? const Icon(Icons.person_rounded, color: Colors.white, size: 40) : null,
            ),
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                gradient: AppTheme.pinkGradient,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.bgDark, width: 2),
              ),
              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
            ),
          ]),
        ),
        const SizedBox(height: 24),
        _field(_uNameCtrl, 'Хэрэглэгчийн нэр', Icons.badge_rounded),
        const SizedBox(height: 12),
        _field(_uEmailCtrl, 'Сургуулийн и-мэйл', Icons.mail_outline_rounded, type: TextInputType.emailAddress),
        const SizedBox(height: 12),
        _field(_uPhoneCtrl, 'Утасны дугаар', Icons.phone_iphone_rounded, type: TextInputType.phone),
        const SizedBox(height: 12),
        _field(_uPassCtrl, 'Нууц үг', Icons.lock_outline_rounded, isPass: true),
        const SizedBox(height: 28),
        GradientButton(text: 'Бүртгүүлэх', isLoading: _isLoading, onTap: _handleStudentRegister),
      ]),
    );
  }

  Widget _buildSchoolForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.primary.withOpacity(.2)),
          ),
          child: const Row(children: [
            Icon(Icons.info_outline_rounded, color: AppTheme.primary, size: 18),
            SizedBox(width: 10),
            Expanded(child: Text('Сургуулийн захиргаа бүртгүүлэх хүсэлт илгээнэ. Систем админ батлах болно.',
              style: TextStyle(fontFamily: 'Nunito', fontSize: 12, color: AppTheme.textSecondary, height: 1.5))),
          ]),
        ),
        const SizedBox(height: 20),
        _field(_sNameCtrl, 'Сургуулийн нэр', Icons.school_rounded),
        const SizedBox(height: 12),
        _field(_sEmailCtrl, 'Админ и-мэйл', Icons.admin_panel_settings_outlined, type: TextInputType.emailAddress),
        const SizedBox(height: 12),
        _field(_sPassCtrl, 'Админ нууц үг', Icons.lock_outline_rounded, isPass: true),
        const SizedBox(height: 12),
        _field(_sAddressCtrl, 'Хаяг, байршил', Icons.location_on_outlined),
        const SizedBox(height: 28),
        GradientButton(text: 'Хүсэлт илгээх', isLoading: _isLoading, onTap: _handleSchoolRegister,
            gradient: AppTheme.greenGradient),
      ]),
    );
  }

  Widget _field(TextEditingController ctrl, String hint, IconData icon,
      {bool isPass = false, TextInputType? type}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(.07)),
      ),
      child: TextField(
        controller: ctrl,
        obscureText: isPass && !_showPass,
        keyboardType: type,
        style: const TextStyle(fontFamily: 'Nunito', color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontFamily: 'Nunito', color: AppTheme.textMuted, fontWeight: FontWeight.w500),
          prefixIcon: Icon(icon, color: AppTheme.primary, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          suffixIcon: isPass ? IconButton(
            onPressed: () => setState(() => _showPass = !_showPass),
            icon: Icon(_showPass ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: AppTheme.textMuted, size: 20),
          ) : null,
        ),
      ),
    );
  }

  Widget _blob(double size, Color color) =>
      Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
}