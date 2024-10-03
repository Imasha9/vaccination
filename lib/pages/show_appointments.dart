import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database.dart';
import 'package:intl/intl.dart';
import '../pages/notification_page.dart';

class ShowAppointmentsPage extends StatefulWidget {
  const ShowAppointmentsPage({Key? key}) : super(key: key);

  @override
  State<ShowAppointmentsPage> createState() => _ShowAppointmentsPageState();
}

class _ShowAppointmentsPageState extends State<ShowAppointmentsPage> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  final DatabaseMethods _databaseMethods = DatabaseMethods();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  Map<DateTime, List<dynamic>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final events = await _databaseMethods.getAllEvents();
      final newEvents = <DateTime, List<dynamic>>{};
      for (var doc in events.docs) {
        final event = doc.data() as Map<String, dynamic>;
        event['id'] = doc.id;
        final date = event['date'];
        if (date is Timestamp) {
          final dateTime = date.toDate();
          final dateKey = DateTime(dateTime.year, dateTime.month, dateTime.day);
          if (newEvents[dateKey] == null) newEvents[dateKey] = [];
          newEvents[dateKey]!.add(event);
        }
      }
      setState(() {
        _events = newEvents;
      });
    } catch (e) {
      print('Error loading events: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error loading events. Please try again later.')),
      );
    }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading:
            true, // This ensures the back button is shown
        backgroundColor: Colors.blue, // Top blue background
        elevation: 0,
        title: const Center(
          // Center the title
          child: Text(
            'Appointments',
            style: TextStyle(
                color: Colors.white, // Change title color to white
                fontSize: 30,
                fontWeight: FontWeight.bold // Adjust font size if needed
                ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications,
                color: Colors.white), // Change notification icon color to white
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const NotificationPage()),
              );
            },
          ),
        ],
        iconTheme: const IconThemeData(
          color: Colors.white, // Change the back button color to white
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue, // Start color
              Colors.white, // End color
            ],
            begin: Alignment.topCenter, // Gradient direction
            end: Alignment.bottomCenter,
            stops: [0.0, 0.9],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildCalendar(),
              SizedBox(height: 20),
              Expanded(child: _buildTodayEventContainer()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Center( // Center the text
        child: Text(
          'Book Your Appointments Here',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white, // Set text color to white
            fontWeight: FontWeight.bold, // Make text bold
          ),
        ),
      ),
    );
  }


  Widget _buildCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: TableCalendar(
        firstDay: DateTime.utc(2010, 10, 16),
        lastDay: DateTime.utc(2030, 3, 14),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        calendarFormat: _calendarFormat,
        eventLoader: _getEventsForDay,
        startingDayOfWeek: StartingDayOfWeek.monday,
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: TextStyle(color: Colors.red),
          holidayTextStyle: TextStyle(color: Colors.red),
          todayDecoration: BoxDecoration(
            color:
                Colors.blue.withOpacity(0.3), // Use the app bar color palette
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: Colors.blue, // Use the app bar color
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: Colors.lightGreenAccent, // Use the app bar color for event markers
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          leftChevronIcon: Icon(Icons.chevron_left, color: Colors.blue),
          rightChevronIcon: Icon(Icons.chevron_right, color: Colors.blue),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(fontWeight: FontWeight.bold),
          weekendStyle:
              TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
        ),
        onDaySelected: _onDaySelected,
        onPageChanged: (focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
          });
        },
      ),
    );
  }

  Widget _buildTodayEventContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Background color for the event container
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30), // Rounded top corners
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 3,
            blurRadius: 7,
            offset: Offset(0, -3), // Shadow for the container
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center( // Center the text within the available width
            child: Text(
              'Events for Today',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: _buildEventList(),
          ),
        ],
      ),

    );
  }

  Widget _buildEventList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _databaseMethods.getEventsForDay(_selectedDay),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: Colors.blue));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No appointments for ${DateFormat('MMMM d, yyyy').format(_selectedDay)}',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final event =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              margin: EdgeInsets.only(bottom: 15),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event['title'] ?? 'Untitled Appointment',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    _buildEventProperty(Icons.access_time,
                        '${event['startTime'] ?? 'N/A'} - ${event['endTime'] ?? 'N/A'}'),
                    _buildEventProperty(
                        Icons.location_on, event['place'] ?? 'No location'),
                    _buildEventProperty(Icons.description,
                        event['description'] ?? 'No description'),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEventProperty(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          SizedBox(width: 5),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
