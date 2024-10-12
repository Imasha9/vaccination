import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final CollectionReference posts = FirebaseFirestore.instance.collection('posts');
  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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

  // Create a new post with image URL, description, and user ID
  Future<void> addPost(String post, String? imageUrl) async {
    try {
      User? currentUser = auth.currentUser;
      if (currentUser != null) {
        final Map<String, dynamic> data = {
          'post': post,
          'imageUrl': imageUrl,
          'userId': currentUser.uid,
          'timestamp': Timestamp.now(),
        };
        await posts.add(data);
      } else {
        print('No user is logged in');
      }
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

  // Update post with new data and user ID
  Future<void> updatePost(String docID, String newPost, String? imageUrl) async {
    try {
      DocumentSnapshot doc = await posts.doc(docID).get();
      if (!doc.exists) {
        print('Document with ID $docID does not exist');
        return;
      }

      User? currentUser = auth.currentUser;

      if (currentUser != null) {
        final Map<String, dynamic> updateData = {
          'post': newPost,
          'imageUrl': imageUrl,
          'userId': currentUser.uid,
          'timestamp': Timestamp.now(),
        };
        await posts.doc(docID).update(updateData);
      } else {
        print('No user is logged in');
      }
    } catch (e) {
      print('Error updating post: $e');
    }
  }

  // Function to delete a post
  Future<void> deletePost(String docID) async {
    try {
      await posts.doc(docID).delete();
    } catch (e) {
      print('Error deleting post: $e');
    }
  }

  // Stream to get posts from Firestore
  Stream<QuerySnapshot> getPostsStream() {
    return posts.snapshots();
  }

  // Function to get posts specific to a user
  // Stream to get posts from Firestore specific to a logged-in user
  Stream<QuerySnapshot> getUserPostsStream() {
    User? currentUser = auth.currentUser;
    if (currentUser != null) {
      return posts.where('userId', isEqualTo: currentUser.uid).snapshots();
    } else {
      print('No user is logged in');
      return const Stream.empty();
    }
  }

  // Function to add a like to a post
  Future<void> addLike(String postId, String userId) async {
    final postRef = _db.collection('posts').doc(postId);
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(postRef);
      final currentLikes = (snapshot.data()?['likes'] as Map<String, bool>?) ?? {};
      if (!currentLikes.containsKey(userId)) {
        currentLikes[userId] = true;
        transaction.update(postRef, {'likes': currentLikes});
      }
    });
  }

  // Function to remove a like from a post
  Future<void> removeLike(String postId, String userId) async {
    final postRef = _db.collection('posts').doc(postId);
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(postRef);
      final currentLikes = (snapshot.data()?['likes'] as Map<String, bool>?) ?? {};
      if (currentLikes.containsKey(userId)) {
        currentLikes.remove(userId);
        transaction.update(postRef, {'likes': currentLikes});
      }
    });
  }

  // Function to add a comment to a post
  Future<void> addComment(String postId, String userId, String comment) async {
    final commentsRef = _db.collection('posts').doc(postId).collection('comments').doc();
    await commentsRef.set({
      'userId': userId,
      'comment': comment,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Function to retrieve comments
  Stream<QuerySnapshot> getComments(String postId) {
    return _db.collection('posts').doc(postId).collection('comments').orderBy('timestamp').snapshots();
  }
}