import 'dart:math';

import 'package:flutter/material.dart';
import 'package:maarif_app/models/Student.dart';
import 'package:maarif_app/pages/loading.dart';
import 'package:maarif_app/services/AuthenticationProvider.dart';
import 'package:maarif_app/utils/color_utilities.dart';
import 'package:provider/provider.dart';
import 'package:maarif_app/pages/homes/home_base.dart';
import 'package:table_calendar/table_calendar.dart';

class HomeStudent extends HomeBase {
  HomeStudent(BuildContext context)
      : super(
          title: "Student Home", // Assuming this, modify as needed
          accountName: Provider.of<AuthenticationProvider>(context,
                      listen: false)
                  .authenticatedUser is Student
              ? (Provider.of<AuthenticationProvider>(context, listen: false)
                      .authenticatedUser as Student)
                  .name
              : "No Name", // This would come from your auth provider normally
          accountEmail: Provider.of<AuthenticationProvider>(context,
                      listen: false)
                  .authenticatedUser is Student
              ? (Provider.of<AuthenticationProvider>(context, listen: false)
                          .authenticatedUser as Student)
                      .name
                      .replaceAll(' ', '_') +
                  "@gmail.com"
              : "No email", // This would come from your auth provider normally
          pages: [
            ProfilePage(),
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
          drawerItems: _buildDrawerItems(context),
        );

  static List<Widget> _buildDrawerItems(BuildContext context) {
    return [
      ListTile(
        leading: Icon(Icons.assignment_turned_in_outlined),
        title: Text('Attendance'),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AttendancePage()));
        },
      ),
      ListTile(
        leading: Icon(Icons.event_available_outlined),
        title: Text('Events'),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => EventsPage()));
        },
      ),
      ListTile(
        leading: Icon(Icons.settings_outlined),
        title: Text('Settings'),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => SettingsPage()));
        },
      ),
      ListTile(
        leading: Icon(Icons.logout),
        title: Text('Log out'),
        onTap: () {
          Navigator.pop(context);
          Navigator.pushReplacementNamed(context, "/login");
        },
      ),
    ];
  }
}

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  DateTime _selectedDay = DateTime.now();

  CalendarFormat _calendarFormat = CalendarFormat.month;

  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;

  DateTime _focusedDay = DateTime.now();

  final List<Map<String, dynamic>> allMarks = [
    {"subject": "Math", "mark": 89, "date": "23 Sep 2023"},
    {"subject": "Science", "mark": 94, "date": "20 Sep 2023"},
    {"subject": "History", "mark": 85, "date": "17 Sep 2023"},
    {"subject": "Geography", "mark": 91, "date": "15 Sep 2023"},
    {"subject": "English", "mark": 88, "date": "12 Sep 2023"},
    {"subject": "Arabic", "mark": 85, "date": "12 Sep 2023"},
  ];

  @override
  Widget build(BuildContext context) {
    final recentMarks = allMarks.take(5).toList();
    return SingleChildScrollView(
      child: Column(children: [
        StudentInfo(),
        SizedBox(
          height: 25,
        ),
        RecentMarks(marks: recentMarks),
        SizedBox(
          height: 25,
        ),
        EventAchievements(),
        SizedBox(
          height: 25,
        ),
        AttendanceWidget(
          selectedDay: _selectedDay,
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          rangeSelectionMode: _rangeSelectionMode,
          onDaySelected: (selectedDay) {
            if (!isSameDay(_selectedDay, selectedDay)) {
              // You can use setState() here if `ProfilePage` ever becomes a StatefulWidget
              _selectedDay = selectedDay;
              print(_selectedDay);
            }
            _focusedDay = selectedDay;
          },
        )
      ]),
    );
  }
}

class StudentInfo extends StatelessWidget {
  const StudentInfo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
      child: Consumer<AuthenticationProvider>(
        builder: (context, authProvider, child) {
          final student = authProvider.authenticatedUser as Student?;
          final name = student?.name ?? "No Name";

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: avatarBackgroundColor(name),
                child: Text(name[0] ?? "?"),
                radius: 50,
              ),
              SizedBox(height: 10),
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
              Text("Grade: ${student?.grade.toString()}" ?? "No Grade"),
            ],
          );
        },
      ),
    );
  }
}

