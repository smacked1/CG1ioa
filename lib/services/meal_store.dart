import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/meal.dart';

class MealStore {
  static final MealStore _instance = MealStore._internal();
  factory MealStore() => _instance;
  MealStore._internal();

  List<Meal> _meals = [];
  String? _filePath;

  List<Meal> get meals => List.unmodifiable(_meals);

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    if (_filePath == null) {
      final path = await _localPath;
      _filePath = '$path/meals.json';
    }
    return File(_filePath!);
  }

  Future<void> load() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonData = json.decode(contents);
        _meals = jsonData.map((meal) => Meal.fromJson(meal)).toList();
      } else {
        _meals = [];
      }
    } catch (e) {
      print('Error loading meals: $e');
      _meals = [];
    }
  }

  Future<void> save() async {
    try {
      final file = await _localFile;
      final jsonData = _meals.map((meal) => meal.toJson()).toList();
      await file.writeAsString(json.encode(jsonData));
    } catch (e) {
      print('Error saving meals: $e');
    }
  }

  Future<void> add(Meal meal) async {
    _meals.add(meal);
    await save();
  }

  Future<void> update(Meal updatedMeal) async {
    final index = _meals.indexWhere((meal) => meal.id == updatedMeal.id);
    if (index != -1) {
      _meals[index] = updatedMeal;
      await save();
    }
  }

  Future<void> delete(String id) async {
    _meals.removeWhere((meal) => meal.id == id);
    await save();
  }

  Meal? getById(String id) {
    try {
      return _meals.firstWhere((meal) => meal.id == id);
    } catch (e) {
      return null;
    }
  }
}
