// home_base.dart
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:maarif_app/models/Student.dart';
import 'package:maarif_app/models/Teacher.dart';
import 'package:maarif_app/services/AuthenticationProvider.dart';
import 'package:maarif_app/utils/color_utilities.dart';
import 'package:provider/provider.dart';

abstract class HomeBase extends StatefulWidget {
  final String accountName;
  final String accountEmail;
  final String? studentGrade;
  final String? teacherSubject;
  final List<Widget> pages;
  final List<BottomNavigationBarItem> bottomNavItems;
  final List<Widget> drawerItems;
  const HomeBase({
    required this.accountName,
    required this.accountEmail,
    this.studentGrade,
    this.teacherSubject,
    required this.pages,
    required this.bottomNavItems,
    required this.drawerItems,
  });

  @override
  _HomeBaseState createState() => _HomeBaseState();
}

class _HomeBaseState extends State<HomeBase> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<String> _titles = [
      "${widget.accountName}'s Profile",
      "Schedule",
      "Communication",
      "Class"
    ];

    // Access the user's data using the AuthenticationProvider
    final user = Provider.of<AuthenticationProvider>(context, listen: false)
        .authenticatedUser;

    // Assuming the base64 image data is stored in a profilePictureBase64 property
    ImageProvider? userImage;
    if (user is Student && user.profilePictureBase64 != null) {
      userImage = MemoryImage(base64Decode(user.profilePictureBase64!));
    }

    return Consumer<AuthenticationProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.authenticatedUser;

        ImageProvider? userImage;
        if (user.profilePictureBase64 != null) {
          userImage = MemoryImage(base64Decode(user.profilePictureBase64!));
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(_titles[_currentIndex]),
            backgroundColor: Theme.of(context).primaryColor,
            centerTitle: true,
            actions: [
              IconButton(
                padding: EdgeInsets.symmetric(horizontal: 15),
                onPressed: () {},
                icon: Icon(Icons.notifications_outlined),
              )
            ],
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(widget.accountName),
                  accountEmail: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (user is Student && widget.studentGrade != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text("Grade: ${widget.studentGrade}"),
                        ),
                      if (user is Teacher && widget.teacherSubject != null)
                        Text("Subject: ${widget.teacherSubject}"),
                      Text("Email: ${widget.accountEmail}"),
                    ],
                  ),
                  currentAccountPicture: Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: CircleAvatar(
                      backgroundColor:
                          avatarBackgroundColor(widget.accountName),
                      backgroundImage:
                          userImage, // Set the user's profile picture
                      child: userImage == null
                          ? Text(widget.accountName[0])
                          : null,
                      radius: 25, // You can adjust this as needed
                    ),
                  ),
                ),
                ...widget.drawerItems,
              ],
            ),
          ),
          body: widget.pages[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            items: widget.bottomNavItems,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        );
      },
    );
  }
}
