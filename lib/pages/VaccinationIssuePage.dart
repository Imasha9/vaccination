import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/database.dart';
import 'VaccintaionIssueCard.dart';

class VaccinationIssuePage extends StatefulWidget {
  @override
  _VaccinationIssuePageState createState() => _VaccinationIssuePageState();
}

class _VaccinationIssuePageState extends State<VaccinationIssuePage> {
  final DatabaseMethods databaseMethods = DatabaseMethods();
  String uid = 'uid'; // Default value
  String userEmail = 'Not available'; // Default value

  bool showRespondedIssues = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Issues"),
        actions: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      showRespondedIssues = false;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: !showRespondedIssues ? Colors.blue : Colors.grey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Not Responded",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      showRespondedIssues = true;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: showRespondedIssues ? Colors.blue : Colors.grey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Responded",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: databaseMethods.getAllVaccinationIssuesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No vaccination issues found"));
          }

          var allIssues = snapshot.data!.docs;

          var respondedIssues = allIssues.where((doc) {
            return doc.data()['response'] != null && doc.data()['response'].isNotEmpty;
          }).toList();

          var notRespondedIssues = allIssues.where((doc) {
            return doc.data()['response'] == null || doc.data()['response'].isEmpty;
          }).toList();

          var issuesToShow =
          showRespondedIssues ? respondedIssues : notRespondedIssues;

          if (issuesToShow.isEmpty) {
            return Center(
              child: Text(
                showRespondedIssues
                    ? "No responded issues found"
                    : "No non-responded issues found",
              ),
            );
          }

          return ListView.builder(
            itemCount: issuesToShow.length,
            itemBuilder: (context, index) {
              var issueData = issuesToShow[index].data();
              String issueId = issuesToShow[index].id;

              return VaccinationIssueCard(
                issueData: issueData,
                issueId: issueId,
                uid: uid,
                userEmail: userEmail,
              );
            },
          );
        },
      ),
    );
  }
}