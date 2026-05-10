import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../theme/app_theme.dart';
import 'club_detail_screen.dart'; // <--- Дэлгэрэнгүй хуудасны файлыг энд заавал импортлоорой

class ClubScreen extends StatefulWidget {
  const ClubScreen({super.key});
  @override
  State<ClubScreen> createState() => _ClubScreenState();
}

class _ClubScreenState extends State<ClubScreen> with SingleTickerProviderStateMixin {
  final _storage = const FlutterSecureStorage();
  late TabController _tabCtrl;
  List _all = [], _mine = [];
  bool _loading = true;
  final String _base = kIsWeb ? "http://127.0.0.1:8000/api" : "http://10.0.2.2:8000/api";

  @override
  void initState() { 
    super.initState(); 
    _tabCtrl = TabController(length: 2, vsync: this); 
    _fetch(); 
  }

  Future<void> _fetch() async {
    if (!mounted) return;
    String? token = await _storage.read(key: "access");
    final headers = {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'};
    try {
      final res = await Future.wait([
        http.get(Uri.parse('$_base/clubs/list/')),
        http.get(Uri.parse('$_base/clubs/my-clubs/'), headers: headers),
      ]);
      if (mounted) setState(() {
        if (res[0].statusCode == 200) _all  = jsonDecode(utf8.decode(res[0].bodyBytes));
        if (res[1].statusCode == 200) _mine = jsonDecode(utf8.decode(res[1].bodyBytes));
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: Column(children: [
          _buildHeader(),
          _buildTabs(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                : TabBarView(controller: _tabCtrl, children: [
                    _list(_all, 'Клуб олдсонгүй'), 
                    _list(_mine, 'Танд хамааралтай клуб алга')
                  ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      child: Row(children: [
        const Expanded(child: Text('Клубүүд', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900, fontSize: 26, color: AppTheme.textPrimary))),
        _addButton(),
      ]),
    );
  }

  Widget _addButton() {
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(12)),
      child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(16)),
      child: TabBar(
        controller: _tabCtrl,
        indicator: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(12)),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white, unselectedLabelColor: AppTheme.textSecondary,
        tabs: const [Tab(text: 'Бүх клубууд'), Tab(text: 'Миний клубууд')],
      ),
    );
  }

  Widget _list(List clubs, String empty) {
    return RefreshIndicator(
      onRefresh: _fetch,
      child: clubs.isEmpty
          ? Center(child: Text(empty, style: const TextStyle(color: AppTheme.textSecondary)))
          : GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: .85
              ),
              itemCount: clubs.length,
              itemBuilder: (_, i) => _ClubGridCard(
                club: clubs[i], 
                colorIdx: i, 
                onTap: () async {
                  // КАРТ ДЭЭР ДАРАХАД ТУСДАА БАЙГАА DETAIL ХУУДАС РУУ ҮСРЭНЭ
                  final changed = await Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => ClubDetailScreen(club: clubs[i]))
                  );
                  if (changed == true) _fetch(); // Хэрэв дэлгэрэнгүй хуудаснаас ямар нэг өөрчлөлт гарвал жагсаалтыг шинэчилнэ
                }
              ),
            ),
    );
  }
}

class _ClubGridCard extends StatelessWidget {
  final Map club; final int colorIdx; final VoidCallback onTap;
  const _ClubGridCard({required this.club, required this.colorIdx, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.categoryGradients[colorIdx % AppTheme.categoryGradients.length];
    final logo   = club['logo'] ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.cardGradient, 
          borderRadius: BorderRadius.circular(20), 
          border: Border.all(color: Colors.white.withOpacity(.07))
        ),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors), 
              borderRadius: BorderRadius.circular(14)
            ),
            child: logo.isNotEmpty
                ? ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.network(logo, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.groups, color: Colors.white)))
                : const Icon(Icons.groups, color: Colors.white),
          ),
          const Spacer(),
          Text(club['name'] ?? 'Клуб', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text('${club['member_count'] ?? 0} гишүүн', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(gradient: LinearGradient(colors: colors), borderRadius: BorderRadius.circular(10)),
            child: const Text('Дэлгэрэнгүй →', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: Colors.white)),
          ),
        ]),
      ),
    );
  }
}