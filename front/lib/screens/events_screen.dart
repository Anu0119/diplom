import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart'; // ApiService-ээ заавал импортлоорой

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final ApiService _apiService = ApiService(); // Токен авах сервис
  final List<String> categories = ["Бүгд", "Ирэх", "Өнгөрсөн", "Орж буй"];
  int selectedCategoryIndex = 0;

  List<dynamic> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  // 🌐 API-аас өгөгдөл татах (Токентой)
  Future<void> _fetchEvents() async {
    setState(() => _isLoading = true);
    
    // 1. Хадгалсан токеноо унших
    String? token = await _apiService.storage.read(key: "access");
    const String apiUrl = "http://127.0.0.1:8000/clubs/api/events/list/";

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // JWT Токен нэмэв
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _events = jsonDecode(utf8.decode(response.bodyBytes));
          _isLoading = false;
        });
      } else if (response.statusCode == 401) {
        // Токен хүчингүй болсон бол нэвтрэх хэсэг рүү шилжүүлж болно
        debugPrint("Алдаа: Нэвтрэх эрхгүй байна (401)");
        setState(() => _isLoading = false);
      } else {
        throw Exception('Failed to load events: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Error fetching events: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text(
          "Эвентүүд",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.black), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          _buildCategoryList(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF3F37C9)))
                : RefreshIndicator(
                    onRefresh: _fetchEvents,
                    child: _events.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            itemCount: _events.length,
                            itemBuilder: (context, index) => _buildEventCard(_events[index]),
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  // --- UI Components ---

  Widget _buildCategoryList() {
    return Container(
      height: 60,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          bool isSelected = selectedCategoryIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(categories[index]),
              selected: isSelected,
              onSelected: (val) => setState(() => selectedCategoryIndex = index),
              selectedColor: const Color(0xFF3F37C9),
              backgroundColor: const Color(0xFFF1F3F9),
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.grey[600]),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        const Center(
          child: Column(
            children: [
              Icon(Icons.event_available_outlined, size: 70, color: Colors.grey),
              SizedBox(height: 10),
              Text("Одоогоор эвент байхгүй байна", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEventCard(Map<String, dynamic> data) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EventDetailScreen(event: data))),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Container(
                width: 100, height: 100,
                color: Colors.grey[100],
                child: data['image'] != null
                    ? Image.network(data['image'], fit: BoxFit.cover, 
                        errorBuilder: (c, e, s) => const Icon(Icons.broken_image))
                    : const Icon(Icons.image, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data['name'] ?? "Нэргүй", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  _iconInfo(Icons.calendar_month, data['date'] ?? "Тодорхойгүй"),
                  _iconInfo(Icons.location_on, data['location'] ?? "Байршилгүй"),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${data['current_participants'] ?? 0}/${data['max_participants'] ?? 0}", 
                        style: const TextStyle(color: Color(0xFF3F37C9), fontWeight: FontWeight.bold, fontSize: 12)),
                      const Text("Бүртгүүлэх", style: TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 5),
        Expanded(child: Text(text, style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}

// --- Detail Screen ---
class EventDetailScreen extends StatelessWidget {
  final Map<String, dynamic> event;
  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(event['name'] ?? "Дэлгэрэнгүй")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (event['image'] != null) Image.network(event['image'], width: double.infinity, height: 250, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event['name'] ?? "", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  Text("Байршил: ${event['location'] ?? 'Тодорхойгүй'}"),
                  const SizedBox(height: 10),
                  Text("Огноо: ${event['date'] ?? 'Тодорхойгүй'}"),
                  const Divider(height: 30),
                  const Text("Тайлбар", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(event['description'] ?? "Тайлбар байхгүй."),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}