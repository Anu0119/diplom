import 'package:flutter/material.dart';

class EventDetailPage extends StatelessWidget {
  final Map<String, dynamic> event; // dynamic болгож өөрчлөв (API-аас ирэх төрөлд нийцүүлж)

  const EventDetailPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final Color themeColor = const Color(0xFF2D265B); // Гүн хөх
    final Color accentColor = const Color(0xFFFFB6B6); // Зөөлөн ягаан

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Дэлгэрэнгүй",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Дээд хэсгийн чимэглэл болон Гарчиг
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: themeColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(60),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      event['club_name'] ?? event['club'] ?? "Клуб тодорхойгүй",
                      style: TextStyle(color: accentColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    event['name'] ?? "Гарчиггүй эвент",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Хугацаа болон Байршлын мэдээлэл
                  _buildInfoRow(Icons.calendar_month_rounded, "Хэзээ:", event['date'] ?? "Хугацаа тодорхойгүй", themeColor),
                  const SizedBox(height: 20),
                  _buildInfoRow(Icons.location_on_rounded, "Хаана:", event['location'] ?? "Сургуулийн зааланд", themeColor),
                  
                  const Divider(height: 40, thickness: 1, color: Color(0xFFEEEEEE)),

                  // Тайлбар хэсэг
                  Text(
                    "Эвентийн тухай",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: themeColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    event['description'] ?? "Энэхүү эвент нь оюутнуудын идэвх оролцоог нэмэгдүүлэх, хоорондоо танилцах боломжийг олгох зорилготой зохион байгуулагдаж байна.",
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Colors.grey[700],
                    ),
                  ),
                  
                  const SizedBox(height: 50),

                  // Бүртгүүлэх товч
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        // Бүртгүүлэх логик энд орно
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                        shadowColor: themeColor.withOpacity(0.4),
                      ),
                      child: const Text(
                        "БҮРТГҮҮЛЭХ",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.1,
                        ),
                      ),
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

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}