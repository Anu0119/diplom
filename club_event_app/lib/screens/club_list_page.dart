import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/club_card.dart';
import 'club_detail_page.dart';
import 'club_create_page.dart';

// =======================
// 📡 SERVICE
// =======================
class ClubService {
  static const String baseUrl = "http://127.0.0.1:8000";

  static Future<List<dynamic>> getClubs() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");

    final response = await http.get(
      Uri.parse("$baseUrl/clubs/api/list/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes)); // utf8 decode нэмэв
    } else {
      throw Exception("Server error: ${response.statusCode}");
    }
  }
}

// =======================
// 📱 PAGE
// =======================
class ClubListPage extends StatefulWidget {
  const ClubListPage({super.key});

  @override
  State<ClubListPage> createState() => _ClubListPageState();
}

class _ClubListPageState extends State<ClubListPage> {
  late Future<List<dynamic>> clubs;
  String? role;

  // Өнгөний тогтмол утгууд
  final Color themeColor = const Color(0xFF2D265B); // Гүн хөх
  final Color accentColor = const Color(0xFFFFB6B6); // Зөөлөн ягаан

  @override
  void initState() {
    super.initState();
    loadRole();
    clubs = ClubService.getClubs();
  }

  Future<void> loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString("role");
    });
  }

  Future<void> _refresh() async {
    setState(() {
      clubs = ClubService.getClubs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD), // Цайвар саарал дэвсгэр
      appBar: AppBar(
        title: const Text(
          "Клубүүд",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.white,
        foregroundColor: themeColor,
        elevation: 0,
        centerTitle: false,
      ),
      body: RefreshIndicator(
        color: themeColor,
        onRefresh: _refresh,
        child: FutureBuilder<List<dynamic>>(
          future: clubs,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: themeColor));
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 50),
                    const SizedBox(height: 10),
                    Text("Алдаа гарлаа: ${snapshot.error}"),
                  ],
                ),
              );
            }

            final data = snapshot.data ?? [];

            if (data.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.group_off_rounded, size: 80, color: accentColor),
                    const SizedBox(height: 16),
                    Text(
                      "Одоогоор клуб байхгүй байна",
                      style: TextStyle(color: themeColor.withOpacity(0.5), fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final club = data[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: themeColor.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ClubDetailPage(club: club),
                        ),
                      );
                    },
                    child: ClubCard(
                      name: club["name"] ?? "",
                      description: club["description"] ?? "",
                      // Картны шинэчлэгдсэн өнгөнүүд
                      cardColor: Colors.white,
                      titleColor: themeColor,
                      subtitleColor: themeColor.withOpacity(0.6),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),

      // =======================
      // ⭐ ROLE BASED BUTTON
      // =======================
      floatingActionButton: (role == "club_leader" || role == "school_admin")
          ? FloatingActionButton.extended(
              backgroundColor: themeColor,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "Клуб нэмэх",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ClubCreatePage(),
                  ),
                );

                if (result != null) {
                  _refresh();
                }
              },
            )
          : null,
    );
  }
}