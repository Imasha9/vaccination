import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final DatabaseMethods _databaseMethods = DatabaseMethods();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _databaseMethods.getNotifications(),
        builder: (context, snapshot) {
          // Show loading indicator while waiting for data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Check if there are no notifications
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No notifications available."));
          }

          final notifications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: Color(0xFFDFF2FF),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Notification Message
                      Text(
                        notification['message'] ?? 'No message',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 8), // Add spacing between message and timestamp
                      // Notification Timestamp
                      Text(
                        notification['timestamp'] != null
                            ? notification['timestamp'].toDate().toString()
                            : 'No timestamp',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
