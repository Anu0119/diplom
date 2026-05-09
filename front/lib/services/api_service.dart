import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  // Эмуляторт 10.0.2.2, Вэб болон iOS-д 127.0.0.1
  final String baseUrl = kIsWeb ? "http://127.0.0.1:8000/api" : "http://10.0.2.2:8000/api";
  final storage = const FlutterSecureStorage();

  // Header бэлдэх туслах функц (Давтагдах кодыг багасгах)
  Future<Map<String, String>> _getHeaders({bool isJson = true}) async {
    String? token = await storage.read(key: "access");
    Map<String, String> headers = {
      "Authorization": "Bearer $token",
      "Accept": "application/json",
    };
    if (isJson) {
      headers["Content-Type"] = "application/json";
    }
    return headers;
  }

  // --- ACCOUNTS (Хэрэглэгч) ---

  // 1. Бүртгүүлэх
  Future<bool> signUp({
    required String username,
    required String email,
    required String password,
    required int schoolId,
    File? avatar,
  }) async {
    try {
      var request = http.MultipartRequest("POST", Uri.parse("$baseUrl/accounts/signup/"));
      request.fields.addAll({
        "username": username,
        "email": email,
        "password": password,
        "school": schoolId.toString(),
      });

      if (avatar != null) {
        request.files.add(await http.MultipartFile.fromPath('avatar', avatar.path));
      }

      var response = await request.send();
      return response.statusCode == 201;
    } catch (e) {
      debugPrint("SignUp error: $e");
      return false;
    }
  }

  // 2. Сургууль шинээр бүртгүүлэх хүсэлт илгээх
  Future<bool> registerSchool(String name, String email, String address) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/accounts/schools/register/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "admin_email": email,
          "address": address,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      debugPrint("RegisterSchool error: $e");
      return false;
    }
  }

  // 3. Нэвтрэх
  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/accounts/login/"),
        body: {"email": email, "password": password},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await storage.write(key: "access", value: data["access"]);
        await storage.write(key: "refresh", value: data["refresh"]);

        // Хэрэглэгчийн мэдээллийг татаж роль хадгалах
        final userData = await getMe();
        if (userData != null && userData['role'] != null) {
          await storage.write(key: "role", value: userData['role']);
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Login error: $e");
      return false;
    }
  }

  // 4. Өөрийн мэдээллийг авах
  Future<Map<String, dynamic>?> getMe() async {
    try {
      var headers = await _getHeaders();
      final response = await http.get(Uri.parse("$baseUrl/accounts/me/"), headers: headers);
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
    } catch (e) {
      debugPrint("getMe error: $e");
    }
    return null;
  }

  // 5. Системээс гарах
  Future<void> logout() async {
    await storage.delete(key: "access");
    await storage.delete(key: "refresh");
    await storage.delete(key: "role");
  }

  // --- ADMIN ACTIONS (Админ үйлдлүүд) ---

  // 6. Сургуулиудын жагсаалт (Админ хүсэлтүүд харна)
  Future<List<dynamic>> getSchools() async {
    try {
      var headers = await _getHeaders();
      final response = await http.get(Uri.parse("$baseUrl/accounts/schools/"), headers: headers);
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
    } catch (e) {
      debugPrint("getSchools error: $e");
    }
    return [];
  }

  // 7. Сургууль батлах/татгалзах
  Future<bool> approveSchool(int schoolId, String action) async {
    try {
      var headers = await _getHeaders();
      final response = await http.post(
        Uri.parse("$baseUrl/accounts/schools/approve/$schoolId/"),
        headers: headers,
        body: jsonEncode({"action": action}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("ApproveSchool error: $e");
      return false;
    }
  }

  // 8. Клуб батлах/татгалзах
  Future<bool> approveClub(int clubId, String action) async {
    try {
      var headers = await _getHeaders();
      final response = await http.post(
        Uri.parse("$baseUrl/clubs/approve/$clubId/"),
        headers: headers,
        body: jsonEncode({"action": action}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("ApproveClub error: $e");
      return false;
    }
  }

  // --- CLUBS & EVENTS (Клуб, Эвент) ---

  // 9. Клубуудын жагсаалт
  Future<List<dynamic>> getClubs() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/clubs/list/"));
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
    } catch (e) {
      debugPrint("getClubs error: $e");
    }
    return [];
  }

  // 10. Эвентүүдийн жагсаалт
  Future<List<dynamic>> getEvents() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/clubs/events/"));
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
    } catch (e) {
      debugPrint("getEvents error: $e");
    }
    return [];
  }

  // 11. Клуб үүсгэх (Multipart)
  Future<bool> createClub(String name, String desc, File? logo) async {
    try {
      var headers = await _getHeaders(isJson: false);
      var request = http.MultipartRequest("POST", Uri.parse("$baseUrl/clubs/create/"));
      request.headers.addAll(headers);
      request.fields['name'] = name;
      request.fields['description'] = desc;
      
      if (logo != null) {
        request.files.add(await http.MultipartFile.fromPath('logo', logo.path));
      }
      
      var response = await request.send();
      return response.statusCode == 201;
    } catch (e) {
      debugPrint("CreateClub error: $e");
      return false;
    }
  }
}