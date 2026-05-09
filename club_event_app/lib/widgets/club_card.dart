import 'package:flutter/material.dart';

class ClubCard extends StatelessWidget {
  final String name;
  final String description;
  final Color cardColor;
  final Color titleColor;
  final Color subtitleColor;

  const ClubCard({
    super.key,
    required this.name,
    required this.description,
    this.cardColor = const Color(0xFFFFF2E0),
    this.titleColor = const Color(0xFFFF8C42),
    this.subtitleColor = const Color(0xFFA0522D),
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
            offset: Offset(0,4),
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
            description,
            style: TextStyle(
              fontSize: 16,
              color: subtitleColor,
            ),
          ),
        ],
      ),
    );
  }
}