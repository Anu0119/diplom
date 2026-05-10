import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart'; // kIsWeb шалгахад хэрэгтэй

class EditSchoolScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const EditSchoolScreen({super.key, required this.userData});

  @override
  State<EditSchoolScreen> createState() => _EditSchoolScreenState();
}

class _EditSchoolScreenState extends State<EditSchoolScreen> {
  final _storage = const FlutterSecureStorage();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isSaving = false;

  // Төхөөрөмжөөс хамаарч URL-ыг тохируулах
  final String apiBaseUrl = kIsWeb 
      ? "http://127.0.0.1:8000/api" 
      : "http://10.0.2.2:8000/api";

  @override
  void initState() {
    super.initState();
    // Одоо байгаа мэдээллийг талбарт оноох
    _nameController.text = widget.userData['school_name'] ?? "";
    // Хэрэв address ирэхгүй байгаа бол API-аас нэмж татах эсвэл хоосон үлдээнэ
    _addressController.text = ""; 
  }

  Future<void> _updateSchool() async {
    if (_nameController.text.isEmpty) {
      _showSnackBar("Нэр заавал бөглөх шаардлагатай", Colors.orange);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final String? token = await _storage.read(key: "access");
      // Django-ийн UserMeSerializer-ээс ирж буй 'school' (ID)
      final schoolId = widget.userData['school']; 

      if (schoolId == null) throw Exception("Сургуулийн ID олдсонгүй");

      final response = await http.patch(
        Uri.parse('$apiBaseUrl/accounts/my-school/update/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': _nameController.text,
          'address': _addressController.text,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        _showSnackBar("Сургуулийн мэдээлэл шинэчлэгдлээ", Colors.green);
        Navigator.pop(context, true); // Амжилттай болсон тул буцах
      } else {
        throw Exception("Хадгалахад алдаа гарлаа: ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) _showSnackBar("Алдаа: $e", Colors.red);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Сургууль засах", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.edit_calendar_outlined, size: 80, color: Color(0xFF3F37C9)),
            const SizedBox(height: 30),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Сургуулийн нэр",
                prefixIcon: const Icon(Icons.business),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _addressController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Хаяг / Байршил",
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _updateSchool,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F37C9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSaving 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Хадгалах", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}