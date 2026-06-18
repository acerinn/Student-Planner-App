import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/timetable_model.dart';
import '../providers/timetables_provider.dart';
import '../widgets/animated_background.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TimetablesProvider>().fetchTimetables();
    });
  }

  Future<void> _confirmDelete(TimetableModel timetable) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Timetable'),
          content: Text('Delete "${timetable.title}"?'),
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
      final provider = context.read<TimetablesProvider>();
      await provider.deleteTimetable(timetable.timetableId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Timetable deleted.')),
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
            'Timetable',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Consumer<TimetablesProvider>(
          builder: (context, provider, child) {
            final timetables = provider.timetables;
            final pinnedTimetable = provider.pinnedTimetable;
            final pinnedTimetableId = provider.pinnedTimetableId;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  color: Colors.white.withOpacity(0.6),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pin to Dashboard',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: pinnedTimetableId != null && timetables.any((item) => item.timetableId == pinnedTimetableId)
                              ? pinnedTimetableId
                              : null,
                          decoration: InputDecoration(
                            labelText: timetables.isEmpty ? 'No timetables created yet' : 'Select timetable to pin',
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items: timetables
                              .map(
                                (timetable) => DropdownMenuItem<String>(
                                  value: timetable.timetableId,
                                  child: Text(timetable.title),
                                ),
                              )
                              .toList(),
                          onChanged: timetables.isEmpty
                              ? null
                              : (value) {
                                  provider.pinTimetable(value);
                                },
                        ),
                        const SizedBox(height: 10),
                        Text(
                          pinnedTimetable == null
                              ? 'No timetable is pinned to the dashboard yet.'
                              : 'Pinned: ${pinnedTimetable.title}',
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => context.push('/timetable-editor'),
                    icon: const Icon(Icons.add),
                    label: const Text('Add New Timetable'),
                  ),
                ),
                const SizedBox(height: 16),
                if (timetables.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Text(
                        'No timetable added yet.',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  )
                else
                  ...timetables.map((timetable) {
                    return Card(
                      color: Colors.white.withOpacity(0.6),
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ExpansionTile(
                        title: Text(
                          timetable.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        subtitle: Text(
                          timetable.timetableId == pinnedTimetableId ? 'Pinned to dashboard' : 'Not pinned',
                          style: const TextStyle(color: Colors.black54),
                        ),
                        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        children: [
                          ...timetableDays.map((day) {
                            final daySchedule = timetable.schedule[day] ?? {};
                            final hasAnyEntry = daySchedule.values.any((cell) => cell.name.isNotEmpty || cell.venue.isNotEmpty);

                            if (!hasAnyEntry) {
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(day, style: const TextStyle(fontWeight: FontWeight.w600)),
                                subtitle: const Text('No classes added for this day.'),
                              );
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(day, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
                                  const SizedBox(height: 6),
                                  ...timetableSlots.map((slot) {
                                    final cell = daySchedule[slot.key];
                                    if (cell == null || (cell.name.isEmpty && cell.venue.isEmpty)) {
                                      return const SizedBox.shrink();
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: Text(
                                        '${slot.label}: ${cell.name}${cell.venue.isEmpty ? '' : ' @ ${cell.venue}'}',
                                        style: const TextStyle(color: Colors.black54),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => context.push('/timetable-editor', extra: timetable),
                                  icon: const Icon(Icons.edit),
                                  label: const Text('Edit'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _confirmDelete(timetable),
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  label: const Text('Delete'),
                                  style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            );
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          currentIndex: 0,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.black38,
          onTap: (index) {
            if (index == 0) context.go('/dashboard');
            if (index == 1) context.go('/assignments');
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
