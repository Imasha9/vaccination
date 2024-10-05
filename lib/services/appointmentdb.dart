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
      String eventId) {
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
      'status': status, // Updated status
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
}
