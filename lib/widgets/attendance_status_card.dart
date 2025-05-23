import 'package:attendance/models/enum.dart';
import 'package:flutter/material.dart';
import 'package:attendance/models/attendance_record.dart';

class AttendanceStatusCard extends StatelessWidget {
  final AttendanceRecord? record;
  final bool isLoading;

  const AttendanceStatusCard({
    super.key,
    required this.record,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isLoading) {
      return _buildLoadingCard(colorScheme);
    }

    if (record == null) {
      return _buildNoDataCard(colorScheme);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: _getStatusColor(record!.status.toString(), colorScheme).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getStatusColor(record!.status.toString(), colorScheme).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color:
                _getStatusColor(record!.status.toString(), colorScheme).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Status',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildStatusBadge(record!.status.toString(), colorScheme),
            ],
          ),
          const SizedBox(height: 16),
          _buildTimeInfo(record!, theme),
          const SizedBox(height: 12),
          _buildStatusMessage(record!, theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildLoadingCard(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 100,
                height: 20,
                decoration: BoxDecoration(
                  color: colorScheme.outline.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                width: 80,
                height: 25,
                decoration: BoxDecoration(
                  color: colorScheme.outline.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 20,
            decoration: BoxDecoration(
              color: colorScheme.outline.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 200,
            height: 20,
            decoration: BoxDecoration(
              color: colorScheme.outline.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.outline.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataCard(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 48,
            color: colorScheme.primary.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'No attendance data available',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Scan a QR code to check in',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, ColorScheme colorScheme) {
    IconData icon;
    String label;

    switch (status) {
      case 'checked-in':
        icon = Icons.login;
        label = 'Checked In';
        break;
      case 'checked-out':
        icon = Icons.logout;
        label = 'Checked Out';
        break;
      case 'absent':
      default:
        icon = Icons.cancel_outlined;
        label = 'Not Checked In';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status, colorScheme).withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: _getStatusColor(status, colorScheme),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _getStatusColor(status, colorScheme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInfo(AttendanceRecord record, ThemeData theme) {
    final checkInTime = record.status != 'absent'
        ? '${record.checkIn.hour.toString().padLeft(2, '0')}:${record.checkIn.minute.toString().padLeft(2, '0')}'
        : '--:--';

    final checkOut = record.checkOut != null
        ? '${record.checkOut!.hour.toString().padLeft(2, '0')}:${record.checkOut!.minute.toString().padLeft(2, '0')}'
        : '--:--';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Check-in Time',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    checkInTime,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          width: 1,
          height: 40,
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Check-out Time',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 18,
                      color: record.checkOut != null
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      checkOut,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: record.checkOut != null
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusMessage(
      AttendanceRecord record, ThemeData theme, ColorScheme colorScheme) {
    String message;
    IconData icon;

    if (record.status == 'checked-in') {
      message =
          'You are currently checked in. Don\'t forget to check out before leaving!';
      icon = Icons.info_outline;
    } else if (record.status == 'checked-out') {
      message = 'You have completed your workday. See you tomorrow!';
      icon = Icons.check_circle_outline;
    } else {
      message =
          'You haven\'t checked in today. Please scan a QR code to check in.';
      icon = Icons.warning_amber_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getStatusInfoColor(record.status.toString(), colorScheme).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: _getStatusInfoColor(record.status.toString(), colorScheme),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: _getStatusInfoColor(record.status.toString(), colorScheme)
                    .withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status, ColorScheme colorScheme) {
    switch (status) {
      case 'checked-in':
        return colorScheme.primary;
      case 'checked-out':
        return colorScheme.secondary;
      case 'absent':
      default:
        return colorScheme.error;
    }
  }

  Color _getStatusInfoColor(String status, ColorScheme colorScheme) {
    switch (status) {
      case 'checked-in':
        return Colors.blue;
      case 'checked-out':
        return Colors.green;
      case 'absent':
      default:
        return Colors.amber;
    }
  }
}