class EventAchievements extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Text(
            "Event Achievements",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          width: 250,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.class_outlined),
                title: Text("Maarif Talks 2021"),
              ),

              // ... Add more achievements as needed
            ],
          ),
        ),
      ],
    );
  }
}

class RecentMarks extends StatelessWidget {
  final List<Map<String, dynamic>> marks;
  RecentMarks({required this.marks});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // This will center "Recent Marks"
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 10),
                child: Text("Recent Marks", style: TextStyle(fontSize: 18)),
              ),
            ),
            // This will position "View All Marks" to the top right
            Positioned(
              top: 20,
              left: 260,
              child: TextButton(
                onPressed: () {
                  // Handle button press
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  alignment: Alignment(1, 0),
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.transparent,
                  // adjust values as required
                ),
                child: Text(
                  "View All Marks",
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey), // adjust font size as required
                ),
              ),
            ),
          ],
        ),
        Container(
          width: 250,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: marks.map((mark) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(mark["subject"]),
                    Text("Mark: ${mark["mark"].toString()}"),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class AttendanceWidget extends StatelessWidget {
  final DateTime selectedDay;
  final DateTime focusedDay;
  final CalendarFormat calendarFormat;
  final RangeSelectionMode rangeSelectionMode;
  final ValueChanged<DateTime> onDaySelected;

  AttendanceWidget({
    required this.selectedDay,
    required this.focusedDay,
    required this.calendarFormat,
    required this.rangeSelectionMode,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      child: Column(
        children: [
          Text(
            "Attendance",
            style: TextStyle(fontSize: 18),
          ),
          TableCalendar(
            firstDay: DateTime.utc(2023, 9, 22),
            lastDay: DateTime.utc(2033, 9, 22),
            focusedDay: selectedDay,
            calendarFormat: calendarFormat,
            rangeSelectionMode: rangeSelectionMode,
            calendarStyle: CalendarStyle(),
            eventLoader: (day) {
              return [];
            },
            onDaySelected: (selected, focused) {
              onDaySelected(selected);
            },
          ),
        ],
      ),
    );
  }
}

class SchedulePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Schedule Page'));
  }
}

class CommunicationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Communication Page'));
  }
}

class ClassPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticationProvider>(
      builder: (context, authProvider, child) {
        final currentStudent = authProvider.authenticatedUser as Student?;
        if (currentStudent == null) {
          return Center(child: Text('No logged-in student found'));
        }

        return FutureBuilder<List<Student>>(
          future: Provider.of<AuthenticationProvider>(context, listen: false)
              .fetchStudentsByGrade(currentStudent.grade),
          builder: (context, snapshot) {
            // If the Future is still running, show a loading indicator
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: Loading());
            }

            // If the Future is completed and no errors occurred, display the students
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              List<Student> students = snapshot.data!;

              // Remove any student from the list with the same username as the current student
              students.removeWhere(
                  (student) => student.username == currentStudent.username);

              // Add the current student to the beginning of the list
              students.insert(0, currentStudent);

              return ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(students[index].name),
                    subtitle:
                        Text('Grade: ${students[index].grade.toString()}'),
                    // Add other fields of the student as required
                  );
                },
              );
            }

            // If we run into an error, display it to the user
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            // If the Future is complete but no students are found, inform the user.
            return Center(child: Text('No students found in the same grade'));
          },
        );
      },
    );
  }
}

class AttendancePage extends StatelessWidget {
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  DateTime _focusedDay = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Attendance"),
          centerTitle: true,
        ),
        body: TableCalendar(
          firstDay: DateTime.utc(2023, 9, 22),
          lastDay: DateTime.utc(2033, 9, 22),
          focusedDay: _selectedDay,
          calendarFormat: _calendarFormat,
          rangeSelectionMode: _rangeSelectionMode,
          calendarStyle: CalendarStyle(),
          eventLoader: (day) {
            return [];
          },
          onDaySelected: (selectedDay, focusedDay) {
            if (!isSameDay(_selectedDay, selectedDay)) {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            }
          },
        ));
  }
}

class EventsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Events"),
        centerTitle: true,
      ),
      body: Center(
        child: Text("Events"),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        centerTitle: true,
      ),
      body: Center(
        child: Text("Settings"),
      ),
    );
  }
}
