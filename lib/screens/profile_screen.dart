import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../widgets/animated_background.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // --- 1. UPLOAD PHOTO FUNCTION ---
  Future<void> _uploadPhoto(BuildContext context, String uid) async {
    final picker = ImagePicker();
    
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery, 
      imageQuality: 20, 
      maxWidth: 400,    
    );

    if (pickedFile != null) {
      try {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saving photo to database...')),
        );

        final bytes = await pickedFile.readAsBytes();
        final base64String = base64Encode(bytes);

        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'photoBase64': base64String, 
        }, SetOptions(merge: true));

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile photo updated!')),
          );
        }
      } catch (e) {
        print("Upload error: $e");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed. Image might still be too large.')),
          );
        }
      }
    }
  }

  // --- 2. NEW: REMOVE PHOTO FUNCTION ---
  Future<void> _removePhoto(BuildContext context, String uid) async {
    try {
      // Use FieldValue.delete() to completely erase this specific field from Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'photoBase64': FieldValue.delete(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile photo removed!')),
        );
      }
    } catch (e) {
      print("Remove error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to remove photo.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return AnimatedBackground(
      // Make the Scaffold completely transparent!
      child: Scaffold(
        backgroundColor: Colors.transparent, 
        
        appBar: AppBar(
          title: const Text('My Profile', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
          // Make the AppBar transparent too so it blends perfectly
          backgroundColor: Colors.transparent, 
          elevation: 0, 
        ),
      body: user == null
          ? _buildProfileContent(
              context,
              userData: {
                'username': 'Test Student',
                'email': 'student@studysync.edu.my',
                'matricNo': '2012345',
                'gender': 'Female',
              },
              isLoggedIn: false,
              uid: '',
            )
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
                userData['email'] = userData['email'] ?? user.email;

                return _buildProfileContent(context, userData: userData, isLoggedIn: true, uid: user.uid);
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        
        type: BottomNavigationBarType.fixed,
        currentIndex: 3,
    
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.black38, // Darkened so they show up on the gradient
        onTap: (index) {
          if (index == 0) context.go('/dashboard');
          if (index == 1) context.go('/assignments');
          if (index == 2) context.go('/notes');
          if (index == 3) return;
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_turned_in), label: 'Assignments'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Notes'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    ),
    );
  }

  Widget _buildProfileContent(BuildContext context, {required Map<String, dynamic> userData, required bool isLoggedIn, required String uid}) {
    final username = userData['username'] ?? 'Student Name';
    final email = userData['email'] ?? 'No email linked';
    final matricNo = userData['matricNo'] ?? 'Matric No. Not Set';
    final gender = userData['gender'] ?? 'Not Set';
    
    final photoBase64 = userData['photoBase64']; 

    String birthdate = 'Not Set';
    if (userData['birthdate'] != null) {
      DateTime dt = (userData['birthdate'] as Timestamp).toDate();
      birthdate = DateFormat('dd MMM yyyy').format(dt);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              // Avatar Image
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.blueAccent,
                backgroundImage: photoBase64 != null ? MemoryImage(base64Decode(photoBase64)) : null,
                child: photoBase64 == null ? const Icon(Icons.person, size: 60, color: Colors.white) : null,
              ),
              
              // Upload Button (Bottom Right)
              Container(
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.blue),
                  onPressed: () {
                    if (isLoggedIn) {
                      _uploadPhoto(context, uid);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cannot upload in Dummy Mode.')),
                      );
                    }
                  },
                ),
              ),

              // Delete Button (Top Right) - Only shows if a photo exists
              if (photoBase64 != null)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)]
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                      constraints: const BoxConstraints(), // Keeps the button tiny
                      padding: const EdgeInsets.all(6),
                      onPressed: () {
                        if (isLoggedIn) {
                          _removePhoto(context, uid);
                        }
                      },
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          // UPDATED TEXT COLORS HERE
          Text(username, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87)),
          Text(email, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black54)),
          
          const SizedBox(height: 30),
          _buildInfoTile(Icons.badge, 'Matric No', matricNo),
          _buildInfoTile(Icons.person_outline, 'Gender', gender),
          _buildInfoTile(Icons.cake, 'Birthdate', birthdate),
          const SizedBox(height: 30),
          
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () {
                context.push('/edit-profile', extra: userData);
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.black87), // Ensure button text is readable
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton.icon(
              onPressed: () async {
                if (isLoggedIn) {
                  await FirebaseAuth.instance.signOut();
                }
                if (context.mounted) context.go('/login');
              },
              icon: const Icon(Icons.logout),
              label: const Text('Log Out'),
              style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  // UPDATED GLASSMORPHISM TILE HERE
  Widget _buildInfoTile(IconData icon, String title, String value) {
    return Card(
      color: Colors.white.withOpacity(0.6), // Frosted glass effect
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87)),
      ),
    );
  }
}