import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EventCreatePage extends StatefulWidget {
  const EventCreatePage({super.key});

  @override
  State<EventCreatePage> createState() => _EventCreatePageState();
}

class _EventCreatePageState extends State<EventCreatePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  // Өнгөний тогтмол утгууд
  final Color themeColor = const Color(0xFF2D265B); // Гүн хөх
  final Color accentColor = const Color(0xFFFFB6B6); // Зөөлөн ягаан
  final Color inputFillColor = const Color(0xFFF3F3F9);

  DateTime? selectedDate;

  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // Өнгөрсөн цагт эвент үүсгэхгүй
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: themeColor, // Сонгогдсон өдөр
              onPrimary: Colors.white,
              onSurface: themeColor, // Текст
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<bool> createEventAPI() async {
    final url = Uri.parse("http://127.0.0.1:8000/clubs/api/events/"); 
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("access_token");
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "name": nameController.text,
          "description": descriptionController.text,
          "location": locationController.text,
          "date": dateController.text,
          "club": 2, // Жишээ ID
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("ERROR: $e");
      return false;
    }
  }

  void saveEvent() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final newEntry = {
        "name": nameController.text,
        "description": descriptionController.text,
        "location": locationController.text,
        "date": dateController.text, 
        "club_name": "Миний клуб", // Жагсаалтад харагдах түр нэр
      };

      bool success = await createEventAPI();

      setState(() => _isLoading = false);

      if (success) {
        if (mounted) {
          Navigator.pop(context, newEntry); 
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Амжилттай үүсгэлээ"), backgroundColor: Colors.green),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Алдаа гарлаа"), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Шинэ эвент", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: BoxDecoration(
                color: themeColor,
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(60)),
              ),
              child: const Text(
                "Үйл ажиллагааны\nмэдээллийг бөглөнө үү",
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(25),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildInputLabel("Эвентийн нэр"),
                    _buildTextField(
                      controller: nameController,
                      hint: "Жишээ: Хакатон 2026",
                      icon: Icons.title_rounded,
                      validator: (v) => v!.isEmpty ? "Нэр оруулна уу" : null,
                    ),
                    const SizedBox(height: 20),

                    _buildInputLabel("Хаана болох"),
                    _buildTextField(
                      controller: locationController,
                      hint: "Байршил, заалны дугаар",
                      icon: Icons.location_on_rounded,
                      validator: (v) => v!.isEmpty ? "Байршил оруулна уу" : null,
                    ),
                    const SizedBox(height: 20),

                    _buildInputLabel("Хэзээ болох"),
                    _buildTextField(
                      controller: dateController,
                      hint: "Огноо сонгох",
                      icon: Icons.calendar_month_rounded,
                      readOnly: true,
                      onTap: pickDate,
                      validator: (v) => v!.isEmpty ? "Огноо сонгоно уу" : null,
                    ),
                    const SizedBox(height: 20),

                    _buildInputLabel("Дэлгэрэнгүй тайлбар"),
                    _buildTextField(
                      controller: descriptionController,
                      hint: "Эвентийн тухай мэдээлэл...",
                      icon: Icons.description_rounded,
                      maxLines: 4,
                    ),
                    
                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : saveEvent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 5,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                "ЭВЕНТ ҮҮСГЭХ",
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
    bool readOnly = false,
    void Function()? onTap,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        prefixIcon: Icon(icon, color: themeColor, size: 22),
        filled: true,
        fillColor: inputFillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: accentColor, width: 1.5),
        ),
      ),
    );
  }
}