import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_post.dart'; // Import the AddPostPage
import 'package:vaccination/services/firestore.dart'; // Import your Firestore service
import 'package:vaccination/services/auth.dart';
import 'community_post.dart'; // Import your Auth service

class PostsTabScreen extends StatefulWidget {
  @override
  _PostsTabScreenState createState() => _PostsTabScreenState();
}

class _PostsTabScreenState extends State<PostsTabScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Community Posts'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'All Posts'),
            Tab(text: 'My Posts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          PostsList(), // All posts tab
          CommunityPost(), // My posts tab
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPostPage()),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Add Post',
      ),
    );
  }
}

// Your All Posts Page with Search Bar
class PostsList extends StatefulWidget {
  @override
  _PostsListState createState() => _PostsListState();
}

class _PostsListState extends State<PostsList> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: (value) {
              setState(() {
                searchQuery = value.toLowerCase(); // Update search query as the user types
              });
            },
            decoration: InputDecoration(
              hintText: 'Search by username...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('posts').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Something went wrong!'));
              }

              final posts = snapshot.data?.docs ?? [];

              return ListView.builder(
                padding: EdgeInsets.all(16.0),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index].data() as Map<String, dynamic>;
                  final imageUrl = post['imageUrl'];
                  final postText = post['post'] ?? '';
                  final timestamp = post['timestamp']?.toDate() ?? DateTime.now();
                  final userId = post['userId']; // Assuming each post has a userId field
                  final likes = post['likes'] ?? [];
                  final comments = post['comments'] ?? [];

                  // Check for matching username before rendering posts
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (userSnapshot.hasError) {
                        return Center(child: Text('Failed to load user info'));
                      }

                      if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                        return Center(child: Text('User not found'));
                      }

                      final user = userSnapshot.data!.data() as Map<String, dynamic>;
                      final username = user['name'] ?? 'Anonymous';
                      final profilePictureUrl = user['profilePictureUrl'];

                      // Only display posts that match the search query
                      if (searchQuery.isEmpty || username.toLowerCase().contains(searchQuery)) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                children: [
                                  if (profilePictureUrl != null && profilePictureUrl.isNotEmpty)
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(profilePictureUrl),
                                      radius: 20,
                                    )
                                  else
                                    CircleAvatar(
                                      radius: 20,
                                      child: Icon(Icons.person),
                                    ),
                                  SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        username,
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      Text(
                                        'Posted on: ${timestamp.toLocal().toString().split(' ')[0]}',
                                        style: TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            PostCard(
                              imageUrl: imageUrl,
                              postText: postText,
                              timestamp: timestamp,
                              username: username,
                              profilePictureUrl: profilePictureUrl,
                              likes: likes,
                              comments: comments,
                              postId: posts[index].id,
                            ),
                          ],
                        );
                      } else {
                        return Container(); // Return an empty container for non-matching posts
                      }
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class PostCard extends StatefulWidget {
  final String? imageUrl;
  final String postText;
  final DateTime timestamp;
  final String username;
  final String? profilePictureUrl;
  final List likes; // New likes field
  final List comments; // New comments field
  final String postId; // Post ID for referencing in Firestore

  PostCard({
    required this.imageUrl,
    required this.postText,
    required this.timestamp,
    required this.username,
    required this.profilePictureUrl,
    required this.likes,
    required this.comments,
    required this.postId,
  });

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isExpanded = false;
  final TextEditingController _commentController = TextEditingController();
  bool _showComments = false;

  void _addComment() async {
    if (_commentController.text.isNotEmpty) {
      // Get current user info
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        String userId = currentUser.uid;
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
        if (userDoc.exists) {
          String username = userDoc['name'] ?? 'Anonymous';
          String profilePictureUrl = userDoc['profilePictureUrl'] ?? '';

          // Add comment with user info
          Map<String, String> commentData = {
            'userId': userId,
            'username': username,
            'profilePictureUrl': profilePictureUrl,
            'comment': _commentController.text
          };

          await FirebaseFirestore.instance.collection('posts').doc(widget.postId).update({
            'comments': FieldValue.arrayUnion([commentData]),
          });

          _commentController.clear();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLiked = widget.likes.contains(FirebaseAuth.instance.currentUser?.uid);

    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                widget.imageUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Center(child: Text('Image not available')),
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.postText),
                SizedBox(height: 8.0),
                Text(
                  'Posted on: ${widget.timestamp.toLocal().toString().split(' ')[0]}',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
                      onPressed: () {
                        setState(() {
                          isLiked = !isLiked;
                        });
                        FirebaseFirestore.instance.collection('posts').doc(widget.postId).update({
                          'likes': isLiked
                              ? FieldValue.arrayUnion([FirebaseAuth.instance.currentUser?.uid])
                              : FieldValue.arrayRemove([FirebaseAuth.instance.currentUser?.uid]),
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.comment),
                      onPressed: () {
                        setState(() {
                          _showComments = !_showComments;
                        });
                      },
                    ),
                  ],
                ),
                if (_showComments) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.send),
                          onPressed: _addComment,
                        ),
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: widget.comments.length,
                    itemBuilder: (context, index) {
                      final comment = widget.comments[index];
                      final commentUsername = comment['username'] ?? 'Anonymous';
                      final commentProfilePictureUrl = comment['profilePictureUrl'] ?? '';
                      final commentText = comment['comment'] ?? '';

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: commentProfilePictureUrl.isNotEmpty
                              ? NetworkImage(commentProfilePictureUrl)
                              : null,
                          child: commentProfilePictureUrl.isEmpty ? Icon(Icons.person) : null,
                        ),
                        title: Text(commentUsername),
                        subtitle: Text(commentText),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
