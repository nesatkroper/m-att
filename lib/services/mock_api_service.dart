import 'dart:math';
import 'package:uuid/uuid.dart';
import '../models/employee.dart';
import '../models/attendance_record.dart';

class MockApiService {
  // Sample employee data
  final List<Employee> _employees = [
    Employee(
      id: 'EMP001',
      name: 'John Doe',
      department: 'Engineering',
      position: 'Senior Developer',
      imageUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
    ),
    Employee(
      id: 'EMP002',
      name: 'Jane Smith',
      department: 'Design',
      position: 'UI/UX Designer',
      imageUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
    ),
    Employee(
      id: 'EMP003',
      name: 'Robert Johnson',
      department: 'Marketing',
      position: 'Marketing Manager',
      imageUrl: 'https://randomuser.me/api/portraits/men/46.jpg',
    ),
  ];

  // Sample attendance records
  final Map<String, List<AttendanceRecord>> _attendanceRecords = {};

  // Constructor to initialize sample data
  MockApiService() {
    _initializeSampleData();
  }

  void _initializeSampleData() {
    final uuid = Uuid();
    final random = Random();

    // Generate sample attendance records for the past 7 days
    for (final employee in _employees) {
      _attendanceRecords[employee.id] = [];

      // Create records for the last 7 days
      for (int i = 6; i >= 0; i--) {
        final date = DateTime.now().subtract(Duration(days: i));

        // For demo purposes, create some variety in attendance patterns
        if (random.nextDouble() > 0.2) {
          // 80% attendance rate
          final checkInTime = DateTime(
            date.year,
            date.month,
            date.day,
            8 + random.nextInt(2), // Between 8-10 AM
            random.nextInt(60),
          );

          final hasCheckedOut = i != 0 || random.nextDouble() > 0.5;

          final checkOutTime = hasCheckedOut
              ? DateTime(
                  date.year,
                  date.month,
                  date.day,
                  16 + random.nextInt(3), // Between 4-7 PM
                  random.nextInt(60),
                )
              : null;

          _attendanceRecords[employee.id]!.add(
            AttendanceRecord(
              id: uuid.v4(),
              employeeId: employee.id,
              checkInTime: checkInTime,
              checkOutTime: checkOutTime,
              status: hasCheckedOut ? 'checked-out' : 'checked-in',
            ),
          );
        } else {
          // Absent record
          _attendanceRecords[employee.id]!.add(
            AttendanceRecord(
              id: uuid.v4(),
              employeeId: employee.id,
              checkInTime: DateTime(date.year, date.month, date.day),
              checkOutTime: null,
              status: 'absent',
            ),
          );
        }
      }
    }
  }

  // Simulate login API
  Future<Employee?> login(String employeeId, String password) async {
    // For demo, accept any password but require valid employee ID
    final employee = _employees.firstWhere(
      (emp) => emp.id == employeeId,
      orElse: () => Employee(
        id: '',
        name: '',
        department: '',
        position: '',
        imageUrl: '',
      ),
    );

    if (employee.id.isEmpty) {
      return null; // Employee not found
    }

    // Simulate successful login
    return employee;
  }

  // Simulate token validation
  Future<bool> validateToken() async {
    // For demo, always return true
    return true;
  }

  // Get current employee info
  Future<Employee> getCurrentEmployeeInfo() async {
    // For demo, return the first employee
    return _employees.first;
  }

  // Get today's attendance record
  Future<AttendanceRecord?> getTodayAttendanceRecord(String employeeId) async {
    if (!_attendanceRecords.containsKey(employeeId)) {
      return null;
    }

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final record = _attendanceRecords[employeeId]!.lastWhere(
      (record) =>
          record.checkInTime.year == todayDate.year &&
          record.checkInTime.month == todayDate.month &&
          record.checkInTime.day == todayDate.day,
      orElse: () => AttendanceRecord(
        id: Uuid().v4(),
        employeeId: employeeId,
        checkInTime: todayDate,
        status: 'absent',
      ),
    );

    return record;
  }

  // Get recent attendance records
  Future<List<AttendanceRecord>> getRecentAttendanceRecords(
      String employeeId) async {
    if (!_attendanceRecords.containsKey(employeeId)) {
      return [];
    }

    return _attendanceRecords[employeeId]!;
  }

  // Process attendance scan
  Future<AttendanceRecord?> processAttendanceScan(
      String qrData, String employeeId) async {
    // For demo purposes, any QR code with 'attendance:' prefix is valid
    if (!qrData.startsWith('attendance:')) {
      return null;
    }

    final uuid = Uuid();
    final today = DateTime.now();

    // Get today's record if exists
    final existingRecord = await getTodayAttendanceRecord(employeeId);

    if (existingRecord?.status == 'absent' || existingRecord == null) {
      // Create a check-in record
      final newRecord = AttendanceRecord(
        id: uuid.v4(),
        employeeId: employeeId,
        checkInTime: today,
        status: 'checked-in',
      );

      // Update in the mock database
      if (_attendanceRecords.containsKey(employeeId)) {
        _attendanceRecords[employeeId]!.removeWhere(
          (record) =>
              record.checkInTime.year == today.year &&
              record.checkInTime.month == today.month &&
              record.checkInTime.day == today.day,
        );
        _attendanceRecords[employeeId]!.add(newRecord);
      } else {
        _attendanceRecords[employeeId] = [newRecord];
      }

      return newRecord;
    } else if (existingRecord.status == 'checked-in') {
      // Update to checked-out
      final updatedRecord = existingRecord.copyWith(
        checkOutTime: today,
        status: 'checked-out',
      );

      // Update in the mock database
      final index = _attendanceRecords[employeeId]!.indexWhere(
        (record) => record.id == existingRecord.id,
      );

      if (index != -1) {
        _attendanceRecords[employeeId]![index] = updatedRecord;
      }

      return updatedRecord;
    }

    // Already checked out
    return existingRecord;
  }
}
