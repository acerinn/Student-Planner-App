import 'package:flutter/material.dart';

class DashboardProvider with ChangeNotifier {
  int _pendingTasks = 0;
  int _completedTasks = 0;

  int get pendingTasks => _pendingTasks;
  int get completedTasks => _completedTasks;

  double get productivityProgress {
    final total = _pendingTasks + _completedTasks;
    if (total == 0) return 0;
    return _completedTasks / total;
  }

  void setTaskStats({required int pendingTasks, required int completedTasks}) {
    _pendingTasks = pendingTasks;
    _completedTasks = completedTasks;
    notifyListeners();
  }

  void markTaskCompleted() {
    if (_pendingTasks > 0) {
      _pendingTasks -= 1;
    }
    _completedTasks += 1;
    notifyListeners();
  }

  void addPendingTask() {
    _pendingTasks += 1;
    notifyListeners();
  }

  void reset() {
    _pendingTasks = 0;
    _completedTasks = 0;
    notifyListeners();
  }
}