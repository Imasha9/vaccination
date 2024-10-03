import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:vaccination/pages/community_post.dart';
import 'package:vaccination/pages/home_page.dart';
import '../pages/VaccinationDetails.dart';
import '../pages/admin_home.dart';
import '../pages/calendar.dart';


class AdminNavBar extends StatefulWidget {
  const AdminNavBar({super.key});

  @override
  State<AdminNavBar> createState() => _AdminNavBarState();
}

class _AdminNavBarState extends State<AdminNavBar> {
  final List<Widget> _pages = [
    AdminHomePage(),

    CalendarPage(),
  ];

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF007AFD),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(33),
            topRight: Radius.circular(33),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              spreadRadius: 8,
              blurRadius: 12,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 2), // Increases height
        child: SalomonBottomBar(
          currentIndex: _currentIndex,
          onTap: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            SalomonBottomBarItem(
              selectedColor: Colors.white, // Color of the selected item
              unselectedColor: Colors.black45, // Color of the unselected item
              icon: _currentIndex == 0
                  ? const Icon(Icons.home,size: 30.0,) // Filled icon when selected
                  : const Icon(Icons.home_outlined,size: 25.0,), // Rounded home icon
              title: const Text("Home"),
            ),

            SalomonBottomBarItem(
              selectedColor: Colors.white,
              unselectedColor: Colors.black45,
              icon: _currentIndex == 3
                  ? const Icon(Icons.person_rounded,size: 30.0,)
                  : const Icon(Icons.person_outline,size: 25.0,), // Rounded profile icon
              title: const Text("Profile"),
            ),
          ],
        ),
      ),
    );
  }
}