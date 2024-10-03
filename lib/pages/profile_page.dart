import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // For File type
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
      String fileName = DateTime.now().millisecondsSinceEpoch.toString(); // Unique file name

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
      backgroundColor: const Color(0xFFA2CFFE),
      body: Stack(
        children: [
          // Main content of the profile page
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : Column(
            children: [
              // User Details Card (outside the scrollable container)
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    color: const Color(0xFFA2CFFE), // Light background color
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 50), // Adjust height for spacing

                        // Profile Picture Section
                        Center(
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey[300],
                                backgroundImage: _userDetails?['profilePictureUrl'] != null
                                    ? NetworkImage(_userDetails!['profilePictureUrl'])
                                    : null,
                                child: _userDetails?['profilePictureUrl'] == null
                                    ? const Text(
                                  '👤',
                                  style: TextStyle(fontSize: 30),
                                )
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: _pickAndUploadImage,
                                  child: CircleAvatar(
                                    radius: 15,
                                    backgroundColor: Colors.blue,
                                    child: const Icon(
                                      Icons.edit,
                                      size: 15,
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
                              Flexible( // Added to allow the name to wrap
                                child: Text(
                                  _userDetails?['name'] ?? 'N/A',
                                  style: const TextStyle(
                                    fontSize: 28, // Adjust size if needed
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white, // Set font color to white
                                  ),
                                  maxLines: 2, // Allow up to 2 lines
                                  overflow: TextOverflow.ellipsis, // Show ellipsis if overflow
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.white),
                                onPressed: _showEditNameDialog, // Show dialog to edit name
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Personal Details',
                          style: const TextStyle(
                            fontSize: 20,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold, // Italic font
                          ),
                        ),
                        const SizedBox(height: 10),
                        // User Details Section with enhanced styling
                        Card(
                          elevation: 6,
                          margin: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            side: const BorderSide(color: Colors.white70, width: 2), // Border styling
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Name: ${_userDetails?['name'] ?? 'N/A'}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontStyle: FontStyle.italic, // Italic font
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Email: ${_userDetails?['email'] ?? 'N/A'}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontStyle: FontStyle.italic, // Italic font
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'NIC: ${_userDetails?['nic'] ?? 'N/A'}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontStyle: FontStyle.italic, // Italic font
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'My Posts',
                          style: const TextStyle(
                            fontSize: 20,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold, // Italic font
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Posts ListView with clickable cards
                        Card(
                          elevation: 6,
                          margin: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            side: const BorderSide(color: Colors.white70, width: 2), // Border styling
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.post_add, // Choose an appropriate icon for posts
                              color: Colors.blue, // Change color as needed
                            ),
                            title: Text(
                              'My Posts',
                              style: const TextStyle(
                                fontStyle: FontStyle.italic, // Italic font for post title
                                fontWeight: FontWeight.bold, // Optional: make it bold
                              ),
                            ),
                            onTap: () {
                              // Navigate to the CommunityPost page
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CommunityPost(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Notification Icon positioned at the top right corner
          Positioned(
            top: 64,
            right: 10,
            child: IconButton(
              icon: const Icon(
                Icons.notifications,
                color: Colors.white, // Set icon color to white
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationPage(),
                  ),
                );
              },
            ),
          ),

        ],
      ),
    );
  }
}
