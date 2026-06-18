import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/timetable_model.dart';

class TimetablesProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<TimetableModel> _timetables = [];
  String? _pinnedTimetableId;

  List<TimetableModel> get timetables => List.unmodifiable(_timetables);

  TimetableModel? get pinnedTimetable {
    if (_pinnedTimetableId == null) return null;
    for (final timetable in _timetables) {
      if (timetable.timetableId == _pinnedTimetableId) {
        return timetable;
      }
    }
    return null;
  }

  String? get pinnedTimetableId => _pinnedTimetableId;

  CollectionReference<Map<String, dynamic>>? _timelinesCollection() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('timetables');
  }

  DocumentReference<Map<String, dynamic>>? _settingsDocument() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('planner')
        .doc('settings');
  }

  Future<void> fetchTimetables() async {
    final timetableCollection = _timelinesCollection();
    final settingsDocument = _settingsDocument();

    if (_auth.currentUser == null) {
      _timetables = [];
      _pinnedTimetableId = null;
      notifyListeners();
      return;
    }

    if (timetableCollection == null || settingsDocument == null) return;

    try {
      final snapshot = await timetableCollection.orderBy('title').get();
      _timetables = snapshot.docs
          .map((doc) => TimetableModel.fromMap(doc.data(), doc.id))
          .toList();

      final settingsSnapshot = await settingsDocument.get();
      _pinnedTimetableId = settingsSnapshot.data()?['pinnedTimetableId'] as String?;

      if (_pinnedTimetableId != null &&
          !_timetables.any((timetable) => timetable.timetableId == _pinnedTimetableId)) {
        _pinnedTimetableId = null;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching timetables: $e');
    }
  }

  Future<String?> saveTimetable({
    String? timetableId,
    required String title,
    required Map<String, Map<String, TimetableCellModel>> schedule,
  }) async {
    final timetableCollection = _timelinesCollection();
    if (timetableCollection == null) return null;

    final payload = {
      'title': title,
      'schedule': schedule.map((day, slots) {
        return MapEntry(
          day,
          slots.map((slotKey, cell) => MapEntry(slotKey, cell.toMap())),
        );
      }),
    };

    try {
      if (timetableId == null) {
        final docRef = await timetableCollection.add(payload);
        _timetables.add(
          TimetableModel(
            timetableId: docRef.id,
            title: title,
            schedule: schedule,
          ),
        );
        _timetables.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        notifyListeners();
        return docRef.id;
      }

      await timetableCollection.doc(timetableId).set(payload);

      final index = _timetables.indexWhere((timetable) => timetable.timetableId == timetableId);
      if (index != -1) {
        _timetables[index] = TimetableModel(
          timetableId: timetableId,
          title: title,
          schedule: schedule,
        );
        _timetables.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        notifyListeners();
      }

      return timetableId;
    } catch (e) {
      debugPrint('Error saving timetable: $e');
      return null;
    }
  }

  Future<void> deleteTimetable(String timetableId) async {
    final timetableCollection = _timelinesCollection();
    if (timetableCollection == null) return;

    try {
      await timetableCollection.doc(timetableId).delete();
      _timetables.removeWhere((timetable) => timetable.timetableId == timetableId);

      if (_pinnedTimetableId == timetableId) {
        _pinnedTimetableId = null;
        await pinTimetable(null);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting timetable: $e');
    }
  }

  Future<void> pinTimetable(String? timetableId) async {
    final settingsDocument = _settingsDocument();
    if (settingsDocument == null) return;

    try {
      await settingsDocument.set({
        'pinnedTimetableId': timetableId,
      }, SetOptions(merge: true));
      _pinnedTimetableId = timetableId;
      notifyListeners();
    } catch (e) {
      debugPrint('Error pinning timetable: $e');
    }
  }
}
