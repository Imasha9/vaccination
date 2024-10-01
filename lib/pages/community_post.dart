import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vaccination/services/firestore.dart';
import 'add_post.dart'; // Import the AddPostPage

class CommunityPost extends StatefulWidget {
  const CommunityPost({super.key});

  @override
  State<CommunityPost> createState() => _CommunityPostState();
}

class _CommunityPostState extends State<CommunityPost> {
  final FirestoreService firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Posts'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getPostsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No posts available.'));
          }

          List<QueryDocumentSnapshot> postsList = snapshot.data!.docs;

          return ListView.builder(
            itemCount: postsList.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document = postsList[index];
              String docID = document.id;
              String postText = (document.data() as Map<String, dynamic>)['post'] ?? 'No content';
              String imageUrl = (document.data() as Map<String, dynamic>)['imageUrl'] ?? '';

              bool isExpanded = false;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                elevation: 4,
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (imageUrl.isNotEmpty)
                            Image.network(
                              imageUrl,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: Center(child: Text('Image not available')),
                                );
                              },
                            ),
                          const SizedBox(height: 8.0),
                          Text(
                            postText,
                            style: const TextStyle(fontSize: 12.0),
                            maxLines: isExpanded ? null : 3,
                            overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                          ),
                          if (postText.length > 100)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  isExpanded = !isExpanded;
                                });
                              },
                              child: Text(isExpanded ? 'Show Less' : 'Show More'),
                            ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'edit') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddPostPage(docID: docID),
                              ),
                            );
                          } else if (value == 'delete') {
                            await firestoreService.deletePost(docID);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Post deleted successfully')),
                            );
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          PopupMenuItem<String>(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: Colors.black26),
                                const SizedBox(width: 8),
                                const Text('Edit Post'),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.black26),
                                const SizedBox(width: 8),
                                const Text('Delete Post'),
                              ],
                            ),
                          ),
                        ],
                        icon: const Icon(Icons.more_vert, color: Colors.black87), // Three-dot icon
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
