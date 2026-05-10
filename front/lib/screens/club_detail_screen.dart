import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

// Файлын нэрс болон класс нэрс зөв эсэхийг дахин шалгаарай
import 'edit_club_screen.dart';
import 'create_event_screen.dart';

class ClubDetailScreen extends StatefulWidget {
  final Map club;
  const ClubDetailScreen({super.key, required this.club});

  @override
  State<ClubDetailScreen> createState() => _ClubDetailScreenState();
}

class _ClubDetailScreenState extends State<ClubDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _storage = const FlutterSecureStorage();
  
  Map? clubFullData;
  List _events = [];
  List _members = [];
  bool _isLoading = true;
  bool _hasChanged = false; // Энэ утгыг ашиглан өмнөх хуудсыг шинэчилнэ

  final String apiBaseUrl = kIsWeb ? "http://127.0.0.1:8000/api" : "http://10.0.2.2:8000/api";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    final int clubId = widget.club['id'];
    String? token = await _storage.read(key: "access");
    final headers = {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'};

    try {
      final responses = await Future.wait([
        http.get(Uri.parse('$apiBaseUrl/clubs/$clubId/'), headers: headers),
        http.get(Uri.parse('$apiBaseUrl/clubs/events/?club_id=$clubId')),
        http.get(Uri.parse('$apiBaseUrl/clubs/my-club/memberships/?club_id=$clubId'), headers: headers),
      ]);

      if (mounted) {
        setState(() {
          if (responses[0].statusCode == 200) clubFullData = jsonDecode(utf8.decode(responses[0].bodyBytes));
          if (responses[1].statusCode == 200) _events = jsonDecode(utf8.decode(responses[1].bodyBytes));
          if (responses[2].statusCode == 200) _members = jsonDecode(utf8.decode(responses[2].bodyBytes));
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Алдаа: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    bool isLeader = clubFullData?['is_leader'] ?? false;
    List pendingMembers = _members.where((m) => m['status'] == 'pending').toList();

    return Scaffold(
      floatingActionButton: isLeader ? FloatingActionButton.extended(
        onPressed: () async {
          debugPrint("Товчлуур дарагдлаа!"); // Энэ бичиг консол дээр гарч байгаа эсэхийг шалга
          
          if (clubFullData == null) {
            debugPrint("Дата ачаалагдаагүй байна");
            return;
          }

          // rootNavigator: true ашиглах нь илүү найдвартай
          final result = await Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (context) => CreateEventScreen(clubId: clubFullData!['id']),
            ),
          );

          if (result == true) {
            _fetchAllData();
          }
        },
        backgroundColor: const Color(0xFF3F37C9),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Эвент нэмэх", style: TextStyle(color: Colors.white)),
      ) : null,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              backgroundColor: const Color(0xFF3F37C9),
              iconTheme: const IconThemeData(color: Colors.white),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context, _hasChanged), // Энд ашиглав
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(clubFullData?['name'] ?? 'Клуб', 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                background: clubFullData?['logo'] != null 
                  ? Image.network(
                      clubFullData!['logo'], 
                      fit: BoxFit.cover, 
                      errorBuilder: (_, __, ___) => Container(color: Colors.grey) // ___ засав
                    )
                  : Container(color: Colors.grey),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Клубын тухай", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        _buildDynamicButton(isLeader),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(clubFullData?['description'] ?? "Тайлбар байхгүй.", style: const TextStyle(fontSize: 14, height: 1.4)),
                    if (isLeader && pendingMembers.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildJoinRequestBanner(pendingMembers),
                    ],
                    const Divider(height: 30),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: const Color(0xFF3F37C9),
                  indicatorColor: const Color(0xFF3F37C9),
                  tabs: const [Tab(text: "Эвэнтүүд"), Tab(text: "Гишүүд"), Tab(text: "Зураг")],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildEventsList(),
            _buildMembersGrid(),
            const Center(child: Text("Зураг оруулаагүй байна.")),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicButton(bool isLeader) {
    if (isLeader) {
      return ElevatedButton.icon(
        onPressed: () async {
          final result = await Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => EditClubScreen(club: clubFullData!))
          );
          if (result == true) {
            _hasChanged = true;
            _fetchAllData();
          }
        },
        icon: const Icon(Icons.edit, size: 16, color: Colors.white),
        label: const Text("Засах", style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
      );
    }
    
    String status = clubFullData?['user_status'] ?? "not_member";
    if (status == "approved") return const Text("Гишүүн ✅", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold));
    if (status == "pending") return const Text("Хүлээгдэж буй...", style: TextStyle(color: Colors.grey));

    return ElevatedButton(
      onPressed: _joinClub,
      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3F37C9)),
      child: const Text("Элсэх хүсэлт", style: TextStyle(color: Colors.white)),
    );
  }

  Widget _buildJoinRequestBanner(List pendingMembers) {
    return InkWell(
      onTap: () => _showJoinRequests(pendingMembers),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          children: [
            const Icon(Icons.person_add_alt_1, color: Colors.orange),
            const SizedBox(width: 10),
            Expanded(
              child: Text("${pendingMembers.length} хүүхэд элсэх хүсэлт илгээсэн байна",
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsList() {
    if (_events.isEmpty) return const Center(child: Text("Эвэнт байхгүй."));
    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: _events.length,
      itemBuilder: (context, index) {
        final ev = _events[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.event, color: Color(0xFF3F37C9)),
            title: Text(ev['name'] ?? ''),
            subtitle: Text(ev['location'] ?? ''),
          ),
        );
      },
    );
  }

  Widget _buildMembersGrid() {
    List approvedMembers = _members.where((m) => m['status'] == 'approved').toList();
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemCount: approvedMembers.length,
      itemBuilder: (context, index) => Column(
        children: [
          const CircleAvatar(child: Icon(Icons.person)),
          Text(approvedMembers[index]['user_name'] ?? '', overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  void _showJoinRequests(List pendingList) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Элсэх хүсэлтүүд", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Expanded(
              child: ListView.builder(
                itemCount: pendingList.length,
                itemBuilder: (context, index) {
                  final req = pendingList[index];
                  return ListTile(
                    title: Text(req['user_name']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.check, color: Colors.green), onPressed: () => _updateMemberStatus(req['id'], 'approved')),
                        IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () => _updateMemberStatus(req['id'], 'rejected')),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateMemberStatus(int membershipId, String status) async {
    String? token = await _storage.read(key: "access");
    try {
      final res = await http.post(
        Uri.parse('$apiBaseUrl/clubs/memberships/update-status/'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode({'membership_id': membershipId, 'status': status}),
      );
      
      if (res.statusCode == 200 && mounted) {
        Navigator.pop(context); // Модалийг хаах
        _fetchAllData(); // Датаг шинэчлэх
      }
    } catch (e) {
      debugPrint("Алдаа: $e");
    }
  }

  Future<void> _joinClub() async {
    String? token = await _storage.read(key: "access");
    final res = await http.post(
      Uri.parse('$apiBaseUrl/clubs/join/${widget.club['id']}/'), 
      headers: {'Authorization': 'Bearer $token'}
    );
    if (res.statusCode == 201) {
      _hasChanged = true;
      _fetchAllData();
    }
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;
  @override double get minExtent => _tabBar.preferredSize.height;
  @override double get maxExtent => _tabBar.preferredSize.height;
  @override Widget build(context, offset, overlaps) => Container(color: Colors.white, child: _tabBar);
  @override bool shouldRebuild(_SliverAppBarDelegate old) => false;
}