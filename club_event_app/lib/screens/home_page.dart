import 'package:flutter/material.dart';
import 'dashboard_page.dart'; // Шинээр үүсгэсэн Нүүр хуудсыг импортлох
import 'club_list_page.dart'; 
import 'event_list_page.dart';
import 'profile_page.dart';
import 'admin_panel_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; 
  final Color themeColor = const Color(0xFF3F37C9);

  // Хуудаснуудын жагсаалтыг цэсний тоотой (5) ижил болгож засав
  final List<Widget> _pages = [
    const DashboardPage(),  // 0: Нүүр (Banner, Search-тэй хэсэг)
    const EventListPage(),  // 1: Эвэнт
    const ClubListPage(),   // 2: Клуб
    const ProfilePage(),    // 3: Профайл
    const AdminPanelPage(), // 4: Админ
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: themeColor,
          unselectedItemColor: Colors.grey[400],
          showUnselectedLabels: true,
          // items-ийн тоо _pages-ийн тоотой яг ижил (5) байх ёстой
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: "Нүүр",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_month),
              label: "Эвэнт",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.groups_outlined),
              activeIcon: Icon(Icons.groups),
              label: "Клуб",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: "Профайл",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings_outlined),
              activeIcon: Icon(Icons.admin_panel_settings),
              label: "Админ",
            ),
          ],
        ),
      ),
    );
  }
}