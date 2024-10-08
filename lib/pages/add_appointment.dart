import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For formatting
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // For local notifications
import '../pages/notification_page.dart';
import '../services/appointmentdb.dart';
import 'appbar.dart'; // Import your DatabaseMethods

class RegisterAppointmentPage extends StatefulWidget {
  final String eventId; // Event ID passed from previous page

  const RegisterAppointmentPage({Key? key, required this.eventId})
      : super(key: key);

  @override
  State<RegisterAppointmentPage> createState() =>
      _RegisterAppointmentPageState();
}

class _RegisterAppointmentPageState extends State<RegisterAppointmentPage> {
  final _formKey = GlobalKey<FormState>();

  String? _name, _email, _phoneNumber, _dateOfBirth, _sex, _message;
  DateTime? _selectedDate;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();

  String? _selectedGender = 'Female';
  final List<String> _genders = ['Female', 'Male'];

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin(); // Local notifications plugin

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  // Initialize local notifications
  void _initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Function to show local notification
  Future<void> _showLocalNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'appointment_channel', 'Appointment Notifications',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  // Function to save appointment to Firestore using DatabaseMethods


  Future<void> _registerAppointment() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String? userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        try {
          // Fetch event details based on eventId
          var eventSnapshot = await FirebaseFirestore.instance.collection('Events').doc(widget.eventId).get();

          // Extract event details
          var eventData = eventSnapshot.data();

          // Convert timestamp to DateTime for the event date
          DateTime eventDate = (eventData!['date'] as Timestamp).toDate(); // The actual event date

          // Get start and end times as strings
          String startTimeString = eventData['startTime']; // Start time as a string
          String endTimeString = eventData['endTime']; // End time as a string

          // Parse start time and end time from strings to DateTime
          DateTime startTime = _parseTimeString(startTimeString);
          DateTime endTime = _parseTimeString(endTimeString);

          // Combine event date with start time and end time
          DateTime fullStartTime = DateTime(
            eventDate.year,
            eventDate.month,
            eventDate.day,
            startTime.hour,
            startTime.minute,
            startTime.second,
          );

          DateTime fullEndTime = DateTime(
            eventDate.year,
            eventDate.month,
            eventDate.day,
            endTime.hour,
            endTime.minute,
            endTime.second,
          );

          // Save the appointment using DatabaseMethods
          await AppointmentDatabaseMethods().addAppointment(
            userId,
            _name!,
            _email!,
            _phoneNumber!,
            eventDate, // Use the event date as DateTime
            _selectedGender!,
            _message,
            widget.eventId, // Link to the event
            fullStartTime, // Pass full start time
            fullEndTime, // Pass full end time
            eventData['description'], // Pass event description
            eventData['place'], // Pass event place
            eventData['title'], // Pass event title
          );

          // Show success popup
          _showSuccessPopup();

          // Show success notification in the status bar
          await _showLocalNotification("Appointment Registered",
              "Your appointment has been recorded and sent for admin approval.");
        } catch (e) {
          // Handle failure, show error popup
          _showErrorPopup();

          // Show error notification in the status bar
          await _showLocalNotification("Appointment Error",
              "Failed to register your appointment: ${e.toString()}");
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
      }
    }
  }

