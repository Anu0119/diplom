import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../theme/app_theme.dart';
import 'club_detail_screen.dart';

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

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
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

  // КЛУБ ҮҮСГЭХ API ХҮСЭЛТ
  Future<void> _createClub(String name, String desc) async {
    String? token = await _storage.read(key: "access");
    try {
      final res = await http.post(
        Uri.parse('$_base/clubs/create/'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'description': desc}),
      );
      if (res.statusCode == 201) {
        _fetch(); // Жагсаалтыг шинэчлэх
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('🎉 Клуб нээх хүсэлт илгээгдлээ. Админ баталгаажуулсны дараа харагдах болно.')),
          );
        }
      }
    } catch (e) {
      debugPrint("Error creating club: $e");
    }
  }

  // ҮҮСГЭХ ЦОНХ (BOTTOM SHEET)
  void _showCreate() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.textMuted, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            const Text('Шинэ клуб үүсгэх', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: AppTheme.textPrimary)),
            const SizedBox(height: 20),
            _SheetField(ctrl: nameCtrl, hint: 'Клубын нэр', icon: Icons.groups_rounded),
            const SizedBox(height: 12),
            _SheetField(ctrl: descCtrl, hint: 'Тайлбар', icon: Icons.description_outlined, maxLines: 3),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                if (nameCtrl.text.isNotEmpty) {
                  _createClub(nameCtrl.text, descCtrl.text);
                  Navigator.pop(context);
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(16)),
                child: const Text('Хүсэлт илгээх', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
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
    return GestureDetector(
      onTap: _showCreate, // ЭНД ДАРАХАД ЦОНХ НЭЭГДЭНЭ
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
      ),
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
                  final changed = await Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => ClubDetailScreen(club: clubs[i]))
                  );
                  if (changed == true) _fetch();
                }
              ),
            ),
    );
  }
}

// ОРОЛТЫН ТАЛБАРЫН ДИЗАЙН
class _SheetField extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final IconData icon;
  final int maxLines;
  const _SheetField({required this.ctrl, required this.hint, required this.icon, this.maxLines = 1});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withOpacity(.07))),
    child: TextField(
      controller: ctrl, maxLines: maxLines,
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint, hintStyle: const TextStyle(color: AppTheme.textMuted),
        prefixIcon: Icon(icon, color: AppTheme.primary, size: 20),
        border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    ),
  );
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