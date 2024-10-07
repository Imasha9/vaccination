import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vaccination/pages/update_appointments.dart';
import 'notification_page.dart';
import 'package:intl/intl.dart';

class ApproveAppointments extends StatefulWidget {
  @override
  _ApproveAppointmentsState createState() => _ApproveAppointmentsState();
}

class _ApproveAppointmentsState extends State<ApproveAppointments> {
  String filter = 'pending'; // Default filter
  String searchQuery = ''; // Holds the current search query
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.blue,
        elevation: 0,
        title: const Center(
          child: Text(
            'Manage Appointments',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
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
          color: Colors.white,
        ),
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
            SizedBox(height: 16),
            _buildSearchBar((query) {
              setState(() {
                searchQuery = query; // Update search query
              });
            }),
            SizedBox(height: 16),
            _buildAppointmentsContainer(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(ValueChanged<String> onSearchChanged) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white, // White background
        borderRadius: BorderRadius.circular(30), // Rounded corners
        border: Border.all(
          color: Colors.blue[900]!, // Dark blue border color
          width: 2, // Border width
        ),
      ),
      child: TextField(
        onChanged: onSearchChanged, // Call the function when the input changes
        decoration: InputDecoration(
          hintText:
              'username/ email/ description/ place',
          hintStyle: TextStyle(
            color: Colors.grey, // Set the color to gray
            fontSize: 15.0, // Reduce the font size
          ),// Placeholder text
          border: InputBorder.none, // Remove default border
          icon: Icon(Icons.search, color: Colors.blue[900]), // Search icon
        ),
      ),
    );
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
      stream: _getAppointmentsStream(filter, searchQuery),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator()); // Show loading indicator
        }

        if (snapshot.hasError) {
          // Display specific error message
          return Center(
              child: Text('Error loading appointments: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
              child:
                  Text('No appointments found.')); // Show message when no data
        }

        var appointments = snapshot.data!;
        return ListView.builder(
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            var appointment = appointments[index];

            // Format the starting and ending times
            String startTimeFormatted =
                DateFormat('HH:mm').format(appointment['startTime'].toDate());
            String endTimeFormatted =
                DateFormat('HH:mm').format(appointment['endTime'].toDate());

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
                            color: Colors.blueAccent // Center the description
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 8),
                    // Username
                    _buildDetailRowApp('Username:', appointment['username']),
                    _buildDetailRowApp('Email:', appointment['email']),
                    // Date (assuming you want to display the date)
                    _buildDetailRowApp(
                        'Date:',
                        DateFormat('yyyy-MM-dd')
                            .format(appointment['startTime'].toDate())),
                    // Starting Time
                    _buildDetailRowApp('Starting Time:', startTimeFormatted,
                        color: Colors.green),
                    _buildDetailRowApp('Ending Time:', endTimeFormatted,
                        color: Colors.red),
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

  Stream<List<QueryDocumentSnapshot>> _getAppointmentsStream(
      String filter, String query) async* {
    var collection = _firestore.collection("Appointments");

    Query appointmentQuery;

    // Apply filter based on appointment status
    if (filter == 'pending') {
      appointmentQuery = collection.where('status', isEqualTo: 'pending');
    } else if (filter == 'approved') {
      appointmentQuery = collection.where('status', isEqualTo: 'approved');
    } else if (filter == 'completed') {
      appointmentQuery = collection.where('status', isEqualTo: 'completed');
    } else {
      appointmentQuery = collection; // All appointments
    }

    // Handle search query
    if (query.isNotEmpty) {
      // Separate queries for each field
      var usernameQuery = appointmentQuery
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThanOrEqualTo: query + '\uf8ff');

      var emailQuery = appointmentQuery
          .where('email', isGreaterThanOrEqualTo: query)
          .where('email', isLessThanOrEqualTo: query + '\uf8ff');

      var descriptionQuery = appointmentQuery
          .where('description', isGreaterThanOrEqualTo: query)
          .where('description', isLessThanOrEqualTo: query + '\uf8ff');

      var placeQuery = appointmentQuery
          .where('place', isGreaterThanOrEqualTo: query)
          .where('place', isLessThanOrEqualTo: query + '\uf8ff');

      // Fetch results from each query
      var usernameResults = await usernameQuery.get();
      var emailResults = await emailQuery.get();
      var descriptionResults = await descriptionQuery.get();
      var placeResults = await placeQuery.get();

      // Combine all results into a set to avoid duplicates
      Set<QueryDocumentSnapshot> combinedResults = {
        ...usernameResults.docs,
        ...emailResults.docs,
        ...descriptionResults.docs,
        ...placeResults.docs,
      };

      // Return the combined results as a stream
      yield combinedResults.toList();
    } else {
      // No search query, return all appointments filtered by status
      yield* appointmentQuery
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs);
    }
  }

  // Build button group for filters
  Widget _buildButtonGroup() {
    List<String> buttons = ['Pending', 'Approved', 'Completed'];

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

  List<bool> _getSelectedState() {
    return [
      filter == 'pending',
      filter == 'approved',
      filter == 'completed',
    ];
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
            crossAxisAlignment:
                CrossAxisAlignment.start, // Left-align the content
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRowApp('Username:', appointment['username']),
              _buildDetailRowApp('Email:', appointment['email']),
              _buildDetailRowApp('Phone:', appointment['phone']),
              _buildDetailRowApp(
                  'Date:',
                  DateFormat('yyyy-MM-dd')
                      .format(appointment['startTime'].toDate())),
              _buildDetailRowApp('Starting Time:', startTimeFormatted,
                  color: Colors.green),
              _buildDetailRowApp('Ending Time:', endTimeFormatted,
                  color: Colors.red),
              _buildDetailRowApp('Place:', appointment['place'],),
              _buildDetailRowApp('Message:', appointment['optionalMessage']),
              _buildDetailRowApp('Status:', status,
                  color: _getStatusColor(status)),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(), // Dismiss popup
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.grey[300], // Light grey background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                ),
                padding: EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12), // Padding
              ),
              child: Text(
                'Close',
                style: TextStyle(color: Colors.black), // Black text color
              ),
            ),
            if (status == 'pending') ...[
              ElevatedButton(
                onPressed: () {
                  _approveAppointment(appointment.id);
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.green[400], // Green background color for update
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                  padding: EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12), // Padding
                ),
                child: Text(
                  'Approve',
                  style: TextStyle(color: Colors.white), // White text color
                ),
              ),
            ],
            if (status == 'approved') ...[
              ElevatedButton(
                onPressed: () {
                  _approveAppointmentCom(appointment.id);
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.green[400], // Green background color for update
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                  padding: EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12), // Padding
                ),
                child: Text(
                  'Complete',
                  style: TextStyle(color: Colors.white), // White text color
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  // Approve appointment and update Firestore
  Future<void> _approveAppointment(String appointmentId) async {
    try {
      await _firestore
          .collection('Appointments')
          .doc(appointmentId)
          .update({'status': 'approved'});

      await _firestore.collection('AppNotifications').add({
        'appointmentId': appointmentId,
        'userId': userId,
        'status': 'approved',
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Appointment approved successfully.')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to approve appointment: $e')));
    }
  }

  Future<void> _approveAppointmentCom(String appointmentId) async {
    try {
      await _firestore
          .collection('Appointments')
          .doc(appointmentId)
          .update({'status': 'completed'});

      final QuerySnapshot notificationSnapshot = await _firestore
          .collection('AppNotifications')
          .where('appointmentId', isEqualTo: appointmentId)
          .limit(1)
          .get();

      if (notificationSnapshot.docs.isNotEmpty) {
        final notificationDocId = notificationSnapshot.docs.first.id;
        await _firestore
            .collection('AppNotifications')
            .doc(notificationDocId)
            .update({
          'status': 'completed',
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Appointment completed successfully.')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to complete appointment: $e')));
    }
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }

  // Build a row with a label and value
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
}

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
    case 'Date:':
      iconData = Icons.calendar_today_rounded; // Gender icon
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

  bool isBold = title == 'Starting Time:' || title == 'Ending Time:' || title == 'Place:';

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(iconData, color: Colors.blue), // Icon for the title
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
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,// Make value bold
            ),
          ),
        ),
      ],
    ),
  );
}
