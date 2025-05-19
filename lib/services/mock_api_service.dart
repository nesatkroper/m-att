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


====
  import 'dart:math';
import 'package:uuid/uuid.dart';
import '../models/employee.dart';
import '../models/attendance_record.dart';
import '../models/leave_request.dart';

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
      _attendanceRecords[employee.id] = [];
      _leaveRequests[employee.id] = [];
      
      // Create records for the last 7 days
      for (int i = 6; i >= 0; i--) {
        final date = DateTime.now().subtract(Duration(days: i));
        
        // For demo purposes, create some variety in attendance patterns
        if (random.nextDouble() > 0.2) { // 80% attendance rate
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
      
      // Generate sample leave requests
      _initializeSampleLeaveRequests(employee.id);
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
      (record) => record.checkInTime.year == todayDate.year &&
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
  Future<List<AttendanceRecord>> getRecentAttendanceRecords(String employeeId) async {
    if (!_attendanceRecords.containsKey(employeeId)) {
      return [];
    }
    
    return _attendanceRecords[employeeId]!;
  }

  // Process attendance scan
  Future<AttendanceRecord?> processAttendanceScan(String qrData, String employeeId) async {
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
          (record) => record.checkInTime.year == today.year &&
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
        id: uuid.v4(),
        employeeId: employeeId,
        type: leaveTypes[random.nextInt(leaveTypes.length)],
        startDate: startDate,
        endDate: endDate,
        reason: _generateRandomReason(leaveTypes[random.nextInt(leaveTypes.length)]),
        status: statuses[random.nextInt(statuses.length)],
        requestDate: requestDate,
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
    requests.sort((a, b) => b.requestDate.compareTo(a.requestDate));
    
    return requests;
  }

  // Submit a new leave request
  Future<LeaveRequest?> submitLeaveRequest({
    required String employeeId,
    required String type,
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
      id: uuid.v4(),
      employeeId: employeeId,
      type: type,
      startDate: startDate,
      endDate: endDate,
      reason: reason,
      status: 'pending', // All new requests start as pending
      requestDate: now,
    );
    
    // Update in mock database
    if (_leaveRequests.containsKey(employeeId)) {
      _leaveRequests[employeeId]!.add(newRequest);
    } else {
      _leaveRequests[employeeId] = [newRequest];
    }
    
    return newRequest;
  }
}
