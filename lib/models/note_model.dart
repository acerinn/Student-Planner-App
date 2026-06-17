class NoteModel {
  String noteId;
  String subject;
  String content;

  NoteModel({
    required this.noteId,
    required this.subject,
    required this.content,
  });

  // Convert a Note object into a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'noteId': noteId,
      'subject': subject,
      'content': content,
    };
  }

  // Create a Note object from a Firestore document
  factory NoteModel.fromMap(Map<String, dynamic> map, String documentId) {
    return NoteModel(
      noteId: documentId,
      subject: map['subject'] ?? '',
      content: map['content'] ?? '',
    );
  }
}