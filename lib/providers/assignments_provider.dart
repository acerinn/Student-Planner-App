import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/assignment_model.dart';

class AssignmentsProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<AssignmentModel> _assignments = [];

  List<AssignmentModel> get assignments => List.unmodifiable(_assignments);

  Future<void> fetchAssignments() async {
    try {
      final snapshot = await _firestore
          .collection('assignments')
          .orderBy('dueDate')
          .get();

      _assignments = snapshot.docs
          .map(
            (doc) => AssignmentModel.fromMap(
              doc.data(),
              doc.id,
            ),
          )
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching assignments: $e');
    }
  }

  Future<void> addAssignment({
    required String name,
    required DateTime dueDate,
  }) async {
    try {
      final docRef = await _firestore.collection('assignments').add({
        'name': name,
        'dueDate': Timestamp.fromDate(dueDate),
      });

      _assignments.add(
        AssignmentModel(
          assignmentId: docRef.id,
          name: name,
          dueDate: dueDate,
        ),
      );
      _assignments.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding assignment: $e');
    }
  }

  Future<void> updateAssignment({
    required String assignmentId,
    required String name,
    required DateTime dueDate,
  }) async {
    try {
      await _firestore.collection('assignments').doc(assignmentId).update({
        'name': name,
        'dueDate': Timestamp.fromDate(dueDate),
      });

      final index = _assignments.indexWhere(
        (assignment) => assignment.assignmentId == assignmentId,
      );

      if (index != -1) {
        _assignments[index] = AssignmentModel(
          assignmentId: assignmentId,
          name: name,
          dueDate: dueDate,
        );
        _assignments.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating assignment: $e');
    }
  }

  Future<void> deleteAssignment(String assignmentId) async {
    try {
      await _firestore.collection('assignments').doc(assignmentId).delete();
      _assignments.removeWhere(
        (assignment) => assignment.assignmentId == assignmentId,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting assignment: $e');
    }
  }
}