// Function to parse time strings
  DateTime _parseTimeString(String timeString) {
    // Remove any unwanted characters (like periods) and normalize the time string
    timeString = timeString.replaceAll('.', ':');

    // Split the time string to get hour and minute
    List<String> timeParts = timeString.split(':');
    int hour = int.parse(timeParts[0].trim());
    int minute = timeParts.length > 1 ? int.parse(timeParts[1].trim()) : 0;

    // Assume AM if the hour is less than 12, otherwise PM
    String amPm = (hour < 12) ? 'AM' : 'PM';

    // Convert 12-hour format to 24-hour format if necessary
    if (hour == 12) {
      hour = 0; // Midnight case
    }

    // Return the parsed DateTime
    return DateTime.now().copyWith(hour: hour + (amPm == 'PM' ? 12 : 0), minute: minute);
  }



  // Success Popup
  void _showSuccessPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Appointment Registered'),
          content: const Text(
            'Your appointment has been recorded and sent for admin approval.',
          ),
          actions: [
            TextButton(
              child: const Text('Back to Home'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context)
                    .pushReplacementNamed('/home'); // Navigate to home
              },
            ),
            TextButton(
              child: const Text('My Appointments'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pushNamed(
                    '/myAppointments'); // Navigate to my appointments
              },
            ),
          ],
        );
      },
    );
  }

  // Error Popup
  void _showErrorPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text(
            'There was an error registering your appointment. Please try again.',
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  // Function to clear form fields
  void _clearForm() {
    _formKey.currentState!.reset();
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _messageController.clear();
    setState(() {
      _selectedDate = null;
      _selectedGender = 'Female';
    });
  }

  // Phone number validator
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    if (value.length != 10) return 'Phone number must be 10 digits long';
    return null;
  }

  // Email validator
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: 'Add Appointment', // Set the title for this page
      ),
      body: Container(
        height: MediaQuery.of(context)
            .size
            .height, // Adjust the container to the full height
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 30),
                child: Center(
                  // Centered the text
                  child: Text(
                    'Enter your details to make an appointment',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold, // Makes the text bold
                    ),
                    textAlign: TextAlign.center, // Center the text
                  ),
                ),
              ),
              IntrinsicHeight(
                // IntrinsicHeight allows the white container to grow dynamically
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(30), // Make all corners rounded
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name input
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            labelStyle: const TextStyle(color: Colors.blue),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.blue),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            suffixIcon:
                                const Icon(Icons.person, color: Colors.blue),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Name is required';
                            }
                            return null;
                          },
                          onSaved: (value) => _name = value,
                        ),
                        const SizedBox(height: 20),

                        // Email input
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'E-mail',
                            labelStyle: const TextStyle(color: Colors.blue),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.blue),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            suffixIcon:
                                const Icon(Icons.email, color: Colors.blue),
                          ),
                          validator: _validateEmail,
                          onSaved: (value) => _email = value,
                        ),
                        const SizedBox(height: 20),

                        // Phone input
                        TextFormField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            labelText: 'Phone number',
                            labelStyle: const TextStyle(color: Colors.blue),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.blue),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            suffixIcon:
                                const Icon(Icons.phone, color: Colors.blue),
                          ),
                          validator: _validatePhone,
                          onSaved: (value) => _phoneNumber = value,
                        ),
                        const SizedBox(height: 20),

                        // Gender dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedGender,
                          decoration: InputDecoration(
                            labelText: 'Gender',
                            labelStyle: const TextStyle(color: Colors.blue),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.blue),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          items: _genders.map((String gender) {
                            return DropdownMenuItem<String>(
                              value: gender,
                              child: Text(gender),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value;
                            });
                          },
                        ),
                        const SizedBox(height: 20),

                        // Date of birth input
                        TextFormField(
                          readOnly: true,
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                _selectedDate = pickedDate;
                                _dateOfBirth =
                                    DateFormat('yyyy-MM-dd').format(pickedDate);
                              });
                            }
                          },
                          decoration: InputDecoration(
                            labelText: 'Date of Birth',
                            labelStyle: const TextStyle(color: Colors.blue),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.blue),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            suffixIcon: const Icon(
                              Icons.calendar_today,
                              color: Colors.blue,
                            ),
                          ),
                          controller: TextEditingController(
                            text: _selectedDate != null
                                ? DateFormat('yyyy-MM-dd')
                                    .format(_selectedDate!)
                                : '',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Date of Birth is required';
                            }
                            return null;
                          },
                          onSaved: (value) => _dateOfBirth = value,
                        ),
                        const SizedBox(height: 20),

                        // Message input (optional)
                        TextFormField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            labelText: 'Message (optional)',
                            labelStyle: const TextStyle(color: Colors.blue),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.blue),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            suffixIcon:
                                const Icon(Icons.message, color: Colors.blue),
                          ),
                          onSaved: (value) => _message = value,
                        ),
                        const SizedBox(height: 30),

                        // Register button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              backgroundColor: Colors.blue, // Button color
                            ),
                            child: const Text(
                              'Register Appointment',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            onPressed: _registerAppointment,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              side: const BorderSide(
                                  color: Colors.red), // Red outline
                            ),
                            child: const Text(
                              'Clear',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            onPressed:
                                _clearForm, // Call clearForm function when pressed
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
