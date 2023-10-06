import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maarif_app/models/Student.dart';
import 'package:maarif_app/models/Teacher.dart';
import 'package:maarif_app/pages/loading.dart';
import 'package:maarif_app/services/AuthenticationProvider.dart';
import 'package:maarif_app/services/StudentProvider.dart';
import 'package:maarif_app/utils/color_utilities.dart';
import 'package:provider/provider.dart';
import 'package:maarif_app/pages/homes/home_base.dart';
import 'package:table_calendar/table_calendar.dart';

class HomeStudent extends HomeBase {
  HomeStudent(BuildContext context)
      : super(
          accountName:
              Provider.of<AuthenticationProvider>(context, listen: false)
                      .authenticatedUser is Student
                  ? (Provider.of<AuthenticationProvider>(context, listen: false)
                          .authenticatedUser as Student)
                      .name
                  : "No Name",
          studentGrade:
              Provider.of<AuthenticationProvider>(context, listen: false)
                      .authenticatedUser is Student
                  ? (Provider.of<AuthenticationProvider>(context, listen: false)
                          .authenticatedUser as Student)
                      .grade
                      .toString()
                  : "No grade assigned",

          // This would come from your auth provider normally
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
            ProfilePage(
                isStudentOwnProfile: true,
                student:
                    Provider.of<AuthenticationProvider>(context, listen: false)
                        .authenticatedUser as Student),
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
        leading: Icon(Icons.library_books_outlined),
        title: const Text(
          'Curriculum',
          style: TextStyle(fontSize: 15),
        ),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => EventsPage()));
        },
      ),
      ListTile(
        leading: Icon(Icons.settings_outlined),
        title: Text(
          'Settings',
          style: TextStyle(fontSize: 15),
        ),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => SettingsPage()));
        },
      ),
      ListTile(
        leading: Icon(Icons.logout),
        title: Text(
          'Log out',
          style: TextStyle(fontSize: 15),
        ),
        onTap: () {
          Provider.of<AuthenticationProvider>(context, listen: false).logout();
          Navigator.pop(context);
          Navigator.pushReplacementNamed(context, "/login");
        },
      ),
    ];
  }
}

class ProfilePage extends StatefulWidget {
  final Student student;
  final bool isStudentOwnProfile;
  ProfilePage({required this.student, required this.isStudentOwnProfile});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  DateTime _selectedDay = DateTime.now();

  CalendarFormat _calendarFormat = CalendarFormat.month;

  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;

  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final student = widget.student;

    return SingleChildScrollView(
      child: Center(
        child: Column(children: [
          StudentInfo(
            student: student,
            showChangePicButton: widget.isStudentOwnProfile,
          ),
          Marks(
            student: student,
          ),
          SizedBox(
            height: 25,
          ),
          EventAchievements(),
          SizedBox(
            height: 25,
          ),
          AttendanceWidget(
            student: student,
            selectedDay: _selectedDay,
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            rangeSelectionMode: _rangeSelectionMode,
            onDaySelected: (selectedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                _selectedDay = selectedDay;
                print(_selectedDay);
              }
              _focusedDay = selectedDay;
            },
          )
        ]),
      ),
    );
  }
}

class Marks extends StatelessWidget {
  final Student student;

  const Marks({
    required this.student,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, Mark>>(
      future: Provider.of<StudentProvider>(context, listen: false)
          .fetchStudentMarks(student
              .username), // Fetching the marks using the provided student
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          print("Snapshot data: ${snapshot.data}");
          return Loading();
        } else if (snapshot.error != null || snapshot.data == null) {
          return Center(child: Text('An error occurred!'));
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final List<Map<String, dynamic>> recentMarksList =
              snapshot.data!.entries
                  .map((entry) => {
                        "subject": entry.key,
                        "mark": entry.value.mark,
                        "date":
                            "Unknown", // Adjust if your Mark object has a date.
                        "type": entry.value.examType,
                      })
                  .take(5)
                  .toList();

          return RecentMarks(
            marks: recentMarksList,
            student: student,
          );
        }
      },
    );
  }
}

class StudentInfo extends StatefulWidget {
  final Student student;
  final bool showChangePicButton;

  const StudentInfo({
    required this.student,
    required this.showChangePicButton,
    Key? key,
  }) : super(key: key);

  @override
  State<StudentInfo> createState() => _StudentInfoState();
}

