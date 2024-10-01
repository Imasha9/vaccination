import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'call.dart';

class EmergencyHelpScreen extends StatefulWidget {
  const EmergencyHelpScreen({Key? key}) : super(key: key);

  @override
  State<EmergencyHelpScreen> createState() => _EmergencyHelpScreenState();
}

class _EmergencyHelpScreenState extends State<EmergencyHelpScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,


      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Emergency Help Needed?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Icon(
                    Icons.phone_in_talk,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),

            SizedBox(height: 32),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildEmergencyButton(
                    icon: Icons.local_hospital,
                    label: 'hospital',
                    phoneNumber: '100',
                  ),
                  _buildEmergencyButton(
                    icon: Icons.health_and_safety_rounded,
                    label: 'health and safety',
                    phoneNumber: '1091',
                  ),
                  _buildEmergencyButton(
                    icon: Icons.airport_shuttle_outlined,
                    label: 'Ambulance',
                    phoneNumber: '134',

                  ),
                  _buildEmergencyButton(
                    icon: Icons.group,
                    label: 'Alert Friends',
                    phoneNumber: '588',

                  ),
                ],
              ),
            ),
          ],
        ),
      ),

    );
  }

  Widget _buildEmergencyButton({
    required IconData icon,
    required String label,
    String? phoneNumber,
    VoidCallback? onPressed,
  }) {
    return ElevatedButton(
      onPressed: () {
        if (phoneNumber != null && phoneNumber.isNotEmpty) {
          if (phoneNumber.startsWith('tel:')) {
            launchUrl(Uri.parse(phoneNumber));
          } else {
            FlutterPhoneDirectCaller.callNumber(phoneNumber);
          }
        } else if (onPressed != null) {
          onPressed();
        }
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}