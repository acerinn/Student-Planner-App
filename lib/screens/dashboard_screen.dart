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
  // Used to track transitions to 0 tasks for the popup
  int? _previousPendingCount;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AssignmentsProvider>().fetchAssignments();
      context.read<NotesProvider>().fetchNotes();
    });
  }

  // The Duolingo-style congratulations popup
  void _showCongratsPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.95),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Column(
            children: [
              Icon(Icons.star, color: Colors.amber, size: 80),
              SizedBox(height: 12),
              Text(
                'Congratulations!',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
          content: const Text(
            'You have completed all your pending tasks. Enjoy your free time!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
          actions: [
            Center(
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(backgroundColor: Colors.blueAccent),
                child: const Text('Awesome!'),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final assignmentsWatch = context.watch<AssignmentsProvider>();
    final timetablesWatch = context.watch<TimetablesProvider>();
    final notesWatch = context.watch<NotesProvider>();

    final allAssignments = assignmentsWatch.assignments;
    final totalAssignments = allAssignments.length;

    // 1. Calculate Completed based on the NEW status boolean
    final completedCount = allAssignments.where((a) => a.status == true).length;

    // 2. Calculate Pending (unchecked) and sort them by due date
    final pendingAssignments = allAssignments.where((a) => a.status != true).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    final pendingCount = pendingAssignments.length;

    // Trigger Popup if tasks were > 0 and just hit 0 (ignoring empty databases)
    if (_previousPendingCount != null && _previousPendingCount! > 0 && pendingCount == 0 && totalAssignments > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCongratsPopup();
      });
    }
    _previousPendingCount = pendingCount;

    // Calculate how many stars to fill (0 to 5)
    final int filledStars = totalAssignments == 0 
        ? 0 
        : ((completedCount / totalAssignments) * 5).round().clamp(0, 5);

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
              
              // 1. ASSIGNMENT OVERVIEW (5-Star Tracker)
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
                        'Assignment Progress',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$pendingCount Tasks Pending',
                            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '$completedCount / $totalAssignments Done',
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // 5-Star Visualizer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(5, (index) {
                          return Icon(
                            index < filledStars ? Icons.star : Icons.star_border,
                            color: index < filledStars ? Colors.amber : Colors.black26,
                            size: 40,
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 2. UPCOMING ASSIGNMENTS (Now only shows Pending tasks!)
              Text(
                'Upcoming Assignments',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black87),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 0,
                color: Colors.white.withOpacity(0.6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: pendingAssignments.isEmpty
                    ? const ListTile(
                        title: Text(
                          'No pending assignments!',
                          style: TextStyle(color: Colors.black54),
                        ),
                        subtitle: Text(
                          'You are all caught up.',
                          style: TextStyle(color: Colors.black54),
                        ),
                      )
                    : Column(
                        children: pendingAssignments.take(3).map((assignment) {
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
                            onTap: () => context.push('/assignments'),
                          );
                        }).toList(),
                      ),
              ),
              const SizedBox(height: 24),

              // 3. TIMETABLE
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

              // 4. QUICK OVERVIEW
              Text(
                'Quick Overview',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black87),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitlesOverviewCard(
                    context: context,
                    title: 'Pending Tasks',
                    icon: Icons.assignment,
                    color: Colors.orange,
                    items: pendingAssignments.map((e) => e.name).toList(),
                    onTap: () => context.push('/assignments'),
                  ),
                  const SizedBox(width: 12),
                  _buildTitlesOverviewCard(
                    context: context,
                    title: 'Notes',
                    icon: Icons.book,
                    color: Colors.blueAccent,
                    items: notesWatch.notes.map((e) => e.subject).toList(),
                    onTap: () => context.push('/notes'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 5. CORE APPLICATION MODULES
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

  Widget _buildTitlesOverviewCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required List<String> items,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: Colors.white.withOpacity(0.6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (items.isEmpty)
                  const Text('Nothing here yet.', style: TextStyle(color: Colors.black54, fontSize: 12))
                else
                  ...items.take(3).map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.circle, size: 6, color: Colors.black54),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                item,
                                style: const TextStyle(color: Colors.black87, fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      )),
              ],
            ),
          ),
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
