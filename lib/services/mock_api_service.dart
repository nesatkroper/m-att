import 'dart:math';
import 'package:attendance/models/enum.dart';
import 'package:uuid/uuid.dart';
import 'package:attendance/models/employee.dart';
import 'package:attendance/models/attendance_record.dart';
import 'package:attendance/models/leave_request.dart';

class MockApiService {
  // Sample employee data
  final List<Employee> _employees = [
    Employee(
      employeeId: '550e8400-e29b-41d4-a716-446655440001',
      employeeCode: 'EMP001',
      firstName: 'Suong',
      lastName: 'Phanun',
      gender: Gender.male,
      dob: DateTime(1990, 5, 15),
      phone: '+1234567890',
      positionId: 'pos001',
      departmentId: 'dept001',
      salary: 7500.00,
      hiredDate: DateTime(2020, 3, 10),
      status: Status.active,
      createdAt: DateTime(2020, 3, 10),
      updatedAt: DateTime.now(),
      picture:
          'https://raw.githubusercontent.com/nesatkroper/img/refs/heads/main/phanunLogo.webp',
    ),
    Employee(
      employeeId: '550e8400-e29b-41d4-a716-446655440002',
      employeeCode: 'EMP002',
      firstName: 'Jane',
      lastName: 'Smith',
      gender: Gender.female,
      dob: DateTime(1988, 8, 22),
      phone: '+1987654321',
      positionId: 'pos002',
      departmentId: 'dept002',
      salary: 6800.50,
      hiredDate: DateTime(2019, 7, 15),
      status: Status.active,
      createdAt: DateTime(2019, 7, 15),
      updatedAt: DateTime.now(),
      picture: 'https://randomuser.me/api/portraits/women/44.jpg',
    ),
    Employee(
      employeeId: '550e8400-e29b-41d4-a716-446655440003',
      employeeCode: 'EMP003',
      firstName: 'Robert',
      lastName: 'Johnson',
      gender: Gender.male,
      dob: DateTime(1985, 11, 5),
      phone: '+1122334455',
      positionId: 'pos003',
      departmentId: 'dept003',
      salary: 9200.75,
      hiredDate: DateTime(2018, 1, 20),
      status: Status.active,
      createdAt: DateTime(2018, 1, 20),
      updatedAt: DateTime.now(),
      picture: 'https://randomuser.me/api/portraits/men/46.jpg',
    ),
    Employee(
      employeeId: '550e8400-e29b-41d4-a716-446655440004',
      employeeCode: 'EMP004',
      firstName: 'Emily',
      lastName: 'Williams',
      gender: Gender.female,
      dob: DateTime(1992, 4, 30),
      phone: '+1555666777',
      positionId: 'pos004',
      departmentId: 'dept001',
      salary: 6200.00,
      hiredDate: DateTime(2021, 9, 5),
      status: Status.active,
      createdAt: DateTime(2021, 9, 5),
      updatedAt: DateTime.now(),
      picture: 'https://randomuser.me/api/portraits/women/63.jpg',
    ),
    Employee(
      employeeId: '550e8400-e29b-41d4-a716-446655440005',
      employeeCode: 'EMP005',
      firstName: 'Michael',
      lastName: 'Brown',
      gender: Gender.male,
      dob: DateTime(1987, 7, 12),
      phone: '+1444333222',
      positionId: 'pos005',
      departmentId: 'dept002',
      salary: 8500.25,
      hiredDate: DateTime(2022, 2, 18),
      status: Status.inactive,
      createdAt: DateTime(2022, 2, 18),
      updatedAt: DateTime.now(),
      picture: 'https://randomuser.me/api/portraits/men/71.jpg',
    ),
  ];
  // Sample attendance records
  final Map<String, List<AttendanceRecord>> _attendanceRecords = {};

  // Sample leave requests
  final Map<String, List<LeaveRequest>> _leaveRequests = {};

  // Constructor to initialize sample data
  MockApiService() {
    _initializeSampleData();
  }

  void _initializeSampleData() {
    final uuid = Uuid();
    final random = Random();

    // Generate sample attendance records for the past 7 days
    for (final employee in _employees) {
      _attendanceRecords[employee.employeeId] = [];
      _leaveRequests[employee.employeeId] = [];

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

          _attendanceRecords[employee.employeeId]!.add(
            AttendanceRecord(
                attendanceId: uuid.v4(),
                employeeId: employee.employeeId,
                eventId: "",
                checkIn: checkInTime,
                checkOut: checkOutTime,
                method: "",
                note: "",
                status:
                    hasCheckedOut ? CheckStatus.checkin : CheckStatus.checkout,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now()),
          );
        } else {
          _attendanceRecords[employee.employeeId]!.add(
            AttendanceRecord(
                attendanceId: uuid.v4(),
                employeeId: employee.employeeId,
                eventId: "",
                checkIn: DateTime(date.year, date.month, date.day),
                checkOut: null,
                method: "",
                note: "",
                status: CheckStatus.checkout,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now()),
          );
        }
      }

