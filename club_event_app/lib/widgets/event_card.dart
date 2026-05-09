import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  final String name;
  final String club;
  final String date;
  final Color cardColor;
  final Color titleColor;
  final Color subtitleColor;
  final Color dateColor;

  const EventCard({
    super.key,
    required this.name,
    required this.club,
    required this.date,
    this.cardColor = const Color(0xFF4A90E2), // Blue background
    this.titleColor = Colors.white,           // Title white
    this.subtitleColor = Colors.white70,      // Club white70
    this.dateColor = Colors.white60,          // Date white60
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            club,
            style: TextStyle(
              fontSize: 16,
              color: subtitleColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            date,
            style: TextStyle(
              fontSize: 14,
              color: dateColor,
            ),
          ),
        ],
      ),
    );
  }
}