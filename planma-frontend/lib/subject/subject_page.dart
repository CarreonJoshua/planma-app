import 'package:flutter/material.dart';
import 'package:planma_app/Providers/class_schedule_provider.dart';
import 'package:planma_app/Providers/semester_provider.dart';
import 'package:planma_app/subject/by_date_view.dart';
import 'package:planma_app/subject/by_subject_view.dart';
import 'package:planma_app/subject/create_subject.dart';
import 'package:planma_app/subject/widget/add_semester.dart';
import 'package:planma_app/subject/widget/widget.dart';
import 'package:provider/provider.dart';

class ClassSchedule extends StatefulWidget {
  const ClassSchedule({super.key});

  @override
  _ClassScheduleState createState() => _ClassScheduleState();
}

class _ClassScheduleState extends State<ClassSchedule> {
  bool isByDate = true;

  // List of days
  final List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
  ];

  // Selected semester
  String? selectedSemester;

  @override
  void initState() {
    super.initState();
    // Initially fetch semesters when the screen loads
    final semesterProvider =
        Provider.of<SemesterProvider>(context, listen: false);
    semesterProvider.fetchSemesters().then((_) {
      setState(() {
        selectedSemester = semesterProvider.semesters.isNotEmpty
            ? "${semesterProvider.semesters[0]['acad_year_start']} - ${semesterProvider.semesters[0]['acad_year_end']} ${semesterProvider.semesters[0]['semester']}"
            : null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Schedule'),
      ),
      body: Consumer2<SemesterProvider, ClassScheduleProvider>(
        builder: (context, semesterProvider, classScheduleProvider, child) {
          // Update semesters list
          List<String> semesters = semesterProvider.semesters
              .map((semester) =>
                  "${semester['acad_year_start']} - ${semester['acad_year_end']} ${semester['semester']}")
              .toList();
          semesters.add('- Add Semester -');

          return semesters.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: CustomWidgets.buildDropdownField(
                              label: 'Semester',
                              value: selectedSemester,
                              items: semesters,
                              onChanged: (String? value) {
                                setState(() {
                                  if (value == '- Add Semester -') {
                                    // Navigate to Add Semester screen
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AddSemesterScreen(),
                                      ),
                                    ).then((_) {
                                      // Refresh semesters after returning
                                      semesterProvider.fetchSemesters();
                                    });
                                  } else if (value != null) {
                                    // Update the selected semester
                                    selectedSemester = value;

                                    // Parse selectedSemester to extract its components
                                    List<String> semesterParts =
                                        selectedSemester!.split(' ');
                                    int acadYearStart =
                                        int.parse(semesterParts[0]);
                                    int acadYearEnd =
                                        int.parse(semesterParts[2]);
                                    String semesterType =
                                        "${semesterParts[3]} ${semesterParts[4]}";

                                    // Find the corresponding semester_id
                                    final selectedSemesterMap =
                                        semesterProvider.semesters.firstWhere(
                                      (semester) {
                                        return semester['acad_year_start'] ==
                                                acadYearStart &&
                                            semester['acad_year_end'] ==
                                                acadYearEnd &&
                                            semester['semester'] ==
                                                semesterType;
                                      },
                                      orElse: () =>
                                          {}, // Return empty map if no match is found
                                    );

                                    if (selectedSemesterMap.isNotEmpty) {
                                      final selectedSemesterId =
                                          selectedSemesterMap['semester_id'];
                                      print(
                                          "Found semester ID: $selectedSemesterId");

                                      // Trigger fetching of class schedules using semester_id
                                      classScheduleProvider.fetchClassSchedules(
                                        selectedSemesterId: selectedSemesterId,
                                      );
                                    } else {
                                      print("No matching semester found!");
                                    }
                                  }
                                });
                              },
                              backgroundColor: const Color(0xFFF5F5F5),
                              labelColor: Colors.black,
                              textColor: Colors.black,
                              borderRadius: 30.0,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              fontSize: 14.0,
                            ),
                          ),
                          const SizedBox(width: 10),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.filter_list,
                                color: Colors.black),
                            onSelected: (value) {
                              setState(() {
                                isByDate = value == 'By Date';
                              });
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem<String>(
                                value: 'By Date',
                                child: Text('By Date',
                                    style: TextStyle(color: Colors.black)),
                              ),
                              const PopupMenuItem<String>(
                                value: 'By Subject',
                                child: Text('By Subject',
                                    style: TextStyle(color: Colors.black)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: classScheduleProvider.classSchedules.isEmpty
                          ? const Center(child: Text('No schedules available'))
                          : isByDate
                              ? ByDateView(
                                  days: days,
                                  subjectsView:
                                      classScheduleProvider.classSchedules,
                                )
                              : BySubjectView(
                                  subjectsView:
                                      classScheduleProvider.classSchedules,
                                ),
                    ),
                  ],
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddClassScreen()),
          );
        },
        backgroundColor: const Color(0xFF173F70),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
