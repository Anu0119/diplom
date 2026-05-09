import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/events_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'services/api_service.dart';

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: ThemeData(primarySwatch: Colors.indigo),
  home: LoginScreen(), 
  routes: {
    '/login': (context) => LoginScreen(),
    '/main': (context) => const MainNavigation(),
  },
));

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;
  String _userRole = 'student';
  Map<String, dynamic>? _userData; // Мэдээллийг хадгалах хувьсагч нэмэв
  bool _isInitializing = true; 

  @override
  void initState() {
    super.initState();
    _initUser();
  }

  void _initUser() async {
    const storage = FlutterSecureStorage();
    
    // 1. Хадгалаастай байгаа роль-ийг унших
    String? storedRole = await storage.read(key: "role");
    if (storedRole != null) {
      if (mounted) setState(() => _userRole = storedRole);
    }

    // 2. Сүлжээнээс хамгийн сүүлийн мэдээллийг баталгаажуулж авах
    final data = await ApiService().getMe();
    
    if (mounted) {
      setState(() {
        _userData = data; // Бүх өгөгдлийг хадгалж авна
        _userRole = data?['role'] ?? 'student';
        _isInitializing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Дэлгэцүүдийг динамикаар угсрах
    List<Widget> screens = [
      const HomeScreen(),
      const EventsScreen(),
    ];
    
    List<BottomNavigationBarItem> navItems = [
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: "Нүүр"),
      const BottomNavigationBarItem(icon: Icon(Icons.event), label: "Эвент"),
    ];

    // Роль нь 'school_admin' ЭСВЭЛ 'is_superuser' нь true үед Админ цэс харагдана
    bool isAdmin = _userRole == 'student' || (_userData != null && _userData!['is_superuser'] == true);

    if (isAdmin) {
      screens.add(const AdminDashboardScreen());
      navItems.add(const BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Админ"));
    }
    
    screens.add(const ProfileScreen());
    navItems.add(const BottomNavigationBarItem(icon: Icon(Icons.person), label: "Профайл"));

    return Scaffold(
      body: IndexedStack(
        index: _index < screens.length ? _index : 0, 
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index < navItems.length ? _index : 0,
        onTap: (i) => setState(() => _index = i),
        selectedItemColor: const Color(0xFF3F37D9),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: navItems,
      ),
    );
  }
}