import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:maarif_app/models/Student.dart';

class StudentProvider with ChangeNotifier {
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
      List<Student> students =
          responseBody.map((dynamic item) => Student.fromJson(item)).toList();

      // Fetch profile pictures for each student
      for (Student student in students) {
        final profilePicResponse = await getProfilePicture(student.username);
        if (profilePicResponse != null) {
          student.profilePictureBase64 = profilePicResponse;
        }
      }

      return students;
    } else {
      throw Exception('Failed to load students for the grade: $grade');
    }
  }

  Future<bool> updateProfilePicture(String username, String base64Image) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:5294/api/student/uploadProfilePic'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'base64Image': base64Image}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print("Error updating profile picture: ${response.body}");
      return false;
    }
  }

  Future<String?> getProfilePicture(String username) async {
    final response = await http.get(
      Uri.parse(
          'http://10.0.2.2:5294/api/student/getProfilePic?username=$username'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return response
          .body; // this should be the base64 string of the profile picture
    } else {
      print("Error fetching profile picture: ${response.body}");
      return null;
    }
  }

  Future<bool> removeProfilePicture(String username) async {
    final response = await http.post(
      Uri.parse(
          'http://10.0.2.2:5294/api/student/removeProfilePic?username=$username'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print("Error removing profile picture: ${response.body}");
      return false;
    }
  }

  Future<List<DateTime>> fetchAbsentDays(String username) async {
    final response = await http.get(
      Uri.parse(
          'http://10.0.2.2:5294/api/student/getAbsentDays?username=$username'),
    );
    print('Absent days response: ${response.body}');

    if (response.body != null &&
        response.body.startsWith('[') &&
        response.body.endsWith(']')) {
      List<dynamic> responseBody = json.decode(response.body);
      return responseBody
          .map((dateString) => DateTime.parse(dateString))
          .toList();
    } else {
      return []; // Return an empty list if the response isn't a list or is null
    }
  }

  Future<List<DateTime>> fetchPresentDays(String username) async {
    final response = await http.get(
      Uri.parse(
          'http://10.0.2.2:5294/api/student/getPresentDays?username=$username'),
    );
    print('Present days response: ${response.body}');

    if (response.body != null &&
        response.body.startsWith('[') &&
        response.body.endsWith(']')) {
      List<dynamic> responseBody = json.decode(response.body);
      return responseBody
          .map((dateString) => DateTime.parse(dateString))
          .toList();
    } else {
      return [];
    }
  }

  Future<Student> fetchStudentProfile(String username) async {
    final response = await http
        .get(Uri.parse('http://10.0.2.2:5294/api/student/profile/$username'));

    if (response.statusCode == 200) {
      return Student.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load profile for student: $username');
    }
  }
}
