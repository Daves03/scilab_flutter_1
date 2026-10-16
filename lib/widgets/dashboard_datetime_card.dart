import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

@immutable
class _DashboardWeather {
  final double temperature;
  final int weatherCode;
  final bool isDay;

  const _DashboardWeather({
    required this.temperature,
    required this.weatherCode,
    required this.isDay,
  });
}

class _DashboardWeatherService {
  // CvSU Bacoor City Campus. These can be overridden per deployment without
  // changing the app source.
  static final _latitude =
      double.tryParse(
        const String.fromEnvironment(
          'WEATHER_LATITUDE',
          defaultValue: '14.41276233',
        ),
      ) ??
      14.41276233;
  static final _longitude =
      double.tryParse(
        const String.fromEnvironment(
          'WEATHER_LONGITUDE',
          defaultValue: '120.9813331',
        ),
      ) ??
      120.9813331;

  static _DashboardWeather? _cachedWeather;
  static DateTime? _cachedAt;

  static Future<_DashboardWeather> load({bool forceRefresh = false}) async {
    final now = DateTime.now();
    final cachedAt = _cachedAt;
    if (!forceRefresh &&
        _cachedWeather != null &&
        cachedAt != null &&
        now.difference(cachedAt) < const Duration(minutes: 15)) {
      return _cachedWeather!;
    }

    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': _latitude.toString(),
      'longitude': _longitude.toString(),
      'current': 'temperature_2m,weather_code,is_day',
      'timezone': 'Asia/Manila',
    });
    final response = await http.get(uri).timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) {
      throw StateError('Weather request failed (${response.statusCode}).');
    }

    final payload = jsonDecode(response.body);
    if (payload is! Map<String, dynamic>) {
      throw const FormatException('Invalid weather response.');
    }
    final current = payload['current'];
    if (current is! Map<String, dynamic>) {
      throw const FormatException('Current weather is missing.');
    }
    final temperature = current['temperature_2m'];
    final weatherCode = current['weather_code'];
    final isDay = current['is_day'];
    if (temperature is! num || weatherCode is! num || isDay is! num) {
      throw const FormatException('Current weather values are invalid.');
    }

    final weather = _DashboardWeather(
      temperature: temperature.toDouble(),
      weatherCode: weatherCode.toInt(),
      isDay: isDay.toInt() == 1,
    );
    _cachedWeather = weather;
    _cachedAt = now;
    return weather;
  }
}

@immutable
class DashboardCalendarEvent {
  final String id;
  final String quizName;
  final String courseName;
  final DateTime dueDate;

  const DashboardCalendarEvent({
    required this.id,
    required this.quizName,
    required this.courseName,
    required this.dueDate,
  });
}

/// Compact live date/time card shared by the student and teacher dashboards.
/// Its layout mirrors the admin dashboard widget while remaining phone-safe.
class DashboardDateTimeCard extends StatefulWidget {
  final DateTime dateTime;
  final List<DashboardCalendarEvent> calendarEvents;
  final bool showQuizDeadlines;
  final bool showTeacherQuizSummary;

  const DashboardDateTimeCard({
    required this.dateTime,
    this.calendarEvents = const [],
    this.showQuizDeadlines = false,
    this.showTeacherQuizSummary = false,
    super.key,
  });

  @override
  State<DashboardDateTimeCard> createState() => _DashboardDateTimeCardState();
}

class _DashboardDateTimeCardState extends State<DashboardDateTimeCard> {
  late final ValueNotifier<List<DashboardCalendarEvent>> _eventsNotifier;
  late String _eventsSignature;
  _DashboardWeather? _weather;
  bool _isLoadingWeather = true;
  bool _weatherFailed = false;

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

  String get _weekday => _weekdays[widget.dateTime.weekday - 1].toUpperCase();

  String get _date =>
      '${_months[widget.dateTime.month - 1]} ${widget.dateTime.day}, ${widget.dateTime.year}';

  String get _time {
    final hour = widget.dateTime.hour == 0
        ? 12
        : (widget.dateTime.hour > 12
              ? widget.dateTime.hour - 12
              : widget.dateTime.hour);
    final hourText = hour.toString().padLeft(2, '0');
    final minute = widget.dateTime.minute.toString().padLeft(2, '0');
    final second = widget.dateTime.second.toString().padLeft(2, '0');
    final period = widget.dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hourText:$minute:$second $period';
  }

  @override
  void initState() {
    super.initState();
    _eventsSignature = _calendarEventsSignature(widget.calendarEvents);
    _eventsNotifier = ValueNotifier(
      List<DashboardCalendarEvent>.unmodifiable(widget.calendarEvents),
    );
    _loadWeather();
  }

