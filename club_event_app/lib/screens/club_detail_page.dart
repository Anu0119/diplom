import 'package:flutter/material.dart';

class ClubDetailPage extends StatelessWidget {
  final Map<String, dynamic> club; // dynamic болгож өөрчлөв

  const ClubDetailPage({super.key, required this.club});

  @override
  Widget build(BuildContext context) {
    // Үндсэн өнгөнүүд
    final Color themeColor = const Color(0xFF2D265B); // Гүн хөх
    final Color accentColor = const Color(0xFFFFB6B6); // Зөөлөн ягаан

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Клубын дэлгэрэнгүй",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Дээд хэсгийн Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 25),
              decoration: BoxDecoration(
                color: themeColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(60),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    club['name'] ?? "Нэргүй клуб",
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.star, color: accentColor, size: 20),
                      const SizedBox(width: 5),
                      const Text(
                        "Идэвхтэй клуб",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Тайлбар хэсэг
                  _buildSectionTitle("Клубын тухай", themeColor),
                  const SizedBox(height: 12),
                  Text(
                    club['description'] ?? "Тайлбар оруулаагүй байна.",
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.grey[700],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Үйлдлийн товчлуурууд
                  _buildActionButton(
                    text: "Эвент үүсгэх",
                    icon: Icons.add_circle_outline,
                    color: themeColor,
                    onPressed: () {},
                  ),
                  const SizedBox(height: 15),
                  _buildActionButton(
                    text: "Мэдээлэл засах",
                    icon: Icons.edit_outlined,
                    color: Colors.blueGrey,
                    onPressed: () {},
                  ),
                  const SizedBox(height: 15),
                  _buildActionButton(
                    text: "Клуб устгах",
                    icon: Icons.delete_outline,
                    color: Colors.redAccent,
                    onPressed: () {},
                    isOutlined: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Гарчиг үүсгэгч widget
  Widget _buildSectionTitle(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }

  // Товчлуур үүсгэгч widget
  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    bool isOutlined = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: isOutlined
          ? OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, color: color),
              label: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: color, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            )
          : ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, color: Colors.white),
              label: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 2,
              ),
            ),
    );
  }
}