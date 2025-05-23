import 'package:attendance/models/enum.dart';
import 'package:flutter/foundation.dart';

class Employee {
  final String employeeId;
  final String? employeeCode;
  final String firstName;
  final String lastName;
  final Gender gender;
  final DateTime? dob;
  final String? phone;
  final String positionId;
  final String departmentId;
  final double salary;
  final DateTime? hiredDate;
  final Status status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? picture;

  Employee({
    required this.employeeId,
    this.employeeCode,
    required this.firstName,
    required this.lastName,
    required this.gender,
    this.dob,
    this.phone,
    required this.positionId,
    required this.departmentId,
    required this.salary,
    this.hiredDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.picture,
  });

  String get fullName => '$firstName $lastName';

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      employeeId: json['employeeId'],
      employeeCode: json['employeeCode'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      gender: Gender.values.firstWhere((e) => e.name == json['gender']),
      dob: json['dob'] != null ? DateTime.parse(json['dob']) : null,
      phone: json['phone'],
      positionId: json['positionId'],
      departmentId: json['departmentId'],
      salary: (json['salary'] as num).toDouble(),
      hiredDate:
          json['hiredDate'] != null ? DateTime.parse(json['hiredDate']) : null,
      status: Status.values.firstWhere((e) => e.name == json['status']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      picture: json['picture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employeeId': employeeId,
      'employeeCode': employeeCode,
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender.name,
      'dob': dob?.toIso8601String(),
      'phone': phone,
      'positionId': positionId,
      'departmentId': departmentId,
      'salary': salary,
      'hiredDate': hiredDate?.toIso8601String(),
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'picture': picture,
    };
  }

  // factory Employee.fromJson(Map<String, dynamic> json) {
  //   return Employee(
  //     employeeId: json['employeeId'] as String,
  //     employeeCode: json['employeeCode'] as String?,
  //     firstName: json['firstName'] as String,
  //     lastName: json['lastName'] as String,
  //     gender: json['gender'] as Gender,
  //     dob: json['dob'] != null ? DateTime.parse(json['dob'] as String) : null,
  //     phone: json['phone'] as String?,
  //     positionId: json['positionId'] as String,
  //     departmentId: json['departmentId'] as String,
  //     salary: (json['salary'] as num).toDouble(),
  //     hiredDate: json['hiredDate'] != null
  //         ? DateTime.parse(json['hiredDate'] as String)
  //         : null,
  //     status: json['status'] as Status,
  //     createdAt: DateTime.parse(json['createdAt'] as String),
  //     updatedAt: DateTime.parse(json['updatedAt'] as String),
  //     picture: json['picture'] as String?,
  //   );
  // }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'employeeId': employeeId,
  //     'employeeCode': employeeCode,
  //     'firstName': firstName,
  //     'lastName': lastName,
  //     'gender': gender,
  //     'dob': dob?.toIso8601String(),
  //     'phone': phone,
  //     'positionId': positionId,
  //     'departmentId': departmentId,
  //     'salary': salary,
  //     'hiredDate': hiredDate?.toIso8601String(),
  //     'status': status,
  //     'createdAt': createdAt.toIso8601String(),
  //     'updatedAt': updatedAt.toIso8601String(),
  //     'picture': picture,
  //   };
  // }

  @override
  String toString() {
    return 'Employee(employeeId: $employeeId, name: $firstName $lastName, positionId: $positionId, departmentId: $departmentId)';
  }

  // For equality comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Employee && other.employeeId == employeeId;
  }

  @override
  int get hashCode => employeeId.hashCode;
}

// class Employee {
//   final String id;
//   final String name;
//   final String department;
//   final String position;
//   final String imageUrl;

//   Employee({
//     required this.id,
//     required this.name,
//     required this.department,
//     required this.position,
//     required this.imageUrl,
//   });

//   factory Employee.fromJson(Map<String, dynamic> json) {
//     return Employee(
//       id: json['id'] as String,
//       name: json['name'] as String,
//       department: json['department'] as String,
//       position: json['position'] as String,
//       imageUrl: json['imageUrl'] as String,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'department': department,
//       'position': position,
//       'imageUrl': imageUrl,
//     };
//   }
// }
