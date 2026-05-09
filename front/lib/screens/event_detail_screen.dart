import 'package:flutter/material.dart';

class EventDetailPage extends StatelessWidget {
  final Map<String, dynamic> eventData;

  const EventDetailPage({super.key, required this.eventData});

  @override
  Widget build(BuildContext context) {
    // 🛡️ Null алдаанаас сэргийлж утгуудыг шалгах
    final String title = eventData['title']?.toString() ?? "Нэргүй эвент";
    final String date = eventData['date']?.toString() ?? "Огноо тодорхойгүй";
    final String location = eventData['location']?.toString() ?? "Байршил тодорхойгүй";
    final String club = eventData['club']?.toString() ?? "Клуб тодорхойгүй";
    final String participants = eventData['stats']?.toString() ?? "0/0";
    final bool isRegistered = eventData['isRegistered'] ?? false;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Дээд талын зураг болон товчлуурууд
            Stack(
              children: [
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                    image: DecorationImage(
                      image: NetworkImage('https://via.placeholder.com/600x400'), // Энд eventData['image'] орно
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Буцах болон Share товч
                Positioned(
                  top: 50,
                  left: 20,
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.3),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  right: 20,
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.3),
                    child: const Icon(Icons.share, color: Colors.white),
                  ),
                ),
                // Bookmark icon
                Positioned(
                  bottom: 20,
                  right: 30,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                    ),
                    child: Icon(Icons.bookmark_border, color: Color(0xFF3F37D9)),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Гарчиг болон статус
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      _statusBadge(isRegistered),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 3. Мэдээллийн хэсэг (Иконтой)
                  _infoRow(Icons.calendar_today_outlined, date),
                  _infoRow(Icons.location_on_outlined, location),
                  _infoRow(Icons.person_outline, club),
                  _infoRow(Icons.groups_outlined, "$participants оролцогч"),

                  const Divider(height: 40),

                  // 4. Тухай хэсэг
                  const Text("Тухай", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text(
                    "Хакатон нь 24 цагийн турш үргэлжлэх ба оюутнууд багаар ажиллаж, шинэлэг шийдэл хөгжүүлнэ.",
                    style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 20),

                  // 5. Шаардлага хэсэг
                  const Text("Шаардлага", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _bulletPoint("2-5 гишүүнтэй баг"),
                  _bulletPoint("Өөрийн компьютер"),
                  _bulletPoint("Бүтээлч санаа!"),

                  const SizedBox(height: 40),

                  // 6. Доод талын товчлуурууд
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3F37D9),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text("Дэлгэрэнгүй мэдээлэл", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF3F37D9)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text("Бүртгэлээ цуцлах", style: TextStyle(color: Color(0xFF3F37D9), fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(text, style: TextStyle(color: Colors.grey[800], fontSize: 14)),
        ],
      ),
    );
  }

  Widget _bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const Text(" • ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(text, style: const TextStyle(fontSize: 14, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _statusBadge(bool isRegistered) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isRegistered ? const Color(0xFFEEF2FF) : const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isRegistered ? "Бүртгүүлсэн" : "Бүртгүүлэх",
        style: TextStyle(
          color: isRegistered ? const Color(0xFF3F37D9) : const Color(0xFF10B981),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}