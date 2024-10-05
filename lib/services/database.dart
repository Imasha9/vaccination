import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to add a user
  Future<void> addUser(String userId, Map<String, dynamic> userInfoMap) {
    userInfoMap['role'] = 'user'; // Default to user role
    return FirebaseFirestore.instance.collection("User").doc(userId).set(userInfoMap);
  }
  Future<void> addUserAsAdmin(String userId, Map<String, dynamic> userInfoMap) {
    userInfoMap['role'] = 'admin'; // Admin role
    return FirebaseFirestore.instance.collection("User").doc(userId).set(userInfoMap);
  }


  // Method to add an event
  Future<void> addEvent(String userId, String title, String description, String place, DateTime date, String startTime, String endTime) async {
    final eventRef =  await _firestore.collection("Events").add({
      'userId': userId,
      'title': title,
      'description': description,
      'place': place,
      'date': Timestamp.fromDate(date),
      'startTime': startTime,
      'endTime': endTime,
      'timestamp': Timestamp.now(),
    });

    // Generate notification after event is added
    await addNotification(
        userId,
        "Event added: $title at $place on ${date.toString().split(" ")[0]}, starts at $startTime and ends at $endTime."
    );
  }

  // Method to add a notification
  Future<void> addNotification(String userId, String message) {
    return FirebaseFirestore.instance.collection("Notifications").add({
      'userId': userId,
      'message': message,
      'timestamp': Timestamp.now(),
    });
  }

  // Method to get notifications
  Stream<QuerySnapshot> getNotifications() {
    return FirebaseFirestore.instance.collection("Notifications").orderBy('timestamp', descending: true).snapshots();
  }


  Stream<QuerySnapshot> getEventsForDay(DateTime selectedDay) {
    final startOfDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    final endOfDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day, 23, 59, 59);

    return FirebaseFirestore.instance
        .collection('Events')
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThanOrEqualTo: endOfDay)
        .snapshots();
  }


  Future<void> updateEvent(String docId, String userId, String title, String description, String place, DateTime date, String startTime, String endTime) {
    return _firestore.collection("Events").doc(docId).update({
      'userId': userId,
      'title': title,
      'description': description,
      'place': place,
      'date': Timestamp.fromDate(date),
      'startTime': startTime,
      'endTime': endTime,
    });
  }

  Future<void> deleteEvent(String docId) {
    return _firestore.collection("Events").doc(docId).delete();
  }

  Future<QuerySnapshot> getAllEvents() async {
    return _firestore.collection('Events').get();
  }

  // Method to add a vaccination issue
  Future<void> addVaccinationIssue(String uid, String vaccineName, String issueDescription) async {
    // Fetch vaccine details
    final vaccineDetailsSnapshot = await FirebaseFirestore.instance
        .collection('VaccinationDetails')
        .where('uid', isEqualTo: uid)
        .where('vaccineName', isEqualTo: vaccineName)
        .orderBy('date', descending: true)
        .limit(1)
        .get();

    if (vaccineDetailsSnapshot.docs.isEmpty) {
      throw Exception("No vaccine details found for the selected vaccine name.");
    }

    final vaccineData = vaccineDetailsSnapshot.docs.first.data() as Map<String, dynamic>;

    // Add issue to VaccinationIssues collection
    await FirebaseFirestore.instance.collection('VaccinationIssues').add({
      'uid': uid,
      'vaccineName': vaccineName,
      'issueDescription': issueDescription,
      'vaccineDetails': vaccineData,
      'timestamp': Timestamp.now(),
    });
  }

  // Method to retrieve vaccine names for the user
  Stream<List<String>> getVaccineNames(String uid) {
    return FirebaseFirestore.instance
        .collection('VaccinationDetails')
        .where('uid', isEqualTo: uid)
        .where('date', isGreaterThanOrEqualTo: DateTime.now().subtract(Duration(days: 90)))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => (doc.data() as Map<String, dynamic>)['vaccineName'] as String)
        .toSet() // Remove duplicates
        .toList());
  }

  // Method to get vaccination issues for the user
  Stream<QuerySnapshot> getVaccinationIssues(String uid) {
    return FirebaseFirestore.instance
        .collection('VaccinationIssues')
        .where('uid', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }


}
