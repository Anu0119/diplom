import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart'; // Таны AppTheme файл

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _storage = const FlutterSecureStorage();
  List _notifications = [];
  bool _isLoading = true;

  final String apiBaseUrl = kIsWeb ? "http://127.0.0.1:8000/api" : "http://10.0.2.2:8000/api";

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    String? token = await _storage.read(key: "access");
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/clubs/notifications/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _notifications = jsonDecode(utf8.decode(response.bodyBytes));
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Notification Fetch Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(int id) async {
    String? token = await _storage.read(key: "access");
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/clubs/notifications/$id/read/'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (response.statusCode == 200) {
        _fetchNotifications(); 
      }
    } catch (e) {
      debugPrint("Mark Read Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text("Мэдэгдэл", 
          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.textSecondary),
            onPressed: _fetchNotifications,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : _notifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _fetchNotifications,
                  color: AppTheme.primary,
                  backgroundColor: AppTheme.surface,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final item = _notifications[index];
                      bool isRead = item['is_read'] ?? false;

                      return _buildNotificationItem(item, isRead);
                    },
                  ),
                ),
    );
  }

  Widget _buildNotificationItem(dynamic item, bool isRead) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isRead ? AppTheme.surfaceLight : AppTheme.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isRead ? Colors.white.withOpacity(0.03) : AppTheme.primary.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: isRead ? [] : [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _markAsRead(item['id']),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon хэсэг
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: isRead 
                        ? LinearGradient(colors: [Colors.grey.shade800, Colors.grey.shade900])
                        : AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isRead ? Icons.notifications_none_rounded : Icons.notifications_active_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                // Text хэсэг
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item['title'] ?? '',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontWeight: isRead ? FontWeight.w600 : FontWeight.w800,
                                fontSize: 15,
                                color: isRead ? AppTheme.textSecondary : AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(color: AppTheme.accent, shape: BoxShape.circle),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item['message'] ?? '',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 13, 
                          color: isRead ? AppTheme.textMuted : AppTheme.textSecondary,
                          height: 1.4
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _formatDate(item['created_at']),
                        style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, fontFamily: 'Nunito'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_off_outlined, size: 64, color: AppTheme.textMuted.withOpacity(0.5)),
          ),
          const SizedBox(height: 20),
          const Text(
            "Одоогоор мэдэгдэл алга",
            style: TextStyle(
              fontFamily: 'Nunito',
              color: AppTheme.textSecondary, 
              fontSize: 16, 
              fontWeight: FontWeight.w700
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Шинэ мэдэгдэл ирэх үед энд харагдах болно.",
            style: TextStyle(fontFamily: 'Nunito', color: AppTheme.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      DateTime dt = DateTime.parse(dateStr);
      // Монгол хэлээр "Өнөөдөр", "Өчигдөр" гэж харуулбал илүү гоё
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final notificationDate = DateTime(dt.year, dt.month, dt.day);

      if (notificationDate == today) {
        return "Өнөөдөр ${DateFormat('HH:mm').format(dt.toLocal())}";
      } else if (notificationDate == today.subtract(const Duration(days: 1))) {
        return "Өчигдөр ${DateFormat('HH:mm').format(dt.toLocal())}";
      }
      return DateFormat('MM/dd HH:mm').format(dt.toLocal());
    } catch (e) {
      return dateStr;
    }
  }
}