import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database.dart';
import 'package:intl/intl.dart';
import '../pages/notification_page.dart';
import '../pages/add_appointment.dart';
import 'appbar.dart';

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
      print('Attempting to load events from Firestore...');

      final events = await _databaseMethods.getAllEvents();
      print(
          'Successfully retrieved events from Firestore. Processing events...');

      final newEvents = <DateTime, List<dynamic>>{};

      for (var doc in events.docs) {
        final event = doc.data() as Map<String, dynamic>;

        // Ensure the event has the document ID as 'id'
        event['id'] = doc.id; // doc.id is the Firestore document ID
        print(
            'Processing event with ID: ${event['id']}'); // This should now print the correct ID

        final date = event['date'];

        if (date is Timestamp) {
          final dateTime = date.toDate();
          final dateKey = DateTime(dateTime.year, dateTime.month, dateTime.day);

          if (newEvents[dateKey] == null) {
            newEvents[dateKey] = [];
          }
          newEvents[dateKey]!.add(event);
        } else {
          print(
              'Event does not contain a valid date (not a Timestamp): $event');
        }
      }

      setState(() {
        _events = newEvents;
      });

      print('State updated with loaded events.');
    } catch (e) {
      print('Error while loading events: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading events. Please try again later.'),
        ),
      );
    }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    // Log the day being queried for events
    print('Fetching events for day: ${DateFormat('yyyy-MM-dd').format(day)}');

    // Construct the key for the events map
    DateTime key = DateTime(day.year, day.month, day.day);

    // Get the events for the specific day
    List<dynamic> eventsForDay = _events[key] ?? [];

    // Log the number of events found for that day
    print(
        'Number of events found for ${DateFormat('yyyy-MM-dd').format(day)}: ${eventsForDay.length}');

    // Optionally, log each event's ID and title (if available)
    for (var event in eventsForDay) {
      print('Event ID: ${event['id']}, Title: ${event['title']}');
    }

    return eventsForDay;
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
      appBar: CommonAppBar(
        title: 'Vaccine Events', // Set the title for this page
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align text and buttons to the start (left)
        children: [
          // The header text at the top
          Text(
            'Book Your Appointments Here',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white, // Set text color to white
              fontWeight: FontWeight.bold, // Make text bold
            ),
          ),
          SizedBox(height: 10), // Add some space between the text and the row below

          // The row containing PopupMenuButton and IconButton below the text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Aligns dropdown and notification button
            children: [
              PopupMenuButton<CalendarFormat>(
                onSelected: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: CalendarFormat.month,
                    child: Text('Month View'),
                  ),
                  PopupMenuItem(
                    value: CalendarFormat.twoWeeks,
                    child: Text('2 Weeks View'),
                  ),
                  PopupMenuItem(
                    value: CalendarFormat.week,
                    child: Text('Week View'),
                  ),
                ],
                child: Row(
                  children: [
                    Text(
                      _calendarFormat == CalendarFormat.month
                          ? 'Month'
                          : _calendarFormat == CalendarFormat.twoWeeks
                          ? '2 Weeks'
                          : 'Week',
                      style: TextStyle(fontSize: 18, color: Colors.pink),
                    ),
                    Icon(Icons.arrow_drop_down, color: Colors.pink),
                  ],
                ),
              ),
              SizedBox(width: 16),

            ],
          ),
        ],
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
            color: Colors
                .lightGreenAccent, // Use the app bar color for event markers
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
          Center(
            // Center the text within the available width
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

        // Log event data for debugging
        for (var doc in snapshot.data!.docs) {
          if (doc.id.isEmpty) {
            print('Error: Document ID is empty for event: ${doc.data()}');
          } else {
            print('Valid Document ID: ${doc.id}'); // Log valid IDs
          }
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final event = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            String eventId = doc.id;
            print('Building UI for event with ID: $eventId'); // Use the document ID

            return GestureDetector(
              onTap: () {
                if (eventId.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RegisterAppointmentPage(eventId: eventId),
                    ),
                  );
                } else {
                  print('Event ID is null');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Event ID is missing')),
                  );
                }
              },
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                margin: EdgeInsets.only(bottom: 15),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          event['title'] ?? 'Untitled Appointment',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      _buildEventProperty(
                        Icons.access_time,
                        'Time:',
                        '${event['startTime'] ?? 'N/A'} - ${event['endTime'] ?? 'N/A'}',
                        color: Colors.green,
                      ),
                      _buildEventProperty(
                        Icons.location_on,
                        'Location:',
                        event['place'] ?? 'No location',
                        color: Colors.red,
                      ),
                      _buildEventProperty(
                        Icons.description,
                        'Description:',
                        event['description'] ?? 'No description',
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEventProperty(IconData icon, String title, String text, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10), // Increased spacing
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align items to the start
        children: [
          Icon(icon, size: 20, color: color ?? Colors.grey), // Increased icon size to 20
          SizedBox(width: 10),
          Expanded(
            child: Row( // Use Row instead of Column
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align items with space between
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold, // Bold title
                    color: Colors.black87,
                  ),
                ),
                Flexible( // Use Flexible to prevent overflow
                  child: Text(
                    text,
                    style: TextStyle(fontSize: 16, color: Colors.black87), // Increased text size
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end, // Align text to the end
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


}
