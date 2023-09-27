import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:maarif_app/models/Student.dart';
import 'package:maarif_app/models/Teacher.dart';
import 'package:provider/provider.dart';

class AuthenticationProvider with ChangeNotifier {
  Student? _authenticatedStudent;
  Teacher? _authenticatedTeacher;

  dynamic get authenticatedUser =>
      _authenticatedStudent ?? _authenticatedTeacher;

  Future<bool> login(String username, String password, String role) async {
    try {
      final endpoint = role == "student"
          ? 'http://10.0.2.2:5294/api/student/login'
          : 'http://10.0.2.2:5294/api/teacher/login';

      final response = await http
          .get(Uri.parse('$endpoint?username=$username&password=$password'));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        print('Login response: ${response.body}');

        final role = responseData['role'];
        if (role == 'student') {
          _authenticatedStudent = Student.fromJson(responseData);
        } else if (role == 'teacher') {
          _authenticatedTeacher = Teacher.fromJson(responseData);
        }
        print('API Response: ${response.body}');

        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error during login: $e");
      return false;
    }
  }

  Future<Map<String, Mark>> fetchStudentMarks(String username) async {
    final response = await http.get(
        Uri.parse('http://10.0.2.2:5294/api/student/marks?username=$username'));

    if (response.statusCode == 200) {
      List<dynamic> rawMarksList = json.decode(response.body);
      Map<String, Mark> processedMarks = {};

      for (var item in rawMarksList) {
        processedMarks[item['subject']] = Mark.fromJson(item);
      }

      return processedMarks;
    } else {
      throw Exception('Failed to load marks for student: $username');
    }
  }

  Future<List<Student>> fetchStudentsByGrade(int grade) async {
    final response = await http.get(
        Uri.parse('http://10.0.2.2:5294/api/student/byGrade?grade=$grade'));

    if (response.statusCode == 200) {
      List<dynamic> responseBody = json.decode(response.body);
      return responseBody
          .map((dynamic item) => Student.fromJson(item))
          .toList();
    } else {
      throw Exception('Failed to load students for the grade: $grade');
    }
  }
}
