import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/assignment_model.dart';

class AssignmentsProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<AssignmentModel> _assignments = [];

  List<AssignmentModel> get assignments => List.unmodifiable(_assignments);

  CollectionReference<Map<String, dynamic>>? _assignmentsCollection() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('assignments');
  }

  Future<void> fetchAssignments() async {
    final assignmentsCollection = _assignmentsCollection();
    if (assignmentsCollection == null) {
      _assignments = [];
      notifyListeners();
      return;
    }

    try {
      final snapshot = await assignmentsCollection.orderBy('dueDate').get();

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
    final assignmentsCollection = _assignmentsCollection();
    if (assignmentsCollection == null) return;

    try {
      final docRef = await assignmentsCollection.add({
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
    final assignmentsCollection = _assignmentsCollection();
    if (assignmentsCollection == null) return;

    try {
      await assignmentsCollection.doc(assignmentId).update({
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
    final assignmentsCollection = _assignmentsCollection();
    if (assignmentsCollection == null) return;

    try {
      await assignmentsCollection.doc(assignmentId).delete();
      _assignments.removeWhere(
        (assignment) => assignment.assignmentId == assignmentId,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting assignment: $e');
    }
  }
}
