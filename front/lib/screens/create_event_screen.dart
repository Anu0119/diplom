import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart'; // Зураг сонгоход хэрэгтэй
import 'dart:io'; // File классад хэрэгтэй

class CreateEventScreen extends StatefulWidget {
  final int clubId;
  const CreateEventScreen({super.key, required this.clubId});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storage = const FlutterSecureStorage();
  
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _locController = TextEditingController();
  final _limitController = TextEditingController(); // Хүүхдийн тоо
  
  DateTime? _selectedDate;
  XFile? _pickedImage; // Сонгосон зураг
  bool _isSubmitting = false;

  final String apiBaseUrl = kIsWeb ? "http://127.0.0.1:8000/api" : "http://10.0.2.2:8000/api";

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _pickedImage = image);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Мэдээллээ бүрэн бөглөнө үү")));
      return;
    }

    setState(() => _isSubmitting = true);
    String? token = await _storage.read(key: "access");

    try {
      // Зураг илгээх тул MultipartRequest ашиглана
      var request = http.MultipartRequest('POST', Uri.parse('$apiBaseUrl/clubs/events/create/'));
      
      // Headers
      request.headers['Authorization'] = 'Bearer $token';

      // Fields (Текстэн өгөгдлүүд)
      request.fields['club'] = widget.clubId.toString();
      request.fields['name'] = _nameController.text;
      request.fields['description'] = _descController.text;
      request.fields['location'] = _locController.text;
      request.fields['max_participants'] = _limitController.text.isEmpty ? "0" : _limitController.text;
      request.fields['date'] = _selectedDate!.toIso8601String();

      // Image (Зураг байгаа бол хавсаргах)
      if (_pickedImage != null) {
        if (kIsWeb) {
          // Вэб дээр ажиллаж байгаа бол bytes-ээр илгээнэ
          var bytes = await _pickedImage!.readAsBytes();
          request.files.add(http.MultipartFile.fromBytes(
            'image', bytes, filename: _pickedImage!.name));
        } else {
          // Мобайл дээр ажиллаж байгаа бол замаар нь илгээнэ
          request.files.add(await http.MultipartFile.fromPath('image', _pickedImage!.path));
        }
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        Navigator.pop(context, true);
      } else {
        print("Error Body: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Алдаа гарлаа")));
      }
    } catch (e) {
      print("Submit Error: $e");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Шинэ эвент үүсгэх"), backgroundColor: const Color(0xFF3F37C9)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- Зураг сонгох хэсэг ---
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: _pickedImage == null 
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Icon(Icons.camera_alt, size: 40, color: Colors.grey), Text("Эвентийн зураг нэмэх")],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: kIsWeb 
                          ? Image.network(_pickedImage!.path, fit: BoxFit.cover)
                          : Image.file(File(_pickedImage!.path), fit: BoxFit.cover),
                      ),
                ),
              ),
              const SizedBox(height: 20),
              
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Эвент нэр", border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? "Нэр оруулна уу" : null,
              ),
              const SizedBox(height: 15),
              
              // Хүүхдийн тоог авах талбар
              TextFormField(
                controller: _limitController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Оролцох хүүхдийн хязгаар (0 бол хязгааргүй)", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: "Тайлбар", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              
              TextFormField(
                controller: _locController,
                decoration: const InputDecoration(labelText: "Байршил", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              
              ListTile(
                title: Text(_selectedDate == null ? "Огноо сонгох" : "Огноо: ${_selectedDate.toString().split(' ')[0]}"),
                trailing: const Icon(Icons.calendar_today),
                shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(5)),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2027),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
              ),
              const SizedBox(height: 30),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3F37C9)),
                  child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text("Үүсгэх", style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}