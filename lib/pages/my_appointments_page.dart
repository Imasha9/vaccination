import 'package:flutter/material.dart';

class MyAppointments extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
      ),
      body: const Center(
        child: Text('This is where you will display your appointments.'),
      ),
    );
  }
}