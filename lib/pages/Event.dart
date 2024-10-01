import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final String place;
  final DateTime date;
  final String startTime;
  final String endTime;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.place,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  factory Event.fromMap(Map<String, dynamic> data) {
    return Event(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      place: data['place'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'place': place,
      'date': Timestamp.fromDate(date),
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}