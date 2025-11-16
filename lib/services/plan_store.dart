import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/weekly_plan.dart';

class PlanStore {
  static final PlanStore _instance = PlanStore._internal();
  factory PlanStore() => _instance;
  PlanStore._internal();

  WeeklyPlan? _currentPlan;
  String? _filePath;

  WeeklyPlan? get currentPlan => _currentPlan;

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    if (_filePath == null) {
      final path = await _localPath;
      _filePath = '$path/weekly_plan.json';
    }
    return File(_filePath!);
  }

  Future<void> load() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        final jsonData = json.decode(contents);
        _currentPlan = WeeklyPlan.fromJson(jsonData);
      } else {
        _currentPlan = WeeklyPlan.create(
          weekStartDate: _getMonday(DateTime.now()),
        );
      }
    } catch (e) {
      print('Error loading weekly plan: $e');
      _currentPlan = WeeklyPlan.create(
        weekStartDate: _getMonday(DateTime.now()),
      );
    }
  }

  Future<void> save() async {
    if (_currentPlan == null) return;
    try {
      final file = await _localFile;
      await file.writeAsString(json.encode(_currentPlan!.toJson()));
    } catch (e) {
      print('Error saving weekly plan: $e');
    }
  }

  Future<void> updatePlan(WeeklyPlan plan) async {
    _currentPlan = plan;
    await save();
  }

  Future<void> addMealToDay(String day, String mealId) async {
    if (_currentPlan == null) return;
    final meals = List<String>.from(_currentPlan!.mealsByDay[day] ?? []);
    meals.add(mealId);
    final updatedPlan = _currentPlan!.copyWith(
      mealsByDay: {..._currentPlan!.mealsByDay, day: meals},
    );
    await updatePlan(updatedPlan);
  }

  Future<void> removeMealFromDay(String day, String mealId) async {
    if (_currentPlan == null) return;
    final meals = List<String>.from(_currentPlan!.mealsByDay[day] ?? []);
    meals.remove(mealId);
    final updatedPlan = _currentPlan!.copyWith(
      mealsByDay: {..._currentPlan!.mealsByDay, day: meals},
    );
    await updatePlan(updatedPlan);
  }

  DateTime _getMonday(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }
}
