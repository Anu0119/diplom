import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../theme/app_theme.dart'; // Өнгөний тохиргоо
// Дэлгэцүүд
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/events_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/club_list.dart';
import 'screens/SchoolAdminScreen.dart';
import 'screens/notification_screen.dart';
// Сервис
import 'services/api_service.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: AppTheme.primary,
        scaffoldBackgroundColor: AppTheme.bgDark,
        fontFamily: 'Nunito',
        useMaterial3: true, // Material 3 ашиглах нь орчин үеийн харагдуулна
      ),
      home: const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/main': (context) => const MainNavigation(),
      },
    ));

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;
  String _userRole = 'student';
  Map<String, dynamic>? _userData;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initUser();
  }

  void _initUser() async {
    const storage = FlutterSecureStorage();
    try {
      String? storedRole = await storage.read(key: "role");
      if (storedRole != null) {
        if (mounted) setState(() => _userRole = storedRole);
      }

      final data = await ApiService().getMe();
      if (mounted) {
        setState(() {
          _userData = data;
          _userRole = data?['role'] ?? 'student';
          _isInitializing = false;
        });
      }
    } catch (e) {
      debugPrint("Init Error: $e");
      if (mounted) setState(() => _isInitializing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(
        backgroundColor: AppTheme.bgDark,
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    // 1. Үндсэн дэлгэцүүд
    List<Widget> screens = [
      const HomeScreen(),
      const EventsScreen(),
      const ClubScreen(),
      const NotificationScreen(),
    ];

    List<BottomNavigationBarItem> navItems = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined), 
        activeIcon: Icon(Icons.home_rounded), 
        label: "Нүүр"
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.calendar_month_outlined), 
        activeIcon: Icon(Icons.calendar_month_rounded), 
        label: "Эвент"
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.groups_outlined), 
        activeIcon: Icon(Icons.groups_rounded), 
        label: "Клуб"
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.notifications_outlined), 
        activeIcon: Icon(Icons.notifications_rounded), 
        label: "Мэдэгдэл"
      ),
    ];

    // 2. Систем Админ
    bool isAdmin = _userRole == 'admin' || (_userData != null && _userData!['is_superuser'] == true);
    if (isAdmin) {
      screens.add(const AdminDashboardScreen());
      navItems.add(const BottomNavigationBarItem(
        icon: Icon(Icons.admin_panel_settings_outlined), 
        activeIcon: Icon(Icons.admin_panel_settings_rounded), 
        label: "Админ"
      ));
    }

    // 3. Сургуулийн Админ
    bool isSchoolAdmin = _userRole == 'school_admin';
    if (isSchoolAdmin && !isAdmin) {
      screens.add(const SchoolAdminScreen());
      navItems.add(const BottomNavigationBarItem(
        icon: Icon(Icons.dashboard_customize_outlined), 
        activeIcon: Icon(Icons.dashboard_customize_rounded), 
        label: "Сургууль"
      ));
    }

    // 4. Профайл
    screens.add(const ProfileScreen());
    navItems.add(const BottomNavigationBarItem(
      icon: Icon(Icons.person_outline_rounded), 
      activeIcon: Icon(Icons.person_rounded), 
      label: "Би"
    ));

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      // IndexedStack нь дэлгэц хооронд шилжихэд State-ийг хадгална
      body: IndexedStack(
        index: _index < screens.length ? _index : 0,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _index < navItems.length ? _index : 0,
          onTap: (i) => setState(() => _index = i),
          
          // Style тохиргоо
          backgroundColor: AppTheme.bgDark,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.textMuted,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          
          selectedLabelStyle: const TextStyle(
            fontFamily: 'Nunito', 
            fontWeight: FontWeight.w800, 
            fontSize: 11
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Nunito', 
            fontWeight: FontWeight.w600, 
            fontSize: 11
          ),
          
          items: navItems,
        ),
      ),
    );
  }
}