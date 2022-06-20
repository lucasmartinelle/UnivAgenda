import 'dart:core';
import 'package:http/http.dart' as http;

// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:google_fonts/google_fonts.dart';

import 'db/linkModal.dart';

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
  // ignore: library_private_types_in_public_api
  _AgendaWidgetState createState() => _AgendaWidgetState();
}

// Agenda widget state
class _AgendaWidgetState extends State<AgendaWidget> {
  // Declare variables
  ICalendar? _iCalendar;
  bool _isLoading = false;
  bool _isError = false;
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

  /// Get data from .ics file threw URL
  /// @return Future<void>
  /// @param url      URL to the ics file
  Future<void> _getAssetsURL(String url) async {
    if (Uri.parse(url).isAbsolute) {
      try {
        Uri urlToCall = Uri.parse(url);
        http.Response response = await http.get(urlToCall);

        // update state to set _iCalendar with .ics data
        setState(() {
          _iCalendar = ICalendar.fromString(response.body);
        });
        // If an error occured, update stat to cancel CircularProgressIndicator
      } catch (e) {
        setState(() {
          _isError = true;
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isError = true;
        _isLoading = false;
      });
    }
  }

  /// Get datasource for calendar
  /// @return Future<void>
  Future<void> _getCalendarDataSource() async {
    // Update state to set load CircularProgressIndicator
    setState(() => _isLoading = true);

    // list of appointments
    List<Appointment> appointments = <Appointment>[];

    // get URL of agenda from database
    String? link = await linkModal().getLink();

    if (link != null) {
      await _getAssetsURL(link);

      if (_iCalendar != null) {
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
      } else {
        setState(() {
          _isError = true;
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isError = true;
        _isLoading = false;
      });
    }
  }

  /// Build calendar widget
  @override
  Widget build(BuildContext context) {
    if (_isError) {
      return Scaffold(
          appBar:
              AppBar(backgroundColor: Colors.red, title: const Text("Agenda")),
          body: Center(
              child: Text("URL de l'agenda invalide ou non-fournis.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)))));
    } else if (_ds == null || _isLoading) {
      _getCalendarDataSource();
      return Scaffold(
          appBar:
              AppBar(backgroundColor: Colors.red, title: const Text("Agenda")),
          body: const Center(child: CircularProgressIndicator()));
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
      _timeDetails = (appointmentDetails.isAllDay)
          ? 'Toute la journée'
          : '$_startTimeText - $_endTimeText';
      _locationDetails = appointmentDetails.location;

      List<String> detailsNotes =
          appointmentDetails.notes!.replaceAll('\\n', ' ').split(' ');
      if (detailsNotes[2] == 'Grp') {
        _notesGroupDetails = "${detailsNotes[2]} ${detailsNotes[3]}";
        _notesTeacherDetails = (detailsNotes[4].startsWith("(Exported"))
            ? ""
            : "${detailsNotes[4]} ${detailsNotes[5]}";
      } else {
        _notesGroupDetails = detailsNotes[2];
        _notesTeacherDetails = (detailsNotes[3].startsWith("(Exported"))
            ? ""
            : "${detailsNotes[3]} ${detailsNotes[4]}";
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
