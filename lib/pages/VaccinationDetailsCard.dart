import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class VaccinationDetailsCard extends StatelessWidget {
  final Map<String, dynamic> vaccinationData;
  final String vaccineId;

  VaccinationDetailsCard({
    required this.vaccinationData,
    required this.vaccineId,
  });

  @override
  Widget build(BuildContext context) {
    String nic = vaccinationData['nic'] ?? 'Unknown NIC';
    String name = vaccinationData['name'] ?? 'Unknown Name';
    String status = vaccinationData['status'] ?? 'Unknown Status';
    String vaccineSerialNumber = vaccinationData['vaccineSerialNumber'] ?? 'Unknown Serial Number';
    String center = vaccinationData['center'] ?? 'Unknown Center';

    DateTime? vaccinationDate = vaccinationData['date']?.toDate();
    String formattedDate = vaccinationDate != null
        ? DateFormat('MMM dd, yyyy').format(vaccinationDate)
        : 'No date available';

    Future<void> _updateStatus(String newStatus) async {
      if (vaccineId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: Vaccine ID is missing.")),
        );
        return;
      }

      try {
        await FirebaseFirestore.instance
            .collection('VaccinationDetails')
            .doc(vaccineId)
            .update({'status': newStatus});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Status updated to $newStatus")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating status: $e")),
        );
      }
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: status == 'Approved' ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _buildInfoRow(Icons.credit_card, "NIC", nic),
              _buildInfoRow(Icons.qr_code, "Vaccine Serial", vaccineSerialNumber),
              _buildInfoRow(Icons.local_hospital, "Center", center),
              _buildInfoRow(Icons.calendar_today, "Date", formattedDate),
              SizedBox(height: 16),
              if (status != 'Approved' && status != 'Rejected')
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      onPressed: () => _updateStatus('Approved'),
                      icon: Icons.check_circle,
                      label: 'Approve',
                      color: Colors.green,
                    ),
                    _buildActionButton(
                      onPressed: () => _updateStatus('Rejected'),
                      icon: Icons.cancel,
                      label: 'Reject',
                      color: Colors.red,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue.shade600),
          SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                children: [
                  TextSpan(text: "$label: ", style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}