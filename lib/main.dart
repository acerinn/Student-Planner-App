import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart'; 
import 'models/note_model.dart';
import 'providers/notes_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/assignments_provider.dart';

// --- Screens ---
import 'screens/notes_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/add_note_screen.dart';
import 'screens/edit_note_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/assignments_screen.dart';
// Add your teammate's screens:
import 'screens/login_page.dart';
import 'screens/register_page.dart';

void main() async {
  // 1. Ensure Flutter bindings are ready before initializing Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Firebase connection
  // Note: Once you run 'flutterfire configure', you will pass DefaultFirebaseOptions here.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); 
  // 3. Run the app
  runApp(const StudySyncApp());
}

// 4. Configure Navigation Flow (go_router)
final GoRouter _router = GoRouter(
  // Temporarily set to '/notes' so you can test your specific modules immediately.
  // Once the login screen is ready, change this to '/' or '/login'.
  initialLocation: '/login', 
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/notes',
      builder: (context, state) => const NotesScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>? ?? {};
        return EditProfileScreen(userData: data);
      },
    ),
    GoRoute(
      path: '/add-note',
      builder: (context, state) => const AddNoteScreen(),
    ),
    // Placeholders for your teammates' modules to prevent routing errors
    GoRoute(
      path: '/edit-note',
      builder: (context, state) {
        // Extract the note data being passed through the router
        final note = state.extra as NoteModel; 
        return EditNoteScreen(note: note);
      },
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/assignments',
      builder: (context, state) => const AssignmentsScreen(),
    ),
  ],
);

class StudySyncApp extends StatelessWidget {
  const StudySyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 5. Inject State Management at the root level
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NotesProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => AssignmentsProvider()),
        // Add more providers here as your teammates finish their parts
      ],
      child: MaterialApp.router(
        title: 'StudySync',
        debugShowCheckedModeBanner: false,
        routerConfig: _router, // Hooking up go_router
        
        // 6. Enforce Material Design 3 and Theming
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.blue, // Adjust to match your team's UI mockups
          brightness: Brightness.light,
        ),
        // Fulfilling the "Dark Mode" feature requested in your proposal
        darkTheme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.blue,
          brightness: Brightness.dark,
        ),
        // Automatically switches between light/dark based on the user's phone settings
        themeMode: ThemeMode.system, 
      ),
    );
  }
}
