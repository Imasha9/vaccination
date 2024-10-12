import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vaccination/pages/VaccinationDetails.dart';
import 'package:vaccination/pages/VaccinationIssueScreen.dart';
import 'package:vaccination/pages/my_appointments_page.dart';
import 'dart:io'; // For File type
import 'appbar.dart';
import 'community_post.dart';
import 'map_page.dart';
import 'notification_page.dart'; // Import the CommunityPost page

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? _userDetails;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _userDetails = userDoc.data() as Map<String, dynamic>?;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'User document does not exist.';
            _isLoading = false;
          });
        }
      } catch (error) {
        setState(() {
          _errorMessage = 'Error fetching user details: $error';
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _errorMessage = 'No user is currently logged in.';
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      File file = File(image.path);
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      try {
        TaskSnapshot snapshot = await FirebaseStorage.instance
            .ref('profilePictures/$fileName')
            .putFile(file);

        String downloadUrl = await snapshot.ref.getDownloadURL();

        User? user = _auth.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'profilePictureUrl': downloadUrl});
          setState(() {
            _userDetails?['profilePictureUrl'] = downloadUrl;
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Error uploading image: $e';
        });
      }
    }
  }

  Future<void> _updateUserName(String newName) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'name': newName});
        setState(() {
          _userDetails?['name'] = newName;
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'Error updating name: $e';
        });
      }
    }
  }

  void _showEditNameDialog() {
    final TextEditingController _nameController = TextEditingController();
    _nameController.text = _userDetails?['name'] ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Name'),
          content: TextField(
            controller: _nameController,
            decoration: const InputDecoration(hintText: 'Enter new name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _updateUserName(_nameController.text);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: 'Profile', // Set the title for this page
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue, // Blue color at the top
              Colors.white, // White color at the bottom
            ],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? Center(child: Text(_errorMessage!))
            : SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),
              Center(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 70,
                        backgroundColor: Colors.grey[300],
                        backgroundImage:
                        _userDetails?['profilePictureUrl'] != null
                            ? NetworkImage(
                            _userDetails!['profilePictureUrl'])
                            : null,
                        child: _userDetails?['profilePictureUrl'] == null
                            ? const Text('👤', style: TextStyle(fontSize: 40))
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _pickAndUploadImage,
                        child: const CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.camera_alt,
                              size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _userDetails?['name'] ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: _showEditNameDialog,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                _userDetails?['email'] ?? 'N/A',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              _buildButton(
                'My Posts',
                Icons.post_add_rounded,
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CommunityPost()),
                  );
                },
              ),
              _buildButton(
                'My Appointments',
                Icons.calendar_today_rounded,
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MyAppointments()),
                  );
                },
              ),
              _buildButton(
                'Vaccine Records',
                Icons.medical_services_rounded,
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => VaccinationForm()),
                  );
                },
              ),
              _buildButton(
                'Select Location',
                Icons.map,
                    () {
                  final LatLng northEast = LatLng(6.951312, 80.232918);
                  final LatLng southWest = LatLng(6.869346, 79.973077);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapPage(
                        northEast: northEast,
                        southWest: southWest,
                        onLocationSelected: (LatLng selectedLocation) {
                          print('Selected location: $selectedLocation');
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String title, IconData icon, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black87,
          backgroundColor: Colors.white70,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.black),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 18, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
