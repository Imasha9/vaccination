import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For formatting
import '../pages/notification_page.dart';

class RegisterAppointmentPage extends StatefulWidget {
  final String eventId; // Event ID passed from previous page

  const RegisterAppointmentPage({Key? key, required this.eventId}) : super(key: key);

  @override
  State<RegisterAppointmentPage> createState() => _RegisterAppointmentPageState();
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

  // Function to save appointment to Firestore
  Future<void> _registerAppointment() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String? userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        // Save the appointment to the database
        await FirebaseFirestore.instance.collection('appointments').add({
          'name': _name,
          'email': _email,
          'phone': _phoneNumber,
          'dateOfBirth': _dateOfBirth,
          'sex': _selectedGender,
          'message': _message ?? '',
          'eventId': widget.eventId, // Event ID from previous page
          'userId': userId,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment registered successfully')),
        );
        Navigator.pop(context); // Go back after registration
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
      }
    }
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
      appBar: AppBar(
        automaticallyImplyLeading:
        true, // This ensures the back button is shown
        backgroundColor: Colors.blue, // Top blue background
        elevation: 0,
        title: const Center(
          // Center the title
          child: Text(
            'Add Appointment',
            style: TextStyle(
                color: Colors.white, // Change title color to white
                fontSize: 30,
                fontWeight: FontWeight.bold // Adjust font size if needed
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications,
                color: Colors.white), // Change notification icon color to white
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
          color: Colors.white, // Change the back button color to white
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
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
                  border: const OutlineInputBorder(),
                  suffixIcon: const Icon(Icons.person, color: Colors.blue),
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
                  border: const OutlineInputBorder(),
                  suffixIcon: const Icon(Icons.email, color: Colors.blue),
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
                  border: const OutlineInputBorder(),
                  suffixIcon: const Icon(Icons.phone, color: Colors.blue),
                ),
                validator: _validatePhone,
                onSaved: (value) => _phoneNumber = value,
              ),
              const SizedBox(height: 20),

              // Date of birth input
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Date of birth (DD/MM/YYYY)',
                  labelStyle: const TextStyle(color: Colors.blue),
                  border: const OutlineInputBorder(),
                  suffixIcon: const Icon(Icons.cake, color: Colors.blue),
                ),
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
                      _dateOfBirth = DateFormat('dd/MM/yyyy').format(pickedDate);
                    });
                  }
                },
                validator: (value) {
                  if (_selectedDate == null) return 'Date of birth is required';
                  return null;
                },
                controller: TextEditingController(
                    text: _selectedDate != null
                        ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                        : ''),
                onSaved: (value) => _dateOfBirth = value,
              ),
              const SizedBox(height: 20),

              // Gender selection
              Row(
                children: [
                  const Text(
                    'Sex:',
                    style: TextStyle(color: Colors.blue),
                  ),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: _selectedGender,
                    items: _genders
                        .map((gender) => DropdownMenuItem(
                      value: gender,
                      child: Text(gender),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Message input
              TextFormField(
                controller: _messageController,
                decoration: InputDecoration(
                  labelText: 'Leave a message (Optional)',
                  labelStyle: const TextStyle(color: Colors.blue),
                  border: const OutlineInputBorder(),
                  suffixIcon: const Icon(Icons.message, color: Colors.blue),
                ),
                maxLines: 3,
                onSaved: (value) => _message = value,
              ),
              const SizedBox(height: 20),

              // Register button
              Center(
                child: ElevatedButton(
                  onPressed: _registerAppointment,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 30.0), backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    'Register',
                    style: TextStyle(fontSize: 18, color: Colors.white),
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
