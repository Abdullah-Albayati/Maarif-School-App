import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:maarif_app/models/Student.dart';
import 'package:maarif_app/services/AuthenticationProvider.dart';
import 'package:provider/provider.dart';

// ... other imports ...

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  String selectedRole = 'student'; // either 'student' or 'teacher'
  String? usernameErrorText;
  String? passwordErrorText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: SingleChildScrollView(
            primary: true,
            reverse: true,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 70,
                ),
                Image.asset(
                  "assets/logo.png",
                  scale: 1.5,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _usernameController,
                  onChanged: (value) {
                    _usernameController.value = TextEditingValue(
                      text: value.toLowerCase(),
                      selection: _usernameController.selection,
                    );
                  },
                  decoration: InputDecoration(
                    labelText: 'Username',
                    errorText: usernameErrorText,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    errorText: passwordErrorText,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                Text(
                  "I'm a:",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            if (selectedRole == 'student') return Colors.blue;
                            return Colors.grey;
                          },
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          selectedRole = 'student';
                        });
                      },
                      child: Text('Student'),
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            if (selectedRole == 'teacher') return Colors.blue;
                            return Colors.grey;
                          },
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          selectedRole = 'teacher';
                        });
                      },
                      child: Text('Teacher'),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      usernameErrorText = _usernameController.text.isEmpty
                          ? "Username is empty."
                          : null;
                      passwordErrorText = _passwordController.text.isEmpty
                          ? "Password is empty."
                          : null;
                    });
                    if (usernameErrorText == null &&
                        passwordErrorText == null) {
                      print(selectedRole);
                      Navigator.pushNamed(context, '/loading');
                      bool success = await Provider.of<AuthenticationProvider>(
                              context,
                              listen: false)
                          .login(_usernameController.text,
                              _passwordController.text, selectedRole);
                      Navigator.pop(context);
                      if (success) {
                        if (selectedRole == "student") {
                          Navigator.pushReplacementNamed(context, '/homest');
                        } else if (selectedRole == "teacher") {
                          Navigator.pushReplacementNamed(context, '/homete');
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                            "Login Failed!",
                          ),
                          duration: Duration(seconds: 1),
                        ));
                      }
                    }
                  },
                  child: Text(
                    'Login',
                    style: TextStyle(fontSize: 25),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.fromLTRB(30, 8, 30, 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
