import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:vaccination/pages/calendar.dart';
import 'AdminVaccineApproval.dart';
import 'VaccinationIssuePage.dart';
import 'approve_appointments.dart';
import 'news.dart'; // Import your NewsPage
import 'notification_page.dart';
import 'posts_page.dart';
import 'emergency_contact.dart'; // Import the EmergencyContactPage
import 'package:vaccination/models/article.dart'; // Import your Article model class
import 'package:vaccination/services/auth.dart'; // Import AuthMethods

class AdminHomePage extends StatefulWidget {
  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  String? userName;

  // Current index for navigation bar
  int _currentIndex = 0;

  // Pages for navigation bar
  final List<Widget> _pages = [
    AdminHomeScreen(), // Custom widget displaying content of home page
    CalendarPage(),
    // Other pages like Community Post or Calendar
    // Add more pages here based on the navigation tabs you want
  ];

  @override
  void initState() {
    super.initState();
    getUserData(); // Fetch user name on init
  }

  // Method to get the current user's name
  void getUserData() async {
    User? user = FirebaseAuth.instance.currentUser; // Get the current logged-in user
    if (user != null) {
      String userId = user.uid; // Get the user's UID
      DocumentReference ref = FirebaseFirestore.instance.collection('users').doc(userId);

      ref.get().then((DocumentSnapshot snapshot) {
        if (snapshot.exists) {
          Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
          setState(() {
            userName = data?['name'] ?? 'User'; // Get the user's name
            String userEmail = data?['email'] ?? user.email ?? "Not available";
            String userNic = data?['nic'] ?? "Not available";
            print("Name: $userName, Email: $userEmail, NIC: $userNic"); // Debugging
          });
        } else {
          print("User data does not exist");
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFA2CFFE),

      body: SafeArea(
        child: Stack(
          children: [
            _pages[_currentIndex], // Display the page based on the current index

            // Image at the top center of the screen

            // User info display
            if (_currentIndex == 0)
              Positioned(
                top: 32, // Adjust based on the image height
                left: 16, // Display user info on the left side
                child: Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.center, // Align text and icon vertically
                  children: [
                    // Person Icon
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle, // Makes the background a circle
                        border: Border.all(
                            color: Colors.blueAccent,
                            width: 2), // Optional border
                      ),
                      padding: EdgeInsets.all(4), // Space between icon and border
                      child: Icon(Icons.person,
                          color: Colors.blue), // Person icon with color
                    ),
                    SizedBox(width: 16), // Add space between the icon and text
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment
                          .center, // Center vertically inside the row
                      children: [
                        // Greeting Text
                        Text(
                          'Hi !!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: 'Roboto',
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Username Text
                        Text(
                          userName ?? 'User',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontFamily: 'Roboto',
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            if (_currentIndex == 0)
              Positioned(
                top: 64,
                left: 32,
                right: 32,
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(top: 16), // Add padding if necessary
                  child: Image.asset(
                    'images/onb.png', // Replace with your image path
                    height: 100,
                    width: 100, // Adjust the height as needed
                    fit: BoxFit.cover, // Choose the appropriate fit
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF007AFD),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(33),  // Top-left radius
            topRight: Radius.circular(33), // Top-right radius
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              spreadRadius: 8,
              blurRadius: 12,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 2), // Increases height of the navigation bar
        child: SalomonBottomBar(
          currentIndex: _currentIndex,
          onTap: (int index) {
            setState(() {
              _currentIndex = index; // Update the selected page index
            });
          },
          items: [
            // Home Tab
            SalomonBottomBarItem(
              selectedColor: Colors.white, // Color of the selected item
              unselectedColor: Colors.black45, // Color of the unselected item
              icon: _currentIndex == 0
                  ? const Icon(Icons.home, size: 30.0,) // Filled icon when selected
                  : const Icon(Icons.home_outlined, size: 25.0,), // Outlined home icon
              title: const Text("Home"),
            ),
            // Events Tab
            SalomonBottomBarItem(
              selectedColor: Colors.white,
              unselectedColor: Colors.black45,
              icon: _currentIndex == 1
                  ? const Icon(Icons.calendar_today, size: 30.0,)
                  : const Icon(Icons.calendar_today_outlined, size: 25.0,), // Calendar icon
              title: const Text("Events"),
            ),
            // Add more items as needed
          ],
        ),
      ),
    );
  }
}

// Home page content widget
class AdminHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(height: 20),
                // Add latest appointments logic or placeholder here
              ],
            ),
          ),
        ),
        // Adjusted the second container to wrap according to button height
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50),
              topRight: Radius.circular(50),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          height: 500,
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // First Card for Vaccination Events
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: ListTile(
                    leading: Icon(Icons.event, color: Colors.blue, size: 50),
                    title: Text(
                      'Vaccination Events',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    subtitle: Text('Stay updated with vaccination events'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CalendarPage()),
                      );
                    },
                  ),
                ),
              ),

              // Second Card for Issue Responses
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: ListTile(
                    leading: Icon(Icons.report_problem, color: Colors.orange, size: 50),
                    title: Text(
                      'Vaccination Issues',

                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    subtitle: Text('Responses to vaccination issues'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>  VaccinationIssuePage()),
                      );
                    },
                  ),
                ),
              ), SizedBox(height: 16),
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: ListTile(
                    leading: Icon(Icons.approval, color: Colors.orange, size: 50),
                    title: Text(
                      'Approval',

                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    subtitle: Text('Responses to vaccination issues'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>  ApproveAppointments()),
                      );
                    },
                  ),
                ),
              ), SizedBox(height: 16),

            ],
          ),
        )
      ],
    );
  }
}
