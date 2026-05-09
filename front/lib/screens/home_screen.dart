import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  
  Map<String, dynamic>? _userData;
  List<dynamic> _events = [];
  List<dynamic> _clubs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Backend-ээс бүх датаг зэрэг татах
  Future<void> _loadData() async {
    try {
      // Хэрэглэгчийн мэдээлэл, эвент, клубүүдийг зэрэг татна
      final results = await Future.wait([
      _apiService.getMe(),      // getMe() гэж дуудна
      _apiService.getEvents(),  // getSchools-ийн оронд getEvents() ашиглах нь илүү тохиромжтой
    ]);

      setState(() {
        _userData = results[0] as Map<String, dynamic>?;
        _events = results[1] as List<dynamic>;
        // Клуб татах API байгаа бол энд нэмж болно
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Дата татахад алдаа гарлаа: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Хэрэв first_name байхгүй бол username-ийг нь харуулна
    String displayName = "Зочин";
    if (_userData != null) {
      displayName = (_userData!['first_name'] != null && _userData!['first_name'].toString().isNotEmpty)
          ? _userData!['first_name']
          : _userData!['username'] ?? "Хэрэглэгч";
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.menu, color: Colors.black),
        actions: [ _buildNotificationIcon(3) ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF3F37D9)))
        : RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Сайн байна уу,", style: TextStyle(fontSize: 16, color: Colors.grey)),
                  Text(
                    "$displayName! 👋", 
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 20),
                  
                  _buildSearchBar(),
                  const SizedBox(height: 20),
                  _buildBanner(),
                  
                  _buildSectionHeader("Тун удахгүй болох эвентүүд"),
                  _buildEventList(),

                  _buildSectionHeader("Идэвхтэй клубүүд"),
                  _buildClubList(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
    );
  }

  // --- UI Components ---

  Widget _buildNotificationIcon(int count) {
    return Padding(
      padding: const EdgeInsets.only(right: 15, top: 10),
      child: Stack(
        children: [
          const Icon(Icons.notifications_none, color: Colors.black, size: 28),
          Positioned(
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
              constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
              child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 8), textAlign: TextAlign.center),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: "Эвент, клуб хайх...",
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF3F37D9), Color(0xFF635AD9)]),
        borderRadius: BorderRadius.circular(20)
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Клубүүддээ нэгдэж, сонирхолтой эвентүүдэд оролцоорой!", 
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF3F37D9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Дэлгэрэнгүй"),
                )
              ],
            ),
          ),
          const Icon(Icons.groups_rounded, size: 70, color: Colors.white54),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          TextButton(
            onPressed: () {}, 
            child: const Text("Бүгдийг харах", style: TextStyle(color: Color(0xFF3F37D9)))
          ),
        ],
      ),
    );
  }

  Widget _buildEventList() {
    if (_events.isEmpty) {
      return const Text("Одоогоор эвент байхгүй байна.");
    }
    return Column(
      children: _events.take(3).map((event) => _buildEventCard(
        event['name'] ?? "Нэргүй эвент",
        event['date'] ?? "Хугацаа тодорхойгүй",
        event['location'] ?? "Байршил тодорхойгүй",
        event['image'] // Хэрэв зураг байгаа бол
      )).toList(),
    );
  }

  Widget _buildEventCard(String title, String time, String location, String? imageUrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 70, height: 70,
              color: Colors.indigo[50],
              child: imageUrl != null 
                ? Image.network(imageUrl, fit: BoxFit.cover)
                : const Icon(Icons.event, color: Color(0xFF3F37D9)),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(location, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.bookmark_border, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildClubList() {
    return SizedBox(
      height: 160,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildClubCard("Програмчлалын клуб", "123 гишүүн", Icons.code, Colors.indigo),
          _buildClubCard("Маркетингийн клуб", "98 гишүүн", Icons.campaign, Colors.pink),
          _buildClubCard("Байгаль орчны клуб", "76 гишүүн", Icons.eco, Colors.green),
        ],
      ),
    );
  }

  Widget _buildClubCard(String name, String members, IconData icon, Color color) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color),
          ),
          const Spacer(),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 2),
          const SizedBox(height: 5),
          Text(members, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }
}