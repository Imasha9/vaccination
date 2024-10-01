import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'news.dart'; // Import your NewsPage
import 'notification_page.dart';
import 'posts_page.dart';
import 'emergency_contact.dart'; // Import the EmergencyContactPage
import 'package:vaccination/models/article.dart'; // Import your Article model class

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<Article>> fetchLatestNews() async {
    try {
      final String apiKey = '987b06cfc70542919758e1e0cf36d052'; // Replace with your News API key
      final response = await http.get(
        Uri.parse('https://newsapi.org/v2/top-headlines?country=us&category=health&apiKey=$apiKey'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> articlesJson = data['articles'];

        List<Article> validArticles = articlesJson
            .map((json) => Article.fromJson(json))
            .where((article) => article.title != '[Removed]' && article.urlToImage != null)
            .toList();

        return validArticles.take(2).toList();
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      throw Exception('Failed to load news: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Handle notification button press
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationPage()),
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double bigCardHeight = constraints.maxHeight * 0.25; // 25% of the screen height for big cards
          double mediumCardHeight = constraints.maxHeight * 0.20; // Increased size for medium cards

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Add image at the top (wrap content)
                  Center(
                    child: Image.asset(
                      'images/home.jpg', // Use your image path here
                      width: constraints.maxWidth * 0.8, // Adjust width for responsive content
                      height: null, // Wrap content height
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 16), // Add some spacing after the image

                  // Big Card at the top (Vaccine Appointments)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: Card(
                      elevation: 6,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Color(0xFF17C2EC), width: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: bigCardHeight,
                        child: TextButton(
                          onPressed: () {
                            // Handle button press
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.calendar_month, color: Colors.blue, size: 60),
                              SizedBox(width: 20),
                              Expanded(
                                child: Text(
                                  'Vaccine Appointments',
                                  style: TextStyle(color: Colors.blue, fontSize: 24, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Row for two medium cards and another big card
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Column for two medium cards
                      Expanded(
                        child: Column(
                          children: [
                            // Medium Card 1 (Community Post)
                            Container(
                              margin: const EdgeInsets.only(bottom: 8.0),
                              child: Card(
                                elevation: 4,
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(color: Color(0xFF17C2EC), width: 0.6),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: SizedBox(
                                  height: mediumCardHeight,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => PostsPage()),
                                      );
                                    },
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          'images/3900425.png',
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Community Post',
                                          style: TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Medium Card 2 (Issue Responses)
                            Card(
                              elevation: 4,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(color: Color(0xFF17C2EC), width: 0.6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: SizedBox(
                                height: mediumCardHeight,
                                child: TextButton(
                                  onPressed: () {
                                    // Handle button press
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'images/issue.png',
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Issue Responses',
                                        style: TextStyle(color: Color(0xFF17C2EC), fontSize: 14, fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Big Card on the right (Emergency Contacts)
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(left: 16.0),
                          child: Card(
                            elevation: 6,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: Colors.red, width: 0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: SizedBox(
                              height: bigCardHeight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => EmergencyHelpScreen()),
                                  );
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'images/em-removebg-preview.png',
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Emergency Contacts',
                                      style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Latest Health News button
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => NewsPage()),
                        );
                      },
                      child: Text(
                        'Latest Health News',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ),
                  ),
                  // News List at the bottom
                  FutureBuilder<List<Article>>(
                    future: fetchLatestNews(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error loading news.'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('No news available.'));
                      } else {
                        final articles = snapshot.data!;
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(), // Prevent scrolling for the inner list
                          itemCount: articles.length,
                          itemBuilder: (context, index) {
                            final article = articles[index];
                            return ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => NewsPage()), // Redirecting to NewsPage
                                );
                              },
                              title: Text(
                                article.title ?? 'No Title',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                article.description ?? 'No Description',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              leading: article.urlToImage != null
                                  ? Image.network(
                                article.urlToImage!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              )
                                  : Icon(Icons.image, size: 100),
                            );
                          },
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
