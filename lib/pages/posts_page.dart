import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_post.dart';
import 'appbar.dart'; // Import the AddPostPage

class PostsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: 'Community Posts', // Set the title for this page
      ),
      body: PostsList(),
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

class PostsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
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

            return PostCard(
              imageUrl: imageUrl,
              postText: postText,
              timestamp: timestamp,
            );
          },
        );
      },
    );
  }
}

class PostCard extends StatefulWidget {
  final String? imageUrl;
  final String postText;
  final DateTime timestamp;

  PostCard({
    required this.imageUrl,
    required this.postText,
    required this.timestamp,
  });

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty)
                Image.network(
                  widget.imageUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 150,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      color: Colors.grey[300],
                      child: Center(child: Text('Image not available')),
                    );
                  },
                )
              else
                Container(
                  height: 150,
                  color: Colors.grey[300],
                  child: Center(child: Text('No Image')),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.postText,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                      maxLines: _isExpanded ? null : 3,
                      overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                    ),
                    if (widget.postText.length > 100)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                        child: Text(_isExpanded ? 'Show Less' : 'Show More'),
                      ),
                    SizedBox(height: 8),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        'Posted on: ${widget.timestamp.toLocal().toString().split(' ')[0]}',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
