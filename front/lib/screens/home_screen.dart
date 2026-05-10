import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
// Дараах дэлгэцүүд таны төсөлд байгаа гэж үзэв:
import 'club_detail_screen.dart'; 
import 'event_detail_screen.dart'; // Эвент дэлгэрэнгүй хуудас

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _api = ApiService();
  Map<String, dynamic>? _userData;
  List<dynamic> _events = [];
  List<dynamic> _clubs  = [];
  int  _notifCount = 0;
  bool _isLoading  = true;

  String get imgBase => kIsWeb ? "http://127.0.0.1:8000" : "http://10.0.2.2:8000";

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final res = await Future.wait([
        _api.getMe().catchError((_) => null),
        _api.getEvents().catchError((_) => []),
        _api.getClubs().catchError((_) => []),
        _api.getNotifications().catchError((_) => []),
      ]);
      if (mounted) setState(() {
        _userData    = res[0] as Map<String, dynamic>?;
        _events      = res[1] as List;
        _clubs       = res[2] as List;
        _notifCount  = (res[3] as List).where((n) => n['is_read'] == false).length;
        _isLoading   = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _fullUrl(String? path) {
    if (path == null || path.isEmpty) return "";
    return path.startsWith('http') ? path : "$imgBase$path";
  }

  String _date(dynamic v) {
    if (v == null || v.toString().isEmpty) return "Огноо тодорхойгүй";
    final s = v.toString();
    return s.contains('T') ? s.split('T')[0] : s;
  }

  @override
  Widget build(BuildContext context) {
    final name = _userData?['first_name']?.toString().isNotEmpty == true
        ? _userData!['first_name']
        : (_userData?['username'] ?? 'Зочин');

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : RefreshIndicator(
              onRefresh: _load,
              color: AppTheme.primary,
              backgroundColor: AppTheme.surface,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Сайн байна уу', 
                                    style: TextStyle(fontFamily: 'Nunito', fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
                                  Text(name, 
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontFamily: 'Nunito', fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textPrimary, height: 1.2)),
                                ],
                              ),
                            ),
                            _buildNotificationIcon(),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _buildBanner(),
                        const SizedBox(height: 28),
                        _buildSectionHeader('Удахгүй болох'),
                        const SizedBox(height: 14),
                        _buildEventList(),
                        const SizedBox(height: 28),
                        _buildSectionHeader('Идэвхтэй клубүүд'),
                        const SizedBox(height: 14),
                        _buildClubRow(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildNotificationIcon() {
    return Stack(
      children: [
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(.08)),
          ),
          child: const Icon(Icons.notifications_outlined, color: AppTheme.textPrimary, size: 24),
        ),
        if (_notifCount > 0)
          Positioned(
            top: 10, right: 10,
            child: Container(
              width: 10, height: 10,
              decoration: BoxDecoration(
                color: AppTheme.accent,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.bgDark, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontFamily: 'Nunito', fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
          Text('Бүгдийг харах', style: TextStyle(fontFamily: 'Nunito', fontSize: 13, color: AppTheme.primary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(.3), blurRadius: 24, offset: const Offset(0, 8))],
        ),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                child: const Text('Шинэ хэрэглэгч', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              const Text('Клубдаа нэгдэж, сонирхолтой эвентүүдэд оролцоорой!',
                style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 15, color: Colors.white, height: 1.4)),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(.2), borderRadius: BorderRadius.circular(30)),
                child: const Text('Нэгдэх →', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 12, color: Colors.white)),
              ),
            ]),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.hub_rounded, size: 64, color: Colors.white24),
        ]),
      ),
    );
  }

  Widget _buildEventList() {
    if (_events.isEmpty) {
      return const Padding(padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text('Одоогоор эвент байхгүй.', style: TextStyle(fontFamily: 'Nunito', color: AppTheme.textSecondary)));
    }
    return Column(
      children: _events.take(3).toList().asMap().entries.map((e) {
        final ev = e.value;
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: _EventCard(
            data: ev, // Бүх датаг дамжуулна
            name    : ev['name'] ?? 'Нэргүй',
            date    : _date(ev['date'] ?? ev['created_at']),
            location: ev['location'] ?? 'Байршилгүй',
            imageUrl: _fullUrl(ev['image']),
            current : ev['current_participants'] ?? 0,
            max     : ev['max_participants'] ?? 0,
            colorIdx: e.key,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => EventDetailPage(eventData: ev),));
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildClubRow() {
    if (_clubs.isEmpty) {
      return const Padding(padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text('Клуб байхгүй.', style: TextStyle(fontFamily: 'Nunito', color: AppTheme.textSecondary)));
    }
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _clubs.length,
        itemBuilder: (_, i) {
          final c = _clubs[i];
          int members = c['member_count'] ?? 0;
          return _ClubCard(
            name: c['name'] ?? 'Клуб', 
            members: members, 
            logoUrl: _fullUrl(c['logo']), 
            colorIdx: i,
            onTap: () {
              // ClubDetailScreen-рүү үсрэх
              Navigator.push(context, MaterialPageRoute(builder: (_) => ClubDetailScreen(club: c)));
            },
          );
        },
      ),
    );
  }
}

// --- ТУСЛАХ CARD WIDGET-ҮҮД ---

class _EventCard extends StatelessWidget {
  final Map data;
  final String name, date, location, imageUrl;
  final int current, max, colorIdx;
  final VoidCallback onTap;

  const _EventCard({
    required this.data, required this.name, required this.date, required this.location,
    required this.imageUrl, required this.current, required this.max, required this.colorIdx,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.categoryGradients[colorIdx % AppTheme.categoryGradients.length];
    final pct = max > 0 ? (current / max).clamp(0.0, 1.0) : 0.0;
    final isFull = max > 0 && current >= max;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(.05)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Row(children: [
              Container(
                width: 90, height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
                ),
                child: imageUrl.isNotEmpty
                    ? Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.event, color: Colors.white))
                    : const Icon(Icons.event, color: Colors.white, size: 30),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w800, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.calendar_today, size: 10, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text(date, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
                    ]),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          LinearProgressIndicator(
                            value: pct,
                            minHeight: 4,
                            borderRadius: BorderRadius.circular(2),
                            backgroundColor: Colors.white10,
                            valueColor: AlwaysStoppedAnimation(isFull ? Colors.redAccent : colors[0]),
                          ),
                          const SizedBox(height: 4),
                          Text('$current/$max оролцогч', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 9)),
                        ]),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: isFull ? null : LinearGradient(colors: colors),
                          color: isFull ? Colors.white10 : null,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(isFull ? 'Дүүрсэн' : 'Харах', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ]),
                  ]),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _ClubCard extends StatelessWidget {
  final String name, logoUrl;
  final int members, colorIdx;
  final VoidCallback onTap;

  const _ClubCard({required this.name, required this.logoUrl, required this.members, required this.colorIdx, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.categoryGradients[colorIdx % AppTheme.categoryGradients.length];
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 130,
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(.05)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: colors),
                borderRadius: BorderRadius.circular(12),
              ),
              child: logoUrl.isNotEmpty
                  ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(logoUrl, fit: BoxFit.cover))
                  : const Icon(Icons.groups, color: Colors.white),
            ),
            const Spacer(),
            Text(name, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w800, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text('$members гишүүн', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          ]),
        ),
      ),
    );
  }
}