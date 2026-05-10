import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

// Хэрэв таны файл дотор EventDetailPage гэж байгаа бол үүнийг ашиглана
// import 'event_detail_screen.dart'; 

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});
  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final ApiService _api = ApiService();
  final List<String> _cats = ['Бүгд', 'Ирэх', 'Өнгөрсөн', 'Орж буй'];
  int _selectedCat = 0;
  List<dynamic> _events = [];
  bool _isLoading = true;
  String get _base => kIsWeb ? "http://127.0.0.1:8000" : "http://10.0.2.2:8000";

  @override
  void initState() { super.initState(); _fetch(); }

  Future<void> _fetch() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final ev = await _api.getEvents();
      if (mounted) setState(() { _events = ev; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _imgUrl(String? path) {
    if (path == null || path.isEmpty) return "";
    return path.startsWith('http') ? path : "$_base$path";
  }

  String _date(dynamic v) {
    if (v == null || v.toString().isEmpty) return "Огноо тодорхойгүй";
    final s = v.toString();
    return s.contains('T') ? s.split('T')[0] : s;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: Column(children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(children: [
              const Expanded(child: Text('Эвентүүд', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900, fontSize: 26, color: AppTheme.textPrimary))),
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(.08))),
                child: const Icon(Icons.search_rounded, color: AppTheme.textPrimary, size: 20),
              ),
            ]),
          ),
          const SizedBox(height: 16),

          // Category chips
          SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _cats.length,
              itemBuilder: (_, i) {
                final sel = _selectedCat == i;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedCat = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: sel ? AppTheme.primaryGradient : null,
                        color: sel ? null : AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(30),
                        border: sel ? null : Border.all(color: Colors.white.withOpacity(.07)),
                        boxShadow: sel ? [BoxShadow(color: AppTheme.primary.withOpacity(.3), blurRadius: 10, offset: const Offset(0,4))] : null,
                      ),
                      child: Text(_cats[i], style: TextStyle(
                        fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 13,
                        color: sel ? Colors.white : AppTheme.textSecondary,
                      )),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                : RefreshIndicator(
                    onRefresh: _fetch,
                    color: AppTheme.primary,
                    backgroundColor: AppTheme.surface,
                    child: _events.isEmpty
                        ? _buildEmpty()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _events.length,
                            itemBuilder: (_, i) {
                              final ev = _events[i] as Map<String, dynamic>;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(24),
                                  onTap: () {
                                    // Detail хуудас руу шилжих
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => EventDetailPage(
                                          eventData: ev,
                                          baseUrl: _base,
                                        ),
                                      ),
                                    );
                                  },
                                  child: _BigEventCard(
                                    data    : ev,
                                    imgUrl  : _imgUrl(ev['image']),
                                    dateStr : _date(ev['date'] ?? ev['created_at']),
                                    colorIdx: i,
                                    onJoin  : _fetch,
                                    api     : _api,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ]),
      ),
    );
  }

  Widget _buildEmpty() {
    return ListView(children: [
      const SizedBox(height: 100),
      Center(
        child: Column(children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(24)),
            child: const Icon(Icons.event_available_rounded, color: AppTheme.textMuted, size: 40),
          ),
          const SizedBox(height: 16),
          const Text('Эвент байхгүй байна', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.textSecondary)),
        ]),
      ),
    ]);
  }
}

class _BigEventCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final String imgUrl, dateStr;
  final int colorIdx;
  final VoidCallback onJoin;
  final ApiService api;
  const _BigEventCard({required this.data, required this.imgUrl, required this.dateStr, required this.colorIdx, required this.onJoin, required this.api});

  @override
  State<_BigEventCard> createState() => _BigEventCardState();
}

class _BigEventCardState extends State<_BigEventCard> {
  bool _joining = false;

