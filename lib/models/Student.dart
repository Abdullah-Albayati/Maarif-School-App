class Student {
  final String username;
  final String name;
  final int grade;
  Map<String, double> marks;
  Student(
      {required this.username,
      required this.name,
      required this.grade,
      required this.marks});

  // Factory constructor to create a Student from JSON
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      username: json['username'],
      name: json['name'],
      grade: json['grade'],
      marks: json['marks'] == null
          ? {}
          : (json['marks'] as Map<String, dynamic>)
              .map((key, value) => MapEntry(key, value.toDouble())),
    );
  }

  // Convert a Student to JSON
  Map<String, dynamic> toJson() => {
        'username': username,
        'name': name,
        'grade': grade,
        'marks': marks,
      };
}
