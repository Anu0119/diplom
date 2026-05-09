import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Өнгөний тогтмол тохиргоо
const kPrimaryColor = Color(0xFF3F37C9);
const kBgColor = Color(0xFFF8F9FD);
const kTextBlack = Color(0xFF1E1E26);
const kTextGrey = Color(0xFF91919F);
const kAccentColor = Color(0xFFF0EEFF);

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Клуб болон эвэнтүүдийг дуудах Future
  late Future<List<dynamic>> clubs;

  @override
  void initState() {
    super.initState();
    clubs = fetchClubs();
  }

  Future<List<dynamic>> fetchClubs() async {
    // Таны өмнөх API дуудах логик энд байна
    return []; 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Мэндчилгээ болон Мэдэгдэл
              _buildHeader(),

              // 2. Хайлтын хэсэг
              _buildSearchBar(),

              // 3. Сурталчилгааны баннер
              _buildPromoBanner(),

              // 4. Тун удахгүй болох эвэнтүүд
              _buildSectionTitle("Тун удахгүй болох эвэнтүүд"),
              _buildEventList(),

              // 5. Идэвхтэй клубүүд
              _buildSectionTitle("Идэвхтэй клубүүд"),
              _buildClubHorizontalList(),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.menu_rounded, color: kTextBlack),
              SizedBox(height: 15),
              Text(
                "Сайн байна уу,\nБат-Эрдэнэ! 👋",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kTextBlack, height: 1.2),
              ),
            ],
          ),
          _buildNotificationIcon(),
        ],
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: const Icon(Icons.notifications_none_rounded, color: kTextBlack),
        ),
        Positioned(
          right: 2, top: 2,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
            child: const Text("3", style: TextStyle(color: Colors.white, fontSize: 10)),
          ),
        )
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Эвэнт, клуб хайх...",
          prefixIcon: const Icon(Icons.search, color: kTextGrey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Клубүүддээ нэгдэж,\nсонирхолтой эвэнтүүдэд\nоролцоорой!",
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: kPrimaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Дэлгэрэнгүй"),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Text("Бүгдийг харах", style: TextStyle(color: kPrimaryColor, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildEventList() {
    return Column(
      children: List.generate(2, (index) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
        child: Row(
          children: [
            Container(width: 50, height: 50, decoration: BoxDecoration(color: kAccentColor, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.image, color: kPrimaryColor)),
            const SizedBox(width: 15),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Хакатон 2024", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("2024.05.25 • МУИС", style: TextStyle(color: kTextGrey, fontSize: 12)),
            ])),
            const Icon(Icons.bookmark_border, color: kTextGrey),
          ],
        ),
      )),
    );
  }

  Widget _buildClubHorizontalList() {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20),
        itemCount: 4,
        itemBuilder: (context, index) => Container(
          width: 120,
          margin: const EdgeInsets.only(right: 15),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(padding: const EdgeInsets.all(10), decoration: const BoxDecoration(color: kAccentColor, shape: BoxShape.circle), child: const Icon(Icons.groups, color: kPrimaryColor)),
              const SizedBox(height: 10),
              const Text("Кодчиллын клуб", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 1),
              const Text("123 гишүүн", style: TextStyle(fontSize: 10, color: kTextGrey)),
            ],
          ),
        ),
      ),
    );
  }
}