class Student {
  final String username;
  final String name;
  final String grade;

  Student({required this.username, required this.name, required this.grade});

  // Factory constructor to create a Student from JSON
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      username: json['username'],
      name: json['name'],
      grade: json['grade'],
    );
  }

  // Convert a Student to JSON
  Map<String, dynamic> toJson() => {
        'username': username,
        'name': name,
        'grade': grade,
      };
}
