import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database.dart';

import 'notification_page.dart';
import 'package:intl/intl.dart';


class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
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
        SnackBar(content: Text('Error loading events. Please try again later.')),
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

  void _showAddEventDialog({Map<String, dynamic>? existingEvent}) {
    final _formKey = GlobalKey<FormState>();
    String title = existingEvent?['title'] ?? '';
    String description = existingEvent?['description'] ?? '';
    String place = existingEvent?['place'] ?? '';
    String startTime = existingEvent?['startTime'] ?? '';
    String endTime = existingEvent?['endTime'] ?? '';
    DateTime selectedDate = existingEvent != null
        ? (existingEvent['date'] as Timestamp).toDate()
        : _selectedDay;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(existingEvent == null ? 'Add Event' : 'Edit Event'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: title,
                    decoration: InputDecoration(labelText: 'Title'),
                    validator: (value) => value!.isEmpty ? 'Title cannot be empty' : null,
                    onSaved: (value) => title = value!,
                  ),
                  TextFormField(
                    initialValue: description,
                    decoration: InputDecoration(labelText: 'Description'),
                    onSaved: (value) => description = value!,
                  ),
                  TextFormField(
                    initialValue: place,
                    decoration: InputDecoration(labelText: 'Place'),
                    onSaved: (value) => place = value!,
                  ),
                  TextFormField(
                    initialValue: startTime,
                    decoration: InputDecoration(labelText: 'Start Time (HH:MM)'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Start time cannot be empty';
                      }
                      // Validate time format (HH:MM)
                      final timeParts = value.split(':');
                      if (timeParts.length != 2 ||
                          int.tryParse(timeParts[0]) == null ||
                          int.tryParse(timeParts[1]) == null) {
                        return 'Please enter a valid time in HH:MM format';
                      }
                      return null;
                    },
                    onSaved: (value) => startTime = value!,
                  ),
                  TextFormField(
                    initialValue: endTime,
                    decoration: InputDecoration(labelText: 'End Time (HH:MM)'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'End time cannot be empty';
                      }
                      // Validate time format (HH:MM)
                      final timeParts = value.split(':');
                      if (timeParts.length != 2 ||
                          int.tryParse(timeParts[0]) == null ||
                          int.tryParse(timeParts[1]) == null) {
                        return 'Please enter a valid time in HH:MM format';
                      }
                      return null;
                    },
                    onSaved: (value) => endTime = value!,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null && pickedDate != selectedDate) {
                        setState(() {
                          selectedDate = pickedDate;
                        });
                      }
                    },
                    child: Text('Pick Event Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  if (existingEvent == null) {
                    await _databaseMethods.addEvent(
                      "userId", // Replace with actual user ID
                      title,
                      description,
                      place,
                      selectedDate,
                      startTime,
                      endTime,
                    );
                  } else {
                    await _databaseMethods.updateEvent(
                      existingEvent['id'],
                      "userId", // Replace with actual user ID
                      title,
                      description,
                      place,
                      selectedDate,
                      startTime,
                      endTime,
                    );
                  }
                  Navigator.pop(context);
                  _loadEvents();
                  setState(() {});
                }
              },
              child: Text(existingEvent == null ? 'Add' : 'Update'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFA2CFFE),

      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildCalendar(),
            SizedBox(height: 20),
            Expanded(child: _buildEventList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEventDialog(),
        child: Icon(Icons.add),
        backgroundColor: Colors.pink,
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

            ],
          ),
          Row(

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
              IconButton(
                icon: Icon(Icons.notifications, color: Colors.pink),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationPage()),
                ),
              ),
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
            color: Colors.pink.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: Colors.pink,
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          leftChevronIcon: Icon(Icons.chevron_left, color: Colors.pink),
          rightChevronIcon: Icon(Icons.chevron_right, color: Colors.pink),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(fontWeight: FontWeight.bold),
          weekendStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
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

  Widget _buildEventList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _databaseMethods.getEventsForDay(_selectedDay),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: Colors.pink));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No events for ${DateFormat('MMMM d, yyyy').format(_selectedDay)}',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final event = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            final eventId = snapshot.data!.docs[index].id;

            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              margin: EdgeInsets.only(bottom: 15),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left side with place
                    Container(
                      width: 100,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          bottomLeft: Radius.circular(15),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          event['place'] ?? 'No location',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    // Vertical divider
                    VerticalDivider(width: 1, color: Colors.grey),
                    // Right side with event details
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Row for the title with icon
                            Row(
                              children: [
                                Icon(Icons.event, size: 20, color: Colors.blue), // Icon for title
                                SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    event['title'] ?? 'Untitled Event',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            // Row for time with icons
                            Row(
                              children: [
                                Icon(Icons.access_time, size: 20, color: Colors.green),
                                SizedBox(width: 5),
                                Text(
                                  '${event['startTime'] ?? 'N/A'}',
                                  style: TextStyle(fontSize: 16, color: Colors.black87),
                                ),
                                SizedBox(width: 5),
                                Icon(Icons.arrow_forward, size: 20, color: Colors.grey),
                                SizedBox(width: 5),
                                Text(
                                  '${event['endTime'] ?? 'N/A'}',
                                  style: TextStyle(fontSize: 16, color: Colors.black87),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            // Row for place with icon
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 20, color: Colors.red), // Icon for place
                                SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    event['place'] ?? 'No location provided',
                                    style: TextStyle(fontSize: 16, color: Colors.black87),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            // Row for description with icon
                            Row(
                              children: [
                                Icon(Icons.description, size: 20, color: Colors.orange), // Icon for description
                                SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    event['description'] ?? 'No description',
                                    style: TextStyle(fontSize: 14, color: Colors.grey),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
,
                    // Edit and Delete buttons
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showAddEventDialog(existingEvent: {...event, 'id': eventId}),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _showDeleteConfirmationDialog(eventId),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEventProperty(IconData icon, String value, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16, color: Colors.black87),
              overflow: TextOverflow.ellipsis, // Ensure long text is truncated properly
            ),
          ),
        ],
      ),
    );
  }


  void _showDeleteConfirmationDialog(String eventId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Event'),
          content: Text('Are you sure you want to delete this event?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _databaseMethods.deleteEvent(eventId);
                Navigator.pop(context);
                _loadEvents();
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
