class Mark {
  final double mark;
  final String examType;

  Mark({required this.mark, required this.examType});

  // Factory constructor to create a Mark from JSON
  factory Mark.fromJson(Map<String, dynamic> json) {
    return Mark(
      mark: (json['mark'] ?? 0).toDouble(),
      examType: json['examType'] ?? 'DefaultExamType',
    );
  }

  // Convert a Mark to JSON
  Map<String, dynamic> toJson() => {
        'mark': mark,
        'examType': examType,
      };
}

class Student {
  final String username;
  final String name;
  final int grade;
  Map<String, Mark> marks;

  Student({
    required this.username,
    required this.name,
    required this.grade,
    required this.marks,
  });

  // Factory constructor to create a Student from JSON
  factory Student.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> rawMarks =
        json['marks'] as Map<String, dynamic>? ?? {};

    Map<String, Mark> processedMarks = {};

    rawMarks.forEach((key, value) {
      processedMarks[key] = Mark.fromJson(value);
    });

    return Student(
      username: json['username'],
      name: json['name'],
      grade: json['grade'],
      marks: processedMarks,
    );
  }

  // Convert a Student to JSON
  Map<String, dynamic> toJson() => {
        'username': username,
        'name': name,
        'grade': grade,
        'marks': marks.map((key, value) => MapEntry(key, value.toJson())),
      };
}
