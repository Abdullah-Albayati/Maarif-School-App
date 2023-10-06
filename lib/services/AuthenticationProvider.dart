import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:maarif_app/models/Student.dart';
import 'package:maarif_app/models/Teacher.dart';

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

          // Fetch profile picture for the student
          final profilePicEndpoint =
              'http://10.0.2.2:5294/api/student/getProfilePic';
          final profilePicResponse = await http
              .get(Uri.parse('$profilePicEndpoint?username=$username'));
          if (profilePicResponse.statusCode == 200) {
            _authenticatedStudent!.profilePictureBase64 =
                profilePicResponse.body;
          }
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

  void logout() {
    if (authenticatedUser is Student) {
      _authenticatedStudent = null;
      print("logging student out");
    } else if (authenticatedUser is Teacher) {
      _authenticatedTeacher = null;
      print("logging teacher out");
    }
    notifyListeners();
  }
}
