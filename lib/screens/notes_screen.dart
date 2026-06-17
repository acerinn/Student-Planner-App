import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/notes_provider.dart';
import '../widgets/animated_background.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  @override
  void initState() {
    super.initState();
    // This triggers the fetch automatically when the screen is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotesProvider>(context, listen: false).fetchNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        
        appBar: AppBar(
          title: const Text('Study Notes', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black87),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Search feature coming soon!')),
                );
              },
            ),
          ],
        ),
        
        body: Consumer<NotesProvider>(
          builder: (context, notesProvider, child) {
            // Check if notes are empty - you might want to show a loading spinner here if still fetching
            if (notesProvider.notes.isEmpty) {
              return const Center(child: Text('No notes yet. Add one!', style: TextStyle(color: Colors.black54)));
            }
            return ListView.builder(
              itemCount: notesProvider.notes.length,
              itemBuilder: (context, index) {
                final note = notesProvider.notes[index];
                
                return Card(
                  color: Colors.white.withOpacity(0.6),
                  elevation: 0,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    onTap: () {
                      context.push('/edit-note', extra: note);
                    },
                    title: Text(note.subject, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                    subtitle: Text(note.content, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black54)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () {
                        notesProvider.deleteNote(note.noteId);
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
        
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            context.push('/add-note');
          },
          backgroundColor: Colors.blueAccent,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          currentIndex: 2, 
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.black38,
          onTap: (index) {
            if (index == 0) context.go('/dashboard');
            if (index == 1) context.go('/tasks');
            if (index == 2) return;
            if (index == 3) context.go('/profile');
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.assignment_turned_in), label: 'Tasks'),
            BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Notes'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}