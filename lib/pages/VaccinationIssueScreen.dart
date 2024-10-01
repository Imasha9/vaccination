import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VaccinationIssuesScreen extends StatelessWidget {
  final String uid;

  VaccinationIssuesScreen({required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vaccination Issues'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios), // Custom back icon
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0), // Top and side margins
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('VaccinationIssues')
              .where('uid', isEqualTo: uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;
            if (docs.isEmpty) {
              return const Center(child: Text("No Issues Found"));
            }

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final document = docs[index];
                final data = document.data() as Map<String, dynamic>;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0), // Space between list items
                  child: ListTile(
                    title: Text(data['vaccineSerialNumber'] ?? 'Unknown Serial Number'),
                    subtitle: Text(data['issueDescription'] ?? 'No Description'),
                    trailing: Text(data['date']?.toDate()?.toString() ?? 'No Date'),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
