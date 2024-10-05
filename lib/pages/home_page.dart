import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'news.dart';
import 'my_appointments_page.dart';
import 'notification_page.dart';
import 'posts_page.dart';
import 'emergency_contact.dart';
import 'package:vaccination/models/article.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<Article>>? _latestNews;

  @override
  void initState() {
    super.initState();
    _latestNews = fetchLatestNews();
  }

  Future<List<Article>> fetchLatestNews() async {
    try {
      final String apiKey = '987b06cfc70542919758e1e0cf36d052';
      final response = await http.get(
        Uri.parse(
            'https://newsapi.org/v2/top-headlines?country=us&category=health&apiKey=$apiKey'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> articlesJson = data['articles'];

        List<Article> validArticles = articlesJson
            .map((json) => Article.fromJson(json))
            .where((article) =>
        article.title != '[Removed]' && article.urlToImage != null)
            .toList();

        return validArticles
            .take(3)
            .toList(); // Show the first 3 valid articles
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
        automaticallyImplyLeading:
        true, // This ensures the back button is shown
        backgroundColor: Colors.blue, // Top blue background
        elevation: 0,
        title: const Center(
          // Center the title
          child: Text(
            'VacciCare',
            style: TextStyle(
                color: Colors.white, // Change title color to white
                fontSize: 30,
                fontWeight: FontWeight.bold // Adjust font size if needed
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications,
                color: Colors.white), // Change notification icon color to white
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const NotificationPage()),
              );
            },
          ),
        ],
        iconTheme: const IconThemeData(
          color: Colors.white, // Change the back button color to white
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue, // Start color
                Colors.white, // End color
              ],
              begin: Alignment.topCenter, // Gradient direction
              end: Alignment.bottomCenter,
              stops: [0.0, 0.2],
            ),
          ), // Top background color
          child: Column(
            children: [
              // Header Image
              Padding(
                padding: const EdgeInsets.all(0.0),
                child: Image.asset(
                  'images/homebg.png', // Example image
                  width: MediaQuery.of(context).size.width * 0.8,
                  fit: BoxFit.contain,
                ),
              ),

              // White rounded corner background container
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // My Appointments and Community Posts buttons
                    _buildCustomButton(
                      icon: Icons.calendar_today_rounded,
                      label: "My Appointments",
                      subtitle: "See your upcoming visits", // Added subtitle
                      color: Colors.blue,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => MyAppointments()));
                      },
                    ),
                    SizedBox(height: 8),

                    // Quick Access Menu
                    const Text("Quick Access Menu",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue)),
                    SizedBox(height: 16),
                    _buildQuickAccessMenu(),

                    // Latest Health News Section
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .center, // Align content in the center horizontally
                        children: [
                          const Center(
                            // Wrap the Text widget in Center
                            child: Text(
                              'Latest Health News',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            ),
                          ),
                          SizedBox(height: 8),
                          FutureBuilder<List<Article>>(
                            future: _latestNews,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return const Text('No news available at the moment');
                              } else {
                                return Column(
                                  children: snapshot.data!.map((article) {
                                    return _buildNewsCard(article);
                                  }).toList(),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Custom Button Builder
  Widget _buildCustomButton(
      {required IconData icon,
        required String label,
        required String subtitle,
        required Color color,
        required Function onTap}) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: () => onTap(),
        leading: Icon(icon, size: 40, color: Colors.blue),
        title: Text(
          label,
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blue),
      ),
    );
  }

  // News Card Builder
  Widget _buildNewsCard(Article article) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Provide a fallback value for the title if it's null
            Text(
              article.title ?? 'No Title Available', // Fallback string
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            ),
            const SizedBox(height: 8),
            if (article.urlToImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(article.urlToImage!,
                    height: 150, width: double.infinity, fit: BoxFit.cover),
              ),
            const SizedBox(height: 8),
            Text(
              article.description ??
                  'No description available', // Provide fallback for description as well
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  // Quick Access Menu
  // Quick Access Menu
  Widget _buildQuickAccessMenu() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildQuickAccessButton("Health News", Icons.health_and_safety,
            Colors.green[100]!, Colors.green, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => NewsPage()));
            }),
        _buildQuickAccessButton("Emergency Contacts", Icons.contact_phone,
            Colors.red[100]!, Colors.red, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => EmergencyHelpScreen()));
            }),
        _buildQuickAccessButton("Issue Responses", Icons.announcement_rounded,
            Colors.yellow[100]!, Colors.yellow[700]!, () {
              // Add your issue responses page navigation here
            }),
        _buildQuickAccessButton("My Vaccine Records", Icons.vaccines,
            Colors.teal[100]!, Colors.teal, () {
              // Add your vaccine records page navigation here
            }),
        _buildQuickAccessButton("Notifications", Icons.notifications_active,
            Colors.blue[100]!, Colors.blue, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationPage()));
            }),
        _buildQuickAccessButton("Community Posts", Icons.forum_rounded,
            Colors.purple[200]!, Colors.purple[400]!, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => PostsPage()));
            }),
      ],
    );
  }

// Quick Access Button Builder
  Widget _buildQuickAccessButton(
      String label, IconData icon, Color bgColor, Color iconColor, Function onTap) {
    return Column(
      children: [
        // Button with smaller size and background color
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: bgColor, // Apply the background color
          child: InkWell(
            onTap: () => onTap(),
            child: Padding(
              padding: const EdgeInsets.all(22.0), // Adjust padding to make it smaller
              child: Icon(icon, size: 48, color: iconColor), // Smaller icon
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}