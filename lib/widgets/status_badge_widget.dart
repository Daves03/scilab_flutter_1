import 'package:flutter/material.dart';

enum BadgeStatus { approved, pending, locked, active, completed, warning }

class StatusBadgeWidget extends StatelessWidget {
  final BadgeStatus status;
  final String? label;

  const StatusBadgeWidget({required this.status, this.label, super.key});

  @override
  Widget build(BuildContext context) {
    final (bgColor, textColor, defaultLabel) = switch (status) {
      BadgeStatus.approved => (
        const Color(0xFF0D2E1F),
        const Color(0xFF00FF88),
        'Approved',
      ),
      BadgeStatus.pending => (
        const Color(0xFF2E2010),
        const Color(0xFFFFB800),
        'Pending',
      ),
      BadgeStatus.locked => (
        const Color(0xFF1E2A3A),
        const Color(0xFF8BA3C0),
        'Locked',
      ),
      BadgeStatus.active => (
        const Color(0xFF0D2E3F),
        const Color(0xFF00D4FF),
        'Active',
      ),
      BadgeStatus.completed => (
        const Color(0xFF0D2E1F),
        const Color(0xFF00FF88),
        'Done',
      ),
      BadgeStatus.warning => (
        const Color(0xFF2E1515),
        const Color(0xFFFF4757),
        'Alert',
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: textColor.withAlpha(77), width: 1),
      ),
      child: Text(
        label ?? defaultLabel,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
