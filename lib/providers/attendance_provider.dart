import 'package:flutter/foundation.dart';
import '../models/attendance_record.dart';
import '../services/mock_api_service.dart';

class AttendanceProvider with ChangeNotifier {
  AttendanceRecord? _todayRecord;
  List<AttendanceRecord> _recentRecords = [];
  bool _isLoading = false;
  String? _error;
  bool _scanSuccess = false;
  bool _showScanResult = false;

  AttendanceRecord? get todayRecord => _todayRecord;
  List<AttendanceRecord> get recentRecords => _recentRecords;
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
}
