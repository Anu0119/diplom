import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _pendingSchools = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Вэб дээр хуудас бүрэн зурагдаж дууссаны дараа датаг дуудах нь аюулгүй байдаг
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchSchoolRequests();
    });
  }

  // 1. Сургуулийн хүсэлтүүдийг татах
  Future<void> _fetchSchoolRequests() async {
    // Хэрэв виджет устсан бол ажиллуулахгүй
    if (!mounted) return;
    
    setState(() => _isLoading = true);

    try {
      final schools = await _apiService.getSchools();
      
      // Асинхрон үйлдлийн дараа заавал mounted эсэхийг дахин шалгана
      if (!mounted) return;

      setState(() {
        _pendingSchools = schools
            .where((s) => s['status'].toString().toLowerCase() == 'pending')
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Сургууль татахад алдаа гарлаа: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar("Мэдээлэл татахад алдаа гарлаа.");
      }
    }
  }

  // 2. Сургууль батлах/татгалзах үйлдэл
  Future<void> _handleAction(int id, String action) async {
    // Давхар даралтаас сэргийлж түр зуур loading харуулж болно
    final success = await _apiService.approveSchool(id, action);

    if (!mounted) return;

    if (success) {
      _showSnackBar(action == 'approve' 
          ? "Сургууль амжилттай баталгаажлаа" 
          : "Сургуулийн хүсэлтээс татгалзлаа");
      _fetchSchoolRequests(); // Жагсаалтыг шинэчлэх
    } else {
      _showSnackBar("Алдаа гарлаа. Дахин оролдоно уу.");
    }
  }

  // SnackBar харуулах аюулгүй функц
  void _showSnackBar(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars(); // Өмнөх SnackBar-уудыг арилгах
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg), 
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text(
          "Системийн удирдлага",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF3F37D9)),
            onPressed: _isLoading ? null : _fetchSchoolRequests,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF3F37D9)))
          : _pendingSchools.isEmpty
              ? _buildEmptyState()
              : _buildSchoolList(),
    );
  }

  // Хоосон үед харуулах дизайн
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            "Хүлээгдэж буй сургуулийн хүсэлт байхгүй",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  // Сургуулийн жагсаалт харуулах
  Widget _buildSchoolList() {
    return RefreshIndicator(
      onRefresh: _fetchSchoolRequests,
      color: const Color(0xFF3F37D9),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pendingSchools.length,
        itemBuilder: (context, index) {
          final school = _pendingSchools[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          school['name'] ?? 'Нэргүй сургууль',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Icon(Icons.pending_actions, color: Colors.orange, size: 20),
                    ],
                  ),
                  const Divider(height: 24),
                  _infoRow(Icons.email_outlined, "Админ: ${school['admin_email']}"),
                  const SizedBox(height: 8),
                  _infoRow(Icons.location_on_outlined, "Хаяг: ${school['address']}"),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _handleAction(school['id'], 'reject'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text("Татгалзах"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _handleAction(school['id'], 'approve'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          child: const Text("Батлах"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.grey[800], fontSize: 14),
          ),
        ),
      ],
    );
  }
}