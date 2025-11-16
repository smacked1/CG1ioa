import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/budget.dart';

class BudgetStore {
  static final BudgetStore _instance = BudgetStore._internal();
  factory BudgetStore() => _instance;
  BudgetStore._internal();

  Map<String, BudgetItem> _budgetItems = {};
  List<PriceCalculation> _calculations = [];
  String? _budgetFilePath;
  String? _calcFilePath;

  Map<String, BudgetItem> get budgetItems => Map.unmodifiable(_budgetItems);
  List<PriceCalculation> get calculations => List.unmodifiable(_calculations);

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _budgetFile async {
    if (_budgetFilePath == null) {
      final path = await _localPath;
      _budgetFilePath = '$path/budget_items.json';
    }
    return File(_budgetFilePath!);
  }

  Future<File> get _calcFile async {
    if (_calcFilePath == null) {
      final path = await _localPath;
      _calcFilePath = '$path/price_calculations.json';
    }
    return File(_calcFilePath!);
  }

  Future<void> load() async {
    await _loadBudgetItems();
    await _loadCalculations();
  }

  Future<void> _loadBudgetItems() async {
    try {
      final file = await _budgetFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        final Map<String, dynamic> jsonData = json.decode(contents);
        _budgetItems = jsonData.map(
          (key, value) => MapEntry(key, BudgetItem.fromJson(value)),
        );
      } else {
        _budgetItems = {};
      }
    } catch (e) {
      print('Error loading budget items: $e');
      _budgetItems = {};
    }
  }

  Future<void> _loadCalculations() async {
    try {
      final file = await _calcFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonData = json.decode(contents);
        _calculations = jsonData
            .map((calc) => PriceCalculation.fromJson(calc))
            .toList();
      } else {
        _calculations = [];
      }
    } catch (e) {
      print('Error loading calculations: $e');
      _calculations = [];
    }
  }

  Future<void> saveBudgetItems() async {
    try {
      final file = await _budgetFile;
      final jsonData = _budgetItems.map(
        (key, value) => MapEntry(key, value.toJson()),
      );
      await file.writeAsString(json.encode(jsonData));
    } catch (e) {
      print('Error saving budget items: $e');
    }
  }

  Future<void> saveCalculations() async {
    try {
      final file = await _calcFile;
      final jsonData = _calculations.map((calc) => calc.toJson()).toList();
      await file.writeAsString(json.encode(jsonData));
    } catch (e) {
      print('Error saving calculations: $e');
    }
  }

  Future<void> updateItemCost(String itemId, double cost) async {
    _budgetItems[itemId] = BudgetItem(
      groceryItemId: itemId,
      cost: cost,
      updatedAt: DateTime.now(),
    );
    await saveBudgetItems();
  }

  double getItemCost(String itemId) {
    return _budgetItems[itemId]?.cost ?? 0.0;
  }

  Future<void> addCalculation(PriceCalculation calculation) async {
    _calculations.insert(0, calculation);
    if (_calculations.length > 50) {
      _calculations = _calculations.sublist(0, 50);
    }
    await saveCalculations();
  }

  Future<void> clearCalculations() async {
    _calculations = [];
    await saveCalculations();
  }
}
