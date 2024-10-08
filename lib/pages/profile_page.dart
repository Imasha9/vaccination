import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vaccination/pages/VaccinationDetails.dart';
import 'package:vaccination/pages/VaccinationIssueScreen.dart';
import 'package:vaccination/pages/my_appointments_page.dart';
import 'dart:io'; // For File type
import 'appbar.dart';
import 'community_post.dart';
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
    String? userId = FirebaseAuth.instance.currentUser?.uid;
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
      String fileName =
          DateTime.now().millisecondsSinceEpoch.toString(); // Unique file name

      try {
        // Uploading the image to Firebase Storage
        TaskSnapshot snapshot = await FirebaseStorage.instance
            .ref('profilePictures/$fileName')
            .putFile(file);

        // Get the download URL
        String downloadUrl = await snapshot.ref.getDownloadURL();

        // Update Firestore with the new profile picture URL
        User? user = _auth.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'profilePictureUrl': downloadUrl});
          setState(() {
            _userDetails?['profilePictureUrl'] = downloadUrl; // Update the UI
          });
        }
      } catch (e) {
        print('Error uploading image: $e');
        setState(() {
          _errorMessage = 'Error uploading image: $e';
        });
      }
    }
  }

  // Method to update the user's name in Firestore
  Future<void> _updateUserName(String newName) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'name': newName});
        setState(() {
          _userDetails?['name'] = newName; // Update the name in the UI
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'Error updating name: $e';
        });
      }
    }
  }

  // Method to show a dialog for updating the name
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
        // Adding the gradient background
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
        child: Stack(
          children: [
            // Main content of the profile page
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text(_errorMessage!))
                    : Column(
                        children: [
                          // Move image and contents up
                          const SizedBox(
                              height: 30), // Adjust the height for spacing

                          // Profile Picture Section with larger image frame
                          Center(
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 70, // Make image frame larger
                                  backgroundColor: Colors.grey[300],
                                  backgroundImage: _userDetails?[
                                              'profilePictureUrl'] !=
                                          null
                                      ? NetworkImage(
                                          _userDetails!['profilePictureUrl'])
                                      : null,
                                  child: _userDetails?['profilePictureUrl'] ==
                                          null
                                      ? const Text(
                                          '👤',
                                          style: TextStyle(
                                              fontSize: 40), // Larger icon size
                                        )
                                      : null,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: InkWell(
                                    onTap: _pickAndUploadImage,
                                    child: CircleAvatar(
                                      radius:
                                          18, // Adjust size of the edit button
                                      backgroundColor: Colors.blue,
                                      child: const Icon(
                                        Icons.edit,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Display user name with edit option
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    _userDetails?['name'] ?? 'N/A',
                                    style: const TextStyle(
                                      fontSize: 28, // Adjust size if needed
                                      fontWeight: FontWeight.bold,
                                      color: Colors
                                          .white, // Set font color to white
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.white),
                                  onPressed:
                                      _showEditNameDialog, // Show dialog to edit name
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Center the "Personal Details" text
                          Center(
                            child: Text(
                              'Personal Details',
                              style: const TextStyle(
                                fontSize: 20,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // Set font color to white
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // User Details Section with increased width
                          Center(
                            child: Container(
                              width: MediaQuery.of(context).size.width *
                                  1, // Adjust width to 90% of the screen
                              child: Card(
                                elevation: 6,
                                margin: const EdgeInsets.all(16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                  side: const BorderSide(
                                      color: Colors.white70, width: 2),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Name: ${_userDetails?['name'] ?? 'N/A'}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Email: ${_userDetails?['email'] ?? 'N/A'}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'NIC: ${_userDetails?['nic'] ?? 'N/A'}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Add space between the page and buttons
                          const SizedBox(
                              height: 20), // Adjust the height as needed
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // My Posts Button
                              Expanded(
                                child: Column(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        // Navigate to My Posts page
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const CommunityPost(),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors
                                            .blue[800], // Set button color
                                        minimumSize: const Size(
                                            100, 100), // Square button
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              16.0), // Rounded corners
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.post_add_rounded,
                                        color: Colors.blue[100]!,
                                        size: 55, // Large icon size
                                      ),
                                    ),
                                    const SizedBox(
                                        height:
                                            5), // Space between icon and text
                                    const Text('My Posts',
                                        textAlign: TextAlign.center),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),

                              // My Appointments Button
                              Expanded(
                                child: Column(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        // Navigate to My Appointments page
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                MyAppointments(),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors
                                            .green[100], // Set button color
                                        minimumSize: const Size(
                                            100, 100), // Square button
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              16.0), // Rounded corners
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.calendar_today_rounded,
                                        color: Colors.green,
                                        size: 55, // Large icon size
                                      ),
                                    ),
                                    const SizedBox(
                                        height:
                                            5), // Space between icon and text
                                    const Text('My Appointments',
                                        textAlign: TextAlign.center),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),

                              // My Vaccine Records Button
                              Expanded(
                                child: Column(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        // Navigate to My Vaccine Records page
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                VaccinationForm(),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Colors.red[100], // Set button color
                                        minimumSize: const Size(
                                            100, 100), // Square button
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              16.0), // Rounded corners
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.medical_services_rounded,
                                        color: Colors.red,
                                        size: 55, // Large icon size
                                      ),
                                    ),
                                    const SizedBox(
                                        height:
                                            5), // Space between icon and text
                                    const Text('Vaccine Records',
                                        textAlign: TextAlign.center),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
          ],
        ),
      ),
    );
  }
}
