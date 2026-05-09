import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Фонт илүү гоё болгохын тулд
import 'screens/login_page.dart';
import 'screens/home_page.dart';
import 'screens/profile_page.dart';
import 'screens/register_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Дизайн дээрх үндсэн нил ягаан/хөх өнгө: #3F37C9 эсвэл #2D265B
    const Color primaryBrandColor = Color(0xFF3F37C9);
    const Color scaffoldBgColor = Color(0xFFF8F9FD); // Цайвар саарал дэвсгэр

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UniConnect',
      
      // Апп-ын ерөнхий дизайн (Theme) тохиргоо
      // main.dart доторх Theme хэсгийг ингэж шинэчилж болно:

theme: ThemeData(
  useMaterial3: true,
  primaryColor: primaryBrandColor,
  
  // Фонт (Manrope бол маш цэвэрхэн фонт)
  textTheme: GoogleFonts.manropeTextTheme(Theme.of(context).textTheme),
  
  colorScheme: ColorScheme.fromSeed(
    seedColor: primaryBrandColor,
    primary: primaryBrandColor,
    surface: Colors.white, // Card болон Dialog-д зориулав
    background: scaffoldBgColor,
  ),
  
  scaffoldBackgroundColor: scaffoldBgColor,
  
  // AppBar дизайн
  appBarTheme: AppBarTheme(
    backgroundColor: scaffoldBgColor,
    elevation: 0,
    surfaceTintColor: Colors.transparent, // Гүйлгэхэд өнгө өөрчлөгдөхөөс сэргийлнэ
    titleTextStyle: GoogleFonts.manrope(
      color: Colors.black,
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
  ),

  // Input Field дизайн (Login/Register хуудсанд зориулж)
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  ),
),
      // Чиглүүлэлт (Routing)
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/register_page': (context) => const RegisterPage(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}