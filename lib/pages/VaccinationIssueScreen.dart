import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class VaccinationIssuesScreen extends StatefulWidget {
  final String uid;

  VaccinationIssuesScreen({required this.uid});

  @override
  _VaccinationIssuesScreenState createState() => _VaccinationIssuesScreenState();
}

class _VaccinationIssuesScreenState extends State<VaccinationIssuesScreen> {
  bool _showResponded = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vaccination Issues',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[100]!, Colors.white],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Show: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ToggleButtons(
                    borderRadius: BorderRadius.circular(20),
                    selectedColor: Colors.white,
                    fillColor: Colors.blue[700],
                    textStyle: const TextStyle(fontSize: 16),
                    borderColor: Colors.blue[700],
                    selectedBorderColor: Colors.blue[700],
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text('Responded'),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text('Not Responded'),
                      ),
                    ],
                    isSelected: [_showResponded, !_showResponded],
                    onPressed: (index) {
                      setState(() {
                        _showResponded = index == 0;
                      });
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('VaccinationIssues')
                      .where('uid', isEqualTo: widget.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snapshot.data!.docs;
                    if (docs.isEmpty) {
                      return Center(
                        child: Text(
                          "No Issues Found",
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                      );
                    }

                    final filteredDocs = docs.where((doc) {
                      final data = doc.data() as Map;
                      return _showResponded
                          ? data['response'] != null
                          : data['response'] == null;
                    }).toList();

                    return ListView.builder(
                      itemCount: filteredDocs.length,
                      itemBuilder: (context, index) {
                        final document = filteredDocs[index];
                        final data = document.data() as Map;

                        String formattedDate = 'No Date';
                        String month = '';
                        String day = '';
                        String year = '';
                        if (data['date'] != null) {
                          DateTime date = (data['date'] as Timestamp).toDate();
                          formattedDate = DateFormat('yyyy-MM-dd – HH:mm').format(date);
                          month = DateFormat('MMM').format(date);
                          day = DateFormat('dd').format(date);
                          year = DateFormat('yyyy').format(date);
                        }

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          color: Colors.grey[50],
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[700],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        month,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        day,
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        year,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['vaccineSerialNumber'] ?? 'Unknown Serial Number',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[700],
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Issue: ${data['issueDescription'] ?? 'No Description'}',
                                        style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                                      ),
                                      if (_showResponded) ...[
                                        SizedBox(height: 8),
                                        Text(
                                          'Response: ${data['response']}',
                                          style: TextStyle(fontSize: 15, color: Colors.green[700]),
                                        ),
                                      ],
                                      if (!_showResponded) ...[
                                        SizedBox(height: 8),
                                        Row(
                                          children: [
                                            ElevatedButton.icon(
                                              icon: Icon(Icons.edit, size: 18),
                                              label: Text('Edit'),
                                              onPressed: () => _editIssue(document.id, data['issueDescription']),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blue[700],
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            ElevatedButton.icon(
                                              icon: Icon(Icons.delete, size: 18),
                                              label: Text('Delete'),
                                              onPressed: () => _deleteIssue(document.id),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red[700],
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editIssue(String issueId, String currentDescription) async {
    TextEditingController _controller = TextEditingController(text: currentDescription);
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Issue Description'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Enter new issue description',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () {
                updateVaccinationIssue(issueId, _controller.text);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700]),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteIssue(String issueId) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this issue?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ElevatedButton(
            child: Text('Delete'),
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      await deleteIssues(issueId);
    }
  }

  Future<void> updateVaccinationIssue(String issueId, String issueDescription) async {
    try {
      await FirebaseFirestore.instance
          .collection('VaccinationIssues')
          .doc(issueId)
          .update({
        'issueDescription': issueDescription,
      });
    } catch (e) {
      print("Error updating response: $e");
    }
  }

  Future<void> deleteIssues(String issueId) async {
    try {
      await FirebaseFirestore.instance
          .collection('VaccinationIssues')
          .doc(issueId)
          .delete();
    } catch (e) {
      print("Error deleting issue: $e");
    }
  }
}