import 'package:flutter/material.dart';
import 'package:maarif_app/models/Teacher.dart';
import 'package:maarif_app/pages/homes/home_base.dart';
import 'package:maarif_app/services/AuthenticationProvider.dart';
import 'package:maarif_app/utils/color_utilities.dart';
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
          teacherSubject:
              Provider.of<AuthenticationProvider>(context, listen: false)
                      .authenticatedUser is Teacher
                  ? (Provider.of<AuthenticationProvider>(context, listen: false)
                          .authenticatedUser as Teacher)
                      .subject
                      .toString()
                  : "No subjects assigned",
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
            ProfilePage(
                teacher:
                    Provider.of<AuthenticationProvider>(context, listen: false)
                        .authenticatedUser as Teacher,
                isTeacherOwnProfile: true),
            SchedulePage(),
            CommunicationPage(),
            ClassesPage(),
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
              label: 'Classes',
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

class ProfilePage extends StatefulWidget {
  final Teacher teacher;
  final bool isTeacherOwnProfile;
  ProfilePage({required this.teacher, required this.isTeacherOwnProfile});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final teacher = widget.teacher;

    return SingleChildScrollView(
      child: Center(
          child: Column(
        children: [
          TeacherInfo(
            teacher: teacher,
          ),
        ],
      )),
    );
  }
}

class TeacherInfo extends StatefulWidget {
  final Teacher teacher;

  const TeacherInfo({
    required this.teacher,
    Key? key,
  }) : super(key: key);

  @override
  State<TeacherInfo> createState() => _TeacherInfoState();
}

class _TeacherInfoState extends State<TeacherInfo> {
  @override
  Widget build(BuildContext context) {
    final name = widget.teacher.name;

    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/MaarifBg.jpg"),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                            Color.fromRGBO(77, 208, 225, 0.5),
                            BlendMode.darken),
                        isAntiAlias: true)),
                height: 150,
                width: double.infinity,
              ),
              Positioned(
                bottom: -50,
                child: CircleAvatar(
                  backgroundColor: avatarBackgroundColor(name),
                  child: Text("${widget.teacher.name[0].toUpperCase()}"),
                  radius: 50,
                ),
              ),
            ],
          ),
          SizedBox(height: 50),
          LayoutBuilder(
            builder: (context, constraints) {
              final textSpan = TextSpan(
                text: name,
                style: TextStyle(fontSize: 22),
              );
              final textPainter = TextPainter(
                text: textSpan,
                maxLines: 1,
                textDirection: TextDirection.ltr,
              )..layout(maxWidth: constraints.maxWidth);

              if (textPainter.didExceedMaxLines) {
                final nameParts = name.split(' ');
                if (nameParts.length > 1) {
                  final lastName = nameParts.removeLast();
                  final restOfName = nameParts.join(' ');
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(restOfName, style: TextStyle(fontSize: 22)),
                      Text(lastName, style: TextStyle(fontSize: 22)),
                    ],
                  );
                }
              }
              return Text(name, style: TextStyle(fontSize: 22));
            },
          ),
          SizedBox(height: 5),
          Text("Subject: ${widget.teacher.subject.toString()}" ?? "No Subject"),
        ],
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

class ClassesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Classes Page')),
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
