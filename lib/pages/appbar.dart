import 'package:badges/badges.dart' as badges; // Import the badges package
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'notification_page.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title; // Title for each page
  final bool showNotificationIcon; // Flag to control notification icon visibility

  CommonAppBar({required this.title, this.showNotificationIcon = true}); // Default to true

  // Method to fetch unread appointment notifications (readStatus = 0)
  Stream<QuerySnapshot> _getUnreadAppointmentNotifications() {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    return FirebaseFirestore.instance
        .collection('AppNotifications')
        .where('userId', isEqualTo: userId)
        .where('readStatus', isEqualTo: 0) // Fetch only unread appointment notifications
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    bool canGoBack = Navigator.of(context).canPop(); // Check if there's a back button

    return AppBar(
      automaticallyImplyLeading: false, // Disable default leading widget behavior
      backgroundColor: Colors.blue, // Top blue background
      elevation: 0,
      leading: canGoBack
          ? IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white), // Custom back button
        onPressed: () {
          Navigator.of(context).pop(); // Navigate back
        },
      )
          : const SizedBox(width: 48), // Placeholder when no back button, width matches IconButton
      title: LayoutBuilder(
        builder: (context, constraints) {
          // Try different font sizes and find one that fits
          double fontSize = _getTitleFontSize(title, constraints.maxWidth);

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white, // Title color
                  fontSize: fontSize,  // Dynamically calculated font size
                  fontWeight: FontWeight.bold, // Font style
                ),
              ),
            ],
          );
        },
      ),
      actions: showNotificationIcon
          ? [
        StreamBuilder<QuerySnapshot>(
          stream: _getUnreadAppointmentNotifications(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return IconButton(
                icon: const Icon(
                  Icons.notifications,
                  color: Colors.white, // Notification icon color
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationPage()),
                  );
                },
              );
            }

            // Count unread notifications
            int unreadCount = snapshot.data!.docs.length;

            return IconButton(
              icon: badges.Badge(
                position: badges.BadgePosition.topEnd(top: -10, end: -5),
                showBadge: unreadCount > 0,
                badgeContent: Text(
                  unreadCount.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
                badgeStyle: badges.BadgeStyle(badgeColor: Colors.red), // Red badge color
                child: const Icon(
                  Icons.notifications,
                  color: Colors.white,
                  size: 30,// Notification icon color
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationPage()),
                );
              },
            );
          },
        ),
      ]
          : [const SizedBox(width: 48)], // Placeholder when no notification icon
      iconTheme: const IconThemeData(
        color: Colors.white, // Back button color
      ),
    );
  }

  // Function to determine the appropriate font size based on title length and available space
  double _getTitleFontSize(String title, double maxWidth) {
    // Start with a large font size
    double fontSize = 30.0;
    TextPainter textPainter;

    do {
      textPainter = TextPainter(
        text: TextSpan(
          text: title,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      // Reduce the font size if the text is too wide
      if (textPainter.size.width > maxWidth) {
        fontSize -= 1.0; // Decrease the font size
      } else {
        break; // Break if the text fits
      }
    } while (fontSize > 12.0); // Avoid going below a minimum font size

    return fontSize;
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