class _StudentInfoState extends State<StudentInfo> {
  Future<void> _changeProfilePicture(BuildContext context) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      final imageBytes = await File(pickedImage.path).readAsBytes();
      final base64Image = base64Encode(imageBytes);

      final bool isSuccessful =
          await Provider.of<StudentProvider>(context, listen: false)
              .updateProfilePicture(widget.student.username, base64Image);
      Provider.of<AuthenticationProvider>(context, listen: false)
          .notifyListeners();

      if (isSuccessful) {
        setState(() {
          widget.student.profilePictureBase64 = base64Image;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile picture.')),
        );
      }
    }
  }

  Future<void> _removeProfilePicture(BuildContext context) async {
    final bool isSuccessful =
        await Provider.of<StudentProvider>(context, listen: false)
            .removeProfilePicture(widget.student.username);

    Provider.of<AuthenticationProvider>(context, listen: false)
        .notifyListeners();

    if (isSuccessful) {
      setState(() {
        widget.student.profilePictureBase64 = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile picture removed successfully.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing profile picture.')),
      );
    }
  }

  void _showProfileOptions(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            height: 120,
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.photo_camera),
                  title: Text('Add new profile picture'),
                  onTap: () {
                    _changeProfilePicture(context);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete),
                  title: Text('Remove profile picture'),
                  onTap: () {
                    _removeProfilePicture(context);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.student.name;

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
                  backgroundImage: widget.student.profilePictureBase64 != null
                      ? MemoryImage(
                          base64Decode(widget.student.profilePictureBase64!))
                      : null,
                  child: widget.student.profilePictureBase64 == null
                      ? Text(name[0] ?? "?")
                      : null,
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
          Text("Grade: ${widget.student?.grade.toString()}" ?? "No Grade"),
          Visibility(
            visible: widget.showChangePicButton,
            child: Container(
              width: 300,
              child: ElevatedButton(
                onPressed: () {
                  _showProfileOptions(context);
                },
                child: Text("Change Profile Picture"),
              ),
            ),
          ),
        ],
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
            "Contributions",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          width: 250,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.lightBlue),
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
  final Student student;
  RecentMarks({required this.marks, required this.student});

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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AllMarks(
                              student: student,
                            )),
                  );
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  alignment: Alignment(1, 0),
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.transparent,
                  // adjust values as required
                ),
                child: Text(
                  "View all details",
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
            border: Border.all(color: Colors.lightBlue),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: marks.map((mark) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Text(mark["subject"]),
                    ),
                    Expanded(child: Text(mark["type"])),
                    Expanded(child: Text("Mark: ${mark["mark"].toString()}")),
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

class AttendanceWidget extends StatefulWidget {
  final DateTime selectedDay;
  final DateTime focusedDay;
  final CalendarFormat calendarFormat;
  final RangeSelectionMode rangeSelectionMode;
  final Function(DateTime) onDaySelected;
  final Student student; // Changed username to Student object

  AttendanceWidget({
    required this.selectedDay,
    required this.focusedDay,
    required this.calendarFormat,
    required this.rangeSelectionMode,
    required this.onDaySelected,
    required this.student, // Adjusted here
  });

  @override
  State<AttendanceWidget> createState() => _AttendanceWidgetState();
}

class _AttendanceWidgetState extends State<AttendanceWidget> {
  List<DateTime> absentDays = [];
  List<DateTime> presentDays = [];

  @override
  void initState() {
    super.initState();
    _fetchAttendanceData();
  }

  _fetchAttendanceData() async {
    final provider = Provider.of<StudentProvider>(context, listen: false);
    absentDays = await provider
        .fetchAbsentDays(widget.student.username); // Use the student object
    presentDays = await provider
        .fetchPresentDays(widget.student.username); // Use the student object
    setState(() {}); // Refresh the UI once the data is fetched
  }

  bool isInList(DateTime day, List<DateTime> dateList) {
    return dateList.any((date) =>
        date.year == day.year &&
        date.month == day.month &&
        date.day == day.day);
  }

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
          Material(
            child: TableCalendar(
              firstDay: DateTime.utc(2023, 9, 22),
              lastDay: DateTime.utc(2033, 9, 22),
              focusedDay: widget.focusedDay,
              calendarFormat: widget.calendarFormat,
              rangeSelectionMode: widget.rangeSelectionMode,
              calendarStyle: CalendarStyle(),
              eventLoader: (day) => [],
              onDaySelected: (selected, focused) {
                widget.onDaySelected(selected);
              },
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  print("Building for date: $day");
                  if (isInList(day, absentDays)) {
                    print("Absent date: $day");
                    return Container(
                      width: 25,
                      decoration: BoxDecoration(
                        color: Colors.red[600],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  } else if (isInList(day, presentDays)) {
                    print("Present date: $day");
                    return Container(
                      width: 25,
                      decoration: BoxDecoration(
                        color: Colors.green[600],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }
                  return Center(child: Text(day.day.toString()));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SchedulePage extends StatelessWidget {
  // Static times for each class
  final List<String> times = [
    '8:00-8:45',
    '8:50-9:35',
    '9:45-10:30',
    '10:35-11:20',
    '11:40-12:25',
    '12:30-13:15',
    '13:25-14:10'
  ];

  // Mock data for the schedule based on the given format
  final Map<String, List<String>> schedule = {
    'Sunday': [
      'Geology',
      'P.E',
      'Chemistry',
      'Arabic',
      'Arabic',
      'Biology',
      'Turkish',
    ],
    'Monday': [
      'Chemistry',
      'Art/Music',
      'English',
      'English',
      'Arabic',
      'Arabic',
      'Religion'
    ],
    'Tuesday': [
      'Computer Science',
      'English',
      'Physics',
      'Mathmatics',
      'Mathmatics',
      'Chemistry',
      'Turkish'
    ],
    'Wednesday': [
      "Mathmatics",
      'English',
      'English',
      'Physics',
      'Arabic',
      'P.E',
      'Geology'
    ],
    'Thursday': [
      'Physics',
      'Mathmatics',
      'Biology',
      'Biology',
      'Religion',
      'Computer Science',
      'Mathmatics'
    ]
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: schedule.keys.length,
        itemBuilder: (context, index) {
          String day = schedule.keys.elementAt(index);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  day,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
              ),
              Column(
                children: List.generate(
                  times.length,
                  (i) => _buildClassItem(schedule[day]![i], times[i]),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildClassItem(String subject, String time) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text(subject),
        subtitle: Text(time),
        leading: CircleAvatar(
          child: Text(subject[0]),
          backgroundColor: Colors.blueGrey[50],
          foregroundColor: Colors.blueGrey,
        ),
      ),
    );
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
          future: Provider.of<StudentProvider>(context, listen: false)
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
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            ProfileInspection(student: students[index]),
                      ));
                    },
                    child: ListTile(
                      title: Text(students[index].name),
                      subtitle:
                          Text('Grade: ${students[index].grade.toString()}'),
                      leading: CircleAvatar(
                        backgroundColor:
                            avatarBackgroundColor(students[index].name),
                        backgroundImage:
                            (students[index].profilePictureBase64 != null)
                                ? MemoryImage(base64Decode(
                                    students[index].profilePictureBase64!))
                                : null,
                        child: (students[index].profilePictureBase64 == null)
                            ? Text(students[index].name[0])
                            : null,
                        radius: 25,
                      ),
                    ),
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

class ProfileInspection extends StatelessWidget {
  final Student student;
  const ProfileInspection({required this.student, Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${student.name}")),
      body: ProfilePage(
        student: student,
        isStudentOwnProfile: false,
      ),
    );
  }
}

class AllMarks extends StatelessWidget {
  final Student student;
  const AllMarks({required this.student, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All Marks"),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, Mark>>(
        future: Provider.of<StudentProvider>(context, listen: false)
            .fetchStudentMarks(student.username),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            print("Snapshot data: ${snapshot.data}");
            return Loading();
          } else if (snapshot.error != null || snapshot.data == null) {
            return Center(child: Text('An error occurred!'));
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final List<Map<String, dynamic>> recentMarksList =
                snapshot.data!.entries
                    .map((entry) => {
                          "subject": entry.key,
                          "mark": entry.value.mark,
                          "date": entry.value
                              .date, // Adjust if your Mark object has a date.
                          "type": entry.value.examType,
                        })
                    .toList();

            return ListView.builder(
              itemCount: recentMarksList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                      "${recentMarksList[index]["subject"]}.\n${recentMarksList[index]["type"]}."),
                  subtitle: Text("${recentMarksList[index]["date"]}."),
                  trailing: Text("Mark: ${recentMarksList[index]["mark"]}"),
                );
              },
            );
          }
        },
      ),
    );
  }
}
