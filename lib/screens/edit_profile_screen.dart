import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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
  String? _selectedGender;
  DateTime? _selectedDate;

  final List<String> _genderOptions = ['Male', 'Female'];

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.userData['username'] ?? '');
    _matricNoController = TextEditingController(text: widget.userData['matricNo'] ?? '');
    _selectedGender = _genderOptions.contains(widget.userData['gender']) ? widget.userData['gender'] : null;
    
    if (widget.userData['birthdate'] != null) {
      var birthdate = widget.userData['birthdate'];
      _selectedDate = (birthdate is Timestamp) ? birthdate.toDate() : (birthdate as DateTime);
    }
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2004),
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _updateProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'username': _usernameController.text,
        'matricNo': _matricNoController.text,
        'gender': _selectedGender,
        'birthdate': _selectedDate != null ? Timestamp.fromDate(_selectedDate!) : null,
      }, SetOptions(merge: true));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved successfully!')),
        );
        context.pop();
      }
    } catch (e) {
      debugPrint("Firestore Error: $e");
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error saving profile.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Edit Profile', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              TextField(controller: _usernameController, style: const TextStyle(color: Colors.black87), decoration: _buildInputDecoration('Username')),
              const SizedBox(height: 16),
              TextField(controller: _matricNoController, style: const TextStyle(color: Colors.black87), decoration: _buildInputDecoration('Matric No')),
              const SizedBox(height: 16),
              
              // Gender Dropdown
              DropdownButtonFormField<String>(
                value: _selectedGender,
                items: _genderOptions.map((gender) => DropdownMenuItem(value: gender, child: Text(gender, style: const TextStyle(color: Colors.black87)))).toList(),
                onChanged: (val) => setState(() => _selectedGender = val),
                decoration: _buildInputDecoration('Gender'),
                dropdownColor: Colors.white,
              ),
              const SizedBox(height: 16),
              
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: _buildInputDecoration('Birthdate'),
                  child: Text(_selectedDate == null ? 'Select Date' : DateFormat('dd MMM yyyy').format(_selectedDate!), style: const TextStyle(color: Colors.black87)),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity, height: 50,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: Colors.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  onPressed: _updateProfile,
                  child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black54),
      filled: true,
      fillColor: Colors.white.withOpacity(0.7),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
    );
  }
}