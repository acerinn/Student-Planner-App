import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/notes_provider.dart';
import '../models/note_model.dart';
import '../widgets/animated_background.dart'; // Import the background!

class EditNoteScreen extends StatefulWidget {
  final NoteModel note; 
  const EditNoteScreen({super.key, required this.note});

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  late TextEditingController _subjectController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _subjectController = TextEditingController(text: widget.note.subject);
    _contentController = TextEditingController(text: widget.note.content);
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Wrap the entire screen in the Animated Background
    return AnimatedBackground(
      child: Scaffold(
        // 2. Make the Scaffold and AppBar completely transparent
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Edit Note', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black87), // Ensures the back arrow is dark and visible
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 3. Apply Frosted Glass to the Subject Field
              TextField(
                controller: _subjectController,
                style: const TextStyle(color: Colors.black87), // Dark text for typing
                decoration: InputDecoration(
                  labelText: 'Subject',
                  labelStyle: const TextStyle(color: Colors.black54),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.6), // Translucent white fill
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none, // Removes the harsh black outline
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // 4. Apply Frosted Glass to the Content Field
              Expanded(
                child: TextField(
                  controller: _contentController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: const TextStyle(color: Colors.black87), // Dark text for typing
                  decoration: InputDecoration(
                    labelText: 'Note Content',
                    labelStyle: const TextStyle(color: Colors.black54),
                    alignLabelWithHint: true,
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.6), // Translucent white fill
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none, // Removes the harsh black outline
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // 5. Update the Save Button to match the soft UI
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15), // Rounded corners to match text fields
                    ),
                  ),
                  onPressed: () {
                    if (_subjectController.text.isNotEmpty && _contentController.text.isNotEmpty) {
                      Provider.of<NotesProvider>(context, listen: false).updateNote(
                        widget.note.noteId, 
                        _subjectController.text, 
                        _contentController.text
                      );
                      context.pop(); 
                    }
                  },
                  icon: const Icon(Icons.update, color: Colors.white),
                  label: const Text('Update Note', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}