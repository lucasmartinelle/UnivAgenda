// ignore_for_file: empty_statements, deprecated_member_use

import 'dart:core';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

// Datasource for the calendar
class DataSource extends CalendarDataSource {
  DataSource(List<Appointment> source) {
    appointments = source;
  }
}

// Agenda Widget
class AgendaWidget extends StatefulWidget {
  // constructor
  const AgendaWidget({Key? key}) : super(key: key);

  // Create state
  @override
  _AgendaWidgetState createState() => _AgendaWidgetState();
}

// Agenda widget state
class _AgendaWidgetState extends State<AgendaWidget> {
  // Declare variables
  ICalendar? _iCalendar;
  bool _isLoading = false;
  DataSource? _ds;

  // Dialog box information for appointments
  String? _subjectText = '',
      _startTimeText = '',
      _endTimeText = '',
      _dateText = '',
      _timeDetails = '',
      _locationDetails = '',
      _notesGroupDetails = '',
      _notesTeacherDetails = '';
  Color? _headerColor, _viewHeaderColor, _calendarColor;

  /// Get data from .ics file
  /// @return Future<void>
  /// @param assetName      Name of the .ics fle
  Future<void> _getAssetsFile(String assetName) async {
    try {
      // get file path
      final directory = await getTemporaryDirectory();
      final myPath = path.join(directory.path, assetName);
      final data = await rootBundle.load('assets/$assetName');

      // read file
      final bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      final file = await File(myPath).writeAsBytes(bytes);
      final lines = await file.readAsLines();

      // update state to set _iCalendar with .ics data
      setState(() {
        _iCalendar = ICalendar.fromLines(lines);
      });
      // If an error occured, update stat to cancel CircularProgressIndicator
    } catch (e) {
      setState(() => _isLoading = false);
      throw 'Error: $e';
    }
  }

  /// Get datasource for calendar
  /// @return Future<void>
  Future<void> _getCalendarDataSource() async {
    // Update state to set load CircularProgressIndicator
    setState(() => _isLoading = true);

    // list of appointments
    List<Appointment> appointments = <Appointment>[];

    // wait until .ics file was completly read.
    await _getAssetsFile("ADECal.ics");

    // add appointment from data parsed
    appointments.addAll(_iCalendar!.data.map((e) => Appointment(
        startTime: e["dtstart"].toDateTime(),
        endTime: e["dtend"].toDateTime(),
        subject: e["summary"],
        location: e["location"],
        notes: e["description"],
        color: Colors.red)));

    // update state to show appointments in calendar and cancel CircularProgressIndicator
    setState(() {
      _ds = DataSource(appointments);
      _isLoading = false;
    });
  }

  /// Build calendar widget
  @override
  Widget build(BuildContext context) {
    if (_ds == null || _isLoading) {
      _getCalendarDataSource();
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    } else {
      return Scaffold(
          appBar:
              AppBar(backgroundColor: Colors.red, title: const Text("Agenda")),
          body: SfCalendar(
            view: CalendarView.workWeek,
            appointmentTimeTextFormat: 'HH:mm',
            showCurrentTimeIndicator: true,
            showWeekNumber: true,
            timeZone: 'Romance Standard Time',
            todayHighlightColor: Colors.pink,
            weekNumberStyle: const WeekNumberStyle(
              backgroundColor: Colors.pink,
              textStyle: TextStyle(color: Colors.white, fontSize: 15),
            ),
            timeSlotViewSettings: const TimeSlotViewSettings(
                startHour: 7,
                endHour: 20,
                timeFormat: 'kk:mm',
                nonWorkingDays: <int>[DateTime.saturday, DateTime.sunday]),
            dataSource: _ds,
            onTap: calendarTapped,
          ));
    }
  }

  void calendarTapped(CalendarTapDetails details) {
    if (details.targetElement == CalendarElement.appointment ||
        details.targetElement == CalendarElement.agenda) {
      final Appointment appointmentDetails = details.appointments![0];
      _subjectText = appointmentDetails.subject;
      _dateText = DateFormat('MMMM dd', 'fr')
          .format(appointmentDetails.startTime.add(const Duration(hours: 2)))
          .toString();
      _startTimeText = DateFormat('kk:mm', 'fr')
          .format(appointmentDetails.startTime.add(const Duration(hours: 2)))
          .toString();
      _endTimeText = DateFormat('kk:mm', 'fr')
          .format(appointmentDetails.endTime.add(const Duration(hours: 2)))
          .toString();
      if (appointmentDetails.isAllDay) {
        _timeDetails = 'Toute la journée';
      } else {
        _timeDetails = '$_startTimeText - $_endTimeText';
      }
      _locationDetails = appointmentDetails.location;

      List<String> detailsNotes =
          appointmentDetails.notes!.replaceAll('\\n', ' ').split(' ');
      if (detailsNotes[2] == 'Grp') {
        _notesGroupDetails = "${detailsNotes[2]} ${detailsNotes[3]}";
        _notesTeacherDetails = "${detailsNotes[4]} ${detailsNotes[5]}";
      } else {
        _notesGroupDetails = detailsNotes[2];
        _notesTeacherDetails = "${detailsNotes[3]} ${detailsNotes[4]}";
      }

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('$_subjectText'),
              content: SizedBox(
                height: 150,
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          '$_dateText',
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: const <Widget>[
                        Text(''),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Text(_timeDetails!,
                            style: const TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 15)),
                      ],
                    ),
                    Row(
                      children: const <Widget>[
                        Text(''),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Text("Salle ${_locationDetails!}",
                            style: const TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 15)),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Text("Groupe: ${_notesGroupDetails!}",
                            style: const TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 15)),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Text("Professeur: ${_notesTeacherDetails!}",
                            style: const TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 15)),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('fermer'))
              ],
            );
          });
    }
  }
}