      // Generate sample leave requests
      _initializeSampleLeaveRequests(employee.employeeId);
    }
  }

  // Simulate login API
  Future<Employee?> login(String employeeId, String password) async {
    // For demo, accept any password but require valid employee ID
    final employee = _employees.firstWhere(
      (emp) => emp.employeeId == employeeId,
      orElse: () => Employee(
        employeeId: '',
        employeeCode: '',
        firstName: '',
        lastName: '',
        gender: Gender.other,
        dob: DateTime(1987, 7, 12),
        phone: '',
        positionId: '',
        departmentId: '',
        salary: 0,
        hiredDate: DateTime(2022, 2, 18),
        status: Status.inactive,
        createdAt: DateTime(2022, 2, 18),
        updatedAt: DateTime.now(),
        picture: '',
      ),
    );

    if (employee.employeeId.isEmpty) {
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
          record.checkIn.year == todayDate.year &&
          record.checkIn.month == todayDate.month &&
          record.checkIn.day == todayDate.day,
      orElse: () => AttendanceRecord(
        attendanceId: Uuid().v4(),
        employeeId: employeeId,
        eventId: '',
        checkIn: todayDate,
        status: CheckStatus.checkout,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
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
        attendanceId: uuid.v4(),
        employeeId: employeeId,
        eventId: '',
        checkIn: today,
        status: CheckStatus.checkin,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Update in the mock database
      if (_attendanceRecords.containsKey(employeeId)) {
        _attendanceRecords[employeeId]!.removeWhere(
          (record) =>
              record.checkIn.year == today.year &&
              record.checkIn.month == today.month &&
              record.checkIn.day == today.day,
        );
        _attendanceRecords[employeeId]!.add(newRecord);
      } else {
        _attendanceRecords[employeeId] = [newRecord];
      }

      return newRecord;
    } else if (existingRecord.status == 'checked-in') {
      // Update to checked-out
      final updatedRecord = existingRecord.copyWith(
        checkOut: today,
        status: CheckStatus.checkin,
      );

      // Update in the mock database
      final index = _attendanceRecords[employeeId]!.indexWhere(
        (record) => record.attendanceId == existingRecord.attendanceId,
      );

      if (index != -1) {
        _attendanceRecords[employeeId]![index] = updatedRecord;
      }

      return updatedRecord;
    }

    // Already checked out
    return existingRecord;
  }

  // Initialize sample leave requests
  void _initializeSampleLeaveRequests(String employeeId) {
    final uuid = Uuid();
    final random = Random();
    final leaveTypes = ['sick', 'vacation', 'personal', 'other'];
    final statuses = ['pending', 'approved', 'rejected'];

    // Generate between 0-3 leave requests
    final requestCount = random.nextInt(4);

    for (int i = 0; i < requestCount; i++) {
      final now = DateTime.now();
      final requestDate = now.subtract(Duration(days: random.nextInt(30)));

      // Create a start date in the next 15 days
      final startDate = now.add(Duration(days: random.nextInt(15) + 1));

      // Create an end date 1-5 days after start date
      final endDate = startDate.add(Duration(days: random.nextInt(5) + 1));

      // Create a leave request
      final leaveRequest = LeaveRequest(
        leaveId: uuid.v4(),
        employeeId: employeeId,
        leaveType: LeaveType.annual,
        startDate: startDate,
        endDate: endDate,
        reason: _generateRandomReason(
            leaveTypes[random.nextInt(leaveTypes.length)]),
        status: LeaveStatus.pending,
        createdAt: requestDate,
        updatedAt: now,
      );

      _leaveRequests[employeeId]!.add(leaveRequest);
    }
  }

  // Generate a random reason for leave
  String _generateRandomReason(String type) {
    final sickReasons = [
      'I have a fever and need to rest.',
      'Doctor recommended bed rest for a few days.',
      'Recovering from a minor surgery.',
      'Not feeling well enough to work effectively.',
    ];

    final vacationReasons = [
      'Planning a family trip.',
      'Need some time off to recharge.',
      'Visiting relatives in another city.',
      'Taking a short break before the next project phase.',
    ];

    final personalReasons = [
      'Need to attend a family function.',
      'Have some personal matters to attend to.',
      'Need time to handle personal responsibilities.',
      'Family emergency requires my attention.',
    ];

    final otherReasons = [
      'Need to attend a training program.',
      'Going for a conference related to work.',
      'Need to process some important documents.',
      'Have an important appointment to attend.',
    ];

    final random = Random();

    switch (type) {
      case 'sick':
        return sickReasons[random.nextInt(sickReasons.length)];
      case 'vacation':
        return vacationReasons[random.nextInt(vacationReasons.length)];
      case 'personal':
        return personalReasons[random.nextInt(personalReasons.length)];
      case 'other':
      default:
        return otherReasons[random.nextInt(otherReasons.length)];
    }
  }

  // Get leave requests for an employee
  Future<List<LeaveRequest>> getLeaveRequests(String employeeId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));

    if (!_leaveRequests.containsKey(employeeId)) {
      return [];
    }

    // Sort by request date (newest first)
    final requests = List<LeaveRequest>.from(_leaveRequests[employeeId]!);
    requests.sort((a, b) => b.createdAt.compareTo(a.approvedAt ?? a.createdAt));

    return requests;
  }

  // Submit a new leave request
  Future<LeaveRequest?> submitLeaveRequest({
    required String employeeId,
    required LeaveType type,
    required String reason,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 1000));

    final uuid = Uuid();
    final now = DateTime.now();

    // Create a new leave request
    final newRequest = LeaveRequest(
        leaveId: uuid.v4(),
        employeeId: employeeId,
        leaveType: type,
        startDate: startDate,
        endDate: endDate,
        reason: reason,
        status: LeaveStatus.approved, // All new requests start as pending
        createdAt: now,
        updatedAt: now);

    // Update in mock database
    if (_leaveRequests.containsKey(employeeId)) {
      _leaveRequests[employeeId]!.add(newRequest);
    } else {
      _leaveRequests[employeeId] = [newRequest];
    }

    return newRequest;
  }
}
