class Mark {
  final double mark;
  final String examType;
  final String date;
  Mark({required this.mark, required this.examType, required this.date});

  // Factory constructor to create a Mark from JSON
  factory Mark.fromJson(Map<String, dynamic> json) {
    return Mark(
      mark: (json['mark'] ?? 0).toDouble(),
      examType: json['examType'] ?? 'DefaultExamType',
      date: json['date'] ?? "Unknown date",
    );
  }

  // Convert a Mark to JSON
  Map<String, dynamic> toJson() => {
        'mark': mark,
        'examType': examType,
        'date': date,
      };
}

class Student {
  final String username;
  final String name;
  final int grade;
  String? profilePictureBase64;
  Map<String, Mark> marks;
  List<DateTime> absentDays;
  List<DateTime> presentDays;
  Student(
      {required this.username,
      required this.name,
      required this.grade,
      required this.marks,
      required this.absentDays,
      required this.presentDays,
      this.profilePictureBase64});

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
        absentDays: (json['absentDays'] as List?)
                ?.map((date) => DateTime.parse(date))
                .toList() ??
            [],
        presentDays: (json['presentDays'] as List?)
                ?.map((date) => DateTime.parse(date))
                .toList() ??
            [],
        profilePictureBase64: json['profilePictureBase64']);
  }

  // Convert a Student to JSON
  Map<String, dynamic> toJson() => {
        'username': username,
        'name': name,
        'grade': grade,
        'marks': marks.map((key, value) => MapEntry(key, value.toJson())),
        'absentDays': absentDays
            .map((date) => date.toIso8601String())
            .toList(), // Added this
        'presentDays': presentDays
            .map((date) => date.toIso8601String())
            .toList(), // Added this
        'profilePictureBase64': profilePictureBase64,
      };
}
