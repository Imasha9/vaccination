import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class FirestoreService {
  final CollectionReference posts = FirebaseFirestore.instance.collection('posts');
  final FirebaseStorage storage = FirebaseStorage.instance;

  // Function to upload the image to Firebase Storage
  Future<String?> uploadImage(File image) async {
    try {
      final fileName = path.basename(image.path);
      final storageRef = storage.ref().child('posts/$fileName');
      final uploadTask = storageRef.putFile(image);
      final snapshot = await uploadTask.whenComplete(() => null);
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Method to get a stream of posts from Firestore
  Stream<QuerySnapshot> getPostsStream() {
    return posts.snapshots();
  }

  // Create a new post with an image URL and description
  Future<void> addPost(String post, String? imageUrl) async {
    try {
      final Map<String, dynamic> data = {
        'post': post,
        'imageUrl': imageUrl,
        'timestamp': Timestamp.now(),
      };
      await posts.add(data);
    } catch (e) {
      print('Error adding post: $e');
    }
  }

  // Get a single post by its document ID
  Future<Map<String, dynamic>> getPost(String docID) async {
    try {
      DocumentSnapshot doc = await posts.doc(docID).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>? ?? {};
      } else {
        print('Document does not exist');
        return {};
      }
    } catch (e) {
      print('Error fetching post: $e');
      return {};
    }
  }

  // Update post with new data
  Future<void> updatePost(String docID, String newPost, String? imageUrl) async {
    try {
      DocumentSnapshot doc = await posts.doc(docID).get();
      if (!doc.exists) {
        print('Document with ID $docID does not exist');
        return;
      }

      final Map<String, dynamic> updateData = {
        'post': newPost,
        'imageUrl': imageUrl,
        'timestamp': Timestamp.now(),
      };

      await posts.doc(docID).update(updateData);
      print('Post updated successfully');
    } catch (e) {
      print('Error updating post: $e');
    }
  }

  // Delete a post
  Future<void> deletePost(String docID) async {
    try {
      final doc = await posts.doc(docID).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;

        final imageUrl = data?['imageUrl'];
        if (imageUrl != null) {
          try {
            final ref = FirebaseStorage.instance.refFromURL(imageUrl);
            await ref.delete();
          } catch (e) {
            print('Error deleting image from Firebase Storage: $e');
          }
        }

        await posts.doc(docID).delete();
      } else {
        print('Document with ID $docID does not exist');
      }
    } catch (e) {
      print('Error deleting post: $e');
    }
  }
}
