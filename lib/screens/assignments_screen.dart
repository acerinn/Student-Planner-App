import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/assignment_model.dart';
import '../providers/assignments_provider.dart';
import '../widgets/animated_background.dart';

class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AssignmentsProvider>().fetchAssignments();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDateAndSave({AssignmentModel? assignment}) async {
    final nameController = TextEditingController(text: assignment?.name ?? '');
    DateTime selectedDueDate = assignment?.dueDate ?? DateTime.now().add(const Duration(days: 1));

    final didSave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(assignment == null ? 'Add Assignment' : 'Edit Assignment'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Assignment Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Due: ${DateFormat('dd MMM yyyy').format(selectedDueDate)}',
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDueDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            setDialogState(() {
                              selectedDueDate = pickedDate;
                            });
                          }
                        },
                        icon: const Icon(Icons.calendar_today),
                        label: const Text('Select Date'),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(content: Text('Assignment name cannot be empty.')),
                      );
                      return;
                    }

                    final assignmentsProvider = this.context.read<AssignmentsProvider>();
                    if (assignment == null) {
                      await assignmentsProvider.addAssignment(
                        name: name,
                        dueDate: selectedDueDate,
                      );
                    } else {
                      await assignmentsProvider.updateAssignment(
                        assignmentId: assignment.assignmentId,
                        name: name,
                        dueDate: selectedDueDate,
                      );
                    }

                    if (!dialogContext.mounted) return;
                    Navigator.of(dialogContext).pop(true);
                  },
                  child: Text(assignment == null ? 'Add' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();

    if (didSave == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            assignment == null
                ? 'Assignment added successfully.'
                : 'Assignment updated successfully.',
          ),
        ),
      );
    }
  }

  Future<void> _confirmDelete(AssignmentModel assignment) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Assignment'),
          content: Text('Delete "${assignment.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      if (!mounted) return;
      final assignmentsProvider = context.read<AssignmentsProvider>();
      await assignmentsProvider.deleteAssignment(assignment.assignmentId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assignment deleted.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Assignments',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Search Assignment by Name',
                  labelStyle: const TextStyle(color: Colors.black54),
                  prefixIcon: const Icon(Icons.search, color: Colors.black54),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.trim().toLowerCase();
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _pickDueDateAndSave(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Assignment'),
                ),
              ),
            ),
            Expanded(
              child: Consumer<AssignmentsProvider>(
                builder: (context, assignmentsProvider, child) {
                  final filteredAssignments = assignmentsProvider.assignments.where((assignment) {
                    if (_searchQuery.isEmpty) return true;
                    return assignment.name.toLowerCase().contains(_searchQuery);
                  }).toList();

                  if (filteredAssignments.isEmpty) {
                    return Center(
                      child: Text(
                        _searchQuery.isEmpty
                            ? 'No assignments yet. Add your first assignment.'
                            : 'No assignment found for your search.',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredAssignments.length,
                    itemBuilder: (context, index) {
                      final assignment = filteredAssignments[index];
                      
                      // Assumes you have an isCompleted boolean in your model.
                      // Defaults to false if it's null.
                      final bool isCompleted = assignment.status ?? false;

                      return Card(
                        color: Colors.white.withOpacity(0.6),
                        elevation: 0,
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: ListTile(
                          // NEW: The Completion Toggle Button on the left
                          leading: IconButton(
                            icon: Icon(
                              isCompleted ? Icons.check_circle : Icons.circle_outlined,
                              color: isCompleted ? Colors.green : Colors.blueAccent,
                              size: 28,
                            ),
                            onPressed: () async {
                              await assignmentsProvider.toggleAssignmentStatus(
                                assignment.assignmentId, 
                                !isCompleted,
                              );
                            },
                          ),
                          title: Text(
                            assignment.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              // NEW: Changes color and strikes through text if done
                              color: isCompleted ? Colors.grey : Colors.black87,
                              decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                            ),
                          ),
                          subtitle: Text(
                            'Due date: ${DateFormat('dd MMM yyyy').format(assignment.dueDate)}',
                            style: TextStyle(color: isCompleted ? Colors.grey : Colors.black54),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: isCompleted ? Colors.grey : Colors.blueAccent),
                                onPressed: () => _pickDueDateAndSave(assignment: assignment),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () => _confirmDelete(assignment),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          currentIndex: 1,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.black38,
          onTap: (index) {
            if (index == 0) context.go('/dashboard');
            if (index == 1) return;
            if (index == 2) context.go('/notes');
            if (index == 3) context.go('/profile');
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
}
