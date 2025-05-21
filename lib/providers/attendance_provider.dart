import 'package:flutter/foundation.dart';
import '../models/attendance_record.dart';
import '../models/leave_request.dart';
import '../services/mock_api_service.dart';

class AttendanceProvider with ChangeNotifier {
  AttendanceRecord? _todayRecord;
  List<AttendanceRecord> _recentRecords = [];
  List<LeaveRequest> _leaveRequests = [];
  bool _isLoading = false;
  String? _error;
  bool _scanSuccess = false;
  bool _showScanResult = false;

  AttendanceRecord? get todayRecord => _todayRecord;
  List<AttendanceRecord> get recentRecords => _recentRecords;
  List<LeaveRequest> get leaveRequests => _leaveRequests;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get scanSuccess => _scanSuccess;
  bool get showScanResult => _showScanResult;

  final MockApiService _apiService = MockApiService();

  Future<void> loadAttendanceData(String employeeId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Get today's attendance record
      _todayRecord = await _apiService.getTodayAttendanceRecord(employeeId);

      // Get recent attendance history (last 7 days)
      _recentRecords = await _apiService.getRecentAttendanceRecords(employeeId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load attendance data: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> processQrScan(String qrData, String employeeId) async {
    _isLoading = true;
    _showScanResult = false;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Process QR scan with mock API
      final result =
          await _apiService.processAttendanceScan(qrData, employeeId);

      if (result != null) {
        _todayRecord = result;
        _scanSuccess = true;
      } else {
        _scanSuccess = false;
        _error = 'Invalid QR code';
      }

      // Reload recent records after successful scan
      if (_scanSuccess) {
        _recentRecords =
            await _apiService.getRecentAttendanceRecords(employeeId);
      }

      _isLoading = false;
      _showScanResult = true;
      notifyListeners();

      // Hide result after a delay
      await Future.delayed(const Duration(seconds: 3));
      _showScanResult = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to process scan: ${e.toString()}';
      _scanSuccess = false;
      _isLoading = false;
      _showScanResult = true;
      notifyListeners();

      // Hide error after a delay
      await Future.delayed(const Duration(seconds: 3));
      _showScanResult = false;
      notifyListeners();
    }
  }

  void resetScanResult() {
    _showScanResult = false;
    notifyListeners();
  }

  Future<void> loadLeaveRequests(String employeeId) async {
    try {
      _leaveRequests = await _apiService.getLeaveRequests(employeeId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load leave requests: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> submitLeaveRequest({
    required String employeeId,
    required String type,
    required String reason,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 800));

      final newRequest = await _apiService.submitLeaveRequest(
        employeeId: employeeId,
        type: type,
        reason: reason,
        startDate: startDate,
        endDate: endDate,
      );

      if (newRequest != null) {
        _leaveRequests.add(newRequest);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to submit leave request: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      rethrow; // Re-throw to be caught by the UI
    }
  }

  // Calculate attendance statistics for the current month
  Map<String, int> getMonthlyAttendanceStats() {
    final stats = {
      'present': 0,
      'earlyOut': 0,
      'absent': 0,
      'leave': 0,
    };

    // Get current month records
    final now = DateTime.now();
    final monthRecords = _recentRecords
        .where((record) =>
            record.checkInTime.year == now.year &&
            record.checkInTime.month == now.month)
        .toList();

    for (var record in monthRecords) {
      if (record.status == 'absent') {
        stats['absent'] = (stats['absent'] ?? 0) + 1;
      } else if (record.status == 'checked-out') {
        stats['present'] = (stats['present'] ?? 0) + 1;
      } else if (record.status == 'checked-in') {
        stats['earlyOut'] = (stats['earlyOut'] ?? 0) + 1;
      }
    }

    // Also count approved leave days
    final approvedLeaves = _leaveRequests
        .where((leave) =>
            leave.status == 'approved' &&
            ((leave.startDate.year == now.year &&
                    leave.startDate.month == now.month) ||
                (leave.endDate.year == now.year &&
                    leave.endDate.month == now.month)))
        .toList();

    for (var leave in approvedLeaves) {
      // Count number of days in the current month that are on leave
      final start = leave.startDate;
      final end = leave.endDate;

      for (var day = start;
          !day.isAfter(end);
          day = day.add(const Duration(days: 1))) {
        if (day.month == now.month && day.year == now.year) {
          stats['leave'] = (stats['leave'] ?? 0) + 1;
        }
      }
    }

    return stats;
  }
}
