import 'package:cloud_firestore/cloud_firestore.dart';

class AssignmentModel {
  final String assignmentId;
  final String name;
  final DateTime dueDate;

  AssignmentModel({
    required this.assignmentId,
    required this.name,
    required this.dueDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dueDate': Timestamp.fromDate(dueDate),
    };
  }

  factory AssignmentModel.fromMap(Map<String, dynamic> map, String documentId) {
    final dueDateValue = map['dueDate'];
    DateTime parsedDueDate;

    if (dueDateValue is Timestamp) {
      parsedDueDate = dueDateValue.toDate();
    } else if (dueDateValue is String) {
      parsedDueDate = DateTime.tryParse(dueDateValue) ?? DateTime.now();
    } else {
      parsedDueDate = DateTime.now();
    }

    return AssignmentModel(
      assignmentId: documentId,
      name: (map['name'] ?? '').toString(),
      dueDate: parsedDueDate,
    );
  }
}
