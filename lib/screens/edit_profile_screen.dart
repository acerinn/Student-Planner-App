import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../widgets/animated_background.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const EditProfileScreen({super.key, required this.userData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _matricNoController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.userData['username']);
    _matricNoController = TextEditingController(text: widget.userData['matricNo']);
  }

  @override
  Widget build(BuildContext context) {
    // 1. Wrap the entire screen in the Animated Background
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent, // Make Scaffold transparent
        appBar: AppBar(
          title: const Text('Edit Profile', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // 2. Frosted Glass Input Fields
              TextField(
                controller: _usernameController,
                decoration: _buildInputDecoration('Username'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _matricNoController,
                decoration: _buildInputDecoration('Matric No'),
              ),
              const SizedBox(height: 30),
              
              // 3. Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: () async {
                    // Logic to update Firestore would go here
                    context.pop();
                  },
                  child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to keep your glass inputs consistent
  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black54),
      filled: true,
      fillColor: Colors.white.withOpacity(0.6), // Frosted glass fill
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    );
  }
}