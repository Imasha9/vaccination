import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database.dart';

class VaccinationIssueCard extends StatefulWidget {
  final Map<String, dynamic> issueData;
  final String issueId;
  final String uid;
  final String userEmail;

  VaccinationIssueCard({
    required this.issueData,
    required this.issueId,
    required this.uid,
    required this.userEmail,
  });

  @override
  _VaccinationIssueCardState createState() => _VaccinationIssueCardState();
}

class _VaccinationIssueCardState extends State<VaccinationIssueCard> {
  TextEditingController _responseController = TextEditingController();
  String? _selectedResponseType;
  String _userName = "Loading..."; // Default text while loading the name

  @override
  void initState() {
    super.initState();
    _loadUserName(widget.issueData['uid'] ); // Fetch the user name when the widget is initialized
  }

  // Method to load user name from Firestore using uid
  void _loadUserName(String uid) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        setState(() {
          _userName = userDoc['name'] ?? 'Name Not Found'; // Assuming "name" field exists
        });
      } else {
        setState(() {
          _userName = 'Name Not Found';
        });
      }
    } catch (e) {
      setState(() {
        _userName = 'Error fetching name';
      });
      print(e.toString());
    }
  }

  void submitResponse() {
    if (_responseController.text.isNotEmpty) {
      String newResponse = _responseController.text;
      DatabaseMethods().updateVaccinationIssueResponse(
        widget.issueId,
        newResponse,
        _selectedResponseType ?? "Pending",
      );
      setState(() {
        _responseController.clear();
        _selectedResponseType = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String vaccineName = widget.issueData['vaccineSerialNumber'] ?? 'Unknown Vaccine';
    String issueDescription = widget.issueData['issueDescription'] ?? 'No description provided';
    String response = widget.issueData['response'] ?? '';
    DateTime? timestamp = widget.issueData['date']?.toDate();
    String formattedDate = timestamp != null
        ? DateFormat('MMM dd, yyyy – HH:mm').format(timestamp)
        : 'No date available';

    bool isResponded = response.isNotEmpty;
    Color cardColor = isResponded ? Colors.green[50]! : Colors.orange[50]!;

    return Card(
      color: cardColor,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Colors.blue[700], size: 28),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "User: $_userName",  // Now displaying the fetched username
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.medical_services, color: Colors.purple[700], size: 24),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Vaccine: $vaccineName",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.purple[700],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning, color: Colors.red[700], size: 24),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Issue: $issueDescription",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.red[700],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isResponded ? Icons.check_circle : Icons.hourglass_empty,
                  color: isResponded ? Colors.green[700] : Colors.orange[700],
                  size: 24,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Response: ${isResponded ? response : 'Awaiting response'}",
                    style: TextStyle(
                      fontSize: 16,
                      color: isResponded ? Colors.green[700] : Colors.orange[700],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.grey[700], size: 20),
                SizedBox(width: 8),
                Text(
                  "Reported: $formattedDate",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            if (!isResponded) ...[
              SizedBox(height: 20),
              TextField(
                controller: _responseController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Type your response here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blue[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blue[500]!, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: submitResponse,
                icon: Icon(Icons.send),
                label: Text(
                  "Submit Response",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResponseTypeButton(String type, IconData icon, Color color) {
    bool isSelected = _selectedResponseType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedResponseType = type;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey[400]!,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            SizedBox(width: 4),
            Text(
              type,
              style: TextStyle(
                color: color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
