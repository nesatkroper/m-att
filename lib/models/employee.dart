class Employee {
  final String id;
  final String name;
  final String department;
  final String position;
  final String imageUrl;

  Employee({
    required this.id,
    required this.name,
    required this.department,
    required this.position,
    required this.imageUrl,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] as String,
      name: json['name'] as String,
      department: json['department'] as String,
      position: json['position'] as String,
      imageUrl: json['imageUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'department': department,
      'position': position,
      'imageUrl': imageUrl,
    };
  }
}
