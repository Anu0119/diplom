import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late TabController _tabController;
  
  List<dynamic> _pendingClubs = [];
  List<dynamic> _pendingSchools = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchAllRequests();
  }

  Future<void> _fetchAllRequests() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      final clubs = await _apiService.getClubs();
      final schools = await _apiService.getSchools(); 

      if (mounted) {
        setState(() {
          // Шүүх логикийг илүү баттай болгов
          _pendingClubs = clubs.where((c) => c['is_active'] == false).toList();
          _pendingSchools = schools.where((s) => s['status'].toString().toLowerCase() == 'pending').toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAction(String type, int id, String action) async {
    bool success = false;
    if (type == 'club') {
      success = await _apiService.approveClub(id, action);
    } else {
      success = await _apiService.approveSchool(id, action);
    }

    if (success) {
      _showSnackBar(action == 'approve' ? "Амжилттай баталгаажлаа" : "Татгалзлаа");
      _fetchAllRequests();
    } else {
      _showSnackBar("Алдаа гарлаа. Дахин оролдоно уу.");
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Админ удирдлага"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF3F37D9),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF3F37D9),
          tabs: const [
            Tab(text: "Клубууд"),
            Tab(text: "Сургуулиуд"),
          ],
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : TabBarView(
            controller: _tabController,
            children: [
              _buildList('club', _pendingClubs),
              _buildList('school', _pendingSchools),
            ],
          ),
    );
  }

  Widget _buildList(String type, List<dynamic> items) {
    if (items.isEmpty) {
      return Center(child: Text("Хүлээгдэж буй ${type == 'club' ? 'клуб' : 'сургууль'} байхгүй"));
    }
    return RefreshIndicator(
      onRefresh: _fetchAllRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(15),
              title: Text(item['name'] ?? 'Нэргүй', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(type == 'club' 
                ? "Ахлагч: ${item['leader_name'] ?? 'Тодорхойгүй'}" 
                : "И-мэйл: ${item['admin_email']}\nХаяг: ${item['address']}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    onPressed: () => _handleAction(type, item['id'], 'approve'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () => _handleAction(type, item['id'], 'reject'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}