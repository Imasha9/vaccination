import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:vaccination/pages/community_post.dart';
import 'package:vaccination/pages/home_page.dart';

import '../pages/VaccinationDetails.dart';
import '../pages/calendar.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  final List<Widget> _pages = [
    HomePage(),
    CalendarPage(),
    VaccinationForm(),
    CommunityPost(),

  ];

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: SalomonBottomBar(
        backgroundColor: Color(0xFF17C2EC), // Background color of the bar
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          SalomonBottomBarItem(
            selectedColor: Colors.black45, // Color of the selected item
            unselectedColor: Colors.grey, // Color of the unselected item
            icon: const Icon(Icons.home),
            title: const Text("Home"),
          ),
          SalomonBottomBarItem(
            selectedColor: Colors.black45, // Color of the selected item
            unselectedColor: Colors.grey, // Color of the unselected item
            icon: const Icon(Icons.calendar_month),
            title: const Text("Appointments"),
          ),
          SalomonBottomBarItem(
            selectedColor: Colors.black45,
            unselectedColor: Colors.grey,
            icon: const Icon(Icons.vaccines),
            title: const Text("records"),
          ),
          SalomonBottomBarItem(
            selectedColor: Colors.black45,
            unselectedColor: Colors.grey,
            icon: const Icon(Icons.person),
            title: const Text("Profile"),
          ),

        ],
      ),
    );
  }
}
