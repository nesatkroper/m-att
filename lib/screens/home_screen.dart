// import 'package:flutter/material.dart';
// import 'package:flutter_hooks/flutter_hooks.dart';
// import 'package:provider/provider.dart';
// import 'package:lottie/lottie.dart';

// import '../providers/auth_provider.dart';
// import '../providers/attendance_provider.dart';
// import '../models/attendance_record.dart';
// import '../widgets/attendance_status_card.dart';
// import 'qr_scanner_screen.dart';
// import 'login_screen.dart';

// class HomeScreen extends HookWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final selectedTabIndex = useState(0);
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;

//     final authProvider = Provider.of<AuthProvider>(context);
//     final attendanceProvider = Provider.of<AttendanceProvider>(context);

//     // This will ensure attendance data is loaded when the employee is authenticated
//     useEffect(() {
//       if (authProvider.currentEmployee != null) {
//         attendanceProvider.loadAttendanceData(authProvider.currentEmployee!.id);
//       }
//       return null;
//     }, [authProvider.currentEmployee]);

//     // Animation for scan result
//     final scanResultController = useAnimationController(
//       duration: const Duration(milliseconds: 800),
//     );

//     useEffect(() {
//       if (attendanceProvider.showScanResult) {
//         scanResultController.forward(from: 0.0);
//       } else {
//         scanResultController.reverse();
//       }
//       return null;
//     }, [attendanceProvider.showScanResult]);

//     final scanResultAnimation = CurvedAnimation(
//       parent: scanResultController,
//       curve: Curves.easeOutBack,
//     );

//     // Function to open QR scanner
//     void openQrScanner() async {
//       final result = await Navigator.push(
//         context,
//         PageRouteBuilder(
//           pageBuilder: (context, animation, secondaryAnimation) =>
//               const QrScannerScreen(),
//           transitionsBuilder: (context, animation, secondaryAnimation, child) {
//             const begin = Offset(0.0, 1.0);
//             const end = Offset.zero;
//             const curve = Curves.easeInOutCubic;

//             var tween =
//                 Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
//             var offsetAnimation = animation.drive(tween);

//             return SlideTransition(position: offsetAnimation, child: child);
//           },
//           transitionDuration: const Duration(milliseconds: 300),
//         ),
//       );

//       // Process QR scan result if available
//       if (result != null &&
//           result is String &&
//           authProvider.currentEmployee != null) {
//         await attendanceProvider.processQrScan(
//             result, authProvider.currentEmployee!.id);
//       }
//     }

//     // Function to sign out
//     void signOut() async {
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text('Sign Out'),
//           content: const Text('Are you sure you want to sign out?'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text(
//                 'Cancel',
//                 style: TextStyle(color: colorScheme.primary),
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 Navigator.pop(context);
//                 await authProvider.logout();
//                 if (context.mounted) {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => const LoginScreen()),
//                   );
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: colorScheme.primary,
//                 foregroundColor: colorScheme.onPrimary,
//               ),
//               child: const Text('Sign Out'),
//             ),
//           ],
//         ),
//       );
//     }

//     // Function to format date for display
//     String formatDate(DateTime date) {
//       final now = DateTime.now();
//       final today = DateTime(now.year, now.month, now.day);
//       final yesterday = DateTime(today.year, today.month, today.day - 1);

//       final recordDate = DateTime(date.year, date.month, date.day);

//       if (recordDate == today) {
//         return 'Today';
//       } else if (recordDate == yesterday) {
//         return 'Yesterday';
//       } else {
//         return '${date.day}/${date.month}/${date.year}';
//       }
//     }

//     // Get greeting based on time of day
//     String getGreeting() {
//       final hour = DateTime.now().hour;
//       if (hour < 12) {
//         return 'Good Morning';
//       } else if (hour < 17) {
//         return 'Good Afternoon';
//       } else {
//         return 'Good Evening';
//       }
//     }

//     // Content for Home tab
//     Widget buildHomeTab() {
//       final employee = authProvider.currentEmployee;

//       if (employee == null) {
//         return const Center(child: CircularProgressIndicator());
//       }

