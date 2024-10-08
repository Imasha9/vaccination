import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // For formatting
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // For local notifications
import '../pages/notification_page.dart';
import '../services/appointmentdb.dart';
import 'appbar.dart';

class UpdateAppointments extends StatefulWidget {
  final Map<String, dynamic> appointment; // Receive the appointment object

  const UpdateAppointments({Key? key, required this.appointment})
      : super(key: key);

  @override
  State<UpdateAppointments> createState() => _UpdateAppointmentsState();
}

class _UpdateAppointmentsState extends State<UpdateAppointments> {
  final _formKey = GlobalKey<FormState>();

  String? _name, _email, _phoneNumber, _dateOfBirth, _sex, _message;
  DateTime? _selectedDate;

  // Define controllers for the form fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();

  late String _initialName;
  late String _initialEmail;
  late String _initialPhone;
  late String _initialMessage;

  String? _selectedGender = 'Female'; // Default gender
  final List<String> _genders = ['Female', 'Male'];

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _loadAppointmentData();
    _initializeNotifications(); // Load the appointment data into the form fields
  }

  void _initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

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

  // Load the passed appointment data into form fields
  void _loadAppointmentData() {
    // Set initial values from the appointment
    _initialName = widget.appointment['username'] ?? '';
    _initialEmail = widget.appointment['email'] ?? '';
    _initialPhone = widget.appointment['phone'] ?? '';
    _initialMessage = widget.appointment['optionalMessage'] ?? '';
    _selectedGender = widget.appointment['sex'] ?? 'Female';

    if (widget.appointment['dob'] != null) {
      // Assuming dateOfBirth is a Timestamp
      Timestamp dobTimestamp = widget.appointment['dob'];
      _selectedDate = dobTimestamp.toDate();
      _dateOfBirth =
          "${_selectedDate!.year}-${_selectedDate!.month}-${_selectedDate!.day}";
    }
  }

  // Function to update appointment (you can modify this as per your DB structure)
  Future<void> _updateAppointment() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Prepare the updated data, check if values have changed
      Map<String, dynamic> updatedData = {
        'username': _nameController.text.isNotEmpty
            ? _nameController.text
            : widget.appointment['username'],
        'email': _emailController.text.isNotEmpty
            ? _emailController.text
            : widget.appointment['email'],
        'phone': _phoneController.text.isNotEmpty
            ? _phoneController.text
            : widget.appointment['phone'],
        'gender': _selectedGender,
        'dob': _selectedDate ??
            widget.appointment['dob'], // Use existing date if not changed
        'optionalMessage': _messageController.text.isNotEmpty
            ? _messageController.text
            : widget.appointment['optionalMessage'],
      };

      try {
        // Update the appointment in Firestore using the appointment ID
        await FirebaseFirestore.instance
            .collection('Appointments')
            .doc(widget
                .appointment['id']) // Use the appointment's ID from the Map
            .update(updatedData);

        // Show success message
        _showSuccessPopup();

        // Send local notification
        await _showLocalNotification(
          "Appointment Updated",
          "Your appointment has been recorded and sent for admin approval.",
        );
      } catch (e) {
        // Handle error if update fails
        _showErrorPopup();

        await _showLocalNotification(
          "Appointment Error",
          "Failed to update your appointment: ${e.toString()}",
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix the errors in the form.')),
      );
    }
  }

  void _showSuccessPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Appointment Updated'),
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

  void _showErrorPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text(
            'There was an error updating your appointment. Please try again.',
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

  // Phone validator
  // Phone validator
  String? _validatePhone(String? value) {
    // Allow empty input for validation; checks will be made during saving
    if (value != null && value.isNotEmpty && value.length != 10) {
      return 'Phone number must be 10 digits long';
    }
    return null; // No errors
  }

// Email validator
  String? _validateEmail(String? value) {
    // Allow empty input for validation; checks will be made during saving
    if (value != null && value.isNotEmpty) {
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
      if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
    }
    return null; // No errors
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: 'Update Appointment', // Set the title for this page
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
                    'Enter your details to update the appointment',
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
                            hintText: _initialName,
                            floatingLabelBehavior: FloatingLabelBehavior.always,
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
                            // Allow empty input for validation
                            if (value != null && value.isNotEmpty) {
                              if (value.trim().isEmpty) {
                                return 'Name cannot be just whitespace';
                              }
                            } else {
                              // If the value is empty, check if it's the initial value (which allows updates)
                              return null; // No error for empty input if it matches initial value
                            }
                            return null; // No errors
                          },
                          onSaved: (value) {
                            // Save the updated value, or fallback to the initial hint if unchanged
                            _name = value!.isNotEmpty ? value : _initialName;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Email input
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'E-mail',
                            labelStyle: const TextStyle(color: Colors.blue),
                            hintText: _initialEmail,
                            floatingLabelBehavior: FloatingLabelBehavior.always,
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
                          onSaved: (value) {
                            // Save the updated value, or fallback to the initial hint if unchanged
                            _email = value!.isNotEmpty ? value : _initialEmail;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Phone input
                        TextFormField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            labelText: 'Phone number',
                            labelStyle: const TextStyle(color: Colors.blue),
                            hintText: _initialPhone,
                            floatingLabelBehavior: FloatingLabelBehavior.always,
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
                          onSaved: (value) {
                            // Save the updated value, or fallback to the initial hint if unchanged
                            _phoneNumber =
                                value!.isNotEmpty ? value : _initialPhone;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Gender dropdown
                        DropdownButtonFormField<String>(
                          value:
                              _selectedGender, // This will show the existing gender
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
                              _selectedGender = value!;
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
                              initialDate: _selectedDate ??
                                  DateTime
                                      .now(), // Use the existing date or current date
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                _selectedDate = pickedDate;
                                _dateOfBirth = DateFormat('dd-MM-yyyy')
                                    .format(pickedDate); // Update date format
                              });
                            }
                          },
                          decoration: InputDecoration(
                            labelText: 'Date of Birth',
                            labelStyle: const TextStyle(color: Colors.blue),
                            hintText: _dateOfBirth!.isNotEmpty
                                ? _dateOfBirth
                                : 'Select your Date of Birth', // Display formatted DOB as hint
                            floatingLabelBehavior: FloatingLabelBehavior
                                .always, // Show the label at the top
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
                                ? DateFormat('dd-MM-yyyy').format(
                                    _selectedDate!) // Show formatted date in text field
                                : '', // Leave empty if no date is selected
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
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            hintText: _initialMessage,
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
                          onSaved: (value) {
                            // Save the updated value, or fallback to the initial hint if unchanged
                            _message =
                                value!.isNotEmpty ? value : _initialMessage;
                          },
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
                            onPressed: _updateAppointment,
                            child: const Text(
                              'Update Appointment',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
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
                              'Clear Form',
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
