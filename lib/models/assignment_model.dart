import 'package:cloud_firestore/cloud_firestore.dart';

class AssignmentModel {
  final String assignmentId;
  final String name;
  final DateTime dueDate;
  final bool? status; // Add the status boolean

  AssignmentModel({
    required this.assignmentId,
    required this.name,
    required this.dueDate,
    this.status = false, // Defaults to false
  });

  factory AssignmentModel.fromMap(Map<String, dynamic> map, String documentId) {
    return AssignmentModel(
      assignmentId: documentId,
      name: map['name'] ?? '',
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      // Adding ?? false ensures old data without a status doesn't crash the app!
      status: map['status'] ?? false, 
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dueDate': Timestamp.fromDate(dueDate),
      'status': status,
    };
  }
}
