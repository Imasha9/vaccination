import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'appbar.dart';

class EmergencyHelpScreen extends StatefulWidget {
  const EmergencyHelpScreen({Key? key}) : super(key: key);

  @override
  State<EmergencyHelpScreen> createState() => _EmergencyHelpScreenState();
}

class _EmergencyHelpScreenState extends State<EmergencyHelpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: 'Emergency Contacts', // Set the title for this page
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue,
              Colors.white,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Emergency? Don\'t Panic, Just Dial!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white, // White color for contrast
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Container(
                width: double.infinity, // Full width
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildEmergencyButton(
                        icon: Icons.airport_shuttle_rounded,
                        label: '1990',
                        phoneNumber: '1990',
                        backgroundColor: Colors.red[100]!,
                        iconColor: Colors.red[400]!,
                      ),
                      _buildEmergencyButton(
                        icon: Icons.local_hospital_rounded,
                        label: 'Nearest Hospital',
                        phoneNumber: '0453453820',
                        backgroundColor: Colors.blue[100]!,
                        iconColor: Colors.blue[400]!,
                      ),
                      _buildEmergencyButton(
                        icon: Icons.health_and_safety_rounded,
                        label: 'Health & Safety',
                        phoneNumber: '1091',
                        backgroundColor: Colors.green[100]!,
                        iconColor: Colors.green,
                      ),
                      _buildEmergencyButton(
                        icon: Icons.airport_shuttle_rounded,
                        label: 'Ambulance',
                        phoneNumber: '6565',
                        backgroundColor: Colors.orange[100]!,
                        iconColor: Colors.orange,
                      ),
                      _buildEmergencyButton(
                        icon: Icons.local_hospital_rounded, // Use a different icon if available
                        label: 'Poison Control',
                        phoneNumber: '9090',
                        backgroundColor: Colors.purple[100]!,
                        iconColor: Colors.purple[400]!,
                      ),
                      _buildEmergencyButton(
                        icon: Icons.group_rounded,
                        label: 'Alert Friends',
                        phoneNumber: '588',
                        backgroundColor: Colors.yellow[100]!,
                        iconColor: Colors.yellow[700]!, // Changed to yellowAccent for consistency
                      ),
                    ],
                  ),
                ),
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
    required Color backgroundColor,
    required Color iconColor,
    String? phoneNumber,
    VoidCallback? onPressed,
  }) {
    return ElevatedButton(
      onPressed: () {
        if (phoneNumber != null && phoneNumber.isNotEmpty) {
          FlutterPhoneDirectCaller.callNumber(phoneNumber);
        } else if (onPressed != null) {
          onPressed();
        }
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        backgroundColor: backgroundColor, // Use provided background color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24), // More rounded corners
        ),
        elevation: 4,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: iconColor), // Larger icon size with matching color
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 19, color: Colors.black), // Adjusted font size
          ),
        ],
      ),
    );
  }
}
