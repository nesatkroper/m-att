import 'package:flutter/material.dart';
import 'package:attendance/models/attendance_record.dart';

class MonthlyCalendarView extends StatelessWidget {
  final List<AttendanceRecord> records;
  final DateTime month;

  MonthlyCalendarView({
    super.key,
    required this.records,
    DateTime? month,
  }) : month = month ?? DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Map of date to attendance status
    final Map<int, String> attendanceByDay = {};

    // Build map of attendance by day
    for (final record in records) {
      final day = record.checkIn.day;
      attendanceByDay[day] = record.status.toString();
    }

    // Get the first day of the month
    final firstDay = DateTime(month.year, month.month, 1);

    // Get the day of week (0 = Sunday, 6 = Saturday)
    final firstDayOfWeek = firstDay.weekday % 7;

    // Get number of days in the month
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    // Calculate rows needed (including header)
    final int rows = ((daysInMonth + firstDayOfWeek) / 7).ceil() + 1;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_getMonthName(month.month)} ${month.year}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                Row(
                  children: [
                    _buildLegendItem(context, 'Present', colorScheme.primary),
                    const SizedBox(width: 8),
                    _buildLegendItem(context, 'Absent', Colors.red),
                  ],
                ),
              ],
            ),
          ),

          // Calendar grid
          SizedBox(
            height: 48.0 * rows, // Fixed height based on number of rows
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount:
                  7 + (rows - 1) * 7, // Days of week + days in calendar view
              itemBuilder: (context, index) {
                // First row is the days of the week
                if (index < 7) {
                  return _buildDayOfWeekHeader(index, theme);
                }

                // Adjust index to account for the header row
                final adjustedIndex = index - 7;

                // Calculate the day of month
                final day = adjustedIndex - firstDayOfWeek + 1;

                // Check if this grid cell has a valid day
                if (day < 1 || day > daysInMonth) {
                  return const SizedBox();
                }

                // Determine if today
                final now = DateTime.now();
                final isToday = now.year == month.year &&
                    now.month == month.month &&
                    now.day == day;

                // Get attendance status
                final status = attendanceByDay[day];

                return _buildDayCell(day, status, isToday, colorScheme, theme);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayOfWeekHeader(int dayIndex, ThemeData theme) {
    final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Center(
      child: Text(
        days[dayIndex],
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: dayIndex == 0 || dayIndex == 6
              ? theme.colorScheme.primary.withOpacity(0.7)
              : null,
        ),
      ),
    );
  }

  Widget _buildDayCell(int day, String? status, bool isToday,
      ColorScheme colorScheme, ThemeData theme) {
    Color bgColor;
    Color textColor;
    FontWeight fontWeight = FontWeight.normal;

    if (isToday) {
      bgColor = colorScheme.primary;
      textColor = colorScheme.onPrimary;
      fontWeight = FontWeight.bold;
    } else if (status == 'checked-in' || status == 'checked-out') {
      bgColor = colorScheme.primary.withOpacity(0.15);
      textColor = colorScheme.primary;
    } else if (status == 'absent') {
      bgColor = Colors.red.withOpacity(0.15);
      textColor = Colors.red;
    } else {
      // No status (weekend or future date)
      final isWeekend = (day + month.weekday - 1) % 7 == 0 ||
          (day + month.weekday - 1) % 7 == 6;
      bgColor = isWeekend ? Colors.grey.withOpacity(0.1) : Colors.transparent;
      textColor =
          isWeekend ? Colors.grey.shade600 : theme.colorScheme.onSurface;
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          day.toString(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: textColor,
            fontWeight: fontWeight,
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    final months = [
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
      'December'
    ];
    return months[month - 1];
  }
}