  Future<void> _loadWeather({bool forceRefresh = false}) async {
    if (mounted) {
      setState(() {
        _isLoadingWeather = true;
        _weatherFailed = false;
      });
    }
    try {
      final weather = await _DashboardWeatherService.load(
        forceRefresh: forceRefresh,
      );
      if (!mounted) return;
      setState(() {
        _weather = weather;
        _isLoadingWeather = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingWeather = false;
        _weatherFailed = true;
      });
    }
  }

  String _weatherDescription(int code) {
    if (code == 0) return 'Clear';
    if (code <= 3) return 'Cloudy';
    if (code == 45 || code == 48) return 'Foggy';
    if (code >= 51 && code <= 57) return 'Drizzle';
    if ((code >= 61 && code <= 67) || (code >= 80 && code <= 82)) {
      return 'Rainy';
    }
    if ((code >= 71 && code <= 77) || (code >= 85 && code <= 86)) {
      return 'Snowy';
    }
    if (code >= 95) return 'Stormy';
    return 'Weather';
  }

  IconData _weatherIcon(_DashboardWeather weather) {
    final code = weather.weatherCode;
    if (code == 0) {
      return weather.isDay ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded;
    }
    if (code <= 3) return Icons.cloud_outlined;
    if (code == 45 || code == 48) return Icons.foggy;
    if ((code >= 51 && code <= 67) || (code >= 80 && code <= 82)) {
      return Icons.water_drop_outlined;
    }
    if ((code >= 71 && code <= 77) || (code >= 85 && code <= 86)) {
      return Icons.ac_unit_rounded;
    }
    if (code >= 95) return Icons.thunderstorm_outlined;
    return Icons.cloud_outlined;
  }

