import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note_model.dart';

class NotesProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<NoteModel> _notes = [];
  String _searchQuery = "";

  List<NoteModel> get notes {
    if (_searchQuery.isEmpty) return _notes;
    return _notes.where((note) =>
        note.subject.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        note.content.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Fetch notes from Firestore
  Future<void> fetchNotes() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('notes').get();
      _notes = snapshot.docs.map((doc) => NoteModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
      notifyListeners();
    } catch (e) {
      print("Error fetching notes: $e");
    }
  }

  // Add a new note
 // Update your addNote in NotesProvider
  Future<void> addNote(String subject, String content) async {
    try {
      final docRef = await _firestore.collection('notes').add({
        'subject': subject,
        'content': content,
      });
      
      // Create the object
      NoteModel newNote = NoteModel(noteId: docRef.id, subject: subject, content: content);
      
      // Update the local list
      _notes.add(newNote);
      
      // Force notify
      notifyListeners(); 
    } catch (e) {
      print("Error adding note: $e");
    }
  }

  // Delete a note
  Future<void> deleteNote(String noteId) async {
    try {
      await _firestore.collection('notes').doc(noteId).delete();
      _notes.removeWhere((note) => note.noteId == noteId);
      notifyListeners();
    } catch (e) {
      print("Error deleting note: $e");
    }
  }
  // Update an existing note
  Future<void> updateNote(String noteId, String newSubject, String newContent) async {
    try {
      // 1. Update the note in Firebase Cloud Firestore
      await _firestore.collection('notes').doc(noteId).update({
        'subject': newSubject,
        'content': newContent,
      });
      
      // 2. Update the note in our local screen state
      int index = _notes.indexWhere((note) => note.noteId == noteId);
      if (index != -1) {
        _notes[index].subject = newSubject;
        _notes[index].content = newContent;
        notifyListeners(); // Refresh the screen
      }
    } catch (e) {
      print("Error updating note: $e");
    }
  }
}
