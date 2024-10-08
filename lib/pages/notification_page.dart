import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'appbar.dart'; // For time formatting

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  String _selectedSegment = 'appointments'; // Tracks selected button
  String? userId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid; // Get the current user ID
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: 'Notifications',
        showNotificationIcon: false,// Set the title for this page
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Colors.white],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Segmented buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSegmentedButton(),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // White rounded top corner container for notifications
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: StreamBuilder<QuerySnapshot>(
                  stream: _selectedSegment == 'appointments'
                      ? _getUserNotifications(userId!) // Fetch appointments
                      : _getAllNotifications(), // Fetch all notifications
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No notifications available."));
                    }

                    final notifications = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index].data() as Map<String, dynamic>;

                        if (_selectedSegment == 'appointments') {
                          return _buildAppointmentNotification(notification, notifications[index].id);
                        } else {
                          return _buildCommonNotification(notification);
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showDeleteConfirmationDialog,
        backgroundColor: Colors.red,
        child: const Icon(Icons.delete),
      ),
    );
  }

  // Build segmented button
  Widget _buildSegmentedButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.0),
        border: Border.all(color: Colors.white),
      ),
      child: ToggleButtons(
        isSelected: [_selectedSegment == 'appointments', _selectedSegment == 'common'],
        onPressed: (int index) {
          setState(() {
            _selectedSegment = index == 0 ? 'appointments' : 'common';
          });
        },
        borderRadius: BorderRadius.circular(20.0),
        selectedBorderColor: Colors.white,
        selectedColor: Colors.white,
        fillColor: Colors.blue[900],
        color: Colors.white,
        borderColor: Colors.white,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('Appointments'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('Common'),
          ),
        ],
      ),
    );
  }

  // Build appointment notification item with Mark as Read and Delete buttons
  Widget _buildAppointmentNotification(Map<String, dynamic> notification, String notificationId) {
    String status = notification['status'] ?? 'unknown';
    String appointmentId = notification['appointmentId'] ?? '';
    int readStatus = notification['readStatus'] ?? 0;

    Color? backgroundColor;
    if (readStatus == 1) {
      backgroundColor = Colors.grey[200]!; // Gray background for read notifications
    } else if (status == 'approved') {
      backgroundColor = Colors.green[100]; // Green accent background for approved
    } else if (status == 'completed') {
      backgroundColor = Colors.orange[100]!; // Orange accent background for completed
    } else {
      backgroundColor = Colors.grey;
    }

    if (status == 'approved' || status == 'completed') {
      return FutureBuilder<int>(
        future: _getQueueNumber(appointmentId), // Generates the queue number
        builder: (context, queueSnapshot) {
          if (queueSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!queueSnapshot.hasData) {
            return const Center(child: Text("Unable to get queue number."));
          }

          int queueNumber = queueSnapshot.data ?? -1;

          return FutureBuilder<DocumentSnapshot>(
            future: _getAppointmentDetails(appointmentId), // Fetch appointment details
            builder: (context, appointmentSnapshot) {
              if (appointmentSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!appointmentSnapshot.hasData || !appointmentSnapshot.data!.exists) {
                return const Center(child: Text("Appointment details not found."));
              }

              // Extract appointment details
              var appointmentData = appointmentSnapshot.data!.data() as Map<String, dynamic>;
              String place = appointmentData['place'] ?? 'N/A';
              String startTime = appointmentData['startTime'] != null
                  ? DateFormat('hh:mm a').format((appointmentData['startTime'] as Timestamp).toDate())
                  : 'N/A';
              String endTime = appointmentData['endTime'] != null
                  ? DateFormat('hh:mm a').format((appointmentData['endTime'] as Timestamp).toDate())
                  : 'N/A';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: backgroundColor, // Set the background color based on status
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0), // More rounded corners
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'An admin has approved your appointment.',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow(Icons.confirmation_number, 'Queue Number', queueNumber.toString()),
                      const SizedBox(height: 8),
                      _buildDetailRow(Icons.title, 'Title', notification['title'] ?? 'N/A'),
                      _buildDetailRow(
                        Icons.access_time,
                        'Starting Time',
                        startTime,
                        valueStyle: TextStyle(fontSize: 16, color: Colors.green[900], fontWeight: FontWeight.bold),
                      ),
                      _buildDetailRow(
                        Icons.access_time,
                        'Ending Time',
                        endTime,
                        valueStyle: const TextStyle(fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                      _buildDetailRow(Icons.place, 'Place', place),
                      const SizedBox(height: 8),
                      // Mark as Read and Delete buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (readStatus != 1)
                            TextButton(
                              onPressed: () => _markAsRead(notificationId),
                              child: const Text(
                                'Mark as Read',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold, // Bold text
                                ),
                              ),
                            ),
                          TextButton(
                            onPressed: () => _showDeleteConfirmationDialogForOne(notificationId),
                            child: const Text(
                              'Delete',
                              style: TextStyle(
                                fontWeight: FontWeight.bold, // Bold text
                                color: Colors.red,           // Red color for the text
                              ),
                            ),
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
    } else {
      return const SizedBox.shrink(); // Return nothing if status is not approved or completed
    }
  }

  // Method to mark a notification as read
  Future<void> _markAsRead(String notificationId) async {
    await FirebaseFirestore.instance.collection('AppNotifications').doc(notificationId).update({
      'readStatus': 1,
    });
  }

  void _showDeleteConfirmationDialogForOne(String notificationId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Notification'),
          content: const Text('Are you sure you want to delete this notification?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog without deleting
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                _deleteNotification(notificationId); // Call the delete method for this specific notification
                Navigator.of(context).pop(); // Close the dialog after deleting
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  // Method to delete a notification
  Future<void> _deleteNotification(String notificationId) async {
    await FirebaseFirestore.instance.collection('AppNotifications').doc(notificationId).delete();
  }

  // Method to delete all notifications of the user
  Future<void> _deleteAllNotifications() async {
    var notifications = await FirebaseFirestore.instance
        .collection('AppNotifications')
        .where('userId', isEqualTo: userId)
        .get();

    for (var doc in notifications.docs) {
      await doc.reference.delete();
    }
  }

  // Method to fetch user-specific notifications from AppNotifications collection (sorted by readStatus)
  Stream<QuerySnapshot> _getUserNotifications(String userId) {
    return FirebaseFirestore.instance
        .collection('AppNotifications')
        .where('userId', isEqualTo: userId) // Sort by readStatus: viewed first, then read
        .orderBy('readStatus')
        .snapshots();
  }

  // Build common notification item
  Widget _buildCommonNotification(Map<String, dynamic> notification) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: const Color(0xFFDFF2FF),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification['message'] ?? 'No message',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
            ),
            const SizedBox(height: 8),
            Text(
              notification['timestamp'] != null
                  ? notification['timestamp'].toDate().toString()
                  : 'No timestamp',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // Method to fetch all notifications from Notifications collection
  Stream<QuerySnapshot> _getAllNotifications() {
    return FirebaseFirestore.instance.collection('Notifications').snapshots();
  }

  // Helper widget to build detail rows with icons
  Widget _buildDetailRow(IconData icon, String label, String value, {TextStyle? valueStyle}) {
    return Row(
      children: [
        Icon(icon, color: Colors.black, size: 24), // All icons in black
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 16),
        ),
        Text(
          value,
          style: valueStyle ?? const TextStyle(fontSize: 16), // Use provided style or default
        ),
      ],
    );
  }

  Future<DocumentSnapshot> _getAppointmentDetails(String appointmentId) async {
    return FirebaseFirestore.instance
        .collection('Appointments')
        .doc(appointmentId)
        .get();
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete All Notifications'),
          content: const Text('Are you sure you want to delete all appointment notifications?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                _deleteAllNotifications(); // Call the method to delete all notifications
                Navigator.of(context).pop(); // Close the dialog after deleting
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  Future<int> _getQueueNumber(String appointmentId) async {
    DocumentSnapshot appointmentSnapshot = await FirebaseFirestore.instance
        .collection('Appointments')
        .doc(appointmentId)
        .get();

    if (!appointmentSnapshot.exists) {
      return -1; // If the appointment does not exist, return -1
    }

    var appointmentData = appointmentSnapshot.data() as Map<String, dynamic>;
    String eventId = appointmentData['eventId']; // Get the eventId from the appointment

    QuerySnapshot appointmentsSnapshot = await FirebaseFirestore.instance
        .collection('Appointments')
        .where('eventId', isEqualTo: eventId)
        .orderBy('timestamp') // Order by timestamp to assign queue number based on time
        .get();

    List<DocumentSnapshot> allAppointments = appointmentsSnapshot.docs;
    for (int i = 0; i < allAppointments.length; i++) {
      if (allAppointments[i].id == appointmentId) {
        return i + 1; // Queue number starts from 1
      }
    }

    return -1; // Return -1 if appointmentId not found in the list (this shouldn't happen)
  }
}
