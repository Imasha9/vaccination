import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vaccination/pages/update_appointments.dart';
import 'package:vaccination/pages/user_calendar.dart';
import 'appbar.dart';
import 'notification_page.dart';
import 'package:intl/intl.dart';

class MyAppointments extends StatefulWidget {
  @override
  _MyAppointmentsState createState() => _MyAppointmentsState();
}

class _MyAppointmentsState extends State<MyAppointments> {
  String filter = 'pending'; // Default filter
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: 'My Appointments', // Set the title for this page
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 16),
            _buildButtonGroup(),
            _buildGoToCalendarButton(),
            SizedBox(height: 16),
            _buildAppointmentsContainer(),
          ],
        ),
      ),
    );
  }

  // Build button group for filters
  Widget _buildButtonGroup() {
    List<String> buttons = ['Pending', 'Today', 'Upcoming', 'Completed'];

    return ToggleButtons(
      isSelected: _getSelectedState(),
      onPressed: (int index) {
        setState(() {
          filter = buttons[index].toLowerCase();
        });
      },
      color: Colors.white,
      selectedColor: Colors.white,
      fillColor: Colors.blue[900],
      borderColor: Colors.white,
      selectedBorderColor: Colors.white,
      borderRadius: BorderRadius.circular(30),
      constraints: BoxConstraints(minHeight: 45.0, minWidth: 80.0),
      children: buttons.map((text) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Text(text),
        );
      }).toList(),
    );
  }

  Widget _buildGoToCalendarButton() {
    return Container(
      margin: EdgeInsets.only(top: 16), // Adds a top margin of 16 pixels
      child: ElevatedButton(
        onPressed: () {
          // Navigate to the calendar page when pressed
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserCalendarPage(), // Assuming you have a CalendarPage widget
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[900], // Blue background color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // Rounded corners
          ),
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12), // Padding for the button
        ),
        child: Text(
          'Go to Calendar',
          style: TextStyle(
            color: Colors.white, // White text color
            fontSize: 16, // Font size
          ),
        ),
      ),
    );
  }


  List<bool> _getSelectedState() {
    return [
      filter == 'pending',
      filter == 'today',
      filter == 'upcoming',
      filter == 'completed',
    ];
  }

  Widget _buildAppointmentsContainer() {
    return Expanded(
      child: Container(
        margin: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: _buildAppointmentsList(),
      ),
    );
  }

  Widget _buildAppointmentsList() {
    return StreamBuilder<List<QueryDocumentSnapshot>>(
      stream: _getAppointmentsStream(filter),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // Show loading indicator
        }

        if (snapshot.hasError) {
          // Display specific error message
          return Center(child: Text('Error loading appointments: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No appointments found.')); // Show message when no data
        }

        var appointments = snapshot.data!;
        return ListView.builder(
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            var appointment = appointments[index];

            // Format the starting and ending times
            String startTimeFormatted = DateFormat('HH:mm').format(appointment['startTime'].toDate());
            String endTimeFormatted = DateFormat('HH:mm').format(appointment['endTime'].toDate());

            return GestureDetector(
              onTap: () => _showAppointmentDetailsDialog(appointment),
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white12, // White background color
                  borderRadius: BorderRadius.circular(30), // Rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 0,
                      blurRadius: 0,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Description
                    Center(
                      child: Text(
                        appointment['description'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.blueAccent// Center the description
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 8),
                    // Username
                    _buildDetailRowApp('Username:', appointment['username']),
                    // Date (assuming you want to display the date)
                    _buildDetailRowApp('Date:', DateFormat('yyyy-MM-dd').format(appointment['startTime'].toDate())),
                    // Starting Time
                    _buildDetailRowApp('Starting Time:', startTimeFormatted, color: Colors.green),
                    // Ending Time
                    _buildDetailRowApp('Ending Time:', endTimeFormatted, color: Colors.red),
                    // Place
                    _buildDetailRowApp('Place:', appointment['place']),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

// Helper method to build detail rows
  Widget _buildDetailRowApp(String title, String value, {Color? color}) {
    IconData iconData;

    // Determine which icon to show based on the title
    switch (title) {
      case 'Username:':
        iconData = Icons.person; // User icon
        break;
      case 'Email:':
        iconData = Icons.email; // Email icon
        break;
      case 'Phone:':
        iconData = Icons.phone; // Phone icon
        break;
      case 'Gender:':
        iconData = Icons.wc; // Gender icon
        break;
      case 'Starting Time:':
        iconData = Icons.access_time; // Clock icon
        break;
      case 'Ending Time:':
        iconData = Icons.access_time; // Clock icon
        break;
      case 'Place:':
        iconData = Icons.place; // Place icon
        break;
      case 'Message:':
        iconData = Icons.message; // Message icon
        break;
      case 'Status:':
        iconData = Icons.check_circle; // Status icon
        break;
      default:
        iconData = Icons.info; // Default info icon
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(iconData, color: Colors.black), // Icon for the title
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: color ?? Colors.black,
                fontWeight: FontWeight.bold, // Make value bold
              ),
            ),
          ),
        ],
      ),
    );
  }





  // Fetch appointments based on the selected filter
  Stream<List<QueryDocumentSnapshot>> _getAppointmentsStream(String filter) {
    DateTime today = DateTime.now();
    Timestamp startOfDay = Timestamp.fromDate(DateTime(today.year, today.month, today.day));
    Timestamp endOfDay = Timestamp.fromDate(startOfDay.toDate().add(Duration(days: 1)).subtract(Duration(milliseconds: 1)));

    String? userId = FirebaseAuth.instance.currentUser?.uid; // Get the current user's ID

    if (userId!.isEmpty) {
      return Stream.error("User not authenticated"); // Return an error if the user is not authenticated
    }

    try {
      if (filter == 'pending') {
        return _firestore
            .collection("Appointments")
            .where('userId', isEqualTo: userId) // Filter by userId
            .where('status', isEqualTo: 'pending')
            .orderBy('timestamp', descending: true)
            .snapshots()
            .map((snapshot) => snapshot.docs);
      } else if (filter == 'today') {
        return _firestore
            .collection("Appointments")
            .where('userId', isEqualTo: userId) // Filter by userId
            .where('status', isEqualTo: 'approved')
            .where('startTime', isGreaterThanOrEqualTo: startOfDay)
            .where('startTime', isLessThanOrEqualTo: endOfDay)
            .snapshots()
            .map((snapshot) => snapshot.docs);
      } else if (filter == 'upcoming') {
        Timestamp currentTimestamp = Timestamp.now();
        return _firestore
            .collection("Appointments")
            .where('userId', isEqualTo: userId) // Filter by userId
            .where('status', isEqualTo: 'approved')
            .where('startTime', isGreaterThan: currentTimestamp)
            .snapshots()
            .map((snapshot) => snapshot.docs);
      } else if (filter == 'completed') {
        return _firestore
            .collection("Appointments")
            .where('userId', isEqualTo: userId) // Filter by userId
            .where('status', isEqualTo: 'completed')
            .snapshots()
            .map((snapshot) => snapshot.docs);
      }
    } catch (e) {
      print("Error fetching appointments for filter $filter: $e");
      return Stream.error("Error loading appointments");
    }

    return Stream.value([]); // Return empty list stream for unmatched cases
  }




  // Show appointment details in a popup
  void _showAppointmentDetailsDialog(DocumentSnapshot appointment) {
    // Format start and end times
    String startTimeFormatted = _formatTime(appointment['startTime'].toDate());
    String endTimeFormatted = _formatTime(appointment['endTime'].toDate());

    // Get status
    String status = appointment['status'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Appointment Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Left-align the content
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Username:', appointment['username']),
              _buildDetailRow('Email:', appointment['email']),
              _buildDetailRow('Phone:', appointment['phone']),
              _buildDetailRow('Gender:', appointment['gender']),
              _buildDetailRow('Starting Time:', startTimeFormatted, color: Colors.green, isBold: true, isValueBold: true), // Starting time bold label and value
              _buildDetailRow('Ending Time:', endTimeFormatted, color: Colors.red, isBold: true, isValueBold: true), // Ending time bold label and value
              _buildDetailRow('Place:', appointment['place'], isBold: true, isValueBold: true), // Place bold label and value
              _buildDetailRow('Message:', appointment['optionalMessage']),
              SizedBox(height: 16),
              _buildDetailRow(
                  'Status:',
                  status,
                  color: _getStatusColor(status), // Status color
                  isBold: true
              ),
            ],
          ),
          actions: [
            // Back Button
            // Back Button
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(), // Dismiss popup
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300], // Light grey background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Padding
              ),
              child: Text(
                'Back',
                style: TextStyle(color: Colors.black), // Black text color
              ),
            ),

