// home_base.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:maarif_app/services/AuthenticationProvider.dart';
import 'package:maarif_app/utils/color_utilities.dart';
import 'package:provider/provider.dart';

abstract class HomeBase extends StatefulWidget {
  final String title;
  final String accountName;
  final String accountEmail;
  final List<Widget> pages;
  final List<BottomNavigationBarItem> bottomNavItems;
  final List<Widget> drawerItems;
  HomeBase({
    required this.title,
    required this.accountName,
    required this.accountEmail,
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
              accountEmail: Text(widget.accountEmail),
              currentAccountPicture: CircleAvatar(
                backgroundColor: avatarBackgroundColor(widget.accountName),
                child: Text(widget.accountName[0]),
                radius: 25, // You can adjust this as needed
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
  }
}
