import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/timetable_model.dart';
import '../providers/assignments_provider.dart';
import '../providers/timetables_provider.dart';
import '../providers/notes_provider.dart';
import '../widgets/animated_background.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AssignmentsProvider>().fetchAssignments();
      context.read<NotesProvider>().fetchNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final assignmentsWatch = context.watch<AssignmentsProvider>();
    final timetablesWatch = context.watch<TimetablesProvider>();
    final notesWatch = context.watch<NotesProvider>();

    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final upcomingAssignments = assignmentsWatch.assignments
        .where((assignment) => !assignment.dueDate.isBefore(startOfToday))
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    final dueSoonCount = upcomingAssignments
        .where((assignment) => assignment.dueDate.difference(startOfToday).inDays <= 7)
        .length;

    final totalAssignments = assignmentsWatch.assignments.length;
    final assignmentsDueSoonProgress = totalAssignments == 0
        ? 0.0
        : (dueSoonCount / totalAssignments).clamp(0.0, 1.0);

    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'StudySync Dashboard',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome Back!',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              const Text(
                'Track your assignments and keep up with academic goals.',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 0,
                color: Colors.white.withOpacity(0.6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Assignment Overview',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$dueSoonCount Due In 7 Days',
                            style: const TextStyle(color: Colors.black87),
                          ),
                          Text(
                            '$totalAssignments Total',
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: assignmentsDueSoonProgress,
                        backgroundColor: Colors.white54,
                        color: Colors.blueAccent,
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Timetable',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black87),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 0,
                color: Colors.white.withOpacity(0.6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        timetablesWatch.pinnedTimetable?.title ?? 'No timetable pinned yet.',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        timetablesWatch.pinnedTimetable == null
                            ? 'Create a timetable and pin it from the timetable page.'
                            : 'Pinned timetable for dashboard display',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 12),
                      if (timetablesWatch.pinnedTimetable != null)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Table(
                            border: TableBorder.all(color: Colors.black12),
                            defaultColumnWidth: const IntrinsicColumnWidth(),
                            children: [
                              TableRow(
                                decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.08)),
                                children: [
                                  _buildTableHeaderCell('Day'),
                                  ...timetableSlots.map((slot) => _buildTableHeaderCell(slot.label)),
                                ],
                              ),
                              ...timetableDays.map((day) {
                                final daySchedule = timetablesWatch.pinnedTimetable!.schedule[day] ?? {};
                                return TableRow(
                                  children: [
                                    _buildTableBodyCell(day, isHeader: true),
                                    ...timetableSlots.map((slot) {
                                      final cell = daySchedule[slot.key];
                                      final text = cell == null || (cell.name.isEmpty && cell.venue.isEmpty)
                                          ? '-'
                                          : cell.venue.isEmpty
                                              ? cell.name
                                              : '${cell.name}\n${cell.venue}';
                                      return _buildTableBodyCell(text);
                                    }),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => context.push('/timetable'),
                          icon: const Icon(Icons.edit_calendar),
                          label: const Text('Edit Timetable'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Quick Overview',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black87),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  _buildSummaryCard(
                    context,
                    title: 'Total Assignments',
                    value: '$totalAssignments',
                    icon: Icons.assignment,
                    color: Colors.orange,
                  ),
                  _buildSummaryCard(
                    context,
                    title: 'Total Notes Saved',
                    value: '${notesWatch.notes.length}',
                    icon: Icons.book,
                    color: Colors.blueAccent,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Core Application Modules',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black87),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 0,
                color: Colors.white.withOpacity(0.6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  leading: const Icon(Icons.assignment, color: Colors.blueAccent),
                  title: const Text(
                    'Assignment Tracker',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  subtitle: const Text(
                    'Manage assignment names and due dates',
                    style: TextStyle(color: Colors.black54),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.black54),
                  onTap: () => context.push('/assignments'),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                color: Colors.white.withOpacity(0.6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  leading: const Icon(Icons.note_alt, color: Colors.blueAccent),
                  title: const Text(
                    'Notes Repository',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  subtitle: const Text(
                    'Review your subject study notes',
                    style: TextStyle(color: Colors.black54),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.black54),
                  onTap: () => context.push('/notes'),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Upcoming Assignments',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black87),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 0,
                color: Colors.white.withOpacity(0.6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: upcomingAssignments.isEmpty
                    ? const ListTile(
                        title: Text(
                          'No upcoming assignments',
                          style: TextStyle(color: Colors.black54),
                        ),
                        subtitle: Text(
                          'Add assignments to see them here.',
                          style: TextStyle(color: Colors.black54),
                        ),
                      )
                    : Column(
                        children: upcomingAssignments.take(3).map((assignment) {
                          return ListTile(
                            leading: const Icon(Icons.event_note, color: Colors.blueAccent),
                            title: Text(
                              assignment.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            subtitle: Text(
                              'Due: ${DateFormat('dd MMM yyyy').format(assignment.dueDate)}',
                              style: const TextStyle(color: Colors.black54),
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          currentIndex: 0,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.black38,
          onTap: (index) {
            if (index == 0) return;
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

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white.withOpacity(0.6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 28),
            Text(title, style: const TextStyle(color: Colors.black54, fontSize: 12)),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildTableBodyCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: isHeader ? Colors.black87 : Colors.black54,
          fontSize: 12,
        ),
      ),
    );
  }
}
