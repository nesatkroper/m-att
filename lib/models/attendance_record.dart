
import 'package:attendance/models/enum.dart';

class AttendanceRecord {
  final String attendanceId;
  final String employeeId;
  final String eventId;
  final DateTime checkIn;
  final DateTime? checkOut;
  final String? method;
  final String? note;
  final CheckStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  AttendanceRecord({
    required this.attendanceId,
    required this.employeeId,
    required this.eventId,
    required this.checkIn,
    this.checkOut,
    this.method,
    this.note,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Computed property to get duration between check-in & check-out
  Duration? get duration {
    if (checkOut == null) return null;
    return checkOut!.difference(checkIn);
  }

  /// Factory constructor for JSON deserialization
  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      attendanceId: json['attendanceId'] as String,
      employeeId: json['employeeId'] as String,
      eventId: json['eventId'] as String,
      checkIn: DateTime.parse(json['checkIn'] as String),
      checkOut: json['checkOut'] != null ? DateTime.parse(json['checkOut'] as String) : null,
      method: json['method'] as String?,
      note: json['note'] as String?,
      status: json['status'] as CheckStatus,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['datetime'] as String),
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'attendanceId': attendanceId,
      'employeeId': employeeId,
      'eventId': eventId,
      'checkIn': checkIn.toIso8601String(),
      'checkOut': checkOut?.toIso8601String(),
      'method': method,
      'note': note,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'datetime': updatedAt.toIso8601String(),
    };
  }

  /// For immutable updates
  AttendanceRecord copyWith({
    String? attendanceId,
    String? employeeId,
    String? eventId,
    DateTime? checkIn,
    DateTime? checkOut,
    String? method,
    String? note,
    CheckStatus? status,
    DateTime? createdAt,
    DateTime? datetime,
  }) {
    return AttendanceRecord(
      attendanceId: attendanceId ?? this.attendanceId,
      employeeId: employeeId ?? this.employeeId,
      eventId: eventId ?? this.eventId,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      method: method ?? this.method,
      note: note ?? this.note,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: datetime ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'AttendanceRecord(attendanceId: $attendanceId, employeeId: $employeeId, checkIn: $checkIn, checkOut: $checkOut, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AttendanceRecord && other.attendanceId == attendanceId;
  }

  @override
  int get hashCode => attendanceId.hashCode;
}



// class AttendanceRecord {
//   final String id;
//   final String employeeId;
//   final DateTime checkInTime;
//   final DateTime? checkOutTime;
//   final String status; // "checked-in", "checked-out", "absent"

//   AttendanceRecord({
//     required this.id,
//     required this.employeeId,
//     required this.checkInTime,
//     this.checkOutTime,
//     required this.status,
//   });

//   factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
//     return AttendanceRecord(
//       id: json['id'] as String,
//       employeeId: json['employeeId'] as String,
//       checkInTime: DateTime.parse(json['checkInTime'] as String),
//       checkOutTime: json['checkOutTime'] != null
//           ? DateTime.parse(json['checkOutTime'] as String)
//           : null,
//       status: json['status'] as String,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'employeeId': employeeId,
//       'checkInTime': checkInTime.toIso8601String(),
//       'checkOutTime': checkOutTime?.toIso8601String(),
//       'status': status,
//     };
//   }

//   AttendanceRecord copyWith({
//     String? id,
//     String? employeeId,
//     DateTime? checkInTime,
//     DateTime? checkOutTime,
//     String? status,
//   }) {
//     return AttendanceRecord(
//       id: id ?? this.id,
//       employeeId: employeeId ?? this.employeeId,
//       checkInTime: checkInTime ?? this.checkInTime,
//       checkOutTime: checkOutTime ?? this.checkOutTime,
//       status: status ?? this.status,
//     );
//   }
// }
