import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'VaccinationDetailsCard.dart'; // Ensure this import matches your file structure

class AdminVaccineApproval extends StatefulWidget {
  @override
  _AdminVaccineApprovalState createState() => _AdminVaccineApprovalState();
}

class _AdminVaccineApprovalState extends State<AdminVaccineApproval> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _showApproved = true; // State to toggle between approved and new added statuses

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllVaccinationDetails() {
    return _firestore.collection('VaccinationDetails').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50], // Light blue-grey background for a modern look
      appBar: AppBar(
        title: Text("Vaccination Approval"),
        centerTitle: true, // Center the title
        backgroundColor: Colors.blue[700], // Deep blue for app bar to stand out
        elevation: 5.0, // Add some elevation to give the app bar a shadow
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 20), // Add vertical margin
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, // Center the row
              children: [
                Text(
                  _showApproved ? "Approved" : "New Added",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700, // More boldness for emphasis
                    color: Colors.blue[800], // Dark blue text for contrast
                  ),
                ),
                SizedBox(width: 15), // Space between text and switch
                Container(
                  width: 60, // Set a fixed width for a square toggle
                  height: 30, // Set a fixed height for a square toggle
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12, // Subtle shadow effect
                        offset: Offset(2, 2),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Switch(
                    value: _showApproved,
                    onChanged: (value) {
                      setState(() {
                        _showApproved = value;
                      });
                    },
                    activeColor: Colors.greenAccent,
                    inactiveTrackColor: Colors.grey[400],
                    inactiveThumbColor: Colors.white, // Change thumb color
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: getAllVaccinationDetails(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      "No vaccination details available",
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                  );
                }

                var vaccinationDetails = snapshot.data!.docs;

                // Filter vaccination details based on the toggle
                var filteredDetails = vaccinationDetails.where((doc) {
                  var vaccinationData = doc.data();
                  return _showApproved
                      ? vaccinationData['status'] == 'Approved' // Show approved details
                      : vaccinationData['status'] != 'Approved'; // Show new added details
                }).toList();

                return ListView.builder(
                  itemCount: filteredDetails.length,
                  itemBuilder: (context, index) {
                    var vaccinationData = filteredDetails[index].data();
                    String vaccineId = filteredDetails[index].id; // Get the document ID

                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10), // Add margin around cards
                      decoration: BoxDecoration(
                        color: Colors.white, // White background for the cards
                        borderRadius: BorderRadius.circular(15), // Rounded corners for a modern look
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12, // Shadow to add depth
                            blurRadius: 8, // Spread the shadow softly
                            offset: Offset(3, 3), // Move shadow slightly
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15), // Add padding inside the card
                        child: VaccinationDetailsCard(
                          vaccinationData: vaccinationData,
                          vaccineId: vaccineId, // Pass vaccineId to VaccinationDetailsCard
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
