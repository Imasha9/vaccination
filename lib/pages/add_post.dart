import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import '../services/firestore.dart';

import 'package:http/http.dart' as http;


class AddPostPage extends StatefulWidget {
  final String? docID;

  const AddPostPage({Key? key, this.docID}) : super(key: key);

  @override
  _AddPostPageState createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final TextEditingController _postController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.docID != null) {
      _loadPost();
    }
  }

  Future<void> _loadPost() async {
    try {
      final postData = await FirestoreService().getPost(widget.docID!);
      _postController.text = postData['post'] ?? '';

      // Load the image if URL exists
      if (postData['imageUrl'] != null) {
        _imageFile = await _loadImageFromUrl(postData['imageUrl']);
        setState(() {}); // Update the UI
      }
    } catch (e) {
      print('Error loading post: $e');
    }
  }

  Future<File?> _loadImageFromUrl(String imageUrl) async {
    try {
      // Download the image and return as File
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/${path.basename(imageUrl)}');
        await file.writeAsBytes(bytes);
        return file;
      } else {
        print('Failed to load image from URL');
        return null;
      }
    } catch (e) {
      print('Error loading image from URL: $e');
      return null;
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      final fileName = path.basename(imageFile.path);
      final storageRef = FirebaseStorage.instance.ref().child('posts/$fileName');
      final uploadTask = storageRef.putFile(imageFile);

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _submitPost() async {
    if (_postController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some text')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String? imageUrl;

    if (_imageFile != null) {
      imageUrl = await _uploadImage(_imageFile!);
    }

    try {
      if (widget.docID != null) {
        await FirestoreService().updatePost(widget.docID!, _postController.text, imageUrl);
      } else {
        await FirestoreService().addPost(_postController.text, imageUrl);
      }
    } catch (e) {
      print('Error submitting post: $e');
    }

    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(widget.docID != null ? 'Post updated successfully!' : 'Post added successfully!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.docID == null ? 'Add Post' : 'Edit Post'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TextFormField(
                controller: _postController,
                minLines: 6, // Minimum number of lines
                maxLines: 10, // Maximum number of lines
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter description here...',
                ),
              ),
            ),

            const SizedBox(height: 20),
            if (_imageFile != null)
              Image.file(_imageFile!, height: 150, width: 150, fit: BoxFit.cover),
            if (_imageFile == null) const Text('No image selected.'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Choose Image'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitPost,
              child: const Text('Submit Post'),
            ),
          ],
        ),
      ),
    );
  }
}
