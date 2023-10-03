import 'package:flutter/material.dart';
import 'package:maarif_app/models/Teacher.dart';
import 'package:maarif_app/pages/homes/home_base.dart';
import 'package:maarif_app/services/AuthenticationProvider.dart';
import 'package:provider/provider.dart';

class HomeTeacher extends HomeBase {
  HomeTeacher(BuildContext context)
      : super(
          accountName:
              Provider.of<AuthenticationProvider>(context, listen: false)
                      .authenticatedUser is Teacher
                  ? (Provider.of<AuthenticationProvider>(context, listen: false)
                          .authenticatedUser as Teacher)
                      .name
                  : "No Name",
          drawerItems: _buildDrawerItems(context),
          // This would come from your auth provider normally
          accountEmail: Provider.of<AuthenticationProvider>(context,
                      listen: false)
                  .authenticatedUser is Teacher
              ? (Provider.of<AuthenticationProvider>(context, listen: false)
                          .authenticatedUser as Teacher)
                      .name
                      .replaceAll(' ', '_') +
                  "@gmail.com"
              : "No email", // This would come from your auth provider normally
          pages: [
            ProfileTeacherPage(),
            SchedulePage(),
            CommunicationPage(),
            ClassPage(),
          ],
          bottomNavItems: [
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.schedule),
              label: 'Schedule',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.message_outlined),
              label: 'Communication',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.class_outlined),
              label: 'Class',
            ),
          ],
        );

  static List<Widget> _buildDrawerItems(BuildContext context) {
    return [
      ListTile(
        leading: Icon(Icons.event_available_outlined),
        title: const Text('Events'),
      ),
      ListTile(
        leading: Icon(Icons.settings_outlined),
        title: Text('Settings'),
        onTap: () {
          Navigator.pop(context);
          ;
        },
      ),
      ListTile(
        leading: Icon(Icons.logout),
        title: Text('Log out'),
        onTap: () {},
      ),
    ];
  }
}

class ProfileTeacherPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);
    final user = authProvider.authenticatedUser;
    final teacher = user is Teacher ? user : null;

    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              child: Text(
                teacher?.name[0] ?? '?',
                style: TextStyle(fontSize: 28),
              ),
            ),
            SizedBox(height: 20),
            Text(
              teacher?.name ?? 'No Name',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              teacher?.subject ?? 'No Subject',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class SchedulePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('SchedulePage')),
    );
  }
}

class CommunicationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('CommunicationPage')),
    );
  }
}

class ClassPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('ClassPage')),
    );
  }
}

class EventsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('EventsPage')),
    );
  }
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('SettingsPage')),
    );
  }
}
