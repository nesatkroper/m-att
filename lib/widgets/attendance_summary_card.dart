import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/attendance_record.dart';

class AttendanceSummaryCard extends StatelessWidget {
  final List<AttendanceRecord> records;
  final bool isLoading;
  final String viewMode; // 'weekly' or 'monthly'

  const AttendanceSummaryCard({
    super.key,
    required this.records,
    this.isLoading = false,
    this.viewMode = 'weekly',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isLoading) {
      return _buildLoadingCard(colorScheme);
    }

    if (records.isEmpty) {
      return _buildNoDataCard(colorScheme);
    }

    // Calculate attendance statistics
    final stats = _calculateAttendanceStats(records);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Monthly Summary',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _getCurrentMonthName(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Statistics Grid
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
            child: Row(
              children: [
                _buildStatItem(
                  context: context,
                  icon: Icons.check_circle,
                  label: 'Present',
                  value: '${stats['present']}',
                  color: colorScheme.primary,
                ),
                _buildStatItem(
                  context: context,
                  icon: Icons.update,
                  label: 'Early Out',
                  value: '${stats['earlyOut']}',
                  color: colorScheme.tertiary,
                ),
                _buildStatItem(
                  context: context,
                  icon: Icons.cancel,
                  label: 'Absent',
                  value: '${stats['absent']}',
                  color: colorScheme.error,
                ),
              ],
            ),
          ),

