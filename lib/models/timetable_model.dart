class TimetableCellModel {
  final String name;
  final String venue;

  TimetableCellModel({
    required this.name,
    required this.venue,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'venue': venue,
    };
  }

  factory TimetableCellModel.fromMap(Map<String, dynamic>? map) {
    return TimetableCellModel(
      name: (map?['name'] ?? '').toString(),
      venue: (map?['venue'] ?? '').toString(),
    );
  }
}

class TimetableSlotDefinition {
  final String key;
  final String label;

  const TimetableSlotDefinition({
    required this.key,
    required this.label,
  });
}

const List<String> timetableDays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
];

const List<TimetableSlotDefinition> timetableSlots = [
  TimetableSlotDefinition(key: '08:30-10:00', label: '8:30 - 10:00'),
  TimetableSlotDefinition(key: '10:00-11:30', label: '10:00 - 11:30'),
  TimetableSlotDefinition(key: '11:30-13:00', label: '11:30 - 1:00'),
  TimetableSlotDefinition(key: '14:00-15:30', label: '2:00 - 3:30'),
  TimetableSlotDefinition(key: '15:30-17:00', label: '3:30 - 5:00'),
  TimetableSlotDefinition(key: '17:00-19:00', label: '5:00 - 7:00'),
];

class TimetableModel {
  final String timetableId;
  final String title;
  final Map<String, Map<String, TimetableCellModel>> schedule;

  TimetableModel({
    required this.timetableId,
    required this.title,
    required this.schedule,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'schedule': schedule.map((day, slots) {
        return MapEntry(
          day,
          slots.map((slotKey, cell) => MapEntry(slotKey, cell.toMap())),
        );
      }),
    };
  }

  factory TimetableModel.fromMap(Map<String, dynamic> map, String documentId) {
    final rawSchedule = map['schedule'] as Map<String, dynamic>? ?? {};
    final parsedSchedule = <String, Map<String, TimetableCellModel>>{};

    for (final dayEntry in rawSchedule.entries) {
      final daySlots = dayEntry.value as Map<String, dynamic>? ?? {};
      parsedSchedule[dayEntry.key] = daySlots.map(
        (slotKey, slotValue) => MapEntry(
          slotKey,
          TimetableCellModel.fromMap(slotValue as Map<String, dynamic>?),
        ),
      );
    }

    return TimetableModel(
      timetableId: documentId,
      title: (map['title'] ?? '').toString(),
      schedule: parsedSchedule,
    );
  }

  TimetableCellModel? cellFor(String day, String slotKey) {
    return schedule[day]?[slotKey];
  }
}
