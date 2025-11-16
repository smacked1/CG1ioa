import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/grocery_item.dart';

class ItemStore {
  static final ItemStore _instance = ItemStore._internal();
  factory ItemStore() => _instance;
  ItemStore._internal();

  List<GroceryItem> _items = [];
  String? _filePath;

  List<GroceryItem> get items => List.unmodifiable(_items);

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    if (_filePath == null) {
      final path = await _localPath;
      _filePath = '$path/grocery_items.json';
    }
    return File(_filePath!);
  }

  Future<void> load() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonData = json.decode(contents);
        _items = jsonData.map((item) => GroceryItem.fromJson(item)).toList();
      } else {
        _items = [];
      }
    } catch (e) {
      print('Error loading items: $e');
      _items = [];
    }
  }

  Future<void> save() async {
    try {
      final file = await _localFile;
      final jsonData = _items.map((item) => item.toJson()).toList();
      await file.writeAsString(json.encode(jsonData));
    } catch (e) {
      print('Error saving items: $e');
    }
  }

  Future<void> add(GroceryItem item) async {
    _items.add(item);
    await save();
  }

  Future<void> update(GroceryItem updatedItem) async {
    final index = _items.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      _items[index] = updatedItem;
      await save();
    }
  }

  Future<void> delete(String id) async {
    _items.removeWhere((item) => item.id == id);
    await save();
  }

  GroceryItem? getById(String id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  List<GroceryItem> search(String query) {
    if (query.isEmpty) return items;
    final lowerQuery = query.toLowerCase();
    return _items.where((item) {
      return item.name.toLowerCase().contains(lowerQuery) ||
          item.category.toLowerCase().contains(lowerQuery) ||
          item.notes.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  List<GroceryItem> filterByCategory(String category) {
    if (category.isEmpty) return items;
    return _items.where((item) => item.category == category).toList();
  }

  List<GroceryItem> getStarred() {
    return _items.where((item) => item.starred).toList();
  }

  List<String> getCategories() {
    final categories = _items.map((item) => item.category).toSet().toList();
    categories.sort();
    return categories;
  }
}
