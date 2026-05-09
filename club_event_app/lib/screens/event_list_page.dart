import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'event_detail_page.dart';
import 'event_create_page.dart';

// ==========================================
// 🎨 ТОГТМОЛ ӨНГӨНҮҮД (UniConnect Theme)
// ==========================================
const kPrimaryColor = Color(0xFF3F37C9);
const kBgColor = Color(0xFFF8F9FD);
const kTextBlack = Color(0xFF1E1E26);
const kTextGrey = Color(0xFF91919F);
const kAccentColor = Color(0xFFF0EEFF);
const kSuccessColor = Color(0xFF4CAF50);

class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  List<dynamic> events = [];
  bool isLoading = true;
  String? role;
  String selectedFilter = "Бүгд";

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => role = prefs.getString("role"));
    await _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("access_token");

      final response = await http.get(
        Uri.parse("http://127.0.0.1:8000/clubs/api/events/list/"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            events = jsonDecode(utf8.decode(response.bodyBytes));
            isLoading = false;
          });
        }
      } else {
        throw Exception("Алдаа гарлаа");
      }
    } catch (e) {
      debugPrint("API Error: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      body: Column(
        children: [
          _buildFilterBar(), // Шүүлтүүр (Бүгд, Ирэх...)
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
                : RefreshIndicator(
                    onRefresh: _loadEvents,
                    color: kPrimaryColor,
                    child: events.isEmpty ? _buildEmptyState() : _buildEventList(),
                  ),
          ),
        ],
      ),
      floatingActionButton: (role == "club_leader" || role == "school_admin")
          ? FloatingActionButton(
              backgroundColor: kPrimaryColor,
              onPressed: _navigateToCreate,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  // 1. Шүүлтүүрийн хэсэг
  Widget _buildFilterBar() {
    final filters = ["Бүгд", "Ирэх", "Өнгөрсөн", "Орж буй"];
    return Container(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final isSelected = selectedFilter == filters[index];
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(filters[index]),
              selected: isSelected,
              onSelected: (val) => setState(() => selectedFilter = filters[index]),
              selectedColor: kPrimaryColor,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : kTextGrey,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              side: BorderSide.none,
            ),
          );
        },
      ),
    );
  }

  // 2. Эвэнт жагсаалт
  Widget _buildEventList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      physics: const BouncingScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) => _buildEventCard(events[index]),
    );
  }

  // 3. Эвэнт Карт (image_857cf1.png загвараар)
  Widget _buildEventCard(dynamic event) {
    // Null safety check
    final String name = event["name"]?.toString() ?? "Нэргүй эвэнт";
    final String date = event["date"]?.toString() ?? "Тодорхойгүй";
    final String location = event["location"]?.toString() ?? "МУИС, Номын сан";
    final String club = (event["club_name"] ?? event["club"])?.toString() ?? "Клуб";
    final bool isRegistered = event["is_registered"] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EventDetailPage(event: event))),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Зүүн талын зураг
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: kAccentColor,
                  borderRadius: BorderRadius.circular(15),
                  image: event["image"] != null 
                    ? DecorationImage(image: NetworkImage(event["image"]), fit: BoxFit.cover)
                    : null,
                ),
                child: event["image"] == null ? const Icon(Icons.image, color: kPrimaryColor) : null,
              ),
              const SizedBox(width: 15),
              // Баруун талын мэдээлэл
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        // Бүртгүүлсэн статус
                        if (isRegistered)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: kSuccessColor.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
                            child: const Text("Бүртгүүлсэн", style: TextStyle(color: kSuccessColor, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _iconInfo(Icons.calendar_today_outlined, date),
                    const SizedBox(height: 4),
                    _iconInfo(Icons.location_on_outlined, location),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(club, style: const TextStyle(color: kPrimaryColor, fontSize: 11, fontWeight: FontWeight.bold)),
                        const Icon(Icons.bookmark_border, color: kTextGrey, size: 20),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: kTextGrey),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(color: kTextGrey, fontSize: 11)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note_outlined, size: 60, color: kTextGrey.withOpacity(0.5)),
          const SizedBox(height: 10),
          const Text("Одоогоор эвэнт байхгүй байна", style: TextStyle(color: kTextGrey)),
        ],
      ),
    );
  }

  void _navigateToCreate() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const EventCreatePage()));
    if (result != null) _loadEvents();
  }
}