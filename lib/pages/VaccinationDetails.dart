import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

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
  bool showApproved = false;

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
                  ElevatedButton(
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
                      foregroundColor: Colors.white, backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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

  void _showEditFormBottomSheet(DocumentSnapshot document) {
    final data = document.data() as Map<String, dynamic>;
    _vaccineNumberController.text = data['vaccineSerialNumber'] ?? '';
    _centerController.text = data['center'] ?? '';
    _nameController.text = data['name'] ?? '';

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
                    'Update Vaccination Details',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  _buildTextField(_vaccineNumberController, 'Vaccine Serial Number', Icons.vaccines),
                  SizedBox(height: 16),
                  _buildTextField(_centerController, 'Center', Icons.location_on),
                  SizedBox(height: 16),
                  _buildTextField(_nameController, 'Name', Icons.person),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      _updateForm(document.id);
                      Navigator.of(context).pop();
                    },
                    child: Text('Update'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showReportIssueDialog(DocumentSnapshot document) {
    final data = document.data() as Map<String, dynamic>;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Report Issue'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailItem('Name', data['name'] ?? 'Unknown'),
                _buildDetailItem('Center', data['center'] ?? 'Unknown'),
                _buildDetailItem('Vaccine Serial Number', data['vaccineSerialNumber'] ?? 'Unknown'),
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
                }
              },
              child: Text('Submit Issue'),
            ),
          ],
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

  Widget _buildVaccinationCard(DocumentSnapshot document) {
    final data = document.data() as Map<String, dynamic>;
    final bool isApproved = data['status'] == 'Approved';

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date column
            Column(
              children: [
                Text(
                  DateFormat('MMM').format((data['date'] as Timestamp).toDate()),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                Text(
                  DateFormat('dd').format((data['date'] as Timestamp).toDate()),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  DateFormat('yyyy').format((data['date'] as Timestamp).toDate()),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            SizedBox(width: 16),
            // Details column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['name'] ?? 'Unknown',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  SizedBox(height: 8),
                  _buildDetailItem('Center', data['center'] ?? 'Unknown', Icons.location_on),
                  _buildDetailItem('Vaccine Serial Number', data['vaccineSerialNumber'] ?? 'Unknown', Icons.vaccines),
                  _buildDetailItem('NIC', data['nic'] ?? 'Unknown', Icons.perm_identity),
                  _buildDetailItem('Status', data['status'], isApproved ? Icons.check_circle : Icons.pending),
                  SizedBox(height: 6),
                  if (!isApproved)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showEditFormBottomSheet(document),
                        ),
                        IconButton(
                          icon: Icon(Icons.report_problem, color: Colors.red),
                          onPressed: () => _showReportIssueDialog(document),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, [IconData? icon]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          if (icon != null) Icon(icon, size: 18),
          if (icon != null) SizedBox(width: 8),
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Vaccines'),
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
      body: Column(
        children: [
          // Toggle Button Row (Pending, Approved)
          Container(
            padding: EdgeInsets.all(10),
            color: Colors.blue.shade600,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildToggleButton('Pending', showApproved == false),
                _buildToggleButton('Approved', showApproved == true),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('VaccinationDetails')
                  .where('uid', isEqualTo: uid)
                  .where('status', isEqualTo: showApproved ? 'Approved' : 'Pending')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final docs = snapshot.data!.docs.toList();
                  return ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: docs.length,
                    itemBuilder: (context, index) => _buildVaccinationCard(docs[index]),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading data'));
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormBottomSheet(),
        icon: Icon(Icons.add),
        label: Text('Add Vaccination'),
        backgroundColor: Colors.blue,
      ),
    );
  }


  Widget _buildToggleButton(String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        setState(() {
          showApproved = label == 'Approved';
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.blue.shade600,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.blue : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),


    );
  }

}
