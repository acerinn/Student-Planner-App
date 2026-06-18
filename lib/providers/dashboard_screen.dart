import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/dashboard_provider.dart';
import '../providers/notes_provider.dart';
import '../widgets/animated_background.dart'; // 1. IMPORT THE CUSTOM BACKGROUND!

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardWatch = context.watch<DashboardProvider>();
    final notesWatch = context.watch<NotesProvider>(); 

    // 2. WRAP THE ENTIRE SCREEN IN YOUR TEAMMATE'S ANIMATED BACKGROUND
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent, // Let the animation show through
        
        appBar: AppBar(
          title: const Text('StudySync Dashboard', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
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
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              const Text(
                'Track your assignments and keep up with academic goals.',
                style: TextStyle(color: Colors.black54), 
              ),
              const SizedBox(height: 20),

              Card(
                elevation: 0,
                color: Colors.white.withOpacity(0.6), // Matched to NotesScreen card opacity
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Academic Progress Tracker',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Productivity Metric: ${(dashboardWatch.productivityProgress * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(color: Colors.black87),
                          ),
                          Text(
                            '${dashboardWatch.completedTasks} Tasks Done',
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: dashboardWatch.productivityProgress,
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

              Text('Quick Overview', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black87)),
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
                    title: 'Pending Tasks',
                    value: '${dashboardWatch.pendingTasks}',
                    icon: Icons.assignment_late,
                    color: Colors.orange,
                  ),
                  _buildSummaryCard(
                    context,
                    title: 'Total Notes Saved',
                    value: '${notesWatch.notes.length}', // REAL DATA FROM NOTES!
                    icon: Icons.book,
                    color: Colors.blueAccent, 
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Text('Core Application Modules', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black87)),
              const SizedBox(height: 12),
              
              Card(
                elevation: 0,
                color: Colors.white.withOpacity(0.6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  leading: const Icon(Icons.assignment, color: Colors.blueAccent),
                  title: const Text('Assignment Task Tracker', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                  subtitle: const Text('Manage workloads and deadlines', style: TextStyle(color: Colors.black54)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.black54),
                  onTap: () => context.push('/tasks'),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                color: Colors.white.withOpacity(0.6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  leading: const Icon(Icons.note_alt, color: Colors.blueAccent),
                  title: const Text('Notes Repository', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                  subtitle: const Text('Review your subject study notes', style: TextStyle(color: Colors.black54)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.black54),
                  onTap: () => context.push('/notes'),
                ),
              ),
            ],
          ),
        ),
        
        // 3. SYNCED NAVIGATION BAR STYLE
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          currentIndex: 0, // Dashboard is index 0
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.black38,
          onTap: (index) {
            if (index == 0) return; // Already on dashboard
            if (index == 1) context.go('/tasks');
            if (index == 2) context.go('/notes');
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

  Widget _buildSummaryCard(BuildContext context, {
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
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87), overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}