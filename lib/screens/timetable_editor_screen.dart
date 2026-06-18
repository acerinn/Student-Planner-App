import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/timetable_model.dart';
import '../providers/timetables_provider.dart';
import '../widgets/animated_background.dart';

class TimetableEditorScreen extends StatefulWidget {
  final TimetableModel? timetable;

  const TimetableEditorScreen({super.key, this.timetable});

  @override
  State<TimetableEditorScreen> createState() => _TimetableEditorScreenState();
}

class _TimetableEditorScreenState extends State<TimetableEditorScreen> {
  late final TextEditingController _titleController;
  late final Map<String, Map<String, TextEditingController>> _nameControllers;
  late final Map<String, Map<String, TextEditingController>> _venueControllers;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.timetable?.title ?? '');
    _nameControllers = {};
    _venueControllers = {};

    for (final day in timetableDays) {
      _nameControllers[day] = {};
      _venueControllers[day] = {};

      for (final slot in timetableSlots) {
        final cell = widget.timetable?.cellFor(day, slot.key);
        _nameControllers[day]![slot.key] = TextEditingController(text: cell?.name ?? '');
        _venueControllers[day]![slot.key] = TextEditingController(text: cell?.venue ?? '');
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (final dayControllers in _nameControllers.values) {
      for (final controller in dayControllers.values) {
        controller.dispose();
      }
    }
    for (final dayControllers in _venueControllers.values) {
      for (final controller in dayControllers.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  Future<void> _saveTimetable() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Timetable title is required.')),
      );
      return;
    }

    final schedule = <String, Map<String, TimetableCellModel>>{};
    for (final day in timetableDays) {
      schedule[day] = {};
      for (final slot in timetableSlots) {
        schedule[day]![slot.key] = TimetableCellModel(
          name: _nameControllers[day]![slot.key]!.text.trim(),
          venue: _venueControllers[day]![slot.key]!.text.trim(),
        );
      }
    }

    final provider = context.read<TimetablesProvider>();
    final savedId = await provider.saveTimetable(
      timetableId: widget.timetable?.timetableId,
      title: title,
      schedule: schedule,
    );

    if (!mounted) return;

    if (savedId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.timetable == null ? 'Timetable created.' : 'Timetable updated.',
          ),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.timetable != null;

    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            isEditing ? 'Edit Timetable' : 'Add Timetable',
            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                style: const TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  labelText: 'Timetable Title',
                  labelStyle: const TextStyle(color: Colors.black54),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Add subject name and venue for each time slot',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 16),
              ...timetableDays.map((day) {
                return Card(
                  color: Colors.white.withOpacity(0.6),
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ExpansionTile(
                    initiallyExpanded: day == 'Monday',
                    title: Text(
                      day,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: [
                      ...timetableSlots.map((slot) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                slot.label,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _nameControllers[day]![slot.key],
                                style: const TextStyle(color: Colors.black87),
                                decoration: InputDecoration(
                                  labelText: 'Name',
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.8),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _venueControllers[day]![slot.key],
                                style: const TextStyle(color: Colors.black87),
                                decoration: InputDecoration(
                                  labelText: 'Venue',
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.8),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: _saveTimetable,
                  icon: const Icon(Icons.save),
                  label: Text(isEditing ? 'Update Timetable' : 'Save Timetable'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
