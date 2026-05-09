import 'package:flutter/material.dart';

class AdminPanelPage extends StatelessWidget {
  const AdminPanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Үндсэн өнгөнүүд
    final Color themeColor = const Color(0xFF2D265B); // Гүн хөх
    final Color accentColor = const Color(0xFFFFB6B6); // Зөөлөн ягаан

    final List<Map<String, dynamic>> adminOptions = [
      {
        "title": "Хэрэглэгчид",
        "subtitle": "Бүртгэл удирдах",
        "icon": Icons.people_alt_rounded,
        "onTap": () {}
      },
      {
        "title": "Клубууд",
        "subtitle": "Зөвшөөрөл олгох",
        "icon": Icons.fort_rounded,
        "onTap": () {}
      },
      {
        "title": "Эвентүүд",
        "subtitle": "Хяналт тавих",
        "icon": Icons.campaign_rounded,
        "onTap": () {}
      },
      {
        "title": "Тайлан",
        "subtitle": "Статистик харах",
        "icon": Icons.analytics_rounded,
        "onTap": () {}
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, left: 30, right: 30, bottom: 40),
            decoration: BoxDecoration(
              color: themeColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(50),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white24,
                  radius: 25,
                  child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 30),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Админ Панель",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Системийн тохиргоо болон удирдлага",
                  style: TextStyle(
                    fontSize: 14,
                    color: accentColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),

          // Grid Section
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(25),
              itemCount: adminOptions.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 0.85, // Картыг бага зэрэг урт болгоно
              ),
              itemBuilder: (context, index) {
                final option = adminOptions[index];
                return GestureDetector(
                  onTap: option["onTap"],
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: themeColor.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: themeColor.withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            option["icon"],
                            size: 35,
                            color: themeColor,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          option["title"],
                          style: TextStyle(
                            color: themeColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          option["subtitle"],
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}