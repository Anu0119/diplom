import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../theme/app_theme.dart'; // AppTheme импортлох

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const EditProfileScreen({super.key, required this.userData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Контроллерууд нэмэх
  late TextEditingController _phoneController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  
  final storage = const FlutterSecureStorage();
  Uint8List? _webImage;
  bool _isSaving = false;

  final String apiBaseUrl = kIsWeb ? "http://127.0.0.1:8000/api" : "http://10.0.2.2:8000/api";
  final String mediaBaseUrl = "http://127.0.0.1:8000";

  @override
  void initState() {
    super.initState();
    // Хуучин датаг оноох
    _phoneController = TextEditingController(text: widget.userData['phone'] ?? "");
    _firstNameController = TextEditingController(text: widget.userData['first_name'] ?? "");
    _lastNameController = TextEditingController(text: widget.userData['last_name'] ?? "");
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() => _webImage = bytes);
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _isSaving = true);
    try {
      String? token = await storage.read(key: "access");
      var request = http.MultipartRequest('PATCH', Uri.parse('$apiBaseUrl/accounts/me/'));
      request.headers.addAll({'Authorization': 'Bearer $token', 'Accept': 'application/json'});

      // Бүх талбаруудыг илгээх
      request.fields['phone'] = _phoneController.text;
      request.fields['first_name'] = _firstNameController.text;
      request.fields['last_name'] = _lastNameController.text;

      if (_webImage != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'avatar', _webImage!,
          filename: 'profile.jpg',
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      var response = await http.Response.fromStream(await request.send());

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Амжилттай хадгалагдлаа")));
          Navigator.pop(context, true);
        }
      } else {
        throw Exception("Хадгалахад алдаа гарлаа");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Алдаа: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String currentAvatar = widget.userData['avatar'] ?? "";
    ImageProvider profileImage;
    if (_webImage != null) {
      profileImage = MemoryImage(_webImage!);
    } else if (currentAvatar.isNotEmpty) {
      profileImage = NetworkImage(currentAvatar.startsWith('http') ? currentAvatar : "$mediaBaseUrl$currentAvatar");
    } else {
      profileImage = const NetworkImage("https://via.placeholder.com/150");
    }

    return Scaffold(
      backgroundColor: AppTheme.bgDark, // Хар 배경
      appBar: AppBar(
        title: const Text("Профайл засах", style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar Section
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppTheme.primary, width: 2)),
                      child: CircleAvatar(radius: 60, backgroundColor: AppTheme.surfaceLight, backgroundImage: profileImage),
                    ),
                    Positioned(
                      bottom: 0, right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Input Fields
            _buildTextField("Овог", _lastNameController, Icons.person_outline),
            const SizedBox(height: 16),
            _buildTextField("Нэр", _firstNameController, Icons.person),
            const SizedBox(height: 16),
            _buildTextField("Утасны дугаар", _phoneController, Icons.phone_android, isPhone: true),
            
            const SizedBox(height: 40),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isSaving 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Хадгалах", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool isPhone = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppTheme.primary, size: 20),
            filled: true,
            fillColor: AppTheme.surfaceLight,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.primary),
            ),
          ),
        ),
      ],
    );
  }
}