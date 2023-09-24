class Teacher {
  final String username;
  final String name;
  final String subject;

  Teacher({required this.username, required this.name, required this.subject});

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      username: json['username'],
      name: json['name'],
      subject: json['subject'],
    );
  }

  Map<String, dynamic> toJson() => {
        'username': username,
        'name': name,
        'subject': subject,
      };
}