  Widget _buildWeatherTile(bool isDark) {
    const accent = Color(0xFFF59E0B);
    final primaryText = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryText = isDark
        ? const Color(0xFF9FB3CC)
        : const Color(0xFF64748B);
    final weather = _weather;

    String value;
    IconData icon;
    if (_isLoadingWeather) {
      value = 'Updating...';
      icon = Icons.cloud_sync_outlined;
    } else if (_weatherFailed || weather == null) {
      value = 'Tap to retry';
      icon = Icons.cloud_off_outlined;
    } else {
      value = '${weather.temperature.round()}°C · '
          '${_weatherDescription(weather.weatherCode)}';
      icon = _weatherIcon(weather);
    }

    return Semantics(
      button: true,
      label: weather == null
          ? 'Bacoor weather $value'
          : 'Bacoor weather, $value. Tap to refresh.',
      child: Tooltip(
        message: weather == null
            ? 'Bacoor campus weather'
            : 'Bacoor campus weather • Tap to refresh',
        child: InkWell(
          onTap: _isLoadingWeather
              ? null
              : () => _loadWeather(forceRefresh: true),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 9),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF101D34) : const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF29405F)
                    : const Color(0xFFFDE68A),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoadingWeather)
                  const SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: accent,
                    ),
                  )
                else
                  Icon(icon, color: accent, size: 17),
                const SizedBox(width: 6),
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WEATHER',
                        maxLines: 1,
                        style: TextStyle(
                          color: accent,
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: weather == null ? secondaryText : primaryText,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          height: 1,
                        ),
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

  @override
  void didUpdateWidget(covariant DashboardDateTimeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final signature = _calendarEventsSignature(widget.calendarEvents);
    if (signature == _eventsSignature) return;
    _eventsSignature = signature;
    final latestEvents = List<DashboardCalendarEvent>.unmodifiable(
      widget.calendarEvents,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _eventsNotifier.value = latestEvents;
    });
  }

  String _calendarEventsSignature(List<DashboardCalendarEvent> events) => events
      .map(
        (event) =>
            '${event.id}|${event.quizName}|${event.courseName}|${event.dueDate.microsecondsSinceEpoch}',
      )
      .join('||');

  @override
  void dispose() {
    _eventsNotifier.dispose();
    super.dispose();
  }

  Future<void> _showCalendar(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => _DashboardCalendarDialog(
        currentDate: widget.dateTime,
        eventsListenable: _eventsNotifier,
        showQuizDeadlines: widget.showQuizDeadlines,
        showTeacherQuizSummary: widget.showTeacherQuizSummary,
      ),
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
            Row(
              children: [
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
                const SizedBox(width: 8),
                Expanded(child: _buildWeatherTile(isDark)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCalendarDialog extends StatefulWidget {
  final DateTime currentDate;
  final ValueListenable<List<DashboardCalendarEvent>> eventsListenable;
  final bool showQuizDeadlines;
  final bool showTeacherQuizSummary;

  const _DashboardCalendarDialog({
    required this.currentDate,
    required this.eventsListenable,
    required this.showQuizDeadlines,
    required this.showTeacherQuizSummary,
  });

  @override
  State<_DashboardCalendarDialog> createState() =>
      _DashboardCalendarDialogState();
}

class _DashboardCalendarDialogState extends State<_DashboardCalendarDialog> {
  static const _monthNames = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const _shortMonthNames = <String>[
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

  static const _weekdayLabels = <String>['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  static const _deadlineColor = Color(0xFFFF4757);
  static const _teacherQuizMarkerColor = Color(0xFF10B981);

  late DateTime _selectedDate;
  late DateTime _visibleMonth;
  int _visibleQuizIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedDate = _dateOnly(widget.currentDate);
    _visibleMonth = DateTime(_selectedDate.year, _selectedDate.month);
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static bool _isSameDay(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;

  List<DashboardCalendarEvent> _eventsOn(
    DateTime date,
    List<DashboardCalendarEvent> events,
  ) {
    final matching = events
        .where((event) => _isSameDay(event.dueDate, date))
        .toList(growable: false);
    return [...matching]..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  void _changeMonth(int offset) {
    final next = DateTime(_visibleMonth.year, _visibleMonth.month + offset);
    if (next.year < 2020 || next.year > 2100) return;
    final today = _dateOnly(widget.currentDate);
    final daysInNextMonth = DateTime(next.year, next.month + 1, 0).day;
    final selectedDay = next.year == today.year && next.month == today.month
        ? today.day
        : math.min(_selectedDate.day, daysInNextMonth);
    setState(() {
      _visibleMonth = next;
      _selectedDate = DateTime(next.year, next.month, selectedDay);
      _visibleQuizIndex = 0;
    });
  }

  String _selectedDateLabel(DateTime date) =>
      '${_shortMonthNames[date.month - 1]} ${date.day}, ${date.year}';

  String _timeLabel(DateTime date) {
    var hour = date.hour;
    final period = hour >= 12 ? 'PM' : 'AM';
    if (hour == 0) hour = 12;
    if (hour > 12) hour -= 12;
    return '$hour:${date.minute.toString().padLeft(2, '0')} $period';
  }

  String _dueDateTimeLabel(DateTime date) =>
      '${_selectedDateLabel(date)} at ${_timeLabel(date)}';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? const Color(0xFF00D4FF) : const Color(0xFF1565C0);
    final surface = isDark ? const Color(0xFF142240) : Colors.white;
    final border = isDark ? const Color(0xFF1E3A5F) : const Color(0xFFDCE3EC);
    final primaryText = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryText = isDark
        ? const Color(0xFF9FB3CC)
        : const Color(0xFF64748B);

    return ValueListenableBuilder<List<DashboardCalendarEvent>>(
      valueListenable: widget.eventsListenable,
      builder: (context, events, _) {
        final selectedEvents = _eventsOn(_selectedDate, events);
        final visibleMonthQuizCount = events
            .where(
              (event) =>
                  event.dueDate.year == _visibleMonth.year &&
                  event.dueDate.month == _visibleMonth.month,
            )
            .length;
        final availableHeight = MediaQuery.sizeOf(context).height - 32;
        final desiredHeight = widget.showTeacherQuizSummary
            ? 550.0
            : !widget.showQuizDeadlines
            ? 500.0
            : selectedEvents.isEmpty
            ? 550.0
            : 690.0;

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 370),
            child: Container(
              height: math.min(desiredHeight, availableHeight),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: border),
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
                children: [
                  _buildHeader(
                    context,
                    isDark: isDark,
                    accent: accent,
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                  ),
                  Divider(height: 1, color: border),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                      child: Column(
                        children: [
                          _buildMonthNavigation(
                            primaryText: primaryText,
                            secondaryText: secondaryText,
                          ),
                          _buildWeekdayHeader(secondaryText),
                          const SizedBox(height: 4),
                          _buildMonthGrid(
                            widget.showQuizDeadlines ||
                                    widget.showTeacherQuizSummary
                                ? events
                                : const [],
                            isDark: isDark,
                            accent: accent,
                            eventMarkerColor: widget.showTeacherQuizSummary
                                ? _teacherQuizMarkerColor
                                : _deadlineColor,
                            primaryText: primaryText,
                            surface: surface,
                          ),
                          if (widget.showQuizDeadlines) ...[
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: _deadlineColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 7),
                                  Text(
                                    'Quiz due date',
                                    style: TextStyle(
                                      color: secondaryText,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildSelectedDateDetails(
                              selectedEvents,
                              isDark: isDark,
                              accent: accent,
                              primaryText: primaryText,
                              secondaryText: secondaryText,
                            ),
                          ] else if (widget.showTeacherQuizSummary) ...[
                            const SizedBox(height: 12),
                            _buildTeacherMonthlyQuizSummary(
                              visibleMonthQuizCount,
                              isDark: isDark,
                              accent: _teacherQuizMarkerColor,
                              primaryText: primaryText,
                              secondaryText: secondaryText,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Divider(height: 1, color: border),
                  _buildFooter(context, accent),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context, {
    required bool isDark,
    required Color accent,
    required Color primaryText,
    required Color secondaryText,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 8, 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? const [Color(0x3322D3EE), Color(0x333B82F6)]
                    : const [Color(0xFFE0F2FE), Color(0xFFDBEAFE)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.calendar_month_outlined, color: accent, size: 21),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Calendar',
                  style: TextStyle(
                    color: primaryText,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  _selectedDateLabel(_selectedDate),
                  style: TextStyle(color: secondaryText, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Close calendar',
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.close_rounded, color: secondaryText),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthNavigation({
    required Color primaryText,
    required Color secondaryText,
  }) {
    final canGoBack = !(_visibleMonth.year == 2020 && _visibleMonth.month == 1);
    final canGoForward =
        !(_visibleMonth.year == 2100 && _visibleMonth.month == 12);

    return SizedBox(
      height: 42,
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${_monthNames[_visibleMonth.month - 1]} ${_visibleMonth.year}',
              style: TextStyle(
                color: primaryText,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Previous month',
            visualDensity: VisualDensity.compact,
            onPressed: canGoBack ? () => _changeMonth(-1) : null,
            icon: Icon(Icons.chevron_left_rounded, color: secondaryText),
          ),
          IconButton(
            tooltip: 'Next month',
            visualDensity: VisualDensity.compact,
            onPressed: canGoForward ? () => _changeMonth(1) : null,
            icon: Icon(Icons.chevron_right_rounded, color: secondaryText),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeader(Color secondaryText) {
    return Row(
      children: _weekdayLabels
          .map(
            (label) => Expanded(
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }

  Widget _buildMonthGrid(
    List<DashboardCalendarEvent> events, {
    required bool isDark,
    required Color accent,
    required Color eventMarkerColor,
    required Color primaryText,
    required Color surface,
  }) {
    final firstDay = DateTime(_visibleMonth.year, _visibleMonth.month);
    final leadingEmptyDays = firstDay.weekday % 7;
    final daysInMonth = DateTime(
      _visibleMonth.year,
      _visibleMonth.month + 1,
      0,
    ).day;
    final cellCount = ((leadingEmptyDays + daysInMonth + 6) ~/ 7) * 7;
    final today = _dateOnly(widget.currentDate);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cellCount,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.08,
      ),
      itemBuilder: (context, index) {
        final day = index - leadingEmptyDays + 1;
        if (day < 1 || day > daysInMonth) return const SizedBox.shrink();

        final date = DateTime(_visibleMonth.year, _visibleMonth.month, day);
        final eventCount = events
            .where((event) => _isSameDay(event.dueDate, date))
            .length;
        final hasDeadline = eventCount > 0;
        final isSelected = _isSameDay(date, _selectedDate);
        final isToday = _isSameDay(date, today);
        final semanticsLabel = StringBuffer(_selectedDateLabel(date));
        if (hasDeadline) {
          semanticsLabel.write(
            '. $eventCount ${eventCount == 1 ? 'quiz' : 'quizzes'} due',
          );
        }

        return Semantics(
          button: true,
          selected: isSelected,
          label: semanticsLabel.toString(),
          child: InkResponse(
            radius: 23,
            onTap: () {
              setState(() {
                _selectedDate = date;
                _visibleQuizIndex = 0;
              });
            },
            child: Center(
              child: SizedBox(
                width: 36,
                height: 36,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: isToday
                              ? accent
                              : isSelected
                              ? (isDark
                                    ? const Color(0xFF21314D)
                                    : const Color(0xFFF1F5F9))
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          border: isSelected && !isToday
                              ? Border.all(
                                  color: isDark
                                      ? const Color(0xFF526681)
                                      : const Color(0xFFCBD5E1),
                                )
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            '$day',
                            style: TextStyle(
                              color: isToday ? Colors.white : primaryText,
                              fontSize: 14,
                              fontWeight: isSelected || isToday
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (hasDeadline)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: eventMarkerColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: surface, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: eventMarkerColor.withAlpha(85),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTeacherMonthlyQuizSummary(
    int quizCount, {
    required bool isDark,
    required Color accent,
    required Color primaryText,
    required Color secondaryText,
  }) {
    final hasQuizzes = quizCount > 0;
    final message = hasQuizzes
        ? 'You set $quizCount ${quizCount == 1 ? 'quiz' : 'quizzes'} this month.'
        : 'No quizzes set for this month.';

    return Semantics(
      label: message,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF101D34) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF29405F) : const Color(0xFFDCE3EC),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: hasQuizzes
                    ? accent.withAlpha(28)
                    : secondaryText.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                hasQuizzes
                    ? Icons.assignment_turned_in_outlined
                    : Icons.event_busy_outlined,
                color: hasQuizzes ? accent : secondaryText,
                size: 20,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly quiz summary',
                    style: TextStyle(
                      color: secondaryText,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: TextStyle(
                      color: primaryText,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDateDetails(
    List<DashboardCalendarEvent> events, {
    required bool isDark,
    required Color accent,
    required Color primaryText,
    required Color secondaryText,
  }) {
    if (events.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF101D34) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.event_available_outlined,
              color: secondaryText,
              size: 19,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                'No quizzes due on ${_selectedDateLabel(_selectedDate)}.',
                style: TextStyle(color: secondaryText, fontSize: 12.5),
              ),
            ),
          ],
        ),
      );
    }

    final visibleIndex = math.min(_visibleQuizIndex, events.length - 1);
    final event = events[visibleIndex];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.assignment_late_outlined,
              color: _deadlineColor,
              size: 19,
            ),
            const SizedBox(width: 8),
            Text(
              '${events.length} ${events.length == 1 ? 'quiz' : 'quizzes'} due',
              style: TextStyle(
                color: primaryText,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        SizedBox(
          height: 112,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.04, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: Container(
              key: ValueKey(
                '${event.id}:${event.dueDate.microsecondsSinceEpoch}',
              ),
              width: double.infinity,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF281B33)
                    : const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF713244)
                      : const Color(0xFFFFCCD2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF4B2030)
                          : const Color(0xFFFFDFE3),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(
                      Icons.quiz_outlined,
                      color: _deadlineColor,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.quizName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: primaryText,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (event.courseName.trim().isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            event.courseName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: secondaryText,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          'Due ${_dueDateTimeLabel(event.dueDate)}',
                          maxLines: 2,
                          style: const TextStyle(
                            color: _deadlineColor,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (events.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              _buildQuizArrowButton(
                tooltip: 'Previous quiz',
                icon: Icons.chevron_left_rounded,
                onPressed: visibleIndex > 0
                    ? () => setState(() => _visibleQuizIndex = visibleIndex - 1)
                    : null,
                isDark: isDark,
                accent: accent,
              ),
              const SizedBox(width: 9),
              Text(
                '${visibleIndex + 1} of ${events.length}',
                style: TextStyle(
                  color: secondaryText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                'Next quiz',
                style: TextStyle(
                  color: secondaryText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 7),
              _buildQuizArrowButton(
                tooltip: 'Next quiz',
                icon: Icons.chevron_right_rounded,
                onPressed: visibleIndex < events.length - 1
                    ? () => setState(() => _visibleQuizIndex = visibleIndex + 1)
                    : null,
                isDark: isDark,
                accent: accent,
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildQuizArrowButton({
    required String tooltip,
    required IconData icon,
    required VoidCallback? onPressed,
    required bool isDark,
    required Color accent,
  }) {
    return SizedBox(
      width: 36,
      height: 34,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        iconSize: 21,
        style: IconButton.styleFrom(
          foregroundColor: accent,
          disabledForegroundColor: isDark
              ? const Color(0xFF526681)
              : const Color(0xFFB4BFCC),
          backgroundColor: isDark
              ? const Color(0xFF101D34)
              : const Color(0xFFF8FAFC),
          disabledBackgroundColor: isDark
              ? const Color(0xFF101827)
              : const Color(0xFFF1F5F9),
          side: BorderSide(
            color: isDark ? const Color(0xFF29405F) : const Color(0xFFDCE3EC),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        ),
        icon: Icon(icon),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, Color accent) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () {
              final today = _dateOnly(widget.currentDate);
              setState(() {
                _selectedDate = today;
                _visibleMonth = DateTime(today.year, today.month);
                _visibleQuizIndex = 0;
              });
            },
            child: const Text('Today'),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
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
