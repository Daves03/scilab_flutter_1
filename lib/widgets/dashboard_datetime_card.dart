import 'package:flutter/material.dart';

/// Compact live date/time card shared by the student and teacher dashboards.
/// Its layout mirrors the admin dashboard widget while remaining phone-safe.
class DashboardDateTimeCard extends StatelessWidget {
  final DateTime dateTime;

  const DashboardDateTimeCard({required this.dateTime, super.key});

  static const _weekdays = <String>[
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const _months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String get _weekday => _weekdays[dateTime.weekday - 1].toUpperCase();

  String get _date =>
      '${_months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';

  String get _time {
    final hour = dateTime.hour == 0
        ? 12
        : (dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour);
    final hourText = hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hourText:$minute:$second $period';
  }

  Future<void> _showCalendar(BuildContext context) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? const Color(0xFF00D4FF) : const Color(0xFF1565C0);
    final surface = isDark ? const Color(0xFF142240) : Colors.white;
    var selectedDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 24,
              ),
              backgroundColor: Colors.transparent,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 370),
                child: Container(
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF1E3A5F)
                          : const Color(0xFFDCE3EC),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? const Color(0x3300D4FF)
                            : const Color(0x1F0F172A),
                        blurRadius: 28,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 16, 10, 10),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isDark
                                      ? const [
                                          Color(0x3322D3EE),
                                          Color(0x333B82F6),
                                        ]
                                      : const [
                                          Color(0xFFE0F2FE),
                                          Color(0xFFDBEAFE),
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.calendar_month_outlined,
                                color: accent,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Calendar',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF0F172A),
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    '${_months[selectedDate.month - 1]} ${selectedDate.day}, ${selectedDate.year}',
                                    style: TextStyle(
                                      color: isDark
                                          ? const Color(0xFF8BA3C0)
                                          : const Color(0xFF64748B),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Close calendar',
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(),
                              icon: Icon(
                                Icons.close_rounded,
                                color: isDark
                                    ? const Color(0xFF8BA3C0)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        height: 1,
                        color: isDark
                            ? const Color(0xFF1E3A5F)
                            : const Color(0xFFE2E8F0),
                      ),
                      Theme(
                        data: theme.copyWith(
                          colorScheme: theme.colorScheme.copyWith(
                            primary: accent,
                            onPrimary: Colors.white,
                            surface: surface,
                            onSurface: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                        ),
                        child: CalendarDatePicker(
                          key: ValueKey(selectedDate),
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                          currentDate: DateTime(
                            dateTime.year,
                            dateTime.month,
                            dateTime.day,
                          ),
                          onDateChanged: (value) {
                            setDialogState(() => selectedDate = value);
                          },
                        ),
                      ),
                      Divider(
                        height: 1,
                        color: isDark
                            ? const Color(0xFF1E3A5F)
                            : const Color(0xFFE2E8F0),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                setDialogState(() {
                                  selectedDate = DateTime(
                                    dateTime.year,
                                    dateTime.month,
                                    dateTime.day,
                                  );
                                });
                              },
                              child: const Text('Today'),
                            ),
                            const SizedBox(width: 8),
                            FilledButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(),
                              style: FilledButton.styleFrom(
                                backgroundColor: accent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Done'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateAccent = isDark
        ? const Color(0xFF00D4FF)
        : const Color(0xFF1565C0);
    const timeAccent = Color(0xFF10B981);

    return Semantics(
      container: true,
      label: '$_weekday, $_date. Current time $_time Philippine time.',
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF142240) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF1E3A5F) : const Color(0xFFDCE3EC),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? const Color(0x1F00D4FF) : const Color(0x1A0F172A),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _showCalendar(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: _DateTimeItem(
                        icon: Icons.calendar_today_outlined,
                        label: _weekday,
                        value: _date,
                        accent: dateAccent,
                        iconGradient: isDark
                            ? const [Color(0x3322D3EE), Color(0x333B82F6)]
                            : const [Color(0xFFE0F2FE), Color(0xFFDBEAFE)],
                        useTabularFigures: false,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 30,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: isDark
                      ? const Color(0xFF29405F)
                      : const Color(0xFFE2E8F0),
                ),
                Expanded(
                  child: _DateTimeItem(
                    icon: Icons.schedule_rounded,
                    label: 'TIME',
                    value: _time,
                    accent: timeAccent,
                    iconGradient: isDark
                        ? const [Color(0x3310B981), Color(0x3300D4FF)]
                        : const [Color(0xFFD1FAE5), Color(0xFFCFFAFE)],
                    useTabularFigures: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 34,
              child: OutlinedButton.icon(
                onPressed: () => _showCalendar(context),
                icon: const Icon(Icons.calendar_month_outlined, size: 17),
                label: const Text('Calendar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark
                      ? const Color(0xFFE2E8F0)
                      : const Color(0xFF0F172A),
                  backgroundColor: isDark
                      ? const Color(0xFF101D34)
                      : const Color(0xFFF8FAFC),
                  side: BorderSide(
                    color: isDark
                        ? const Color(0xFF29405F)
                        : const Color(0xFFDCE3EC),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 11),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateTimeItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;
  final List<Color> iconGradient;
  final bool useTabularFigures;

  const _DateTimeItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
    required this.iconGradient,
    required this.useTabularFigures,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: iconGradient),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: accent, size: 19),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: accent,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.55,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 3),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  maxLines: 1,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontSize: 13.5,
                    fontWeight: useTabularFigures
                        ? FontWeight.w700
                        : FontWeight.w600,
                    fontFeatures: useTabularFigures
                        ? const [FontFeature.tabularFigures()]
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
