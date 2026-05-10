import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart'; // kIsWeb-д хэрэгтэй
import 'package:http_parser/http_parser.dart'; // MediaType-д хэрэгтэй

class EditClubScreen extends StatefulWidget {
  final Map club;
  const EditClubScreen({super.key, required this.club});

  @override
  State<EditClubScreen> createState() => _EditClubScreenState();
}

class _EditClubScreenState extends State<EditClubScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storage = const FlutterSecureStorage();
  final ImagePicker _picker = ImagePicker();
  
  late TextEditingController _nameController;
  late TextEditingController _descController;
  
  XFile? _pickedFile; // Сонгосон файл (Web болон Mobile-д адилхан ажиллана)
  Uint8List? _webImagePreview; // Дэлгэцэнд харуулах байт
  bool _isUpdating = false;

  final String apiBaseUrl = kIsWeb ? "http://127.0.0.1:8000/api" : "http://10.0.2.2:8000/api";

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.club['name']);
    _descController = TextEditingController(text: widget.club['description']);
  }

  // ЗУРАГ СОНГОХ (WEB-Д ЗОРИУЛСАН)
  Future<void> _pickImage() async {
    final XFile? selected = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80, // Зургийн хэмжээг багасгах
    );
    
    if (selected != null) {
      final bytes = await selected.readAsBytes();
      setState(() {
        _pickedFile = selected;
        _webImagePreview = bytes;
      });
    }
  }

  // BACKEND РҮҮ ИЛГЭЭХ (DART:IO АШИГЛАХГҮЙ)
  Future<void> _updateClub() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUpdating = true);
    String? token = await _storage.read(key: "access");

    try {
      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse('$apiBaseUrl/clubs/${widget.club['id']}/'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['name'] = _nameController.text;
      request.fields['description'] = _descController.text;

      // ЗУРАГ ИЛГЭЭХ ХЭСЭГ (Web-д MultipartFile.fromPath ажилладаггүй тул fromBytes ашиглав)
      if (_pickedFile != null) {
        final bytes = await _pickedFile!.readAsBytes();
        final multipartFile = http.MultipartFile.fromBytes(
          'logo',
          bytes,
          filename: _pickedFile!.name,
          contentType: MediaType('image', 'jpeg'), // Эсвэл png
        );
        request.files.add(multipartFile);
      }

      var response = await request.send();
      var responseBody = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Клубын мэдээлэл амжилттай засагдлаа!"), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true); // true утгатай буцаж датаг refresh хийнэ
        }
      } else {
        throw Exception("Засахад алдаа гарлаа: ${responseBody.body}");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Алдаа: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Клуб засах", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3F37C9),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- ЗУРАГ СОНГОХ ПРЕВЬЮ ХЭСЭГ ---
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey[300]!, width: 2),
                          image: _webImagePreview != null
                              ? DecorationImage(image: MemoryImage(_webImagePreview!), fit: BoxFit.cover)
                              : (widget.club['logo'] != null
                                  ? DecorationImage(image: NetworkImage(widget.club['logo']), fit: BoxFit.cover)
                                  : null),
                        ),
                        child: _webImagePreview == null && widget.club['logo'] == null
                            ? const Icon(Icons.camera_enhance, size: 40, color: Colors.grey)
                            : null,
                      ),
                      const Positioned(
                        bottom: 5,
                        right: 5,
                        child: CircleAvatar(
                          backgroundColor: Color(0xFF3F37C9),
                          radius: 18,
                          child: Icon(Icons.edit, size: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              // Нэр засах
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Клубын нэр",
                  prefixIcon: const Icon(Icons.edit_note),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) => value!.isEmpty ? "Нэр оруулна уу" : null,
              ),
              const SizedBox(height: 20),

              // Тайлбар засах
              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: "Клубын тайлбар",
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) => value!.isEmpty ? "Тайлбар оруулна уу" : null,
              ),
              const SizedBox(height: 40),

              // ХАДГАЛАХ ТОВЧ
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4361EE),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  onPressed: _isUpdating ? null : _updateClub,
                  child: _isUpdating
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("ӨӨРЧЛӨЛТИЙГ ХАДГАЛАХ", 
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}