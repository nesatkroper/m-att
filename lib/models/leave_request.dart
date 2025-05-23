import 'package:attendance/models/enum.dart';

class LeaveRequest {
  final String leaveId;
  final String employeeId;
  final LeaveType leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final String? reason;
  final LeaveStatus status;
  final String? approvedById;
  final DateTime? approvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  LeaveRequest({
    required this.leaveId,
    required this.employeeId,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    this.reason,
    required this.status,
    this.approvedById,
    this.approvedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  // Calculated property
  int get durationInDays => endDate.difference(startDate).inDays + 1;

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      leaveId: json['leaveId'] as String,
      employeeId: json['employeeId'] as String,
      leaveType: LeaveType.values.firstWhere(
        (e) => e.name == json['leaveType'],
        orElse: () => LeaveType.other,
      ),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      reason: json['reason'] as String?,
      status: LeaveStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => LeaveStatus.pending,
      ),
      approvedById: json['approvedById'] as String?,
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'leaveId': leaveId,
      'employeeId': employeeId,
      'leaveType': leaveType.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'reason': reason,
      'status': status.name,
      'approvedById': approvedById,
      'approvedAt': approvedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  LeaveRequest copyWith({
    String? leaveId,
    String? employeeId,
    LeaveType? leaveType,
    DateTime? startDate,
    DateTime? endDate,
    String? reason,
    LeaveStatus? status,
    String? approvedById,
    DateTime? approvedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LeaveRequest(
      leaveId: leaveId ?? this.leaveId,
      employeeId: employeeId ?? this.employeeId,
      leaveType: leaveType ?? this.leaveType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      approvedById: approvedById ?? this.approvedById,
      approvedAt: approvedAt ?? this.approvedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'LeaveRequest(leaveId: $leaveId, type: ${leaveType.name}, status: ${status.name}, days: $durationInDays)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LeaveRequest && other.leaveId == leaveId;
  }

  @override
  int get hashCode => leaveId.hashCode;
}

// class LeaveRequest {
//   final String id;
//   final String employeeId;
//   final String type; // 'sick', 'vacation', 'personal', 'other'
//   final DateTime startDate;
//   final DateTime endDate;
//   final String reason;
//   final String status; // 'pending', 'approved', 'rejected'
//   final DateTime requestDate;

//   LeaveRequest({
//     required this.id,
//     required this.employeeId,
//     required this.type,
//     required this.startDate,
//     required this.endDate,
//     required this.reason,
//     required this.status,
//     required this.requestDate,
//   });

//   factory LeaveRequest.fromJson(Map<String, dynamic> json) {
//     return LeaveRequest(
//       id: json['id'],
//       employeeId: json['employeeId'],
//       type: json['type'],
//       startDate: DateTime.parse(json['startDate']),
//       endDate: DateTime.parse(json['endDate']),
//       reason: json['reason'],
//       status: json['status'],
//       requestDate: DateTime.parse(json['requestDate']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'employeeId': employeeId,
//       'type': type,
//       'startDate': startDate.toIso8601String(),
//       'endDate': endDate.toIso8601String(),
//       'reason': reason,
//       'status': status,
//       'requestDate': requestDate.toIso8601String(),
//     };
//   }

//   LeaveRequest copyWith({
//     String? id,
//     String? employeeId,
//     String? type,
//     DateTime? startDate,
//     DateTime? endDate,
//     String? reason,
//     String? status,
//     DateTime? requestDate,
//   }) {
//     return LeaveRequest(
//       id: id ?? this.id,
//       employeeId: employeeId ?? this.employeeId,
//       type: type ?? this.type,
//       startDate: startDate ?? this.startDate,
//       endDate: endDate ?? this.endDate,
//       reason: reason ?? this.reason,
//       status: status ?? this.status,
//       requestDate: requestDate ?? this.requestDate,
//     );
//   }
// }
