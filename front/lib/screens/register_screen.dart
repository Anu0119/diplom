import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final ApiService _apiService = ApiService();
  
  final _uNameController = TextEditingController();
  final _uEmailController = TextEditingController();
  final _uPassController = TextEditingController();
  int? _selectedSchoolId; 
  File? _avatarFile;

  final _sNameController = TextEditingController();
  final _sEmailController = TextEditingController();
  final _sAddressController = TextEditingController();

  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _avatarFile = File(pickedFile.path));
    }
  }

  void _handleStudentRegister() async {
    setState(() => _isLoading = true);
    bool success = await _apiService.signUp(
      username: _uNameController.text,
      email: _uEmailController.text,
      password: _uPassController.text,
      schoolId: _selectedSchoolId ?? 1, 
      avatar: _avatarFile,
    );
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Амжилттай бүртгүүллээ!")));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Бүртгэл амжилтгүй. И-мэйл хаягаа шалгана уу.")));
    }
  }

  void _handleSchoolRegister() async {
    setState(() => _isLoading = true);
    bool success = await _apiService.registerSchool(
      _sNameController.text,
      _sEmailController.text,
      _sAddressController.text,
    );
    setState(() => _isLoading = false);

    if (success) {
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Хүсэлт илгээгдлээ"),
        content: const Text("Сургуулийн бүртгэл хүлээгдэж байна. Админ баталгаажуулсны дараа и-мэйл очих болно."),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Ойлголоо"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Бүртгүүлэх"),
          bottom: const TabBar(
            indicatorColor: Color(0xFF3F37D9),
            labelColor: Color(0xFF3F37D9),
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: "Оюутан"),
              Tab(text: "Сургууль"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildStudentForm(),
            _buildSchoolForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[200],
              backgroundImage: _avatarFile != null ? FileImage(_avatarFile!) : null,
              child: _avatarFile == null ? const Icon(Icons.add_a_photo, size: 30) : null,
            ),
          ),
          const SizedBox(height: 20),
          _buildField("Хэрэглэгчийн нэр", Icons.person_outlined, _uNameController),
          const SizedBox(height: 15),
          _buildField("Сургуулийн и-мэйл", Icons.email_outlined, _uEmailController),
          const SizedBox(height: 15),
          _buildField("Нууц үг", Icons.lock_outlined, _uPassController, isPass: true),
          const SizedBox(height: 30),
          _buildButton("Оюутан болж бүртгүүлэх", _handleStudentRegister),
        ],
      ),
    );
  }

  Widget _buildSchoolForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          const Text("Сургуулийн захиргаа бүртгүүлэх хэсэг", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          _buildField("Сургуулийн нэр", Icons.school_outlined, _sNameController),
          const SizedBox(height: 15),
          _buildField("Админ и-мэйл", Icons.admin_panel_settings_outlined, _sEmailController),
          const SizedBox(height: 15),
          // ЗАСВАР: Энд 'location_on_outlined' болгож засав
          _buildField("Хаяг, байршил", Icons.location_on_outlined, _sAddressController),
          const SizedBox(height: 30),
          _buildButton("Бүртгүүлэх хүсэлт илгээх", _handleSchoolRegister),
        ],
      ),
    );
  }

  Widget _buildField(String hint, IconData icon, TextEditingController controller, {bool isPass = false}) {
    return TextField(
      controller: controller,
      obscureText: isPass,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF1F3F9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return _isLoading 
      ? const Center(child: CircularProgressIndicator())
      : ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3F37D9),
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
        );
  }
}