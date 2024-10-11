import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentDatabaseMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to add an appointment with event ID
  Future<void> addAppointment(
      String userId,
      String username,
      String email,
      String phone,
      DateTime dob,
      String gender,
      String? optionalMessage,
      String eventId,
      DateTime startTime, // Add startTime parameter
      DateTime endTime,   // Add endTime parameter
      String description,  // Add description parameter
      String place,        // Add place parameter
      String title         // Add title parameter
      ) {
    return _firestore.collection("Appointments").add({
      'userId': userId,
      'username': username,
      'email': email,
      'phone': phone,
      'dob': Timestamp.fromDate(dob),
      'gender': gender,
      'optionalMessage': optionalMessage ?? '',
      'status': 'pending', // Default status
      'eventId': eventId,  // Event ID added
      'timestamp': Timestamp.now(),
      'startTime': startTime, // Store start time as Timestamp
      'endTime': endTime,     // Store end time as Timestamp
      'description': description, // Store description
      'place': place, // Store place
      'title': title, // Store title
    });
  }





  // Method to view appointment by ID
  Future<DocumentSnapshot> getAppointmentById(String docId) {
    return _firestore.collection("Appointments").doc(docId).get();
  }

  // Method to view all appointments
  Stream<QuerySnapshot> getAllAppointments() {
    return _firestore.collection("Appointments").orderBy('timestamp', descending: true).snapshots();
  }

  // Method to update an appointment (without eventId)
  Future<void> updateAppointment(
      String docId,
      String username,
      String email,
      String phone,
      DateTime dob,
      String gender,
      String? optionalMessage,
      String status) {
    return _firestore.collection("Appointments").doc(docId).update({
      'username': username,
      'email': email,
      'phone': phone,
      'dob': Timestamp.fromDate(dob),
      'gender': gender,
      'optionalMessage': optionalMessage ?? '',
      'status': 'pending', // Updated status
      'timestamp': Timestamp.now(),
    });
  }

  // Method to delete an appointment
  Future<void> deleteAppointment(String docId) {
    return _firestore.collection("Appointments").doc(docId).delete();
  }

  // Method to get appointments by user ID
  Stream<QuerySnapshot> getAppointmentsByUserId(String userId) {
    return _firestore
        .collection("Appointments")
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<QuerySnapshot> getAppointmentsForUser(String userId) {
    return _firestore
        .collection('appointments') // Adjust this to your collection name
        .where('userId', isEqualTo: userId) // Filter by user ID
        .get();
  }

  Stream<QuerySnapshot> getEventsForDay(DateTime selectedDay) {
    // Set the start of the day (midnight) and end of the day (23:59:59)
    final startOfDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day, 0, 0, 0).toUtc();
    final endOfDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day, 23, 59, 59).toUtc();


    return FirebaseFirestore.instance
        .collection('Appointments')
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay)) // Events starting after or on the start of the day
        .where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay)) // Events starting before or on the end of the day
        .snapshots();
  }

}
