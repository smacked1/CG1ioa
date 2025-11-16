import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import '../models/grocery_item.dart';
import '../services/item_store.dart';
import 'item_detail_view.dart';
import 'item_edit_view.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  final ItemStore _store = ItemStore();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    await _store.load();
    setState(() {});
  }

  Map<String, List<GroceryItem>> _getGroupedItems() {
    List<GroceryItem> items = _store.items;

    if (_searchQuery.isNotEmpty) {
      final lowerQuery = _searchQuery.toLowerCase();
      items = items.where((item) {
        return item.name.toLowerCase().contains(lowerQuery) ||
            item.category.toLowerCase().contains(lowerQuery) ||
            item.notes.toLowerCase().contains(lowerQuery);
      }).toList();
    }

    final Map<String, List<GroceryItem>> grouped = {};
    for (final item in items) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }

    // Sort categories alphabetically
    final sortedKeys = grouped.keys.toList()..sort();
    return Map.fromEntries(
      sortedKeys.map((key) => MapEntry(key, grouped[key]!)),
    );
  }

  Future<void> _toggleStar(GroceryItem item) async {
    final updated = item.copyWith(starred: !item.starred);
    await _store.update(updated);
    setState(() {});
  }

  Future<void> _deleteItem(GroceryItem item) async {
    await _store.delete(item.id);
    setState(() {});
  }

  void _navigateToDetail(GroceryItem item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailView(itemId: item.id),
      ),
    );
    _loadItems();
  }

  void _navigateToEdit([GroceryItem? item]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemEditView(item: item),
      ),
    );
    _loadItems();
  }

  Future<void> _exportData() async {
    final items = _store.items;
    final jsonData = items.map((item) => item.toJson()).toList();
    final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);
    
    await Share.share(
      jsonString,
      subject: 'ChefGrocer Shopping List Export',
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupedItems = _getGroupedItems();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _exportData,
            tooltip: 'Export JSON',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search items...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: groupedItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No items found',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: groupedItems.length,
                    itemBuilder: (context, index) {
                      final category = groupedItems.keys.elementAt(index);
                      final items = groupedItems[category]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Sticky Header
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            color: Theme.of(context).colorScheme.primaryContainer,
                            child: Text(
                              category,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                          // Items in category
                          ...items.map((item) => Dismissible(
                                key: Key(item.id),
                                background: Container(
                                  color: Colors.amber,
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.only(left: 20),
                                  child: const Icon(
                                    Icons.star,
                                    color: Colors.white,
                                  ),
                                ),
                                secondaryBackground: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                confirmDismiss: (direction) async {
                                  if (direction == DismissDirection.startToEnd) {
                                    // Swipe to star
                                    await _toggleStar(item);
                                    return false;
                                  } else {
                                    // Swipe to delete
                                    return await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete Item'),
                                        content: Text(
                                          'Are you sure you want to delete "${item.name}"?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                },
                                onDismissed: (direction) {
                                  if (direction == DismissDirection.endToStart) {
                                    _deleteItem(item);
                                  }
                                },
                                child: Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  child: ListTile(
                                    leading: IconButton(
                                      icon: Icon(
                                        item.starred ? Icons.star : Icons.star_border,
                                        color: item.starred ? Colors.amber : null,
                                      ),
                                      onPressed: () => _toggleStar(item),
                                    ),
                                    title: Text(
                                      item.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text('${item.quantity} ${item.unit}'),
                                    trailing: PopupMenuButton(
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit),
                                              SizedBox(width: 8),
                                              Text('Edit'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete),
                                              SizedBox(width: 8),
                                              Text('Delete'),
                                            ],
                                          ),
                                        ),
                                      ],
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          _navigateToEdit(item);
                                        } else if (value == 'delete') {
                                          _deleteItem(item);
                                        }
                                      },
                                    ),
                                    onTap: () => _navigateToDetail(item),
                                  ),
                                ),
                              )),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEdit(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
