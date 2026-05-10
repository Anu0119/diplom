import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class SchoolAdminScreen extends StatefulWidget {
  const SchoolAdminScreen({super.key});

  @override
  State<SchoolAdminScreen> createState() => _SchoolAdminScreenState();
}

class _SchoolAdminScreenState extends State<SchoolAdminScreen> {
  final _storage = const FlutterSecureStorage();
  List _pendingClubs = [];
  bool _isLoading = true;

  final String apiBaseUrl = kIsWeb ? "http://127.0.0.1:8000/api" : "http://10.0.2.2:8000/api";

  @override
  void initState() {
    super.initState();
    _fetchPendingClubs();
  }

  // Зөвхөн баталгаажаагүй (is_active=False) клубуудыг татах
  // Тэмдэглэл: Үүний тулд Backend-д Filter нэмэх эсвэл тусдаа URL хэрэгтэй
  Future<void> _fetchPendingClubs() async {
    setState(() => _isLoading = true);
    try {
      String? token = await _storage.read(key: "access");
      final response = await http.get(
        Uri.parse('$apiBaseUrl/clubs/list/'), // Энд бүх клуб ирж байгаа бол filter хийнэ
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        List allClubs = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          // Зөвхөн идэвхгүй (батлуулах хүсэлтүүд) клубуудыг шүүх
          _pendingClubs = allClubs.where((club) => club['is_active'] == false).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // Клуб батлах эсвэл татгалзах функц
  Future<void> _handleApproval(int clubId, String action) async {
    try {
      String? token = await _storage.read(key: "access");
      final response = await http.post(
        Uri.parse('$apiBaseUrl/clubs/approve/$clubId/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'action': action}),
      );

      if (response.statusCode == 200) {
        _showSnackBar(action == 'approve' ? "Клуб батлагдлаа" : "Татгалзлаа");
        _fetchPendingClubs(); // Жагсаалтыг шинэчлэх
      }
    } catch (e) {
      _showSnackBar("Алдаа гарлаа");
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Сургуулийн Админ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(onPressed: _fetchPendingClubs, icon: const Icon(Icons.refresh, color: Colors.black))
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingClubs.isEmpty
              ? const Center(child: Text("Батлуулах хүсэлт байхгүй байна."))
              : ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: _pendingClubs.length,
                  itemBuilder: (context, index) {
                    final club = _pendingClubs[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundImage: NetworkImage(club['logo'] ?? 'https://via.placeholder.com/150'),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(club['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                      Text("Ахлагч: ${club['leader_name']}", style: const TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 30),
                            Text(club['description'] ?? "Тайтлбар байхгүй"),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                                    onPressed: () => _handleApproval(club['id'], 'reject'),
                                    child: const Text("Татгалзах"),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                    onPressed: () => _handleApproval(club['id'], 'approve'),
                                    child: const Text("Батлах", style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}