          // Chart section
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 20),
            child: SizedBox(
              height: 180,
              child: _buildAttendanceChart(colorScheme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 22,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildAttendanceChart(ColorScheme colorScheme) {
  //   return BarChart(
  //     BarChartData(
  //       alignment: BarChartAlignment.spaceAround,
  //       maxY: 1.0,
  //       minY: 0,
  //       groupsSpace: 12,
  //       borderData: FlBorderData(show: false),
  //       gridData: const FlGridData(show: false),
  //       titlesData: FlTitlesData(
  //         show: true,
  //         rightTitles:
  //             const AxisTitles(sideTitles: SideTitles(showTitles: false)),
  //         topTitles:
  //             const AxisTitles(sideTitles: SideTitles(showTitles: false)),
  //         leftTitles:
  //             const AxisTitles(sideTitles: SideTitles(showTitles: false)),
  //         bottomTitles: AxisTitles(
  //           sideTitles: SideTitles(
  //             showTitles: true,
  //             getTitlesWidget: (value, meta) {
  //               const style = TextStyle(
  //                 color: Color(0xff7589a2),
  //                 fontWeight: FontWeight.w500,
  //                 fontSize: 12,
  //               );
  //               Widget text;
  //               switch (value.toInt()) {
  //                 case 0:
  //                   text = const Text('M', style: style);
  //                   break;
  //                 case 1:
  //                   text = const Text('T', style: style);
  //                   break;
  //                 case 2:
  //                   text = const Text('W', style: style);
  //                   break;
  //                 case 3:
  //                   text = const Text('T', style: style);
  //                   break;
  //                 case 4:
  //                   text = const Text('F', style: style);
  //                   break;
  //                 case 5:
  //                   text = const Text('S', style: style);
  //                   break;
  //                 case 6:
  //                   text = const Text('S', style: style);
  //                   break;
  //                 default:
  //                   text = const Text('', style: style);
  //                   break;
  //               }
  //               return SideTitleWidget(
  //                 axisSide: meta.axisSide,
  //                 space: 16,
  //                 child: text,
  //               );
  //             },
  //             reservedSize: 25,
  //           ),
  //         ),
  //       ),
  //       barGroups: _generateBarGroups(colorScheme),
  //     ),
  //     swapAnimationDuration: const Duration(milliseconds: 500),
  //     swapAnimationCurve: Curves.easeInOutCubic,
  //   );
  // }

  Widget _buildAttendanceChart(ColorScheme colorScheme) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 1.0,
        minY: 0,
        groupsSpace: 12,
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          show: true,
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const style = TextStyle(
                  color: Color(0xff7589a2),
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                );
                Widget text;
                switch (value.toInt()) {
                  case 0:
                    text = const Text('M', style: style);
                    break;
                  case 1:
                    text = const Text('T', style: style);
                    break;
                  case 2:
                    text = const Text('W', style: style);
                    break;
                  case 3:
                    text = const Text('T', style: style);
                    break;
                  case 4:
                    text = const Text('F', style: style);
                    break;
                  case 5:
                    text = const Text('S', style: style);
                    break;
                  case 6:
                    text = const Text('S', style: style);
                    break;
                  default:
                    text = const Text('', style: style);
                    break;
                }
                return SideTitleWidget(
                  meta: meta, // Required meta parameter
                  space: 16,
                  child: text,
                );
              },
              reservedSize: 25,
            ),
          ),
        ),
        barGroups: _generateBarGroups(colorScheme),
      ),
      swapAnimationDuration: const Duration(milliseconds: 500),
      swapAnimationCurve: Curves.easeInOutCubic,
    );
  }

  List<BarChartGroupData> _generateBarGroups(ColorScheme colorScheme) {
    // Generate data for each day of the week
    final List<double> attendanceData = _getWeeklyAttendanceData();

    return List.generate(7, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: attendanceData[index],
            color: attendanceData[index] > 0
                ? colorScheme.primary
                : colorScheme.error,
            width: 20,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
        ],
      );
    });
  }

  List<double> _getWeeklyAttendanceData() {
    // This would ideally come from actual data
    // For now, we'll create some sample data based on the records
    final weekData = List<double>.filled(7, 0.0);

    // Get current date and start of week
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    // Populate week data from records
    for (var record in records) {
      final day = record.checkIn.weekday - 1; // 0 for Monday, 6 for Sunday
      if (day >= 0 && day < 7) {
        // Only count records from the current week
        final recordDate = DateTime(
            record.checkIn.year, record.checkIn.month, record.checkIn.day);
        final weekStart =
            DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
        final diff = recordDate.difference(weekStart).inDays;

        if (diff >= 0 && diff < 7) {
          weekData[day] = record.status == 'absent' ? 0.0 : 1.0;
        }
      }
    }

    return weekData;
  }

  Map<String, int> _calculateAttendanceStats(List<AttendanceRecord> records) {
    // Initialize stats
    final stats = {
      'present': 0,
      'earlyOut': 0,
      'absent': 0,
    };

    // Get records for the current month only
    final now = DateTime.now();
    final currentMonthRecords = records
        .where((record) =>
            record.checkIn.year == now.year &&
            record.checkIn.month == now.month)
        .toList();

    for (var record in currentMonthRecords) {
      if (record.status == 'absent') {
        stats['absent'] = (stats['absent'] ?? 0) + 1;
      } else if (record.status == 'checked-out') {
        stats['present'] = (stats['present'] ?? 0) + 1;
      } else if (record.status == 'checked-in') {
        // If checked in but not checked out yet, count as early out
        stats['earlyOut'] = (stats['earlyOut'] ?? 0) + 1;
      }
    }

    return stats;
  }

  String _getCurrentMonthName() {
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
    return months[DateTime.now().month - 1];
  }

  Widget _buildLoadingCard(ColorScheme colorScheme) {
    return Container(
      height: 280,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: colorScheme.primary,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading attendance summary...',
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataCard(ColorScheme colorScheme) {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 48,
              color: colorScheme.primary.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'No attendance data available',
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.7),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import '../models/attendance_record.dart';

// class AttendanceSummaryCard extends StatelessWidget {
//   final List<AttendanceRecord> records;
//   final bool isLoading;

//   const AttendanceSummaryCard({
//     super.key,
//     required this.records,
//     this.isLoading = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;

//     if (isLoading) {
//       return _buildLoadingCard(colorScheme);
//     }

//     if (records.isEmpty) {
//       return _buildNoDataCard(colorScheme);
//     }

//     // Calculate attendance statistics
//     final stats = _calculateAttendanceStats(records);

//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       decoration: BoxDecoration(
//         color: theme.cardColor,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header
//           Padding(
//             padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Monthly Summary',
//                   style: theme.textTheme.titleLarge?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: colorScheme.onSurface,
//                   ),
//                 ),
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: colorScheme.primary.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.calendar_today,
//                         size: 16,
//                         color: colorScheme.primary,
//                       ),
//                       const SizedBox(width: 6),
//                       Text(
//                         _getCurrentMonthName(),
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: colorScheme.primary,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Statistics Grid
//           Padding(
//             padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
//             child: Row(
//               children: [
//                 _buildStatItem(
//                   context: context,
//                   icon: Icons.check_circle,
//                   label: 'Present',
//                   value: '${stats['present']}',
//                   color: colorScheme.primary,
//                 ),
//                 _buildStatItem(
//                   context: context,
//                   icon: Icons.update,
//                   label: 'Early Out',
//                   value: '${stats['earlyOut']}',
//                   color: colorScheme.tertiary,
//                 ),
//                 _buildStatItem(
//                   context: context,
//                   icon: Icons.cancel,
//                   label: 'Absent',
//                   value: '${stats['absent']}',
//                   color: colorScheme.error,
//                 ),
//               ],
//             ),
//           ),

//           // Chart section
//           Padding(
//             padding: const EdgeInsets.fromLTRB(8, 16, 8, 20),
//             child: SizedBox(
//               height: 180,
//               child: _buildAttendanceChart(colorScheme),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatItem({
//     required BuildContext context,
//     required IconData icon,
//     required String label,
//     required String value,
//     required Color color,
//   }) {
//     final theme = Theme.of(context);

//     return Expanded(
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 4),
//         padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Column(
//           children: [
//             Icon(
//               icon,
//               color: color,
//               size: 22,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               value,
//               style: theme.textTheme.headlineSmall?.copyWith(
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               label,
//               style: theme.textTheme.bodySmall?.copyWith(
//                 color: theme.colorScheme.onSurface.withOpacity(0.7),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAttendanceChart(ColorScheme colorScheme) {
//     return BarChart(
//       BarChartData(
//         alignment: BarChartAlignment.spaceAround,
//         maxY: 1.0,
//         minY: 0,
//         groupsSpace: 12,
//         borderData: FlBorderData(show: false),
//         gridData: const FlGridData(show: false),
//         titlesData: FlTitlesData(
//           show: true,
//           rightTitles:
//               const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           topTitles:
//               const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           leftTitles:
//               const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           // bottomTitles: AxisTitles(
//           //   sideTitles: SideTitles(
//           //     showTitles: true,
//           //     getTitlesWidget: (value, meta) {
//           //       const style = TextStyle(
//           //         color: Color(0xff7589a2),
//           //         fontWeight: FontWeight.w500,
//           //         fontSize: 12,
//           //       );
//           //       Widget text;
//           //       switch (value.toInt()) {
//           //         case 0:
//           //           text = const Text('M', style: style);
//           //           break;
//           //         case 1:
//           //           text = const Text('T', style: style);
//           //           break;
//           //         case 2:
//           //           text = const Text('W', style: style);
//           //           break;
//           //         case 3:
//           //           text = const Text('T', style: style);
//           //           break;
//           //         case 4:
//           //           text = const Text('F', style: style);
//           //           break;
//           //         case 5:
//           //           text = const Text('S', style: style);
//           //           break;
//           //         case 6:
//           //           text = const Text('S', style: style);
//           //           break;
//           //         default:
//           //           text = const Text('', style: style);
//           //           break;
//           //       }
//           //       return SideTitleWidget(
//           //         axisSide: meta.axisSide,
//           //         space: 16,
//           //         child: text,
//           //       );
//           //     },
//           //     reservedSize: 25,
//           //   ),
//           // ),
//           bottomTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               getTitlesWidget: (value, meta) {
//                 const style = TextStyle(
//                   color: Color(0xff7589a2),
//                   fontWeight: FontWeight.w500,
//                   fontSize: 12,
//                 );
//                 Widget text;
//                 switch (value.toInt()) {
//                   case 0:
//                     text = const Text('M', style: style);
//                     break;
//                   case 1:
//                     text = const Text('T', style: style);
//                     break;
//                   case 2:
//                     text = const Text('W', style: style);
//                     break;
//                   case 3:
//                     text = const Text('T', style: style);
//                     break;
//                   case 4:
//                     text = const Text('F', style: style);
//                     break;
//                   case 5:
//                     text = const Text('S', style: style);
//                     break;
//                   case 6:
//                     text = const Text('S', style: style);
//                     break;
//                   default:
//                     text = const Text('', style: style);
//                     break;
//                 }
//                 return SideTitleWidget(
//                   meta: meta,
//                   space: 16,
//                   child: text,
//                 );
//               },
//               reservedSize: 25,
//             ),
//           ),
//         ),
//         barGroups: _generateBarGroups(colorScheme),
//       ),
//       swapAnimationDuration: const Duration(milliseconds: 500),
//       swapAnimationCurve: Curves.easeInOutCubic,
//     );
//   }

//   List<BarChartGroupData> _generateBarGroups(ColorScheme colorScheme) {
//     // Generate data for each day of the week
//     final List<double> attendanceData = _getWeeklyAttendanceData();

//     return List.generate(7, (index) {
//       return BarChartGroupData(
//         x: index,
//         barRods: [
//           BarChartRodData(
//             toY: attendanceData[index],
//             color: attendanceData[index] > 0
//                 ? colorScheme.primary
//                 : colorScheme.error,
//             width: 20,
//             borderRadius: const BorderRadius.only(
//               topLeft: Radius.circular(6),
//               topRight: Radius.circular(6),
//             ),
//           ),
//         ],
//       );
//     });
//   }

//   List<double> _getWeeklyAttendanceData() {
//     // This would ideally come from actual data
//     // For now, we'll create some sample data based on the records
//     final weekData = List<double>.filled(7, 0.0);

//     // Get current date and start of week
//     final now = DateTime.now();
//     final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

//     // Populate week data from records
//     for (var record in records) {
//       final day = record.checkInTime.weekday - 1; // 0 for Monday, 6 for Sunday
//       if (day >= 0 && day < 7) {
//         // Only count records from the current week
//         final recordDate = DateTime(record.checkInTime.year,
//             record.checkInTime.month, record.checkInTime.day);
//         final weekStart =
//             DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
//         final diff = recordDate.difference(weekStart).inDays;

//         if (diff >= 0 && diff < 7) {
//           weekData[day] = record.status == 'absent' ? 0.0 : 1.0;
//         }
//       }
//     }

//     return weekData;
//   }

//   Map<String, int> _calculateAttendanceStats(List<AttendanceRecord> records) {
//     // Initialize stats
//     final stats = {
//       'present': 0,
//       'earlyOut': 0,
//       'absent': 0,
//     };

//     // Get records for the current month only
//     final now = DateTime.now();
//     final currentMonthRecords = records
//         .where((record) =>
//             record.checkInTime.year == now.year &&
//             record.checkInTime.month == now.month)
//         .toList();

//     for (var record in currentMonthRecords) {
//       if (record.status == 'absent') {
//         stats['absent'] = (stats['absent'] ?? 0) + 1;
//       } else if (record.status == 'checked-out') {
//         stats['present'] = (stats['present'] ?? 0) + 1;
//       } else if (record.status == 'checked-in') {
//         // If checked in but not checked out yet, count as early out
//         stats['earlyOut'] = (stats['earlyOut'] ?? 0) + 1;
//       }
//     }

//     return stats;
//   }

//   String _getCurrentMonthName() {
//     final months = [
//       'January',
//       'February',
//       'March',
//       'April',
//       'May',
//       'June',
//       'July',
//       'August',
//       'September',
//       'October',
//       'November',
//       'December'
//     ];
//     return months[DateTime.now().month - 1];
//   }

//   Widget _buildLoadingCard(ColorScheme colorScheme) {
//     return Container(
//       height: 280,
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             SizedBox(
//               width: 40,
//               height: 40,
//               child: CircularProgressIndicator(
//                 color: colorScheme.primary,
//                 strokeWidth: 3,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Loading attendance summary...',
//               style: TextStyle(
//                 color: colorScheme.onSurface.withOpacity(0.7),
//                 fontSize: 14,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildNoDataCard(ColorScheme colorScheme) {
//     return Container(
//       height: 200,
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.bar_chart,
//               size: 48,
//               color: colorScheme.primary.withOpacity(0.4),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'No attendance data available',
//               style: TextStyle(
//                 color: colorScheme.onSurface.withOpacity(0.7),
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
