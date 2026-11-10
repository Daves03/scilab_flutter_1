import 'package:flutter/material.dart';

class CourseCreatedDate extends StatelessWidget {
  final DateTime? createdAt;

  const CourseCreatedDate({super.key, required this.createdAt});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF8BA3C0)
        : Colors.grey.shade600;
    final label = createdAt == null
        ? 'Creation date unavailable'
        : 'Created ${MaterialLocalizations.of(context).formatShortDate(createdAt!.toLocal())}';
    return Row(
      children: [
        Icon(Icons.calendar_today_outlined, size: 12, color: color),
        const SizedBox(width: 5),
        Flexible(
          child: Text(label, style: TextStyle(fontSize: 11, color: color)),
        ),
      ],
    );
  }
}
