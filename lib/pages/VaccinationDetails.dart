import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'VaccinationIssueScreen.dart';

class VaccinationForm extends StatefulWidget {
  @override
  _VaccinationFormState createState() => _VaccinationFormState();
}

class _VaccinationFormState extends State<VaccinationForm> {
  final TextEditingController _vaccineNumberController = TextEditingController();
  final TextEditingController _centerController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nicController = TextEditingController();
  final TextEditingController _issueDescriptionController = TextEditingController();

  String uid = '';

  @override
  void initState() {
    super.initState();
    _loadUID();
  }

  void _loadUID() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        uid = user.uid;
      });
      _loadNIC(uid);
    }
  }

  void _loadNIC(String uid) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (userDoc.exists) {
      setState(() {
        _nicController.text = userDoc['nic'] ?? 'NIC Not Found';
      });
    }
  }

  void _submitForm() async {
    String vaccineSerialNumber = _vaccineNumberController.text.trim();
    String center = _centerController.text.trim();
    String name = _nameController.text.trim();
    String nic = _nicController.text.trim();

    await FirebaseFirestore.instance.collection('VaccinationDetails').add({
      'uid': uid,
      'nic': nic,
      'vaccineSerialNumber': vaccineSerialNumber,
      'center': center,
      'name': name,
      'status': 'Pending',
      'date': DateTime.now(),
    });

    _vaccineNumberController.clear();
    _centerController.clear();
    _nameController.clear();

    _showSuccessMessage('Vaccination details added successfully');
  }

  void _updateForm(String docId) async {
    String vaccineSerialNumber = _vaccineNumberController.text.trim();
    String center = _centerController.text.trim();
    String name = _nameController.text.trim();

    await FirebaseFirestore.instance.collection('VaccinationDetails').doc(docId).update({
      'vaccineSerialNumber': vaccineSerialNumber,
      'center': center,
      'name': name,
    });

    _vaccineNumberController.clear();
    _centerController.clear();
    _nameController.clear();

    _showSuccessMessage('Vaccination details updated successfully');
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showFormBottomSheet({DocumentSnapshot? document}) {
    final bool isUpdate = document != null;

    if (isUpdate) {
      final data = document!.data() as Map<String, dynamic>;
      _vaccineNumberController.text = data['vaccineSerialNumber'] ?? '';
      _centerController.text = data['center'] ?? '';
      _nameController.text = data['name'] ?? '';
    } else {
      _vaccineNumberController.clear();
      _centerController.clear();
      _nameController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isUpdate ? 'Update Vaccination Details' : 'Add Vaccination Details',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  _buildTextField(_vaccineNumberController, 'Vaccine Serial Number', Icons.vaccines),
                  SizedBox(height: 16),
                  _buildTextField(_centerController, 'Center', Icons.location_on),
                  SizedBox(height: 16),
                  _buildTextField(_nameController, 'Name', Icons.person),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (isUpdate) {
                              _updateForm(document!.id);
                            } else {
                              _submitForm();
                            }
                            Navigator.of(context).pop();
                          },
                          child: Text(isUpdate ? 'Update' : 'Submit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }

  void _showDetailDialog(DocumentSnapshot document) {
    final data = document.data() as Map<String, dynamic>;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Vaccination Details'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailItem('Name', data['name'] ?? 'Unknown'),
                _buildDetailItem('Center', data['center'] ?? 'Unknown'),
                _buildDetailItem('Vaccine Serial Number', data['vaccineSerialNumber'] ?? 'Unknown'),
                _buildDetailItem('Status', data['status'] ?? 'Unknown'),
                _buildDetailItem('NIC', data['nic'] ?? 'Unknown'),
                SizedBox(height: 16),
                TextField(
                  controller: _issueDescriptionController,
                  decoration: InputDecoration(
                    labelText: 'Issue Description',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                String issueDescription = _issueDescriptionController.text.trim();
                if (issueDescription.isNotEmpty) {
                  await FirebaseFirestore.instance.collection('VaccinationIssues').add({
                    'uid': uid,
                    'vaccineSerialNumber': data['vaccineSerialNumber'],
                    'issueDescription': issueDescription,
                    'date': DateTime.now(),
                  });
                  _issueDescriptionController.clear();
                  Navigator.of(context).pop();
                  _showSuccessMessage('Issue reported successfully');
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => VaccinationIssuesScreen(uid: uid),
                  ));
                }
              },
              child: Text('Submit Issue'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vaccination Details'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.report_problem),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => VaccinationIssuesScreen(uid: uid),
              ));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('VaccinationDetails')
                    .where('uid', isEqualTo: uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return Center(
                      child: Text(
                        "No Vaccination Details Found",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final document = docs[index];
                      final data = document.data() as Map<String, dynamic>;

                      return Card(
                        elevation: 4,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          title: Text(
                            data['name'] ?? 'Unknown',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 8),
                              Text('Vaccine: ${data['vaccineSerialNumber'] ?? 'Unknown'}'),
                              Text('Center: ${data['center'] ?? 'Unknown'}'),
                              Text('Status: ${data['status'] ?? 'Unknown'}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showFormBottomSheet(document: document),
                              ),
                              IconButton(
                                icon: Icon(Icons.info_outline, color: Colors.green),
                                onPressed: () => _showDetailDialog(document),
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormBottomSheet(),
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}