// Show "Delete" and "Update" buttons only if status is pending
            if (status == 'pending') ...[
              ElevatedButton(
                onPressed: () => _showCancelConfirmation(appointment.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[400], // Red background color for delete
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Padding
                ),
                child: Text(
                  'Delete',
                  style: TextStyle(color: Colors.white), // White text color
                ),
              ),
              ElevatedButton(
                onPressed: () => _navigateToUpdatePage(appointment),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[400], // Green background color for update
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Padding
                ),
                child: Text(
                  'Update',
                  style: TextStyle(color: Colors.white), // White text color
                ),
              ),
            ],

          ],
        );
      },
    );
  }

// Helper method to format time as 'HH:mm'
  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

// Helper method to build a row with a bold title and normal value
  Widget _buildDetailRow(String title, String value, {Color? color, bool isBold = false, bool isValueBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal, // Make title bold if isBold is true
              color: Colors.black,
            ),
          ),
          SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: isValueBold ? FontWeight.bold : FontWeight.normal, // Make value bold if isValueBold is true
              color: color ?? Colors.black, // Use the provided color or default to black
            ),
          ),
        ],
      ),
    );
  }



// Helper method to get status color
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.red; // Pending in red
      case 'approved':
        return Colors.blue; // Approved in blue
      case 'completed':
        return Colors.green; // Completed in green
      default:
        return Colors.black;
    }
  }


  // Show cancel confirmation
  void _showCancelConfirmation(String appointmentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cancel Appointment'),
          content: Text('Are you sure you want to cancel this appointment?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                _deleteAppointment(appointmentId);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  // Delete appointment from Firestore
  Future<void> _deleteAppointment(String appointmentId) {
    return _firestore.collection("Appointments").doc(appointmentId).delete();
  }

  // Navigate to appointment update page
  void _navigateToUpdatePage(DocumentSnapshot appointment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateAppointments(appointment: {
          'id': appointment.id, // Add the document ID
          ...appointment.data() as Map<String, dynamic>, // Convert to Map
        },),
      ),
    );
  }
}
