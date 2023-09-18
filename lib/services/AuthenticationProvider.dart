import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:maarif_app/models/Student.dart';
import 'package:provider/provider.dart';

class AuthenticationProvider with ChangeNotifier {
  Student? _authenticatedStudent;

  Student? get authenticatedStudent => _authenticatedStudent;

  Future<bool> login(String username, String password) async {
    try {
      final response = await http.get(Uri.parse(
          'http://10.0.2.2:5294/api/student/login?username=$username&password=$password'));

      print(
          'Sending request to: http://10.0.2.2:5294/api/student/login?username=$username&password=$password');

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        _authenticatedStudent = Student.fromJson(jsonDecode(response.body));
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
}
