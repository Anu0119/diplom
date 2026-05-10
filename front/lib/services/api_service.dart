import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  final String baseUrl = kIsWeb ? "http://127.0.0.1:8000/api" : "http://10.0.2.2:8000/api";
  final storage = const FlutterSecureStorage();

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
        return true;
      }
    } catch (e) {
      debugPrint("Login error: $e");
    }
    return false;
  }

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

  // --- ADMIN ACTIONS (Энэ хэсгийг заавал нэмээрэй) ---

  // 1. Сургуулиудын хүсэлтийн жагсаалт авах
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

  // 2. Сургууль батлах эсвэл татгалзах
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

  // --- CLUBS & EVENTS ---

  Future<List<dynamic>> getClubs() async {
  try {
    final response = await http.get(Uri.parse("$baseUrl/clubs/list/"));
    if (response.statusCode == 200) {
      // Ирж буй өгөгдлийг шалгах: [{ "id": 1, "name": "Starship", "member_count": 10 ... }]
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
  } catch (e) {
    debugPrint("getClubs error: $e");
  }
  return [];
}
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

// Эвентэд бүртгүүлэх функц
Future<Map<String, dynamic>> joinEvent(int eventId) async {
  try {
    var headers = await _getHeaders();
    final response = await http.post(
      Uri.parse("$baseUrl/clubs/events/$eventId/join/"), // Таны backend-ийн URL-тай таарах ёстой
      headers: headers,
    );
    return jsonDecode(utf8.decode(response.bodyBytes));
  } catch (e) {
    return {"success": false, "message": "Алдаа гарлаа: $e"};
  }
}

  Future<List<dynamic>> getNotifications() async {
    try {
      String? token = await storage.read(key: "access");
      final response = await http.get(
        Uri.parse("$baseUrl/clubs/notifications/"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
    } catch (e) {
      debugPrint("getNotifications error: $e");
    }
    return [];
  }

  Future<void> logout() async {
    await storage.deleteAll();
  }
}