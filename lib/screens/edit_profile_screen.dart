import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // Helps format the date

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> currentData;
  const EditProfileScreen({super.key, required this.currentData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _matricController;
  String? _selectedGender;
  DateTime? _selectedDate;

@override
  void initState() {
    super.initState();
    
    _nameController = TextEditingController(text: widget.currentData['username'] ?? '');
    _matricController = TextEditingController(text: widget.currentData['matricNo'] ?? '');
    
    // SAFETY CHECK: Only set the gender if it exactly matches our dropdown options
    String? incomingGender = widget.currentData['gender'];
    if (incomingGender == 'Male' || incomingGender == 'Female') {
      _selectedGender = incomingGender;
    } else {
      _selectedGender = null; // Leaves the dropdown blank if the data is weird
    }
    
    if (widget.currentData['birthdate'] != null) {
      _selectedDate = (widget.currentData['birthdate'] as Timestamp).toDate();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _matricController.dispose();
    super.dispose();
  }

  // Function to show the calendar picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name Field
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            
            // Matric Number Field
            TextField(
              controller: _matricController,
              decoration: const InputDecoration(labelText: 'Matric Number', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),

            // Gender Dropdown
            DropdownButtonFormField<String>(
              initialValue: _selectedGender,
              decoration: const InputDecoration(labelText: 'Gender', border: OutlineInputBorder()),
              items: ['Male', 'Female'].map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedGender = newValue;
                });
              },
            ),
            const SizedBox(height: 16),

            // Birthdate Picker
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Birthdate', border: OutlineInputBorder()),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_selectedDate == null ? 'Select Date' : DateFormat('dd MMM yyyy').format(_selectedDate!)),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                onPressed: () async {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    // Update Firestore (SetOptions merge ensures we don't overwrite the email)
                    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
                      'username': _nameController.text,
                      'matricNo': _matricController.text,
                      'gender': _selectedGender,
                      'birthdate': _selectedDate != null ? Timestamp.fromDate(_selectedDate!) : null,
                    }, SetOptions(merge: true));
                    
                    if (context.mounted) context.pop(); // Go back
                  }
                },
                icon: const Icon(Icons.save),
                label: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}