import 'package:cloud_firestore/cloud_firestore.dart';

class Completion {
  final String title;
  final List<ProgressRecord> progress;

  Completion({
    required this.title,
    required this.progress,
  });

  // Firestore -> Dart
  factory Completion.fromJson(Map<String, dynamic> json) {
    return Completion(
      title: json['title'],
      progress: (json['progress'] as List<dynamic>)
          .map((e) => ProgressRecord.fromJson(e))
          .toList(),
    );
  }

  // Dart -> Firestore
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'progress': progress.map((e) => e.toJson()).toList(),
    };
  }
}

class ProgressRecord {
  final Timestamp date;
  final bool isCompleted;

  ProgressRecord({
    required this.date,
    required this.isCompleted,
  });

  factory ProgressRecord.fromJson(Map<String, dynamic> json) {
    return ProgressRecord(
      date: Timestamp.fromDate(DateTime.parse(json['date'])),
      isCompleted: json['isCompleted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toDate().toIso8601String(),
      'isCompleted': isCompleted,
    };
  }
}