//       return RefreshIndicator(
//         onRefresh: () => attendanceProvider.loadAttendanceData(employee.id),
//         color: colorScheme.primary,
//         child: ListView(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//           children: [
//             // Greeting and profile
//             Row(
//               children: [
//                 CircleAvatar(
//                   radius: 30,
//                   backgroundColor: colorScheme.primary.withOpacity(0.2),
//                   backgroundImage: NetworkImage(employee.imageUrl),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         getGreeting(),
//                         style: theme.textTheme.titleMedium?.copyWith(
//                           color: colorScheme.onSurface.withOpacity(0.7),
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         employee.name,
//                         style: theme.textTheme.headlineSmall?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: signOut,
//                   icon: Icon(
//                     Icons.logout,
//                     color: colorScheme.primary,
//                   ),
//                   tooltip: 'Sign Out',
//                 ),
//               ],
//             ),

//             // Employee details
//             Container(
//               margin: const EdgeInsets.symmetric(vertical: 24),
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: colorScheme.surface,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 10,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.badge_outlined,
//                         color: colorScheme.primary,
//                         size: 20,
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Text(
//                           'Employee ID',
//                           style: theme.textTheme.bodyMedium?.copyWith(
//                             color: colorScheme.onSurface.withOpacity(0.7),
//                           ),
//                         ),
//                       ),
//                       Text(
//                         employee.id,
//                         style: theme.textTheme.titleSmall?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const Divider(height: 24),
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.work_outline,
//                         color: colorScheme.primary,
//                         size: 20,
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Text(
//                           'Department',
//                           style: theme.textTheme.bodyMedium?.copyWith(
//                             color: colorScheme.onSurface.withOpacity(0.7),
//                           ),
//                         ),
//                       ),
//                       Text(
//                         employee.department,
//                         style: theme.textTheme.titleSmall?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const Divider(height: 24),
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.person_outline,
//                         color: colorScheme.primary,
//                         size: 20,
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Text(
//                           'Position',
//                           style: theme.textTheme.bodyMedium?.copyWith(
//                             color: colorScheme.onSurface.withOpacity(0.7),
//                           ),
//                         ),
//                       ),
//                       Text(
//                         employee.position,
//                         style: theme.textTheme.titleSmall?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),

//             // Today's attendance
//             const Text(
//               'Today\'s Attendance',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),
//             AttendanceStatusCard(
//               record: attendanceProvider.todayRecord,
//               isLoading: attendanceProvider.isLoading,
//             ),
//             const SizedBox(height: 30),

//             // Scan button
//             SizedBox(
//               height: 55,
//               child: ElevatedButton.icon(
//                 onPressed: openQrScanner,
//                 icon: const Icon(Icons.qr_code_scanner),
//                 label: const Text('Scan QR Code'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: colorScheme.primary,
//                   foregroundColor: colorScheme.onPrimary,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   elevation: 0,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     // Content for History tab
//     Widget buildHistoryTab() {
//       final employee = authProvider.currentEmployee;

//       if (employee == null) {
//         return const Center(child: CircularProgressIndicator());
//       }

//       final recentRecords = attendanceProvider.recentRecords;

//       return RefreshIndicator(
//         onRefresh: () => attendanceProvider.loadAttendanceData(employee.id),
//         color: colorScheme.primary,
//         child: recentRecords.isEmpty
//             ? Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.history,
//                       size: 64,
//                       color: colorScheme.primary.withOpacity(0.5),
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       'No attendance records found',
//                       style: theme.textTheme.titleMedium?.copyWith(
//                         color: colorScheme.onSurface.withOpacity(0.7),
//                       ),
//                     ),
//                   ],
//                 ),
//               )
//             : ListView.builder(
//                 padding: const EdgeInsets.all(16),
//                 itemCount: recentRecords.length,
//                 itemBuilder: (context, index) {
//                   final record = recentRecords[index];
//                   return _buildAttendanceHistoryItem(
//                       record, theme, colorScheme);
//                 },
//               ),
//       );
//     }

//     return Scaffold(
//       body: Stack(
//         children: [
//           SafeArea(
//             child: Column(
//               children: [
//                 // Body content
//                 Expanded(
//                   child: IndexedStack(
//                     index: selectedTabIndex.value,
//                     children: [
//                       buildHomeTab(),
//                       buildHistoryTab(),
//                     ],
//                   ),
//                 ),

//                 // Bottom navigation
//                 Container(
//                   decoration: BoxDecoration(
//                     color: theme.scaffoldBackgroundColor,
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.05),
//                         blurRadius: 10,
//                         offset: const Offset(0, -5),
//                       ),
//                     ],
//                   ),
//                   child: Padding(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         _buildNavItem(
//                           icon: Icons.home_outlined,
//                           label: 'Home',
//                           isSelected: selectedTabIndex.value == 0,
//                           onTap: () => selectedTabIndex.value = 0,
//                           theme: theme,
//                         ),
//                         _buildNavItem(
//                           icon: Icons.history,
//                           label: 'History',
//                           isSelected: selectedTabIndex.value == 1,
//                           onTap: () => selectedTabIndex.value = 1,
//                           theme: theme,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Scan result overlay
//           ScaleTransition(
//             scale: scanResultAnimation,
//             child: FadeTransition(
//               opacity: scanResultAnimation,
//               child: SafeArea(
//                 child: Align(
//                   alignment: Alignment.topCenter,
//                   child: Padding(
//                     padding: const EdgeInsets.only(top: 24),
//                     child: Container(
//                       margin: const EdgeInsets.symmetric(horizontal: 24),
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 20, vertical: 16),
//                       decoration: BoxDecoration(
//                         color: attendanceProvider.scanSuccess
//                             ? Colors.green
//                             : Colors.red,
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: [
//                           BoxShadow(
//                             color: (attendanceProvider.scanSuccess
//                                     ? Colors.green
//                                     : Colors.red)
//                                 .withOpacity(0.3),
//                             blurRadius: 8,
//                             offset: const Offset(0, 4),
//                           ),
//                         ],
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(
//                             attendanceProvider.scanSuccess
//                                 ? Icons.check_circle
//                                 : Icons.error,
//                             color: Colors.white,
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Text(
//                               attendanceProvider.scanSuccess
//                                   ? attendanceProvider.todayRecord?.status ==
//                                           'checked-in'
//                                       ? 'Successfully checked in!'
//                                       : 'Successfully checked out!'
//                                   : attendanceProvider.error ?? 'Scan failed',
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                           IconButton(
//                             icon: const Icon(
//                               Icons.close,
//                               color: Colors.white,
//                               size: 20,
//                             ),
//                             onPressed: attendanceProvider.resetScanResult,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildNavItem({
//     required IconData icon,
//     required String label,
//     required bool isSelected,
//     required VoidCallback onTap,
//     required ThemeData theme,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(16),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//         decoration: BoxDecoration(
//           color: isSelected
//               ? theme.colorScheme.primary.withOpacity(0.1)
//               : Colors.transparent,
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               icon,
//               color: isSelected
//                   ? theme.colorScheme.primary
//                   : theme.colorScheme.onSurface.withOpacity(0.6),
//             ),
//             if (isSelected) ...[
//               const SizedBox(width: 8),
//               Text(
//                 label,
//                 style: TextStyle(
//                   color: theme.colorScheme.primary,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAttendanceHistoryItem(
//     AttendanceRecord record,
//     ThemeData theme,
//     ColorScheme colorScheme,
//   ) {
//     Color statusColor;
//     IconData statusIcon;
//     String statusText;

//     switch (record.status) {
//       case 'checked-in':
//         statusColor = colorScheme.primary;
//         statusIcon = Icons.login;
//         statusText = 'Checked In';
//         break;
//       case 'checked-out':
//         statusColor = colorScheme.secondary;
//         statusIcon = Icons.logout;
//         statusText = 'Checked Out';
//         break;
//       case 'absent':
//       default:
//         statusColor = colorScheme.error;
//         statusIcon = Icons.cancel_outlined;
//         statusText = 'Absent';
//         break;
//     }

//     final formattedDate = formatDate(record.checkInTime);
//     final checkInTime = record.status != 'absent'
//         ? '${record.checkInTime.hour.toString().padLeft(2, '0')}:${record.checkInTime.minute.toString().padLeft(2, '0')}'
//         : '--:--';
//     final checkOutTime = record.checkOutTime != null
//         ? '${record.checkOutTime!.hour.toString().padLeft(2, '0')}:${record.checkOutTime!.minute.toString().padLeft(2, '0')}'
//         : '--:--';

//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       decoration: BoxDecoration(
//         color: theme.cardColor,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header with date and status
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             decoration: BoxDecoration(
//               color: statusColor.withOpacity(0.1),
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(12),
//                 topRight: Radius.circular(12),
//               ),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   formattedDate,
//                   style: theme.textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: statusColor.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(
//                         statusIcon,
//                         size: 14,
//                         color: statusColor,
//                       ),
//                       const SizedBox(width: 4),
//                       Text(
//                         statusText,
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold,
//                           color: statusColor,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Time details
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Check-in',
//                         style: theme.textTheme.bodySmall?.copyWith(
//                           color: colorScheme.onSurface.withOpacity(0.6),
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.access_time,
//                             size: 16,
//                             color: record.status != 'absent'
//                                 ? colorScheme.primary
//                                 : colorScheme.outline,
//                           ),
//                           const SizedBox(width: 6),
//                           Text(
//                             checkInTime,
//                             style: theme.textTheme.titleMedium?.copyWith(
//                               fontWeight: FontWeight.bold,
//                               color: record.status != 'absent'
//                                   ? colorScheme.onSurface
//                                   : colorScheme.onSurface.withOpacity(0.4),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   height: 40,
//                   width: 1,
//                   color: colorScheme.outline.withOpacity(0.2),
//                 ),
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.only(left: 16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Check-out',
//                           style: theme.textTheme.bodySmall?.copyWith(
//                             color: colorScheme.onSurface.withOpacity(0.6),
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Row(
//                           children: [
//                             Icon(
//                               Icons.access_time,
//                               size: 16,
//                               color: record.checkOutTime != null
//                                   ? colorScheme.primary
//                                   : colorScheme.outline,
//                             ),
//                             const SizedBox(width: 6),
//                             Text(
//                               checkOutTime,
//                               style: theme.textTheme.titleMedium?.copyWith(
//                                 fontWeight: FontWeight.bold,
//                                 color: record.checkOutTime != null
//                                     ? colorScheme.onSurface
//                                     : colorScheme.onSurface.withOpacity(0.4),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String formatDate(DateTime date) {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final yesterday = DateTime(today.year, today.month, today.day - 1);

//     final recordDate = DateTime(date.year, date.month, date.day);

//     if (recordDate == today) {
//       return 'Today';
//     } else if (recordDate == yesterday) {
//       return 'Yesterday';
//     } else {
//       return '${date.day}/${date.month}/${date.year}';
//     }
//   }
// }

// ============
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

import '../providers/auth_provider.dart';
import '../providers/attendance_provider.dart';
import '../models/attendance_record.dart';
import '../models/leave_request.dart';
import '../widgets/attendance_status_card.dart';
import '../widgets/attendance_summary_card.dart';
import '../screens/qr_scanner_screen.dart';
import '../screens/login_screen.dart';
import '../screens/leave_request_screen.dart';

class HomeScreen extends HookWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedTabIndex = useState(0);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final authProvider = Provider.of<AuthProvider>(context);
    final attendanceProvider = Provider.of<AttendanceProvider>(context);

    // This will ensure attendance data is loaded when the employee is authenticated
    useEffect(() {
      if (authProvider.currentEmployee != null) {
        attendanceProvider.loadAttendanceData(authProvider.currentEmployee!.id);
        attendanceProvider.loadLeaveRequests(authProvider.currentEmployee!.id);
      }
      return null;
    }, [authProvider.currentEmployee]);

    // Animation for scan result
    final scanResultController = useAnimationController(
      duration: const Duration(milliseconds: 800),
    );

    useEffect(() {
      if (attendanceProvider.showScanResult) {
        scanResultController.forward(from: 0.0);
      } else {
        scanResultController.reverse();
      }
      return null;
    }, [attendanceProvider.showScanResult]);

    final scanResultAnimation = CurvedAnimation(
      parent: scanResultController,
      curve: Curves.easeOutBack,
    );

    // Function to open QR scanner
    void openQrScanner() async {
      final result = await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const QrScannerScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(position: offsetAnimation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );

      // Process QR scan result if available
      if (result != null &&
          result is String &&
          authProvider.currentEmployee != null) {
        await attendanceProvider.processQrScan(
            result, authProvider.currentEmployee!.id);
      }
    }

    // Function to sign out
    void signOut() async {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: colorScheme.primary),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: const Text('Sign Out'),
            ),
          ],
        ),
      );
    }

    // Get greeting based on time of day
    String getGreeting() {
      final hour = DateTime.now().hour;
      if (hour < 12) {
        return 'Good Morning';
      } else if (hour < 17) {
        return 'Good Afternoon';
      } else {
        return 'Good Evening';
      }
    }

    // Content for Home tab
    Widget buildHomeTab() {
      final employee = authProvider.currentEmployee;

      if (employee == null) {
        return const Center(child: CircularProgressIndicator());
      }

      return RefreshIndicator(
        onRefresh: () => attendanceProvider.loadAttendanceData(employee.id),
        color: colorScheme.primary,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Greeting and profile
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: colorScheme.primary.withOpacity(0.2),
                  backgroundImage: NetworkImage(employee.imageUrl),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getGreeting(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        employee.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: signOut,
                  icon: Icon(
                    Icons.logout,
                    color: colorScheme.primary,
                  ),
                  tooltip: 'Sign Out',
                ),
              ],
            ),

            // Employee details
            Container(
              margin: const EdgeInsets.symmetric(vertical: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
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
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.badge_outlined,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Employee ID',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ),
                      Text(
                        employee.id,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      Icon(
                        Icons.work_outline,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Department',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ),
                      Text(
                        employee.department,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Position',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ),
                      Text(
                        employee.position,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Monthly attendance summary
            const Text(
              'Monthly Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            AttendanceSummaryCard(
              records: attendanceProvider.recentRecords,
              isLoading: attendanceProvider.isLoading,
            ),
            const SizedBox(height: 24),

            // Today's attendance
            const Text(
              'Today\'s Attendance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            AttendanceStatusCard(
              record: attendanceProvider.todayRecord,
              isLoading: attendanceProvider.isLoading,
            ),
            const SizedBox(height: 30),

            // Scan button
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: openQrScanner,
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Scan QR Code'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LeaveRequestScreen(),
                        ),
                      );

                      if (result == true) {
                        // Reload leave requests if a new one was submitted
                        attendanceProvider.loadLeaveRequests(employee.id);
                      }
                    },
                    icon: const Icon(Icons.note_add),
                    label: const Text('Request Leave'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.secondary,
                      foregroundColor: colorScheme.onSecondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Content for History tab
    Widget buildHistoryTab() {
      final employee = authProvider.currentEmployee;

      if (employee == null) {
        return const Center(child: CircularProgressIndicator());
      }

      final recentRecords = attendanceProvider.recentRecords;

      return RefreshIndicator(
        onRefresh: () => attendanceProvider.loadAttendanceData(employee.id),
        color: colorScheme.primary,
        child: recentRecords.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      size: 64,
                      color: colorScheme.primary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No attendance records found',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: recentRecords.length,
                itemBuilder: (context, index) {
                  final record = recentRecords[index];
                  return _buildAttendanceHistoryItem(
                      record, theme, colorScheme);
                },
              ),
      );
    }

    // Content for Requests tab
    Widget buildRequestsTab() {
      final employee = authProvider.currentEmployee;

      if (employee == null) {
        return const Center(child: CircularProgressIndicator());
      }

      final leaveRequests = attendanceProvider.leaveRequests;

      return RefreshIndicator(
        onRefresh: () => attendanceProvider.loadLeaveRequests(employee.id),
        color: colorScheme.primary,
        child: Column(
          children: [
            // Header with new request button
            Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Leave Requests',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LeaveRequestScreen(),
                        ),
                      );

                      if (result == true) {
                        // Reload leave requests if a new one was submitted
                        attendanceProvider.loadLeaveRequests(employee.id);
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('New Request'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: leaveRequests.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.note_alt_outlined,
                            size: 64,
                            color: colorScheme.primary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No leave requests found',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create a new request by clicking the button above',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: leaveRequests.length,
                      itemBuilder: (context, index) {
                        final request = leaveRequests[index];
                        return _buildLeaveRequestItem(
                            request, theme, colorScheme);
                      },
                    ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Body content
                Expanded(
                  child: IndexedStack(
                    index: selectedTabIndex.value,
                    children: [
                      buildHomeTab(),
                      buildHistoryTab(),
                      buildRequestsTab(),
                    ],
                  ),
                ),

                // Bottom navigation
                Container(
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavItem(
                          icon: Icons.home_outlined,
                          label: 'Home',
                          isSelected: selectedTabIndex.value == 0,
                          onTap: () => selectedTabIndex.value = 0,
                          theme: theme,
                        ),
                        _buildNavItem(
                          icon: Icons.history,
                          label: 'History',
                          isSelected: selectedTabIndex.value == 1,
                          onTap: () => selectedTabIndex.value = 1,
                          theme: theme,
                        ),
                        _buildNavItem(
                          icon: Icons.request_page,
                          label: 'Requests',
                          isSelected: selectedTabIndex.value == 2,
                          onTap: () => selectedTabIndex.value = 2,
                          theme: theme,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scan result overlay
          ScaleTransition(
            scale: scanResultAnimation,
            child: FadeTransition(
              opacity: scanResultAnimation,
              child: SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: attendanceProvider.scanSuccess
                            ? Colors.green
                            : Colors.red,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: (attendanceProvider.scanSuccess
                                    ? Colors.green
                                    : Colors.red)
                                .withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            attendanceProvider.scanSuccess
                                ? Icons.check_circle
                                : Icons.error,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              attendanceProvider.scanSuccess
                                  ? attendanceProvider.todayRecord?.status ==
                                          'checked-in'
                                      ? 'Successfully checked in!'
                                      : 'Successfully checked out!'
                                  : attendanceProvider.error ?? 'Scan failed',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: attendanceProvider.resetScanResult,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceHistoryItem(
    AttendanceRecord record,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (record.status) {
      case 'checked-in':
        statusColor = colorScheme.primary;
        statusIcon = Icons.login;
        statusText = 'Checked In';
        break;
      case 'checked-out':
        statusColor = colorScheme.secondary;
        statusIcon = Icons.logout;
        statusText = 'Checked Out';
        break;
      case 'absent':
      default:
        statusColor = colorScheme.error;
        statusIcon = Icons.cancel_outlined;
        statusText = 'Absent';
        break;
    }

    final formattedDate = formatDate(record.checkInTime);
    final checkInTime = record.status != 'absent'
        ? '${record.checkInTime.hour.toString().padLeft(2, '0')}:${record.checkInTime.minute.toString().padLeft(2, '0')}'
        : '--:--';
    final checkOutTime = record.checkOutTime != null
        ? '${record.checkOutTime!.hour.toString().padLeft(2, '0')}:${record.checkOutTime!.minute.toString().padLeft(2, '0')}'
        : '--:--';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with date and status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusIcon,
                        size: 14,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Time details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Check-in',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: record.status != 'absent'
                                ? colorScheme.primary
                                : colorScheme.outline,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            checkInTime,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: record.status != 'absent'
                                  ? colorScheme.onSurface
                                  : colorScheme.onSurface.withOpacity(0.4),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: colorScheme.outline.withOpacity(0.2),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Check-out',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: record.checkOutTime != null
                                  ? colorScheme.primary
                                  : colorScheme.outline,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              checkOutTime,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: record.checkOutTime != null
                                    ? colorScheme.onSurface
                                    : colorScheme.onSurface.withOpacity(0.4),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveRequestItem(
    LeaveRequest request,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    dateFormat(DateTime date) => '${date.day}/${date.month}/${date.year}';

    // Determine status color and icon
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (request.status) {
      case 'approved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Approved';
        break;
      case 'rejected':
        statusColor = colorScheme.error;
        statusIcon = Icons.cancel;
        statusText = 'Rejected';
        break;
      case 'pending':
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        statusText = 'Pending';
        break;
    }

    // Determine leave type icon
    IconData typeIcon;
    switch (request.type) {
      case 'sick':
        typeIcon = Icons.healing;
        break;
      case 'vacation':
        typeIcon = Icons.beach_access;
        break;
      case 'personal':
        typeIcon = Icons.person;
        break;
      case 'other':
      default:
        typeIcon = Icons.more_horiz;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with request type and status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(typeIcon, size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${request.type.substring(0, 1).toUpperCase()}${request.type.substring(1)} Leave',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusIcon,
                        size: 14,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Request details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date information
                Row(
                  children: [
                    Expanded(
                      child: _buildLeaveInfoItem(
                        label: 'From',
                        value: dateFormat(request.startDate),
                        icon: Icons.calendar_today,
                        theme: theme,
                        colorScheme: colorScheme,
                      ),
                    ),
                    Container(
                      height: 40,
                      width: 1,
                      color: colorScheme.outline.withOpacity(0.2),
                    ),
                    Expanded(
                      child: _buildLeaveInfoItem(
                        label: 'To',
                        value: dateFormat(request.endDate),
                        icon: Icons.calendar_today,
                        theme: theme,
                        colorScheme: colorScheme,
                      ),
                    ),
                  ],
                ),

                const Divider(height: 24),

                // Reason
                Text(
                  'Reason',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  request.reason,
                  style: theme.textTheme.bodyMedium,
                ),

                const SizedBox(height: 16),

                // Request date information
                Text(
                  'Requested on ${dateFormat(request.requestDate)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveInfoItem({
    required String label,
    required String value,
    required IconData icon,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(today.year, today.month, today.day - 1);

    final recordDate = DateTime(date.year, date.month, date.day);

    if (recordDate == today) {
      return 'Today';
    } else if (recordDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