  Future<void> _join() async {
    setState(() => _joining = true);
    final res = await widget.api.joinEvent(widget.data['id']);
    if (!mounted) return;
    setState(() => _joining = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(res['success'] == true ? '🎉 Амжилттай бүртгүүллээ!' : (res['message'] ?? 'Алдаа гарлаа')),
    ));
    if (res['success'] == true) widget.onJoin();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final colors = AppTheme.categoryGradients[widget.colorIdx % AppTheme.categoryGradients.length];
    final current = d['current_participants'] ?? 0;
    final max     = d['max_participants'] ?? 0;
    final isFull  = max > 0 && current >= max;

    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(.07)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Image / banner
        Container(
          height: 130,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Stack(children: [
            if (widget.imgUrl.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Image.network(widget.imgUrl, width: double.infinity, height: 130, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox()),
              ),
            // AppTag байхгүй бол Container-аар орлуулж болно
            Positioned(top: 12, right: 12, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(8)),
              child: Text(isFull ? '🔴 Дүүрсэн' : '🟢 Нээлттэй', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            )),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(d['name'] ?? 'Нэргүй эвент', style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.textPrimary)),
            const SizedBox(height: 10),
            Row(children: [
              _meta(Icons.calendar_today_rounded, widget.dateStr),
              const SizedBox(width: 16),
              Expanded(child: _meta(Icons.location_on_rounded, d['location'] ?? 'Байршилгүй')),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: max > 0 ? (current / max).clamp(0.0, 1.0) : 0.0,
                      minHeight: 6,
                      backgroundColor: Colors.white.withOpacity(.08),
                      valueColor: AlwaysStoppedAnimation(isFull ? AppTheme.danger : colors[0]),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text('$current / $max оролцогч', style: const TextStyle(fontFamily: 'Nunito', fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
                ]),
              ),
              const SizedBox(width: 14),
              GestureDetector(
                onTap: (isFull || _joining) ? null : _join,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: isFull ? null : LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
                    color: isFull ? AppTheme.surfaceLight : null,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: isFull ? null : [BoxShadow(color: colors[0].withOpacity(.35), blurRadius: 12, offset: const Offset(0,4))],
                  ),
                  child: _joining
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(isFull ? 'Дүүрсэн' : 'Бүртгүүлэх', style: TextStyle(
                          fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 13,
                          color: isFull ? AppTheme.textMuted : Colors.white)),
                ),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _meta(IconData icon, String text) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: AppTheme.textSecondary),
      const SizedBox(width: 4),
      Flexible(child: Text(text, style: const TextStyle(fontFamily: 'Nunito', fontSize: 12, color: AppTheme.textSecondary), overflow: TextOverflow.ellipsis)),
    ]);
  }
}

// ── EventDetailPage (Таны нэрлэснээр) ──────────────────────────────────────────

class EventDetailPage extends StatefulWidget {
  final Map<String, dynamic> eventData;
  final String baseUrl;
  const EventDetailPage({super.key, required this.eventData, required this.baseUrl});
  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  final ApiService _api = ApiService();
  late Map<String, dynamic> _ev;
  bool _joining = false;

  @override
  void initState() { super.initState(); _ev = widget.eventData; }

  Future<void> _join() async {
    setState(() => _joining = true);
    final res = await _api.joinEvent(_ev['id']);
    if (!mounted) return;
    setState(() {
      _joining = false;
      if (res['success'] == true) {
        _ev['current_participants'] = (_ev['current_participants'] ?? 0) + 1;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(res['success'] == true ? '🎉 Амжилттай бүртгүүллээ!' : (res['message'] ?? 'Алдаа')),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final current = _ev['current_participants'] ?? 0;
    final max     = _ev['max_participants'] ?? 0;
    final isFull  = max > 0 && current >= max;
    final rawImg  = _ev['image'] as String?;
    final imgUrl  = (rawImg != null && !rawImg.startsWith('http')) ? "${widget.baseUrl}$rawImg" : (rawImg ?? "");

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppTheme.surface,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: imgUrl.isNotEmpty
                  ? Image.network(imgUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: AppTheme.surface))
                  : Container(
                      decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
                      child: const Icon(Icons.event_rounded, color: Colors.white54, size: 80),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_ev['name'] ?? '', style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900, fontSize: 24, color: AppTheme.textPrimary)),
                const SizedBox(height: 16),
                _detailRow(Icons.location_on_rounded, 'Байршил', _ev['location'] ?? 'Тодорхойгүй'),
                _detailRow(Icons.calendar_today_rounded, 'Огноо', (_ev['date'] ?? _ev['created_at'] ?? '').toString().split('T')[0]),
                _detailRow(Icons.group_rounded, 'Оролцогчид', '$current / $max ${isFull ? "(Дүүрсэн)" : ""}'),
                const SizedBox(height: 20),
                const Text('Тайлбар', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.textPrimary)),
                const SizedBox(height: 8),
                Text(_ev['description'] ?? 'Тайлбар байхгүй.', style: const TextStyle(fontFamily: 'Nunito', fontSize: 14, color: AppTheme.textSecondary, height: 1.6)),
                const SizedBox(height: 32),
                
                // Бүртгүүлэх товч
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: (isFull || _joining) ? null : _join,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      disabledBackgroundColor: AppTheme.surfaceLight,
                    ),
                    child: _joining 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(isFull ? 'Оролцогч дүүрсэн' : 'Бүртгүүлэх', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: AppTheme.primary.withOpacity(.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppTheme.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontFamily: 'Nunito', fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(fontFamily: 'Nunito', fontSize: 14, color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
        ]),
      ]),
    );
  }
}